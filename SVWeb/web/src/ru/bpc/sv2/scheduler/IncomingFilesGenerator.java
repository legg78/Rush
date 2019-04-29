package ru.bpc.sv2.scheduler;

import au.com.forward.threads.ThreadException;
import au.com.forward.threads.ThreadReturn;
import oracle.jdbc.internal.OracleTypes;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.vfs.*;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.SecurityDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.scheduler.process.*;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.security.RsaKey;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.MaskFileSelector;
import ru.bpc.sv2.utils.UserException;

import javax.annotation.Resource;
import javax.sql.DataSource;
import java.io.*;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;
import java.util.zip.GZIPInputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class IncomingFilesGenerator {

	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	private static final String UNZIPPED_EXT = ".unzipped";
	private static final String UNTARRED_EXT = ".untarred";

	private ProcessFileAttribute file = null;
	private ProcessSession sess = null;
	private ProcessBO proc = null;

	private ProcessDao processDao;
	private Long userSessionId;
	private String userName;

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer threadNumber;

	public IncomingFilesGenerator(ProcessFileAttribute file,
								  ProcessSession sess,
								  ProcessBO proc,
								  ProcessDao processDao,
								  Long userSessionId,
								  String userName,
								  Integer traceLevel,
								  Integer traceLimit,
								  Integer threadNumber) {
		this.file = file;
		this.sess = sess;
		this.proc = proc;
		this.processDao = processDao;
		this.userSessionId = userSessionId;
		this.userName = userName;
		this.traceLevel = traceLevel;
		this.traceLimit = traceLimit;
		this.threadNumber = threadNumber;
	}

	public void generate() throws Exception {
		generate(null);
	}

	public void generate(Map<String, Object> uiParams) throws Exception {
		logger.info("File loading ... [Session id: " + sess.getSessionId() + "]");

		Integer processedFilesSaver = 0;
		Integer expectedFilesSaver = 0;

		if (file.getSaverClass() != null) {
			FileSaver saver = (FileSaver) createObject(file.getSaverClass());
			if (!saver.isRequiredInFiles()) {
				Connection con = null;
				try {
					con = JndiUtils.getConnection();
					saver.setConnection(con);
					saver.setFileAttributes(file);
					saver.setSessionId(sess.getSessionId());
					saver.setUserSessionId(userSessionId);
					saver.setUserName(userName);
					saver.setProcess(proc);
					saver.setParams(uiParams);
					saver.setTraceLevel(traceLevel);
					saver.setTraceLimit(traceLimit);
					saver.setTraceThreadNumber(threadNumber);
					saver.save();
					if (saver.getOutParams() != null) {
						processedFilesSaver = (saver.getOutParams().get("processedFiles") != null) ? (Integer) saver.getOutParams().get("processedFiles") : 0;
						expectedFilesSaver = (saver.getOutParams().get("expectedFiles") != null) ? (Integer) saver.getOutParams().get("expectedFiles") : 0;
					}
				} finally {
					DBUtils.close(con);
				}
			}
		}

		FileSystemManager fsManager;
		CallableStatement cstmt = null;
		Connection con = null;
		int numthreadsAppServer = 1; // TODO make like numthreadsAll
		InputStream inputStream = null;
		String newName;
		int expectedFiles = 0;
		int processedFiles = 0;
		int unprocessedFiles = 0;

		try {
			int fileThreadsNumber = numthreadsAppServer;
			if (file.isXml()) {
				fileThreadsNumber = 1;
			}

			fsManager = VFS.getManager();

			if (file.getLocation() == null) {
				return;
			}
			FileObject locationV = fsManager.resolveFile(file.getLocation());
			boolean isDirectory = FileType.FOLDER.equals(locationV.getType());

			con = JndiUtils.getConnection();
			String message;
			if (isDirectory) {
				message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "looking_for_files", file.getLocation());
				logger.info(message);
				loggerDB.debug(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));

				// FileObject cannot correctly process PatternSyntaxException 
				// during regexp compilation in MaskFileSelector. (It just throws out FileNotFoundException)
				// So we need to check regexp before findFiles() will be called. 
				// We will do this by Pattern.compile()!

				logger.info("Mask for file searching: " + file.getFileNameMask());
				if (file.getFileNameMask() == null) {
					file.setFileNameMask("");
				}
				try {
					//noinspection ResultOfMethodCallIgnored
					Pattern.compile(file.getFileNameMask());
				} catch (PatternSyntaxException e) {
					throw new UserException("Regular expression error: " + e.getMessage(), e);
				}

				FileSelector selector = new MaskFileSelector(file.getFileNameMask());
				FileObject[] fileObjects = locationV.findFiles(selector);
				locationV.close();
				try {
					Arrays.sort(fileObjects, new Comparator<FileObject>() {
						@Override
						public int compare(FileObject o1, FileObject o2) {
							//noinspection unchecked
							return o1.getName().getBaseName().toLowerCase().compareTo(o2.getName().getBaseName().toLowerCase());
						}
					});
				} catch (Exception ignored) {
				}
				expectedFiles = fileObjects.length;
				message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "files_found", expectedFiles);
				logger.info(message);
				loggerDB.debug(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));

				ProcessIncomingFileBody[] fileThreadsBody;

				List<String> processedFileObjects = new ArrayList<String>();

				Thread[] fileThreads = new Thread[fileThreadsNumber];
				for (FileObject fileObject : fileObjects) {
					ProcessFileAttribute tmpFile;
					fileThreadsBody = new ProcessIncomingFileBody[fileThreadsNumber];
					boolean fileProcessed = false;
					try {
						logger.info("The file has been found: " + fileObject.getName().getBaseName());

						String processedFolder = FilenameUtils.concat(file.getLocation(), ProcessConstants.PROCESSED_FOLDER);
						String rejectedFolder = FilenameUtils.concat(file.getLocation(), ProcessConstants.REJECTED_FOLDER);
						String inProcessFolder = FilenameUtils.concat(file.getLocation(), ProcessConstants.IN_PROCESS_FOLDER);

						try {
							cstmt = con.prepareCall("{call prc_api_session_pkg.start_session(io_session_id => ? , i_container_id => ?)}");
							cstmt.setLong(1, sess.getSessionId());
							cstmt.setLong(2, proc.getContainerBindId());
							cstmt.execute();
						} finally {
							DBUtils.close(cstmt);
						}
						FileObject newFO = VFS.getManager().resolveFile(processedFolder);
						newFO.createFolder();
						newFO = VFS.getManager().resolveFile(rejectedFolder);
						newFO.createFolder();
						newFO = VFS.getManager().resolveFile(inProcessFolder);
						newFO.createFolder();

						String baseName = fileObject.getName().getBaseName();

						// move file being processed to "in_process" folder
						fileObject = renameFile(fileObject, FilenameUtils.concat(inProcessFolder, baseName));

						HashMap<String, FileObject> fileObjectsList = new HashMap<String, FileObject>();

						if (file.getIsZip() || file.getIsTar()) {
							message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "unpacking_file", baseName);
							logger.trace(message);
							loggerDB.trace(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));
							if (file.getIsZip() && file.getIsTar()) {
								FileObject tar = extractGZip(fsManager, fileObject);
								extractTar(fsManager, tar, fileObjectsList);
								tar.close();
								tar.delete();
							} else if (file.getIsZip()) {
								extractZip(fsManager, fileObject, fileObjectsList);
							} else if (file.getIsTar()) {
								extractTar(fsManager, fileObject, fileObjectsList);
							}
							message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "files_extracted", fileObjectsList.size());
							logger.trace(message);
							loggerDB.trace(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));
							expectedFiles += (fileObjectsList.size() == 0 ? 0 : fileObjectsList.size() - 1); // "-1" -- archive itself
						} else {
							fileObjectsList.put(baseName, fileObject);
						}

						for (String fileName : fileObjectsList.keySet()) {
							String pureFileName;
							if (file.getIsTar()) {
								// if file was just ".tar" or ".tar.gz" here we will deal with
								// untarred files anyway
								pureFileName = fileName.substring(0, fileName.lastIndexOf(UNTARRED_EXT));
							} else if (file.getIsZip()) {
								pureFileName = fileName.substring(0, fileName.lastIndexOf(UNZIPPED_EXT));
							} else {
								pureFileName = fileName;
							}

							FileObject nextObject = fileObjectsList.get(fileName);
							if (!file.getUploadEmptyFile()
									&& (nextObject.getContent() == null || nextObject.getContent().getSize() == 0)) {
								unprocessedFiles++;
								continue;
							}
							boolean processed = false;
							String fileStatus = null;

							file.setFileName(pureFileName);
							try {
								message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "opening_file", pureFileName);
								logger.trace(message);
								loggerDB.trace(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));

								try {
									cstmt = con.prepareCall("{call prc_api_file_pkg.open_file(	"
											+ "o_sess_file_id	 => ? "
											+ ", i_file_name 	 => ? " + ", i_file_purpose=> ? "
											+ ", i_file_type 	 => ?)}");

									cstmt.registerOutParameter(1, OracleTypes.BIGINT);
									cstmt.setString(2, pureFileName);
									cstmt.setString(3, file.getPurpose());
									cstmt.setString(4, file.getFileType());
									cstmt.execute();

									file.setSessionId((Long) cstmt.getObject(1));
									file.setProcessSessionId(sess.getSessionId());
									file.setContainerBindId(proc.getContainerBindId());
								} finally {
									DBUtils.close(cstmt);
								}

								message = "File opened, sess_file_id=" + file.getSessionId();
								logger.debug(message);
								loggerDB.debug(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));

								if (file.isSigned()
										&& !checkSignature(nextObject, sess.getSessionId(), pureFileName, proc.getId())) {
									message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "sig_verif_failed",
											pureFileName);
									logger.error(message + " Process ID = " + proc.getId() + ". Session ID = "
											+ sess.getSessionId());
									loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));
									unprocessedFiles++;
									continue;
								}
								// TODO check if this file has already been uploaded

								newName = FilenameUtils.concat(inProcessFolder, fileName);
								nextObject = renameFile(nextObject, newName);
								fileName = nextObject.getName().getBaseName();

								boolean valid = true;
								if (file.isXml()) {
									logger.debug("Starting XMLProcessor for file \"" + fileName + "\"");
									// If this is XML validation and XSLT must be performed
									XMLProcessor xmlProcessor = new XMLProcessor(file, nextObject, false, null);
									xmlProcessor.process();
									logger.debug("Getting stream from xmlProcessor \"" + fileName + "\"");
									valid = xmlProcessor.isValid();
									inputStream = xmlProcessor.getInputStream();
								}

								if (!valid) {
									newName = FilenameUtils.concat(rejectedFolder, nextObject.getName().getBaseName());
									renameFile(nextObject, newName).close();
									processed = true;    // TODO: why?
									unprocessedFiles++;
									continue;
								}

								try {
									tmpFile = file.clone();
								} catch (CloneNotSupportedException e) {
									tmpFile = new ProcessFileAttribute(file);
								}

								for (int j = 0; j < fileThreadsNumber; j++) {
									fileThreadsBody[j] = new ProcessIncomingFileBody(tmpFile, nextObject, sess.getSessionId(),
																					 inputStream, j, uiParams,
																					 traceLevel, traceLimit, threadNumber);
									fileThreads[j] = new Thread(fileThreadsBody[j]);
									logger.info("starting loading file: " +
											nextObject.getName().getURI() + "; thread number " + j);
									fileThreads[j].start();
								}

								for (int j = 0; j < fileThreadsNumber; j++) {
									Object obj = ThreadReturn.join(fileThreads[j]);
									if (obj != null) {
										ProcessIncomingFileBodyResult result = (ProcessIncomingFileBodyResult) obj;
										fileStatus = result.getFileStatus();
									}
								} // end for joining file threads

								logger.trace("Closing file \"" + nextObject.getName().getBaseName() + "\"");

								// move processed file to "processed" folder
								newName = FilenameUtils.concat(processedFolder, pureFileName);
								if (nextObject.exists()) {
									// we rename file if it exists, i.e. not renamed by saver
									renameFile(nextObject, newName).close();
								}

								logger.trace("File \"" + nextObject.getName().getBaseName() + "\" closed");
								processedFileObjects.add(newName);
								processed = true;
								processedFiles++;
							} catch (Exception e) {
								if (e instanceof ThreadException && e.getCause() instanceof Exception)
									e = (Exception) e.getCause();
								unprocessedFiles++;
								if (file.isIgnoreFileErrors()) {
									logger.error(e.getMessage(), e);
									loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), e.getMessage()), e);

									message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process",
											"ignore_file_errors_continue_upload");
									logger.trace(message);
									loggerDB.trace(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));
								} else {
									throw e;
								}
							} finally {
								IOUtils.closeQuietly(inputStream);
								if (processed) {
									fileProcessed = true;
								} else {
									try {
										newName = FilenameUtils.concat(rejectedFolder, pureFileName);
										renameFile(nextObject, newName).close();
									} catch (FileSystemException e) {
										message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process",
												"unprocessed_file_move_failed");
										logger.error(message, e);
										loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), message));
									}
								}
								try {
									nextObject.close();
								} catch (Exception ignored) {
								}
								if (file.getSessionId() != null) {
									try {
										cstmt = con.prepareCall("{call prc_api_file_pkg.close_file(	"
												+ "i_sess_file_id	 => ?, i_status => ?)}");
										cstmt.setLong(1, file.getSessionId());
										if (fileStatus != null) {
											cstmt.setString(2, fileStatus);
										} else if (processed) {
											cstmt.setString(2, ProcessConstants.FILE_STATUS_ACCEPTED);
										} else {
											cstmt.setString(2, ProcessConstants.FILE_STATUS_REJECT);
										}
										cstmt.execute();
									} catch (Exception ignored) {
									} finally {
										DBUtils.close(cstmt);
									}
								}
							}
						}
						if (file.getIsZip() || file.getIsTar()) {
							if (fileProcessed) {
								newName = FilenameUtils.concat(processedFolder, fileObject.getName().getBaseName());
							} else {
								newName = FilenameUtils.concat(rejectedFolder, fileObject.getName().getBaseName());
							}
							fileObject = renameFile(fileObject, newName);
							// we can never reach this section that's why FileObject for zip file is
							// closed in finally
						}
					} catch (Exception e) {
						// In the case of exception we want ot move all successfully processed files back to original location
						for (String processedFileName : processedFileObjects) {
							FileObject fo = VFS.getManager().resolveFile(processedFileName);
							renameFile(fo, VFS.getManager().resolveFile(locationV, FilenameUtils.getName(processedFileName)));
						}
						throw e;
					} finally {
						if (file.getIsZip() || file.getIsTar()) {
							try {
								fileObject.close();
							} catch (FileSystemException ignored) {
							}
						}
					}
				}
			} else {
				logger.error(String.format("File location %s is not a directory", locationV.getName()));
			}
		} finally {
			DBUtils.close(cstmt);
			DBUtils.close(con);
			logger.info("File loading has been completed... [Session id: " + sess.getSessionId() + "]");

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "incoming_files_result", expectedFiles + expectedFilesSaver,
					processedFiles + processedFilesSaver, unprocessedFiles);
			logger.debug(msg);
			loggerDB.debug(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg));
		}
	}

	private void extractZip(FileSystemManager fsManager, FileObject fileObject,
	                        HashMap<String, FileObject> fileObjectsList) throws Exception {
		byte[] buf = new byte[1024];
		ZipEntry zipEntry;
		ZipInputStream zipInputStream = null;
		FileOutputStream fos = null;

		try {
			zipInputStream = new ZipInputStream(fileObject.getContent().getInputStream());
			zipEntry = zipInputStream.getNextEntry();
			while (zipEntry != null) {
				// for each entry to be extracted
				String entryName = zipEntry.getName();
				System.out.println("entryname " + entryName);
				entryName += UNZIPPED_EXT;

				int n;
				File newFile = new File(entryName);
				String directory = newFile.getParent();

				if (directory == null && newFile.isDirectory()) {
					break;
				}

				// if parent is windows root directory (i.e. "c:/" or "d:/")
				// fileObject.getParent().getName().getPath() will return just "/" without drive
				// letter
				// that's why we have to get parent path using URL.
				String filePath = fileObject.getParent().getURL().getFile().substring(2);
				if (!filePath.endsWith("/")) {
					filePath += "/";
				}
				filePath += entryName;

				fos = new FileOutputStream(filePath);

				while ((n = zipInputStream.read(buf, 0, 1024)) > -1) {
					fos.write(buf, 0, n);
				}

				fos.close();
				zipInputStream.closeEntry();
				zipEntry = zipInputStream.getNextEntry();

				FileObject zippedFO = fsManager.resolveFile(filePath);
				fileObjectsList.put(zippedFO.getName().getBaseName(), zippedFO);
			}
		} finally {
			if (zipInputStream != null) {
				try {
					zipInputStream.close();
				} catch (IOException e) {
					String msg = "Couldn't close ZIP input stream.";
					logger.error(msg, e);
					loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg), e);
				}
			}
			if (fos != null) {
				try {
					fos.close();
				} catch (IOException e) {
					String msg = "Couldn't close file output stream.";
					logger.error(msg, e);
					loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg), e);
				}
			}
		}
	}

	private void extractTar(FileSystemManager fsManager, FileObject fileObject,
	                        HashMap<String, FileObject> fileObjectsList) throws Exception {
		byte[] buf = new byte[1024];
		TarArchiveEntry tarEntry;
		TarArchiveInputStream tarInputStream = null;
		FileOutputStream fos = null;

		try {
			tarInputStream = new TarArchiveInputStream(fileObject.getContent().getInputStream());
			tarEntry = (TarArchiveEntry) tarInputStream.getNextEntry();
			while (tarEntry != null) {
				// for each entry to be extracted
				String entryName = tarEntry.getName();
				System.out.println("entryname " + entryName);
				entryName += UNTARRED_EXT;

				int n;
				File newFile = new File(entryName);
				String directory = newFile.getParent();

				if (directory == null && newFile.isDirectory()) {
					break;
				}

				String filePath = fileObject.getParent().getURL().getFile().substring(2);
				if (!filePath.endsWith("/")) {
					filePath += "/";
				}
				filePath += entryName;

				fos = new FileOutputStream(filePath);

				while ((n = tarInputStream.read(buf, 0, 1024)) > -1) {
					fos.write(buf, 0, n);
				}

				fos.close();
				tarEntry = (TarArchiveEntry) tarInputStream.getNextEntry();

				FileObject zippedFO = fsManager.resolveFile(filePath);
				fileObjectsList.put(zippedFO.getName().getBaseName(), zippedFO);
			}
		} finally {
			if (tarInputStream != null) {
				try {
					tarInputStream.close();
				} catch (IOException e) {
					String msg = "Couldn't close TAR input stream.";
					logger.error(msg, e);
					loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg), e);
				}
			}
			if (fos != null) {
				try {
					fos.close();
				} catch (IOException e) {
					String msg = "Couldn't close file output stream.";
					logger.error(msg, e);
					loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg), e);
				}
			}
		}
	}

	private FileObject extractGZip(FileSystemManager fsManager, FileObject fileObject) throws Exception {
		int buffer = 2048;
		byte[] data = new byte[buffer];
		BufferedInputStream in = null;
		OutputStream out = null;
		GZIPInputStream gzIn = null;

		try {
			in = new BufferedInputStream(fileObject.getContent().getInputStream());
			gzIn = new GZIPInputStream(in);

			String tarFileName = getTarFileName(fileObject);
			FileObject tar = fsManager.resolveFile(tarFileName);
			tar.createFile();
			out = tar.getContent().getOutputStream();

			int n;
			while ((n = gzIn.read(data, 0, buffer)) > -1) {
				out.write(data, 0, n);
			}

			out.close();
			return tar;
		} finally {
			if (in != null) {
				try {
					in.close();
				} catch (IOException e) {
					String msg = "Couldn't close input stream.";
					logger.error(msg, e);
					loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg), e);
				}
			}
			if (gzIn != null) {
				try {
					gzIn.close();
				} catch (IOException e) {
					String msg = "Couldn't close GZIP input stream.";
					logger.error(msg, e);
					loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg), e);
				}
			}
			if (out != null) {
				try {
					out.close();
				} catch (IOException e) {
					String msg = "Couldn't close file output stream.";
					logger.error(msg, e);
					loggerDB.error(new TraceLogInfo(sess.getSessionId(), getPrcContainerBindId(), msg), e);
				}
			}
		}
	}

	/**
	 * <p>
	 * Usually zipped tars have name like "name.tar.gz", but it could be any other name and we have
	 * to get correct name for compressed archive.
	 * </p>
	 *
	 * @param fileObject - gzipped tar file
	 * @return tar file name
	 * @throws FileSystemException
	 */
	private String getTarFileName(FileObject fileObject) throws FileSystemException {
		String tarFileName = fileObject.getURL().getFile().substring(2);
		if (tarFileName.endsWith("/")) {
			tarFileName = tarFileName.substring(0, tarFileName.length() - 1);
		}
		int extIndex = tarFileName.lastIndexOf('.');
		if (extIndex < tarFileName.lastIndexOf('/')) {
			tarFileName += ".tar";
		} else {
			tarFileName = tarFileName.substring(0, tarFileName.lastIndexOf('.'));
			if (!tarFileName.endsWith(".tar")) {
				tarFileName += ".tar";
			}
		}
		return tarFileName;
	}

	private class ProcessIncomingFileBodyResult {
		private String fileStatus;

		String getFileStatus() {
			return fileStatus;
		}

		void setFileStatus(String fileStatus) {
			this.fileStatus = fileStatus;
		}
	}

	private class ProcessIncomingFileBody implements Runnable {
		private ProcessFileAttribute file;
		private FileObject fileObject;
		private Long sessionId;
		private int num;
		private InputStream inputStream;
		private Map<String, Object> params;

		private Integer traceLevel;
		private Integer traceLimit;
		private Integer threadNumber;

		ProcessIncomingFileBody(ProcessFileAttribute file,
								FileObject fileObject,
								Long sessionId,
								InputStream inputStream,
								int num,
								Map<String, Object> params,
								Integer traceLevel,
								Integer traceLimit,
								Integer threadNumber) {
			this.file = file;
			this.fileObject = fileObject;
			this.sessionId = sessionId;
			this.num = num;
			this.inputStream = inputStream;
			this.params = params;
			this.traceLevel = traceLevel;
			this.traceLimit = traceLimit;
			this.threadNumber = threadNumber;
		}

		@Override
		public void run() {
			Connection con = null;

			FileSaver saver;

			try {
				con = JndiUtils.getConnection();

				// Define associated saver
				if (file.getSaverClass() != null && ((FileSaver) createObject(file.getSaverClass())).isRequiredInFiles()) {
					saver = (FileSaver) createObject(file.getSaverClass());
				} else {
					// If saverClass is not defined then use default simple savers
					if (file.isXml()) {
						saver = new SimpleXMLFileSaver();
					} else if (file.isLob()) {
						saver = new SimpleClobFileSaver();
					} else if (file.isBlob()) {
						saver = new SimpleBlobFileSaver();
					} else {
						saver = new SimpleFileSaver();
					}
				}
				saver.setParams(params);
				if (inputStream == null) {
					logger.trace("Getting stream from fileObject");
					inputStream = fileObject.getContent().getInputStream();
				}
				// Define associated converter
				FileConverter converter = null;
				if (file.getConverterClass() != null) {
					converter = (FileConverter) createObject(file.getConverterClass());
				}
				logger.info("Using file saver: " + saver.getClass());
				saver.setConnection(con);
				saver.setConverter(converter);
				saver.setInputStream(inputStream);
				saver.setFileAttributes(file);
				saver.setFileObject(fileObject);
				saver.setThreadNum(num);
				saver.setSessionId(sessionId);
				saver.setUserSessionId(userSessionId);
				saver.setUserName(userName);
				saver.setProcess(proc);
				saver.setTraceLevel(traceLevel);
				saver.setTraceLimit(traceLimit);
				saver.setTraceThreadNumber(threadNumber);
				saver.save();

				if (saver instanceof ResultableFileSaver) {
					ResultableFileSaver rfs = (ResultableFileSaver) saver;
					String fileStatus = rfs.getFileStatus();
					ProcessIncomingFileBodyResult result = new ProcessIncomingFileBodyResult();
					result.setFileStatus(fileStatus);
					ThreadReturn.save(result);
				}

			} catch (Exception e) {
				logger.error("Exception:", e);
				loggerDB.error(new TraceLogInfo(sess.getSessionId(), "Error. File name: " + file.getFileName(), num), e);
				ThreadReturn.save(e);
			} finally {
				DBUtils.close(con);
				IOUtils.closeQuietly(inputStream);
				try {
					fileObject.close();
				} catch (Exception ignored) {
				}
			}
		}
	}

	private static Object createObject(String className) {
		Object object;
		try {
			Class<?> classDefinition = Class.forName(className);
			object = classDefinition.newInstance();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			throw new RuntimeException("Could not instantiate object of class " + className + ": " + e.getMessage(), e);
		}
		return object;
	}

	private FileObject renameFile(FileObject fileObject, String newName) throws FileSystemException {
		return renameFile(fileObject, VFS.getManager().resolveFile(newName));
	}

	private FileObject renameFile(FileObject fileObject, FileObject newFileObject) throws FileSystemException {
		fileObject.moveTo(newFileObject);
		fileObject.close();
		return newFileObject;
	}

	private boolean checkSignature(FileObject file, Long sessionId, String fileName, Integer processId) {
		HashMap<String, Object> params = new HashMap<String, Object>(2);
		params.put("processId", processId);
		params.put("sessionId", sessionId);
		params.put("fileName", fileName + ProcessConstants.SIGNATURE_SUFFIX);

		String[] signs;
		String signature = "";
		try {
			signs = processDao.getFileRawData(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			return false;
		}
		if (signs.length <= 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "no_sign_for_file", fileName);
			logger.error(msg + " (processId = " + processId + ", sessionId = " + sessionId + ")");
			loggerDB.error(msg);
			return false;
		} else {
			for (String sign : signs) {
				signature += sign;
			}
		}

		String securityKey = getSecurityKey();
		if (securityKey == null) {
			return false;
		}
		SignatureEncryptor sig = (SignatureEncryptor) createObject(this.file.getEncryptionPlugin());
		if (sig == null) {
			return false;
		}

		try {
			return sig.checkFile(file, signature, securityKey);
		} catch (Exception e) {
			logger.error("", e);
			return false;
		}
	}

	private String getSecurityKey() {
		SecurityDao secDao = new SecurityDao();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter("objectId", this.file.getId());
		filters[1] = new Filter("entityType", EntityNames.FILE_ATTRIBUTE);
		SelectionParams params = new SelectionParams(filters);
		params.setUser(userName);

		try {
			RsaKey[] keys = secDao.getRsaKeys(userSessionId, params);
			if (keys.length == 0) {
				logger.info("Security key for file attribute (ID = " + this.file.getId() + ") wasn't found.");
				return null;
			}
			return keys[0].getPrivateKey();
		} catch (Exception e) {
			logger.error("", e);
			return null;
		}
	}

	private Integer getPrcContainerBindId() {
		return this.proc != null ? proc.getContainerBindId() : null;
	}
}

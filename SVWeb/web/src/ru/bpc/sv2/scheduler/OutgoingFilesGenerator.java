package ru.bpc.sv2.scheduler;

import oracle.jdbc.internal.OracleTypes;
import org.apache.commons.compress.archivers.ArchiveStreamFactory;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveOutputStream;
import org.apache.commons.io.IOUtils;
import org.apache.commons.vfs.*;
import org.apache.log4j.Logger;
import org.apache.commons.lang3.StringUtils;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.logic.SecurityDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.scheduler.process.*;
import ru.bpc.sv2.scheduler.process.converter.JasperReportOutFileConverter;
import ru.bpc.sv2.scheduler.process.converter.OutgoingFileConverter;
import ru.bpc.sv2.scheduler.process.mergeable.MergeableFileSaver;
import ru.bpc.sv2.scheduler.process.svng.ActiveMQSaver;
import ru.bpc.sv2.security.RsaKey;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.XsltConverter;
import ru.bpc.sv2.utils.*;

import javax.annotation.Resource;
import javax.sql.DataSource;
import javax.xml.parsers.DocumentBuilderFactory;

import java.io.*;
import java.sql.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.zip.GZIPOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

@SuppressWarnings("ResultOfMethodCallIgnored")
public class OutgoingFilesGenerator {

	private static final Logger logger = Logger.getLogger("PROCESSES");

	private ProcessDao processDao;
	private ReportsDao reportsDao;
	private CloseableBlockingQueue<ProcessFileAttribute> filesQueue;
	private Long userSessionId;
	private List<ProcessFileAttribute> processed;
	private List<ProcessFileAttribute> unprocessed;
	private Long sessionId;
	private Logger loggerDb;
	private String userName;
	private Integer containerId;
	private String predefinedArchiveName;

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer threadNumber;

	public OutgoingFilesGenerator(ProcessDao processDao,
								  ProcessFileAttribute[] files,
								  Long userSessionId,
								  String userName,
								  Integer containerId,
								  String predefinedArchiveName,
								  Integer traceLevel,
								  Integer traceLimit,
								  Integer threadNumber) {
		this.processDao = processDao;
		this.filesQueue = new CloseableArrayBlockingQueue<>(Math.max(files.length, 1));
		if (files.length > 0) {
			filesQueue.addAll(Arrays.asList(files));
		}
		filesQueue.close();
		this.userSessionId = userSessionId;
		this.userName = userName;
		this.containerId = containerId;
		this.predefinedArchiveName = predefinedArchiveName;
		this.reportsDao = new ReportsDao();
		this.traceLevel = traceLevel;
		this.traceLimit = traceLimit;
		this.threadNumber = threadNumber;
	}

	public OutgoingFilesGenerator(ProcessDao processDao,
								  ProcessFileAttribute[] files,
								  Long userSessionId,
								  String userName,
								  Integer containerId,
								  String predefinedArchiveName) {
		this(processDao, files, userSessionId, userName, containerId, predefinedArchiveName, null, null, null);
	}

	public OutgoingFilesGenerator(ProcessDao processDao,
								  ProcessFileAttribute[] files,
								  Long userSessionId,
								  String userName,
								  Integer containerId,
								  Integer traceLevel,
								  Integer traceLimit,
								  Integer threadNumber) {
		this(processDao, files, userSessionId, userName, containerId, null, traceLevel, traceLimit, threadNumber);
	}

	public OutgoingFilesGenerator(ProcessDao processDao,
								  CloseableBlockingQueue<ProcessFileAttribute> filesQueue,
								  Long userSessionId,
								  String userName,
								  Integer containerId,
								  Integer traceLevel,
								  Integer traceLimit,
								  Integer threadNumber) {
		this.processDao = processDao;
		this.filesQueue = filesQueue;
		this.userSessionId = userSessionId;
		this.userName = userName;
		this.containerId = containerId;
		this.reportsDao = new ReportsDao();
		this.traceLevel = traceLevel;
		this.traceLimit = traceLimit;
		this.threadNumber = threadNumber;
	}

	public void generate() throws Exception {
		generate(null);
	}

	public Future<Boolean> generateAsync(final Map<String, Object> uiParams) {
		logger.info("Starting OutgoingFilesGenerator in async mode");
		ExecutorService executor = Executors.newSingleThreadExecutor();
		return executor.submit(new Callable<Boolean>() {
			@Override
			public Boolean call() throws Exception {
				generate(uiParams);
				return true;
			}
		});
	}

	public void generate(Map<String, Object> uiParams) throws Exception {
		if (filesQueue.isClosedAndEmpty()) {
			return;
		}
		FileSystemManager fsManager;
		String newName;
		FileObject fileObject = null;
		InputStream fileContentsStream = null;
		Long fileSessionId = null;
		processed = new ArrayList<>();
		unprocessed = new ArrayList<>();
		boolean deleteUnFile = true;
		boolean isMqSaver;
		List<ProcessFileAttribute> filesWs = new ArrayList<>();
		ActiveMQSaver saverWs = null;
		CloseableBlockingQueue<ProcessFileAttribute> saverFilesQueue = null;
		Future<Boolean> saverWsResult = null;
		ProcessFileAttribute firstFile = null;
		ProcessFileAttribute nextFile = null;
		try {
			fsManager = VFS.getManager();

			HashMap<String, String> filesToArchive = new HashMap<>();
			String fileLocation = null;
			String archiveName = null;
			int lastFileId = 0;
			boolean toZip = false;
			boolean toTar = false;

			while (!filesQueue.isClosedAndEmpty()) {
				if (saverWsResult != null && saverWsResult.isDone()) {
					break;
				}
				nextFile = filesQueue.poll(1, TimeUnit.SECONDS);
				if (Thread.currentThread().isInterrupted()) {
					throw new SystemException("Outgoing files generation has been interrupted");
				}
				if (nextFile != null) {
					try (Connection con = JndiUtils.getConnection()) {
						// set process session to get correct environment (at least getFileName() needs it, may be some others too)
						initializeSession(con, sessionId, containerId);

						if (firstFile == null) {
							firstFile = nextFile;
							fileSessionId = firstFile.getSessionId();
							logger.info("Outgoing files generation... [Session id: " + fileSessionId + "]");
							fileLocation = firstFile.getLocation();
							lastFileId = firstFile.getFileId();
							toZip = firstFile.getIsZip();
							toTar = firstFile.getIsTar();
							if (toZip || toTar) {
								// as it's seen from code we need this filename only when we need archive otherwise file name is taken
								// from processFileName
								archiveName = predefinedArchiveName == null ? getFileName(con, firstFile) : predefinedArchiveName;
							}
						}
						logger.info(String.format("Saver class:%s; file:%s; location:%s; lastFileId:%d; toZip:%s; toTar:%s",
								nextFile.getSaverClass(), nextFile.getName(), nextFile.getLocation(), nextFile.getFileId(), String.valueOf(nextFile.getIsZip()), String.valueOf(nextFile.getIsTar())));
						isMqSaver = false;
						ProcessBO process = new ProcessBO();
						process.setContainerBindId(containerId);
						if (nextFile.getSaverClass() != null) {
							FileSaver saver = (FileSaver) createObject(nextFile.getSaverClass());
							saver.setUserSessionId(userSessionId);
							saver.setProcess(process);
							saver.setTraceLevel(traceLevel);
							saver.setTraceLimit(traceLimit);
							saver.setTraceThreadNumber(threadNumber);
							saver.setConnection(con);
							saver.setInputStream(fileContentsStream);
							saver.setFileAttributes(nextFile);
							saver.setFileObject(fileObject);
							saver.setSessionId(this.sessionId);
							saver.setUserName(userName);
							saver.setParams(uiParams);
							if (saver instanceof ru.bpc.sv2.scheduler.process.svng.ActiveMQSaver) {
								isMqSaver = true;
								if (saverWs == null) {
									saverWs = (ActiveMQSaver) createObject(nextFile.getSaverClass());
									saverWs.setFileAttributes(nextFile);
									saverWs.setParams(uiParams);
									saverWs.setSessionId(this.sessionId);
									saverWs.setUserSessionId(userSessionId);
									saverWs.setUserName(userName);
									saverWs.setProcess(process);
									saverFilesQueue = new CloseableArrayBlockingQueue<>(100);
									saverWs.setFilesQueue(saverFilesQueue);
									saverWsResult = saverWs.saveAsync();
									deleteUnFile = false;
								}

								saverFilesQueue.put(nextFile);
								filesWs.add(nextFile);

								if (nextFile.getLocation() == null || nextFile.getLocation().isEmpty()) {
									continue;
								}
							}
						}
						if ((toZip || toTar) && nextFile.getFileId() != lastFileId) {
							if (!filesToArchive.isEmpty()) {
								if (toZip && toTar) {
									FileObject tar = tarFiles(filesToArchive, fileLocation, archiveName, lastFileId);
									if (tar != null) {
										gzipTar(tar);
									}
								} else if (toZip) {
									zipFiles(filesToArchive, fileLocation, archiveName, lastFileId);
								} else if (toTar) {
									FileObject tar = tarFiles(filesToArchive, fileLocation, archiveName, lastFileId);
									if (tar != null) {
										tar.close();
									}
								}
							}
							filesToArchive = new HashMap<>();
							archiveName = predefinedArchiveName == null ? getFileName(con, nextFile) : predefinedArchiveName;
							fileLocation = nextFile.getLocation();
							lastFileId = nextFile.getFileId();
							toZip = nextFile.getIsZip();
							toTar = nextFile.getIsTar();
						}

						String generatedName = nextFile.getName();
						String location = nextFile.getLocation();
						if (location == null) {
							throw new Exception(String.format("ERROR: File '%s' (%s) does not have location specified",
															  nextFile.getProcessFileName(), nextFile.getName()));
						}
						String fileBaseName = nextFile.getName();
						if (generatedName == null) {
							generatedName = "generated_name";
						}
						if (generatedName.contains("/")) {
							//If file name contains "/", then use it as a location to save this file
							int lastPos = generatedName.lastIndexOf("/");
							location = generatedName.substring(0, lastPos + 1);
							fileBaseName = generatedName.substring(lastPos + 1);
						} else if (!location.endsWith("/") && !location.endsWith("\\")) {
							location += "/";
						}
						logger.debug("location:" + location);
						FileObject locationV = fsManager.resolveFile(location);
						if (!locationV.exists()) {
							try {
								locationV.createFolder();
								String msg = String.format("Folder '%s' has been created", location);
								logger.info(msg);
								loggerDb.info(new TraceLogInfo(this.sessionId, containerId, msg));
							} catch (FileSystemException e) {
								logger.error(e.getMessage());
								throw e;
							}
						}
						boolean isDirectory = FileType.FOLDER.equals(locationV.getType());
						logger.debug("isDirectory:" + isDirectory + " fileLocation:" + nextFile.getLocation());
						if (isDirectory) {
							String fullFileName;
							logger.info(String.format("Generating file %s to location %s; [sessionId:%d]",
									fileBaseName, location, fileSessionId));

							fullFileName = location + fileBaseName + ".TMP";
							fileObject = VFS.getManager().resolveFile(fullFileName);
							fileObject.createFile();
							String baseName = fileObject.getName().getBaseName();

							logger.trace("Openning file \"" + baseName + "\"");
							fileContentsStream = processDao.getSessionFileContentsStream(userSessionId, con,
																						 nextFile.getId(),
																						 nextFile.getCharacterSet(),
																						 nextFile.getLineSeparator().getSeparator());
							if (fileContentsStream == null) {
								fileContentsStream = new ByteArrayInputStream(new byte[0]);
							}
							boolean emptyFile = nextFile.isEmpty();
							if (nextFile.getSaverClass() != null && !"".equals(nextFile.getSaverClass()) && !isMqSaver) {
								FileSaver saver = (FileSaver) createObject(nextFile.getSaverClass());
								saver.setConnection(con);
								saver.setInputStream(fileContentsStream);
								saver.setFileAttributes(nextFile);
								saver.setFileObject(fileObject);
								saver.setProcess(process);
								saver.setSessionId(this.sessionId);
								saver.setUserName(userName);
								saver.setParams(uiParams);
								saver.setTraceLevel(traceLevel);
								saver.setTraceLimit(traceLimit);
								saver.setTraceThreadNumber(threadNumber);
								saver.save();
							} else if (nextFile.isReport()) {
								if (!emptyFile) {
									if (nextFile.getIsPasswordProtect()) {
										nextFile.setPassword(processDao.generateFilePassword(userSessionId, nextFile.getId()));
									}
									ReportTemplate[] templates = reportsDao.getReportTemplates(userSessionId, SelectionParams.build("id", nextFile.getReportTemplateId()));
									if (templates != null && templates.length > 0 && templates[0] != null && templates[0].isProcessorXslt()) {
										generateOutgoingProcessFileReportXslt(nextFile, fileObject, fileContentsStream);
									} else if (templates != null && templates.length > 0) {
										generateOutgoingProcessFileReportJasper(nextFile, fileObject, fileContentsStream, templates[0]);
									} else {
										generateOutgoingProcessFileReportJasper(nextFile, fileObject, fileContentsStream, null);
									}
								}
							} else if (nextFile.isXml()) {
								if (!emptyFile) {
									logger.debug("Starting XMLProcessor for file \"" + baseName + "\"");
									// If this is XML validation and XSLT must be performed
									XMLProcessor xmlProcessor = new XMLProcessor(nextFile, fileObject, false, null, fileContentsStream);
									xmlProcessor.process();
									if (!xmlProcessor.isValid()) {
										String msg = xmlProcessor.getValidationMessage();
										throw new UserException("Validation error: " + msg);
									}
									logger.debug("Getting stream from xmlProcessor \"" + baseName + "\"");
									fileContentsStream = xmlProcessor.getInputStream();
									generateOutgoingProcessFileXml(nextFile, fileObject, fileContentsStream);
									fileContentsStream.close();
								}
							} else if (nextFile.isLob() || nextFile.isBlob()) {
								if (!emptyFile) {
									generateOutgoingProcessFileXml(nextFile, fileObject, fileContentsStream);
								}
							} else {
								emptyFile = generateOutgoingProcessFileText(con, nextFile, fileObject);
							}

							FileObject fileSignature = null;
							if (nextFile.isSigned() && !emptyFile) {
								try {
									//byte[] signature = generateSignature(fileObject, nextFile);
									String signature = generateSignature(fileObject, nextFile);
									if (ProcessConstants.FILE_SIGNATURE_SEPARATELY.equals(nextFile.getSignatureType())) {
										fileSignature = VFS.getManager().resolveFile(
												location + fileBaseName + ProcessConstants.SIGNATURE_SUFFIX);
										fillSignatureFile(fileSignature, signature);
									}
									// TODO: add internal signature implementation
								} catch (Exception e) {
									String msg = "Error generating signature for file '" + fileBaseName + "': " + e.getMessage();
									logger.error(msg, e);
									loggerDb.error(new TraceLogInfo(this.sessionId, containerId, msg));
									// if a file should be signed and we didn't sign it - delete it and move to the next
									deleteFileObject(fileObject);
									continue;
								} finally {
									if (fileSignature != null) {
										fileSignature.close();
									}
								}
							}

							emptyFile = fileObject.getContent().getSize() == 0;

							if (!emptyFile || emptyFile && nextFile.getUploadEmptyFile()) {
								if (toZip || toTar) {
									filesToArchive.put(baseName.substring(0, baseName.length() - 4), getFilePath(fileObject));
									fileObject.close();
									if (fileSignature != null) {
										filesToArchive.put(fileSignature.getName().getBaseName(), getFilePath(fileSignature));
										fileSignature.close();
									}
								} else {
									newName = location + baseName.substring(0, baseName.length() - 4);
									fileObject.close();
									fileObject = renameFile(fileObject, newName);
									fileObject.close();
								}
							} else {
								deleteFileObject(fileObject);
							}
						}
						if (!isMqSaver) {
							processed.add(nextFile);
						}
					}
				}
			}

			try (Connection connect = JndiUtils.getConnection()) {
				MergeableFileSaver.writeTrailer(connect);
			}

			if (saverFilesQueue != null) {
				saverFilesQueue.close();
				// Waiting for MQ to finish
				try {
					saverWsResult.get();
				} catch (Throwable e) {
					while (e instanceof ExecutionException)
						e = e.getCause();
					throw e instanceof Exception ? (Exception) e : new RuntimeException(e.getMessage(), e);
				}
			}

			if (filesWs.size() > 0) {
				processed.addAll(filesWs);
			}

			if (!filesToArchive.isEmpty()) {
				if (toZip && toTar) {
					FileObject tar = tarFiles(filesToArchive, fileLocation, archiveName, lastFileId);
					if (tar != null) {
						gzipTar(tar);
					}
				} else if (toZip) {
					zipFiles(filesToArchive, fileLocation, archiveName, lastFileId);
				} else if (toTar) {
					FileObject tar = tarFiles(filesToArchive, fileLocation, archiveName, lastFileId);
					if (tar != null) {
						tar.close();
					}
				}
			}
		} catch (Exception e) {
			if (saverWsResult != null && !saverWsResult.isDone())
				saverWsResult.cancel(true);
			if (fileObject != null && deleteUnFile) {
				deleteFileObject(fileObject);
			}
			throw e;
		} finally {
			if (fileContentsStream != null) {
				if (fileContentsStream instanceof NamedFileInputStream)
					((NamedFileInputStream) fileContentsStream).closeAndDelete();
				else
					fileContentsStream.close();
			}
			if (fileObject != null) {
				fileObject.close();
			}
			if (nextFile != null && !processed.contains(nextFile))
				unprocessed.add(nextFile);
			while (!filesQueue.isEmpty()) {
				ProcessFileAttribute file = filesQueue.poll();
				if (file != null && !file.isEmpty())
					unprocessed.add(file);
			}
			if (saverWs != null && saverWs.isReject()) {
				unprocessed.add(new ProcessFileAttribute());
			}
			logger.info("Outgoing file generation has been completed... [Session id: " + fileSessionId + "]");
		}
	}

	private void deleteFileObject(FileObject fileObject) {
		try {
			fileObject.close();
			fileObject.delete();
		} catch (FileSystemException e) {
			logger.error(e.getMessage(), e);
		}
	}

	private void deleteFile(File file) {
		try {
			file.delete();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	private void generateOutgoingProcessFileReportJasper(ProcessFileAttribute file,
	                                                     FileObject fileObject,
	                                                     InputStream inputStream,
	                                                     ReportTemplate template) throws Exception {
		OutputStream out = fileObject.getContent().getOutputStream();
		try {
			JasperReportOutFileConverter jasperConverter = new JasperReportOutFileConverter();
			jasperConverter.setInputStream(inputStream);
			if (template != null) {
				jasperConverter.setFileFormat(template.getFormat());
			} else {
				String destination = getFileDestination(file);
				if ("xls".equalsIgnoreCase(destination) || "xlsx".equalsIgnoreCase(destination)) {
					jasperConverter.setFileFormat(ReportConstants.REPORT_FORMAT_EXCEL);
				} else if ("pdf".equalsIgnoreCase(destination)) {
					jasperConverter.setFileFormat(ReportConstants.REPORT_FORMAT_PDF);
				} else if ("html".equalsIgnoreCase(destination)) {
					jasperConverter.setFileFormat(ReportConstants.REPORT_FORMAT_HTML);
				} else if ("txt".equalsIgnoreCase(destination)) {
					jasperConverter.setFileFormat(ReportConstants.REPORT_FORMAT_TEXT);
				} else if ("rtf".equalsIgnoreCase(destination)) {
					jasperConverter.setFileFormat(ReportConstants.REPORT_FORMAT_RTF);
				} else if ("csv".equalsIgnoreCase(destination)) {
					jasperConverter.setFileFormat(ReportConstants.REPORT_FORMAT_CSV);
				} else {
					throw new Exception("unknown file format " + destination);
				}
			}
			if (file.getIsPasswordProtect()) {
				jasperConverter.setFilePassword(file.getPassword());
			}
			jasperConverter.setOutputStream(out);
			jasperConverter.convertFile();

			out.flush();
		} finally {
			IOUtils.closeQuietly(out);
		}
	}

	private void generateOutgoingProcessFileReportXslt(ProcessFileAttribute file,
	                                                   FileObject fileObject,
	                                                   InputStream inputStream) throws Exception {
		OutputStream out = fileObject.getContent().getOutputStream();
		try {
			InputStreamReader isr = new InputStreamReader(inputStream, SystemConstants.DEFAULT_CHARSET);
			Document doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse(new InputSource(isr));
			IOUtils.closeQuietly(isr);

			NodeList nodeList = doc.getElementsByTagName("datasource");
			Node dataSourceNode = nodeList.item(0);
			nodeList = doc.getElementsByTagName("template");
			Node templateNode = nodeList.item(0).getFirstChild();

			XsltConverter.convertFromNodes(templateNode, dataSourceNode, out, file.getName());
			out.flush();
		} finally {
			IOUtils.closeQuietly(out);
		}
	}

	private String getFileDestination(ProcessFileAttribute file) {
		String fileName = file.getName();
		return fileName.substring(fileName.lastIndexOf(".") + 1, fileName.length());
	}

	private void generateOutgoingProcessFileXml(ProcessFileAttribute file, FileObject fileObject,
	                                            InputStream inputStream) throws Exception {
		logger.debug(String.format("[sessionId:%d] Writing the stream to \"%s\"", file.getSessionId(),
				fileObject.getName().getBaseName()));

		OutputStream out = fileObject.getContent().getOutputStream();
		try {
			if (CommonUtils.hasText(file.getConverterClass())) {
				logger.debug(String.format(
						"[sessionId:%d] \"%s\" converter has been found. The control is passed to the converter.",
						file.getSessionId(), file.getConverterClass()));

				OutgoingFileConverter converter = (OutgoingFileConverter) createObject(file.getConverterClass());
				if (converter != null) {
					converter.setOutputStream(out);
					converter.setInputStream(inputStream);
					converter.convertFile();
				}
			} else {
				long fullLen = org.apache.commons.io.IOUtils.copyLarge(inputStream, out);
				logger.debug(String.format("[sessionId:%d] %d bytes has been written to \"%s\"", file.getSessionId(),
						fullLen, fileObject.getName().getBaseName()));

			}
			out.flush();
		} finally {
			IOUtils.closeQuietly(out);
		}
	}

	private boolean generateOutgoingProcessFileText(Connection con, ProcessFileAttribute file, FileObject fileObject) throws Exception {
		PreparedStatement pstmt = null;
		ResultSet rs;
		OutputStream out = null;
		try {
			out = fileObject.getContent().getOutputStream();
			String character = file.getCharacterSet();
			if (character == null || character.length() == 0) {
				character = "UTF-8";
			}
			String queryCount = "SELECT count(record_number) FROM prc_ui_file_raw_data_vw WHERE session_file_id = ?";
			String query = "SELECT " +
					"a.raw_data " +
					"FROM " +
					"prc_ui_file_raw_data_vw a " +
					"WHERE  " +
					"a.session_file_id = ? " +
					"and a.record_number >= ? " +
					"and a.record_number <= ? " +
					"ORDER BY a.record_number";

			pstmt = con.prepareStatement(queryCount);
			pstmt.setLong(1, file.getId());
			rs = pstmt.executeQuery();
			int count = 0;
			if (rs.next()) {
				count = rs.getInt(1);
			}
			rs.close();

			if (count == 0) {
				return true;
			}
			int batch = 2000;
			pstmt = con.prepareStatement(query);
			String ls = file.getLineSeparator().getSeparator();
			for (int i = 1; i <= count; i += batch) {
				pstmt.setLong(1, file.getId());
				pstmt.setInt(2, i);
				pstmt.setInt(3, i + batch - 1);

				rs = pstmt.executeQuery();
				String str;
				while (rs.next()) {
					str = rs.getString(1) + ls;
					out.write(str.getBytes(character));
				}
				out.flush();
			}
			rs.close();
			return false;
		} finally {
			DBUtils.close(pstmt);
			IOUtils.closeQuietly(out);
		}
	}

	public static void initializeSession(Connection connect, Long sessionId, Integer containerId) throws SQLException {
		try (CallableStatement cstmt = connect.prepareCall("{call prc_api_session_pkg.start_session(" +
																"  io_session_id	=> ?" +
																", i_container_id	=> ?)}")) {
			cstmt.setLong(1, sessionId);
			if (containerId != null) {
				cstmt.setLong(2, containerId);
			} else {
				cstmt.setObject(2, null);
			}
			cstmt.execute();
		}
	}

	public static Object createObject(String className) throws SystemException {
		try {
			Class<?> classDefinition = Class.forName(className);
			return classDefinition.newInstance();
		} catch (Exception e) {
			throw new SystemException(e.getMessage(), e);
		}
	}

	private FileObject renameFile(FileObject fileObject, String newName) throws FileSystemException {
		FileObject newFO = VFS.getManager().resolveFile(newName);
		fileObject.moveTo(newFO);
		return newFO;
	}

	private void zipFiles(HashMap<String, String> filesToZip, String zipLocation,
	                      String zipName, int lastFileId) throws Exception {
		int buffer = 2048;
		BufferedInputStream origin = null;
		FileOutputStream dest = null;
		ZipOutputStream out = null;
		try {
			if (zipLocation == null || zipName == null || zipLocation.trim().length() == 0
					|| zipName.trim().length() == 0) {
				throw new Exception("File name or location for file with ID = " + lastFileId
						+ " is not defined!");
			}
			FileSystemManager fsManager = VFS.getManager();

			if (!zipLocation.endsWith("\\") && !zipLocation.endsWith("/")) {
				zipLocation += System.getProperty("file.separator");
			}
			String zipFileName = zipLocation + zipName.replaceAll("[ ]", "_") + ".zip";
			byte data[] = new byte[buffer];
			dest = new FileOutputStream(zipFileName);
			out = new ZipOutputStream(new BufferedOutputStream(dest));

			for (String fileName : filesToZip.keySet()) {
				FileObject fileObject = fsManager.resolveFile(filesToZip.get(fileName));
				origin = new BufferedInputStream(fileObject.getContent().getInputStream(), buffer);

				ZipEntry entry = new ZipEntry(fileName);
				out.putNextEntry(entry);
				int count;
				while ((count = origin.read(data, 0, buffer)) != -1) {
					out.write(data, 0, count);
				}
				deleteFileObject(fileObject);
			}
		} finally {
			IOUtils.closeQuietly(origin);
			IOUtils.closeQuietly(out);
			IOUtils.closeQuietly(dest);
		}
	}

	private FileObject tarFiles(HashMap<String, String> filesToTar, String tarLocation,
	                            String tarName, int lastFileId) {
		TarArchiveOutputStream aos = null;
		FileObject tar = null;
		try {
			if (tarLocation == null || tarName == null || tarLocation.trim().length() == 0
					|| tarName.trim().length() == 0) {
				throw new Exception("File name or location for file with ID = " + lastFileId
						+ " is not defined!");
			}
			FileSystemManager fsManager = VFS.getManager();

			String tarFileName = tarLocation + tarName.replaceAll("[ ]", "_") + ".tar";
			tar = fsManager.resolveFile(tarFileName);
			tar.createFile();
			aos = (TarArchiveOutputStream) new ArchiveStreamFactory().createArchiveOutputStream(
					"tar", tar.getContent().getOutputStream());

			for (String fileName : filesToTar.keySet()) {
				FileObject fileObject = fsManager.resolveFile(filesToTar.get(fileName));

				TarArchiveEntry entry = new TarArchiveEntry(fileName);
				entry.setSize(fileObject.getContent().getSize());
				aos.putArchiveEntry(entry);
				IOUtils.copy(fileObject.getContent().getInputStream(), aos);
				fileObject.getContent().getInputStream().close();
				aos.closeArchiveEntry();
			}
			aos.finish();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			if (tar != null) {
				try {
					tar.delete();
				} catch (FileSystemException ignored) {
				}
				tar = null;
			}
		} finally {
			IOUtils.closeQuietly(aos);
			for (String fileName : filesToTar.keySet()) {
				deleteFile(new File(filesToTar.get(fileName)));
			}
		}
		return tar;
	}

	private void gzipTar(FileObject tar) throws Exception {
		int buffer = 2048;
		BufferedInputStream origin = null;
		FileOutputStream dest = null;
		GZIPOutputStream gzOut = null;
		try {
			String fileName = tar.getName().getPath() + ".gz";
			byte data[] = new byte[buffer];
			dest = new FileOutputStream(fileName);
			gzOut = new GZIPOutputStream(new BufferedOutputStream(dest));

			origin = new BufferedInputStream(tar.getContent().getInputStream(), buffer);

			int count;
			while ((count = origin.read(data, 0, buffer)) != -1) {
				gzOut.write(data, 0, count);
			}
			tar.delete();
			tar.close();
		} finally {
			IOUtils.closeQuietly(origin);
			IOUtils.closeQuietly(dest);
			IOUtils.closeQuietly(gzOut);
		}
	}

	private String getSecurityKey(ProcessFileAttribute file) {
		SecurityDao secDao = new SecurityDao();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter("objectId", file.getFileAttributeId());
		filters[1] = new Filter("entityType", EntityNames.FILE_ATTRIBUTE);
		SelectionParams params = new SelectionParams(filters);
		params.setUser(userName);

		try {
			RsaKey[] keys = secDao.getRsaKeys(userSessionId, params);
			if (keys.length == 0) {
				logger.info("Security key for file attribute (ID = " + file.getId() + ") wasn't found.");
				return null;
			}
			return keys[0].getPrivateKey();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			return null;
		}
	}

	private String generateSignature(FileObject file, ProcessFileAttribute fileAttribute) throws Exception {
		String secKey = getSecurityKey(fileAttribute);
		if (secKey == null) {
			throw new Exception("Error generating signature: security key was not found.");
		}

		SignatureEncryptor sig = (SignatureEncryptor) createObject(fileAttribute.getEncryptionPlugin());
		if (sig == null) {
			throw new Exception("Error generating signature: signature encryptor wasn't created.");
		}

		return sig.generateSignatureBase64(file, secKey);
	}

	private void fillSignatureFile(FileObject fileSignature, String signature) throws Exception {
		OutputStream out = fileSignature.getContent().getOutputStream();
		out.write(signature.getBytes(SystemConstants.DEFAULT_CHARSET));

		out.flush();
	}

	public List<ProcessFileAttribute> getProcessed() {
		return processed;
	}

	public List<ProcessFileAttribute> getUnprocessed() {
		return unprocessed;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public void setLoggerDb(Logger loggerDb) {
		this.loggerDb = loggerDb;
	}

	private String getFileName(Connection con, ProcessFileAttribute file) {
		if (file.getNameFormatId() == null) {
			return file.getProcessFileName();
		}

		CommonParamRec[] params = new CommonParamRec[2];
		params[0] = new CommonParamRec("SESSION_ID", sessionId);
		params[1] = new CommonParamRec("PROCESS_ID", file.getProcessId());

		String fileName = null;
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall("{ ? = call prc_ui_file_pkg.get_default_file_name(" +
					"i_file_type => ?, i_file_purpose => ?, i_params => ?)}");
			cstmt.setObject(1, null, OracleTypes.VARCHAR);
			cstmt.setString(2, file.getFileType());
			cstmt.setString(3, file.getPurpose());

			Array parameter = DBUtils.createArray(AuthOracleTypeNames.COM_PARAM_MAP_TAB, con, params);
			cstmt.setArray(4, parameter);

			cstmt.registerOutParameter(1, OracleTypes.VARCHAR);
			cstmt.executeUpdate();

			fileName = cstmt.getString(1);
			cstmt.close();
			cstmt = con.prepareCall("commit");
			cstmt.execute();
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			loggerDb.error(new TraceLogInfo(sessionId, containerId, "OutgoingFileProcessor:getFileName: " + e.getMessage()));
		} finally {
			DBUtils.close(cstmt);
		}

		if (fileName == null || fileName.trim().isEmpty()) {
			return file.getProcessFileName();
		}

		return fileName;
	}

	private String getFilePath(FileObject file) {
		String path = file.getName().getURI(); // -> file://host/path
		path = path.substring(path.indexOf("://") + 3); // -> host/path
		return path;
	}
}

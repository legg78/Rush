package ru.bpc.sv2.scheduler.process.mc;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSystemException;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.slf4j.LoggerFactory;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.FileSaver;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.utils.SystemException;

import javax.xml.bind.DatatypeConverter;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

public class SV2SVFileLoader implements FileSaver {
	private static final String query = "SELECT a.raw_data " +
										"FROM prc_ui_file_raw_data_vw a " +
										"WHERE a.session_file_id = ? " +
										"AND a.record_number = ? " +
										"ORDER BY a.record_number";

	private InputStream is;
	private FileObject fileObject = null;
	private Connection con = null;
	private ProcessFileAttribute fileAttrs = null;
	private OutputStream out = null;
//	private static final Logger logger = Logger.getLogger("PROCESSES");

	protected Map<String, Object> params;

	private Integer traceLevel = 6;
	private Integer traceLimit;
	private Integer traceThreadNumber;

	@Override
	public void save() throws Exception {
//		logger.setLevel(getTraceLevel(traceLevel));

//		logger.debug("SV2SV File Loader: start");
		String dbCharset = SystemConstants.DEFAULT_CHARSET;  // TODO: should be database charset
		String charset = null;
		if (fileObject == null) {
//			logger.error("SV2SV File Loader: fileObject is null");
		}
		if (con == null) {
//			logger.error("SV2SV File Loader: connection is null");
		}
		if (fileAttrs == null) {
//			logger.error("SV2SV File Loader: fileAttrs is null");
		}
		if (fileAttrs != null && fileAttrs.getCharacterSet() != null) {
			charset = fileAttrs.getCharacterSet(); // NB: This is file attribute's charset not the one from process parameters!
			if (SimpleFileSaver.CHARSET_WE8EBCDIC37.equals(charset)) {
				charset = "IBM01140";
			}
		}
		if ((fileObject != null) && (con != null) && (fileAttrs != null)) {
			try {
//				logger.debug("SV2SV File Loader: getting output stream to file");
				out = fileObject.getContent().getOutputStream();
				String queryCount = "SELECT count(record_number) FROM prc_ui_file_raw_data_vw WHERE session_file_id = ?";

				int count = 0;
				try (PreparedStatement pstmt1 = con.prepareStatement(queryCount)) {
					pstmt1.setLong(1, fileAttrs.getId());
					try (ResultSet rs1 = pstmt1.executeQuery()) {
						if (rs1.next()) {
							count = rs1.getInt(1);
//							logger.debug("SV2SV File Loader: records count = " + count);
						}
					}
				}

				if (count == 0) {
//					logger.debug("SV2SV File Loader: no records");
					return;
				}

				int i = 0;

				char newLine = 0x0A;
				StringBuilder builder = new StringBuilder();
				while (true) {
					String currentRecord = getData(i);
					if (currentRecord != null) {
						String hexedRecord;
						if (charset == null) {
							hexedRecord = currentRecord;
						} else {
							hexedRecord = convertHexes(currentRecord, dbCharset, charset);
						}
						builder.append(hexedRecord);
						builder.append(newLine);
					} else {
						break;
					}
					i++;
				}
				out.write(DatatypeConverter.parseHexBinary(builder.toString()));
//				logger.debug("SV2SV File Loader: flushing file");
				out.flush();
			} catch (SQLException e) {
//				logger.error("", e);
				throw new SystemException("Could not obtain records from DB", e);
			} catch (FileSystemException e) {
//				logger.error("", e);
				throw new SystemException("Could not get file stream", e);
			} catch (IOException e) {
//				logger.error("", e);
				throw new SystemException("Could not write to file", e);
			} catch (Exception e) {
//				logger.error("", e);
				throw new SystemException(e);
			} finally {
				if (out != null) {
					try {
						out.close();
					} catch (IOException e) {
//						logger.error("", e);
					}
				}
			}
		}
	}

	private Level getTraceLevel(int dbLevel) {
		switch (dbLevel) {
			case 6: return Level.TRACE;
			case 5: return Level.INFO;
			case 4: return Level.WARN;
			case 3: return Level.ERROR;
			case 2: return Level.FATAL;
			case 1: return Level.OFF;
			default: return Level.INFO;
		}
	}

	private String getData(int startPos) throws SQLException {
		try (PreparedStatement pstmt = con.prepareStatement(query)) {
			pstmt.setLong(1, fileAttrs.getId());
			pstmt.setInt(2, startPos);
			try (ResultSet rs = pstmt.executeQuery()) {
				if (rs.next()) {
					return rs.getString(1);
				}
				return null;
			}
		}
	}

	private String convertHexes(String hexStr, String sourceEnc, String destEnc) throws UnsupportedEncodingException {
		byte[] destHeaderBytes = new String(DatatypeConverter.parseHexBinary(hexStr), sourceEnc).getBytes(destEnc);
		return Hex.encodeHexString(destHeaderBytes);
	}

	@Override
	public InputStream getInputStream() {
		return is;
	}

	@Override
	public void setInputStream(InputStream inputStream) {
		is = inputStream;

	}

	@Override
	public FileObject getFileObject() {
		return fileObject;
	}

	@Override
	public void setFileObject(FileObject fileObject) {
		this.fileObject = fileObject;

	}

	@Override
	public Connection getConnection() {
		return con;
	}

	@Override
	public void setConnection(Connection con) {
		this.con = con;
	}

	@Override
	public FileConverter getConverter() {
		throw new UnsupportedOperationException("getConverter()");
	}

	@Override
	public void setConverter(FileConverter converter) {
		throw new UnsupportedOperationException("setConverter()");

	}

	@Override
	public ProcessFileAttribute getFileAttributes() {
		return fileAttrs;
	}

	@Override
	public void setFileAttributes(ProcessFileAttribute fileAttributes) {
		fileAttrs = fileAttributes;

	}

	@Override
	public void setSsn(SqlMapSession ssn) {
		throw new UnsupportedOperationException("setSsn()");

	}

	@Override
	public void setThreadNum(int threadNum) {
		throw new UnsupportedOperationException("setThreadNum()");

	}

	@Override
	public void setParams(Map<String, Object> params) {
		this.params = params;
	}

	@Override
	public Map<String, Object> getOutParams() {
		return null;
	}

	@Override
	public void setUserSessionId(Long userSessionId) {
		// TODO Auto-generated method stub

	}

	@Override
	public void setSessionId(Long sessionId) {
		// TODO Auto-generated method stub

	}

	@Override
	public void setUserName(String userName) {
		// TODO Auto-generated method stub
	}

	@Override
	public boolean isRequiredInFiles() {
		return true;
	}

	@Override
	public boolean isRequiredOutFiles() {
		// TODO Auto-generated method stub
		return true;
	}

	@Override
	public void setProcess(ProcessBO proc) {
		// TODO Auto-generated method stub

	}

	@Override
	public void setTraceLevel(Integer traceLevel) {
		this.traceLevel = traceLevel;
	}

	@Override
	public void setTraceLimit(Integer traceLimit) {
		this.traceLimit = traceLimit;
	}

	@Override
	public void setTraceThreadNumber(Integer traceThreadNumber) {
		this.traceThreadNumber = traceThreadNumber;
	}
}

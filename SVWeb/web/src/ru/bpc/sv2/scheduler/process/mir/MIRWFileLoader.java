package ru.bpc.sv2.scheduler.process.mir;

import com.ibatis.sqlmap.client.SqlMapSession;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;
import javax.xml.bind.DatatypeConverter;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSystemException;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.FileSaver;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;

public class MIRWFileLoader implements FileSaver {
	private static final int BLOCK_SIZE = 1014;
	private static final int BATCH_SIZE = 2000;
	public static final String RECORD_FORMAT = "I_RECORD_FORMAT";
	public static final String RDW_1014 = "RCFM1014";
	private static final String query = "SELECT " +
			"a.raw_data " +
			"FROM " +
			"prc_ui_file_raw_data_vw a " +
			"WHERE  " +
			"a.session_file_id = ? " +
			"and a.record_number >= ? " +
			"and a.record_number <= ? " +
			"ORDER BY a.record_number";

	private final String NULL_CHARACTER = "0";

	private InputStream is;
	private FileObject fileObject = null;
	private Connection con = null;
	private ProcessFileAttribute fileAttrs = null;
	private OutputStream out = null;
	private static final Logger logger = Logger.getLogger("PROCESSES");

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer traceThreadNumber;

	protected Map<String, Object> params;
	private boolean rdw1014;

	@Override
	public void save() throws Exception {
		setupTracelevel();

		PreparedStatement pstmt = null;
		ResultSet rs = null;
		logger.debug("MCW File Loader: start");
		String dbCharset = SystemConstants.DEFAULT_CHARSET;  // TODO: should be database charset
		String charset = null;
		if (fileObject == null) {
			logger.error("MCW File Loader: fileObject is null");
		}
		if (con == null) {
			logger.error("MCW File Loader: connection is null");
		}
		if (fileAttrs == null) {
			logger.error("MCW File Loader: fileAttrs is null");
		}
		if (fileAttrs != null && fileAttrs.getCharacterSet() != null) {
			charset = fileAttrs.getCharacterSet(); // NB: This is file attribute's charset not the one from process parameters!
			if (SimpleFileSaver.CHARSET_WE8EBCDIC37.equals(charset)) {
				charset = "IBM01140";
			}
		}
		if ((fileObject != null) && (con != null) && (fileAttrs != null)) {
			try {
				logger.debug("MCW File Loader: getting output stream to file");
				out = fileObject.getContent().getOutputStream();
				String queryCount = "SELECT count(record_number) FROM prc_ui_file_raw_data_vw WHERE session_file_id = ?";

				pstmt = con.prepareStatement(queryCount);
				pstmt.setLong(1, fileAttrs.getId());
				rs = pstmt.executeQuery();
				int count = 0;
				if (rs.next()) {
					count = rs.getInt(1);
					logger.debug("MCW File Loader: records count = " + count);
				}
				rs.close();

				if (count == 0) {
					logger.debug("MCW File Loader: no records");
					return;
				}
				String line = "";

				int i = 0;
				int recordNumber = 0;
				rs = getData(pstmt, i);
				String str = "";
				boolean finish = false;

				/**
				 * RDW with blocks
				 */
				determineFormat();

				while (!finish) {
					while (line.length() < (BLOCK_SIZE - 2) * 2) { // because every symbol is a half byte
						if (str == null && i > 0) break;  // just in case we return here after EOF

						if (!rs.next()) {
							rs.close();
							i += BATCH_SIZE;
							rs = getData(pstmt, i);
							if (!rs.next()) { // EOF
								str = null;
								break;
							}
						}

						// these strings are supposed to be hexadecimal
						str = rs.getString(1);
						recordNumber++;
						String encodedHexStr;
						if (charset == null) {
							encodedHexStr = str;
						}
						else {
							encodedHexStr = convertHexes(str, dbCharset, charset);
						}
						line += getComplementedHexedLength(encodedHexStr.length()) + encodedHexStr;
					}
					int rightLimit;
					if (line.length() <= (BLOCK_SIZE - 2) * 2) {
						rightLimit = line.length();
						if (recordNumber > count - 1) {
							finish = true;
						}
					}
					else {
						rightLimit = (BLOCK_SIZE - 2) * 2;
					}
					String block = getBlock(line, rightLimit);

					//String decodedBlock = new String(DatatypeConverter.parseHexBinary(block));
					//out.write(decodedBlock.getBytes(charset));
					out.write(DatatypeConverter.parseHexBinary(block));
					if (rightLimit < line.length()) {
						line = line.substring(rightLimit);
					}
					else {
						line = "";
					}
				}
				logger.debug("MCW File Loader: flushing file");
				out.flush();
			}
			catch (SQLException e) {
				logger.error("", e);
				throw new SystemException("Could not obtain records from DB", e);
			}
			catch (FileSystemException e) {
				logger.error("", e);
				throw new SystemException("Could not get file stream", e);
			}
			catch (IOException e) {
				logger.error("", e);
				throw new SystemException("Could not write to file", e);
			}
			catch (Exception e) {
				logger.error("", e);
				throw new SystemException(e);
			}
			finally {
				if (out != null) {
					try {
						out.close();
					}
					catch (IOException e) {
						logger.error("", e);
					}
				}
				if (rs != null) {
					try {
						rs.close();
					}
					catch (SQLException e) {
						logger.error("", e);
					}
				}
				if (pstmt != null) {
					try {
						pstmt.close();
					}
					catch (SQLException e) {
						logger.error("", e);
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

	private ResultSet getData(PreparedStatement pstmt, int startPos) throws SQLException {
		pstmt = con.prepareStatement(query);
		pstmt.setLong(1, fileAttrs.getId());
		pstmt.setInt(2, startPos);
		pstmt.setInt(3, startPos + BATCH_SIZE - 1);

		ResultSet rs = pstmt.executeQuery();
		return rs;
	}

	private String getComplementedHexedLength(int length) {
		length = length / 2;    // we count byte length and two hex symbols represent one byte
		String result = Integer.toHexString(length);
		for (int i = result.length(); i < 8; i++) {
			result = NULL_CHARACTER + result;
		}
		return result;
	}

	private String getBlock(String line, int rightLimit) {
		String block = line.substring(0, rightLimit);
		String nulls = "";
		if (rdw1014) {
			for (int i = rightLimit; i < BLOCK_SIZE * 2; i++) {
				nulls += NULL_CHARACTER;
			}
		}
		return block + nulls;
	}

	private byte[] hexStringToByteArray(String str) {
		int len = str.length();
		byte[] data = new byte[len / 2];
		for (int i = 0; i < len; i += 2) {
			data[i / 2] = (byte) ((Character.digit(str.charAt(i), 16) << 4) + Character.digit(str.charAt(i + 1), 16));
		}
		return data;
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

	private String convertHexes(String hexStr, String sourceEnc, String destEnc) throws UnsupportedEncodingException {
		String header = hexStr.substring(0, 8); // first 4 bytes -- header
		String mask = hexStr.substring(8, 40); // next 16 bytes -- mask
		String body = hexStr.substring(40); // the rest is body

		byte[] destHeaderBytes = new String(DatatypeConverter.parseHexBinary(header), sourceEnc).getBytes(destEnc);
		byte[] destMaskBytes = DatatypeConverter.parseHexBinary(mask);
		byte[] destBodyBytes = new String(DatatypeConverter.parseHexBinary(body), sourceEnc).getBytes(destEnc);
		String destHex = Hex.encodeHexString(destHeaderBytes) + Hex.encodeHexString(destMaskBytes)
				+ Hex.encodeHexString(destBodyBytes);
		return destHex;
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

	private void determineFormat() {
		if (params.get(RECORD_FORMAT) != null && params.get(RECORD_FORMAT).equals(RDW_1014)) {
			rdw1014 = true;
		}
		else {
			rdw1014 = false;
		}
	}

	private void setupTracelevel() {
		Integer level = traceLevel;
		if (level == null) {
			level = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.TRACE_LEVEL).intValue();
		}
		logger.setLevel(getTraceLevel(level));
	}
}

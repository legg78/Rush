package ru.bpc.sv2.logic.transfer;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.cup.FileContents;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.UserException;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.io.IOException;
import java.io.Reader;
import java.sql.Clob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;


public class TransferDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger(TransferDao.class);
	private static final String USER = "ADMIN";

	public Long savePackage(Long sessionId, Long processId, String fileName, String fileType, String svxpData,
							Long recordsCount)
			throws Exception {
		SqlMapSession ssn = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			conn = ssn.getCurrentConnection();
			pstmt = conn.prepareStatement(
					"INSERT INTO prc_session_file(id, file_attr_id, file_name, file_date, record_count, file_xml_contents, file_type, session_id) " +
							"VALUES(?, (SELECT id FROM prc_file_attribute WHERE file_id=(SELECT id FROM prc_file WHERE process_id=?) AND rownum=1), " +
							"?, CURRENT_TIMESTAMP, ?, XMLTYPE.CREATEXML(?), ?, ?)");
			Long id = createSessionFileId((Long) ssn.queryForObject("cup.next_session_file_seq_value"));
			pstmt.setLong(1, id);
			pstmt.setLong(2, processId);
			pstmt.setString(3, fileName);
			pstmt.setLong(4, recordsCount);
			Clob tempClob = ssn.getCurrentConnection().createClob();
			tempClob.setString(1, svxpData);
			pstmt.setObject(5, tempClob);
			pstmt.setString(6, fileType);
			pstmt.setLong(7, sessionId);
			logger.info("Insert data into prc_session_file");
			pstmt.execute();
			return id;
		} catch (SQLException ex) {
			logger.error("Error saving package", ex);
			throw new DataAccessException(ex.getCause().getMessage());
		} finally {
			if (conn != null) {
				conn.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
			close(ssn);
		}
	}


	public Long savePackageWithSessionId(Long sessionId, Long processId, String fileName, String fileType,
										 String svxpData,
										 Long recordsCount)
			throws Exception {
		SqlMapSession ssn = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		Clob tempClob = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			conn = ssn.getCurrentConnection();
			pstmt = conn.prepareStatement(
					"INSERT INTO prc_session_file(id, file_attr_id, file_name, file_date, record_count, file_xml_contents, file_type, session_id) " +
							"VALUES(?, (SELECT id FROM prc_file_attribute WHERE file_id=(SELECT id FROM prc_file WHERE process_id=?) AND rownum=1), " +
							"?, CURRENT_TIMESTAMP, ?, XMLTYPE.CREATEXML(?), ?, ?)");
			Long id = createSessionFileId((Long) ssn.queryForObject("cup.next_session_file_seq_value"));
			pstmt.setLong(1, id);
			pstmt.setLong(2, processId);
			pstmt.setString(3, fileName);
			pstmt.setLong(4, recordsCount);
			tempClob = ssn.getCurrentConnection().createClob();
			tempClob.setString(1, svxpData);
			pstmt.setObject(5, tempClob);
			pstmt.setString(6, fileType);
			pstmt.setLong(7, sessionId);
			logger.info("Insert data into prc_session_file");
			pstmt.execute();
			return id;
		} catch (SQLException ex) {
			logger.error("Error saving package", ex);
			throw new DataAccessException(ex.getCause().getMessage());
		} finally {
			if (conn != null) {
				conn.close();
			}
			if (pstmt != null) {
				pstmt.close();
			}
			if (tempClob != null) {
				tempClob.free();
			}
			close(ssn);
		}
	}


	public void deleteSavedData(Long sessionId, List<Long> ids) throws Exception {
		SqlMapSession ssn = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			conn = ssn.getCurrentConnection();
			pstmt = conn.prepareStatement(
					"DELETE FROM prc_session_file WHERE id IN(" + ids.toString().replaceAll("\\[|\\]", "") + ")");
			pstmt.executeUpdate();
		} catch (SQLException ex) {
			logger.error("Error deleting saved data", ex);
			throw new DataAccessException(ex.getCause().getMessage());
		} finally {
			if (pstmt != null) {
				pstmt.close();
			}
			if (conn != null) {
				conn.close();
			}
			close(ssn);
		}
	}


	public String getMqUrl(Long sessionId) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			return (String) ssn.queryForObject("transfer.get-mq-url");
		} catch (SQLException ex) {
			logger.error("Error getting mq url", ex);
			throw new DataAccessException(ex.getCause().getMessage());
		} finally {
			close(ssn);
		}
		//return "tcp://localhost:61616";//TODO for tests
	}


	public String getBpelUrl(Long sessionId) throws Exception {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			return (String) ssn.queryForObject("transfer.get-bpel-url");
		} catch (SQLException ex) {
			logger.error("Error getting subprocess progress", ex);
			throw new DataAccessException(ex.getCause().getMessage());
		} finally {
			close(ssn);
		}
	}


	public FileContents getFileContents(Long sessionId) throws Exception {
		SqlMapSession ssn = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs;
		Clob clob = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			conn = ssn.getCurrentConnection();
			pstmt = conn.prepareCall("SELECT file_name, file_contents FROM prc_session_file WHERE session_id=?");
			pstmt.setLong(1, sessionId);
			rs = pstmt.executeQuery();
			String filename = null;
			if (rs.next()) {
				clob = rs.getClob("file_contents");
				filename = rs.getString("file_name");
			}
			FileContents fc = new FileContents();
			if (clob != null) {
				fc.setContent(readClob(clob));
				fc.setFilename(filename);
				return fc;
			}
		} catch (SQLException ex) {
			logger.error("Error getting file content", ex);
			if (ex.getErrorCode() >= 20000 && ex.getErrorCode() <= 20999) {
				throw new UserException(ex.getCause().getMessage());
			} else {
				throw new DataAccessException(ex.getCause().getMessage());
			}
		} finally {
			if (clob != null) {
				clob.free();
			}
			DBUtils.close(pstmt);
			DBUtils.close(conn);
			close(ssn);
		}
		return null;
	}


	public FileContents getFileContents(Long sessionId, long shift) throws Exception {
		SqlMapSession ssn = null;
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs;
		Clob clob = null;
		try {
			ssn = getIbatisSession(sessionId, USER);
			conn = ssn.getCurrentConnection();
			pstmt = conn.prepareCall(
					"SELECT file_name, file_contents FROM (SELECT rownum as n, a.* FROM (SELECT file_name, file_contents FROM prc_session_file WHERE session_id=? ORDER BY id) a) WHERE n>? AND rownum=1");
			pstmt.setLong(1, sessionId);
			pstmt.setLong(2, shift);
			rs = pstmt.executeQuery();
			String filename = null;
			if (rs.next()) {
				clob = rs.getClob("file_contents");
				filename = rs.getString("file_name");
			}
			FileContents fc = new FileContents();
			if (clob != null) {
				fc.setContent(readClob(clob));
				fc.setFilename(filename);
				return fc;
			}
		} catch (SQLException ex) {
			logger.error("Error getting file content", ex);
			if (ex.getErrorCode() >= 20000 && ex.getErrorCode() <= 20999) {
				throw new UserException(ex.getCause().getMessage());
			} else {
				throw new DataAccessException(ex.getCause().getMessage());
			}
		} finally {
			if (clob != null) {
				clob.free();
			}
			DBUtils.close(pstmt);
			DBUtils.close(conn);
			close(ssn);
		}
		return null;
	}


	public Long getFileItemsCnt(Long sessionId) throws Exception {
		SqlMapSession ssn = null;
		PreparedStatement pstmt = null;
		ResultSet rs;
		try {
			ssn = getIbatisSession(sessionId, USER);
			pstmt = ssn.getCurrentConnection()
					.prepareStatement("SELECT current_count as cnt FROM prc_stat WHERE session_id=?");
			pstmt.setLong(1, sessionId);
			rs = pstmt.executeQuery();
			if (rs.next()) {
				return rs.getLong("cnt");
			}
			return null;
		} catch (SQLException ex) {
			logger.error("Error getting file items count", ex);
			throw new DataAccessException(ex.getCause().getMessage());
		} finally {
			DBUtils.close(pstmt);
			close(ssn);
		}
	}

	private String readClob(Clob clob) throws SQLException, IOException {
		StringBuilder sb = new StringBuilder((int) clob.length());
		Reader r = clob.getCharacterStream();
		char[] cbuf = new char[2048];
		int n;
		while ((n = r.read(cbuf, 0, cbuf.length)) != -1) {
			sb.append(cbuf, 0, n);
		}
		return sb.toString();
	}

	private Long createSessionFileId(Long seqValue) {
		StringBuilder sb = new StringBuilder();
		sb.append(seqValue);
		while (sb.length() < 10) {
			sb.insert(0, '0');
		}
		sb.insert(0, new SimpleDateFormat("yyMMdd").format(new Date()));
		return Long.valueOf(sb.toString());
	}
}

package ru.bpc.sv2.scheduler.process.external.svng;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;

import java.io.Reader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class FileSessionDataSave {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private Connection connection;
	private Integer containerBindId;
	private Long userSessionId;
	private Long sessionId;
	private ProcessDao processDao;
	private ProcessFileAttribute attr;
	private String statusSessionFile;
	private Long sessionFileId;

	CallableStatement cstmt;

	public FileSessionDataSave(Integer containerBindId, Long userSessionId, ProcessFileAttribute attr, String statusSessionFile) {
		this.containerBindId = containerBindId;
		this.userSessionId = userSessionId;
		this.attr = attr;
		this.statusSessionFile = statusSessionFile;
		try {
			init();
		} catch (SystemException e) {
			e.printStackTrace();
		}
	}

	public void updateRejectCount() {
		if (attr.getFileType() != null && !attr.getFileType().isEmpty()) {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("fileType", attr.getFileType());
			logger.debug("Setup session " + sessionId + " context");
			processDao.setSessionContext(sessionId);
			logger.debug("File session id: " + sessionId + ", file type: " + attr.getFileType());
			processDao.saveRejectedCount(sessionId, params);
		} else {
			logger.debug("File session id:" + sessionId + ", file type: NaN");
		}
	}

	public void createSqlQuery(Reader reader, String fileName, Integer recordNumber, long dataSizeBytes) throws SQLException {
		if (sessionFileId == null) {
			sessionFileId = openFile(fileName);
		}
		logger.debug("File session id: " + sessionFileId);

		cstmt = connection.prepareCall("{call prc_api_file_pkg.put_file(  " +
				"i_sess_file_id   => ?" +
				", i_clob_content => ?" +
				", i_add_to => ?)}");
		cstmt.setLong(1, sessionFileId);
		if (dataSizeBytes < 0) {
			cstmt.setCharacterStream(2, reader);
		} else {
			cstmt.setCharacterStream(2, reader, dataSizeBytes);
		}
		cstmt.setInt(3, 0);
		setRecordCount(sessionFileId, recordNumber);
	}

	public void executeUpdate() throws SQLException {
		cstmt.execute();
	}

	public void close() {
		DBUtils.close(cstmt);
	}


	private Long openFile(String fileName) {
		ProcessFileAttribute fileAttributes = new ProcessFileAttribute();
		fileAttributes.setPurpose(ProcessConstants.FILE_PURPOSE_INCOMING);
		fileAttributes.setFileType(attr.getFileType());
		fileAttributes.setContainerBindId(containerBindId);
		fileAttributes.setFileName(fileName);
		Long sessionFileId;
		if (sessionId == null) {
			sessionFileId = processDao.openFileNoSession(userSessionId, fileAttributes);
		} else {
			fileAttributes.setSessionId(sessionId);
			sessionFileId = processDao.openFile(userSessionId, fileAttributes);
		}
		return sessionFileId;
	}

	private void setRecordCount(Long id, Integer count) {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("sessionFileId", id);
		params.put("recordCount", count);
		params.put("status", statusSessionFile);
		logger.debug("sessionFileId:" + id + " recordCount:" + count + " status:" + statusSessionFile);
		processDao.changeSessionFile(userSessionId, params);
	}

	@SuppressWarnings("unused")
	private void setStatusToFile(Long id, String status) {
		processDao.setStatusToFile(userSessionId, id, status);
	}

	private void init() throws SystemException {
		processDao = new ProcessDao();
	}

	public Connection getConnection() {
		return connection;
	}

	public void setConnection(Connection connection) {
		this.connection = connection;
	}

	public Integer getContainerBindId() {
		return containerBindId;
	}

	@SuppressWarnings("UnusedDeclaration")
	public void setContainerBindId(Integer containerBindId) {
		this.containerBindId = containerBindId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public void setSessionFileId(Long sessionFileId) {
		this.sessionFileId = sessionFileId;
	}
}

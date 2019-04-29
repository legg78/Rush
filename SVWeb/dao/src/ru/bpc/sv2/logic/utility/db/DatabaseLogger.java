package ru.bpc.sv2.logic.utility.db;

import oracle.jdbc.OracleTypes;
import org.apache.log4j.AppenderSkeleton;
import org.apache.log4j.Level;
import org.apache.log4j.spi.LoggingEvent;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.utils.ExceptionUtils;

import javax.sql.DataSource;
import java.sql.*;

public class DatabaseLogger extends AppenderSkeleton {

    protected DataSource dataSource;

    public DatabaseLogger() {
	    dataSource = JndiUtils.getDataSource();
	}
	
	@Override
	protected void append(LoggingEvent event) {
		// we can pass here Map or some class containing session ID and user name
		Long sessionId = null;
		Integer containerId = null;
		String message = null;
		Long objectId = null;
		String entityType = null;
		String user = null;
		TraceLogInfo logInfo;
		if (event.getMessage() != null && event.getMessage() instanceof TraceLogInfo) {
			logInfo = (TraceLogInfo)event.getMessage();
			sessionId = logInfo.getSessionId();
			message = logInfo.getMessage();
			objectId = logInfo.getObjectId();
			entityType = logInfo.getEntityType();
			containerId = logInfo.getContainerId();
			user = logInfo.getUser();
		}
		
		String errMsg;
		if (event.getThrowableInformation() != null && event.getThrowableInformation().getThrowable() != null) {
			errMsg = ExceptionUtils.getExceptionMessage(event.getThrowableInformation().getThrowable());
			if (message == null) {
				message = errMsg;
			} else {
				message += ": Error: " + errMsg;
			}
		}
		
		Connection conn = null;
		CallableStatement cstmt = null;
		try {
			conn = dataSource.getConnection();
			if (sessionId != null) {
				if(user != null) {
					cstmt = conn.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
							"  i_user_name  	=> ?" +
							", io_session_id	=> ?)}");
					cstmt.setString(1, user.toUpperCase());
					cstmt.setObject(2, sessionId, OracleTypes.BIGINT);
					cstmt.execute();
				}
				else {
					cstmt = conn.prepareCall("{call PRC_API_SESSION_PKG.set_session_id(?)}");
					cstmt.setLong(1, sessionId);
					cstmt.execute();
				}
			}			
			
			if (Level.ERROR.equals(event.getLevel())) {
				closeStatement(cstmt);
			    cstmt = conn.prepareCall("{call TRC_LOG_PKG.error(i_text => ?, i_entity_type => ?, i_object_id => ?, i_container_id => ?)}");
			    fillStatement(cstmt, message, entityType, objectId, containerId);
			    cstmt.execute();
			} else if (Level.WARN.equals(event.getLevel())) {
				closeStatement(cstmt);
			    cstmt = conn.prepareCall("{call TRC_LOG_PKG.warn(i_text => ?, i_entity_type => ?, i_object_id => ?, i_container_id => ?)}");
			    fillStatement(cstmt, message, entityType, objectId, containerId);
			    cstmt.execute();
			} else if (Level.FATAL.equals(event.getLevel())) {
				closeStatement(cstmt);
			    cstmt = conn.prepareCall("{call TRC_LOG_PKG.fatal(i_text => ?, i_entity_type => ?, i_object_id => ?, i_container_id => ?)}");
			    fillStatement(cstmt, message, entityType, objectId, containerId);
			    cstmt.execute();
			} else if (Level.INFO.equals(event.getLevel()) || Level.TRACE.equals(event.getLevel())) {
				closeStatement(cstmt);
			    cstmt = conn.prepareCall("{call TRC_LOG_PKG.info(i_text => ?, i_entity_type => ?, i_object_id => ?, i_container_id => ?)}");
			    fillStatement(cstmt, message, entityType, objectId, containerId);
			    cstmt.execute();
			} else if (Level.DEBUG.equals(event.getLevel())) {
				closeStatement(cstmt);
			    cstmt = conn.prepareCall("{call TRC_LOG_PKG.debug(i_text => ?, i_entity_type => ?, i_object_id => ?, i_container_id => ?)}");
			    fillStatement(cstmt, message, entityType, objectId, containerId);
			    cstmt.execute();
			}

		} catch (Exception e) {
			System.err.println(e.getMessage());
			e.printStackTrace();
		} finally {
			closeStatement(cstmt);
			closeConnection(conn);
		}
	}

	private void fillStatement(CallableStatement cstmt, String message, String entityType, Long objectId, Integer containerId) throws SQLException{
	    if (message == null)
	    	cstmt.setNull(1, Types.VARCHAR);
	    else
	    	cstmt.setString(1, message);
	    if (entityType == null)
	    	cstmt.setNull(2, Types.VARCHAR);
	    else
	    	cstmt.setString(2, entityType);
	    if (objectId == null)
	    	cstmt.setNull(3, Types.NUMERIC);
	    else 
	    	cstmt.setLong(3, objectId);
	    if (containerId == null)
	    	cstmt.setNull(4, Types.NUMERIC);
	    else
	    	cstmt.setInt(4, containerId);
	}
	
	public void close() {
//		System.out.println("Database appender: close()");
	}

	public boolean requiresLayout() {
		return false;
	}
	
	private void closeConnection(Connection conn) {
		if (conn != null) {
			try {
				conn.close();
			} catch (SQLException ignored) {}
		}
	}

	private void closeStatement(Statement stmt) {
		if (stmt != null) {
			try {
				stmt.close();
			} catch (SQLException ignored) {}
		}
	}
	
}

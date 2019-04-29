package ru.bpc.sv2.scheduler.process;

import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.logic.utility.db.IbatisClient;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.utils.SystemException;

import javax.sql.DataSource;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Abstract class with basic functionality needed for running external process
 * and logging statistics.
 *
 * @author alexeev
 */
public abstract class IbatisExternalProcess implements ExternalProcess {
	protected SqlMapSession ssn = null;
	protected Connection con = null;
	protected SqlMapClient sqlClient;
	protected Long userSessionId;

	private Date effectiveDate;
	protected ProcessSession processSession;
	protected ProcessBO process;
	protected int threadsNumber = 1;
	protected String userName;

	private static Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDb = Logger.getLogger("PROCESSES_DB");

	public SqlMapSession getSsn() {
		return ssn;
	}

	protected void getIbatisSession() throws SystemException {
		try {
			if (sqlClient == null) {
				sqlClient = IbatisClient.getInstance().getSqlClient();
			}
			ssn = sqlClient.openSession(getConnection());
		} catch (Exception e) {
			throw new SystemException(e.getMessage(), e);
		}
	}

	protected Connection getConnection() throws SystemException {
		try {
			con = JndiUtils.getConnection();
			con.setAutoCommit(false);
		} catch (Exception e) {
			throw new SystemException(e.getMessage(), e);
		}
		return con;
	}

	/**
	 * <p>
	 * Logs current status. When errors percent exceeds error limit database
	 * will throw an exception and we <b>must</b> stop processing.
	 * </p>
	 *
	 * @param current - total number of processed entries including successful,
	 *                failed and rejected entries.
	 * @param fail    - number of failed entries
	 * @throws SystemException
	 */
	public void logCurrent(int current, int fail) throws SystemException {
		Map<String, Integer> map = new HashMap<String, Integer>(2);
		map.put("currentCount", current);
		map.put("exceptedCount", fail);

		try {
			ssn.update("process.prc-log-current", map);
		} catch (SQLException e) {
			throw new SystemException(FacesUtils.getMessage(e), e);
		}
	}

	public void endLogging(int succeed, int failed) {
		endLogging(succeed, failed, 0);
	}

	protected void endLogging(int succeed, int failed, int excepted) {
		Map<String, Object> map = new HashMap<String, Object>(4);
		map.put("processedTotal", succeed + failed + excepted);
		map.put("exceptedTotal", failed);
		map.put("rejectedTotal", excepted);
		map.put("resultCode", processSession.getResultCode());

		try {
			ssn.update("process.prc-log-end", map);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void logEstimated(int estimation) {
		logger.debug(String.format("Estimated records count: %d", estimation));
		try {
			ssn.update("process.prc-log-estimation", estimation);
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void startLogging() {
		try {
			ssn.update("process.prc-log-start");
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
		}
	}

	protected void startSession() throws SystemException {
		CallableStatement cstmt = null;
		try {
			if (effectiveDate != null) {
				cstmt = con.prepareCall("{call com_api_sttl_day_pkg.set_sysdate(i_sysdate => ?)}");
				cstmt.setTimestamp(1, new java.sql.Timestamp(effectiveDate.getTime()));
				cstmt.execute();
				cstmt.close();
			}
			cstmt = con.prepareCall("{call prc_api_session_pkg.start_session(io_session_id => ? , i_container_id => ?)}");
			cstmt.setLong(1, processSession.getSessionId());
			cstmt.setLong(2, process.getContainerBindId());
			cstmt.execute();
			con.commit();
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			throw new SystemException(e);
		} finally {
			DBUtils.close(cstmt);
		}
	}

	protected void closeConAndSsn() {
		try {
			if (ssn != null) {
				ssn.close();
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
		try {
			if (con != null) {
				con.close();
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
		}
	}

	public void commit() throws SystemException {
		try {
			if (con != null) {
				con.commit();
			}
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			throw new SystemException(e);
		}
	}

	public void rollback() throws SystemException {
		try {
			if (con != null) {
				con.rollback();
			}
		} catch (SQLException e) {
			logger.error(e.getMessage(), e);
			throw new SystemException(e);
		}
	}

	public ProcessSession getProcessSession() {
		return processSession;
	}

	@Override
	public void setProcessSession(ProcessSession processSession) {
		this.processSession = processSession;
	}

	public ProcessBO getProcess() {
		return process;
	}

	@Override
	public void setProcess(ProcessBO process) {
		this.process = process;
	}

	@SuppressWarnings("UnusedDeclaration")
	public Date getEffectiveDate() {
		if (effectiveDate != null) {
			return effectiveDate;
		} else {
			return new Date();
		}
	}

	@Override
	public void setEffectiveDate(Date effectiveDate) {
		this.effectiveDate = effectiveDate;
	}

	public Logger getLogger() {
		return logger;
	}

	public void setLogger(Logger logger) {
		IbatisExternalProcess.logger = logger;
	}


	protected String prepareMsg(String msg) {
		return String.format("%s [Seesion ID:%d]", msg, processSession.getSessionId());
	}

	public void debug(String msg) {
		logger.debug(prepareMsg(msg));
		if (msg != null && msg.length() > 128) {
			return; // Don't write too long messages to DB
		}
		loggerDb.debug(new TraceLogInfo(processSession.getSessionId(), getProcess() != null? getProcess().getContainerBindId() : null, msg));
	}

	public void info(String msg){
		logger.info(prepareMsg(msg));
		loggerDb.info(new TraceLogInfo(processSession.getSessionId(), getProcess() != null? getProcess().getContainerBindId() : null,  msg));
	}

	public void error(String msg) {
		logger.error(prepareMsg(msg));
		loggerDb.error(new TraceLogInfo(processSession.getSessionId(), getProcess() != null? getProcess().getContainerBindId() : null, msg));
	}

	public void error(Throwable t) {
		logger.error(prepareMsg(t.getMessage()), t);
		loggerDb.error(new TraceLogInfo(processSession.getSessionId(), getProcess() != null? getProcess().getContainerBindId() : null, t.getMessage()), t);
	}

	public void error(String msg, Throwable t) {
		logger.error(msg + "; " + prepareMsg(t.getMessage()), t);
		loggerDb.error(new TraceLogInfo(processSession.getSessionId(), getProcess() != null? getProcess().getContainerBindId() : null, msg + "; " + t.getMessage()), t);
	}

	public void trace(String msg){
		logger.trace(prepareMsg(msg));
	}

	public void warn(String msg) {
		logger.warn(prepareMsg(msg));
	}

	public Long processSessionId() {
		return processSession.getSessionId();
	}

	@Override
	public void setUserSessionId(Long userSessionId) {
		this.userSessionId = userSessionId;

	}

	@SuppressWarnings("UnusedDeclaration")
	public int getThreadsNumber() {
		return threadsNumber;
	}

	public void setThreadsNumber(int threadsNumber) {
		this.threadsNumber = threadsNumber;
	}

	@Override
	public void setUserName(String userName) {
		this.userName = userName;

	}
}

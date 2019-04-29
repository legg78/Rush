package ru.bpc.sv2.logic.utility.db;

import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;

import java.lang.reflect.InvocationTargetException;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.HashMap;

public abstract class IbatisAware extends DatabaseAware {

	private static final Logger systemLogger = Logger.getLogger("SYSTEM");

	protected SqlMapSession getIbatisSessionFE(Long sessionId) throws SQLException {
		return getIbatisSession(sessionId, null);
	}

	protected SqlMapSession getIbatisSessionFE(Long sessionId, String user) throws SQLException {
		return getIbatisSession(sessionId,  user);
	}

	protected SqlMapSession getIbatisSessionForConnection(Long sessionId, Connection con, String user) throws SQLException {
		return getIbatisSessionForConnection(sessionId, con, user, null);
	}

	protected SqlMapSession getIbatisSessionForConnection(Long sessionId, Connection con, String user, Integer containerId) throws SQLException {
		if (sessionId == null) {
			try {
				throw new SQLException(new Throwable("Session ID not defined!"));
			} catch (SQLException e) {
				systemLogger.error("", e);
				throw e;
			}
		}
		SqlMapSession ssn = new SqlMapSessionWrapper(geSqlClient().openSession(), false);
		HashMap<String, Object> params = new HashMap<String, Object>();
		params.put("sessionId", sessionId);
		params.put("user", user);
		params.put("containerId", containerId);
		setUserContext(params, con);
		ssn.setUserConnection(con);
		return ssn;
	}

	protected SqlMapSession getIbatisSession(Long sessionId) throws SQLException {
		return getIbatisSession(sessionId, null);
	}

	/**
	 * Set session context for internal processes and web services. Do not use for user sessions!
	 *
	 * @param sessionId      - session ID
	 * @param user           - system user name
	 * @return session
	 * @throws SQLException
	 */
	protected SqlMapSession getIbatisSession(Long sessionId, String user) throws SQLException {
		return getIbatisSession(sessionId, user, null);
	}

	protected SqlMapSession getIbatisSession(Long sessionId, String user, Integer containerId) throws SQLException {
		if (sessionId == null) {
			try {
				throw new SQLException(new Throwable("Session ID not defined!"));
			} catch (SQLException e) {
				systemLogger.error("", e);
				throw e;
			}
		}
		SqlMapSession ssn = new SqlMapSessionWrapper(geSqlClient().openSession());
		HashMap<String, Object> params = new HashMap<String, Object>();
		params.put("sessionId", sessionId);
		params.put("user", user);
		params.put("containerId", containerId);
		Connection con = getConnection(params);
		ssn.setUserConnection(con);
		return ssn;
	}

	protected SqlMapSession getIbatisSession(Long sessionId, String user, String privName, CommonParamRec[] paramArr) throws SQLException {
		if (sessionId == null) {
			try {
				throw new SQLException(new Throwable("Session ID not defined!"));
			} catch (SQLException e) {
				systemLogger.error("", e);
				throw e;
			}
		}
		SqlMapSession ssn = new SqlMapSessionWrapper(geSqlClient().openSession());
		HashMap<String, Object> params = new HashMap<String, Object>();
		params.put("sessionId", sessionId);
		params.put("user", user);
		params.put("privName", privName);
		Connection con;
		if (paramArr != null) {
			params.put("paramMap", paramArr);
			con = getConnectionForAudit(params);
		} else {
			con = getConnection(params);
		}
		ssn.setUserConnection(con);
		return ssn;
	}

	protected Long getUserSessionId(Long sessionId, String user, String privName, String remoteAddress, CommonParamRec[] paramArr) throws SQLException {
		HashMap<String, Object> params = new HashMap<String, Object>();
		params.put("sessionId", sessionId);
		params.put("user", user);
		params.put("privName", privName);
		params.put("paramMap", paramArr);
		params.put("remoteAddress", remoteAddress);
		getConnectionForAudit(params).close();
		return (Long) params.get("sessionId");
	}

    protected Long getUserSessionId(String user, String privName, String remoteAddress, CommonParamRec[] paramArr) throws SQLException {
        return getUserSessionId(null, user, privName, remoteAddress, paramArr);
    }

	/**
	 * Initialize context for UI user or system user
	 *
	 * @param params         May contain user name. If userName is null then it will be taken from the context.
	 *                       For UI users leave null in userName
	 * @return session
	 * @throws SQLException
	 */
	protected SqlMapSession getIbatisSessionInitContext(HashMap<String, Object> params) throws SQLException {
		SqlMapSession ssn = new SqlMapSessionWrapper(geSqlClient().openSession());
		Connection con = getConnection(params);
		ssn.setUserConnection(con);
		return ssn;
	}


	/**
	 * Get connection without context
	 *
	 * @return session
	 * @throws SQLException
	 */
	protected SqlMapSession getIbatisSessionNoContext() throws SQLException {
		SqlMapSession ssn = new SqlMapSessionWrapper(geSqlClient().openSession());
		Connection con = getConnectionNoContext();
		ssn.setUserConnection(con);
		return ssn;
	}

	protected SqlMapSession getIbatisProcessSession(boolean dropContext) throws SQLException {
		SqlMapSession ssn = getIbatisSessionNoContext();
		if (dropContext) {
			dropUserContext(ssn.getCurrentConnection());
		}
		return ssn;
	}

	protected SqlMapSession getIbatisProcessSession(Connection con, boolean dropContext) throws SQLException {
		SqlMapSession ssn = new SqlMapSessionWrapper(geSqlClient().openSession(), false);
		if (dropContext) {
			dropUserContext(con);
		}
		ssn.setUserConnection(con);
		return ssn;
	}

	protected void close(SqlMapSession ssn) {
		if (ssn != null) {
			try {
				// WAS eats all connections.
				if (!(ssn instanceof SqlMapSessionWrapper) && ssn.getCurrentConnection() != null)
					ssn.getCurrentConnection().close();
			} catch (Exception ignored) {
			}
			ssn.close();
		}
	}

	protected UserException getUserExceptionWithErrorCode(SqlMapSession ssn, String msg) {
		String errorCode = null;
		try {
			errorCode = (String) ssn.queryForObject("common.get-last-error");
		} catch (SQLException ignored) {
		}
		if (errorCode == null) {
			return new UserException(msg);
		} else {
			return new UserException(msg, errorCode, null);
		}
	}

	@SuppressWarnings("UnusedDeclaration")
	protected <R> R executeWithSession(IbatisSessionCallback<R> callback) {
		return executeWithSession(null,  null, null, callback);
	}

	@SuppressWarnings("UnusedDeclaration")
	protected <R> R executeWithSession(Logger logger, IbatisSessionCallback<R> callback) {
		return executeWithSession(null,  null, logger, callback);
	}

	@SuppressWarnings("UnusedDeclaration")
	protected <R> R executeWithSession(Long sessionId, Logger logger, IbatisSessionCallback<R> callback) {
		return executeWithSession(sessionId, null, logger, callback);
	}

	protected <R> R executeWithSession(Long sessionId, String privName, Logger logger, IbatisSessionCallback<R> callback) {
		return executeWithSession(sessionId, null, privName, null, logger, callback);
	}

	protected <R> R executeWithSession(Long sessionId, String privName, CommonParamRec[] paramArr, Logger logger, IbatisSessionCallback<R> callback) {
		return executeWithSession(sessionId, null, privName, paramArr, logger, callback);
	}

	protected <R> R executeWithSession(Long sessionId, String privName, SelectionParams params, Logger logger, IbatisSessionCallback<R> callback) {
		return executeWithSession(sessionId, null, privName, AuditParamUtil.getCommonParamRec(params.getFilters()), logger, callback);
	}

	protected <R> R executeWithSession(Long sessionId, String user, String privName, CommonParamRec[] paramArr, Logger logger, IbatisSessionCallback<R> callback) {
		SqlMapSession ssn;
		try {
			if (sessionId != null){
				ssn = getIbatisSession(sessionId, user, privName, paramArr);
			} else {
				ssn = getIbatisSessionNoContext();
			}
		} catch (SQLException e) {
			throw processException(e, logger);
		}
		return executeWithSession(ssn, true, logger, callback);
	}

	protected <R> R executeWithSession(SqlMapSession ssn, boolean closeSession, Logger logger, IbatisSessionCallback<R> callback) {
		try {
			return callback.doInSession(ssn);
		} catch (Exception e) {
			throw processException(e, logger);
		} finally {
			if (closeSession) {
				close(ssn);
			}
		}
	}

	protected DataAccessException processException(Throwable e, Logger logger) {
		if (e instanceof SQLException && e.getCause() != null) {
			e = e.getCause();
		}
		if (e instanceof InvocationTargetException && ((InvocationTargetException) e).getTargetException() != null) {
			e = ((InvocationTargetException) e).getTargetException();
		}
		if (logger != null) {
			logger.error(e.getMessage(), e);
		}
		if (!(e instanceof Exception)) {
			e = new DataAccessException(e.getMessage(), e);
		}
		return new DataAccessException(e.getMessage(), e);
	}

	private SqlMapClient geSqlClient() {
		return IbatisClient.getInstance().getSqlClient();
	}

	protected DataAccessException createDaoException(Exception e) {
		return DataAccessUtils.createException(e);
}
}

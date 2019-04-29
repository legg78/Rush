package ru.bpc.sv2.logic.utility.db;

import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.InsufficientPrivilegesException;
import ru.bpc.sv2.utils.LruCache;

import javax.annotation.Resource;
import javax.annotation.Resources;
import java.sql.*;
import java.util.*;

@SuppressWarnings("UnusedDeclaration")
public abstract class DatabaseAware {
	private static final Logger systemLogger = Logger.getLogger("SYSTEM");

	private static final String STATUS_OK = "UASTOKAY";

	public static final int REUSE_SESSIONS_CACHE_SIZE = 100;
	public static final long REUSE_SESSION_TIMEOUT_MSEC = 1000 * 60; // 1min
	private static final Map<Long, Long> reuseSessionsCache = Collections.synchronizedMap(new LruCache<Long, Long>(REUSE_SESSIONS_CACHE_SIZE));

	private static long reuseSessionsCacheLastCleanup = 0;
	private static ConnectionProvider connectionProvider = new ConnectionProvider();


	protected Connection getConnection() throws SQLException {
		return getConnection(null);
	}

	protected Connection getConnection(HashMap<String, Object> params) throws SQLException {
		Connection con = getConnectionFromDS();
		if (isNeededToSetContext(con, params)) {
			dropUserContext(con);
			setUserContext(params, con);
		}
		return con;
	}

	protected Connection getConnectionNoContext() throws SQLException {
		return getConnectionFromDS();
	}

	protected Connection getConnectionForAudit(HashMap<String, Object> params) throws SQLException {
		Connection con = getConnectionFromDS();
		dropUserContext(con);
		setUserContextForAudit(params, con);
		return con;
	}

	private Connection getConnectionFromDS() throws SQLException {
		return connectionProvider.getConnection();
	}

	/**
	 * When we need connection without additional audit parameters, and we are actually reusing connection that
	 * we initialized before, we could skip context initialization procedures to speed up db access
	 * To figure out that we got formely "ours" connection, we check session id, associated with that connection.
	 */
	protected boolean isNeededToSetContext(Connection con, HashMap<String, Object> params) {
		long now = System.currentTimeMillis();
		if (now > reuseSessionsCacheLastCleanup + REUSE_SESSION_TIMEOUT_MSEC) {
			reuseSessionsCacheLastCleanup = now;
			synchronized (reuseSessionsCache) {
				for (Iterator<Long> i = reuseSessionsCache.values().iterator(); i.hasNext(); ) {
					Long reuseStarted = i.next();
					if (now > reuseStarted + REUSE_SESSION_TIMEOUT_MSEC)
						i.remove();
				}
			}
		}
		if (con != null && params != null) {
			Long sessionId = (Long) params.get("sessionId");
			if (sessionId != null && sessionId > 0) {
				Long currentUserSessionId = getCurrentUserSessionId(con);
				if (currentUserSessionId != null && currentUserSessionId.equals(sessionId)) {
					Long reuseStarted = reuseSessionsCache.get(sessionId);
					if (reuseStarted != null) {
						return false;
					} else
						reuseSessionsCache.put(sessionId, System.currentTimeMillis());
				}
			}
		}
		return true;
	}

	protected void flushReusedSessionCache(Long sessionId) {
		reuseSessionsCache.remove(sessionId);
	}

	private void setUserContextForAudit(HashMap<String, Object> params, Connection con) throws SQLException {
		if (params == null || con == null) {
			return;
		}
		CallableStatement cstmt = null;
		try {
			Long sessionId = (Long) params.get("sessionId");
			String user = (String) params.get("user");
			String remoteAddress = (String) params.get("remoteAddress");
			String status = (String) params.get("status");
			String privName = (String) params.get("privName");
			String entityType = null;
			Number objectId = null;
			List<CommonParamRec> commonParamRecs = new ArrayList<CommonParamRec>();
			CommonParamRec[] commonParamRecsArr = (CommonParamRec[]) params.get("paramMap");
			// Extracting entity type and object id from params
			if (commonParamRecsArr != null) {
				Number fallbackObjectId = null;
				for (CommonParamRec param : commonParamRecsArr) {
					if (param.getElementName().equals(IAuditableObject.AUDIT_PARAM_OBJECT_ID)) {
						objectId = param.getValueN();
					} else if (param.getElementName().equals(IAuditableObject.AUDIT_PARAM_ENTITY_TYPE)) {
						entityType = param.getValueV();
					} else {
						commonParamRecs.add(param);
					}
					if (param.getElementName().equals("id")) {
						fallbackObjectId = param.getValueN();
					}
				}
				if (objectId == null && fallbackObjectId != null) {
					objectId = fallbackObjectId;
				}
			}

			cstmt = con.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
					"  i_user_name  	=> ?" +
					", io_session_id	=> ?" +
					", i_ip_address		=> ?" +
					", i_priv_name		=> ?" +
					", io_status		=> ?" +
					", i_entity_type	=> ?" +
					", i_object_id	    => ?" +
					", i_param_map		=> ?" +
					")}");
			if (user == null) {
				user = getUserName();
			}
			cstmt.setString(1, user.toUpperCase());
			if (sessionId == null) {
				cstmt.setObject(2, null, OracleTypes.BIGINT);
			} else {
				cstmt.setObject(2, sessionId, OracleTypes.BIGINT);
			}
			if (remoteAddress == null) {
				cstmt.setObject(3, null, OracleTypes.VARCHAR);
			} else {
				cstmt.setString(3, remoteAddress);
			}
			if (privName == null) {
				cstmt.setObject(4, null, OracleTypes.VARCHAR);
			} else {
				cstmt.setString(4, privName);
			}
			if (status == null) {
				cstmt.setObject(5, null, OracleTypes.VARCHAR);
			} else {
				cstmt.setString(5, status);
			}
			if (entityType == null) {
				cstmt.setObject(6, null, OracleTypes.VARCHAR);
			} else {
				cstmt.setString(6, entityType);
			}
			if (objectId == null) {
				cstmt.setObject(7, null, OracleTypes.BIGINT);
			} else {
				cstmt.setObject(7, objectId, OracleTypes.BIGINT);
			}

			Array parameter = DBUtils.createArray(AuthOracleTypeNames.COM_PARAM_MAP_TAB, con, commonParamRecs.toArray());
			cstmt.setArray(8, parameter);
			cstmt.registerOutParameter(2, OracleTypes.BIGINT);
			cstmt.registerOutParameter(5, OracleTypes.VARCHAR);
			cstmt.executeUpdate();

			if (sessionId == null) {
				sessionId = cstmt.getLong(2);
				params.put("sessionId", sessionId);
			}
			status = cstmt.getString(5);

			// TODO: do we really need this?
			cstmt.close();
			cstmt = con.prepareCall("COMMIT");
			cstmt.execute();

			if (!STATUS_OK.equals(status)) {
				throw new InsufficientPrivilegesException(privName);
			}
		} catch (SQLException e) {
			systemLogger.error(e.getMessage(), e);
			throw new SQLException(e); // just so that DAOs' catch which calls getCause() don't throw NPE
		} finally {
			DBUtils.close(cstmt);
		}
	}

	protected void setUserContext(HashMap<String, Object> params, Connection con) throws SQLException {
		if (params == null || con == null) {
			return;
		}
		CallableStatement cstmt = null;
		try {
			Long sessionId = (Long) params.get("sessionId");
			String user = (String) params.get("user");
			String remoteAddress = (String) params.get("remoteAddress");
			Object containerObj = params.get("containerId");

			cstmt = con.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
					"  i_user_name  	=> ?" +
					", io_session_id	=> ?" +
					", i_ip_address		=> ?" +
					", i_container_id	=> ?)}");

			if (user == null) {
				user = getUserName();
			}
			cstmt.setString(1, user.toUpperCase());
			if (sessionId == null) {
				cstmt.setObject(2, null, OracleTypes.BIGINT);
			} else {
				cstmt.setObject(2, sessionId, OracleTypes.BIGINT);
			}
			cstmt.registerOutParameter(2, OracleTypes.BIGINT);
			if (remoteAddress == null) {
				cstmt.setObject(3, null, OracleTypes.VARCHAR);
			} else {
				cstmt.setString(3, remoteAddress);
			}
			if(containerObj == null){
				cstmt.setObject(4, null, OracleTypes.BIGINT);
			}else{
				cstmt.setObject(4, Integer.valueOf(containerObj.toString()), OracleTypes.BIGINT);
			}
			cstmt.executeUpdate();

			if (sessionId == null) {
				sessionId = cstmt.getLong(2);
				params.put("sessionId", sessionId);
			}
			cstmt.close();
			cstmt = con.prepareCall("COMMIT");
			cstmt.execute();
		} catch (Exception e) {
			systemLogger.error(e.getMessage(), e);
		} finally {
			DBUtils.close(cstmt);
		}
	}

	protected void dropUserContext(Connection con) throws SQLException {
		CallableStatement cstmt = null;
		try {
			String sql = "{ call com_ui_user_env_pkg.drop_user_context() }";
			cstmt = con.prepareCall(sql);
			cstmt.execute();
			cstmt.close();
			cstmt = con.prepareCall("COMMIT");
			cstmt.execute();
		} catch (Exception e) {
			systemLogger.error(e.getMessage(), e);
		} finally {
			DBUtils.close(cstmt);
		}
	}

	public Long getCurrentUserSessionId(Connection con) {
		PreparedStatement ps = null;
		try {
			ps = con.prepareStatement("SELECT prc_api_session_pkg.get_session_id FROM dual");
			ResultSet rs = ps.executeQuery();
			if (rs.next())
				return rs.getLong(1);
		} catch (Exception e) {
			systemLogger.error(e.getMessage(), e);
		} finally {
			DBUtils.close(ps);
		}
		return null;
	}

	protected QueryParams convertQueryParams(SelectionParams params) {
		String userName = getUserName();

		QueryParams qparams;
		if (params == null) {
			qparams = new QueryParams(userName,
					new QueryRange(),
					null,
					true,
					true,
					null,
					null,
					null,
					null);
		} else {
			qparams = new QueryParams(userName,
					new QueryRange(params.getRowIndexStart(), params.getRowIndexEnd()),
					null,
					true,
					true,
					null,
					params.getFilters(),
					params.getSortElement(),
					params.getLimitation(),
					params.getThreshold(),
					params.getStartWith(),
					params.getModule(),
					params.getNetworkId(),
					params.getTableSuffix());
		}
		return qparams;
	}

	/**
	 * @param params     - query params
	 * @param limitation - If not null will override limitation in params
	 * @return converted params
	 */
	protected QueryParams convertQueryParams(SelectionParams params, String limitation) {
		String userName = getUserName();
		QueryParams qparams;
		if (params == null) {
			qparams = new QueryParams(userName,
					new QueryRange(),
					null,
					true,
					true,
					null,
					limitation,
					null,
					null);
		} else {
			if (limitation == null) {
				limitation = params.getLimitation();
			}
			qparams = new QueryParams(userName,
					new QueryRange(params.getRowIndexStart(), params.getRowIndexEnd()),
					null,
					true,
					true,
					null,
					params.getFilters(),
					params.getSortElement(),
					limitation,
					params.getThreshold(),
					params.getStartWith(),
					params.getModule(),
					params.getNetworkId(),
					params.getTableSuffix());
		}
		return qparams;
	}

	/**
	 * @param params     query params
	 * @param limitation - If not null will override limitation in params
	 * @param lang       language
	 * @return converted params
	 */
	protected QueryParams convertQueryParams(SelectionParams params, String limitation, String lang) {
		String userName = getUserName();
		QueryParams qparams;
		if (params == null) {
			qparams = new QueryParams(userName,
					new QueryRange(),
					lang,
					true,
					true,
					null,
					limitation,
					null,
					null);
		} else {
			if (limitation == null) {
				limitation = params.getLimitation();
			}
			qparams = new QueryParams(userName,
					new QueryRange(params.getRowIndexStart(), params.getRowIndexEnd()),
					lang,
					true,
					true,
					null,
					params.getFilters(),
					params.getSortElement(),
					limitation,
					params.getThreshold(),
					params.getStartWith(),
					params.getModule(),
					params.getNetworkId(),
					params.getTableSuffix());
		}
		return qparams;
	}

	private String getUserName() {
		return UserContextHolder.getUserName();
	}
}

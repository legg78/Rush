package ru.bpc.sv2.logic.svng;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.ps.ModuleParam;
import ru.bpc.sv2.ps.ModuleSession;
import ru.bpc.sv2.ps.ModuleSessionTrace;


import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static ru.bpc.sv2.logic.interchange.InterchangeDao.*;

@SuppressWarnings("unchecked")
public class ModuleDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");


	public List<ModuleSession> getSessions(String module, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getSsn(module);
			setupParams(module, params);
			return ssn.queryForList("module.get_sessions", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public List<ModuleSessionTrace> getSessionTrace(String module, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getSsn(module);
			setupParams(module, params);
			return ssn.queryForList("module.get_session_traces", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSessionTraceCount(String module, SelectionParams params) {
		return getCount("module.get_session_traces_count", module, params);
	}


	public int getSessionsCount(String module, SelectionParams params) {
		return getCount("module.get_sessions_count", module, params);
	}

	private int getCount(String queryId, String module, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getSsn(module);
			setupParams(module, params);
			return (Integer)ssn.queryForObject(queryId, convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ModuleParam[] getParams(String module, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getSsn(module);
			params.setModule(module);
			List<ModuleParam> items = ssn.queryForList("module.get_params", convertQueryParams(params));
			return items.toArray(new ModuleParam[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCountryParamsCount(String module, SelectionParams params) {
		return getCount("module.get_country_params_count", module, params);
	}


	public ModuleParam[] getCountryParams(String module, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getSsn(module);
			params.setModule(module);
			List<ModuleParam> items = ssn.queryForList("module.get_country_params", convertQueryParams(params));
			return items.toArray(new ModuleParam[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getParamsCount(String module, SelectionParams params) {
		return getCount("module.get_params_count", module, params);
	}


	public void deleteParam(String module, Long id) {
		SqlMapSession ssn = null;
		try {
			ssn = getSsn(module);
			Map<String, String> map = new HashMap<String, String>();
			map.put("id", id.toString());
			map.put("module", module);
			ssn.delete("module.delete_param", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void saveParam(String module, ModuleParam param, boolean update) {
		SqlMapSession ssn = null;
		try {
			ssn = getSsn(module);
			param.setModule(module);
			if (update) {
				ssn.update("module.update_param", param);
			} else {
				ssn.insert("module.insert_param", param);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	private SqlMapSession getSsn(String module) throws SQLException {
		return getIbatisSessionNoContext();
	}

	private void setupParams(String module, SelectionParams params) {
		params.setModule(module);
		if (MODULES_WITH_OPERATIONS_AS_VIEWS.contains(module)) {
			params.setTableSuffix("_vw");
			params.setModule(module.toLowerCase() + "_ui");
		}
	}
}

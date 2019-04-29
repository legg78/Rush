package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.controller.LovController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.scenario.AuthParam;
import ru.bpc.sv2.scenario.AuthState;
import ru.bpc.sv2.scenario.Scenario;
import ru.bpc.sv2.scenario.ScenarioPrivConstants;
import ru.bpc.sv2.scenario.ScenarioSelection;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class ScenariosDao
 */
public class ScenariosDao extends IbatisAware {

	@SuppressWarnings("unchecked")
	public Scenario[] getScenarios(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_AUTH_SCENARIO, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_AUTH_SCENARIO);
			List<Scenario> types = ssn.queryForList("scenarios.get-scenarios",
					convertQueryParams(params, limitation));
			return types.toArray(new Scenario[types.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getScenariosCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_AUTH_SCENARIO, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_AUTH_SCENARIO);
			return (Integer) ssn.queryForObject("scenarios.get-scenarios-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuthState[] getStates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_AUTH_SCENARIO_STATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_AUTH_SCENARIO_STATE);
			List<AuthState> types = ssn.queryForList("scenarios.get-states",
					convertQueryParams(params, limitation));
			return types.toArray(new AuthState[types.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getStatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_AUTH_SCENARIO_STATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_AUTH_SCENARIO_STATE);
			return (Integer) ssn.queryForObject("scenarios.get-states-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Scenario addScenario(Long userSessionId, Scenario scenario) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scenario.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.ADD_AUTH_SCENARIO, paramArr);

			ssn.insert("scenarios.add-scenario", scenario);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(scenario.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(scenario.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Scenario) ssn.queryForObject("scenarios.get-scenarios",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Scenario editScenario(Long userSessionId, Scenario scenario) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scenario.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.MODIFY_AUTH_SCENARIO, paramArr);
			
			ssn.insert("scenarios.edit-scenario", scenario);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(scenario.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(scenario.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Scenario) ssn.queryForObject("scenarios.get-scenarios",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteScenario(Long userSessionId, Scenario scenario) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scenario.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.REMOVE_AUTH_SCENARIO, paramArr);

			ssn.delete("scenarios.delete-scenario", scenario);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthState addState(Long userSessionId, AuthState state) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(state.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.ADD_AUTH_SCENARIO_STATE, paramArr);

			ssn.insert("scenarios.add-state", state);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(state.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(state.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthState) ssn.queryForObject("scenarios.get-states",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public AuthState editState(Long userSessionId, AuthState state) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(state.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.MODIFY_AUTH_SCENARIO_STATE, paramArr);

			ssn.update("scenarios.edit-state", state);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(state.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(state.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (AuthState) ssn.queryForObject("scenarios.get-states",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteState(Long userSessionId, AuthState state) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(state.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.REMOVE_AUTH_SCENARIO_STATE, paramArr);

			ssn.delete("scenarios.delete-state", state);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Scenario getScnByLangAndId(Long userSessionId, Integer id, String lang) {
		SqlMapSession ssn = null;

		try {
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("id", id);
			map.put("lang", lang);
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_AUTH_SCENARIO, paramArr);
			
			Scenario scn = (Scenario) ssn.queryForObject("scenarios.get-scn-by-lang-id", map);
			return scn;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuthParam[] getStateParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_AUTH_STATE_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_AUTH_STATE_PARAMETER);
			List<AuthParam> types = ssn.queryForList("scenarios.get-params",
					convertQueryParams(params, limitation));
			for (AuthParam param: types) {
				if (param.getLovId() != null && LovConstants.AUTH_STATE_PARAMS_STATES == param.getLovId()) {
					Map<String, Object> lovParams = new HashMap<String, Object>(); 
					lovParams.put("SCENARIO_ID", param.getScenarioId());
					if (param.getValueN() == null) {
						continue;
					}
					String key = String.valueOf(param.getValueN().intValue());
					param.setLovValue(LovController.getLovValue(ssn, key, param.getLovId(), lovParams));
				}
			}
			return types.toArray(new AuthParam[types.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getStateParamsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_AUTH_STATE_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_AUTH_STATE_PARAMETER);
			return (Integer) ssn.queryForObject("scenarios.get-params-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setParameter(Long userSessionId, AuthParam param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.SET_AUTH_STATE_PARAMETER, paramArr);
			if (param.isChar()) {
				ssn.update("scenarios.set-param_v", param);
			} else if (param.isNumber()) {
				ssn.update("scenarios.set-param_n", param);
			} else if(param.isDate()) {
				ssn.update("scenarios.set-param_d", param);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ScenarioSelection[] getScenarioSelections(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_SCENARIO_SELECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_SCENARIO_SELECTION);
			List<ScenarioSelection> types = ssn.queryForList("scenarios.get-scenario-selections",
			        convertQueryParams(params, limitation));
			return types.toArray(new ScenarioSelection[types.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getScenarioSelectionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.VIEW_SCENARIO_SELECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ScenarioPrivConstants.VIEW_SCENARIO_SELECTION);
			return (Integer) ssn.queryForObject("scenarios.get-scenario-selections-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ScenarioSelection addScenarioSelection(Long userSessionId, ScenarioSelection selection) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(selection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.ADD_SCENARIO_SELECTION, paramArr);

			ssn.insert("scenarios.add-scenario-selection", selection);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(selection.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(selection.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ScenarioSelection) ssn.queryForObject("scenarios.get-scenario-selections",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteScenarioSelection(Long userSessionId, ScenarioSelection selection) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(selection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ScenarioPrivConstants.REMOVE_SCENARIO_SELECTION, paramArr);

			ssn.delete("scenarios.delete-scenario-selection", selection);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

}

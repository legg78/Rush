package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.LovController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.settings.SettingPrivConstants;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.KeyLabelItem;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class OrgStructDao
 */
public class SettingsDao extends IbatisAware {

	@SuppressWarnings("unchecked")
	public SettingParam[] getSettingParams( Long userSessionId, SelectionParams params, boolean hierarchy, SettingParam param) {
    	SqlMapSession ssn = null;
		try	{
			List<SettingParam> setParams = new ArrayList<SettingParam>();
			if (param == null)
				param = new SettingParam();

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			String privName = null;
			if (LevelNames.USER.equals(param.getParamLevel())) {
				privName = SettingPrivConstants.VIEW_USER_SETTING_PARAM;
				ssn = getIbatisSession(userSessionId);
			} else {
				privName = SettingPrivConstants.VIEW_SETTING_PARAM;
				ssn = getIbatisSession(userSessionId, null, privName, paramArr);
			}


			if (hierarchy) {
				if (param.getParamLevel() != null) {
					if (param.getParamLevel().equals(LevelNames.SYSTEM))
						setParams = ssn.queryForList("settings.get-system-params-hier", param);
					if (param.getParamLevel().equals(LevelNames.INSTITUTION))
						setParams = ssn.queryForList("settings.get-inst-params-hier", param);
					if (param.getParamLevel().equals(LevelNames.AGENT))
						setParams = ssn.queryForList("settings.get-agent-params-hier", param);
					if (param.getParamLevel().equals(LevelNames.USER))
						setParams = ssn.queryForList("settings.get-user-params-hier", param);
				}
			} else {
				if (param.getParamLevel() != null) {
					if (param.getParamLevel().equals(LevelNames.SYSTEM))
						setParams = ssn.queryForList("settings.get-system-params", param);
					if (param.getParamLevel().equals(LevelNames.INSTITUTION))
						setParams = ssn.queryForList("settings.get-inst-params", param);
					if (param.getParamLevel().equals(LevelNames.AGENT))
						setParams = ssn.queryForList("settings.get-agent-params", param);
					if (param.getParamLevel().equals(LevelNames.USER))
						setParams = ssn.queryForList("settings.get-user-params", param);
				}
			}
			setParamsValue(ssn, setParams);

			return setParams.toArray(new SettingParam[setParams.size()]);
		} catch (Exception e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<SettingParam> getAllSystemParams() {
		return executeWithSession(new IbatisSessionCallback<List<SettingParam>>() {
			@Override
			public List<SettingParam> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("settings.get-system-params-no-context");
			}
		});
	}

	@SuppressWarnings("unchecked")
	public List<SettingParam> getAllInstParams(final Integer instId) {
		return executeWithSession(new IbatisSessionCallback<List<SettingParam>>() {
			@Override
			public List<SettingParam> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("settings.get-inst-params-no-context", instId);
			}
		});
	}

	@SuppressWarnings("unchecked")
	public List<SettingParam> getAllUserParams(final String userName) {
		return executeWithSession(new IbatisSessionCallback<List<SettingParam>>() {
			@Override
			public List<SettingParam> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("settings.get-user-params-no-context", userName);
			}
		});
	}


	public int getSettingParamsCount( Long userSessionId, SelectionParams params, SettingParam param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			String privName = null;
			if (LevelNames.USER.equals(param.getParamLevel())) {
				privName = SettingPrivConstants.VIEW_USER_SETTING_PARAM;
				ssn = getIbatisSession(userSessionId);
			} else {
				privName = SettingPrivConstants.VIEW_SETTING_PARAM;
				ssn = getIbatisSession(userSessionId, null, privName, paramArr);
			}


			return (Integer) ssn.queryForObject("settings.get-params-count", param);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	private void setParamsValue(SqlMapSession ssn, List<SettingParam> setParams) throws SQLException {
		for (SettingParam setParam : setParams) {
			List<KeyLabelItem> lovArr = new ArrayList<KeyLabelItem>();

			//get LOV values for this param
			if (setParam.getLovId() != null) {
				KeyLabelItem[] kli = null;
				if ((setParam.getLovId() == LovConstants.NAME_FORMATS) && setParam.getSystemName().equals("UID_NAME_FORMAT")) {
					try {
						HashMap<String, Object> params = new HashMap<String, Object>();
						params.put("entity_type", EntityNames.CARD_INSTANCE);
						params.put("institution_id", SystemConstants.DEFAULT_INSTITUTION);
						kli = LovController.getLov(ssn, setParam.getLovId(), params, null);
					} catch (Exception e) {
						throw new SQLException(e.getMessage(), e);
					}
				} else {
					kli = LovController.getLov(ssn, setParam.getLovId());
				}
				setParam.setLov(kli);
				lovArr = Arrays.asList(kli);
			}

			if (setParam.isChar()) {
				if (setParam.getLovId() != null) { //apply Label from LOV to field Value
					KeyLabelItem kl = new KeyLabelItem(setParam.getValueV());
					int index = lovArr.indexOf(kl);
					if (index != -1 )
						setParam.setValue(lovArr.get(index).getLabel());
					else
						setParam.setValue("");
				} else {
					setParam.setValue(setParam.getValueV());
				}
			}
			if (setParam.isNumber()){
				if (setParam.getLovId() != null) { //apply Label from LOV to field Value
					KeyLabelItem kl = new KeyLabelItem(setParam.getValueN());
					int index = lovArr.indexOf(kl);
					if (index != -1 )
						setParam.setValue(lovArr.get(index).getLabel());
					else
						setParam.setValue(null);
				} else {
					setParam.setValue(setParam.getValueN());
				}
			}
			if (setParam.isDate()) {
				setParam.setValue(setParam.getValueD());
			}

		}
	}

	@SuppressWarnings("unchecked")
	public SettingParam setParamValue( Long userSessionId, SettingParam param) {
    	SqlMapSession ssn = null;
		try	{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			String privName = null;
			if (LevelNames.USER.equals(param.getParamLevel())) {
				privName = SettingPrivConstants.SET_USER_PARAM_VALUE;
				ssn = getIbatisSession(userSessionId);
			} else {
				privName = SettingPrivConstants.SET_PARAM_VALUE;
				ssn = getIbatisSession(userSessionId, null, privName, paramArr);
			}

			if (param.getParamLevel().equals(LevelNames.SYSTEM)) {
				if (param.isChar())
					ssn.insert("settings.set-system-param_v", param);
				if (param.isNumber())
					ssn.insert("settings.set-system-param_n", param);
				if (param.isDate())
					ssn.insert("settings.set-system-param_d", param);
			}
			if (param.getParamLevel().equals(LevelNames.INSTITUTION)) {
				if (param.isChar())
					ssn.insert("settings.set-inst-param_v", param);
				if (param.isNumber())
					ssn.insert("settings.set-inst-param_n", param);
				if (param.isDate())
					ssn.insert("settings.set-inst-param_d", param);
			}
			if (param.getParamLevel().equals(LevelNames.AGENT)) {
				if (param.isChar())
					ssn.insert("settings.set-agent-param_v", param);
				if (param.isNumber())
					ssn.insert("settings.set-agent-param_n", param);
				if (param.isDate())
					ssn.insert("settings.set-agent-param_d", param);
			}
			if (param.getParamLevel().equals(LevelNames.USER)) {
				if (param.isChar())
					ssn.insert("settings.set-user-param_v", param);
				if (param.isNumber())
					ssn.insert("settings.set-user-param_n", param);
				if (param.isDate())
					ssn.insert("settings.set-user-param_d", param);
			}

			List<SettingParam> setParams = null;
			if (param.getParamLevel().equals(LevelNames.SYSTEM))
				setParams = ssn.queryForList("settings.get-system-params", param);
			if (param.getParamLevel().equals(LevelNames.INSTITUTION))
				setParams = ssn.queryForList("settings.get-inst-params", param);
			if (param.getParamLevel().equals(LevelNames.AGENT))
				setParams = ssn.queryForList("settings.get-agent-params", param);
			if (param.getParamLevel().equals(LevelNames.USER))
				setParams = ssn.queryForList("settings.get-user-params", param);

			if (setParams != null && setParams.size() > 0) {
				setParamsValue(ssn, setParams);

				// if parameter was set correctly there should be one and only one item in this list
				return setParams.get(0);
			}
			return new SettingParam();
		} catch(SQLException e) {
			throw new DataAccessException(e);
		} finally {
			flushReusedSessionCache(userSessionId);
			close(ssn);
		}
	}


	public String getParameterValueV(Long userSessionId, String paramName, String level, String levelValue){
		SqlMapSession ssn = null;
		try	{
			Map<String, String> map = new HashMap<String, String>();
			map.put("systemName", paramName);
			map.put("level", level);
			map.put("levelValue", levelValue);

			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
//				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
//				ssn = getIbatisSession(userSessionId, null, null, SettingPrivConstants.VIEW_PARAM_VALUE, paramArr);
				ssn = getIbatisSession(userSessionId);
			}

			if (LevelNames.SYSTEM.equals(level)) {
				ssn.insert("settings.get-system-param_v", map);
			}
			if (LevelNames.INSTITUTION.equals(level)) {
				ssn.insert("settings.get-inst-param_v", map);
			}
			if (LevelNames.AGENT.equals(level)) {
				ssn.insert("settings.get-agent-param_v", map);
			}
			if (LevelNames.USER.equals(level)) {
				ssn.insert("settings.get-user-param_v", map);
			}

			String result = map.get("value");
			return result;
		} catch(SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public Double getParameterValueN(Long userSessionId, String paramName, String level, String levelValue){
		SqlMapSession ssn = null;
		try	{
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("systemName", paramName);
			map.put("level", level);
			map.put("levelValue", levelValue);

			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
//				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
//				ssn = getIbatisSession(userSessionId, null, null, SettingPrivConstants.VIEW_PARAM_VALUE, paramArr);
				ssn = getIbatisSession(userSessionId);
			}

			if (LevelNames.SYSTEM.equals(level)) {
				ssn.insert("settings.get-system-param_n", map);
			}
			if (LevelNames.INSTITUTION.equals(level)) {
				ssn.insert("settings.get-inst-param_n", map);
			}
			if (LevelNames.AGENT.equals(level)) {
				ssn.insert("settings.get-agent-param_n", map);
			}
			if (LevelNames.USER.equals(level)) {
				ssn.insert("settings.get-user-param_n", map);
			}

			Double result = (Double)map.get("value");
			return result;
		} catch(SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public Date getParameterValueD(Long userSessionId, String paramName, String level, String levelValue){
		SqlMapSession ssn = null;
		try	{
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("systemName", paramName);
			map.put("levelValue", levelValue);

			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
//				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
//				ssn = getIbatisSession(userSessionId, null, null, SettingPrivConstants.VIEW_PARAM_VALUE, paramArr);
				ssn = getIbatisSession(userSessionId);
			}

			if (LevelNames.SYSTEM.equals(level)) {
				ssn.insert("settings.get-system-param_d", map);
			}
			if (LevelNames.INSTITUTION.equals(level)) {
				ssn.insert("settings.get-inst-param_d", map);
			}
			if (LevelNames.AGENT.equals(level)) {
				ssn.insert("settings.get-agent-param_d", map);
			}
			if (LevelNames.USER.equals(level)) {
				ssn.insert("settings.get-user-param_d", map);
			}

			Date result = (Date)map.get("value");
			return result;
		} catch(SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


    public String getRelease(Long userSessionId) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId == null) {
                ssn = getIbatisSessionNoContext();
            }
            else {
                ssn = getIbatisSession(userSessionId);
            }
            return ((String) ssn.queryForObject("settings.get-release"));
        }
        catch (SQLException sqle) {
            throw new DataAccessException(sqle);
        }
        finally {
            close(ssn);
        }
    }


	public void initialization(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("settings.initialization");
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
}

package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.rules.*;
import ru.bpc.sv2.rules.naming.*;
import ru.bpc.sv2.utils.AuditParamUtil;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;

/**
 * Session Bean implementation class RulesDao
 */
public class RulesDao extends AbstractDao {
	private static final Logger logger = Logger.getLogger("RULES");

	@Override
	protected Logger getLogger() {
		return logger;
	}
	@Override
	protected String getSqlMap() {
		return "rules";
	}

	public ModScale getModScaleById(Long userSessionId, ModScale filter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(filter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS_SCALE, paramArr);

			return (ModScale) ssn.queryForObject("rules.get-scale-by-id", filter);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ModScale[] getModScales(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS_SCALE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS_SCALE);
			List<ModScale> scales = ssn
					.queryForList("rules.get-scales", convertQueryParams(params, limitation));

			return scales.toArray(new ModScale[scales.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getModScalesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS_SCALE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS_SCALE);
			return (Integer) ssn.queryForObject("rules.get-scales-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ModScale addModScale(Long userSessionId, ModScale scale) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_SCALE, paramArr);

			ssn.insert("rules.add-scale", scale);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(scale.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(scale.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ModScale) ssn.queryForObject("rules.get-scales", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ModScale modifyModScale(Long userSessionId, ModScale scale) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_RULE_SCALE, paramArr);

			ssn.insert("rules.modify-scale", scale);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(scale.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(scale.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ModScale) ssn.queryForObject("rules.get-scales", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteModScale(Long userSessionId, ModScale scale) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_SCALE, paramArr);

			ssn.delete("rules.remove-scale", scale);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ModParam[] getModParams(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS);
			List<ModParam> modParams = ssn.queryForList("rules.get-params",
					convertQueryParams(params, limitation, lang));

			return modParams.toArray(new ModParam[modParams.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getModParamsCount(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS);
			return (Integer) ssn.queryForObject("rules.get-params-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ModParam[] getModParamsByScaleId(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS);
			List<ModParam> modParams = ssn.queryForList("rules.get-params-by-scale-id",
					convertQueryParams(params, limitation));

			return modParams.toArray(new ModParam[modParams.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getModParamsByScaleIdCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS_PARAMS);
			return (Integer) ssn.queryForObject("rules.get-params-by-scale-id-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ModParam addModParam(Long userSessionId, ModParam modParam) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(modParam.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_MODIFIER_PARAM, paramArr);

			ssn.insert("rules.add-param", modParam);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(modParam.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(modParam.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ModParam) ssn.queryForObject("rules.get-params", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ModParam modifyModParam(Long userSessionId, ModParam modParam) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(modParam.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_RULE_MODIFIER_PARAM, paramArr);

			ssn.insert("rules.modify-param", modParam);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(modParam.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(modParam.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ModParam) ssn.queryForObject("rules.get-params", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteModParam(Long userSessionId, Integer modId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_MODIFIER_PARAM, null);

			ssn.delete("rules.remove-param", modId);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Modifier[] getModifiers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS);
			List<Modifier> mods = ssn.queryForList("rules.get-modifiers", convertQueryParams(params, limitation));
			return mods.toArray(new Modifier[mods.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getModifiersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_MODIFIERS);
			return (Integer) ssn.queryForObject("rules.get-modifiers-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Modifier addModifier(Long userSessionId, Modifier modifier) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(modifier.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_MODIFIER, paramArr);

			ssn.insert("rules.add-modifier", modifier);

			return modifier;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Modifier modifyModifier(Long userSessionId, Modifier modifier) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(modifier.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_RULE_MODIFIER, paramArr);

			ssn.insert("rules.modify-modifier", modifier);

			return modifier;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteModifier(Long userSessionId, Modifier modifier) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(modifier.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_MODIFIER, paramArr);

			ssn.delete("rules.remove-modifier", modifier);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int includeParamInScale(Long userSessionId, Integer paramId, Integer scaleId,
	                               Integer scaleSeqNum) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.INCLUDE_RULE_PARAM_IN_SCALE, null);

			HashMap<String, Integer> map = new HashMap<String, Integer>(3);
			map.put("paramId", paramId);
			map.put("scaleId", scaleId);
			map.put("seqNum", scaleSeqNum);

			ssn.insert("rules.include-param-in-scale", map);

			return scaleSeqNum + 1;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int removeParamFromScale(Long userSessionId, Integer paramId, Integer scaleId,
	                                Integer scaleSeqNum) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_PARAM_FROM_SCALE, null);

			HashMap<String, Integer> map = new HashMap<String, Integer>(3);
			map.put("paramId", paramId);
			map.put("scaleId", scaleId);
			map.put("seqNum", scaleSeqNum);

			ssn.insert("rules.remove-param-from-scale", map);

			return scaleSeqNum + 1;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int createModParamAndAddtoScale(Long userSessionId, ModParam modParam, Integer scaleId,
	                                       Integer scaleSeqNum) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			// TODO: ssn.insert() doesn't return object created.
			// Is there any way to get back parameter except of using Map?
			// modParam = (ModParam) ssn.insert("rules.add-param", modParam);
			//
			// HashMap<String, Integer> map = new HashMap<String, Integer>(3);
			// map.put("paramId", modParam.getId());
			// map.put("scaleId", scaleId);
			// map.put("seqNum", scaleSeqNum);
			//			
			// ssn.insert("rules.include-param-in-scale", map);
			//			
			// return scaleSeqNum.intValue() + 1;
			return scaleSeqNum.intValue();
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public RuleSet[] getRuleSets(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_SETS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_SETS);
			List<RuleSet> sets = ssn
					.queryForList("rules.get-rule-sets", convertQueryParams(params, limitation));

			return sets.toArray(new RuleSet[sets.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRuleSetsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_SETS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_SETS);
			return (Integer) ssn.queryForObject("rules.get-rule-sets-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Rule[] getRules(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES);
			List<Rule> rules = ssn.queryForList("rules.get-rules", convertQueryParams(params, limitation));

			return rules.toArray(new Rule[rules.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRulesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES);
			return (Integer) ssn
					.queryForObject("rules.get-rules-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public RuleParam[] getRuleParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULE_PARAM, paramArr);

			List<RuleParam> pParams = ssn.queryForList("rules.get-rule-params",
					convertQueryParams(params));

			return pParams.toArray(new RuleParam[pParams.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRuleParamsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULE_PARAM, paramArr);
			return (Integer) ssn.queryForObject("rules.get-rule-params-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public RuleSet addRuleSet(Long userSessionId, RuleSet ruleSet) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ruleSet.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_SET, paramArr);

			ssn.insert("rules.add-rule-set", ruleSet);

			return ruleSet;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public RuleSet modifyRuleSet(Long userSessionId, RuleSet ruleSet) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ruleSet.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_RULE_SET, paramArr);

			ssn.update("rules.modify-rule-set", ruleSet);

			return ruleSet;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRuleSet(Long userSessionId, RuleSet ruleSet) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ruleSet.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_SET, paramArr);

			ssn.delete("rules.remove-rule-set", ruleSet);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setRuleParam(Long userSessionId, RuleParam param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.SET_RULE_PARAM_VALUE, paramArr);
			if (param.isChar()) {
				ssn.update("rules.set-value-char-rule-param", param);
			} else if (param.isNumber()) {
				ssn.update("rules.set-value-num-rule-param", param);
			} else if (param.isDate()) {
				ssn.update("rules.set-value-date-rule-param", param);
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeRuleParam(Long userSessionId, RuleParam param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_PARAM_VALUE, paramArr);

			ssn.delete("rules.remove-rule-param", param);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Rule addRule(Long userSessionId, Rule rule, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rule.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE, paramArr);

			ssn.insert("rules.add-rule", rule);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(rule.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Rule) ssn.queryForObject("rules.get-rules", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Rule modifyRule(Long userSessionId, Rule rule, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rule.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_RULE, paramArr);

			ssn.update("rules.modify-rule", rule);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(rule.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Rule) ssn.queryForObject("rules.get-rules", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRule(Long userSessionId, Rule rule) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rule.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE, paramArr);

			ssn.delete("rules.remove-rule", rule);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Modifier[] getModifiersByScaleType(Long userSessionId, String scaleType) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<ModParam> mods = ssn.queryForList("rules.get-modifiers-by-scale-type", scaleType);

			return mods.toArray(new Modifier[mods.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Modifier[] getModifiersForScenario(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS, paramArr);

			List<ModParam> mods = ssn.queryForList("rules.get-modifiers-for-scenario", params);

			return mods.toArray(new Modifier[mods.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Modifier[] getModifiers(Long userSessionId, Integer scaleId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_MODIFIERS, null);

			List<Modifier> mods = ssn.queryForList("rules.get-product-mods", scaleId);
			return mods.toArray(new Modifier[mods.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Procedure[] getProcedures(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_PROCEDURES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_PROCEDURES);
			List<Procedure> procs = ssn.queryForList("rules.get-procedures",
					convertQueryParams(params, limitation));

			return procs.toArray(new Procedure[procs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProceduresCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_PROCEDURES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_PROCEDURES);
			return (Integer) ssn.queryForObject("rules.get-procedures-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Procedure addProcedure(Long userSessionId, Procedure proc) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(proc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_PROCEDURE, paramArr);

			ssn.insert("rules.add-procedure", proc);

			return proc;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Procedure modifyProcedure(Long userSessionId, Procedure proc) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(proc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_RULE_PROCEDURE, paramArr);

			ssn.insert("rules.modify-procedure", proc);

			return proc;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcedure(Long userSessionId, Procedure proc) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(proc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_PROCEDURE, paramArr);

			ssn.delete("rules.remove-procedure", proc);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ProcedureParam[] getProcedureParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_PROCEDURE_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_PROCEDURE_PARAMS);
			List<ProcedureParam> pParams = ssn.queryForList("rules.get-procedure-params",
					convertQueryParams(params, limitation));

			return pParams.toArray(new ProcedureParam[pParams.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcedureParamsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_PROCEDURE_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_PROCEDURE_PARAMS);
			return (Integer) ssn.queryForObject("rules.get-procedure-params-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcedureParam addProcedureParam(Long userSessionId, ProcedureParam param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_PRC_PARAM, paramArr);

			ssn.insert("rules.add-procedure-param", param);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(param.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(param.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcedureParam) ssn.queryForObject("rules.get-procedure-params",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcedureParam modifyProcedureParam(Long userSessionId, ProcedureParam param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_RULE_PRC_PARAM, paramArr);

			ssn.insert("rules.modify-procedure-param", param);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(param.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(param.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcedureParam) ssn.queryForObject("rules.get-procedure-params",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcedureParam(Long userSessionId, ProcedureParam param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_PRC_PARAM, paramArr);

			ssn.delete("rules.remove-procedure-param", param);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Integer getScaleByObjectTypeAndProduct(Long userSessionId, Integer productId,
	                                              Integer instId, String objectType) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("productId", productId);
			map.put("instId", instId);
			map.put("objectType", objectType);

			List<Integer> scales = ssn.queryForList("rules.get-scale-by-object-type-and-product",
					map);
			if (scales.size() > 0)
				return scales.get(0);
			else
				return null;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NameFormat[] getNameFormats(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_FORMAT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_FORMAT);
			List<NameFormat> formats = ssn.queryForList("rules.get-name-formats",
					convertQueryParams(params, limitation));
			return formats.toArray(new NameFormat[formats.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getNameFormatsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_FORMAT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_FORMAT);
			return (Integer) ssn.queryForObject("rules.get-name-formats-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NameFormat syncNameFormat(Long userSessionId, NameFormat format) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(format.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.SYNC_RULE_NAME_FORMAT, paramArr);

			ssn.insert("rules.sync-name-format", format);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(format.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(format.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NameFormat) ssn.queryForObject("rules.get-name-formats",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNameFormat(Long userSessionId, NameFormat format) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(format.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_NAME_FORMAT, paramArr);

			ssn.delete("rules.remove-name-format", format);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public NameBaseParam[] getNameBaseParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_NAME_BASE_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_NAME_BASE_PARAMS);
			List<NameBaseParam> baseParams = ssn.queryForList("rules.get-name-base-params",
					convertQueryParams(params, limitation));
			return baseParams.toArray(new NameBaseParam[baseParams.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getNameBaseParamsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_RULES_NAME_BASE_PARAMS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_RULES_NAME_BASE_PARAMS);
			return (Integer) ssn.queryForObject("rules.get-name-base-params-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NameBaseParam addNameBaseParam(Long userSessionId, NameBaseParam param) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_NAME_BASE_PARAM, paramArr);

			ssn.insert("rules.add-name-base-param", param);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(param.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(param.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NameBaseParam) ssn.queryForObject("rules.get-name-base-params",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public NameComponent[] getNameComponents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_PART, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_PART);
			List<NameComponent> components = ssn.queryForList("rules.get-name-components",
					convertQueryParams(params, limitation));
			return components.toArray(new NameComponent[components.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getNameComponentsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_PART, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_PART);
			return (Integer) ssn.queryForObject("rules.get-name-components-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NameComponent syncNameComponent(Long userSessionId, NameComponent component) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.insert("rules.sync-name-component", component);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(component.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NameComponent) ssn.queryForObject("rules.get-name-components",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NameComponent syncNameComponentAndProperties(Long userSessionId,
	                                                    NameComponent component, List<ComponentProperty> properties) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.SYNC_NAME_PART_PROPERTY, null);

			ssn.insert("rules.sync-name-component", component);

			if (properties != null) {
				for (ComponentProperty property : properties) {
					property.setComponentId(component.getId());
					ssn.insert("rules.sync-property-value", property);
				}
			}

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(component.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NameComponent) ssn.queryForObject("rules.get-name-components",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNameComponent(Long userSessionId, NameComponent component) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_RULE_NAME_PART, null);

			ssn.delete("rules.remove-name-component", component);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNameComponentProperty(Long userSessionId, ComponentProperty property) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("rules.remove-name-component-property", property);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ComponentProperty[] getNameComponentPropertiesValues(Long userSessionId,
	                                                            SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_PART_PROPERTY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_PART_PROPERTY);
			List<ComponentProperty> components = ssn.queryForList(
					"rules.get-name-component-properties-values", convertQueryParams(params, limitation));
			return components.toArray(new ComponentProperty[components.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getNameComponentPropertiesValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_PART_PROPERTY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_PART_PROPERTY);
			return (Integer) ssn.queryForObject("rules.get-name-component-properties-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ComponentProperty syncNameComponentPropertyValue(Long userSessionId,
	                                                        ComponentProperty property) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(property.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.SYNC_NAME_PART_PROPERTY_VALUE, paramArr);

			ssn.insert("rules.sync-property-value", property);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(property.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ComponentProperty) ssn.queryForObject(
					"rules.get-name-component-properties-values", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNameComponentPropertyValue(Long userSessionId, ComponentProperty property) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(property.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_NAME_PART_PROPERTY_VALUE, paramArr);

			ssn.delete("rules.remove-property-value", property);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public NameIndexRange[] getNameIndexRanges(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_INDEX_RANGE);
			List<NameIndexRange> ranges = ssn.queryForList("rules.get-name-index-ranges",
					convertQueryParams(params, limitation));
			return ranges.toArray(new NameIndexRange[ranges.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getNameIndexRangesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_INDEX_RANGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_INDEX_RANGE);
			return (Integer) ssn.queryForObject("rules.get-name-index-ranges-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NameIndexRange syncNameIndexRange(Long userSessionId, NameIndexRange indexRange) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(indexRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.SYNC_NAME_INDEX_RANGE, paramArr);

			ssn.insert("rules.sync-name-index-range", indexRange);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(indexRange.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(indexRange.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NameIndexRange) ssn.queryForObject("rules.get-name-index-ranges",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNameIndexRange(Long userSessionId, NameIndexRange indexRange) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(indexRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_NAME_INDEX_RANGE, paramArr);

			ssn.delete("rules.remove-name-index-range", indexRange);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void regeneratePackages(Long userSessionId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.insert("rules.regenerate-packages");
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public NameIndexPool[] getNameIndexPools(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_INDEX_POOL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_INDEX_POOL);
			List<NameIndexPool> pools = ssn.queryForList("rules.get-name-index-pools",
					convertQueryParams(params, limitation));
			return pools.toArray(new NameIndexPool[pools.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getNameIndexPoolsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_NAME_INDEX_POOL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_NAME_INDEX_POOL);
			return (Integer) ssn.queryForObject("rules.get-name-index-pools-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NameIndexPool addNameIndexPool(Long userSessionId, NameIndexPool indexPool) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(indexPool.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_NAME_INDEX_POOL, paramArr);

			ssn.insert("rules.add-pool", indexPool);

			return indexPool;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeNameIndexPool(Long userSessionId, NameIndexPool indexPool) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(indexPool.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_NAME_INDEX_POOL, paramArr);

			ssn.delete("rules.remove-pool", indexPool);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeNameIndexPoolRange(Long userSessionId, NameIndexPool indexPool) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("rules.remove-pool-range", indexPool);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void clearNameIndexPool(Long userSessionId, NameIndexPool indexPool) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("rules.clear-pool", indexPool);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NameIndexPool addNameIndexPoolValue(Long userSessionId, NameIndexPool indexPoolValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(indexPoolValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_NAME_INDEX_POOL_VALUE, paramArr);

			ssn.insert("rules.add-pool-value", indexPoolValue);

			return indexPoolValue;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeNameIndexPoolValueById(Long userSessionId, Long id) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("rules.remove-pool-value-by-id", id);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeNameIndexPoolValue(Long userSessionId, NameIndexPool indexPoolValue) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(indexPoolValue.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_NAME_INDEX_POOL_VALUE, paramArr);

			ssn.delete("rules.remove-pool-value", indexPoolValue);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public RuleSet cloneRuleSet(Long userSessionId, RuleSet ruleSet) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ruleSet.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_RULE_SET, paramArr);

			ssn.update("rules.clone-rule-set", ruleSet);

			SelectionParams sp = new SelectionParams(new Filter[]{
					new Filter("id", ruleSet.getId()),
					new Filter("lang", ruleSet.getLang())
			});

			List<RuleSet> ruleSets = ssn
					.queryForList("rules.get-rule-sets", convertQueryParams(sp));

			RuleSet result = null;
			if (ruleSets != null && ruleSets.size() > 0) {
				result = ruleSets.get(0);
			}
			return result;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public DspCondition[] getDspConditions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_DISPUT_CONDITIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_DISPUT_CONDITIONS);
			List<ModScale> dspConditions = ssn
					.queryForList("rules.get-dsp-conditions", convertQueryParams(params, limitation));

			return dspConditions.toArray(new DspCondition[dspConditions.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDspConditionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_DISPUT_CONDITIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_DISPUT_CONDITIONS);
			return (Integer) ssn.queryForObject("rules.get-dsp-conditions-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DspCondition addDspCondition(Long userSessionId, DspCondition dspCon) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dspCon.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_DISPUT_CONDITIONS, paramArr);

			ssn.insert("rules.add-condition", dspCon);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(dspCon.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(dspCon.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (DspCondition) ssn.queryForObject("rules.get-dsp-conditions", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DspCondition modifyDspCondition(Long userSessionId, DspCondition dspCon) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dspCon.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_DISPUT_CONDITIONS, paramArr);

			ssn.insert("rules.modify-condition", dspCon);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(dspCon.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(dspCon.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (DspCondition) ssn.queryForObject("rules.get-dsp-conditions", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteDspCondition(Long userSessionId, DspCondition dspCon) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dspCon.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_DISPUT_CONDITIONS, paramArr);

			ssn.delete("rules.remove-condition", dspCon);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DspScale[] getDspScales(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_DISPUTE_SCALE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_DISPUTE_SCALE);
			List<DspScale> dspScales = ssn.queryForList("rules.get-dsp-scales", convertQueryParams(params, limitation));
			return dspScales.toArray(new DspScale[dspScales.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDspScalesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.VIEW_DISPUTE_SCALE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, RulePrivConstants.VIEW_DISPUTE_SCALE);
			return (Integer) ssn.queryForObject("rules.get-dsp-scales-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DspScale addDspScale(Long userSessionId, DspScale dspScale) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dspScale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.ADD_DISPUTE_SCALE, paramArr);
			ssn.insert("rules.add-dsp-scale", dspScale);
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(dspScale.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(dspScale.getId());
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (DspScale) ssn.queryForObject("rules.get-dsp-scales", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DspScale modifyDspScale(Long userSessionId, DspScale dspScale) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dspScale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.MODIFY_DISPUTE_SCALE, paramArr);
			ssn.insert("rules.modify-dsp-scale", dspScale);
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(dspScale.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(dspScale.getId());
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (DspScale) ssn.queryForObject("rules.get-dsp-scales", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteDspScale(Long userSessionId, DspScale dspScale) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dspScale.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, RulePrivConstants.REMOVE_DISPUTE_SCALE, paramArr);
			ssn.delete("rules.remove-dsp-scale", dspScale);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public List<RuleAlgorithm> getAlgorithms(Long userSessionId, SelectionParams params) {
		return getObjects(userSessionId, params, "get-algorithms");
	}

	public int getAlgorithmsCount(Long userSessionId, SelectionParams params) {
		return getCount(userSessionId, params, "get-algorithms-count");
	}

	public RuleAlgorithm addAlgorithm(Long userSessionId, RuleAlgorithm algorithm) {
		algorithm = insert(userSessionId, algorithm, "insert-algorithm");
		return algorithm;
	}

	public RuleAlgorithm modifyAlgorithm(Long userSessionId, RuleAlgorithm algorithm) {
		algorithm = update(userSessionId, algorithm, "update-algorithm");
		return algorithm;
	}

	public void deleteAlgorithm(Long userSessionId, RuleAlgorithm algorithm) {
		delete(userSessionId, algorithm, "delete-algorithm");
	}
}

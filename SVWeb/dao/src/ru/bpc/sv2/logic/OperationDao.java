package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.accounts.Transaction;
import ru.bpc.sv2.application.ApplicationPrivConstants;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.operations.*;
import ru.bpc.sv2.svng.AupTag;
import ru.bpc.sv2.svng.AuthData;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class OperationDao
 */
public class OperationDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	@SuppressWarnings("unchecked")
	public Rule[] getRules(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_RULES_SELECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_RULES_SELECTION);
			List<Rule> rules = ssn.queryForList("operations.get-rules",
					convertQueryParams(params, limitation));
			return rules.toArray(new Rule[rules.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getRulesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_RULES_SELECTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_RULES_SELECTION);
			return (Integer) ssn.queryForObject("operations.get-rules-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<Operation> getOperations(Long userSessionId,
									 SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : OperationPrivConstants.VIEW_OPERATION);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					privil);
			return ssn.queryForList(
					"operations.get-operations",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getOperationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : OperationPrivConstants.VIEW_OPERATION);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					privil);
			return (Integer) ssn.queryForObject(
					"operations.get-operations-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Transaction[] getEntries(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);

			List<Transaction> entries = ssn.queryForList(
					"operations.get-transactions-by-oper",
					convertQueryParams(params));
			return entries.toArray(new Transaction[entries.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Transaction[] getEntriesForOperation(Long userSessionId,
												SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);

			List<Transaction> entries = ssn.queryForList(
					"operations.get-transactions-by-oper",
					convertQueryParams(params));
			return entries.toArray(new Transaction[entries.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEntriesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, AccountPrivConstants.VIEW_TRANSACTION, paramArr);

			return (Integer) ssn.queryForObject(
					"operations.get-transactions-count-by-oper",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Rule addRule(Long userSessionId, Rule rule, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rule.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_RULE_SELECTION, paramArr);

			ssn.insert("operations.add-rule", rule);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(rule.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Rule) ssn.queryForObject("operations.get-rules",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Rule modifyRule(Long userSessionId, Rule rule, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rule.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_RULE_SELECTION, paramArr);
			ssn.update("operations.modify-rule", rule);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(rule.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Rule) ssn.queryForObject("operations.get-rules",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRule(Long userSessionId, Rule rule) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rule.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_RULE_SELECTION, paramArr);
			ssn.delete("operations.remove-rule", rule);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MatchLevel[] getMatchLevels(Long userSessionId,
									   SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_MATCH_LEVELS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_MATCH_LEVELS);
			List<MatchLevel> levels = ssn.queryForList(
					"operations.get-match-levels",
					convertQueryParams(params, limitation));
			return levels.toArray(new MatchLevel[levels.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getMatchLevelsCount(Long userSessionId,
									   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_MATCH_LEVELS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_MATCH_LEVELS);
			return (Integer) ssn.queryForObject(
					"operations.get-match-levels-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MatchLevel addMatchLevel(Long userSessionId, MatchLevel level) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(level.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_MATCH_LEVEL, paramArr);

			ssn.insert("operations.add-match-level", level);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(level.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(level.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MatchLevel) ssn.queryForObject(
					"operations.get-match-levels", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MatchLevel modifyMatchLevel(Long userSessionId, MatchLevel level) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(level.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_MATCH_LEVEL, paramArr);
			ssn.update("operations.modify-match-level", level);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(level.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(level.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MatchLevel) ssn.queryForObject(
					"operations.get-match-levels", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeMatchLevel(Long userSessionId, MatchLevel level) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(level.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_MATCH_LEVEL, paramArr);
			ssn.delete("operations.remove-match-level", level);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MatchCondition[] getMatchConditions(Long userSessionId,
											   SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_MATCH_CONDITIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_MATCH_CONDITIONS);
			List<MatchCondition> conds = ssn.queryForList(
					"operations.get-match-conditions",
					convertQueryParams(params, limitation));
			return conds.toArray(new MatchCondition[conds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getMatchConditionsCount(Long userSessionId,
										   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_MATCH_CONDITIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_MATCH_CONDITIONS);
			return (Integer) ssn.queryForObject(
					"operations.get-match-conditions-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MatchCondition addMatchCondition(Long userSessionId,
											MatchCondition condition) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(condition.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_MATCH_CONDITION, paramArr);

			ssn.insert("operations.add-match-condition", condition);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(condition.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(condition.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MatchCondition) ssn.queryForObject(
					"operations.get-match-conditions",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MatchCondition modifyMatchCondition(Long userSessionId,
											   MatchCondition condition) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(condition.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_MATCH_CONDITION, paramArr);
			ssn.update("operations.modify-match-condition", condition);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(condition.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(condition.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MatchCondition) ssn.queryForObject(
					"operations.get-match-conditions",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeMatchCondition(Long userSessionId,
									 MatchCondition condition) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(condition.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_MATCH_CONDITION, paramArr);
			ssn.delete("operations.remove-match-condition", condition);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MatchLevelCondition[] getMatchLevelConditions(Long userSessionId,
														 SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_MATCH_LEVEL_CONDITIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_MATCH_LEVEL_CONDITIONS);
			List<MatchLevelCondition> conds = ssn.queryForList(
					"operations.get-match-level-conditions",
					convertQueryParams(params, limitation));
			return conds.toArray(new MatchLevelCondition[conds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getMatchLevelConditionsCount(Long userSessionId,
												SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_MATCH_LEVEL_CONDITIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_MATCH_LEVEL_CONDITIONS);
			return (Integer) ssn.queryForObject(
					"operations.get-match-level-conditions-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void includeConditionInLevel(Long userSessionId,
										MatchLevelCondition condition) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(condition.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_LEVEL_CONDITION, paramArr);

			ssn.update("operations.include-condition-in-level", condition);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeConditionFromLevel(Long userSessionId,
										 MatchLevelCondition condition) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(condition.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_LEVEL_CONDITION, paramArr);
			ssn.update("operations.remove-condition-from-level", condition);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void addAdjusment(Long userSessionId, final Operation operation) {
		executeWithSession(userSessionId,
						   OperationPrivConstants.ADD_ADJUSTMENT,
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ru.bpc.sv2.operations.incoming.Operation tmp = operation.toOperation();
				ssn.update("operations.add-adjusment", tmp);
				operation.setId(tmp.getId());
				if (operation.getParticipants() != null) {
					for (Participant participant : operation.getParticipants()) {
						ssn.update("operations.add-participant", operation.toOperation(participant.getParticipantType()));
					}
				}
				return null;
			}
		});
	}

	public void addAdjusment(Long userSessionId, final ru.bpc.sv2.operations.incoming.Operation operation) {
		executeWithSession(userSessionId,
						   OperationPrivConstants.ADD_ADJUSTMENT,
						   AuditParamUtil.getCommonParamRec(operation.getAuditParameters()),
						   logger,
						   new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("operations.add-adjusment", operation);
				ssn.update("operations.add-participant", operation);
				return null;
			}
		});
	}

	@SuppressWarnings("unchecked")
	public Check[] getChecks(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPR_CHECK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPR_CHECK);
			List<Check> checks = ssn.queryForList("operations.get-checks",
					convertQueryParams(params, limitation));
			return checks.toArray(new Check[checks.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getChecksCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPR_CHECK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPR_CHECK);
			return (Integer) ssn.queryForObject("operations.get-checks-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Check addCheck(Long userSessionId, Check check, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(check.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_OPR_CHECK, paramArr);

			ssn.insert("operations.add-check", check);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(check.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Check) ssn.queryForObject("operations.get-checks",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Check modifyCheck(Long userSessionId, Check check, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(check.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_OPR_CHECK, paramArr);
			ssn.update("operations.modify-check", check);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(check.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Check) ssn.queryForObject("operations.get-checks",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeCheck(Long userSessionId, Check check) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(check.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_OPR_CHECK, paramArr);
			ssn.delete("operations.remove-check", check);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CheckGroup[] getCheckGroups(Long userSessionId,
									   SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPR_CHECK_GROUP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPR_CHECK_GROUP);
			List<CheckGroup> groups = ssn.queryForList(
					"operations.get-check-groups",
					convertQueryParams(params, limitation));
			return groups.toArray(new CheckGroup[groups.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getCheckGroupsCount(Long userSessionId,
									   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPR_CHECK_GROUP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPR_CHECK_GROUP);
			return (Integer) ssn.queryForObject(
					"operations.get-check-groups-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CheckGroup addCheckGroup(Long userSessionId, CheckGroup checkGroup) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(checkGroup.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_OPR_CHECK_GROUP, paramArr);

			ssn.insert("operations.add-check-group", checkGroup);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(checkGroup.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(checkGroup.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CheckGroup) ssn.queryForObject(
					"operations.get-check-groups", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CheckGroup modifyCheckGroup(Long userSessionId, CheckGroup checkGroup) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(checkGroup.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_OPR_CHECK_GROUP, paramArr);
			ssn.update("operations.modify-check-group", checkGroup);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(checkGroup.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(checkGroup.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CheckGroup) ssn.queryForObject(
					"operations.get-check-groups", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeCheckGroup(Long userSessionId, CheckGroup checkGroup) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(checkGroup.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_OPR_CHECK_GROUP, paramArr);
			ssn.delete("operations.remove-check-group", checkGroup);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CheckSelection[] getCheckSelections(Long userSessionId,
											   SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPR_CHECK_SELECT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPR_CHECK_SELECT);
			List<CheckSelection> selections = ssn.queryForList(
					"operations.get-check-selections",
					convertQueryParams(params, limitation));
			return selections.toArray(new CheckSelection[selections.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getCheckSelectionsCount(Long userSessionId,
										   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPR_CHECK_SELECT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPR_CHECK_SELECT);
			return (Integer) ssn.queryForObject(
					"operations.get-check-selections-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CheckSelection addCheckSelection(Long userSessionId,
											CheckSelection checkSelection, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(checkSelection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_OPR_CHECK_SELECT, paramArr);

			ssn.insert("operations.add-check-selection", checkSelection);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(checkSelection.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CheckSelection) ssn.queryForObject(
					"operations.get-check-selections",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CheckSelection modifyCheckSelection(Long userSessionId,
											   CheckSelection checkSelection, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(checkSelection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_OPR_CHECK_SELECT, paramArr);
			ssn.update("operations.modify-check-selection", checkSelection);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(checkSelection.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CheckSelection) ssn.queryForObject(
					"operations.get-check-selections",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeCheckSelection(Long userSessionId,
									 CheckSelection checkSelection) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(checkSelection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_OPR_CHECK_SELECT, paramArr);
			ssn.delete("operations.remove-check-selection", checkSelection);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public EntityOperType[] getEntityOperTypes(Long userSessionId,
											   SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_ENTITY_OPER_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_ENTITY_OPER_TYPE);
			List<EntityOperType> entOperTypes = ssn.queryForList(
					"operations.get-entity-oper-types",
					convertQueryParams(params, limitation));
			return entOperTypes
					.toArray(new EntityOperType[entOperTypes.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEntityOperTypesCount(Long userSessionId,
										   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_ENTITY_OPER_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_ENTITY_OPER_TYPE);
			return (Integer) ssn.queryForObject(
					"operations.get-entity-oper-types-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EntityOperType addEntityOperType(Long userSessionId,
											EntityOperType entOperType, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(entOperType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_ENTITY_OPER_TYPE, paramArr);

			ssn.insert("operations.add-entity-oper-type", entOperType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(entOperType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EntityOperType) ssn.queryForObject(
					"operations.get-entity-oper-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EntityOperType modifyEntityOperType(Long userSessionId,
											   EntityOperType entOperType, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(entOperType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_ENTITY_OPER_TYPE, paramArr);
			ssn.update("operations.modify-entity-oper-type", entOperType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(entOperType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EntityOperType) ssn.queryForObject(
					"operations.get-entity-oper-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeEntityOperType(Long userSessionId,
									 EntityOperType entOperType) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(entOperType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_ENTITY_OPER_TYPE, paramArr);
			ssn.delete("operations.remove-entity-oper-type", entOperType);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Operation[] getOperationsByDocument(Long userSessionId,
											   SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_ISSUING_OPERATIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_ISSUING_OPERATIONS);
			List<Operation> opers = ssn.queryForList(
					"operations.get-operations-by-document",
					convertQueryParams(params, limitation));

			return opers.toArray(new Operation[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getOperationsByDocumentCount(Long userSessionId,
												SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_ISSUING_OPERATIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_ISSUING_OPERATIONS);
			return (Integer) ssn.queryForObject(
					"operations.get-operations-by-document-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Operation[] getOperationsByParticipant(Long userSessionId,
												  SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			List<Operation> opers = ssn.queryForList(
					"operations.get-operations-by-participant",
					convertQueryParams(params, limitation));

			return opers.toArray(new Operation[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ru.bpc.sv2.operations.incoming.Operation[] getOperationsByTerminal(Long userSessionId,
																			  SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			List<ru.bpc.sv2.operations.incoming.Operation> opers = ssn.queryForList(
					"operations.get-operations-by-terminal",
					convertQueryParams(params, limitation));

			return opers.toArray(new ru.bpc.sv2.operations.incoming.Operation[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Integer getOperationsByTerminalCount(Long userSessionId,
												SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			return (Integer) ssn.queryForObject(
					"operations.get-operations-by-terminal-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}



	public Integer getOperationsByParticipantCount(Long userSessionId,
												   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			return (Integer) ssn.queryForObject(
					"operations.get-operations-by-participant-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Operation[] getAtmOperationsByParticipant(Long userSessionId,
													 SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			List<Operation> opers = ssn.queryForList(
					"operations.get-atm-operations-by-participant",
					convertQueryParams(params, limitation));

			return opers.toArray(new Operation[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getAtmOperationsByParticipantCount(Long userSessionId,
													  SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			return (Integer) ssn.queryForObject(
					"operations.get-atm-operations-by-participant-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Participant[] getParticipants(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PARTICIPANT, paramArr);
			List<Participant> items = ssn.queryForList(
					"operations.get-participants", convertQueryParams(params));

			return items.toArray(new Participant[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getParticipantsCount(Long userSessionId,
										SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PARTICIPANT, paramArr);
			return (Integer) ssn.queryForObject(
					"operations.get-participants-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Operation[] getOperationsByPmo(Long userSessionId,
										  SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			List<Operation> opers = ssn.queryForList(
					"operations.get-operations-by-pmo",
					convertQueryParams(params, limitation, lang));

			return opers.toArray(new Operation[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getOperationsByPmoCount(Long userSessionId,
										   SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_OPERATION);
			return (Integer) ssn.queryForObject(
					"operations.get-operations-by-pmo-count",
					convertQueryParams(params, limitation, lang));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Operation[] getOperationsLight(SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			ssn = getIbatisSessionNoContext();
			List<Operation> opers = ssn.queryForList(
					"operations.get-operations-light",
					convertQueryParams(params));
			return opers.toArray(new Operation[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ParticipantType[] getParticipantTypes(Long userSessionId,
												 SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PARTICIPANT_TYPE, paramArr);

			List<ParticipantType> items = ssn.queryForList("operations.get-participant-types",
					convertQueryParams(params));
			return items.toArray(new ParticipantType[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getParticipantTypesCount(Long userSessionId,
										SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PARTICIPANT_TYPE, paramArr);

			return (int) (Integer) ssn.queryForObject(
					"operations.get-participant-types-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ParticipantType createParticipantType(Long userSessionId,
												 ParticipantType editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_PARTICIPANT_TYPE, paramArr);
			ssn.update("operations.add-participant-type", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ParticipantType) ssn.queryForObject(
					"operations.get-participant-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeParticipantType(Long userSessionId,
									  ParticipantType activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_PARTICIPANT_TYPE, paramArr);
			ssn.update("operations.remove-participant-type", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public TechnicalMessage[] getTechnicalMessages(Long userSessionId,
												   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_TECHNICAL_MSG, paramArr);

			List<TechnicalMessage> items = ssn.queryForList(
					"operations.get-technical-messages",
					convertQueryParams(params));
			return items.toArray(new TechnicalMessage[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getTechnicalMessagesCount(Long userSessionId,
											 SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_TECHNICAL_MSG, paramArr);
			return (Integer) ssn.queryForObject(
					"operations.get-technical-messages-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public TechnicalMessageDetail[] getTechnicalMessageDetails(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_TECHNICAL_MSG_DETAIL, paramArr);

			List<TechnicalMessageDetail> items = ssn.queryForList(
					"operations.get-technical-message-details", convertQueryParams(params));
			return items.toArray(new TechnicalMessageDetail[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getTechnicalMessageDetailsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_TECHNICAL_MSG_DETAIL, paramArr);
			return (Integer) ssn.queryForObject(
					"operations.get-technical-message-details-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Operation[] getAssociatedOperations(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			Map<String, Object> map = new HashMap<String, Object>();
			for(Filter filter:params.getFilters()){
				map.put(filter.getElement(), filter.getValue());
			}
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			List<Operation> opers = ssn.queryForList("operations.get-associated-operations-pipelined", map);

			return opers.toArray(new Operation[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getAssociatedOperationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, OperationPrivConstants.VIEW_OPERATION);
			return (Integer) ssn.queryForObject("operations.get-associated-operations-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EntityOperTypeBundle[] getEntityOperTypeBundles(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			//noinspection unchecked
			List<EntityOperTypeBundle> items = ssn.queryForList("operations.get-entity-oper-type-bundle", convertQueryParams(params));
			return items.toArray(new EntityOperTypeBundle[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getEntityOperTypeBundlesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return (int) (Integer)ssn.queryForObject("operations.get-entity-oper-type-bundle-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public String processOperation(Long userSessionId, final Long operationId) {
		return processOperation(userSessionId, operationId, null);
	}

	public String processOperation(Long userSessionId, final Long operationId, final Map<String, Object> params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<String>() {
			@Override
			public String doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> paramMap = new HashMap<String, Object>();
				paramMap.put("operationId", operationId);
				paramMap.put("paramsTab", params);
				ssn.update("operations.process-operation", paramMap);

			SelectionParams sp = SelectionParams.build("id", operationId);
				Object operation = ssn.queryForObject("operations.get-operations", convertQueryParams(sp));
				return (operation != null) ? ((Operation)operation).getStatus() : null;
			}
		});
	}

	public ReasonMapping[] getReasonMappings(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_REASON_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, OperationPrivConstants.VIEW_REASON_MAPPING);
			//noinspection unchecked
			List<ReasonMapping> opers = ssn.queryForList("operations.get-reason-mappings",
					convertQueryParams(params, limitation));

			return opers.toArray(new ReasonMapping[opers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getReasonMappingsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_REASON_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, OperationPrivConstants.VIEW_REASON_MAPPING);
			return (Integer) ssn.queryForObject("operations.get-reason-mappings-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReasonMapping addReasonMapping(Long userSessionId, ReasonMapping reasonMapping) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reasonMapping.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_REASON_MAPPING, paramArr);

			ssn.insert("operations.add-reason-mapping", reasonMapping);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reasonMapping.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReasonMapping) ssn.queryForObject("operations.get-reason-mappings",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReasonMapping modifyReasonMapping(Long userSessionId, ReasonMapping reasonMapping) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reasonMapping.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_REASON_MAPPING, paramArr);
			ssn.update("operations.modify-reason-mapping", reasonMapping);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reasonMapping.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReasonMapping) ssn.queryForObject("operations.get-reason-mappings", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteReasonMapping(Long userSessionId, ReasonMapping reasonMapping) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reasonMapping.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_REASON_MAPPING, paramArr);
			ssn.delete("operations.remove-reason-mapping", reasonMapping);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<Operation> getOperationCursor(Long userSessionId, SelectionParams params,
										  Map<String, Object> paramMap, String privName) {
		SqlMapSession ssn = null;
		try{
			List<Filter> filters = new ArrayList<Filter>(Arrays.asList((Filter[])paramMap.get("param_tab")));
			if (!privName.equals(ApplicationPrivConstants.VIEW_DISPUTE_APPLICATIONS)) {
				if (privName == null) {
					privName = OperationPrivConstants.VIEW_OPERATION;
				}
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
				ssn = getIbatisSession(userSessionId, null, privName, paramArr);
				String limitation = CommonController.getLimitationByPriv(ssn, privName);
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			} else {
				ssn = getIbatisSession(userSessionId);
				filters.add(new Filter("PRIVIL_LIMITATION", null));
			}
			paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			QueryParams qparams = convertQueryParams(params);
			paramMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramMap.put("last_row", qparams.getRange().getEndPlusOne());
			paramMap.put("sorting_tab", params.getSortElement());
			ssn.update("operations.get-oper-cur", paramMap);
			return (List<Operation>)paramMap.get("ref_cur");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getOperationCursorCount(Long userSessionId, Map<String, Object> params, String privName) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);

			Filter[] filterArr = (Filter[]) params.get("param_tab");
			if (StringUtils.isNotBlank(privName)) {
				CommonController.checkFilterLimitation(ssn, privName, filterArr);
			}

			List<Filter> filters = new ArrayList<Filter>(Arrays.asList(filterArr));
			if (!privName.equals(ApplicationPrivConstants.VIEW_DISPUTE_APPLICATIONS)) {
				if (privName == null) {
					privName = OperationPrivConstants.VIEW_OPERATION;
				}
				String limitation = CommonController.getLimitationByPriv(ssn, privName);
				filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			} else {
				filters.add(new Filter("PRIVIL_LIMITATION", null));
			}
			params.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("operations.get-oper-cur-count", params);
			return (Integer) params.get("row_count");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifyOperStatus(Long userSessionId, Operation operation) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.modify-status", operation);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public List<OperationStat> getOperationStats(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<OperationStat>>() {
			@Override
			public List<OperationStat> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("operations.get-operations-stat", convertQueryParams(params));
			}
		});
	}


    public List<EntryStat> getEntriesStatsLogs(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSession(userSessionId);
            //noinspection unchecked
            List<EntryStat> opers = ssn.queryForList("operations.get-entries-stat-logs",
                    convertQueryParams(params));

            return opers;
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public List<EntryStat> getEntriesStatsFiles(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSession(userSessionId);
            //noinspection unchecked
            List<EntryStat> opers = ssn.queryForList("operations.get-entries-stat-files",
                    convertQueryParams(params));

            return opers;
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


	public void modifyOperationsStatus(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.change-operations-status", params);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void matchOperations(Long userSessionId, Long presentmentOperId, Long originalOperId) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("presOperId", presentmentOperId);
			map.put("origOperId", originalOperId);
			ssn.update("operations.match-operations", map);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getParticipantCardNumber(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			return (String) ssn.queryForObject("operations.get-participant-card-number",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void matchOperationForReversal(Long userSessionId, Long reversalId, Long originalOperId) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("reversalId", reversalId);
			map.put("origOperId", originalOperId);
			ssn.update("operations.match-reversal-operation", map);
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Participant performChecks(Long userSessionId, Participant participant, String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PARTICIPANT, null);
			ssn.update("operations.perform-checks", participant);

			return participant;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Participant updateParticipant(Long userSessionId, Participant participant) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PARTICIPANT, null);
			ssn.update("operations.update-participant", participant);

			return participant;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifySttlType(Long userSessionId, Operation operation) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, null);
			ssn.update("operations.modify-sttl-type", operation);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getSttlType(Long userSessionId, Map<String,Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPERATION, null);
			ssn.queryForObject("operations.get-sttl-type", params);
			return (String) params.get("sttl_type");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}



	@SuppressWarnings("unchecked")
	public List<Operation> getOperationAccCursor(Long userSessionId, SelectionParams params,
											 Map<String, Object> paramMap, String privName) {
		SqlMapSession ssn = null;
		try{
			if (privName == null) {
				privName = OperationPrivConstants.VIEW_OPERATION;
			}
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, privName, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					privName);
			List<Filter> filters = new ArrayList<Filter>
					(Arrays.asList((Filter[])paramMap.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			paramMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
			QueryParams qparams = convertQueryParams(params);
			paramMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramMap.put("last_row", qparams.getRange().getEndPlusOne());
			paramMap.put("sorting_tab", params.getSortElement());
			ssn.update("operations.get-oper-acc-cur", paramMap);
			return (List<Operation>)paramMap.get("ref_cur");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getOperationAccCursorCount(Long userSessionId,
											  Map<String, Object> params, String privName) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			if (privName == null) {
				privName = OperationPrivConstants.VIEW_OPERATION;
			}
			String limitation = CommonController.getLimitationByPriv(ssn,
					privName);
			List<Filter> filters = new ArrayList<Filter>
					(Arrays.asList((Filter[])params.get("param_tab")));
			filters.add(new Filter("PRIVIL_LIMITATION", limitation));
			params.put("param_tab", filters.toArray(new Filter[filters.size()]));
			ssn.update("operations.get-oper-acc-cur-count", params);
			result = (Integer)params.get("row_count");
		}catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public void feeGenerate(Long userSessionId, String proc, Map map) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations." + proc, map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcStage[] getProcStages(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PROCESS_STAGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_PROCESS_STAGE);
			List<ProcStage> procStages = ssn.queryForList("operations.get-proc-stages",
					convertQueryParams(params, limitation));
			return procStages.toArray(new ProcStage[procStages.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getProcStagesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_PROCESS_STAGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					OperationPrivConstants.VIEW_PROCESS_STAGE);
			return (Integer) ssn.queryForObject("operations.get-proc-stages-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcStage addProcStage(Long userSessionId, ProcStage procStage, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(procStage.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_PROCESS_STAGE, paramArr);

			ssn.insert("operations.add-proc-stage", procStage);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(procStage.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcStage) ssn.queryForObject("operations.get-proc-stages",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcStage modifyProcStage(Long userSessionId, ProcStage procStage, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(procStage.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.MODIFY_PROCESS_STAGE, paramArr);

			ssn.insert("operations.modify-proc-stage", procStage);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(procStage.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcStage) ssn.queryForObject("operations.get-proc-stages",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcStage(Long userSessionId, ProcStage procStage) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(procStage.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.REMOVE_PROCESS_STAGE, paramArr);
			ssn.delete("operations.remove-proc-stage", procStage);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setOperStage(Long userSessionId, String user, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			ssn = getIbatisSession(userSessionId, user, OperationPrivConstants.ADD_PROCESS_STAGE, paramArr);
			ssn.insert("operations.set-oper-stage", params);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long registerSession(String userWS, String privName) throws UserException {
		try {
			return getUserSessionId(userWS, privName, null, null);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		}
	}


	public void unholdOperation(Long userSessionId, final Long operId, final String unholdReason) {
		final Map<String, Object> params = new HashMap<String, Object>();
		params.put("operId", operId);
		params.put("unholdReason", unholdReason);
		executeWithSession(userSessionId, null, AuditParamUtil.getCommonParamRec(params), logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.insert("operations.unhold-operation", params);
				return null;
			}
		});
	}


	public void addParticipant(Long userSessionId, ru.bpc.sv2.operations.incoming.Operation operation) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(operation.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.ADD_ADJUSTMENT, paramArr);
			ssn.update("operations.add-participant", operation);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Stage[] getOperationStages(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPER_STAGES, paramArr);
			List<Stage> items = ssn.queryForList("operations.get-oper-stages", convertQueryParams(
					params));
			return items.toArray(new Stage[items.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getOperationStagesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, OperationPrivConstants.VIEW_OPER_STAGES, paramArr);
			int count = (Integer) ssn.queryForObject("operations.get-oper-stages-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public OperationUnpaidDebt[] getUnpaidDebtOperations(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.get-unpaid-debt-operations", params);
			List<OperationUnpaidDebt> operations = (ArrayList<OperationUnpaidDebt>) params.get("ref_cur");
			return operations.toArray(new OperationUnpaidDebt[operations.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getUnpaidDebtOperationsCount(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.get-unpaid-debt-operations-count", params);
			return (Integer) params.get("count");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Boolean checkAgingDebts(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.check-mad-aging-indebtedness", params);
			return (Boolean) params.get("result");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void performRepaymentDebtOperation(Long userSessionId, OperationUnpaidDebt operation) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.perform-repayment-debt-operation", operation);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void processPendingOperation(Long userSessionId, final Map<String, Object> params) {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return ssn.update("operations.process-pending-opr", params);
			}
		});
	}


    public void setForcedProcessingFlag(Long userSessionId, final Map<String, Object> params) {
        executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                return ssn.update("operations.set-forced-processing-flag", params);
            }
        });
    }


	public boolean isOperationExists(Long userSessionId, final Map<String, Object> params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("operations.is-operation-exists", params);
				return (Boolean) params.get("exist");
			}
		});
	}


	public Long recreateOperation(Long userSessionId, final Map<String, Object> params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Long>() {
			@Override
			public Long doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("operations.recreate-operation", params);
				return (Long) params.get("result_id");
			}
		});
	}


	public Integer getAttrValueNumber(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.get-attr-value-number", params);
			return (Integer) params.get("result");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Double getFeeAmount(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("operations.get-fee-amount", params);
			return (Double) params.get("result");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


    public Double getReversalsAmount(Long userSessionId, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSession(userSessionId);
            ssn.update("operations.get-reversals-amount", params);
            return (Double) params.get("result");
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

	@SuppressWarnings("unchecked")
	public List<Participant> getParticipantsByOperId(Long userSessionId, final Long operId) {
		return executeWithSession(userSessionId,
								  OperationPrivConstants.VIEW_PARTICIPANT,
								  logger,
								  new IbatisSessionCallback<List<Participant>>() {
			@Override
			public List<Participant> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("integ.get-participants-by-operation", operId);
			}
		});
	}

	public void addAupTags(SqlMapSession ssn, List<AupTag> tags, Long authId) throws SQLException {
		if (tags == null || tags.isEmpty()) {
			return;
		}
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("auth_id", authId);
		params.put("tags", tags);

		ssn.update("operations.add-aup-tags", params);
	}

	public void addAupTags(Long userSessionId, List<AupTag> tags, Long authId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);

			addAupTags(ssn, tags, authId);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void addAuthData(SqlMapSession ssn, List<AuthData> data) throws SQLException {
		if (data == null) {
			logger.warn("Auth data is null");
			return;
		}

		Map<String, Object> params = new HashMap<String, Object>();
		params.put("data", data);

		ssn.update("operations.add-auth-data", params);

		for (AuthData authData: data) {
			if (authData.getAupTags() != null) {
				addAupTags(ssn, authData.getAupTags(), authData.getOperId());
			}
		}
	}

	public void addAuthData(Long userSessionId, List<AuthData> tags) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);

			addAuthData(ssn, tags);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public String getCardNumber(Long userSessionId, final Long operationId) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<String>() {
			@Override
			public String doInSession(SqlMapSession ssn) throws Exception {
				return (String) ssn.queryForObject("operations.get-card-number", operationId);
			}
		});
	}
}

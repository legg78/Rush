package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.*;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.dsp.CaseNetworkContext;
import ru.bpc.sv2.logic.utility.db.DataAccessException;


import com.ibatis.sqlmap.client.SqlMapSession;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.*;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.dsp.DisputeActionPermissions;
import ru.bpc.sv2.dsp.DisputeListCondition;
import ru.bpc.sv2.dsp.DisputeParameter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;


public class DisputesDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	@SuppressWarnings("unchecked")
	public List<DisputeListCondition> getDisputesList(Long userSessionId, Map<String, Object> params)
			throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("dsp.get-dispute-list", params);

			List<DisputeListCondition> result = (List<DisputeListCondition>) params.get("disputesList");

			if (result == null) {
				result = Collections.EMPTY_LIST;
			}
			return result;
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<DisputeParameter> prepareDispute(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("dsp.prepare-dispute", params);

			List<DisputeParameter> result = (List<DisputeParameter>) params.get("disputeParams");

			if (result == null) {
				result = Collections.EMPTY_LIST;
			}
			return result;
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public void execDispute(Long userSessionId, final Map<String, Object> params) throws UserException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				if (!params.containsKey("isEdit") || params.get("isEdit") == null) {
					params.remove("isEdit");
					params.put("isEdit", false);
				}
				ssn.update("dsp.exec-dispute", params);
				return null;
			}
		});
	}


	public boolean checkDuplicatedMessage(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		boolean result = false;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("dsp.check-duplicated-message", params);
			Object obj = params.get("result");
			result = (obj != null && obj.toString().equals("1")) ? true : false;
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
		return result;
	}

	public Long createCaseDisputeByOperation(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("dsp.create-disp-appl-by-oper", params);
			return (Long)params.get("applId");
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	public DspApplication getDefaultManualApplication(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		try {
			DspApplication dspApplication = new DspApplication();
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("dsp.get-default-manual-application", dspApplication);

			return dspApplication;
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	public List<Operation> getDisputeUnpairedOperations(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<Operation> operations = ssn.queryForList("dsp.get-unpaired-operation-list");
			return operations;
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public ManualCaseCreation createManualApplication(Long userSessionId, final ManualCaseCreation in) throws UserException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<ManualCaseCreation>() {
			@Override
			public ManualCaseCreation doInSession(SqlMapSession ssn) throws Exception {
				ManualCaseCreation application = in.clone();
				ssn.update("dsp.create-manual-application", application);
				return application;
			}
		});
	}


	public ManualCaseCreation modifyCase(Long userSessionId, final ManualCaseCreation in) throws UserException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<ManualCaseCreation>() {
			@Override
			public ManualCaseCreation doInSession(SqlMapSession ssn) throws Exception {
				ManualCaseCreation application = in.clone();
				ssn.update("dsp.modify-case", application);
				return application;
			}
		});
	}


	public void removeClaim(Long userSessionId, final DspApplication claim) throws UserException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.remove-claim", claim);
				return null;
			}
		});
	}

	public Integer getChargebackLovId(Long userSessionId, Long applId) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("applId", applId);
			ssn.update("dsp.get-chargeback-lov-id", map);
			return (Integer) map.get("lovId");
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public String getAticleText(Long userSessionId, String articleCode) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("articleCode", articleCode);
			ssn.update("dsp.get-article-text-by-code", map);
			return (String) map.get("textCode");
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public List<ApplicationComment> getCommentsByApplication(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("applicationId", params.get("applicationId"));
			map.put("lang", params.get("lang"));
			return ssn.queryForList("dsp.get-comments-by-case", map);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public void modifyApplStatusAndResolution(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("applId", params.get("applId"));
			map.put("seqNum", params.get("seqNum"));
			map.put("reasonCode", params.get("reasonCode"));
			map.put("userId", params.get("userId"));
			ssn.update("dsp.modify-appl-by-reason", map);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	public void createUnpairedCaseApplication(Long userSessionId, Map<String, Object> params) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("dsp.create-disp-appl-unpaired", params);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	public Boolean isCardBelongsToVisaOrMC(Long userSessionId, Long disputeId)  throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("disputeId", disputeId);
			ssn.queryForObject("dsp.get-is-visa-or-mastercard", map);
			return (Boolean)map.get("result");
		} catch (Exception e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getStopListTypeLovId(Long userSessionId, Long disputeId) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("disputeId", disputeId);
			ssn.queryForObject("dsp.get-lov-id", map);
			return (Integer)map.get("result");
		} catch (Exception e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void putCardToStopList(Long userSessionId, final Map<String, Object> params) throws DataAccessException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.send-card-to-stop-list", params);
				return null;
			}
		});
	}


	public Long getCardInstanceIdByMask(Long userSessionId, String cardMask) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("cardMask", cardMask);
			return (Long)ssn.queryForObject("dsp.get-card-instance-id", params);
		} catch (Exception e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getStopListCount(Long userSessionId, SelectionParams params) throws DataAccessException {
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] rec = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DspAppPrivileges.VIEW_STOP_LIST_MESSAGES, rec);
			String limit = CommonController.getLimitationByPriv(ssn, DspAppPrivileges.VIEW_STOP_LIST_MESSAGES);
			return (Integer) ssn.queryForObject("dsp.get-stop-list-count", convertQueryParams(params, limit));
		}catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StopList[] getStopList(Long userSessionId, SelectionParams params) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] rec = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, DspAppPrivileges.VIEW_STOP_LIST_MESSAGES, rec);
			String limit = CommonController.getLimitationByPriv(ssn, DspAppPrivileges.VIEW_STOP_LIST_MESSAGES);
			List<StopList>list = ssn.queryForList("dsp.get-stop-list", convertQueryParams(params, limit));
			return list.toArray(new StopList[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public DisputeActionPermissions getActionPermissions(Long userSessionId, final Long caseId) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DisputeActionPermissions>() {
			@Override
			public DisputeActionPermissions doInSession(SqlMapSession ssn) throws Exception {
				DisputeActionPermissions object = new DisputeActionPermissions(caseId);
				ssn.queryForObject("dsp.check-available-actions", object);
				return object;
			}
		});
	}


	public int getDueDateLov(Long userSessionId, final Long caseId, final Integer flowId) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(2);
				map.put("caseId", caseId);
				map.put("flowId", flowId);
				ssn.queryForObject("dsp.get-due-date-lov", map);
				return (map.get("lovId") != null) ? (Integer)map.get("lovId") : 0;
			}
		});
	}


	public int setApplicationTeam(Long userSessionId, final DspApplication application) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.set-appl-team", application);
				return application.getSeqNum();
			}
		});
	}


	public Integer getProgressLovId(Long userSessionId, final DspApplication application) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(3);
				map.put("caseId", application.getId());
				map.put("flowId", application.getFlowId() != null ? application.getFlowId().longValue() : null);
				ssn.update("dsp.get-progress-lov-id", map);
				return (map.get("lovId") != null) ? (Integer)map.get("lovId") : null;
			}
		});
	}


	public Integer getReasonLovId(Long userSessionId, final DspApplication application) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(3);
				map.put("caseId", application.getId());
				map.put("caseProgress", application.getCaseProgress());
				ssn.update("dsp.get-reason-lov-id", map);
				return (map.get("lovId") != null) ? (Integer)map.get("lovId") : null;
			}
		});
	}


	public int changeCaseProgress(Long userSessionId, final DspApplication application) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.change-case-progress", application);
				return application.getSeqNum();
			}
		});
	}


	public void changeCaseStatus(Long userSessionId, final DspApplication application) throws DataAccessException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.change-case-status", application);
				return null;
			}
		});
	}


	public void setHideUnhideDate(Long userSessionId, final DspApplication application) throws DataAccessException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.set-hide-unhide-date", application);
				return null;
			}
		});
	}


	public void changeCaseVisibility(Long userSessionId, final DspApplication application) throws DataAccessException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.change-case-visibility", application);
				return null;
			}
		});
	}


	public ManualCaseCreation getManualCaseInfo(Long userSessionId, Long caseId) throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("caseId", caseId);
			ssn.update("dsp.get-manual-case-info", map);
			return ((List<ManualCaseCreation>)map.get("result")).get(0);
		} catch (Exception e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public StopList getStopListData(Long userSessionId, final Long cardInstanceId) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<StopList>() {
			@Override
			public StopList doInSession(SqlMapSession ssn) throws Exception {
				StopList out = new StopList();
				out.setCardInstanceId(cardInstanceId);
				ssn.update("dsp.get-stop-list-data", out);
				return out;
			}
		});
	}


	public boolean isItemEditable(Long userSessionId, final Long id) throws UserException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(2);
				map.put("id", id);
				ssn.update("dsp.check-editable-removable", map);
				return (map.get("result") != null) ? ((Integer)map.get("result") != 0) : false;
			}
		});
	}


	public void removeItem(Long userSessionId, final Long id) throws UserException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.remove-dispute", id);
				return null;
			}
		});
	}


	public Map<String, Object> getDisputeRule(Long userSessionId, final Long id) throws UserException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Map<String, Object>>() {
			@Override
			public Map<String, Object> doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> rules = new HashMap<String, Object>(3);
				rules.put("id", id);
				ssn.update("dsp.get-dispute-rule", rules);
				return rules;
			}
		});
	}


	public int getDisputeInstId(Long userSessionId, final Long operId) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(2);
				map.put("operId", operId);
				ssn.update("dsp.get-dispute-inst-id", map);
				return (Integer)map.get("result");
			}
		});
	}

	public void closeCase(Long userSessionId, final DspApplication application) throws DataAccessException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.close-case", application);
				return null;
			}
		});
	}

	public void reopenCase(Long userSessionId, final DspApplication application) throws DataAccessException {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("dsp.reopen-case", application);
				return null;
			}
		});
	}

	public Boolean isPutStopListEnabled(Long userSessionId, final Long disputeId)  throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("disputeId", disputeId);
				ssn.queryForObject("dsp.get-is-put-stop-list-enabled", map);
				return (Boolean)map.get("result");
			}
		});
	}

	public Boolean isDocExportImportEnabled(Long userSessionId, final Long id)  throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("id", id);
				ssn.queryForObject("dsp.get-is-doc-export-import-enabled", map);
				return (Boolean)map.get("result");
			}
		});
	}

	public Boolean isCardInStopList(Long userSessionId, final Map<String, Object> params) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				return (Boolean)ssn.queryForObject("dsp.is-card-in-stop-list", params);
			}
		});
	}

	private void updateNetworkContext(SqlMapSession ssn, CaseNetworkContext context) throws Exception {
		if (context.getOperId() != null) {
			ssn.update("dsp.get-network-by-oper-id", context);
		} else if (StringUtils.isNotBlank(context.getCardNumber())) {
			ssn.update("dsp.get-network-by-card-number", context);
		} else {
			throw new Exception("Unable get network. Can't find expected operation id or card number");
		}
	}
	public void getCaseNetwork(Long userSessionId, final CaseNetworkContext context) {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				updateNetworkContext(ssn, context);
				return null;
			}
		});
	}

	public Boolean isMasterComEnabled(Long userSessionId, final CaseNetworkContext context) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				if (context.getNetworkId() == null || context.getInstId() == null) {
					updateNetworkContext(ssn, context);
				}
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("instId", context.getInstId());
				map.put("networkId", context.getNetworkId());
				ssn.update("dsp.is-mastercom-enabled", map);
				return Boolean.TRUE.equals(map.get("result"));
			}
		});
	}
}

package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.reconciliation.*;
import ru.bpc.sv2.utils.AuditParamUtil;


import java.util.ArrayList;
import java.util.List;
import java.util.Map;


public class ReconciliationDao extends IbatisAware {
    private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

    private int getCount(Long sessionId, final SelectionParams params, final String request, final String privilege) {
        return executeWithSession(sessionId,
                                  privilege,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, privilege);
                Object count = ssn.queryForObject("rcn." + request, convertQueryParams(params, limitation));
                return (count != null) ? (Integer)count : 0;
            }
        });
    }

    private List getList(Long sessionId, final SelectionParams params, final String request, final String privilege) {
        return executeWithSession(sessionId,
                                  privilege,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<List>() {
	        @Override
            public List doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, privilege);
                return ssn.queryForList("rcn." + request, convertQueryParams(params, limitation));
            }
        });
    }

    private Object execute(final Long sessionId, final IAuditableObject object, final String request, final String privilege) {
        return executeWithSession(sessionId,
                                  privilege,
                                  AuditParamUtil.getCommonParamRec(object.getAuditParameters()),
                                  logger,
                                  new IbatisSessionCallback<Object>() {
	        @Override
            public Object doInSession(SqlMapSession ssn) throws Exception {
                ssn.update("rcn." + request, object);
                List out = getList(sessionId, createSelectionParams(object), getRequest(object), privilege);
                return (out != null && out.size() > 0) ? out.get(0) : null;
            }
        });
    }

    private String getRequest(Object object) {
        if (object instanceof RcnCondition) {
            return "get-conditions";
        } else if (object instanceof RcnMessage) {
            return "get-messages";
        } else if (object instanceof RcnParameter) {
            return "get-parameters";
        }
        return null;
    }

    private SelectionParams createSelectionParams(Object object) {
        List<Filter> filters = new ArrayList<Filter>(2);
        SelectionParams params = new SelectionParams();
        if (object instanceof RcnCondition) {
            filters.add(Filter.create("id", ((RcnCondition) object).getId()));
            filters.add(Filter.create("lang", ((RcnCondition) object).getLang()));
            params.setModule(((RcnCondition) object).getModule());
        } else if (object instanceof RcnMessage) {
            filters.add(Filter.create("id", ((RcnMessage) object).getId()));
            filters.add(Filter.create("lang", ((RcnMessage) object).getLang()));
            params.setModule(((RcnMessage) object).getModule());
        } else if (object instanceof RcnParameter) {
            filters.add(Filter.create("id", ((RcnParameter) object).getId()));
            filters.add(Filter.create("lang", ((RcnParameter) object).getLang()));
            params.setModule(((RcnParameter) object).getModule());
        }
        params.setFilters(filters);
        return params;
    }


    public List<RcnCondition> getConditions(Long userSessionId, SelectionParams params) {
        switch (params.getModule()) {
            case RcnConstants.MODULE_CBS:
                return getList(userSessionId, params, "get-conditions", RcnConstants.VIEW_CBS_CONDITIONS);
            case RcnConstants.MODULE_ATM:
                return getList(userSessionId, params, "get-conditions", RcnConstants.VIEW_ATM_CONDITIONS);
            case RcnConstants.MODULE_HOST:
                return getList(userSessionId, params, "get-conditions", RcnConstants.VIEW_HOST_CONDITIONS);
            case RcnConstants.MODULE_SP:
                return getList(userSessionId, params, "get-conditions", RcnConstants.VIEW_SP_CONDITIONS);
        }
        return null;
    }

    public int getConditionsCount(Long userSessionId, SelectionParams params) {
        switch (params.getModule()) {
            case RcnConstants.MODULE_CBS:
                return getCount(userSessionId, params, "get-conditions-count", RcnConstants.VIEW_CBS_CONDITIONS);
            case RcnConstants.MODULE_ATM:
                return getCount(userSessionId, params, "get-conditions-count", RcnConstants.VIEW_ATM_CONDITIONS);
            case RcnConstants.MODULE_HOST:
                return getCount(userSessionId, params, "get-conditions-count", RcnConstants.VIEW_HOST_CONDITIONS);
            case RcnConstants.MODULE_SP:
                return getCount(userSessionId, params, "get-conditions-count", RcnConstants.VIEW_SP_CONDITIONS);
        }
        return 0;
    }


    public RcnCondition addCondition(Long userSessionId, RcnCondition condition) {
        switch (condition.getModule()) {
            case RcnConstants.MODULE_CBS:
                return (RcnCondition) execute(userSessionId, condition, "add-condition", RcnConstants.ADD_CBS_CONDITIONS);
            case RcnConstants.MODULE_ATM:
                return (RcnCondition) execute(userSessionId, condition, "add-condition", RcnConstants.ADD_ATM_CONDITIONS);
            case RcnConstants.MODULE_HOST:
                return (RcnCondition) execute(userSessionId, condition, "add-condition", RcnConstants.ADD_HOST_CONDITIONS);
            case RcnConstants.MODULE_SP:
                return (RcnCondition) execute(userSessionId, condition, "add-condition", RcnConstants.ADD_SP_CONDITIONS);
        }
        return null;
    }

    public RcnCondition modifyCondition(Long userSessionId, RcnCondition condition) {
        switch (condition.getModule()) {
            case RcnConstants.MODULE_CBS:
                return (RcnCondition) execute(userSessionId, condition, "modify-condition", RcnConstants.MODIFY_CBS_CONDITIONS);
            case RcnConstants.MODULE_ATM:
                return (RcnCondition) execute(userSessionId, condition, "modify-condition", RcnConstants.MODIFY_ATM_CONDITIONS);
            case RcnConstants.MODULE_HOST:
                return (RcnCondition) execute(userSessionId, condition, "modify-condition", RcnConstants.MODIFY_HOST_CONDITIONS);
            case RcnConstants.MODULE_SP:
                return (RcnCondition) execute(userSessionId, condition, "modify-condition", RcnConstants.MODIFY_SP_CONDITIONS);
        }
        return null;
    }

    public void removeCondition(Long userSessionId, RcnCondition condition) {
        switch (condition.getModule()) {
            case RcnConstants.MODULE_CBS:
                execute(userSessionId, condition, "remove-condition", RcnConstants.REMOVE_CBS_CONDITIONS);
            case RcnConstants.MODULE_ATM:
                execute(userSessionId, condition, "remove-condition", RcnConstants.REMOVE_ATM_CONDITIONS);
            case RcnConstants.MODULE_HOST:
                execute(userSessionId, condition, "remove-condition", RcnConstants.REMOVE_HOST_CONDITIONS);
            case RcnConstants.MODULE_SP:
                execute(userSessionId, condition, "remove-condition", RcnConstants.REMOVE_SP_CONDITIONS);
        }
    }


    public List<RcnMessage> getMessages(Long userSessionId, SelectionParams params) {
    	if (params.getModule() != null) {
		    switch (params.getModule()) {
			    case RcnConstants.MODULE_CBS:
				    return getList(userSessionId, params, "get-messages", RcnConstants.VIEW_CBS_MESSAGES);
			    case RcnConstants.MODULE_ATM:
				    return getList(userSessionId, params, "get-messages", RcnConstants.VIEW_ATM_MESSAGES);
			    case RcnConstants.MODULE_HOST:
				    return getList(userSessionId, params, "get-messages", RcnConstants.VIEW_HOST_MESSAGES);
			    case RcnConstants.MODULE_SP:
				    return getList(userSessionId, params, "get-messages", RcnConstants.VIEW_SP_MESSAGES);
		    }
	    } else {
		    return getList(userSessionId, params, "get-messages", null);
	    }

        return null;
    }

    public int getMessagesCount(Long userSessionId, SelectionParams params) {
        switch (params.getModule()) {
            case RcnConstants.MODULE_CBS:
                return getCount(userSessionId, params, "get-messages-count", RcnConstants.VIEW_CBS_MESSAGES);
            case RcnConstants.MODULE_ATM:
                return getCount(userSessionId, params, "get-messages-count", RcnConstants.VIEW_ATM_MESSAGES);
            case RcnConstants.MODULE_HOST:
                return getCount(userSessionId, params, "get-messages-count", RcnConstants.VIEW_HOST_MESSAGES);
            case RcnConstants.MODULE_SP:
                return getCount(userSessionId, params, "get-messages-count", RcnConstants.VIEW_SP_MESSAGES);
        }
        return 0;
    }


    public RcnMessage addMessage(Long userSessionId, RcnMessage message) {
        switch (message.getModule()) {
            case RcnConstants.MODULE_CBS:
                return (RcnMessage) execute(userSessionId, message, "add-message", RcnConstants.ADD_CBS_MESSAGES);
            case RcnConstants.MODULE_ATM:
                return (RcnMessage) execute(userSessionId, message, "add-message", RcnConstants.ADD_ATM_MESSAGES);
            case RcnConstants.MODULE_HOST:
                return (RcnMessage) execute(userSessionId, message, "add-message", RcnConstants.ADD_HOST_MESSAGES);
            case RcnConstants.MODULE_SP:
                return (RcnMessage) execute(userSessionId, message, "add-message", RcnConstants.ADD_SP_MESSAGES);
        }
        return null;
    }

    public RcnMessage modifyMessage(Long userSessionId, RcnMessage message) {
        switch (message.getModule()) {
            case RcnConstants.MODULE_CBS:
                return (RcnMessage) execute(userSessionId, message, "modify-message", RcnConstants.MODIFY_CBS_MESSAGES);
            case RcnConstants.MODULE_ATM:
                return (RcnMessage) execute(userSessionId, message, "modify-message", RcnConstants.MODIFY_ATM_MESSAGES);
            case RcnConstants.MODULE_HOST:
                return (RcnMessage) execute(userSessionId, message, "modify-message", RcnConstants.MODIFY_HOST_MESSAGES);
            case RcnConstants.MODULE_SP:
                return (RcnMessage) execute(userSessionId, message, "modify-message", RcnConstants.MODIFY_SP_MESSAGES);
        }
        return null;
    }

    public void removeMessage(Long userSessionId, RcnMessage message) {
        switch (message.getModule()) {
            case RcnConstants.MODULE_CBS:
                execute(userSessionId, message, "remove-message", RcnConstants.REMOVE_CBS_MESSAGES);
            case RcnConstants.MODULE_ATM:
                execute(userSessionId, message, "remove-message", RcnConstants.REMOVE_ATM_MESSAGES);
            case RcnConstants.MODULE_HOST:
                execute(userSessionId, message, "remove-message", RcnConstants.REMOVE_HOST_MESSAGES);
            case RcnConstants.MODULE_SP:
                execute(userSessionId, message, "remove-message", RcnConstants.REMOVE_SP_MESSAGES);
        }
    }


    public List<RcnParameter> getParameters(Long userSessionId, SelectionParams params) {
        switch (params.getModule()) {
            case RcnConstants.MODULE_SP:
                return getList(userSessionId, params, "get-parameters", RcnConstants.VIEW_SP_PARAMETERS);
        }
        return null;
    }

    public int getParametersCount(Long userSessionId, SelectionParams params) {
        switch (params.getModule()) {
            case RcnConstants.MODULE_SP:
                return getCount(userSessionId, params, "get-parameters-count", RcnConstants.VIEW_SP_PARAMETERS);
        }
        return 0;
    }


    public RcnParameter addParameter(Long userSessionId, RcnParameter parameter) {
        switch (parameter.getModule()) {
            case RcnConstants.MODULE_SP:
                return (RcnParameter) execute(userSessionId, parameter, "add-parameter", RcnConstants.ADD_SP_PARAMETERS);
        }
        return null;
    }

    public RcnParameter modifyParameter(Long userSessionId, RcnParameter parameter) {
        switch (parameter.getModule()) {
            case RcnConstants.MODULE_SP:
                return (RcnParameter) execute(userSessionId, parameter, "modify-parameter", RcnConstants.MODIFY_SP_PARAMETERS);
        }
        return null;
    }

    public void removeParameter(Long userSessionId, RcnParameter parameter) {
        switch (parameter.getModule()) {
            case RcnConstants.MODULE_SP:
                execute(userSessionId, parameter, "remove-parameter", RcnConstants.REMOVE_SP_PARAMETERS);
        }
    }


    public List<RcnParameter> getMessageParameters(Long userSessionId, SelectionParams params) {
        return getList(userSessionId, params, "get-message-parameters", RcnConstants.VIEW_SP_PARAMETERS);
    }

	public RcnMessage modifyStatus(Long userSessionId, RcnMessage message) {
		switch (message.getModule()) {
			case RcnConstants.MODULE_HOST:
				return (RcnMessage) execute(userSessionId, message, "modify-status", RcnConstants.VIEW_HOST_MESSAGES);
		}
		return null;
	}
}

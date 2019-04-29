package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeOperationsStatusDS")
public class MbChangeOperationsStatusDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbChangeOperationsStatusDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/changeOperationsStatusDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String SESSION_ID = "SESSION_ID";
    private static final String SESSION_FILE_ID = "SESSION_FILE_ID";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String OPER_TYPE = "OPER_TYPE";
    private static final String MSG_TYPE = "MSG_TYPE";
    private static final String STTL_TYPE = "STTL_TYPE";
    private static final String OPER_CURRENCY = "OPER_CURRENCY";
    private static final String REVERSAL = "REVERSAL";

    private OperationDao operationDao = new OperationDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private String entityType;
    private Long objectId;
    private transient DictUtils dictUtils;
    private List<SelectItem> statuses = null;
    private List<SelectItem> operTypes = null;
    private List<SelectItem> msgTypes = null;
    private List<SelectItem> sttlTypes = null;
    private List<SelectItem> currencies = null;
    private List<SelectItem> yesNoList = null;
    private List<SelectItem> operReasons;

    private String msgType;
    private String operType;
    private String status;
    private String sttlType;
    private String operCurrency;
    private Boolean reversal;
    private Long sessionId;
    private Long sessionFileId;
    private String operReason;
    private String newStatus;
    private Integer instId;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        reset();

        classLogger.trace("init...");

        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (EntityNames.SESSION.equals(entityType)) {
            sessionId = (Long) context.get(OBJECT_ID);
        } else if (EntityNames.SESSION_FILE.equals(entityType)) {
            sessionFileId = (Long) context.get(OBJECT_ID);
        }
        sessionId = (Long) context.get(SESSION_ID);
        sessionFileId = (Long) context.get(SESSION_FILE_ID);

        msgType = (String) context.get(MSG_TYPE);
        instId = (Integer) context.get(MbOperTypeSelectionStep.INST_ID);

        String newOperType = (String) context.get(MbCommonWizard.OPER_TYPE);
        if (operType == null || newOperType == null || !operType.equals(newOperType)) {
            operReasons = null;
        }
        operType = newOperType;

        sttlType = (String) context.get(STTL_TYPE);
        status = (String) context.get(WizardConstants.OPER_STATUS);
        operCurrency = (String) context.get(OPER_CURRENCY);
        reversal = (Boolean) context.get(REVERSAL);
        objectId = (Long) context.get(OBJECT_ID);
        newStatus = status;
    }

    private void reset() {
        msgType = null;
        operType = null;
        sttlType = null;
        status = null;
        reversal = null;
        operCurrency = null;
        sessionId = null;
        sessionFileId = null;
        objectId = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            getContext().put(WizardConstants.OPER_STATUS, changeStatus());
        }
        return getContext();
    }

    private String changeStatus() {
        classLogger.trace("changeStatus...");

        if (isMaker()) {
            Operation oper = new Operation();
            oper.setId(objectId);
            oper.setOperType(operType);
            oper.setMsgType(msgType);
            oper.setSttlType(sttlType);
            oper.setStatus(status);
            oper.setIsReversal(reversal);
            oper.setOperCurrency(operCurrency);
            oper.setSessionId(sessionId);
            oper.setOperReason(operReason);
            oper.setSessionFileId(sessionFileId);
            oper.setNewOperStatus(newStatus);

            Integer instId =((UserSession) ManagedBeanWrapper.getManagedBean("usession")).getUserInst();
            if (instId == null) instId = this.instId;
            if (instId == null) instId = SystemConstants.DEFAULT_INSTITUTION;

            ApplicationBuilder builder = new ApplicationBuilder(
                    applicationDao,
                    userSessionId,
                    instId,
                    getFlowId()
            );

            builder.buildFromOperation(oper, false);
            builder.createApplicationInDB();
            builder.addApplicationObject(objectId, entityType);
            return builder.getApplication().getStatus();
        } else {
            Map<String, Object> params = new HashMap<String, Object>();
            if (operType != null) {
                params.put("operType", operType);
            }
            if (msgType != null) {
                params.put("msgType", msgType);
            }
            if (sttlType != null) {
                params.put("sttlType", sttlType);
            }
            if (status != null) {
                params.put("operStatus", status);
            }
            if (reversal != null) {
                params.put("reversal", reversal ? 1 : 0);
            }
            if (operCurrency != null) {
                params.put("operCurrency", operCurrency);
            }
            if (objectId != null) {
                params.put("operId", objectId);
            }
            if (sessionId != null) {
                params.put("sessionId", sessionId);
            }
            if (sessionFileId != null) {
                params.put("sessionFileId", sessionFileId);
            }
            if (newStatus != null) {
                params.put("newStatus", newStatus);
            }

            if (operReason != null) {
                params.put("operReason", operReason);
            }
            operationDao.modifyOperationsStatus(userSessionId, params);
            return newStatus;
        }
    }

    private Operation getOperationById(Long id) {
        classLogger.trace("accountById...");
        Operation result = null;
        SelectionParams sp = SelectionParams.build("id", id);
        List<Operation> opers = operationDao.getOperations(userSessionId, sp, curLang);
        if (opers.size() != 0) {
            result = opers.get(0);
        }
        return result;
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        this.newStatus = newStatus;
    }

    public Long getObjectId() {
        return objectId;
    }

    public void setObjectId(Long objectId) {
        this.objectId = objectId;
    }

    public String getMsgType() {
        return msgType;
    }

    public void setMsgType(String msgType) {
        this.msgType = msgType;
    }

    public String getOperType() {
        return operType;
    }

    public void setOperType(String operType) {
        this.operType = operType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getSttlType() {
        return sttlType;
    }

    public void setSttlType(String sttlType) {
        this.sttlType = sttlType;
    }

    public String getOperCurrency() {
        return operCurrency;
    }

    public void setOperCurrency(String operCurrency) {
        this.operCurrency = operCurrency;
    }

    public Boolean getReversal() {
        return reversal;
    }

    public void setReversal(Boolean reversal) {
        this.reversal = reversal;
    }

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public Long getSessionFileId() {
        return sessionFileId;
    }

    public void setSessionFileId(Long sessionFileId) {
        this.sessionFileId = sessionFileId;
    }

    public List<SelectItem> getStatuses() {
        if (statuses == null) {
            statuses = getDictUtils().getLov(LovConstants.OPERATION_STATUSES);
        }
        return statuses;
    }

    public List<SelectItem> getOperTypes() {
        if (operTypes == null) {
            operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
        }
        return operTypes;
    }

    public List<SelectItem> getMsgTypes() {
        if (msgTypes == null) {
            msgTypes = getDictUtils().getLov(LovConstants.MESSAGE_TYPES);
        }
        return msgTypes;
    }

    public List<SelectItem> getSttlTypes() {
        if (sttlTypes == null) {
            sttlTypes = getDictUtils().getLov(LovConstants.SETTLEMENT_TYPES);
        }
        return sttlTypes;
    }

    public List<SelectItem> getCurrencies() {
        if (currencies == null) {
            currencies = getDictUtils().getLov(LovConstants.CURRENCIES);
        }
        return currencies;
    }

    public List<SelectItem> getYesNoList() {
        if (yesNoList == null) {
            yesNoList = getDictUtils().getLov(LovConstants.YES_NO_LIST);
        }
        return yesNoList;
    }

    public List<SelectItem> getOperReasons() {
        if (operReasons == null) {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("oper_type", operType);
            operReasons = getDictUtils().getLov(LovConstants.OPER_REASON, params);
        }
        return operReasons;
    }

    public String getOperReason() {
        return operReason;
    }

    public void setOperReason(String operReason) {
        this.operReason = operReason;
    }
}

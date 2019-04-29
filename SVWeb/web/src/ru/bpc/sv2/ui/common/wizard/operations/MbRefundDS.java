package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbRefundDS")
public class MbRefundDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbRefundDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/refundDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OPERATION = "OPERATION";
    private static final String SRC_OPERATION = "SRC_OPERATION";

    protected Map<String, Object> context;
    protected long userSessionId;
    private String curLang;

    private Operation operation;
    private ru.bpc.sv2.operations.Operation sourceOperation;

    private String matchingStatus = "MTST0300";
    private String operStatus = "OPST0100";

    private List<SelectItem> matchingStatuses;
    private List<SelectItem> operStatuses;
    private transient DictUtils dictUtils;

    protected OperationDao operationDao = new OperationDao();

    @Override
    public void init(Map<String, Object> context) {
        reset();
        logger.trace("init...");
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");

        if (!((String)context.get(ENTITY_TYPE)).equalsIgnoreCase(EntityNames.OPERATION)) {
            throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "operation_error"));
        }
        if (context.containsKey(OPERATION)) {
            sourceOperation = (ru.bpc.sv2.operations.Operation) context.get(OPERATION);

            initOperation();
        } else {
            throw new IllegalStateException(OPERATION + " is not defined in wizard step context");
        }
    }

    private void reset(){
        context = null;
        operation = null;
        sourceOperation = null;
    }

    private void initOperation() {
        operation = new Operation();

        operation.setOperType("OPTP5002");
        operation.setMsgType(sourceOperation.getMsgType());
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(sourceOperation.getSttlType());
        operation.setOperationAmount(sourceOperation.getOperAmount());
        operation.setOperationCurrency(sourceOperation.getOperationCurrency());
        operation.setOperationDate(sourceOperation.getOperDate());
        operation.setSourceHostDate(sourceOperation.getHostDate());

        operation.setOriginalId(sourceOperation.getId());
        operation.setReversal(false);

        operation.setTerminalId(sourceOperation.getTerminalId());
        operation.setTerminalType(sourceOperation.getTerminalType());
        operation.setTerminalNumber(sourceOperation.getTerminalNumber());

        operation.setAccountCurrency(sourceOperation.getAccountCurrency());
        operation.setSttlCurrency(sourceOperation.getSttlCurrency());

        operation.setOperCount(sourceOperation.getOperCount());
        operation.setSttlAmount(sourceOperation.getSttlAmount());
        operation.setSttlCurrency(sourceOperation.getSttlCurrency());
        operation.setDisputeId(sourceOperation.getDisputeId());
        operation.setCustomerId(sourceOperation.getCustomerId());

        operation.setClientIdType(sourceOperation.getClientIdType());
        operation.setClientIdValue(sourceOperation.getClientIdValue());
    }

    public List<SelectItem> getMatchingStatuses(){
        if (matchingStatuses == null) {
            List<SelectItem> temp = getDictUtils().getLov(LovConstants.MATCHING_STATUSES);
            matchingStatuses = new LinkedList<>();
            for (SelectItem item : temp) {
                if (item.getLabel().equals("MTST0300") || item.getValue().equals("MTST0300")) {
                    matchingStatuses.add(item);
                    break;
                }
            }
            for (SelectItem item : temp) {
                if (!item.getLabel().equals("MTST0300") && !item.getValue().equals("MTST0300")) {
                    matchingStatuses.add(item);
                }
            }
        }
        return matchingStatuses;
    }

    public List<SelectItem> getOperStatuses(){
        if (operStatuses == null) {
            List<SelectItem> temp = getDictUtils().getLov(LovConstants.OPERATION_STATUSES);
            operStatuses = new LinkedList<>();
            for (SelectItem item : temp) {
                if (item.getLabel().equals("OPST0100") || item.getValue().equals("OPST0100")) {
                    operStatuses.add(item);
                    break;
                }
            }
            for (SelectItem item : temp) {
                if (!item.getLabel().equals("OPST0100") && !item.getValue().equals("OPST0100")) {
                    operStatuses.add(item);
                }
            }
        }
        return operStatuses;
    }

    private DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");

        if (direction == Direction.FORWARD) {

            Map<String, Object> params = new HashMap<>();
            params.put("exist", null);
            params.put("i_orig_oper_id", operation.getOriginalId());
            if (operationDao.isOperationExists(userSessionId, params)) {
                throw new IllegalStateException("This operation has been already created for operation " + operation.getOriginalId());
            }

            params = new HashMap<>();
            params.put("result_id", null);
            params.put("i_oper_id", operation.getOriginalId());
            params.put("i_original_id", operation.getOriginalId());
            params.put("i_status", operStatus);
            params.put("i_match_status", matchingStatus);
            Long operationId = operationDao.recreateOperation(userSessionId, params);
            if (operationId == null) {
                throw new IllegalStateException("Could not recreate operation for operation " + operation.getOriginalId());
            } else if (operationId == -1) {
                throw new IllegalStateException(String.format("Operation %s, manual refund, attempt to recreate debit operation.", operation.getOriginalId()));
            }

            operation.setId(operationId);

            operationDao.processOperation(userSessionId, operation.getId());

            params = new HashMap<>();
            params.put("i_exp_period", 36);
            params.put("i_oper_id", operation.getOriginalId());
            operationDao.processPendingOperation(userSessionId, params);

            context.put(SRC_OPERATION, sourceOperation);
            context.put(OPERATION, operation);
        } else {
            operation = null;
            sourceOperation = null;
        }

        return context;
    }

    @Override
    public boolean validate() {
        return true;
    }

    public Operation getOperation() {
        return operation;
    }
    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public String getCurLang() {
        return curLang;
    }
    public void setCurLang(String curLang) {
        this.curLang = curLang;
    }

    public String getMatchingStatus() {
        return matchingStatus;
    }

    public void setMatchingStatus(String matchingStatus) {
        this.matchingStatus = matchingStatus;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }
}

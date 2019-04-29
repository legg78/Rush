package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbMatchOperationDS")
public class MbMatchOperationDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbMatchOperationDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/matchOperationDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String ORIG_MATCH_STATUS = "ORIG_MATCH_STATUS";
    private static final String PRES_MATCH_STATUS = "PRES_MATCH_STATUS";
    private static final String ORIG_OPER_ID = "ORIG_OPER_ID";
    private static final String PRES_OPER_ID = "PRES_OPER_ID";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String OPER_STATUS_READY = "OPST0100";

    private OperationDao operationDao = new OperationDao();

    private ApplicationDao applicationDao = new ApplicationDao();


    private String entityType;
    private Long objectId;
    private Operation operation;
    private transient DictUtils dictUtils;
    private Operation[] operations;
    private SimpleSelection operationSelection;
    private Operation selectedOperation;
    private String message;
    private boolean operationOk;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        reset();
        classLogger.trace("init...");

        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        if (context.containsKey(OBJECT_ID)) {
            objectId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (EntityNames.OPERATION.equals(entityType)) {
            operation = operationById(objectId);
            if (operation.getIsReversal()) {
//				throw new IllegalStateException("Matching cannot be done for reversals");
            } else if (OperationsConstants.MATCH_STATUS_MATCHED.equals(operation.getMatchStatus())) {
                throw new IllegalStateException("Operation is already matched");
            } else if (!OperationsConstants.MESSAGE_TYPE_AUTHORIZATION.equals(operation.getMsgType()) &&
                    !OperationsConstants.MESSAGE_TYPE_PREAUTHORIZATION.equals(operation.getMsgType()) &&
                    !OperationsConstants.MESSAGE_TYPE_COMPLETION.equals(operation.getMsgType()) &&
                    !OperationsConstants.MESSAGE_TYPE_PRESENTMENT.equals(operation.getMsgType())) {
                throw new IllegalStateException("Manual matching is not supported for operations with such message type");
            } else {
                operations = operationsByCardAndMsgType(retriveCardId(objectId), operation);
            }
        }
    }

    private Operation operationById(Long id) {
        classLogger.trace("accountById...");
        Operation result = null;
        SelectionParams sp = SelectionParams.build("id", id);
        List<Operation> opers = operationDao.getOperations(userSessionId, sp, curLang);
        if (opers.size() != 0) {
            result = opers.get(0);
        }
        return result;
    }

    private void reset() {
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            if (selectedOperation != null) {
                performMatch();
            }
        }
        return getContext();
    }

    @Deprecated
    private boolean checkStatus() {
        String status = operation.getStatus();
        return status.equals("OPST0600") ||
                status.equals("OPST0500") ||
                status.equals("OPST0102");
    }

    private void performMatch() {
        classLogger.trace("match...");

        if (isMaker()) {
            Operation oper = new Operation();
            oper.setId(operation.getId());
            oper.setMatchId(selectedOperation.getId());

            ApplicationBuilder builder = new ApplicationBuilder(
                    applicationDao,
                    userSessionId,
                    operation.getIssInstId() == null ? operation.getAcqInstId() : operation.getIssInstId(),
                    getFlowId()
            );

            builder.buildFromOperation(oper, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(operation);
            getContext().put(WizardConstants.OPER_STATUS, builder.getApplication().getStatus());
        } else {
            Long presOperId = null;
            Long origOperId = null;
            if (OperationsConstants.MESSAGE_TYPE_PRESENTMENT.equals(operation.getMsgType())) {
                presOperId = operation.getId();
                origOperId = selectedOperation.getId();
            } else {
                origOperId = operation.getId();
                presOperId = selectedOperation.getId();
            }

            getContext().put(ORIG_OPER_ID, origOperId);
            getContext().put(PRES_OPER_ID, presOperId);

            operationDao.matchOperations(userSessionId, presOperId, origOperId);
            getContext().put(PRES_MATCH_STATUS, operationById(presOperId).getMatchStatus());
            getContext().put(ORIG_MATCH_STATUS, operationById(origOperId).getMatchStatus());
        }
    }

    @Override
    public boolean validate() {
        if (selectedOperation == null) {
            FacesUtils.addMessageError("Please select the operation");
            return false;
        } else {
            return true;
        }
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public SimpleSelection getOperationSelection() {
        return this.operationSelection;
    }

    public Operation[] getOperations() {
        return operations;
    }

    public void setOperations(Operation[] operations) {
        this.operations = operations;
    }


    public void setOperationSelection(SimpleSelection operationSelection) {
        classLogger.trace("setOperationSelection...");
        this.operationSelection = operationSelection;
        if (operations == null || operations.length == 0) return;
        int index = selectedIdx();
        if (index < 0) return;
        Operation operation = operations[index];
        if (!operation.equals(selectedOperation)) {
            selectedOperation = operation;
        }
    }

    private Integer selectedIdx() {
        classLogger.trace("selectedIdx...");
        Iterator<Object> keys = operationSelection.getKeys();
        if (!keys.hasNext()) return -1;
        Integer index = (Integer) keys.next();
        return index;
    }

    private Operation[] operationsByCardAndMsgType(Long cardId, Operation oper) {
        String selectedMsgType = oper.getMsgType();
        classLogger.trace("operationsByCardAndMsgType...");
        List<String> msgTypes = new ArrayList<String>();
        if (OperationsConstants.MESSAGE_TYPE_PREAUTHORIZATION.equals(selectedMsgType)) {
            msgTypes.add(OperationsConstants.MESSAGE_TYPE_AUTHORIZATION);
            msgTypes.add(OperationsConstants.MESSAGE_TYPE_PREAUTHORIZATION);
            msgTypes.add(OperationsConstants.MESSAGE_TYPE_COMPLETION);
        } else if (OperationsConstants.MESSAGE_TYPE_AUTHORIZATION.equals(selectedMsgType) ||
                OperationsConstants.MESSAGE_TYPE_PREAUTHORIZATION.equals(selectedMsgType) ||
                OperationsConstants.MESSAGE_TYPE_COMPLETION.equals(selectedMsgType)) {
            msgTypes.add(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        }
        Operation[] result;
        SelectionParams sp = new SelectionParams();
        List<Filter> filters = new ArrayList<Filter>();
        filters.add(new Filter("cardId", cardId));
        filters.add(new Filter("lang", curLang));
        filters.add(new Filter("matchStatusOrNull", OperationsConstants.MATCH_STATUS_REQUIRE_MATCHING));
        if (oper.getIsReversal() != null) {
            filters.add(new Filter("reversal", oper.getIsReversal() ? 1 : 0));
        }
        filters.add(new Filter("msgTypes", null, msgTypes));
        sp.setRowIndexEnd(-1);
        sp.setFilters(filters.toArray(new Filter[filters.size()]));
        result = operationDao.getOperationsByParticipant(userSessionId, sp);
        return result;
    }

    private Long retriveCardId(Long operId) {
        classLogger.trace("retriveCard...");
        SelectionParams sp = SelectionParams.build(
                "operId", operId
                , "participantType", Participant.ISS_PARTICIPANT
                , "lang", curLang);
        Participant[] partyIss = operationDao.getParticipants(userSessionId, sp);
        if (partyIss.length > 0) {
            return partyIss[0].getCardId();
        }
        return null;
    }

    public String getMessage() {
        return message;
    }

    public boolean isOperationOk() {
        return operationOk;
    }

}

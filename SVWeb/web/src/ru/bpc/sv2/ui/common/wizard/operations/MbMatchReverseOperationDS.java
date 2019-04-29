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
@ManagedBean(name = "MbMatchReverseOperationDS")
public class MbMatchReverseOperationDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbMatchReverseOperationDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/matchReversalOperationDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String ORIG_OPER_ID = "ORIG_OPER_ID";
    private static final String OBJECT_ID = "OBJECT_ID";

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
            if (!operation.getIsReversal()) {
                throw new IllegalStateException("Matching cannot be done for non reversals");
            } else if (operation.getOriginalId() != null) {
                throw new IllegalStateException("Reversal already matched");
            } else {
                operations = operationsByCard(retriveCardNumber(objectId));
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
            performMatch();
        }
        return getContext();
    }

    private void performMatch() {
        classLogger.trace("match...");

        if (isMaker()) {
            Operation oper = new Operation();
            oper.setId(selectedOperation.getId());
            oper.setMatchId(operation.getId());

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
            getContext().put(ORIG_OPER_ID, selectedOperation.getId());
            operationDao.matchOperationForReversal(userSessionId, objectId, selectedOperation.getId());
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

    private Operation[] operationsByCard(String cardNumber) {
        classLogger.trace("operationsByCard...");
        Operation[] result;
        SelectionParams sp = new SelectionParams();
        List<Filter> filters = new ArrayList<Filter>();
        filters.add(new Filter("cardNumber", cardNumber));
        filters.add(new Filter("lang", curLang));
        filters.add(new Filter("reversal", 0));
        filters.add(new Filter("reversalExists", 0));
        sp.setFilters(filters.toArray(new Filter[filters.size()]));
        sp.setRowIndexEnd(-1);
        result = operationDao.getOperationsByParticipant(userSessionId, sp);
        return result;
    }

    private String retriveCardNumber(Long operId) {
        classLogger.trace("retriveCard...");
        SelectionParams sp = SelectionParams.build(
                "operId", operId
                , "participantType", Participant.ISS_PARTICIPANT);
        String cardNumber = operationDao.getParticipantCardNumber(userSessionId, sp);
        return cardNumber;
    }

    public String getMessage() {
        return message;
    }

    public boolean isOperationOk() {
        return operationOk;
    }

}

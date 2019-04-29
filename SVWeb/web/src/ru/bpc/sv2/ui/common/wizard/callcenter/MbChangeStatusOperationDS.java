package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbChangeStatusOperationDS")
public class MbChangeStatusOperationDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbChangeStatusOperationDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/changeStatusOperationDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String OPER_STATUS_READY = "OPST0100";
    private static final String OPER_STATUS_WAITS_FOR_CHECKER = "OPST0140";

    private EventsDao eventDao = new EventsDao();

    private OrgStructDao orgStructDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private AccountsDao accountsDao = new AccountsDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private String entityType;
    private Long objectId;
    private Operation operation;
    private boolean forceProcess;
    private boolean reProcess;
    private transient DictUtils dictUtils;
    private List<SelectItem> statuses = null;
    private String newStatus;
    private List<Participant> participants = null;
    private List<Comparison> comparisonList;
    private List<SelectItem> settlementTypes;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
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
            loadParticipantsForOperation(objectId);
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
        newStatus = null;
        statuses = null;
        forceProcess = false;
        reProcess = false;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = changeStatus();
            getContext().put(WizardConstants.OPER_STATUS, operStatus);
        }
        return getContext();
    }

    private String changeStatus() {
        classLogger.trace("changeStatus...");
        String operStatus = null;
        Operation oper = new Operation();
        oper.setId(operation.getId());
        oper.setStatus(newStatus);
        oper.setForcedProcessing(forceProcess);

        if (isMaker()) {
            if (newStatus == null || newStatus.trim().length() == 0) return null;

            ApplicationBuilder builder = new ApplicationBuilder(
                    applicationDao,
                    userSessionId,
                    operation.getIssInstId() == null ? operation.getAcqInstId() : operation.getIssInstId(),
                    getFlowId()
            );

            builder.buildFromOperation(oper, false);
            builder.createApplicationInDB();
            builder.addApplicationObject(operation);
            return builder.getApplication().getStatus();
        } else {
            if (newStatus != null && newStatus.trim().length() > 0) {
                operationDao.modifyOperStatus(userSessionId, oper);
            }
            if (isReadyToProcess() && reProcess) {
                try {
                    operStatus = operationDao.processOperation(userSessionId, operation.getId());
                } catch (Exception e) {
                    classLogger.error("Error when process operation. ", e);
                    FacesUtils.addMessageError(e);
                }
            }
            return operStatus == null ? oper.getStatus() : operStatus;
        }


    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public boolean isForceProcess() {
        return forceProcess;
    }

    public void setForceProcess(boolean forceProcess) {
        this.forceProcess = forceProcess;
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public List<SelectItem> getStatuses() {
        if (statuses == null) {
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("INITIAL_STATUS", operation.getStatus());
            statuses = getDictUtils().getLov(LovConstants.OPERATION_STATUSES_TRANSITIONS, map);
        }
        return statuses;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        this.newStatus = newStatus;
        reProcess = (OPER_STATUS_READY.equals(newStatus) || OPER_STATUS_WAITS_FOR_CHECKER.equals(newStatus));
    }

    public boolean isReadyToProcess() {
        if (newStatus != null && newStatus.trim().length() > 0) {
            return (OPER_STATUS_READY.equals(newStatus) || OPER_STATUS_WAITS_FOR_CHECKER.equals(newStatus));
        } else {
            return (OPER_STATUS_READY.equals(operation.getStatus()) || OPER_STATUS_WAITS_FOR_CHECKER.equals(newStatus));
        }
    }

    public boolean isReProcess() {
        return reProcess;
    }

    public void setReProcess(boolean reProcess) {
        this.reProcess = reProcess;
    }

    public void loadParticipantsForOperation(Long operId) {
        Filter[] filters = new Filter[2];
        filters[0] = new Filter("lang", curLang);
        filters[1] = new Filter("operId", operId);

        SelectionParams params = new SelectionParams(filters);
        params.setRowIndexEnd(Integer.MAX_VALUE);
        try {
            Participant[] result = operationDao.getParticipants(userSessionId, params);
            if (result.length > 0) {
                participants = Arrays.asList(result);
            } else {
                participants = null;
            }
        } catch (Exception e) {
            classLogger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public List<Participant> getParticipants() {
        return participants;
    }

    public void setRefreshType(String type) {
        performChecks(type);
        for (Participant participant : participants) {
            if (participant.getParticipantType().equals(type)) {
                getComparisonList().get(0).setCurrent(participant);
            }
        }
    }

    public void performChecks(String type) {
        try {
            Participant participant = new Participant();
            participant.setParticipantType(type);
            participant.setOperId(objectId);
            Participant checked = operationDao.performChecks(userSessionId, participant, curLang);
            getComparisonList().get(0).setChecked(checked);
        } catch (Exception e) {
            classLogger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public List<Comparison> getComparisonList() {
        if (comparisonList == null) {
            comparisonList = new ArrayList<Comparison>();
            comparisonList.add(new Comparison());
        }
        return comparisonList;
    }

    public void refreshSttlType() {
        Map<String, Object> params = new HashMap<String, Object>();
        for (Participant participant : participants) {
            if (participant.getParticipantType().equals(Participant.ISS_PARTICIPANT)) {
                params.put("iss_inst_id", participant.getInstId());
                params.put("card_inst_id", participant.getCardInstId());
                params.put("iss_network_id", participant.getNetworkId());
                params.put("card_network_id", participant.getCardNetworkId());
            }
            if (participant.getParticipantType().equals(Participant.ACQ_PARTICIPANT)) {
                params.put("acq_inst_id", participant.getInstId());
                params.put("acq_network_id", participant.getNetworkId());
            }
        }
        try {
            String sttl_type = operationDao.getSttlType(userSessionId, params);
            getComparisonList().get(0).setCheckedSttlType(sttl_type);
        } catch (Exception e) {
            classLogger.error("", e);
            FacesUtils.addMessageError(e);
        }
        getComparisonList().get(0).setCurrentSttlType(operation.getSttlType());
        params.put("acq_inst_bin", operation.getAcqInstBin());
    }

    public void modifySttlType() {
        try {
            Operation operation = new Operation();
            operation.setSttlType(getComparisonList().get(0).getCheckedSttlType());
            operation.setId(objectId);
            operationDao.modifySttlType(userSessionId, operation);
        } catch (Exception e) {
            classLogger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public List<SelectItem> getSettlementTypes() {
        if (settlementTypes == null) {
            settlementTypes = getDictUtils().getLov(LovConstants.SETTLEMENT_TYPES);
        }
        return settlementTypes;
    }

    public class Comparison {
        Participant current;
        Participant checked;
        String currentSttlType;
        String checkedSttlType;

        public Participant getCurrent() {
            return current;
        }

        public void setCurrent(Participant current) {
            this.current = current;
        }

        public Participant getChecked() {
            return checked;
        }

        public void setChecked(Participant checked) {
            this.checked = checked;
        }

        public String getCurrentSttlType() {
            return currentSttlType;
        }

        public void setCurrentSttlType(String currentSttlType) {
            this.currentSttlType = currentSttlType;
        }

        public String getCheckedSttlType() {
            return checkedSttlType;
        }

        public void setCheckedSttlType(String checkedSttlType) {
            this.checkedSttlType = checkedSttlType;
        }

    }

    public void save() {
        try {
            operationDao.updateParticipant(userSessionId, getComparisonList().get(0).getChecked());
        } catch (Exception e) {
            classLogger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }

    public void cancel() {

    }
}

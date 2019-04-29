package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.evt.StatusMap;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeStatusDS")
public class MbChangeStatusDS extends AbstractWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbChangeStatusDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/changeStatusDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";

    private EventsDao eventDao = new EventsDao();

    private OrgStructDao orgStructDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private AccountsDao accountsDao = new AccountsDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private String entityType;
    private Account account;
    private List<SelectItem> newStatuses;
    private String currentStatus;
    private String reason;
    private String newStatus;
    private List<SelectItem> reasons;
    private Long objectId;

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
        if (EntityNames.ACCOUNT.equals(entityType)) {
            account = accountById(objectId);
            currentStatus = account.getStatus();
            updateNewStatuses();
        }
    }

    private Account accountById(Long id) {
        classLogger.trace("accountById...");
        Account result = null;
        SelectionParams sp = SelectionParams.build("id", id);
        Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
        if (accounts.length != 0) {
            result = accounts[0];
        }
        return result;
    }

    private void reset() {
        newStatuses = null;
        currentStatus = null;
        reason = null;
        newStatus = null;
        reasons = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            if (EntityNames.ACCOUNT.equals(entityType)) {
                String operStatus = changeStatus();
                getContext().put(WizardConstants.OPER_STATUS, operStatus);
            }
        }
        return getContext();
    }

    private String changeStatus() {
        classLogger.trace("changeStatus...");
        Operation operation = new Operation();
        operation.setOperType((String) getContext().get(MbCommonWizard.OPER_TYPE));
        operation.setOperReason(reason);
        operation.setMsgType("MSGTPRES");
        operation.setStatus("OPST0100");
        operation.setSttlType("STTT0010");
        operation.setOperCount(1L);
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());
        operation.setClientIdType("CITPACCT");
        operation.setClientIdValue(account.getAccountNumber());

        operation.setParticipantType("PRTYISS");
        operation.setIssInstId(account.getInstId());
        operation.setCustomerId(account.getCustomerId());
        operation.setAccountId(account.getId());
        operation.setAccountNumber(account.getAccountNumber());

        Integer networkId = orgStructDao.getNetworkIdByInstId(userSessionId, account.getInstId(), curLang);

        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);


        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, account.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(account);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            String operStatus = operationDao.processOperation(userSessionId, operation.getId());
            return operStatus;
        }

    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public List<SelectItem> getNewStatuses() {
        if (newStatuses == null) {
            updateNewStatuses();
        }
        return newStatuses;
    }

    private void updateNewStatuses() {
        classLogger.trace("updateNewStatuses...");
        newStatuses = new LinkedList<SelectItem>();
        SelectionParams sp = SelectionParams.build("initiator", "ENSICLNT"
                , "initialStatus", currentStatus);
        StatusMap[] statusMaps = eventDao.getStatusMaps(userSessionId, sp);
        for (StatusMap sm : statusMaps) {
            newStatuses.add(new SelectItem(sm.getResultStatus(), sm.getResultStatus() + " - " + sm.getResultStatusText()));
        }
    }

    public List<SelectItem> getReasons() {
        if (reasons == null) {
            updateReasons();
        }
        return reasons;
    }

    private void updateReasons() {
        classLogger.trace("updateReasons...");
        reasons = new LinkedList<SelectItem>();
        SelectionParams sp = SelectionParams.build("initiator", "ENSICLNT"
                , "initialStatus", currentStatus
                , "resultStatus", newStatus);
        StatusMap[] statusMaps = eventDao.getStatusMaps(userSessionId, sp);
        for (StatusMap sm : statusMaps) {
            reasons.add(new SelectItem(sm.getEventType(), sm.getEventType() + " - " + sm.getEventTypeText()));
        }
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public String getCurrentStatus() {
        return currentStatus;
    }

    public void setCurrentStatus(String currentStatus) {
        this.currentStatus = currentStatus;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        if (newStatus != null && !newStatus.equals(this.newStatus)) {
            this.newStatus = newStatus;
            updateReasons();
        }
    }

}

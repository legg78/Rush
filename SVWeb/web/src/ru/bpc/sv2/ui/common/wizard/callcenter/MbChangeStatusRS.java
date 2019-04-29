package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeStatusRS")
public class MbChangeStatusRS extends AbstractWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbChangeStatusRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/changeStatusRS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";

    private AccountsDao accountsDao = new AccountsDao();

    private String entityType;
    private Long objectId;
    private String currentStatus;
    private String operStatus;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);

        classLogger.trace("init...");

        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        if (!context.containsKey(ENTITY_TYPE)) {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (!context.containsKey(OBJECT_ID)) {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        objectId = (Long) context.get(OBJECT_ID);
        if (!context.containsKey(WizardConstants.OPER_STATUS)) {
            throw new IllegalStateException(WizardConstants.OPER_STATUS + " is not defined in wizard context");
        }
        operStatus = (String) context.get(WizardConstants.OPER_STATUS);
        if (EntityNames.ACCOUNT.equals(entityType)) {
            Account account = accountById(objectId);
            currentStatus = account.getStatus();
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

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        return getContext();
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public String getCurrentStatus() {
        return currentStatus;
    }

    public void setCurrentStatus(String currentStatus) {
        this.currentStatus = currentStatus;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

}

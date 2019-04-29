package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;


@ViewScoped
@ManagedBean(name = "MbAccountFundsTransferRS")
public class MbAccountFundsTransferRS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbAccountFundsTransferDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/account/accountFundsTransferRS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String SOURCE_ACCOUNT = "SOURCE_ACCOUNT";
    private static final String DEST_ACCOUNT = "DEST_ACCOUNT";
    private static final String OPERATION = "OPERATION";

    private Account sourceAccount;
    private Operation operation;
    private Account destAccount;
    private String operStatus;

    protected AccountsDao accountsDao = new AccountsDao();
    protected OperationDao operationDao = new OperationDao();

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        logger.trace("init...");

        if (!((String) context.get(ENTITY_TYPE)).equalsIgnoreCase(EntityNames.ACCOUNT)) {
            throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "account_error"));
        }
        if (context.containsKey(SOURCE_ACCOUNT)) {
            sourceAccount = (Account) context.get(SOURCE_ACCOUNT);
        } else {
            throw new IllegalStateException(SOURCE_ACCOUNT + " is not defined in wizard step context");
        }
        if (context.containsKey(DEST_ACCOUNT)) {
            destAccount = (Account) context.get(DEST_ACCOUNT);
        } else {
            throw new IllegalStateException(DEST_ACCOUNT + " is not defined in wizard step context");
        }
        if (context.containsKey(OPERATION)) {
            operation = (Operation) context.get(OPERATION);
        } else {
            throw new IllegalStateException(OPERATION + " is not defined in wizard step context");
        }

        operStatus = (String) context.get(WizardConstants.OPER_STATUS);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return getContext();
    }

    @Override
    public boolean validate() {
        return true;
    }

    public Account getSourceAccount() {
        return sourceAccount;
    }

    public void setSourceAccount(Account sourceAccount) {
        this.sourceAccount = sourceAccount;
    }

    public Operation getOperation() {
        return operation;
    }

    public void setOperation(Operation operation) {
        this.operation = operation;
    }

    public Account getDestAccount() {
        return destAccount;
    }

    public void setDestAccount(Account destAccount) {
        this.destAccount = destAccount;
    }

    public String getCurLang() {
        return curLang;
    }

    public void setCurLang(String curLang) {
        this.curLang = curLang;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }
}

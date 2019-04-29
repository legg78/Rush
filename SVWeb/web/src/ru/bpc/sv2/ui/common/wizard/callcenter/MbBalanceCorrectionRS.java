package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbBalanceCorrectionRS")
public class MbBalanceCorrectionRS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbBalanceCorrectionDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/balanceCorrectionRS.jspx";
    private static final String ACCOUNT = "ACCOUNT";

    private AccountsDao accountsDao = new AccountsDao();

    private String operStatus;
    private Balance[] balances;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        operStatus = getContextRequired(WizardConstants.OPER_STATUS);
        balances = balancesByAccount((Account) getContextRequired(ACCOUNT));
    }

    private Balance[] balancesByAccount(Account account) {
        classLogger.trace("balancesByAccount...");
        SelectionParams sp = SelectionParams.build("accountId", account.getId());
        return accountsDao.getBalances(userSessionId, sp);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        return getContext();
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        throw new UnsupportedOperationException("validation");
    }

    public Balance[] getBalances() {
        return balances;
    }

    public void setBalances(Balance[] balances) {
        this.balances = balances;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

}

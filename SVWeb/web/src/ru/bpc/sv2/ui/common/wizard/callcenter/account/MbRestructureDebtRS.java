package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.credit.DppCalculation;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbRestructureDebtRS")
public class MbRestructureDebtRS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbRestructureDebtRS.class);
    protected String PAGE = "/pages/common/wizard/callcenter/account/restructureDebtRS.jspx";

    protected AccountsDao accountsDao = new AccountsDao();

    protected long userSessionId;
    protected Map<String, Object> context;
    protected DppCalculation calculation;
    protected Account account;

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        this.context = context;
        userSessionId = SessionWrapper.getRequiredUserSessionId();

        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.FALSE);

        if (context.containsKey(MbRestructureDebtInputDS.DPP_CALCULATION)) {
            calculation = (DppCalculation)context.get(MbRestructureDebtInputDS.DPP_CALCULATION);
        } else {
            throw new IllegalStateException(MbRestructureDebtInputDS.DPP_CALCULATION + " is not defined in wizard context");
        }

        account = accountById(calculation.getAccountId());
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        return context;
    }

    @Override
    public boolean validate() {
        return false;
    }

    public List<Object> getEmptyTable() {
        List<Object> arr = new ArrayList<Object>(1);
        arr.add(new Object());
        return arr;
    }

    public DppCalculation getCalculation() {
        return calculation;
    }
    public void setCalculation(DppCalculation calculation) {
        this.calculation = calculation;
    }

    public Account getAccount() {
        return account;
    }
    public void setAccount(Account account) {
        this.account = account;
    }

    protected Account accountById(Long id) {
        SelectionParams sp = SelectionParams.build("id", id);
        Account[] accounts = accountsDao.getAccounts(userSessionId, sp);
        return (accounts != null && accounts.length != 0) ? accounts[0] : null;
    }
}

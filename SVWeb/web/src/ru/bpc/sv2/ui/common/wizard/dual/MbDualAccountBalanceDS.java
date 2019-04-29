package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbAccountBalanceDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualAccountBalanceDS")
public class MbDualAccountBalanceDS extends MbAccountBalanceDS {
    public MbDualAccountBalanceDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_CHANGE_BALANCE_MAKER, WizardPrivConstants.ACCOUNT_CHANGE_BALANCE_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbAccountFundsTransferDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualAccountFundsTransferDS")
public class MbDualAccountFundsTransferDS extends MbAccountFundsTransferDS {
    public MbDualAccountFundsTransferDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_FUNDS_TRANSFER_MAKER, WizardPrivConstants.ACCOUNT_FUNDS_TRANSFER_CHECKER);
    }
}

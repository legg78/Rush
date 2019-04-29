package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbFundsTranferBetweenAccountsDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualFundsTranferBetweenAccountsDS")
public class MbDualFundsTranferBetweenAccountsDS extends MbFundsTranferBetweenAccountsDS {
    public MbDualFundsTranferBetweenAccountsDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_FUNDS_TRANSFER_BETWEEN_MAKER, WizardPrivConstants.ACCOUNT_FUNDS_TRANSFER_BETWEEN_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbProvideCreditLimitDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualProvideCreditLimitDS")
public class MbDualProvideCreditLimitDS extends MbProvideCreditLimitDS {
    public MbDualProvideCreditLimitDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_PROVIDE_CREDIT_LIMIT_MAKER, WizardPrivConstants.ACCOUNT_PROVIDE_CREDIT_LIMIT_CHECKER);
    }
}

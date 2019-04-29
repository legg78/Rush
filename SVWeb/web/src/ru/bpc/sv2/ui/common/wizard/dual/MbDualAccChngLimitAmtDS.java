package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbAccChngLimitAmtDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualAccChngLimitAmtDS")
public class MbDualAccChngLimitAmtDS extends MbAccChngLimitAmtDS {
    public MbDualAccChngLimitAmtDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_CHANGE_LIMIT_AMOUNT_MAKER, WizardPrivConstants.ACCOUNT_CHANGE_LIMIT_AMOUNT_CHECKER);
    }
}

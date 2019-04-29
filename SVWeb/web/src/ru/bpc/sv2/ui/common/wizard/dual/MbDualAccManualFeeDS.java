package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbAccManualFeeDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualAccManualFeeDS")
public class MbDualAccManualFeeDS extends MbAccManualFeeDS {
    public MbDualAccManualFeeDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_MANUAL_FEE_MAKER, WizardPrivConstants.ACCOUNT_MANUAL_FEE_CHECKER);
    }
}

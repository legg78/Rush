package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbBalanceCorrectionDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualBalanceCorrectionDS")
public class MbDualBalanceCorrectionDS extends MbBalanceCorrectionDS {
    public MbDualBalanceCorrectionDS() {
        setFlowId(ApplicationFlows.FRQ_BALANCE_CORRECTION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_BALANCE_CORRECTION_MAKER, WizardPrivConstants.ACCOUNT_BALANCE_CORRECTION_CHECKER);
    }
}

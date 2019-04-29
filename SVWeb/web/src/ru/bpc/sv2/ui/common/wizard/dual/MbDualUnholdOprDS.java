package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbManualFeeDS;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbUnholdOprDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualUnholdOprDS")
public class MbDualUnholdOprDS extends MbUnholdOprDS {
    public MbDualUnholdOprDS() {
        setFlowId(ApplicationFlows.FRQ_UNHOLD_AUTHORIZATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_UNHOLD_MAKER, WizardPrivConstants.CARD_UNHOLD_CHECKER);
    }
}

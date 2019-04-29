package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbChangeCardStatusDataStep;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualChangeCardStatusDataStep")
public class MbDualChangeCardStatusDataStep extends MbChangeCardStatusDataStep {
    public MbDualChangeCardStatusDataStep() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_CHANGE_STATUS_MAKER, WizardPrivConstants.CARD_CHANGE_STATUS_CHECKER);
    }
}

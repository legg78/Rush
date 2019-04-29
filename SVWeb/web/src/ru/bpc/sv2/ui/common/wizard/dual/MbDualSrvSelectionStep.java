package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbSrvSelectionStep;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualSrvSelectionStep")
public class MbDualSrvSelectionStep extends MbSrvSelectionStep {
    public MbDualSrvSelectionStep() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_SERVICE_NOTIFICATION_MAKER, WizardPrivConstants.CARD_SERVICE_NOTIFICATION_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.card.MbCardOperationDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean (name = "MbDualCardOperationDS")
public class MbDualCardOperationDS extends MbCardOperationDS {
    public MbDualCardOperationDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_OPERATION_MAKER, WizardPrivConstants.CARD_OPERATION_CHECKER);
    }
}

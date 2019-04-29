package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbDetachServiceDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualDetachServiceDS")
public class MbDualDetachServiceDS extends MbDetachServiceDS {
    public MbDualDetachServiceDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_DETACH_SERVICE_MAKER, WizardPrivConstants.CARD_DETACH_SERVICE_CHECKER);
    }
}

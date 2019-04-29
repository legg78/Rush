package ru.bpc.sv2.ui.common.wizard.dual;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbManualFeeDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualManualFeeDS")
public class MbDualManualFeeDS extends MbManualFeeDS {
    public MbDualManualFeeDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_MANUAL_FEE_MAKER, WizardPrivConstants.CARD_MANUAL_FEE_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.dispute.MbFeeCollectionDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualFeeCollectionDS")
public class MbDualFeeCollectionDS extends MbFeeCollectionDS {
    public MbDualFeeCollectionDS() {
        setFlowId(ApplicationFlows.FRQ_FEE_COLLECTION);
        setMakerCheckerMode(WizardPrivConstants.FEE_COLLECTION_MAKER, WizardPrivConstants.FEE_COLLECTION_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbChangeStatusOperationDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualChangeStatusOperationDS")
public class MbDualChangeStatusOperationDS extends MbChangeStatusOperationDS {
    public MbDualChangeStatusOperationDS() {
        setFlowId(ApplicationFlows.FRQ_ID_REPROCESS_OPER);
        setMakerCheckerMode(WizardPrivConstants.OPERATION_REPROCESSING_MAKER, WizardPrivConstants.OPERATION_REPROCESSING_CHECKER);
    }
}

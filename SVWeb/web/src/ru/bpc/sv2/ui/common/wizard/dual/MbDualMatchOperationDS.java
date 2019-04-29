package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.operations.MbMatchOperationDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualMatchOperationDS")
public class MbDualMatchOperationDS extends MbMatchOperationDS {
    public MbDualMatchOperationDS() {
        setFlowId(ApplicationFlows.FRQ_ID_MATCH_OPER_MANUALLY);
        setMakerCheckerMode(WizardPrivConstants.OPERATION_MATCH_MAKER, WizardPrivConstants.OPERATION_MATCH_CHECKER);
    }
}

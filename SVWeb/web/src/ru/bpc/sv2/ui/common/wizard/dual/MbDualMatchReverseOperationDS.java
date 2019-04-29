package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.operations.MbMatchReverseOperationDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualMatchReverseOperationDS")
public class MbDualMatchReverseOperationDS extends MbMatchReverseOperationDS {
    public MbDualMatchReverseOperationDS() {
        setFlowId(ApplicationFlows.FRQ_ID_MATCH_REVERSAL_OPER);
        setMakerCheckerMode(WizardPrivConstants.OPERATION_MATCH_REVERSAL_MAKER, WizardPrivConstants.OPERATION_MATCH_REVERSAL_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.operations.MbChangeOperationsStatusDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualChangeOperationsStatusDS")
public class MbDualChangeOperationsStatusDS extends MbChangeOperationsStatusDS {
    public MbDualChangeOperationsStatusDS() {
        setFlowId(ApplicationFlows.FRQ_ID_CHANGE_OPER_STATUS);
        setMakerCheckerMode(WizardPrivConstants.OPERATION_CHANGE_STATUS_MAKER, WizardPrivConstants.OPERATION_CHANGE_STATUS_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbAccountOperationDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualAccountOperationAcqDS")
public class MbDualAccountOperationAcqDS extends MbAccountOperationDS {
    public MbDualAccountOperationAcqDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_COMMON_OPERATION_ACQ_MAKER, WizardPrivConstants.ACCOUNT_COMMON_OPERATION_ACQ_CHECKER);
    }
}

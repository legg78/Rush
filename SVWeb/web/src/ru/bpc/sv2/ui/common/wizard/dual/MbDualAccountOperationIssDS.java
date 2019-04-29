package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbAccountOperationDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualAccountOperationIssDS")
public class MbDualAccountOperationIssDS extends MbAccountOperationDS {
    public MbDualAccountOperationIssDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_COMMON_OPERATION_ISS_MAKER, WizardPrivConstants.ACCOUNT_COMMON_OPERATION_ISS_CHECKER);
    }
}

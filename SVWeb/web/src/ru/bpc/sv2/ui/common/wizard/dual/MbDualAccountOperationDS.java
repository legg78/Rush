package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbAccountOperationDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualAccountOperationDS")
public class MbDualAccountOperationDS extends MbAccountOperationDS {
    public MbDualAccountOperationDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.ACCOUNT_CHANGE_STATUS_MAKER, WizardPrivConstants.ACCOUNT_CHANGE_STATUS_CHECKER);
    }
}

package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbAccountOperationWOProcessingDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualAccountOperationWOProcessingDS")
public class MbDualAccountOperationWOProcessingDS extends MbAccountOperationWOProcessingDS {
    public MbDualAccountOperationWOProcessingDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.COMMON_OPERATION_MAKER, WizardPrivConstants.COMMON_OPERATION_CHECKER);
    }
}

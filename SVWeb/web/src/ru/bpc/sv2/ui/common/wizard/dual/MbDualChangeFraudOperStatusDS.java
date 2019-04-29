package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.operations.MbChangeFraudOperStatusDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualChangeFraudOperStatusDS")
public class MbDualChangeFraudOperStatusDS extends MbChangeFraudOperStatusDS {
    public MbDualChangeFraudOperStatusDS() {
        setFlowId(ApplicationFlows.FRQ_ID_SET_OPER_STAGE);
        setMakerCheckerMode(WizardPrivConstants.COMMON_CHANGE_FRAUD_STATUS_MAKER, WizardPrivConstants.COMMON_CHANGE_FRAUD_STATUS_CHECKER);
    }
}

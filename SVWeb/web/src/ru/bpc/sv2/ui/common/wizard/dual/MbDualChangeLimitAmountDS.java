package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbChangeLimitAmountDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbDualChangeLimitAmountDS")
public class MbDualChangeLimitAmountDS extends MbChangeLimitAmountDS {
    public MbDualChangeLimitAmountDS() {
        setFlowId(ApplicationFlows.FRQ_COMMON_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_CHANGE_LIMIT_AMOUNT_MAKER, WizardPrivConstants.CARD_CHANGE_LIMIT_AMOUNT_CHECKER);
    }
}

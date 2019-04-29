package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.callcenter.account.MbBalanceTransferFromPrepaidCardDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualBalanceTransferFromPrepaidCardDS")
public class MbDualBalanceTransferFromPrepaidCardDS extends MbBalanceTransferFromPrepaidCardDS {
    public MbDualBalanceTransferFromPrepaidCardDS() {
        setFlowId(ApplicationFlows.FRQ_BALANCE_TRANSFER);
        setMakerCheckerMode(WizardPrivConstants.COMMON_BALANCE_TRANSFER_FROM_PREPAID_CARD_MAKER, WizardPrivConstants.COMMON_BALANCE_TRANSFER_FROM_PREPAID_CARD_CHECKER);
    }
}

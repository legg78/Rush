package ru.bpc.sv2.ui.common.wizard.dual;

import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.ui.common.wizard.operations.MbRewardsLoyaltyOperationsDS;
import ru.bpc.sv2.wizard.WizardPrivConstants;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;


@ViewScoped
@ManagedBean(name = "MbDualRewardsLoyaltyOperationsDS")
public class MbDualRewardsLoyaltyOperationsDS extends MbRewardsLoyaltyOperationsDS {
    public MbDualRewardsLoyaltyOperationsDS() {
        setFlowId(ApplicationFlows.FRQ_ID_LTY_SPENT_OPERATION);
        setMakerCheckerMode(WizardPrivConstants.CARD_REWARD_LOYALTY_MAKER, WizardPrivConstants.CARD_REWARD_LOYALTY_CHECKER);
    }
}

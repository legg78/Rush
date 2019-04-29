package ru.bpc.sv2.ui.common.wizard.callcenter.account;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbBalanceTransferFromPrepaidCardRS")
public class MbBalanceTransferFromPrepaidCardRS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbBalanceTransferFromPrepaidCardRS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/account/balanceTransferFromPrepaidCardRS.jspx";

    private Application application;
    private Account sourceAccount;
    private Account destAccount;
    private Card sourceCard;
    private BigDecimal amount;
    private String appStatus;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        logger.trace("init...");
        reset();
        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);

        if (!((String)context.get(WizardConstants.ENTITY_TYPE)).equalsIgnoreCase(EntityNames.ACCOUNT)) {
            throw new IllegalStateException(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "account_error"));
        }
        if (isMaker()) {
            if (context.containsKey(WizardConstants.APPLICATION)) {
                application = (Application)context.get(WizardConstants.APPLICATION);
            } else {
                throw new IllegalStateException(WizardConstants.APPLICATION + " is not defined in wizard step context");
            }
        }

        if (context.containsKey(WizardConstants.APP_STATUS)) {
            appStatus = (String) context.get(WizardConstants.APP_STATUS);
        } else {
            throw new IllegalStateException(WizardConstants.APP_STATUS + " is not defined in wizard step context");
        }

        if (context.containsKey(WizardConstants.SOURCE_CARD)) {
            sourceCard = (Card)context.get(WizardConstants.SOURCE_CARD);
        } else {
            throw new IllegalStateException(WizardConstants.SOURCE_CARD + " is not defined in wizard step context");
        }
        if (context.containsKey(WizardConstants.SOURCE_ACCOUNT)) {
            sourceAccount = (Account)context.get(WizardConstants.SOURCE_ACCOUNT);
        } else {
            throw new IllegalStateException(WizardConstants.SOURCE_ACCOUNT + " is not defined in wizard step context");
        }
        if (context.containsKey(WizardConstants.DEST_ACCOUNT)) {
            destAccount = (Account)context.get(WizardConstants.DEST_ACCOUNT);
        } else {
            throw new IllegalStateException(WizardConstants.DEST_ACCOUNT + " is not defined in wizard step context");
        }
        if (context.containsKey(WizardConstants.AMOUNT)) {
            amount = (BigDecimal)context.get(WizardConstants.AMOUNT);
        } else {
            throw new IllegalStateException(WizardConstants.AMOUNT + " is not defined in wizard step context");
        }
    }
    @Override
    public Map<String, Object> release(Direction direction) {
        return null;
    }
    @Override
    public boolean validate() {
        return true;
    }

    public Application getApplication() {
        return application;
    }
    public void setApplication(Application application) {
        this.application = application;
    }

    public Account getSourceAccount() {
        return sourceAccount;
    }
    public void setSourceAccount(Account sourceAccount) {
        this.sourceAccount = sourceAccount;
    }

    public Account getDestAccount() {
        return destAccount;
    }
    public void setDestAccount(Account destAccount) {
        this.destAccount = destAccount;
    }

    public Card getSourceCard() {
        return sourceCard;
    }
    public void setSourceCard(Card sourceCard) {
        this.sourceCard = sourceCard;
    }

    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    private void reset() {
        application = null;
        sourceAccount = null;
        destAccount = null;
        sourceCard = null;
        amount = null;
    }

    public String getAppStatus() {
        return appStatus;
    }

    public void setAppStatus(String appStatus) {
        this.appStatus = appStatus;
    }
}

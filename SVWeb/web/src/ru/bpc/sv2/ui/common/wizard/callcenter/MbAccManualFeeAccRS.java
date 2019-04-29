package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbAccManualFeeAccRS")
public class MbAccManualFeeAccRS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbAccManualFeeAccRS.class);
    private static final String PAGE_CARD = "/pages/common/wizard/callcenter/manualFeeAccRS.jspx";
    private static final String PAGE_ACCOUNT = "/pages/common/wizard/callcenter/accManualFeeAccRS.jspx";
    private static final String FEE_TYPE = "FEE_TYPE";
    private static final String FEE_AMOUNT = "FEE_AMOUNT";
    private static final String CURRENCY = "CURRENCY";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String PROCESSED = "PROCESSED";

    private Map<String, Object> context;
    private String operStatus;
    private String feeType;
    private Double feeAmount;
    private Account account;
    private String currency;
    private String entityType;
    private boolean processed;

    public MbAccManualFeeAccRS() {
        logger.trace("MbAccManualFeeAccRS created...");
    }

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("init...");
        this.context = context;

        if (context.containsKey(WizardConstants.OPER_STATUS)) {
            operStatus = (String) context.get(WizardConstants.OPER_STATUS);
        } else {
            throw new IllegalStateException("OPER_STATUS is not defined in wizard context");
        }
        if (context.containsKey(FEE_TYPE)) {
            feeType = (String) context.get(FEE_TYPE);
        } else {
            throw new IllegalStateException("FEE_TYPE is not defined in wizard context");
        }
        if (context.containsKey(FEE_AMOUNT)) {
            feeAmount = (Double) context.get(FEE_AMOUNT);
        } else {
            throw new IllegalStateException("FEE_AMOUNT is not defined in wizard context");
        }
        if (context.containsKey(CURRENCY)) {
            currency = (String) context.get(CURRENCY);
        } else {
            throw new IllegalStateException("ACCOUNT is not defined in wizard context");
        }
        if (context.containsKey(ENTITY_TYPE)) {
            entityType = (String) context.get(ENTITY_TYPE);
        } else {
            throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
        }
        if (context.containsKey(PROCESSED)) {
            processed = (Boolean) context.get(PROCESSED);
        } else {
            processed = true;
        }

        if (EntityNames.CARD.equals(entityType)) {
            context.put(MbCommonWizard.PAGE, PAGE_CARD);
        } else if (EntityNames.ACCOUNT.equals(entityType)) {
            context.put(MbCommonWizard.PAGE, PAGE_ACCOUNT);
        }

        context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        return context;
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return true;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

    public String getFeeType() {
        return feeType;
    }

    public void setFeeType(String feeType) {
        this.feeType = feeType;
    }

    public Double getFeeAmount() {
        return feeAmount;
    }

    public void setFeeAmount(Double feeAmount) {
        this.feeAmount = feeAmount;
    }

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public boolean isProcessed() {
        return processed;
    }

    public void setProcessed(boolean processed) {
        this.processed = processed;
    }
}

package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.ui.acquiring.MbMerchant;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbRewardsLoyaltyMerchantCardDS")
public class MbRewardsLoyaltyMerchantCardDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbRewardsLoyaltyMerchantCardDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/MbRewardsLoyaltyMerchantCardDS.jspx";
    private static final String CARD = "CARD";
    private static final String MERCHANT = "MERCHANT";
    private static final String OPER_AMOUNT = "OPER_AMOUNT";
    private static final String ACCOUNT_CURRENCY = "ACCOUNT_CURRENCY";

    private String cardNumber;
    private Merchant selectedMerchant;
    private Card card;
    private MbMerchant mbMerchant;
    private BigDecimal operationAmount;
    private String accountCurrency;

    private IssuingDao issuingDao = new IssuingDao();

    private AccountsDao accountDao = new AccountsDao();

    public MbRewardsLoyaltyMerchantCardDS() {
        mbMerchant = (MbMerchant) ManagedBeanWrapper.getManagedBean("MbMerchant");
    }

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);
        reset();
        logger.trace("init...");
    }

    private void reset() {
        cardNumber = null;
        selectedMerchant = null;
        card = null;
        accountCurrency = null;
        operationAmount = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            getContext().put(CARD, card);
            getContext().put(MERCHANT, selectedMerchant);
            getContext().put(OPER_AMOUNT, operationAmount);
            getContext().put(ACCOUNT_CURRENCY, accountCurrency);
        }
        return getContext();
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return isCardExists(cardNumber);
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public Merchant getSelectedMerchant() {
        return selectedMerchant;
    }

    public void setSelectedMerchant(Merchant selectedMerchant) {
        this.selectedMerchant = selectedMerchant;
    }

    public void showMerchants() {
        MbMerchant merchantBean = (MbMerchant) ManagedBeanWrapper.getManagedBean("MbMerchant");
        merchantBean.setNode(null);
        merchantBean.clearFilter();
        if (selectedMerchant != null){
            merchantBean.getFilter().setMerchantNumber(selectedMerchant.getMerchantNumber());
        }
    }

    public void selectMerchant() {
        selectedMerchant = mbMerchant.getNode();
    }

    public void searchMerchants() {
        mbMerchant.searchMerchants();
    }

    public MbMerchant getMbMerchant() {
        if (mbMerchant == null) {
            mbMerchant = (MbMerchant) ManagedBeanWrapper.getManagedBean("MbMerchant");
        }
        return mbMerchant;
    }

    public void setMbMerchant(MbMerchant mbMerchant) {
        this.mbMerchant = mbMerchant;
    }

    private boolean isCardExists(String cardNumber) {
        logger.trace("searchCard...");
        boolean result = false;
        SelectionParams sp = SelectionParams.build("CARD_NUMBER", cardNumber);
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("tab_name", "CARD");
        paramMap.put("param_tab", sp.getFilters());
        Card[] cards = issuingDao.getCardsCur(userSessionId, sp, paramMap);
        if (cards.length > 0) {
            card = cards[0];
            try {
                List<Account> accounts = accountDao.getAccountsByCardId(userSessionId, card.getId());
                if (accounts.size() > 0) {
                    accountCurrency = accounts.get(0).getCurrency();
                    if (null != accountCurrency)
                        result = true;
                    else
                        FacesUtils.addMessageError("The currency of account of card is not found!");
                } else
                    FacesUtils.addMessageError("The account of card is not found!");
            } catch (Exception e) {
                logger.error(e.getMessage(), e);
                FacesUtils.addMessageError(e);
            }
        } else
            FacesUtils.addMessageError("The card is not found!");
        return result;
    }

    public BigDecimal getOperationAmount() {
        return operationAmount;
    }

    public void setOperationAmount(BigDecimal operationAmount) {
        this.operationAmount = operationAmount;
    }

    public String getAccountCurrency() {
        return accountCurrency;
    }

    public void setAccountCurrency(String accountCurrency) {
        this.accountCurrency = accountCurrency;
    }
}


package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.loyalty.LoyaltyOperation;
import ru.bpc.sv2.loyalty.LoyaltyOperationRequest;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbRewardsLoyaltyOperationsDS")
public class MbRewardsLoyaltyOperationsDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbRewardsLoyaltyOperationsDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/MbRewardsLoyaltyOperationsDS.jspx";
    private static final String CARD = "CARD";
    private static final String MERCHANT = "MERCHANT";
    private static final String OPER_AMOUNT = "OPER_AMOUNT";
    private static final String ACCOUNT_CURRENCY = "ACCOUNT_CURRENCY";

    private Card card;
    private Merchant merchant;
    private BigDecimal operationAmount;
    private String accountCurrency;
    private int userInstId;
    private LoyaltyOperation[] selectedOperations;
    private LoyaltyOperation[] searchedOperations;
    private LoyaltyOperationRequest filter;
    private boolean anyOperationSelected;

    private transient DictUtils dictUtils;
    private ArrayList<SelectItem> institutions;
    private ArrayList<SelectItem> statuses;

    private LoyaltyDao loyaltyDao = new LoyaltyDao();

    private IssuingDao issuingDao = new IssuingDao();

    private OperationDao operationDao = new OperationDao();

    private OrgStructDao orgStructureDao = new OrgStructDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        reset();
        logger.trace("init...");

        userInstId = (Integer) SessionWrapper.getObjectField("defaultInst");

        if (!context.containsKey(CARD)){
            throw new IllegalStateException(CARD + " is not defined in wizard context");
        } else
            card = (Card)context.get(CARD);

        if (!context.containsKey(MERCHANT)){
            throw new IllegalStateException(MERCHANT + " is not defined in wizard context");
        } else
            merchant = (Merchant) context.get(MERCHANT);

        if (!context.containsKey(OPER_AMOUNT)){
            throw new IllegalStateException(OPER_AMOUNT + " is not defined in wizard context");
        } else
            operationAmount = (BigDecimal)context.get(OPER_AMOUNT);

        if (!context.containsKey(ACCOUNT_CURRENCY)){
            throw new IllegalStateException(ACCOUNT_CURRENCY + " is not defined in wizard context");
        } else
            accountCurrency = (String)context.get(ACCOUNT_CURRENCY);

        filter = new LoyaltyOperationRequest();
        setDefaultValues();
    }

    private void setDefaultValues() {
        Integer defaultInstId = userInstId;
        List<SelectItem> instList = getInstitutions();
        if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
            // instId from LOV is for some reason String
            defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
        }
        filter.setInstId(defaultInstId);
        filter.setStatus("RLTS0100");
        filter.setMerchantId(merchant.getId());
        filter.setCardNumber(card.getCardNumber());
    }

    private void reset() {
        card = null;
        merchant = null;
        accountCurrency = null;
        operationAmount = null;
        selectedOperations = null;
        searchedOperations = null;
        filter = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            if (selectedOperations != null && (selectedOperations.length > 0))
                createOperation();
        }
        return getContext();
    }

    private void createOperation() {
        Operation operation = new Operation();
        operation.setOperType((String) getContext().get(MbCommonWizard.OPER_TYPE));
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(WizardConstants.US_ON_US);
        operation.setOperCount(1L);
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());

        operation.setParticipantType(Participant.ACQ_PARTICIPANT);

        operation.setClientIdType(OperationsConstants.IDENT_TYPE_CARD);
        operation.setClientIdValue(card.getCardNumber());
        operation.setCardInstId(card.getInstId());
        operation.setIssInstId(card.getInstId());
        operation.setCardId(card.getId());
        operation.setCardTypeId(card.getCardTypeId());
        operation.setCardNumber(card.getCardNumber());
        operation.setCardMask(card.getMask());
        operation.setCardHash(card.getCardHash());
        operation.setCardCountry(card.getCountry());
        operation.setCustomerId(card.getCustomerId());
        operation.setClientIdValue(card.getCardNumber());
        Integer networkId = institutionNetwork(card.getInstId());
        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        CardInstance cardInstance = retriveCardInstance(card);
        if (cardInstance != null) {
            operation.setCardInstanceId(cardInstance.getId());
            operation.setCardExpirationDate(cardInstance.getExpirDate());
            operation.setCardSeqNumber(cardInstance.getSeqNumber());
            operation.setSplitHash(cardInstance.getSplitHash());
            operation.setCardSeqNumber(cardInstance.getSeqNumber());
        }

        operation.setMerchantId(merchant.getId().intValue());
        operation.setMerchantNumber(merchant.getMerchantNumber());
        operation.setMerchantName(merchant.getMerchantName());
        operation.setMccCode(merchant.getMcc());

        operation.setOperationAmount(operationAmount);
        operation.setOperationCurrency(accountCurrency);

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(
                    applicationDao,
                    userSessionId,
                    card.getInstId(),
                    getFlowId()
            );

            builder.buildFromOperation(operation, true);
            operation.setParticipantType(Participant.ISS_PARTICIPANT);
            builder.addParticipant(operation);

            List<BigDecimal> ids = new ArrayList<BigDecimal>();
            for (int i = 0; i < selectedOperations.length; i++ ) {
                ids.add(new BigDecimal(selectedOperations[i].getOperId()));
            }
            builder.addList(AppElements.LOYALTY_OPERATION_ID, ids);

            builder.createApplicationInDB();
            builder.addApplicationObject(card);

            putContext(WizardConstants.OPER_STATUS, builder.getApplication().getStatus());
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            operation.setParticipantType(Participant.ISS_PARTICIPANT);
            operationDao.addParticipant(userSessionId, operation);

            loyaltyDao.addSpentOperation(userSessionId, selectedOperations, operation.getId());

            operationDao.processOperation(userSessionId, operation.getId());
        }
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public void searchOperations() {
        searchedOperations = loyaltyDao.getLoyaltyOperations(userSessionId, filter);
    }

    public Card getCard() {
        return card;
    }

    public void setCard(Card card) {
        this.card = card;
    }

    public Merchant getMerchant() {
        return merchant;
    }

    public void setMerchant(Merchant merchant) {
        this.merchant = merchant;
    }

    public LoyaltyOperation[] getSelectedOperations() {
        return selectedOperations;
    }

    public void setSelectedOperations(LoyaltyOperation[] selectedOperations) {
        this.selectedOperations = selectedOperations;
    }

    public LoyaltyOperation[] getSearchedOperations() {
        return searchedOperations;
    }

    public void setSearchedOperations(LoyaltyOperation[] searchedOperations) {
        this.searchedOperations = searchedOperations;
    }

    public LoyaltyOperationRequest getFilter() {
        return filter;
    }

    public void setFilter(LoyaltyOperationRequest filter) {
        this.filter = filter;
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public ArrayList<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
        }
        if (institutions == null)
            institutions = new ArrayList<SelectItem>();
        return institutions;
    }

    public ArrayList<SelectItem> getStatuses() {
        if (statuses == null) {
            statuses = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.REWARDS_LOYALTY_TRANSACTION_STATUS);
        }
        if (statuses == null)
            statuses = new ArrayList<SelectItem>();
        return statuses;
    }

    public void selectOperations() {
        ArrayList<LoyaltyOperation> selected = new ArrayList<LoyaltyOperation>();
        for (int i = 0; i < searchedOperations.length; i++) {
            if (searchedOperations[i].isChecked()) {
                selected.add(searchedOperations[i]);
            }
        }
        selectedOperations = selected.toArray(new LoyaltyOperation[selected.size()]);
    }

    public boolean isAnyOperationSelected() {
        anyOperationSelected  = false;
        if (null != searchedOperations) {
            for (int i = 0; i < searchedOperations.length; i++) {
                if (searchedOperations[i].isChecked()) {
                    anyOperationSelected = true;
                    break;
                }
            }
        }
        return anyOperationSelected;
    }

    private CardInstance retriveCardInstance(Card card){
        logger.trace("retriveCardInstances...");
        SelectionParams sp = SelectionParams.build("cardId", card.getId(), "lang", curLang);
        sp.setRowIndexEnd(Integer.MAX_VALUE);
        CardInstance[] cardInstances = issuingDao.getCardInstances(userSessionId, sp);
        if (cardInstances.length > 0)
            return cardInstances[0];
        else
            return null;
    }

    private Integer institutionNetwork(Integer instId) {
        logger.trace("institutionNetwork...");
        Integer result = null;
        SelectionParams sp = SelectionParams.build("instId", instId);
        Institution[] insts = orgStructureDao.getInstitutions(userSessionId, sp, curLang, false);
        if (insts.length != 0){
            result = insts[0].getNetworkId();
        }
        return result;
    }
}


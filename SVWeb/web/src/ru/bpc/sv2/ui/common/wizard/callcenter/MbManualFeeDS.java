package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.ClientIdentificationTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.CurrencyCache;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbManualFeeDS")
public class MbManualFeeDS extends AbstractWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbManualFeeDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/manualFeeDS.jspx";
    private static final String FEE_TYPE = "FEE_TYPE";
    private static final String FEE_AMOUNT = "FEE_AMOUNT";
    private static final String ACCOUNT = "ACCOUNT";
    private static final String CURRENCY = "CURRENCY";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String US_ON_US = "STTT0010";
    private static final String ISSUER_FEE = "OPTP0119";
    private static final String PROCESSED = "PROCESSED";

    private OrgStructDao orgStructureDao = new OrgStructDao();
    private IssuingDao issuingDao = new IssuingDao();
    private OperationDao operationDao = new OperationDao();
    private AccountsDao accountsDao = new AccountsDao();
    private ProductsDao productDao = new ProductsDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    private Card card;
    private List<CardInstance> cardInstances;
    private CardInstance selectedCardInstance;
    private String feeType;
    private SimpleSelection cardInstancesSelection;
    private boolean invalidCardInstance;
    private List<SelectItem> feeTypes;
    private Double feeAmount;
    private Account account;
    private String currency;
    private Long cardId;
    private String entityType;
    private List<SelectItem> operationStatuses;
    private String operationStatus;
    private boolean isSkipProcessing;
    private boolean processed;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);
        reset();
        classLogger.trace("init...");

        isSkipProcessing = false;
        processed = false;
        operationStatus = OperationsConstants.OPERATION_STATUS_PROCESS_READY;

        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (EntityNames.CARD.equals(entityType)) {
            card = retriveCard(cardId);
            cardInstances = retriveCardInstances(card);
            account = accountByCard(card);
        } else {
            throw new IllegalStateException("Wizard does not support the current entity");
        }
    }

    private Card retriveCard(Long cardId) {
        classLogger.trace("retriveCard...");
        Card result;
        SelectionParams sp = SelectionParams.build("CARD_ID", cardId);
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("tab_name", "CARD");
        paramMap.put("param_tab", sp.getFilters());
        Card[] cards = issuingDao.getCardsCur(userSessionId, sp, paramMap);
        if (cards.length > 0) {
            result = cards[0];
        } else {
            throw new IllegalStateException("Card with ID:" + cardId + " is not found!");
        }
        return result;
    }

    private Account accountByCard(Card card) {
        Account result = null;
        SelectionParams sp = SelectionParams.build("lang", curLang,
                "objectId", card.getId(),
                "entityType", EntityNames.CARD);
        Account[] accounts = accountsDao.getAccountsByObject(userSessionId, sp);
        if (accounts.length != 0) {
            result = accounts[0];
        }
        return result;
    }

    private List<CardInstance> retriveCardInstances(Card card) {
        classLogger.trace("MbChangeCardStatusData::retriveCardInstances...");
        List<CardInstance> result;
        SelectionParams sp = SelectionParams.build("cardId", card.getId(), "lang", curLang);
        CardInstance[] cardInstances = issuingDao.getCardInstances(userSessionId, sp);
        result = Arrays.asList(cardInstances);
        return result;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = manualFee();
            getContext().put(WizardConstants.OPER_STATUS, operStatus);
            getContext().put(FEE_TYPE, feeType);
            getContext().put(FEE_AMOUNT, feeAmount);
            getContext().put(ACCOUNT, account);
            getContext().put(CURRENCY, currency);
            getContext().put(PROCESSED, (Boolean) processed);
        }
        return getContext();
    }

    private String manualFee() {
        classLogger.trace("manualFee...");
        Operation operation = new Operation();

        operation.setOperType(ISSUER_FEE);
        operation.setOperReason(feeType);
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        operation.setStatus(operationStatus);
        operation.setSttlType(US_ON_US);
        operation.setOperCount(1L);
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());
        operation.setOperationAmount(new BigDecimal(feeAmount));
        operation.setParticipantType(Participant.ISS_PARTICIPANT);
        operation.setCardInstId(card.getInstId());
        operation.setIssInstId(card.getInstId());
        operation.setCardId(card.getId());
        operation.setCardInstanceId(selectedCardInstance.getId());
        operation.setCardTypeId(card.getCardTypeId());
        operation.setCardNumber(card.getCardNumber());
        operation.setCardMask(card.getMask());
        operation.setCardHash(card.getCardHash());
        operation.setCardExpirationDate(card.getExpDate());
        operation.setCardCountry(card.getCountry());
        operation.setCardSeqNumber(selectedCardInstance.getSeqNumber());
        operation.setSplitHash(selectedCardInstance.getSplitHash());
        operation.setCustomerId(card.getCustomerId());
        operation.setClientIdType(ClientIdentificationTypes.CARD);
        operation.setClientIdValue(card.getCardNumber());
        operation.setOperationCurrency(currency);

        Integer networkId = institutionNetwork(card.getInstId());
        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        boolean skipProcessing = isSkipProcessing || !OperationsConstants.OPERATION_STATUS_PROCESS_READY.equals(operation.getStatus());

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId(), skipProcessing);
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(card);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);

            if (!skipProcessing) {
                classLogger.trace("process manualFee...");
                operation.setStatus(operationDao.processOperation(userSessionId, operation.getId()));
                processed = true;
            }
            return operation.getStatus();
        }
    }

    private Integer institutionNetwork(Integer instId) {
        classLogger.trace("institutionNetwork...");
        Integer result = null;
        SelectionParams sp = SelectionParams.build("instId", instId);
        Institution[] insts = orgStructureDao.getInstitutions(userSessionId, sp, curLang, false);
        if (insts.length != 0) {
            result = insts[0].getNetworkId();
        }
        return result;
    }

    private void reset() {
        classLogger.trace("reset...");
        cardInstancesSelection = null;
        selectedCardInstance = null;
        feeTypes = null;
        feeType = null;
        cardInstances = null;
        feeAmount = null;
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        return checkCardInstance();
    }

    public void setCardInstancesSelection(SimpleSelection cardInstancesSelection) {
        classLogger.trace("setCardInstancesSelection...");
        this.cardInstancesSelection = cardInstancesSelection;
        if (getCardInstances() == null || getCardInstances().size() == 0) return;
        int index = selectedIdx();
        if (index < 0) return;
        CardInstance newCardInstance = getCardInstances().get(index);
        if (!newCardInstance.equals(selectedCardInstance)) {
            selectedCardInstance = newCardInstance;
            checkCardInstance();
        }
    }

    private Integer selectedIdx() {
        Iterator<Object> keys = cardInstancesSelection.getKeys();
        if (!keys.hasNext()) return -1;
        Integer index = (Integer) keys.next();
        return index;
    }

    private boolean checkCardInstance() {
        return !(invalidCardInstance = (selectedCardInstance == null));
    }

    private void prepareFeeTypes() {
        classLogger.trace("prepareFeeTypes...");
        SelectionParams sp = SelectionParams.build("lang", curLang,
                "objectId", card.getId(), "attrEntityType", EntityNames.FEE);
        ProductAttribute[] fees = productDao.getFlatObjectAttributes(userSessionId, sp);
        feeTypes = new LinkedList<SelectItem>();
        for (ProductAttribute fee : fees) {
            SelectItem si = new SelectItem(fee.getAttrObjectType(), fee.getAttrObjectType() + " - " + fee.getLabel());
            feeTypes.add(si);
        }
    }

    public List<SelectItem> getCurrencies() {
        return CurrencyCache.getInstance().getAllCurrencies(curLang);
    }

    public SimpleSelection getCardInstancesSelection() {
        return this.cardInstancesSelection;
    }

    public List<CardInstance> getCardInstances() {
        return cardInstances;
    }

    public void setCardInstances(List<CardInstance> cardInstances) {
        this.cardInstances = cardInstances;
    }

    public CardInstance getSelectedCardInstance() {
        return selectedCardInstance;
    }

    public void setSelectedCardInstance(CardInstance selectedCardInstance) {
        this.selectedCardInstance = selectedCardInstance;
    }

    public String getFeeType() {
        return feeType;
    }

    public void setFeeType(String feeType) {
        this.feeType = feeType;
    }

    public boolean isInvalidCardInstance() {
        return invalidCardInstance;
    }

    public void setInvalidCardInstance(boolean invalidCardInstance) {
        this.invalidCardInstance = invalidCardInstance;
    }

    public List<SelectItem> getFeeTypes() {
        if (feeTypes == null) {
            prepareFeeTypes();
        }
        return feeTypes;
    }

    public void setFeeTypes(List<SelectItem> feeTypes) {
        this.feeTypes = feeTypes;
    }

    public Double getFeeAmount() {
        return feeAmount;
    }

    public void setFeeAmount(Double feeAmount) {
        this.feeAmount = feeAmount == null ? null : Long.valueOf(Math.round(feeAmount)).doubleValue();
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

    public List<SelectItem> getOperationStatuses() {
        if (operationStatuses == null) {
            operationStatuses = getLov(LovConstants.OPERATION_STATUSES);
        }
        return operationStatuses;
    }

    public String getOperationStatus() {
        return operationStatus;
    }

    public void setOperationStatus(String operationStatus) {
        this.operationStatus = operationStatus;
    }

    public boolean isSkipProcessing() {
        return isSkipProcessing;
    }

    public void setSkipProcessing(boolean skipProcessing) {
        isSkipProcessing = skipProcessing;
    }
}

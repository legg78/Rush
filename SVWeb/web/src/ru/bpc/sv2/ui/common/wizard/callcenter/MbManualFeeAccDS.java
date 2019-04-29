package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.ClientIdentificationTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbManualFeeAccDS")
public class MbManualFeeAccDS implements CommonWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbManualFeeAccDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/manualFeeAccDS.jspx";
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
    private CommonDao _commonDao = new CommonDao();

    private UserSession usession;
    private DictUtils dictUtils;
    private Map<String, Object> context;
    private Card card;
    private List<CardInstance> cardInstances;
    private long userSessionId;
    private String curLang;
    private CardInstance selectedCardInstance;
    private String feeType;
    private Integer feeTypeId = null;
    private SimpleSelection cardInstancesSelection;
    private boolean invalidCardInstance;
    private List<SelectItem> feeTypes;
    private List<SelectItem> accounts;
    private Double feeAmount;
    private Account account;
    private Long accountId;
    private Integer rateCount;
    private String currency;
    private String accountCurrency;
    private Long cardId;
    private String entityType;
    private List<SelectItem> operationStatuses;
    private String operationStatus;
    private boolean isSkipProcessing;
    private boolean processed;
    private boolean showDialog = false;
    private boolean inRole = false;

    protected List<Filter> filters;

    public MbManualFeeAccDS() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
        usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
        inRole = usession.getInRole().get(IssuingPrivConstants.MODIFY_FEE_AMOUNT);
    }

    public boolean isShowDialog() {
        classLogger.trace("MbManualFeeAccDS::isShowDialog...");
        if ((this.accountId != null) && (this.currency != null))
            if (this.currency.equals(account.getCurrency()))
                return false;
            else if (checkRates() != 0)
                return true;
        return false;
    }

    public void setShowDialog(boolean showDialog) {
        this.showDialog = showDialog;
    }

    @Override
    public void init(Map<String, Object> context) {
        reset();
        classLogger.trace("init...");
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        isSkipProcessing = false;
        processed = false;
        operationStatus = OperationsConstants.OPERATION_STATUS_PROCESS_READY;

        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        context.put(MbCommonWizard.SHOW_DIALOG, Boolean.TRUE);//check for confirmation messages
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
            String operStatus = manualFeeAcc();
            context.put(WizardConstants.OPER_STATUS, operStatus);
            context.put(FEE_TYPE, feeType);
            context.put(FEE_AMOUNT, feeAmount);
            context.put(ACCOUNT, account);
            context.put(CURRENCY, currency);
            context.put(PROCESSED, (Boolean) processed);
        }
        return context;
    }

    private String manualFeeAcc() {
        classLogger.trace("manualFeeAcc...");
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
        operation.setCardMask(card.getMask());
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

        operation.setAccountId(account.getId());
        operation.setAccountCurrency(account.getCurrency());
        operation.setAccountNumber(account.getAccountNumber());
        operation.setAccountType(account.getAccountType());

        Integer networkId = institutionNetwork(card.getInstId());
        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        operationDao.addAdjusment(userSessionId, operation);

        if (!isSkipProcessing && OperationsConstants.OPERATION_STATUS_PROCESS_READY.equals(operation.getStatus())) {
            classLogger.trace("process manualFeeAcc...");
            operation.setStatus(operationDao.processOperation(userSessionId, operation.getId()));
            processed = true;
        }
        return operation.getStatus();
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
        accounts = null;
        account = null;
        accountId = null;
        accountCurrency = null;
        showDialog = false;
        feeTypeId = null;
        currency = null;
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        if (!checkCardInstance())
            return false;
        else if (!this.currency.equals(account.getCurrency()) && (checkRates() == 0))
            throw new IllegalStateException("Error. Conversion rate between Fee currency and Account currency doesn’t exist.");
        return true;
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
        ProductAttribute[] fees = productDao.getObjectFeeAttrs(userSessionId, sp);
        feeTypes = new LinkedList<SelectItem>();
        for (ProductAttribute fee : fees) {
            SelectItem si = new SelectItem(fee.getAttrObjectType(), fee.getAttrObjectType() + " - " + fee.getLabel());
            feeTypes.add(si);
        }
    }

    private void prepareAccounts() {
        classLogger.trace("prepareAccounts...");
        SelectionParams sp = SelectionParams.build("lang", curLang,
                "objectId", card.getId(),
                "entityType", EntityNames.CARD);
        Account[] accs = accountsDao.getAccountsByObject(userSessionId, sp);
        accounts = new LinkedList<SelectItem>();
        for (Account acc : accs) {
            SelectItem si = new SelectItem(acc.getId(), acc.getAccountNumber());
            accounts.add(si);
        }
    }

    private int checkRates() {
        rateCount = 0;
        try {
            SelectionParams params = new SelectionParams(
                    new Filter("instId", card.getInstId().toString()),
                    new Filter("effDate", new SimpleDateFormat("dd.MM.yyyy").format(new Date())),
                    new Filter("dstCurrency", account.getCurrency()),
                    new Filter("srcCurrency", this.currency));
            rateCount = _commonDao.getRatesCount(userSessionId, params);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            classLogger.error("", e);
        }
        return rateCount;
    }

    public List<SelectItem> getCurrencies() {
        return CurrencyCache.getInstance().getAllCurrencies(curLang);
    }

    public List<SelectItem> getAccountCurrencies() {
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

    public String getFeeTypeName() {
        SelectionParams sp = SelectionParams.build("lang", curLang,
                "objectId", card.getId(), "attrEntityType", EntityNames.FEE);
        ProductAttribute[] fees = productDao.getFlatObjectAttributes(userSessionId, sp);
        for (ProductAttribute fee : fees) {
            if (fee.getAttrObjectType().equals(this.feeType))
                return fee.getSystemName();
        }
        return null;
    }

    public void setFeeType(String feeType) {
        this.feeType = feeType;
        if (feeType != null)
            try {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("result", (Integer) 0);
                params.put("entity_type", EntityNames.CARD);
                params.put("object_id", card.getId());
                params.put("attr_name", getFeeTypeName());
                params.put("inst_id", card.getInstId());
                params.put("use_default_value", (Integer) 1);
                params.put("default_value", (Long) 0L);
                feeTypeId = operationDao.getAttrValueNumber(userSessionId, params);

                SelectionParams sp = SelectionParams.build("lang", curLang,
                        "objectId", card.getId(), "attrEntityType", EntityNames.FEE);
                ProductAttribute[] fees = productDao.getObjectFeeAttrs(userSessionId, sp);
                for (ProductAttribute fee : fees) {
                    if (fee.getAttrObjectType().equals(this.feeType))
                        this.currency = fee.getFeeCurrency();
                }
            } catch (Exception e) {
                //classLogger.error(e.getMessage(), e);
                feeTypeId = null;
            }
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

    public List<SelectItem> getAccounts() {
        if (accounts == null) {
            prepareAccounts();
        }
        return accounts;
    }

    public void setAccounts(List<SelectItem> accounts) {
        this.accounts = accounts;
    }

    private Double DefaultFeeAmount() {
        Double result = null;
        if ((feeType != null) && (feeTypeId > 0) && (currency != null))
            try {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("result", (Integer) 0);
                params.put("fee_id", feeTypeId);
                params.put("base_amount", (Long) 0L);
                params.put("base_currency", currency);
                params.put("entity_type", EntityNames.CARD);
                params.put("object_id", card.getId());
                result = operationDao.getFeeAmount(userSessionId, params);
            } catch (Exception e) {
                //classLogger.error(e.getMessage(), e);
                result = null;
            }
        return result;
    }

    public Double getFeeAmount() {
        feeAmount = DefaultFeeAmount();
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

    public Long getAccountId() {
        return accountId;
    }

    public void setAccountId(Long accountId) {
        this.accountId = accountId;
        if (accountId != null) {
            SelectionParams sp = SelectionParams.build("id", accountId);
            Account[] accs = accountsDao.getAccounts(userSessionId, sp);
            if (accs.length != 0)
                setAccount(accs[0]);
        }
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getAccountCurrency() {
        if (accountId != null)
            return account.getCurrency();
        else
            return null;
    }

    public void next() {
        classLogger.trace("MbManualFeeAccDS::next...");
        MbCommonWizard bean = (MbCommonWizard)ManagedBeanWrapper.getManagedBean("MbCommonWizard");
        bean.next();
    }

    public List<SelectItem> getOperationStatuses() {
        if (operationStatuses == null) {
            DictUtils utils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
            operationStatuses = utils.getLov(LovConstants.OPERATION_STATUSES);
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

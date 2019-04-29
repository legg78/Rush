package ru.bpc.sv2.ui.common.wizard.callcenter.card;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.Currency;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbCardOperationDS")
public class MbCardOperationDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbCardOperationDS.class);
    protected String PAGE = "/pages/common/wizard/callcenter/card/cardOperationDS.jspx";

    private transient DictUtils dictUtils;

    private List<SelectItem> operTypes = null;
    private List<SelectItem> currencies = null;
    private Map<String, Integer> exponents = null;

    private String operType;
    private String operReason;
    private String operCurrency;
    protected BigDecimal operAmount;

    private Card card;
    private List<CardInstance> cardInstances;
    private List<SelectItem> operReasons;
    protected Date operDate;
    protected Date bookDate;
    protected Date invoiceDate;

    private boolean invalidCardInstance;

    private SimpleSelection cardInstancesSelection;
    private CardInstance selectedCardInstance;
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String CURRENCY = "CURRENCY";
    private static final String OPER_TYPE = "OPER_TYPE";

    private CommonDao _commonDao = new CommonDao();
    private IssuingDao issuingDao = new IssuingDao();
    private OperationDao operationDao = new OperationDao();
    private OrgStructDao orgStructureDao = new OrgStructDao();
    private IntegrationDao integrationDao = new IntegrationDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);
        reset();
        Long cardId = getContextRequired(OBJECT_ID);
        card = retriveCard(cardId);
        cardInstances = retriveCardInstances(card);
        String newOperType = (String) context.get(MbCommonWizard.OPER_TYPE);
        if (operType == null || newOperType == null || !operType.equals(newOperType)) {
            operReasons = null;
        }
        operType = newOperType;

        operDate = new Date();
        bookDate = new Date();
        try {
            invoiceDate = integrationDao.getInvoiceDate(userSessionId, "ENTTCARD", cardId);
        } catch (UserException e) {
            classLogger.trace("Cannot get last invoice date, set date as null");
            invoiceDate = null;
        }
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = cardOperation();
            putContext(WizardConstants.OPER_STATUS, operStatus);
            putContext(OPER_TYPE, operType);
            putContext(CURRENCY, operCurrency);
        }
        return getContext();
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

    private List<CardInstance> retriveCardInstances(Card card) {
        classLogger.trace("MbChangeCardStatusData::retriveCardInstances...");
        List<CardInstance> result;
        SelectionParams sp = SelectionParams.build("cardId", card.getId(), "lang", curLang);
        sp.setRowIndexEnd(Integer.MAX_VALUE);
        CardInstance[] cardInstances = issuingDao.getCardInstances(userSessionId, sp);
        result = Arrays.asList(cardInstances);
        return result;
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
        return keys.hasNext() ? (Integer) keys.next() : -1;
    }

    private boolean checkCardInstance() {
        return !(invalidCardInstance = (selectedCardInstance == null));
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

    private String cardOperation() {
        classLogger.trace("accountOperation...");
        Operation operation = new Operation();
        operation.setOperType(operType);
        operation.setOperReason(operReason);
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        operation.setStatus("OPST0100");
        operation.setSttlType("STTT0010");
        operation.setOperCount(1L);
        operation.setOperationDate(operDate);
        operation.setSourceHostDate(bookDate);
        operation.setOperationAmount(operAmount);
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
        operation.setClientIdType("CITPCARD");
        operation.setClientIdValue(card.getCardNumber());
        operation.setOperationCurrency(operCurrency);

        Integer networkId = institutionNetwork(card.getInstId());
        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(card);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            return operationDao.processOperation(userSessionId, operation.getId());
        }
    }

    public boolean isOperationDateValid() {
        if (operDate != null && bookDate != null) {
            if (bookDate.getTime() >= operDate.getTime()) {
                if (invoiceDate == null) {
                    return true;
                } else if (operDate.getTime() >= invoiceDate.getTime()) {
                    return true;
                } else {
                    FacesUtils.addMessageError("Operation date cannot be less than last invoice date");
                }
            } else {
                FacesUtils.addMessageError("Operation date cannot be greater than booking date");
            }
        } else {
            FacesUtils.addMessageError("Operation date cannot be empty");
        }
        return false;
    }

    @Override
    public boolean validate() {
        classLogger.trace("validate...");
        return isOperationDateValid() && checkCardInstance();
    }

    public List<SelectItem> getOperTypes() {
        if (operTypes == null) {
            operTypes = getDictUtils().getLov(LovConstants.OPERATION_TYPE);
        }
        return operTypes;
    }

    public List<SelectItem> getOperReasons() {
        if (operReasons == null) {
            updateOperReasons();
        }
        return operReasons;
    }

    public void updateOperReasons() {
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("oper_type", operType);
        operReasons = getDictUtils().getLov(LovConstants.OPER_REASON, params);
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public List<SelectItem> getCurrencies() {
        if (currencies == null) {
            currencies = new ArrayList<SelectItem>();
            exponents = new HashMap<String, Integer>();
            SelectionParams params = new SelectionParams(new Filter("lang", curLang));
            params.setRowIndexStart(0);
            params.setRowIndexEnd(Integer.MAX_VALUE);
            Currency[] currs = _commonDao.getCurrencies(userSessionId, params);
            for (Currency curr : currs) {
                currencies.add(new SelectItem(curr.getCode(), curr.getName() + " " + curr.getCurrencyName()));
                exponents.put(curr.getCode(), curr.getExponent());
            }
        }
        return currencies;
    }

    public Integer getExponent() {
        if (operCurrency == null || exponents == null || exponents.get(operCurrency) == null) {
            return 0;
        }
        return exponents.get(operCurrency);
    }

    private void reset() {
        operType = null;
        operCurrency = null;
        operAmount = null;
        cardInstancesSelection = null;
    }

    public String getOperType() {
        return operType;
    }

    public void setOperType(String operType) {
        this.operType = operType;
    }

    public String getOperCurrency() {
        return operCurrency;
    }

    public void setOperCurrency(String operCurrency) {
        this.operCurrency = operCurrency;
    }

    public BigDecimal getOperAmount() {
        return operAmount;
    }

    public void setOperAmount(BigDecimal operAmount) {
        this.operAmount = operAmount;
    }

    public String getOperReason() {
        return operReason;
    }

    public void setOperReason(String operReason) {
        this.operReason = operReason;
    }

    public boolean isInvalidCardInstance() {
        return invalidCardInstance;
    }

    public void setInvalidCardInstance(boolean invalidCardInstance) {
        this.invalidCardInstance = invalidCardInstance;
    }

    public boolean isShowOperType() {
        return getContext(MbCommonWizard.OPER_TYPE) == null;
    }

    public Date getOperDate() {
        return operDate;
    }

    public void setOperDate(Date operDate) {
        this.operDate = operDate;
    }

    public Date getBookDate() {
        return bookDate;
    }

    public void setBookDate(Date bookDate) {
        this.bookDate = bookDate;
    }
}

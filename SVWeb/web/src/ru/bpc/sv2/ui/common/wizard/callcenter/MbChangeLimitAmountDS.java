package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.AttributeValue;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbChangeLimitAmountDS")
public class MbChangeLimitAmountDS extends AbstractWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbChangeLimitAmountDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/changeLimitAmountDS.jspx";
    private static final String LIMIT_TYPE = "LIMIT_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String CURRENCY = "CURRENCY";


    private IssuingDao issuingDao = new IssuingDao();

    private OrgStructDao orgStructureDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private AccountsDao accountsDao = new AccountsDao();

    private ProductsDao productsDao = new ProductsDao();

    private LimitsDao limitsDao = new LimitsDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private Card card;
    private List<CardInstance> cardInstances;
    private SimpleSelection cardInstancesSelection;
    private CardInstance selectedCardInstance;
    private Boolean invalidCardInstance;
    private List<SelectItem> limitTypes;
    private String limitType;
    private AttributeValue limitAttr;
    private Limit limit;
    private BigDecimal limitAmount;
    private Long limitCount;
    private Long cardId;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        reset();
        classLogger.trace("MbChangeCardStatusData::init...");

        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        card = retriveCard(cardId);
        cardInstances = retriveCardInstances(card);
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

    private void reset() {
        cardInstancesSelection = null;
        selectedCardInstance = null;
        limitTypes = null;
        limitType = null;
        limitAttr = null;
        limit = null;
        limitAmount = null;
        limitCount = null;
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
        if (direction == Direction.FORWARD) {
            String operStatus = changeLimitAmount();
            getContext().put(WizardConstants.OPER_STATUS, operStatus);
            getContext().put(LIMIT_TYPE, limitType);
            getContext().put(OBJECT_ID, card.getId());
            getContext().put(ENTITY_TYPE, EntityNames.CARD);
            getContext().put(CURRENCY, limit.getCurrency());
        }
        return getContext();
    }

    private String changeLimitAmount() {
        classLogger.trace("changeCardStatus...");
        Operation operation = new Operation();
        operation.setOperType("OPTP0403");
        operation.setOperReason(limitType);
        operation.setMsgType("MSGTPRES");
        operation.setStatus("OPST0100");
        operation.setSttlType("STTT0010");
        operation.setOperCount(1L);
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());
        operation.setParticipantType("PRTYISS");
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
        operation.setOperationCurrency(limit.getCurrency());

        if (limitCount == null) {
            operation.setOperCount(-1L);
        } else {
            operation.setOperCount(limitCount);
        }
        if (limitAmount == null) {
            operation.setOperationAmount(new BigDecimal(-1));
        } else {
            operation.setOperationAmount(limitAmount);
        }

        Integer networkId = institutionNetwork(card.getInstId());

        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId());
            builder.buildFromOperation(operation, false);
            builder.createApplicationInDB();
            builder.addApplicationObject(card);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            return operationDao.processOperation(userSessionId, operation.getId());
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

    @Override
    public boolean validate() {
        return checkCardInstance();
    }

    private boolean checkCardInstance() {
        return !(invalidCardInstance = (selectedCardInstance == null));
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

    public SimpleSelection getCardInstancesSelection() {
        return this.cardInstancesSelection;
    }

    private Integer selectedIdx() {
        Iterator<Object> keys = cardInstancesSelection.getKeys();
        if (!keys.hasNext()) return -1;
        Integer index = (Integer) keys.next();
        return index;
    }

    public List<SelectItem> getLimitTypes() {
        if (limitTypes == null) {
            prepareLimitTypes();
        }
        return limitTypes;
    }

    private void prepareLimitTypes() {
        SelectionParams sp = SelectionParams.build("lang", curLang
                , "productId", card.getProductId(), "objectId", card.getId()
                , "attrEntityType", EntityNames.LIMIT);
        ProductAttribute[] definedAttrs = productsDao.getDefinedAttrs(userSessionId, sp);
        limitTypes = new LinkedList<SelectItem>();
        for (ProductAttribute definedAttr : definedAttrs) {
            SelectItem si = new SelectItem(definedAttr.getAttrObjectType(), definedAttr.getAttrObjectType() + " - " + definedAttr.getLabel());
            limitTypes.add(si);
        }
    }

    private void updateLimitAttr() {
        classLogger.trace("updateLimitAttr...");
        SelectionParams sp = SelectionParams.build("objectId", card.getId()
                , "entityType", EntityNames.CARD
                , "attrObjectType", limitType
                , "lang", curLang
        );
        ProductAttribute[] attributes = productsDao.getFlatObjectAttributes(userSessionId, sp);
        ProductAttribute attr = null;
        if (attributes.length > 0) {
            attr = attributes[0];
        }
        if (attr == null) {
            limitAttr = null;
            return;
        }
        SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
        sp = SelectionParams.build("objectId", card.getId()
                , "entityType", EntityNames.CARD
                , "effDate", df.format(new Date())
                , "attributeId", attributes[0].getId()
                , "attrObjectType", limitType);
        sp.setSortElement(new SortElement("levelPriority", SortElement.Direction.ASC), new SortElement("startDate", SortElement.Direction.DESC));
        AttributeValue[] attrValues = productsDao.getMixedAttrValues(userSessionId, sp);
        if (attrValues.length > 0) {
            limitAttr = attrValues[0];
        }
    }

    private void updateLimit() {
        classLogger.trace("updateCurrentLimitAmount...");
        if (limitAttr == null) {
            ;
            limit = null;
            return;
        }

        limit = limitsDao.getLimitById(userSessionId, limitAttr.getValueN().longValue());
        if (limit.getSumLimit().equals(new BigDecimal(-1))) {
            limit.setSumLimit(null);
        }
        if (limit.getCountLimit() == -1) {
            limit.setCountLimit(null);
        }
    }

    public Boolean getInvalidCardInstance() {
        return invalidCardInstance;
    }

    public void setInvalidCardInstance(Boolean invalidCardInstance) {
        this.invalidCardInstance = invalidCardInstance;
    }

    public String getLimitType() {
        return limitType;
    }

    public void setLimitType(String limitType) {
        classLogger.trace("setLimitType...");
        if (limitType != null && !limitType.equals(this.limitType)) {
            this.limitType = limitType;
            updateLimitAttr();
            updateLimit();
        }
    }

    public List<CardInstance> getCardInstances() {
        return cardInstances;
    }

    public void setCardInstances(List<CardInstance> cardInstances) {
        this.cardInstances = cardInstances;
    }

    public AttributeValue getLimitAttr() {
        return limitAttr;
    }

    public void setLimitAttr(AttributeValue limitAttr) {
        this.limitAttr = limitAttr;
    }

    public Limit getLimit() {
        return limit;
    }

    public void setLimit(Limit limit) {
        this.limit = limit;
    }

    public BigDecimal getLimitAmount() {
        return limitAmount;
    }

    public void setLimitAmount(BigDecimal limitAmount) {
        this.limitAmount = limitAmount;
    }

    public Long getLimitCount() {
        return limitCount;
    }

    public void setLimitCount(Long limitCount) {
        this.limitCount = limitCount;
    }

}

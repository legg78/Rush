package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbResetPinCounterDataStep")
public class MbResetPinCounterDataStep implements CommonWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbResetPinCounterDataStep.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/resetPinCounterDataStep.jspx";
    private static final String INSTANCE = "INSTANCE";
    private static final String OBJECT_ID = "OBJECT_ID";

    private IssuingDao issuingDao = new IssuingDao();

    private OperationDao operationDao = new OperationDao();

    private OrgStructDao orgStructureDao = new OrgStructDao();

    private long userSessionId;
    private String curLang;
    private DictUtils dictUtils;
    private Map<String, Object> context;
    private Card card;
    private List<CardInstance> cardInstances;
    private SimpleSelection cardInstancesSelection;
    private CardInstance selectedCardInstance;
    private List<SelectItem> reasons;
    private String reason;
    private boolean invalidCardInstance;
    private Long cardId;

    public MbResetPinCounterDataStep() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
    }

    @Override
    public void init(Map<String, Object> context) {
        classLogger.trace("init...");
        reset();
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException("CARD is not defined in wizard context");
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

    private List<CardInstance> retriveCardInstances(Card card) {
        classLogger.trace("retriveCardInstances...");
        List<CardInstance> result;
        SelectionParams sp = SelectionParams.build(
                "cardId", card.getId()
                , "lang", curLang
                , "status", "CSTS0013");
        CardInstance[] cardInstances = issuingDao.getCardInstances(userSessionId, sp);
        result = Arrays.asList(cardInstances);
        return result;
    }

    private void reset() {
        classLogger.trace("reset...");
        cardInstancesSelection = null;
        setSelectedCardInstance(null);
        reasons = null;
        reason = null;
    }

    public void setCardInstancesSelection(SimpleSelection cardInstancesSelection) {
        classLogger.trace("setCardInstancesSelection...");
        this.cardInstancesSelection = cardInstancesSelection;
        if (cardInstances == null || cardInstances.size() == 0) return;
        int index = selectedIdx();
        if (index < 0) return;
        CardInstance newCardInstance = cardInstances.get(index);
        if (!newCardInstance.equals(getSelectedCardInstance())) {
            setSelectedCardInstance(newCardInstance);
            checkCardInstance();
        }
    }

    private boolean checkCardInstance() {
        return !(invalidCardInstance = selectedCardInstance == null);
    }

    public SimpleSelection getCardInstancesSelection() {
        return cardInstancesSelection;
    }

    private Integer selectedIdx() {
        Iterator<Object> keys = cardInstancesSelection.getKeys();
        if (!keys.hasNext()) return -1;
        Integer index = (Integer) keys.next();
        return index;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = resetPinCounter();
            CardInstance cardInstance = actualCardInstance(getSelectedCardInstance());
            context.put(INSTANCE, cardInstance);
            context.put(WizardConstants.OPER_STATUS, operStatus);
        }
        return context;
    }

    private String resetPinCounter() {
        classLogger.trace("resetPinCounter...");
        Operation operation = new Operation();
        operation.setOperType("OPTP0071");
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
        operation.setOperReason("EVNT0164");

        Integer networkId = institutionNetwork(card.getInstId());

        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        operationDao.addAdjusment(userSessionId, operation);

        String operStatus = operationDao.processOperation(userSessionId, operation.getId());
        return operStatus;
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

    private CardInstance actualCardInstance(CardInstance cardInstance) {
        classLogger.trace("actualCardInstance...");
        CardInstance result = null;
        if (cardInstance == null) return result;
        SelectionParams sp = SelectionParams.build("id", cardInstance.getId(), "lang", curLang);
        CardInstance[] cardInstances = issuingDao.getCardInstances(userSessionId, sp);
        if (cardInstances.length == 0) return result;
        result = cardInstances[0];
        return result;
    }

    @Override
    public boolean validate() {
        return checkCardInstance();
    }

    public List<SelectItem> getReasons() {
        if (reasons == null) {
            reasons = dictUtils.getLov(LovConstants.PIN_COUNTER_RESET_REASONS);
        }
        return reasons;
    }

    public List<CardInstance> getCardInstances() {
        return cardInstances;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public CardInstance getSelectedCardInstance() {
        return selectedCardInstance;
    }

    public void setSelectedCardInstance(CardInstance selectedCardInstance) {
        this.selectedCardInstance = selectedCardInstance;
    }

    public boolean isInvalidCardInstance() {
        return invalidCardInstance;
    }

    public void setInvalidCardInstance(boolean invalidCardInstance) {
        this.invalidCardInstance = invalidCardInstance;
    }
}

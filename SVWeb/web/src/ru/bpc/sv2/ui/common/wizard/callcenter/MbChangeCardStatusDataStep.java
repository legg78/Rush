package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.evt.StatusMap;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbChangeCardStatusDataStep")
public class MbChangeCardStatusDataStep extends AbstractWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbChangeCardStatusDataStep.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/changeCardStatusDataStep.jspx";
    private static final String INSTANCE = "INSTANCE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String CLIENT = "ENSICLNT";
    private static final String OPERATOR = "ENSIOPER";

    private IssuingDao issuingDao = new IssuingDao();

    private EventsDao eventsDao = new EventsDao();

    private OrgStructDao orgStructureDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private Card card;
    private List<CardInstance> cardInstances;
    private SimpleSelection cardInstancesSelection;
    private CardInstance selectedCardInstance;
    private DictUtils dictUtils;
    private List<SelectItem> initiators;
    private List<SelectItem> newStatuses;
    private String newStatus;
    private List<SelectItem> reasons;
    private String reason;
    private Boolean invalidCardInstance;
    private Long cardId;
    private String entityType;
    private String initiator;


    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        reset();
        classLogger.trace("MbChangeCardStatusData::init...");
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        initiator = null;
        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (EntityNames.CARD.equals(entityType)) {
            card = retriveCard(cardId);
            cardInstances = retriveCardInstances(card);
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

    private void reset() {
        reasons = null;
        initiator = null;
        newStatuses = null;
        initiators = null;
        cardInstancesSelection = null;
        selectedCardInstance = null;
        newStatus = null;
        reason = null;
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

    private CardInstance actualCardInstance(CardInstance cardInstance) {
        classLogger.trace("actualCardInstance...");
        CardInstance result = null;
        SelectionParams sp = SelectionParams.build("id", cardInstance.getId(), "lang", curLang);
        CardInstance[] cardInstances = issuingDao.getCardInstances(userSessionId, sp);
        if (cardInstances.length == 0) return result;
        result = cardInstances[0];
        return result;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD) {
            if (EntityNames.CARD.equals(entityType)) {
                String operStatus = changeCardStatus();
                if (!isMaker()) {
                    CardInstance cardInstance = actualCardInstance(selectedCardInstance);
                    getContext().put(INSTANCE, cardInstance);
                }
                getContext().put(WizardConstants.OPER_STATUS, operStatus);
            }
        }
        return getContext();
    }

    private String changeCardStatus() {
        classLogger.trace("changeCardStatus...");
        Operation operation = new Operation();
        operation.setOperType("OPTP0171");
        operation.setOperReason(reason);
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
        operation.setCardExpirationDate(selectedCardInstance.getExpirDate());
        operation.setCardCountry(card.getCountry());
        operation.setCardSeqNumber(selectedCardInstance.getSeqNumber());
        operation.setSplitHash(selectedCardInstance.getSplitHash());
        operation.setCustomerId(card.getCustomerId());
        operation.setClientIdType("CITPCARD");
        operation.setClientIdValue(card.getCardNumber());
        operation.setCardSeqNumber(selectedCardInstance.getSeqNumber());

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
            Map<String, Object> paramsTab = new HashMap<String, Object>();
            paramsTab.put("INITIATOR", initiator);
            return operationDao.processOperation(userSessionId, operation.getId(), paramsTab);
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
        return !(invalidCardInstance = selectedCardInstance == null);
    }

    private Integer selectedIdx() {
        Iterator<Object> keys = cardInstancesSelection.getKeys();
        if (!keys.hasNext()) return -1;
        Integer index = (Integer) keys.next();
        return index;
    }

    public List<SelectItem> getNewStatuses() {
        if (newStatuses == null && initiator != null) {
            updateNewStatuses();
        }
        return newStatuses;
    }

    private void updateNewStatuses() {
        classLogger.trace("updateNewStatuses...");
        newStatuses = new ArrayList<SelectItem>();
        if (selectedCardInstance == null) return;

        List<Filter> filters = new ArrayList<Filter>();
        if (initiator != null) {
            filters.add(new Filter("initiator", initiator));
        }
        filters.add(new Filter("initialStatus", selectedCardInstance.getStatus()));
        if (reason != null && !reason.trim().isEmpty()) {
            filters.add(new Filter("eventType", reason));
        }
        SelectionParams sp = new SelectionParams(filters);

        StatusMap[] statusMaps = eventsDao.getStatusMaps(userSessionId, sp);
        HashSet<String> statusSet = new HashSet<String>();
        for (StatusMap statusMap : statusMaps) {
            String status = statusMap.getResultStatus();
            if (!statusSet.contains(status)) {
                statusSet.add(status);
            } else {
                continue;
            }
            newStatuses.add(new SelectItem(status, status + " - " + statusMap.getResultStatusText()));
        }
    }

    public List<SelectItem> getReasons() {
        if (reasons == null && initiator != null) {
            updateReasons();
        }
        return reasons;
    }

    private void updateReasons() {
        classLogger.trace("updateReasons...");
        reasons = new ArrayList<SelectItem>();
        if (selectedCardInstance == null) return;

        List<Filter> filters = new ArrayList<Filter>();
        if (initiator != null) {
            filters.add(new Filter("initiator", initiator));
        }
        filters.add(new Filter("initialStatus", selectedCardInstance.getStatus()));
        if (newStatus != null && !newStatus.trim().isEmpty()) {
            filters.add(new Filter("resultStatus", newStatus));
        }
        SelectionParams sp = new SelectionParams(filters);

        StatusMap[] statusMaps = eventsDao.getStatusMaps(userSessionId, sp);
        HashSet<String> eventsSet = new HashSet<String>();
        for (StatusMap statusMap : statusMaps) {
            String event = statusMap.getEventType();
            if (!eventsSet.contains(statusMap)) {
                eventsSet.add(event);
            } else {
                continue;
            }
            reasons.add(new SelectItem(event, event + " - " + statusMap.getEventTypeText()));
        }
    }

    public Card getCard() {
        return card;
    }

    public void setCard(Card card) {
        this.card = card;
    }

    public List<CardInstance> getCardInstances() {
        return cardInstances;
    }

    public void setCardInstances(List<CardInstance> cardInstances) {
        this.cardInstances = cardInstances;
    }

    public SimpleSelection getCardInstancesSelection() {
        if (cardInstancesSelection == null && cardInstances != null && cardInstances.size() != 0) {
            classLogger.debug("An instance is not selected. Preparing a new selection...");
            selectedCardInstance = cardInstances.get(0);
            cardInstancesSelection = new SimpleSelection();
            cardInstancesSelection.addKey(0);
        }
        return cardInstancesSelection;
    }

    public void setCardInstancesSelection(SimpleSelection cardInstancesSelection) {
        classLogger.trace("setCardInstancesSelection...");
        this.cardInstancesSelection = cardInstancesSelection;
        if (cardInstances == null || cardInstances.size() == 0) return;
        int index = selectedIdx();
        if (index < 0) return;
        CardInstance newCardInstance = cardInstances.get(index);
        if (!newCardInstance.equals(selectedCardInstance)) {
            selectedCardInstance = newCardInstance;
            checkCardInstance();
            updateNewStatuses();
        }
    }

    public List<SelectItem> getInitiators() {
        if (initiators == null) {
            initiators = new ArrayList<SelectItem>(2);
            initiators.add(new SelectItem(CLIENT, dictUtils.getArticles().get(CLIENT)));
            initiators.add(new SelectItem(OPERATOR, dictUtils.getArticles().get(OPERATOR)));
        }
        return initiators;
    }

    public String getNewStatus() {
        return newStatus;
    }

    public void setNewStatus(String newStatus) {
        classLogger.trace("setNewStatus...");
        if (newStatus == null) return;
        if (!newStatus.equals(this.newStatus)) {
            this.newStatus = newStatus;
            updateReasons();
        }
        this.newStatus = newStatus;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public Boolean getInvalidCardInstance() {
        return invalidCardInstance;
    }

    public void setInvalidCardInstance(Boolean invalidCardInstance) {
        this.invalidCardInstance = invalidCardInstance;
    }

    public void setInitiator(String initiator) {
        this.initiator = initiator;
    }

    public String getInitiator() {
        return initiator;
    }

    public void updateStatusesAndReason() {
        if (initiator == null) {
            newStatuses = new ArrayList<SelectItem>();
            reasons = new ArrayList<SelectItem>();
        } else {
            updateNewStatuses();
            updateReasons();
        }
    }
}

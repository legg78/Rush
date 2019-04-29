package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.*;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.process.btrt.BTRTMapping;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.svng.AupTag;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

/**
 * Step "Service selection" for operation "Attach service". In theory, this step must process all the service types.
 * But now, it process only "SMS notification" service.
 */
@ViewScoped
@ManagedBean(name = "MbSrvSelectionStep")
public class MbSrvSelectionStep extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbSrvSelectionStep.class);
    private static final String PAGE_CARD = "/pages/common/wizard/callcenter/services/srvSelectionStep.jspx";
    private static final String MOBILE_PHONE = "MOBILE_PHONE";
    private static final Long CARD_NOTIFY_SRV = 10002000L;
    private static final String OBJECT_ID = "OBJECT_ID";

    private PaymentOrdersDao pmoDao = new PaymentOrdersDao();
    private CommonDao commonDao = new CommonDao();
    private OrgStructDao orgStructDao = new OrgStructDao();
    private OperationDao operationDao = new OperationDao();
    private ProductsDao productsDao = new ProductsDao();
    private IssuingDao issuingDao = new IssuingDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    private List<SelectItem> services;
    private Long serviceId;
    private String servicePage;
    private String currentPhoneNumber;
    private String newPhoneNumber;
    private Card card;
    private Long cardId;
    private boolean usingCustomEvent;


    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE_CARD);

        logger.trace("init...");
        reset();

        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        card = retriveCard(cardId);
        updateServicePage();
        prepareServices();
    }

    private Card retriveCard(Long cardId) {
        logger.trace("retriveCard...");
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
        serviceId = null;
        services = null;
        currentPhoneNumber = null;
        newPhoneNumber = null;
    }

    private void prepareServices() {
        logger.trace("prepareServices...");
        SelectionParams sp = SelectionParams.build("productId", card.getProductId(), "serviceTypeId", CARD_NOTIFY_SRV
                , "lang", curLang);
        sp.setRowIndexEnd(99);
        Service[] srvEntities = productsDao.getServices(userSessionId, sp);
        services = new ArrayList<SelectItem>();
        for (Service srvEntity : srvEntities) {
            SelectItem pa = new SelectItem(srvEntity.getServiceTypeId(), srvEntity.getLabel());
            services.add(pa);
        }
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            if (CARD_NOTIFY_SRV.equals(serviceId)) {
                String operStatus = attachServiceSms();
                findCurrentMobilePhone();
                getContext().put(WizardConstants.OPER_STATUS, operStatus);
                getContext().put(MOBILE_PHONE, newPhoneNumber);
                List<CommonWizardStepInfo> steps = (List<CommonWizardStepInfo>) getContext().get(MbCommonWizard.STEPS);
                int idx = steps.size() - 1;
                CommonWizardStepInfo si = new CommonWizardStepInfo();
                si.setSource(MbSmsAttachRS.class.getSimpleName());
                si.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "result"));
                steps.set(idx, si);
                getContext().put(MbCommonWizard.STEPS_CHANGED, Boolean.TRUE);
            }
        }
        return getContext();
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        throw new UnsupportedOperationException();
    }

    private void updateServicePage() {
        servicePage = SystemConstants.EMPTY_PAGE;
        if (serviceId == null) {
            return;
        }
        if (CARD_NOTIFY_SRV.equals(serviceId)) {
            servicePage = "/pages/common/wizard/callcenter/services/smsService.jspx";
            findCurrentMobilePhone();
        }
    }

    private void findCurrentMobilePhone() {
        logger.trace("findCurrentMobilePhone...");
        SelectionParams sp = SelectionParams.build("objectId", card.getCardholderId()
                , "entityType", EntityNames.CARDHOLDER
                , "contactType", "CNTTNTFC");
        Contact[] contacts = commonDao.getContacts(userSessionId, sp, curLang);
        if (contacts.length < 1) {
            return;
        }
        Contact contact = contacts[0];
        sp = SelectionParams.build("contactId", contact.getId()
                , "type", "CMNM0001"
                , "activeOnly", contact.getInstId());
        ContactData[] contactDatas = commonDao.getContactDatas(userSessionId, sp);
        if (contactDatas.length < 1) {
            return;
        }
        currentPhoneNumber = contactDatas[0].getAddress();
    }

    private String attachServiceSms() {
        logger.trace("attachServiceSms...");

        Operation operation = new Operation();
        operation.setOperType("OPTP0173");
        operation.setOperReason(serviceId.toString());
        operation.setMsgType(OperationsConstants.MESSAGE_TYPE_PRESENTMENT);
        operation.setStatus(OperationsConstants.OPERATION_STATUS_PROCESS_READY);
        operation.setSttlType(WizardConstants.US_ON_US);
        operation.setOperCount(1L);
        operation.setOperationDate(new Date());
        operation.setSourceHostDate(new Date());

        operation.setParticipantType(Participant.ISS_PARTICIPANT);
        operation.setCardInstId(card.getInstId());
        operation.setIssInstId(card.getInstId());
        operation.setCardId(card.getId());
        operation.setCardTypeId(card.getCardTypeId());
        operation.setCardNumber(card.getCardNumber());
        operation.setCardMask(card.getMask());
        operation.setCardHash(card.getCardHash());
        operation.setCardExpirationDate(card.getExpDate());
        operation.setCardCountry(card.getCountry());
        operation.setCustomerId(card.getCustomerId());

        Integer networkId = orgStructDao.getNetworkIdByInstId(userSessionId, card.getInstId(), curLang);
        operation.setIssNetworkId(networkId);
        operation.setCardNetworkId(networkId);

        List<AupTag> tags = new ArrayList<>();
        tags.add(new AupTag(BTRTMapping.MOBILE_PHONE.getCode(), newPhoneNumber));
	    tags.add(new AupTag(BTRTMapping.USING_CUSTOM_EVENTS.getCode(), usingCustomEvent ? "1" : "0"));
	    tags.add(new AupTag(BTRTMapping.SERVICE_TYPE.getCode(), "SRVT0007"));

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            builder.addAupTags(tags);
            builder.createApplicationInDB();
            builder.addApplicationObject(card);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            operationDao.addAupTags(userSessionId, tags, operation.getId());
            return operationDao.processOperation(userSessionId, operation.getId());
        }
    }

    public List<SelectItem> getServices() {
        return services;
    }

    public Long getServiceId() {
        return serviceId;
    }

    public void setServiceId(Long serviceId) {
        logger.trace("setServiceId...");
        if (serviceId != null && !serviceId.equals(this.serviceId)) {
            this.serviceId = serviceId;
            updateServicePage();
        }
    }

    public String getServicePage() {
        return servicePage;
    }

    public void setServicePage(String servicePage) {
        this.servicePage = servicePage;
    }

    public String getCurrentPhoneNumber() {
        return currentPhoneNumber;
    }

    public void setCurrentPhoneNumber(String currentPhoneNumber) {
        this.currentPhoneNumber = currentPhoneNumber;
    }

    public String getNewPhoneNumber() {
        return newPhoneNumber;
    }

    public void setNewPhoneNumber(String newPhoneNumber) {
        this.newPhoneNumber = newPhoneNumber;
    }

    public boolean getUsingCustomEvent() {
        return usingCustomEvent;
    }

    public void setUsingCustomEvent(boolean usingCustomEvent) {
        this.usingCustomEvent = usingCustomEvent;
    }
}

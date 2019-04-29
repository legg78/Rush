package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbDetachServiceDS")
public class MbDetachServiceDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger(MbSrvSelectionStep.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/services/detachServiceDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";

    private ProductsDao productsDao = new ProductsDao();

    private OrgStructDao orgStructDao = new OrgStructDao();

    private OperationDao operationDao = new OperationDao();

    private IssuingDao issuingDao = new IssuingDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private Card card;
    private List<SelectItem> services;
    private Long serviceId;
    private Long cardId;
    private static final Long CARD_NOTIFY_SRV = 10002000L;

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE);
        logger.trace("init...");
        reset();
        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        card = retriveCard(cardId);
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

    private void prepareServices() {
        logger.trace("prepareServices...");
        SelectionParams sp = SelectionParams.build("productId", card.getProductId(), "serviceTypeId", CARD_NOTIFY_SRV, "lang", curLang);
        sp.setRowIndexEnd(99);
        Service[] srvEntities = productsDao.getServices(userSessionId, sp);
        services = new ArrayList<SelectItem>();
        for (Service srvEntity : srvEntities) {
            SelectItem pa = new SelectItem(srvEntity.getId(),
                    srvEntity.getLabel());
            services.add(pa);
        }
    }

    private void reset() {
        logger.trace("reset...");
        serviceId = null;
        services = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            String operStatus = detachService();
            getContext().put(WizardConstants.OPER_STATUS, operStatus);
        }
        return getContext();
    }

    private String detachService() {
        logger.trace("detachService...");
        Operation operation = new Operation();
        operation.setOperType("OPTP0174");
        operation.setOperReason(serviceId.toString());
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

        if (isMaker()) {
            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId());
            builder.buildFromOperation(operation, true);
            builder.createApplicationInDB();
            builder.addApplicationObject(card);
            return builder.getApplication().getStatus();
        } else {
            operationDao.addAdjusment(userSessionId, operation);
            String operStatus = operationDao.processOperation(userSessionId, operation.getId());
            return operStatus;
        }
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        throw new UnsupportedOperationException();
    }

    public Long getServiceId() {
        return serviceId;
    }

    public void setServiceId(Long serviceId) {
        this.serviceId = serviceId;
    }

    public List<SelectItem> getServices() {
        return services;
    }

    public void setServices(List<SelectItem> services) {
        this.services = services;
    }

}

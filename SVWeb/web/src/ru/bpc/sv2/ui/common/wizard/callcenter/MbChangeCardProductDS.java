package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.wizard.WizardPrivConstants;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbChangeCardProductDS")
public class MbChangeCardProductDS extends AbstractWizardStep {

    protected static final Logger logger = Logger.getLogger("COMMON");
    private static final String PAGE = "/pages/common/wizard/callcenter/changeCardProductDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String DETAILS_SUB_PAGE = "./issCardDetailsTemplate.jspx";

    private IssuingDao issuingDao = new IssuingDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private List<SelectItem> issuingProducts;

    private Integer newCardProductId;

    private Card card;
    private Long cardId;
    private String entityType;

    private Application createdApp;

    public MbChangeCardProductDS() {
        setFlowId(ApplicationFlows.CHANGE_CONTRACT);
        setMakerCheckerMode(WizardPrivConstants.CHANGE_CARD_PRODUCT_REQUEST, WizardPrivConstants.CHANGE_CARD_PRODUCT);
        setMakerCheckerButtonLabel(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "create_and_process_appl"));
    }

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        reset();
        logger.trace("MbReissueCardDS::init...");
        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
        if (EntityNames.CARD.equals(entityType)) {
            card = retriveCard(cardId);
        }
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
        newCardProductId = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD) {
            if (EntityNames.CARD.equals(entityType)) {
                handleChangeCardProductApplication();
                getContext().put(WizardConstants.APPLICATION_ID, createdApp.getId());
                getContext().put(WizardConstants.DETAILS_SUB_PAGE, DETAILS_SUB_PAGE);
            }
        }
        return getContext();
    }

    private void handleChangeCardProductApplication() {
        logger.trace("handleChangeCardProductApplication...");
        card.setProductId(newCardProductId);;
        ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId(), ApplicationConstants.TYPE_ISSUING);
        builder.buildFromCard(card);
        builder.createApplicationInDB(ApplicationStatuses.AWAITING_PROCESSING);
        if (isChecker()) {
            builder.processApplication();
        }
        createdApp = builder.getApp();
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return newCardProductId != null;
    }

    public Card getCard() {
        return card;
    }

    public void setCard(Card card) {
        this.card = card;
    }

    public List<SelectItem> getIssuingProducts() {
        if (issuingProducts == null) {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("institution_id", card.getInstId());
            issuingProducts = getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, params);
        }
        return issuingProducts;
    }

    public Integer getNewCardProductId() {
        return newCardProductId;
    }

    public void setNewCardProductId(Integer newCardProductId) {
        this.newCardProductId = newCardProductId;
    }
}

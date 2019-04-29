package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.common.WizardConstants;
import ru.bpc.sv2.common.application.ApplicationFlows;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ReissueCommands;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.ReissueReason;
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
@ManagedBean(name = "MbReissueCardDS")
public class MbReissueCardDS extends AbstractWizardStep {

    protected static final Logger logger = Logger.getLogger("COMMON");
    private static final String PAGE = "/pages/common/wizard/callcenter/reissueCardDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String DETAILS_SUB_PAGE = "./issCardDetailsTemplate.jspx";

    private IssuingDao issuingDao = new IssuingDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    private ReissueReason reissueReason;

    private List<SelectItem> reissueReasons;
    private List<SelectItem> reissueCommands;
    private List<SelectItem> reissueCommandsEditable;
    private List<SelectItem> pinRequests;
    private List<SelectItem> pinMailerRequests;
    private List<SelectItem> embossRequests;
    private List<SelectItem> reissueStartDateRules;
    private List<SelectItem> reissueExpirDateRules;
    private List<SelectItem> persoPriorities;

    private Card card;
    private Long cardId;
    private String entityType;

    private Application createdApp;



    public MbReissueCardDS() {
        setFlowId(ApplicationFlows.REISSUE_CARD);
        setMakerCheckerMode(WizardPrivConstants.CARD_REISSUE_REQUEST, WizardPrivConstants.CARD_REISSUE);
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
        reissueReason = new ReissueReason();
        reissueReasons = null;
        reissueCommands = null;
        pinRequests = null;
        pinMailerRequests = null;
        embossRequests = null;
        reissueStartDateRules = null;
        reissueExpirDateRules = null;
        persoPriorities = null;

    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD) {
            if (EntityNames.CARD.equals(entityType)) {
                handleReissueApplication();
                getContext().put(WizardConstants.APPLICATION_ID, createdApp.getId());
                getContext().put(WizardConstants.DETAILS_SUB_PAGE, DETAILS_SUB_PAGE);
            }
        }
        return getContext();
    }

    private void handleReissueApplication() {
        logger.trace("handleReissueApplciation...");
        ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, card.getInstId(), getFlowId(), ApplicationConstants.TYPE_ISSUING);
        builder.buildFromCard(card);
        builder.fillReissueReason(reissueReason);
        builder.createApplicationInDB(ApplicationStatuses.AWAITING_PROCESSING);
        if (isChecker()) {
            builder.processApplication();
        }
        createdApp = builder.getApp();
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return StringUtils.isNotBlank(reissueReason.getReissueReason() + reissueReason.getReissueCommand());
    }

    public Card getCard() {
        return card;
    }

    public void setCard(Card card) {
        this.card = card;
    }

    public void onReissueReasonChanged() {
        if (StringUtils.isNotBlank(reissueReason.getReissueReason())) {
            List<Filter> filters = new ArrayList<Filter>();

            filters.add(Filter.create("instId", card.getInstId()));
            filters.add(Filter.create("lang", curLang));
            filters.add(Filter.create("reissueReason", reissueReason.getReissueReason()));

            SelectionParams params = new SelectionParams();
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            try {
                ReissueReason[] reissueReasons = issuingDao.getReissueReasons(userSessionId, params);
                if (reissueReasons != null && reissueReasons.length > 0) {
                    reissueReason = reissueReasons[0];
                }
            } catch (Exception e) {
                FacesUtils.addMessageError(e);
                logger.error("", e);
            }
        } else {
            reissueReason = new ReissueReason();
        }
    }

    public Boolean isEmptyReissueReason() {
        return !StringUtils.isNotBlank(reissueReason.getReissueReason());
    }

    public ReissueReason getReissueReason() {
        return reissueReason;
    }

    public void setReissueReason(ReissueReason reissueReason) {
        this.reissueReason = reissueReason;
    }

    public List<SelectItem> getReissueReasons() {
        if (reissueReasons == null) {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("inst_id", card.getInstId());
            reissueReasons = getDictUtils().getLov(LovConstants.REISSUING_REASONS, params);
        }
        return reissueReasons;
    }

    public List<SelectItem> getReissueCommands() {
        if (reissueCommands == null) {
            reissueCommands = getDictUtils().getLov(LovConstants.REISS_COMMANDS);
            reissueCommandsEditable = new ArrayList<>(reissueCommands.size() - 1);
            for (Iterator<SelectItem> iter = reissueCommands.iterator(); iter.hasNext(); ) {
                SelectItem command = (SelectItem)iter.next();
                if (!ReissueCommands.REISSUE_IS_NOT_REQUIRED.equals(command.getValue())) {
                    reissueCommandsEditable.add(command);
                }
            }
        }
        return isEmptyReissueReason() ? reissueCommandsEditable : reissueCommands;
    }

    public List<SelectItem> getPinRequests() {
        if (pinRequests == null) {
            pinRequests = getDictUtils().getLov(LovConstants.PIN_REQUEST);
        }
        return pinRequests;
    }

    public List<SelectItem> getPinMailerRequests() {
        if (pinMailerRequests == null) {
            pinMailerRequests = getDictUtils().getLov(LovConstants.PIN_MAILER_REQUEST);
        }
        return pinMailerRequests;
    }

    public List<SelectItem> getEmbossRequests() {
        if (embossRequests == null) {
            embossRequests = getDictUtils().getLov(LovConstants.EMBOSS_REQUEST);
        }
        return embossRequests;
    }

    public List<SelectItem> getReissueStartDateRules() {
        if (reissueStartDateRules == null) {
            reissueStartDateRules = getDictUtils().getLov(LovConstants.PERSO_REISS_START_DATE_RULE);
        }
        return reissueStartDateRules;
    }

    public List<SelectItem> getReissueExpirDateRules() {
        if (reissueExpirDateRules == null) {
            reissueExpirDateRules = getDictUtils().getLov(LovConstants.PERSO_REISS_EXPIR_DATE_RULE);
        }
        return reissueExpirDateRules;
    }

    public List<SelectItem> getPersoPriorities() {
        if (persoPriorities == null) {
            persoPriorities = getDictUtils().getLov(LovConstants.PERSO_PRIORITY);
        }
        return persoPriorities;
    }
}

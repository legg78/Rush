package ru.bpc.sv2.ui.common.wizard.dispute;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.DisputesDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbStopListEventTypeSelectionStep")
public class MbStopListEventTypeSelectionStep implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbOperTypeSelectionStep.class);
    private static final String PAGE = "/pages/common/wizard/disputes/stopListEventTypeSelectionStep.jspx";
    private static final String STOP_LIST_EVENT_TYPE = "STOP_LIST_EVENT_TYPE";
    private static final String CARD_MASK = "CARD_MASK";
    private static final String STOP_LIST_TYPE = "STOP_LIST_TYPE";

    private Map<String, Object> context;
    private List<SelectItem> eventTypes;
    private String eventType;

    private long userSessionId;
    private DisputesDao disputesDao = new DisputesDao();

    @Override
    public void init(Map<String, Object> context) {
        logger.trace("MbStopListEventTypeSelectionStep::init");
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        if(context.containsKey(STOP_LIST_EVENT_TYPE)) {
            eventType = (String) context.get(STOP_LIST_EVENT_TYPE);
        } else {
            eventType = null;
        }
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        this.context = context;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("MbStopListEventTypeSelectionStep::release");
        context.put(STOP_LIST_EVENT_TYPE, eventType);
        return context;
    }

    @Override
    public boolean validate() {
        logger.trace("MbStopListEventTypeSelectionStep::validate");
        if (eventType != null && !eventType.isEmpty()) {
            return true;
        }
        return false;
    }

    private DictUtils getDict() {
        return (DictUtils)ManagedBeanWrapper.getManagedBean("DictUtils");
    }

    public List<SelectItem> getEventTypes(){
        if (eventTypes == null) {
            eventTypes = getDict().getLov(LovConstants.STOP_LIST_EVENT_TYPES);
        }
        return eventTypes;
    }

    public String getEventType() {
        return eventType;
    }

    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public Boolean isCardInStopList(){
        if (EventConstants.ADD_CARD_TO_STOP_LIST.equals(eventType)) {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("cardInstanceId", disputesDao.getCardInstanceIdByMask(userSessionId, ((String) context.get(CARD_MASK)).trim().replaceAll("[*]", "%")));
            params.put("stopListType", (String)context.get(STOP_LIST_TYPE));
            return disputesDao.isCardInStopList(userSessionId, params);
        }
        return false;
    }
}

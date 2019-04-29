package ru.bpc.sv2.ui.common.wizard.operations;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.events.RegisteredEvent;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import java.util.*;

@ViewScoped
@ManagedBean(name = "MbManualSendSmsDS")
public class MbManualSendSmsDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(MbManualSendSmsDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/operation/manualSendSmsDS.jspx";
    private static final String EVENT_TYPE = "EVENT_TYPE";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String INST_ID = "INST_ID";

    private Map<String, Object> context;
    private String selectedEvent;
    private List<SelectItem> events;
    private transient DictUtils dictUtils;
    private long userSessionId;
    private Long objectId;
    private Integer instId;

    private EventsDao eventDao = new EventsDao();

    @Override
    public void init(Map<String, Object> context) {
        reset();
        logger.trace("init...");
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        if (context.containsKey(OBJECT_ID)) {
            objectId = (Long)context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID +" is not defined in wizard context");
        }
        if (context.containsKey(INST_ID)) {
            instId = (Integer)context.get(INST_ID);
        } else {
            throw new IllegalStateException(INST_ID +" is not defined in wizard context");
        }
    }

    private void reset() {
        context = null;
        selectedEvent = null;
        objectId = null;
        instId = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("release...");
        if (direction == Direction.FORWARD) {
            registerEvent();
            context.put(EVENT_TYPE, selectedEvent);
        }
        return context;
    }

    private void registerEvent() {
        RegisteredEvent event = new RegisteredEvent();
        event.setEffectiveDate(new Date());
        event.setEventType(selectedEvent);
        event.setEntityType(EntityNames.OPERATION);
        event.setObjectId(objectId);
        event.setInstId(instId);
        try {
            eventDao.registerEvent(event, userSessionId);
        } catch (Exception e) {
            logger.error("Error when process operation. ", e);
            FacesUtils.addMessageError(e);
        }
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        throw new UnsupportedOperationException("validate");
    }

    public String getSelectedEvent() {
        return selectedEvent;
    }

    public void setSelectedEvent(String selectedEvent) {
        this.selectedEvent = selectedEvent;
    }

    public List<SelectItem> getEvents() {
        if (events == null) {
            events = getDictUtils().getLov(LovConstants.EVENT_TYPES,
                        new HashMap<String, Object>() {{
                            put(ENTITY_TYPE, EntityNames.OPERATION);
                        }});
        }
        return events;
    }

    public void setEvents(List<SelectItem> events) {
        this.events = events;
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }
}

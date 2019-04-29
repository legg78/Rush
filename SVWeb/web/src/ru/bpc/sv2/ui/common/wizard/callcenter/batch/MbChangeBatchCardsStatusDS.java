package ru.bpc.sv2.ui.common.wizard.callcenter.batch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbChangeBatchCardsStatusDS")
public class MbChangeBatchCardsStatusDS implements CommonWizardStep {

    private static final Logger classLogger = Logger.getLogger(MbChangeBatchCardsStatusDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/batch/changeBatchCardsStatusDS.jspx";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String AGENT_ID = "AGENT_ID";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String RESULT = "RESULT";

    private Map<String, Object> context;
    private DictUtils dictUtils;
    private String entityType;
    private String eventType;
    private String state;
    private List<SelectItem> eventTypes;
    private List<SelectItem> cardStates;
    private Integer agentId;

    private PersonalizationDao _personalizationDao = new PersonalizationDao();
    private long userSessionId;

    private void reset(){
    	cardStates = null;
    	state = null;
    	eventType = null;
    	eventTypes = null;
    }

    @Override
    public void init(Map<String, Object> context) {
        reset();
        classLogger.trace("MbChangeBatchCardsStatusDS::init...");
        dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
        this.context = context;
        context.put(MbCommonWizard.PAGE, PAGE);
        context.put(MbCommonWizard.VALIDATED_STEP, Boolean.TRUE);
        entityType = (String) context.get(ENTITY_TYPE);
        if (EntityNames.PERSONALIZATION_BATCH.equals(entityType)){
            agentId = (Integer)context.get(AGENT_ID);
        }
        userSessionId = SessionWrapper.getRequiredUserSessionId();
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD){
            if (EntityNames.PERSONALIZATION_BATCH.equals(entityType)){
                context.put(AGENT_ID, agentId);
                changeBatchCardInstancesStatus(userSessionId, (Long) context.get(OBJECT_ID), (Integer)context.get(AGENT_ID), state);
            }
        }
        return context;
    }

    private void changeBatchCardInstancesStatus(long userSessionId, Long batchId, Integer agentId, String state){
        try {
            _personalizationDao.changeBatchCardInstancesState(userSessionId, batchId, agentId, state, null);
            context.put(RESULT, Boolean.TRUE);
        } catch(Exception e) {
            context.put(RESULT, Boolean.FALSE);
            FacesUtils.addMessageError(e);
        }
    }

    @Override
    public boolean validate() {
        return true;
    }

    public Integer getAgentId() {
        return agentId;
    }

    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public List<SelectItem> getAgents() {

        if (context.get("INSTITUTION_ID") == null)
            return new ArrayList<SelectItem>();
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("INSTITUTION_ID", context.get("INSTITUTION_ID"));
        return getDictUtils().getLov(LovConstants.AGENTS, paramMap);

    }

	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public List<SelectItem> getEventTypes() {
		if (eventTypes == null) {
			eventTypes = getDictUtils().getLov(LovConstants.EVENT_TYPES_FOR_STATUS);
		}
		return eventTypes;
	}
	
	public List<SelectItem> getStates() {
		if (cardStates == null) {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("BATCH_ID", (Long) context.get(OBJECT_ID));
			cardStates = getDictUtils().getLov(LovConstants.PRS_BATCH_CARD_INSTANCES_STATES, map);
		}
		return cardStates;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}
	
}

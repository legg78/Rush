package ru.bpc.sv2.ui.common.wizard.callcenter;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.evt.StatusLog;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbChangeStatusCommonDS")
public class MbChangeStatusCommonDS implements CommonWizardStep{

	private static final Logger classLogger = Logger.getLogger("EVENTS");
	private static final String PAGE = "/pages/common/wizard/callcenter/changeStatusCommonDS.jspx";
	private static final String ENTITY_TYPE = "ENTITY_TYPE";
	private static final String OBJECT_ID = "OBJECT_ID";
	private static final String CURRENT_STATUS = "CURRENT_STATUS";
	private static final String INITIATOR_OPERATOR = "ENSIOPER";
	
	private EventsDao eventDao = new EventsDao();
	private transient DictUtils dictUtils;
	
	private Map<String, Object> context;
	private String entityType;
	private List<SelectItem> statuses;
	private String currentStatus;
	private String reason;
	private long userSessionId;
	private String newStatus;
	private List<SelectItem> reasons;
	private Long objectId;
	
	@Override
	public void init(Map<String, Object> context) {
		reset();
		classLogger.trace("MbChangeStatusCommonDS init ...");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		this.context = context;
		context.put(MbCommonWizard.PAGE, PAGE);
		if (context.containsKey(ENTITY_TYPE)){
			entityType = (String)context.get(ENTITY_TYPE);
		} else {
			throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
		}
		if (context.containsKey(OBJECT_ID)){
			objectId = (Long)context.get(OBJECT_ID);
		} else {
			throw new IllegalStateException(OBJECT_ID +" is not defined in wizard context");
		}
		if (context.containsKey(OBJECT_ID)){
			objectId = (Long)context.get(OBJECT_ID);
		} else {
			throw new IllegalStateException(OBJECT_ID +" is not defined in wizard context");
		}
		
		if (context.containsKey(CURRENT_STATUS)){
			currentStatus = (String)context.get(CURRENT_STATUS);
		} else {
			currentStatus = retrieveCurrentStatus(entityType, objectId);			
		}
		if (currentStatus == null) {
			throw new IllegalStateException("Current status of the object was not defined");
		}
	}

	private void reset(){
		context = null;
		statuses = null;
		currentStatus = null;
		newStatus = null;		
		reasons = null;
		reason = null;
	}
	
	@Override
	public Map<String, Object> release(Direction direction) {
		classLogger.trace("MbChangeStatusCommonDS release...");
		if (direction == Direction.FORWARD){
			String newStatus = changeStatus();
			context.put(CURRENT_STATUS, newStatus);
		}		
		return context;
	}

	private String changeStatus(){
		try {
			StatusLog statusLog = new StatusLog();
			statusLog.setEntityType(entityType);
			statusLog.setObjectId(objectId);
			statusLog.setStatus(newStatus);
			statusLog.setInitiator(INITIATOR_OPERATOR);
			statusLog.setReason(reason);
			String newStatus = eventDao.changeStatusByNewStatus(userSessionId, statusLog);
			return newStatus;
		} catch (Exception e) {
			classLogger.error(e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}
	
	@Override
	public boolean validate() {
		classLogger.trace("MbChangeStatusCommonDS validate...");
		throw new UnsupportedOperationException("MbChangeStatusCommonDS validate");
	}
	
	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

	public List<SelectItem> getStatuses() {
		if (statuses == null) {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("INITIAL_STATUS", currentStatus);
			statuses = getDictUtils().getLov(LovConstants.OPERATION_STATUSES_TRANSITIONS, map);
		}
		return statuses;
	}
	
	public List<SelectItem> getReasons(){
		if (reasons == null){
			updateReasons();
		}
		return reasons;
	}
	
	private void updateReasons(){
		classLogger.trace("MbChangeStatusCommonDS updateReasons...");
		Map<String, Object> map = new HashMap<String, Object>();			
		map.put("initiator", INITIATOR_OPERATOR);
		map.put("initial_status", currentStatus);
		map.put("result_status", newStatus);			
		reasons = getDictUtils().getLov(LovConstants.CHANGE_STATUS_COMMANDS, map);		
	}

	private String retrieveCurrentStatus(String entityType, Long objectId) {
		String status = null;
		try {
			status = eventDao.getObjectStatus(userSessionId, entityType, objectId);
		} catch (Exception e) {
			classLogger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return status;
	}
	
	public String getReason() {
		return reason;
	}

	public void setReason(String reason) {
		this.reason = reason;
	}

	public String getCurrentStatus() {
		return currentStatus;
	}

	public void setCurrentStatus(String currentStatus) {
		this.currentStatus = currentStatus;
	}

	public String getNewStatus() {
		return newStatus;
	}

	public void setNewStatus(String newStatus) {
		if (newStatus != null && !newStatus.equals(this.newStatus)){
			this.newStatus = newStatus;
			updateReasons();
		}
	}

}

package ru.bpc.sv2.ui.common.wizard.callcenter;

import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;

import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.SessionWrapper;
@ViewScoped
@ManagedBean (name = "MbChangeStatusCommonRS")
public class MbChangeStatusCommonRS implements CommonWizardStep{

	private static final Logger classLogger = Logger.getLogger(MbChangeStatusCommonRS.class);
	private static final String PAGE = "/pages/common/wizard/callcenter/changeStatusCommonRS.jspx";
	private static final String ENTITY_TYPE = "ENTITY_TYPE";
	private static final String OBJECT_ID = "OBJECT_ID";
	private static final String CURRENT_STATUS = "CURRENT_STATUS";
	
	private EventsDao eventDao = new EventsDao();
	
	private Map<String, Object> context;
	private String entityType;
	private Long objectId;
	private long userSessionId;
	private String currentStatus;
	
	@Override
	public void init(Map<String, Object> context) {
		classLogger.trace("init...");
		
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		
		this.context = context;
		context.put(MbCommonWizard.PAGE, PAGE);
		context.put(MbCommonWizard.DISABLE_BACK, Boolean.TRUE);
		if (!context.containsKey(ENTITY_TYPE)){
			throw new IllegalStateException(ENTITY_TYPE + " is not defined in wizard context");
		}
		entityType = (String) context.get(ENTITY_TYPE);
		if (!context.containsKey(OBJECT_ID)){
			throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
		}
		objectId = (Long) context.get(OBJECT_ID);
		currentStatus = retrieveCurrentStatus(entityType, objectId);			
		
		if (currentStatus == null) {
			throw new IllegalStateException("Current status of the object was not defined");
		}
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
	
	@Override
	public Map<String, Object> release(Direction direction) {
		classLogger.trace("release...");
		return context;
	}

	@Override
	public boolean validate() {
		classLogger.trace("validate...");
		throw new UnsupportedOperationException("validate");
	}

	public String getCurrentStatus() {
		return currentStatus;
	}

	public void setCurrentStatus(String currentStatus) {
		this.currentStatus = currentStatus;
	}

}

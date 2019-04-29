package ru.bpc.sv.ws.application.handlers;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.common.events.RegisteredEvent;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.AppElementsCache;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.io.ByteArrayInputStream;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class AppStageProcessor {

	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private static final Logger logger = Logger.getLogger("SVAP");
	public static boolean traceTime = true;
	public static boolean trace = true;
	private ApplicationsWsDao appDao;
	private EventsDao eventsDao;

	private long applicationId;
	private String currentStage;
	private String currentResult;
	private Integer flowId;
	private AppElementsCache appCache = null;
	private Application application = null;
	private String applicationXml = null;
	private Long sessionId = null;
	private Document appDoc = null;
	private Map<String, Object> handlersParams;

	private Map<String, Object> params = null;
	private String userName;
	
	private int count;
	private long currVal;
	
	public AppStageProcessor(Application application) {
		init(application);
		this.application = application;
	}

	public AppStageProcessor(Application application, String applicationXml) {
		init(application);
		this.application = application;
		this.applicationXml = applicationXml;
		if (applicationXml != null) {
			try {
				DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
				DocumentBuilder builder = domFactory.newDocumentBuilder();
				appDoc = builder.parse(new ByteArrayInputStream(applicationXml.getBytes("UTF-8")));
			} catch (Exception e) {
				logger.error("Incorrect application");
				loggerDB.error(new TraceLogInfo(getSessionId(), "Incorrect application", EntityNames.APPLICATION, getApplicationId()), e);
			}
		}
	}

	public AppStageProcessor(Application application, Document doc) {
		init(application);
		this.application = application;
		this.appDoc = doc;
	}

	public AppStageProcessor(String applicationXml) {
		application = new Application();

		try {
			DocumentBuilderFactory domFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder builder = domFactory.newDocumentBuilder();
			appDoc = builder.parse(new ByteArrayInputStream(applicationXml.getBytes("UTF-8")));
			XPath xpath = XPathFactory.newInstance().newXPath();
			XPathExpression expr = xpath.compile("/application/application_id");
			Double appId = (Double) expr.evaluate(appDoc, XPathConstants.NUMBER);
			expr = xpath.compile("/application/application_flow_id");
			Double flow = (Double) expr.evaluate(appDoc, XPathConstants.NUMBER);
			expr = xpath.compile("/application/application_status");
			String status = (String) expr.evaluate(appDoc, XPathConstants.STRING);
			application.setId(appId.longValue());
			application.setStatus(status);
			application.setFlowId(flow.intValue());
		} catch (Exception e) {
			logger.error("Incorrect application");
			loggerDB.error(new TraceLogInfo(getSessionId(), "Incorrect application", EntityNames.APPLICATION, getApplicationId()), e);
		}

		init(application);
	}

	private void init(Application application) {
		appCache = AppElementsCache.getInstance();
		applicationId = application.getId();
		currentStage = application.getStatus();
		flowId = application.getFlowId();
	}

	public void process() throws Exception {
		appDao = new ApplicationsWsDao();
		eventsDao = new EventsDao();
		if (traceTime) {
			logger.trace("APP: " + applicationId + "; APPLICATION STAGE PROCESSOR: process begin");
			loggerDB.trace(new TraceLogInfo(getSessionId(), "APPLICATION STAGE PROCESSOR: process begin",
					EntityNames.APPLICATION, getApplicationId()));
		}
		long processBegin = System.currentTimeMillis();

		AppStageHandler handler = null;
		if (getHandlersParams() != null){
			params = getHandlersParams();
		} else {
			params = new HashMap<String, Object>();
		}
		while ((handler = getHandler(flowId, currentStage)) != null) {
			if (traceTime) {
				logger.trace("APP: " + applicationId + "; APPLICATION STAGE PROCESSOR: handler " + handler.getName());
				loggerDB.trace(new TraceLogInfo(getSessionId(), "; APPLICATION STAGE PROCESSOR: handler " +
						handler.getName(), EntityNames.APPLICATION, getApplicationId()));
			}
			long handlerBegin = System.currentTimeMillis();
			handler.setApplication(application);
			handler.setApplicationId(applicationId);
			handler.setApplicationXml(applicationXml);
			handler.setApplicationDoc(appDoc);
			handler.setSessionId(sessionId);
			handler.setCurrVal(currVal);
			handler.setCount(count);
			handler.setParams(params);
			String resultComments;
			try {
				handler.process();
				currentResult = handler.getStageResult();
				resultComments = handler.getStageResultComment();
			} catch (Exception e){
				logger.error(e);
				currentResult = ApplicationFlowStage.STAGE_RESULT_FAIL;
				resultComments = "An unhandled exception occured during stage processing";
			}
			if (traceTime) {
				logger.trace("APP: " + applicationId + "; APPLICATION STAGE PROCESSOR: handler " + handler.getName() +
						"; Time process: " + (System.currentTimeMillis() - handlerBegin));
				loggerDB.trace(new TraceLogInfo(getSessionId(), "APPLICATION STAGE PROCESSOR: handler " + handler.getName() +
						"; Time process: " + (System.currentTimeMillis() - handlerBegin), EntityNames.APPLICATION, getApplicationId()));
			}
			if (currentResult == null) {
				break;
			}
			if (handler.isReloadApplication()) {
				appDoc = handler.getApplicationDoc();
			}
			long transitionBegin = System.currentTimeMillis();
			Map<String, String> transitions = appCache.getTransitionsMap(flowId);
			String errorMess = "Cannot find transitions for flow " + flowId;

			if (transitions == null) {
				throw new Exception(errorMess);
			} else {
				currentStage = transitions.get(currentStage + currentResult);
				if (currentStage == null) {
					throw new Exception(errorMess);
				} else {
					application.setNewStatus(currentStage);
					application.setComment(resultComments);
					if (userName == null){
						appDao.modifyApplication(sessionId, application);
					}else{
						appDao.modifyApplication(sessionId, application, userName);
					}
					application.setStatus(currentStage);
					registerEvent(currentStage);					
				}
			}
			currVal = handler.getCurrVal();
			count = handler.getCount();
			
			if (traceTime) {
				logger
						.trace("APP: " + applicationId + "; APPLICATION STAGE PROCESSOR: Select transition + modify application status: " +
								(System.currentTimeMillis() - transitionBegin));
				loggerDB.trace(new TraceLogInfo(getSessionId(), "APPLICATION STAGE PROCESSOR: Select transition + modify application status: " +
						(System.currentTimeMillis() - transitionBegin), EntityNames.APPLICATION, getApplicationId()));
			}
		}
		if (traceTime) {
			logger.trace("APP: " + applicationId + "; APPLICATION STAGE PROCESSOR: process finished. Time process: " +
					(System.currentTimeMillis() - processBegin));
			loggerDB.trace(new TraceLogInfo(getSessionId(), "APPLICATION STAGE PROCESSOR: process finished. Time process: " +
					(System.currentTimeMillis() - processBegin), EntityNames.APPLICATION, getApplicationId()));
		}

	}

	public long getApplicationId() {
		return applicationId;
	}

	public void setApplicationId(long applicationId) {
		this.applicationId = applicationId;
	}

	public String getCurrentStage() {
		return currentStage;
	}

	public void setCurrentStage(String currentStage) {
		this.currentStage = currentStage;
	}

	public Integer getFlowId() {
		return flowId;
	}

	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}

	private AppStageHandler getHandler(Integer flowId, String stage) {
		String className = null;
		Map<String, String> map = appCache.getHandlersMap(flowId);
		if (map == null) {
			return null;
		} else {
			className = map.get(stage);
		}
		if (className != null) {
			return (AppStageHandler) createObject(className);
		} else {
			return null;
		}
	}

	private static Object createObject(String className) {
		Object object = null;
		try {
			Class<?> classDefinition = Class.forName(className);
			object = classDefinition.newInstance();
		} catch (InstantiationException e) {
			logger.error("", e);
		} catch (IllegalAccessException e) {
			logger.error("", e);
		} catch (ClassNotFoundException e) {
			logger.error("", e);
		}
		return object;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public long getCurrVal() {
		return currVal;
	}

	public void setCurrVal(long currVal) {
		this.currVal = currVal;
	}

	private void registerEvent(String newStage) throws Exception{
		if (ApplicationStatuses.PROCESSING_FAILED.equals(newStage))  {
			RegisteredEvent event = formEvent(EventConstants.APPLICATION_PROCESSING_FAILED);
			eventsDao.registerEvent(event, sessionId, userName);
		} else if (ApplicationStatuses.PROCESSES_SUCCESSFULLY.equals(newStage)) {
			RegisteredEvent event = formEvent(EventConstants.APPLICATION_PROCESSED_SUCCESSFULLY);
			eventsDao.registerEvent(event, sessionId, userName);
		} else {
			return;
		}		
	}
	
	private RegisteredEvent formEvent(String eventType) {
		RegisteredEvent event = new RegisteredEvent();
		event.setEffectiveDate(new Date());
		event.setEventType(eventType);
		event.setEntityType(EntityNames.APPLICATION);
		event.setObjectId(applicationId);
		event.setInstId(application.getInstId());
		return event;
	}

	public Map<String, Object> getHandlersParams() {
		return handlersParams;
	}

	public void setHandlersParams(Map<String, Object> handlersParams) {
		this.handlersParams = handlersParams;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

}

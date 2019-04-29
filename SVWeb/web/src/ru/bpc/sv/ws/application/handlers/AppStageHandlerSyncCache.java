package ru.bpc.sv.ws.application.handlers;

import org.apache.log4j.Logger;
import ru.bpc.datamanagement.*;
import ru.bpc.sv.ws.handlers.soap.SOAPLoggingHandler;
import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.common.ObjectEntity;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.cache.DictCache;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import javax.xml.ws.Binding;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.handler.Handler;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class AppStageHandlerSyncCache extends AppStageHandler {

	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private static final Logger logger = Logger.getLogger("SVAP");
	private static final String HANDLER_NAME = "AppStageHandlerSyncCache";


	public AppStageHandlerSyncCache() {
		
	}

	public void process() {
		String errorMessage = null;
		String comment = null;
		long processBegin = System.currentTimeMillis();
		try {
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			String feLocation = settingParamsCache
					.getParameterStringValue(SettingsConstants.FRONT_END_LOCATION);
			if (feLocation == null || feLocation.trim().length() == 0) {
				logger.trace("APP: " + getApplicationId() + "; " + HANDLER_NAME +
						": FE location parameter not defined! Finish handler with code 0020");
				loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME +
						": FE location parameter not defined! Finish handler with code 0020",
						EntityNames.APPLICATION, getApplicationId()));
				setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
				return;
			}
			
			BigDecimal fePortNumber = settingParamsCache
					.getParameterNumberValue(SettingsConstants.UPDATE_CACHE_WS_PORT);
			if (fePortNumber == null) {
				logger.trace("APP: " + getApplicationId() + "; " + HANDLER_NAME +
						": FE cache update port parameter not defined! Finish handler with code 0020");
				loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME +
						": FE cache update port parameter not defined! Finish handler with code 0020",
						EntityNames.APPLICATION, getApplicationId()));
				setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
				return;
			}
			
			feLocation = feLocation + ":" + fePortNumber.intValue();

			ApplicationDao appDao = new ApplicationDao();
			
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[1];
			filters[0] = new Filter("applicationId", getApplicationId());
//			filters[0] = new Filter("needSync", "1");
			params.setFilters(filters);
			
			ObjectEntity[] objects = appDao.getApplicationOnlineObjects(getSessionId(), params);
			
			ObjectFactory of = new ObjectFactory();
//			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
//			syncronizeRqType.setEntityType(EntityNames.HOST);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider) port;
			Binding binding = bp.getBinding();
			@SuppressWarnings("unchecked")
			List<Handler> soapHandlersList = new ArrayList<Handler>();
			SOAPLoggingHandler soapHandler = new SOAPLoggingHandler();
			soapHandler.setLogger(logger);
			soapHandlersList.add(soapHandler);
			binding.getHandlerChain();
			binding.setHandlerChain(soapHandlersList);
			
			bp.getRequestContext().put(
					BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
			bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
			bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);
			
			SyncronizeRsType rsType = null;
			comment = "";
			if (objects.length == 0) {
				comment = "Nothing to sync";
			}
			for (ObjectEntity object : objects) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(object.getObjectId().toString());
				entityObj.setObjSeq(object.getSeqNum());
				
				SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
				syncronizeRqType.setEntityType(object.getEntityType());
				syncronizeRqType.getEntityObj().add(entityObj);
				comment += DictCache.getInstance().getAllArticlesDescByLang().
						get(SystemConstants.ENGLISH_LANGUAGE).get(object.getEntityType()) + 
						" " + object.getObjectId();
				try {
					rsType = port.syncronize(syncronizeRqType);
					EntityObjStatusType status = rsType.getEntityObjStatus().get(0);					
					if (status.getFerrno() == 0) {
						comment += " synchronized;";
					} else {
						comment += " not synchronized (ferrNo = " + status.getFerrno() + "); ";
					}
				} catch (Exception e) {
					comment += " not synchronized (Fault);";
				} finally {
					
				}
			}
			setStageResultComment(comment);
			setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
		} catch (UserException e) {
			logger.error("APP: " + getApplicationId() + "; " + HANDLER_NAME + " error", e);
			loggerDB.error(new TraceLogInfo(getSessionId(), e.getMessage(), EntityNames.APPLICATION, getApplicationId()), e);
			setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
			errorMessage = e.getMessage();
			setStageResultComment(comment + errorMessage);
//			addError(orderDataId, ELEMENT_PAYMENT_ORDER, null, errorMessage, null);
		} catch (Exception e) {
			logger.error("APP: " + getApplicationId() + "; " + HANDLER_NAME + " error", e);
			loggerDB.error(new TraceLogInfo(getSessionId(), e.getMessage(), EntityNames.APPLICATION, getApplicationId()), e);
			setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
			errorMessage = "Server error during processing stage";
			String details = e.getMessage();
			setStageResultComment(comment + errorMessage + "; " + details);
//			addError(orderDataId, ELEMENT_PAYMENT_ORDER, null, errorMessage, details);
		} finally {
			if (AppStageProcessor.trace) {
				logger.trace("APP: " + getApplicationId() + "; " + HANDLER_NAME + ": " + comment +
						"; result = " + getStageResult());
				loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME + ": " + comment +
						"; result = " + getStageResult(),
						EntityNames.APPLICATION, getApplicationId()));
			}
			if (AppStageProcessor.traceTime) {
				logger.trace("APP: " + getApplicationId() + "; " + HANDLER_NAME + "; Time : " +
						(System.currentTimeMillis() - processBegin));
				loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME + "; Time : " +
						(System.currentTimeMillis() - processBegin),
						EntityNames.APPLICATION, getApplicationId()));
			}
		}
	}

	public String getName() {
		return HANDLER_NAME;
	}

	protected Logger getLogger() {
		return logger;
	}

	@Override
	protected Logger getLoggerDB() {
		return loggerDB;
	}
	
}

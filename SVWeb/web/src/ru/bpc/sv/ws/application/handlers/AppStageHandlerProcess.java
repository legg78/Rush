package ru.bpc.sv.ws.application.handlers;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.logic.ws.ApplicationsWsDao;
import ru.bpc.sv2.trace.TraceLogInfo;

public class AppStageHandlerProcess extends AppStageHandler {

	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private static final Logger logger = Logger.getLogger("SVAP");
	private static final String HANDLER_NAME = "AppStageHandlerProcess";

	public void process() {
		long processBegin = System.currentTimeMillis();
		try {
			ApplicationsWsDao appWsDao = new ApplicationsWsDao();
			String result = appWsDao.processApplication(getSessionId(), getApplicationId(), null, "WSUSER");
			setStageResult(result);
		} catch (Exception e) {
			logger.error("APP: " + getApplicationId(), e);
			loggerDB.error(new TraceLogInfo(getSessionId(), e.getMessage(), EntityNames.APPLICATION, getApplicationId()), e);
			setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
		} finally {
			if (AppStageProcessor.trace) {
				logger.trace("APP: " + getApplicationId() + "; " + HANDLER_NAME + "; result = " + getStageResult());
				loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME + "; result = " + getStageResult(),
						EntityNames.APPLICATION, getApplicationId()));
			}
			if (AppStageProcessor.traceTime) {
				logger.trace("APP: " + getApplicationId() + "; " + HANDLER_NAME + "; Time : " + (System.currentTimeMillis() - processBegin));
				loggerDB.trace(new TraceLogInfo(getSessionId(), HANDLER_NAME + "; Time : " +
						(System.currentTimeMillis() - processBegin), EntityNames.APPLICATION, getApplicationId()));
			}
		}
	}
	
	public String getName() {
		return HANDLER_NAME;
	}
	
	@Override
	protected Logger getLogger() {
		return logger;
	}
	
	@Override
	protected Logger getLoggerDB() {
		return loggerDB;
	}
	
}

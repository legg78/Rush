package ru.bpc.sv.ws.application.handlers;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationFlowStage;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.trace.TraceLogInfo;

public class AppStageHandlerStub extends AppStageHandler {

	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private static final Logger logger = Logger.getLogger("SVAP");
	private static final String HANDLER_NAME = "AppStageHandlerStub";
	
	public void process() {
		try {
			setStageResult(ApplicationFlowStage.STAGE_RESULT_SUCCESS);
		} catch (Exception e) {
			logger.error("", e);
			loggerDB.error(new TraceLogInfo(getSessionId(), e.getMessage(), EntityNames.APPLICATION, getApplicationId()), e);
			setStageResult(ApplicationFlowStage.STAGE_RESULT_FAIL);
		}
		if (AppStageProcessor.traceTime) {
			logger.trace("APPLICATION STAGE PROCESSOR: handler " + HANDLER_NAME +"; result = " + getStageResult());
			loggerDB.trace(new TraceLogInfo(getSessionId(), "APPLICATION STAGE PROCESSOR: handler " +
					HANDLER_NAME +"; result = " + getStageResult(), EntityNames.APPLICATION, getApplicationId()));
		}
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

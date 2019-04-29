package ru.bpc.sv2.scheduler.process.interchange;

import com.bpcbt.sv.interchange.message.v1.CalculationResponse;
import ru.bpc.sv.ws.svng.InterchangeClient;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.ws.Response;
import java.util.Map;

public class InterchangeCalculateProcess extends IbatisExternalProcess {
	private static final String FAILED_PARAM_KEY = "I_FAILED_PERCENT";
	private static final String TIMEOUT_PARAM_KEY = "I_TIMEOUT";
	private static final String MODULE_PARAM_KEY = "I_MODULE";

	private long instId;
	private String status;
	private String operType;

	private String mqUrl;//for tests use tcp://localhost:61616
	private double failedPercent;
	private int timeout;
	private String module;

	@Override
	public void execute() throws SystemException, UserException {
		try {
			getIbatisSession();
			startSession();
			startLogging();
			executeBody();
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			commit();
		} catch (Exception e) {
			error(e);
			processSession.setResultCode(ProcessConstants.PROCESS_FAILED);
			rollback();
			if (e instanceof UserException) {
				throw new UserException(e);
			} else {
				throw new SystemException(e);
			}
		} finally {
			closeConAndSsn();
		}

	}

	private void executeBody() throws Exception {
		InterchangeClient interchangeClient =
				new InterchangeClient(mqUrl, module + "_WS_INTERCHANGE", processSessionId());
		trace("Call module ws to calculate fees");
		Response<CalculationResponse> calcResponse =
				interchangeClient.calculate(processSessionId(), instId, status, operType);
		waitResponse(calcResponse);
		if (calcResponse.get().getError() != null) {
			throw new Exception("Error in module: " + calcResponse.get().getError() + ". See module log for details.");
		}
		if (calcResponse.isCancelled()) {
			throw new Exception("Error on calculation request");
		}
		CalculationResponse response = calcResponse.get();
		if (response.getError() != null) {
			throw new Exception("Error in module: " + response.getError() + ". See module log for details.");
		}
		trace(String.format("Received calculation response: succeed=%d, failed=%d", response.getSucceed(),
				response.getFailed()));
		logEstimated((int) response.getSucceed());
		logCurrent((int) response.getSucceed(), (int) response.getFailed());
		double percent = (response.getFailed() / (double) response.getSucceed()) * 100;
		if (percent > failedPercent) {
			trace("Failed operations are over threshold. Rollback. Current threshold is " + failedPercent +
					". Failed percent is " + percent);
			Response<CalculationResponse> resp = interchangeClient.rollback(processSessionId(), true);
			waitResponse(resp);
			if (resp.get().getError() != null) {
				throw new Exception("Error in module: " + resp.get().getError() + ". See module log for details.");
			}
		}
		endLogging((int) response.getSucceed(), (int) response.getFailed());
		trace("Finished");
	}

	private void waitResponse(Response resp) throws Exception {
		long secondsCnt = 0;
		trace("Start waiting for async response...");
		while (!resp.isDone()) {
			Thread.sleep(1000);
			secondsCnt++;
			if (secondsCnt == timeout) {
				throw new Exception("Process is interrupted by timeout");
			}
		}
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		instId = Long.valueOf(parameters.get("I_INST_ID").toString());
		module = parameters.get(MODULE_PARAM_KEY).toString().substring(4).replaceAll("0", "");
		if (parameters.get("I_OPER_STATUS") != null) {
			status = parameters.get("I_OPER_STATUS").toString();
			if (status != null && status.trim().isEmpty()) {
				status = null;
			}
		}
		if (parameters.get("I_TRANSACTION_TYPE") != null) {
			operType = parameters.get("I_TRANSACTION_TYPE").toString();
			if (operType != null && operType.trim().isEmpty()) {
				operType = null;
			}
		}
		if (parameters.get(FAILED_PARAM_KEY) != null) {
			failedPercent = Double.valueOf(parameters.get(FAILED_PARAM_KEY).toString());
		}
		if (parameters.get(TIMEOUT_PARAM_KEY) != null) {
			timeout = Integer.valueOf(parameters.get(TIMEOUT_PARAM_KEY).toString());
		}
	}
}

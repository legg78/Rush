package ru.bpc.sv2.scheduler.process.aggregation;

import com.bpcbt.sv.aggregation.message.v1.AggrResponse;
import ru.bpc.sv.ws.svng.AggregationClient;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.ws.Response;
import java.util.Map;

public class AggregationProcess extends IbatisExternalProcess {
	private long instId;
	private Long aggrType;
	private Long aggrId;
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
			endLogging(0, 0);
			commit();
		} catch (Exception e) {
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
		trace("Aggregation Process::execute...");
		try {
			trace("Aggregation Process::send aggregate request");
			logEstimated(0);
			String mqUrl =
					SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
			trace("Aggregation Process::using mq " + mqUrl);
			AggregationClient client =
					new AggregationClient(mqUrl, module + "_WS_AGGREGATION", processSessionId());
			Response<AggrResponse> response = client.aggregate(instId, aggrType, aggrId);
			trace("Aggregation Process::waiting for response");
			int i = 0;
			while (!response.isDone()) {
				Thread.sleep(1000);
				i++;
				if (i >= timeout) {
					throw new Exception("No actions in " + timeout + " seconds");
				}
			}
			if (!response.get().isResult()) {
				throw new Exception("Error: " + response.get().getDescription());
			}
			logCurrent(0, 0);
			trace("Aggregation Process::finished successfully");
		} catch (Exception ex) {
			throw new UserException(ex);
		}
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		instId = Long.valueOf(parameters.get("I_INST_ID").toString());
		timeout = Integer.valueOf(parameters.get("I_TIMEOUT").toString());
		module = parameters.get("I_MODULE").toString();
		if (parameters.get("I_AGGR_TYPE") != null) {
			aggrType = Long.valueOf(parameters.get("I_AGGR_TYPE").toString());
		}
		if (parameters.get("I_AGGR_ID") != null) {
			aggrId = Long.valueOf(parameters.get("I_AGGR_ID").toString());
		}
	}
}

package ru.bpc.sv2.scheduler.process.cup;

import com.bpcbt.sv.cup.message.v1.FileLoadResponse;
import ru.bpc.sv.ws.cup.clients.CupClient;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.File;
import java.math.BigDecimal;
import java.util.Map;

public class CupDisputeLoadProcess extends IbatisExternalProcess {
	private static final String TIMEOUT_PARAM_KEY = "I_TIMEOUT";
	private static final String ISSUER_PARAM_KEY = "I_ISSUER";

	private String filename;
	private String encoding;
	private String inputDir;
	private String outputDir;
	private String errorDir;
	private boolean issuer;
	private long timeout;

	private String wsInitQueue = "CUP_WS_INIT";

	@Override
	public void execute() throws SystemException, UserException {
		try {
			getIbatisSession();
			startSession();
			startLogging();
			initBeans();
			executeBody();
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			commit();
		} catch (Exception e) {
			processSession.setResultCode(ProcessConstants.PROCESS_FAILED);
			endLogging(0, 0);
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
		trace("Start loading CUP dispute file");
		String mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (mqUrl == null || mqUrl.isEmpty()) {
			trace("No mq address in system settings, use tcp://localhost:61616");
			mqUrl = "tcp://localhost:61616";
		}
		trace("Create init ws-client");
		CupClient cupClient = new CupClient(mqUrl, wsInitQueue);
		FileLoadResponse response =
				cupClient.startLoadingDisputes(processSessionId(), filename, encoding, inputDir, outputDir, errorDir,
						issuer, timeout);
		trace("Received response. Cup module loaded " + response.getTotalRecords() + " records");
		logEstimated((int) response.getTotalRecords());
		logCurrent((int) response.getTotalRecords(), 0);
		trace("Load CUP dispute file process finished");
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		issuer = (((BigDecimal) parameters.get(ISSUER_PARAM_KEY)).intValue() == 1);
		timeout = ((BigDecimal) parameters.get(TIMEOUT_PARAM_KEY)).longValue();
	}

	private void initBeans() throws SystemException {
		trace("Initiating beans...");
		try {
			filename = processSession.getFileName();
			encoding = processSession.getFileEncoding();
			String directory = processSession.getLocation();
			if (filename == null || filename.isEmpty() || encoding == null || encoding.isEmpty() ||
					directory == null || directory.isEmpty()) {
				throw new UserException("There are empty file parameters");
			}
			if (!directory.endsWith("/") && !directory.endsWith("\\")) {
				directory += File.separator;
			}
			inputDir = directory + "input" + File.separator;
			outputDir = directory + "output" + File.separator;
			errorDir = directory + "error" + File.separator;
		} catch (Exception e) {
			error(e);
			throw new SystemException(e.getMessage());
		}
	}
}

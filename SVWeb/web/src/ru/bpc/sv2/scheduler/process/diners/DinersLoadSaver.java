package ru.bpc.sv2.scheduler.process.diners;

import ru.bpc.sv.ws.diners.clients.DinersClient;
import ru.bpc.sv2.diners.enums.LoadType;
import ru.bpc.sv2.scheduler.process.svng.AbstractSvngModuleLoadFileSaver;
import ru.bpc.sv2.utils.UserException;

import java.util.Map;

@SuppressWarnings("unused")
public class DinersLoadSaver extends AbstractSvngModuleLoadFileSaver {
	private static final String LOAD_TYPE_PARAM_NAME = "I_DIN_LOAD_TYPE";
	private static final String transferQueue = "DIN_TRANSFER_OUT";
	private static final String wsCancelQueue = "DIN_WS_CANCEL";
	private static final String wsInitQueue = "DIN_WS_INIT";
	private static final String wsNotificationQueue = "DIN_WS_NOTIFICATION_OUT";

	private LoadType loadType;

	@Override
	protected void startLoading() throws Exception {
		DinersClient dinersClient = new DinersClient(mqUrl, wsInitQueue);
		dinersClient.startLoading(loadType, sessionId, getFilename(), getEncoding(), getInputDir(), getOutputDir(), getErrorDir(), getDataTransferQueue());
	}

	@Override
	protected void processParameters(Map<String, Object> parameters) throws Exception {
		if (parameters.containsKey(LOAD_TYPE_PARAM_NAME)) {
			loadType = LoadType.getByArticleCode(((String) parameters.get(LOAD_TYPE_PARAM_NAME)).substring(LoadType.DICT_CODE.length()));
		} else {
			throw new UserException("Can't find " + LOAD_TYPE_PARAM_NAME + " parameter");
		}
		if (getEncoding() == null) {
			throw new UserException("File character set is not defined");
		}
	}

	@Override
	protected Object getLogMessagePrefix() {
		return loadType;
	}

	@Override
	protected String getWsCancelQueue() {
		return wsCancelQueue;
	}

	@Override
	protected String getDataTransferQueue() {
		return transferQueue;
	}

	@Override
	protected String getWsNotificationQueue() {
		return wsNotificationQueue;
	}
}

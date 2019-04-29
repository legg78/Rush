package ru.bpc.sv2.scheduler.process.jcb;

import ru.bpc.sv.ws.jcb.clients.JcbClient;
import ru.bpc.sv2.jcb.enums.LoadType;
import ru.bpc.sv2.scheduler.process.svng.AbstractSvngModuleLoadFileSaver;
import ru.bpc.sv2.utils.UserException;

import java.util.Map;

@SuppressWarnings("unused")
public class JcbLoadSaver extends AbstractSvngModuleLoadFileSaver {
	private static final String LOAD_TYPE_PARAM_NAME = "I_JCB_LOAD_TYPE";
	private static final String transferQueue = "JCB_TRANSFER_OUT";
	private static final String wsCancelQueue = "JCB_WS_CANCEL";
	private static final String wsInitQueue = "JCB_WS_INIT";
	private static final String wsNotificationQueue = "JCB_WS_NOTIFICATION";

	private LoadType loadType;

	@Override
	protected void startLoading() throws Exception {
		JcbClient jcbClient = new JcbClient(mqUrl, wsInitQueue);
		jcbClient.startLoading(loadType, sessionId, getFilename(), getEncoding(), getInputDir(), getOutputDir(), getErrorDir(), getDataTransferQueue());
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

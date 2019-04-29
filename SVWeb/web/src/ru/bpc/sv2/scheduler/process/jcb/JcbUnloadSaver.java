package ru.bpc.sv2.scheduler.process.jcb;

import ru.bpc.sv.ws.jcb.clients.JcbClient;
import ru.bpc.sv2.jcb.enums.LoadType;
import ru.bpc.sv2.scheduler.process.svng.AbstractSvngModuleUnloadFileSaver;
import ru.bpc.sv2.utils.UserException;

import java.util.Map;

@SuppressWarnings("unused")
public class JcbUnloadSaver extends AbstractSvngModuleUnloadFileSaver {
	private static final String LOAD_TYPE_PARAM_NAME = "I_JCB_LOAD_TYPE";

	private static final String wsServiceQueue = "JCB_WS_INIT";
	private static final String wsNotificationOutQueue = "JCB_WS_NOTIFICATION";
	private static final String transferQueue = "JCB_TRANSFER_IN";
	private static final String wsCancelQueue = "JCB_WS_CANCEL";

	private LoadType loadType;

	@Override
	protected void processParameters(Map<String, Object> parameters) throws Exception {
		super.processParameters(parameters);
		if (parameters.containsKey(LOAD_TYPE_PARAM_NAME)) {
			loadType = LoadType.getByArticleCode(((String) parameters.get(LOAD_TYPE_PARAM_NAME)).substring(LoadType.DICT_CODE.length()));
		} else {
			throw new UserException("Can't find " + LOAD_TYPE_PARAM_NAME + " parameter");
		}
	}

	@Override
	protected String getDataType() throws Exception {
		switch (loadType) {
			case JCB_MERCHANT:
				return "MERCHANT";
			case JCB_CLEARING_OUT:
				return "CLEARING";
			default:
				throw new UserException(String.format("Unsupported %s parameter value: %s", LOAD_TYPE_PARAM_NAME, loadType.getArticleCodeFull()));
		}
	}

	@Override
	protected void startUnloading() throws Exception {
		trace("send ready to unload notification...");
		JcbClient jcbClient = new JcbClient(mqUrl, wsServiceQueue);
		switch (loadType) {
			case JCB_MERCHANT:
				jcbClient.startUnloadingMerchantData(sessionId, fileAttributes.getFileName(), null, null, fileAttributes.getLocation(), null);
				break;
			case JCB_CLEARING_OUT:
				jcbClient.startUnloadingClearingData(sessionId, fileAttributes.getFileName(), null, null, fileAttributes.getLocation(), null);
				break;
			default:
				throw new UserException(String.format("Unsupported %s parameter value: %s", LOAD_TYPE_PARAM_NAME, loadType.getArticleCodeFull()));
		}
		super.startUnloading();
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
	protected String getWsNotificationOutQueue() {
		return wsNotificationOutQueue;
	}
}

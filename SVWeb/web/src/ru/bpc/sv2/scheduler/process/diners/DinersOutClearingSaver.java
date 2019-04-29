package ru.bpc.sv2.scheduler.process.diners;

import ru.bpc.sv2.scheduler.process.svng.AbstractSvngModuleUnloadFileSaver;

@SuppressWarnings("unused")
public class DinersOutClearingSaver extends AbstractSvngModuleUnloadFileSaver {

	private static final String wsNotificationOutQueue = "DIN_WS_NOTIFICATION_OUT";
	private static final String transferQueue = "DIN_TRANSFER_IN";
	private static final String wsCancelQueue = "DIN_WS_CANCEL";

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

	@Override
	protected String getDataType() {
		return "CLEARING";
	}
}

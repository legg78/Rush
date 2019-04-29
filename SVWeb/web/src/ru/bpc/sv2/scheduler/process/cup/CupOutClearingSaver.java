package ru.bpc.sv2.scheduler.process.cup;

import org.apache.commons.lang3.NotImplementedException;
import ru.bpc.sv.ws.cup.clients.NotificationClient;
import ru.bpc.sv.ws.cup.jms.DataMessageSender;
import ru.bpc.sv.ws.cup.servers.CancelServer;
import ru.bpc.sv.ws.cup.servers.NotificationServer;
import ru.bpc.sv2.cup.FileContents;
import ru.bpc.sv2.logic.transfer.TransferDao;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import java.math.BigDecimal;
import java.util.concurrent.atomic.AtomicBoolean;

@SuppressWarnings("unused")
public class CupOutClearingSaver extends AbstractFileSaver {
	private static final String TIMEOUT_PARAM_KEY = "I_TIMEOUT";

	@SuppressWarnings("FieldCanBeLocal")
	private TransferDao transferDao;
	private long timeout = 120;

	private static final String wsNotificationQueue = "CUP_WS_NOTIFICATION_QUEUE";
	private static final String wsNotificationOutQueue = "CUP_WS_NOTIFICATION_OUT_QUEUE";
	private static final String transferQueue = "CUP_TRANSFER_IN_QUEUE";
	private static final String wsCancelQueue = "CUP_WS_CANCEL_QUEUE";

	@Override
	public void save() throws Exception {
		setupTracelevel();
		trace("CupOutClearingSaver::execute...");
		if (params.containsKey(TIMEOUT_PARAM_KEY)) {
			timeout = ((BigDecimal) params.get(TIMEOUT_PARAM_KEY)).longValue();
		}
		final AtomicBoolean finish = new AtomicBoolean(false);
		final AtomicBoolean failed = new AtomicBoolean(false);
		CancelServer cancelSever = null;
		NotificationServer notificationServer = null;
		DataMessageSender sender = null;
		try {
			transferDao = new TransferDao();
			String mqUrl =
					SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
			Long totalRecords = transferDao.getFileItemsCnt(sessionId);
			if (totalRecords == null || mqUrl == null || totalRecords == 0L) {
				throw new Exception("Not data found for session id " + sessionId);
			}
			trace("CupOutClearingSaver::launch cancel server");
			cancelSever = new CancelServer(mqUrl, wsCancelQueue, new CancelServer.CancelListener() {
				@Override
				public void onCancel(String reason) {
					error("Received cancel by WS. Reason is " + reason);
					finish.getAndSet(true);
					failed.getAndSet(true);
				}
			});
			cancelSever.start();
			trace("CupOutClearingSaver::send ready to unload notification");
			NotificationClient notificationClient = new NotificationClient(mqUrl, wsNotificationQueue);
			notificationClient.sendReadyToUnloadNotification(totalRecords);
			trace("CupOutClearingSaver::start notification server");
			notificationServer =
					new NotificationServer(mqUrl, wsNotificationOutQueue,
							new NotificationServer.NotificationListener() {
								@Override
								public void onNotification() {
									trace("CupOutClearingSaver::received file saved notification");
									finish.getAndSet(true);
								}
								@Override
								public void onFileLoadedNotification(long totalRecords, int totalPackages) {
									throw new NotImplementedException("Not implemented");
								}
							});
			notificationServer.start();
			sender = new DataMessageSender(mqUrl, sessionId, transferQueue);
			FileContents content = transferDao.getFileContents(sessionId);
			sender.sendOperations(content.getFilename(), content.getContent(), totalRecords, "CLEARING");
			int i = 0;
			while (!finish.get()) {
				Thread.sleep(1000);
				i++;
				if (i >= timeout) {
					throw new Exception("No actions in " + timeout + " seconds");
				}
			}
			if (failed.get()) {
				throw new Exception("Error occurred. Check the log for more details");
			}
		} finally {
			if (cancelSever != null) {
				cancelSever.stop();
			}
			if (notificationServer != null) {
				notificationServer.stop();
			}
			if (sender != null) {
				sender.close();
			}
		}
	}
}

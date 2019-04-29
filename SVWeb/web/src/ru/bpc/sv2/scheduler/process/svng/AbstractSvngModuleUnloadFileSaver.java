package ru.bpc.sv2.scheduler.process.svng;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.lang3.NotImplementedException;
import ru.bpc.sv.ws.cup.jms.DataMessageSender;
import ru.bpc.sv.ws.cup.servers.CancelServer;
import ru.bpc.sv.ws.cup.servers.NotificationServer;
import ru.bpc.sv2.cup.FileContents;
import ru.bpc.sv2.logic.transfer.TransferDao;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

public abstract class AbstractSvngModuleUnloadFileSaver extends AbstractFileSaver {
	private TransferDao transferDao;
	private AtomicBoolean finished;
	private AtomicBoolean failed;
	private AtomicReference<String> errorMessage;
	private CancelServer cancelSever;
	private NotificationServer notificationServer;
	private DataMessageSender sender;
	private Long totalRecords;
	protected String mqUrl;

	@Override
	public void save() throws Exception {
		setupTracelevel();
		try {
			debug("initBeans...");
			initBeans();
			debug("processParameters...");
			processParameters(getParams());
			info("prepare to unload...");
			prepareToUnload();
			info("starting unloading...");
			startUnloading();
			info("unloading started, waiting for result...");
			waitForResult();
		} catch (Exception e) {
			if (e instanceof UserException || e instanceof SystemException) {
				throw e;
			} else {
				throw new SystemException(e);
			}
		} finally {
			finalizeUnloading();
		}
	}

	private void initBeans() throws Exception {
		transferDao = new TransferDao();
	}

	protected void processParameters(Map<String, Object> parameters) throws Exception {

	}

	@SuppressWarnings("WeakerAccess")
	protected void prepareToUnload() throws Exception {
		finished = new AtomicBoolean(false);
		failed = new AtomicBoolean(false);

		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (mqUrl == null) {
			mqUrl = "tcp://localhost:61616";
			warn("No mq address in db, use default: " + mqUrl);
		}

		totalRecords = transferDao.getFileItemsCnt(sessionId);
		if (totalRecords == null || totalRecords == 0L) {
			throw new Exception("Not data found for session id " + sessionId);
		}

		trace("launch cancel server...");
		errorMessage = new AtomicReference<String>("Error occurred. Check the log for more details");
		cancelSever = new CancelServer(mqUrl, getWsCancelQueue(), new CancelServer.CancelListener() {
			@Override
			public void onCancel(String reason) {
				String message = "Received cancel by WS. Reason is " + reason;
				errorMessage.set(message);
				error(message);
				finished.getAndSet(true);
				failed.getAndSet(true);
			}
		});
		cancelSever.start();
		trace("start notification server....");
		notificationServer =
				new NotificationServer(mqUrl, getWsNotificationOutQueue(),
						new NotificationServer.NotificationListener() {
							@Override
							public void onNotification() {
								info("received file saved notification");
								finished.getAndSet(true);
							}

							@Override
							public void onFileLoadedNotification(long totalRecords, int totalPackages) {
								throw new NotImplementedException("Not implemented");
							}
						});
		notificationServer.start();
		sender = new DataMessageSender(mqUrl, sessionId, getDataTransferQueue());
	}

	protected void startUnloading() throws Exception {
		FileContents content = transferDao.getFileContents(sessionId);
		sender.sendOperations(FilenameUtils.concat(fileAttributes.getLocation(), content.getFilename()),
				content.getContent(), totalRecords, getDataType());
	}

	private void waitForResult() throws Exception {
		long timeout = getTimeout();
		debug(String.format("waiting for %d seconds...", timeout));
		int i = 0;
		while (!finished.get()) {
			Thread.sleep(1000);
			i++;
			if (i >= timeout) {
				throw new Exception("No actions in " + timeout + " seconds");
			}
		}
		if (failed.get()) {
			throw new Exception(errorMessage.get());
		}
	}

	@SuppressWarnings("WeakerAccess")
	protected void finalizeUnloading() {
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

	protected abstract String getWsCancelQueue();

	protected abstract String getDataTransferQueue();

	protected abstract String getWsNotificationOutQueue();

	protected abstract String getDataType() throws Exception;

}

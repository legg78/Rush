package ru.bpc.sv2.scheduler.process.svng;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.NotImplementedException;
import ru.bpc.sv.ws.cup.jms.JmsQueueService;
import ru.bpc.sv.ws.cup.servers.CancelServer;
import ru.bpc.sv.ws.cup.servers.NotificationServer;
import ru.bpc.sv2.logic.transfer.TransferDao;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public abstract class AbstractSvngModuleLoadFileSaver extends AbstractFileSaver {
	private TransferDao transferDao;
	private List<Long> ids = Collections.synchronizedList(new ArrayList<Long>());
	private JmsQueueService jmsService = null;
	private CancelServer cancelServer = null;
	private NotificationServer notificationServer = null;
	private final AtomicBoolean finished = new AtomicBoolean(false);
	private final AtomicBoolean failed = new AtomicBoolean(false);
	private Exception failException;
	private boolean rollbackDone;
	protected String mqUrl;

	@Override
	public final void save() throws Exception {
		setupTracelevel();
		try {
			debug("initBeans...");
			initBeans();
			debug("processParameters...");
			processParameters(getParams());
			debug("processInputStream...");
			processInputStream(getInputStream());
			// Close inputstream as we don't need it anymore.
			IOUtils.closeQuietly(inputStream);
			info("prepare to load...");
			prepareToLoad();
			info("starting loading...");
			startLoading();
			info("loading started, waiting for result...");
			waitForResult();
		} catch (Exception e) {
			rollback(e);
			if (e instanceof UserException || e instanceof SystemException) {
				throw e;
			} else {
				throw new SystemException(e);
			}
		} finally {
			finalizeLoading();
		}
	}

	private void initBeans() throws Exception {
		transferDao = new TransferDao();
	}

	protected void processParameters(Map<String, Object> parameters) throws Exception {

	}

	@SuppressWarnings({"WeakerAccess", "UnusedParameters"})
	protected void processInputStream(InputStream inputStream) {

	}

	protected abstract void startLoading() throws Exception;

	@SuppressWarnings("WeakerAccess")
	protected void prepareToLoad() throws Exception {
		debug(String.format("launch cancel server for queue %s...", getWsCancelQueue()));
		mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (mqUrl == null) {
			mqUrl = "tcp://localhost:61616";
			warn("No mq address in db, use default: " + mqUrl);
		}
		cancelServer = new CancelServer(mqUrl, getWsCancelQueue(), new CancelServer.CancelListener() {
			@Override
			public void onCancel(String reason) {
				rollback(new Exception("Received cancel by WS. Reason is " + reason));
			}
		});
		cancelServer.start();

		final String dataTransferQueue = getDataTransferQueue();
		debug(String.format("launch jms queue listener for queue %s...", dataTransferQueue));
		jmsService = new JmsQueueService(mqUrl, dataTransferQueue, new JmsQueueService.JmsQueueListener() {
			@Override
			public void onReceiveData(String fileName, String svxp, long recordsNum, boolean lastPackage) {
				try {
					info(String.format("Received file %s with %d records from %s", fileName, recordsNum, dataTransferQueue));
					if (recordsNum == 0L) {
						rollback(new Exception("No data found"));
					} else {
						ids.add(transferDao.savePackage(sessionId, Long.valueOf(process.getId()), fileName,
								getFileAttributes().getFileType(), svxp, recordsNum));
						if (lastPackage) {
							finished.getAndSet(true);
						}
					}
				} catch (Exception ex) {
					rollback(ex);
				}
			}

			@Override
			public void onError(Exception ex) {
				rollback(ex);
			}
		});
		jmsService.start();

		debug(String.format("launch notification server for queue %s...", getWsNotificationQueue()));
		notificationServer =
				new NotificationServer(mqUrl, getWsNotificationQueue(),
						new NotificationServer.NotificationListener() {
							@Override
							public void onNotification() {
								throw new NotImplementedException("Not implemented");
							}

							@Override
							public void onFileLoadedNotification(long totalRecords, int totalPackages) {
								info(String.format("Received response. SVFE has sent %d packages in queue with %d records",
										totalPackages, totalRecords));
							}
						});
		notificationServer.start();
	}

	private void waitForResult() throws Exception {
		long timeout = getTimeout();
		debug(String.format("waiting for %d seconds...", timeout));
		int i = 0;
		while (!finished.get()) {
			Thread.sleep(1000);
			i++;
			if (i >= timeout) {
				rollback(new Exception(String.format("No actions in %d seconds", timeout)));
			}
		}
		if (failed.get()) {
			throw failException;
		}
	}

	public void rollback(Exception failException) {
		info(String.format("rollback saved data... (%s)", failException.getMessage()));
		try {
			if (ids != null && !ids.isEmpty()) {
				transferDao.deleteSavedData(sessionId, ids);
			}
			if (rollbackDone) {
				return;
			}
			failed.getAndSet(true);
			finished.getAndSet(true);
			this.failException = failException;
		} catch (Exception e) {
			error(e);
		} finally {
			rollbackDone = true;
		}
	}

	@SuppressWarnings("WeakerAccess")
	protected void finalizeLoading() {
		if (cancelServer != null) {
			cancelServer.stop();
		}
		if (notificationServer != null) {
			notificationServer.stop();
		}
		if (jmsService != null) {
			jmsService.stop();
		}
	}

	protected abstract String getWsCancelQueue();

	protected abstract String getDataTransferQueue();

	protected abstract String getWsNotificationQueue();
}

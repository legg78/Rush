package ru.bpc.sv2.scheduler.process.cup;

import com.bpcbt.sv.cup.message.v1.FileLoadResponse;
import ru.bpc.sv.ws.cup.clients.CupClient;
import ru.bpc.sv.ws.cup.jms.JmsQueueService;
import ru.bpc.sv.ws.cup.servers.CancelServer;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.cup.enums.LoadType;
import ru.bpc.sv2.logic.transfer.TransferDao;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.File;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

@SuppressWarnings("unused")
public class CupLoadSaver extends AbstractFileSaver {

	private static final String LOAD_TYPE_PARAM_NAME = "I_CUP_LOAD_TYPE";
	private static final String TIMEOUT_PARAM_KEY = "I_TIMEOUT";
	private static final String ISSUER_PARAM_KEY = "I_ISSUER";

	private static final String transferQueue = "CUP_TRANSFER_OUT";
	private static final String wsCancelQueue = "CUP_WS_CANCEL";
	private static final String wsInitQueue = "CUP_WS_INIT";

	private long timeout;
	private boolean issuer;
	private String filename;
	private String encoding;
	private String inputDir;
	private String outputDir;
	private String errorDir;
	private LoadType loadType;
	private TransferDao transferDao;

	private List<Long> ids = Collections.synchronizedList(new ArrayList<Long>());
	private JmsQueueService jmsService = null;
	private CancelServer cancelSever = null;
	private final AtomicBoolean finished = new AtomicBoolean(false);
	private final AtomicBoolean failed = new AtomicBoolean(false);
	private Exception failException;

	@Override
	public void save() throws Exception {
		setupTracelevel();
		try {
			setProcessParameters(params);
			initBeans();
			executeBody();
		} catch (Exception e) {
			rollback(e);
			if (e instanceof UserException) {
				throw new UserException(e);
			} else {
				throw new SystemException(e);
			}
		}
	}

	private void executeBody() throws Exception {
		trace(loadType + " Load Saver::execute...");
		String mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (mqUrl == null) {
			trace(loadType + " Saver Process::no mq address in db, use tcp://localhost:61616");
			mqUrl = "tcp://localhost:61616";
		}
		try {
			trace(loadType + " Saver Process::launch cancel server");
			cancelSever = new CancelServer(mqUrl, wsCancelQueue, new CancelServer.CancelListener() {
				@Override
				public void onCancel(String reason) {
					trace(loadType + " Saver Process::received cancel by WS. Reason is " + reason);
					rollback(new Exception("Received cancel by WS. Reason is " + reason));
				}
			});
			cancelSever.start();
			trace(loadType + " Saver Process::launch jms queue listener");
			jmsService = new JmsQueueService(mqUrl, transferQueue, new JmsQueueService.JmsQueueListener() {
				@Override
				public void onReceiveData(String fileName, String svxp, long recordsNum, boolean lastPackage) {
					try {
						if (recordsNum == 0L) {
							rollback(new Exception("No data found"));
						}
						ids.add(transferDao.savePackage(sessionId, Long.valueOf(process.getId()), fileName,
								getFileAttributes().getFileType(), svxp, recordsNum));
						if (lastPackage) {
							finished.getAndSet(true);
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
			trace(loadType + " Saver Process::create init ws-client");
			CupClient cupClient = new CupClient(mqUrl, wsInitQueue);
			FileLoadResponse response =
					cupClient.startLoading(loadType, sessionId, filename, encoding, inputDir,
							outputDir, errorDir, transferQueue, issuer, timeout);
			trace(loadType + " Saver Process::received response. SVFE has sent " + response.getTotalPackages() +
					" packages in queue with " + response.getTotalRecords() + " records");
			int i = 0;
			while (!finished.get()) {
				Thread.sleep(1000);
				i++;
				if (i >= timeout) {
					rollback(new Exception("No actions in " + timeout + " seconds"));
				}
			}
			if (failed.get()) {
				throw failException;
			}
		} finally {
			if (cancelSever != null) {
				cancelSever.stop();
			}
			if (jmsService != null) {
				jmsService.stop();
			}
		}
	}

	public void rollback(Exception failException) {
		trace(loadType + " Saver Process::rollback saved data");
		try {
			if (ids != null && !ids.isEmpty()) {
				transferDao.deleteSavedData(sessionId, ids);
			}
			finished.getAndSet(true);
			failed.getAndSet(true);
			this.failException = failException;
			error(failException);
		} catch (Exception e) {
			error(e);
		}
	}

	public void setProcessParameters(Map<String, Object> parameters) {
		if (parameters.containsKey(LOAD_TYPE_PARAM_NAME)) {
			Integer loadIndex =
					Integer.valueOf(((String) parameters.get(LOAD_TYPE_PARAM_NAME)).replaceAll("CUPV00", "")) - 1;
			loadType = LoadType.values()[loadIndex];
		} else {
			error("Can't find " + LOAD_TYPE_PARAM_NAME + " parameter");
		}
		issuer = (((BigDecimal) parameters.get(ISSUER_PARAM_KEY)).intValue() == 1);
		timeout = ((BigDecimal) parameters.get(TIMEOUT_PARAM_KEY)).longValue();
		trace(loadType + " Saver Process::initiated parameters");
	}

	private void initBeans() throws SystemException {
		trace(loadType + " Saver Process::initBeans...");
		try {

			transferDao = new TransferDao();
			filename = getFileAttributes().getFileName();
			if (filename == null) {
				throw new UserException("File name is not defined");
			}
			encoding = getFileAttributes().getCharacterSet();
			if (encoding == null || encoding.isEmpty()) {
				encoding = "ASCII";
			}
			String directory = getFileAttributes().getLocation();
			if (directory == null) {
				throw new UserException("File directory is not defined");
			}
			if (!directory.endsWith("/") && !directory.endsWith("\\")) {
				directory += File.separator;
			}
			inputDir = directory + ProcessConstants.IN_PROCESS_FOLDER + File.separator;
			outputDir = directory + ProcessConstants.PROCESSED_FOLDER + File.separator;
			errorDir = directory + ProcessConstants.REJECTED_FOLDER + File.separator;
		} catch (Exception e) {
			throw new SystemException(e.getMessage(), e);
		}
	}
}

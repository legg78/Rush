package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.sv_sync.SyncResultFileType;
import com.bpcbt.sv.sv_sync.SyncResultType;
import ru.bpc.sv.ws.process.svng.CallbackService;
import ru.bpc.sv.ws.process.svng.WsClient;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.external.svng.NotificationListener;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.svng.DataTypes;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

public abstract class WebServiceSaver extends ActiveMQSaver {
	private Integer waitSeconds;
	private boolean fromWs;
	private EventsDao evensDao = new EventsDao();
	private ProcessDao _processDao;
	private boolean reject = false;

	protected String callbackAddress;
	SettingsCache settingParamsCache = SettingsCache.getInstance();

	@Override
	public void save() throws Exception {
		boolean invalidCallback = false;
		initCallBackAddress();
		initBeans();
		fromWs = false;
		try {
			logger.debug("start saver: " + this.getClass().getName());
			waitSeconds = fileAttributes.getTimeWait();
			if (sessionId == null) {
				sessionId = fileAttributes.getSessionId();
			}
			loggerDB.debug(new TraceLogInfo(sessionId, getClass().getSimpleName() + ": sending files"));

			final AtomicBoolean finishFlag = new AtomicBoolean(false);
			final AtomicBoolean failedFlag = new AtomicBoolean(false);
			final AtomicInteger resultCode = new AtomicInteger();
			final StringBuilder errorMsg = new StringBuilder();

			NotificationListener listener = new NotificationListener() {
				@Override
				public void notify(Map<String, Object> values) {
					fromWs = true;
					SyncResultType result = (SyncResultType) values.get("result");
					boolean error = result.getCode() != 0 && result.getCode() != 1;
					resultCode.getAndSet(result.getCode());
					String logMsg = "Received ws " + (error ? "error " : "") + "result: " + getSyncResultCodeDesc(result) + "  Session ID:" + sessionId.toString();
					if (error) {
						loggerDB.error(new TraceLogInfo(sessionId, WebServiceSaver.this.getClass().getSimpleName() + ": " + logMsg + "\n" + rejectedFiles(result)));
						logger.error(logMsg);
					} else {
						loggerDB.info(new TraceLogInfo(sessionId, WebServiceSaver.this.getClass().getSimpleName() + ": " + logMsg));
						logger.info(logMsg);
					}
					if (error) {
						errorMsg.append(logMsg);
						failedFlag.getAndSet(true);
					}
					finishFlag.getAndSet(true);
				}
			};

			NotificationListener invalidationListener = new NotificationListener() {
				@Override
				public void notify(Map<String, Object> values) {
					try {
						Long sessionIdCancel = Long.parseLong((String) values.get("sessionId"));
						fromWs = true;
						String logMsg = "Got invalidation request for " + sessionIdCancel;
						logger.warn(logMsg);
						loggerDB.warn(new TraceLogInfo(sessionId, WebServiceSaver.this.getClass().getSimpleName() + ": " + logMsg));
						errorMsg.append(logMsg);
					} catch (Exception ex) {
						String logMsg = "Invalidation error: " + ex.getMessage();
						logger.error(logMsg, ex);
						loggerDB.error(new TraceLogInfo(sessionId, WebServiceSaver.this.getClass().getSimpleName() + ": " + logMsg));
						errorMsg.append(logMsg);
					}finally {
						failedFlag.getAndSet(true);
						finishFlag.getAndSet(true);
					}
				}
			};

			CallbackService.addInvalList(sessionId.toString(), invalidationListener);

			try {

				if(sendRequestWs(listener, settingParamsCache.getParameterStringValue(SettingsConstants.APACHE_CAMEL_LOCATION)  + "/services/load", finishFlag, failedFlag, resultCode, errorMsg)){
					sendRequestWs(listener, settingParamsCache.getParameterStringValue(SettingsConstants.BPEL_URL), finishFlag, failedFlag, resultCode, errorMsg);
				}

				if (resultCode.get() == 1) {
					ProcessFileAttribute attrIncomming = getFileInAttributes();
					if (attrIncomming == null) {
						throw new UserException("There are no values of parameters of the incoming file.");
					}
					reject = true;
					RejectWsSaver rejectWsSaver = new RejectWsSaver();
					rejectWsSaver.setConnection(con);
					//saverWs.setInputStream(fileContentsStream);
					rejectWsSaver.setSessionId(sessionId);
					rejectWsSaver.setUserSessionId(userSessionId);
					rejectWsSaver.setUserName(userName);
					rejectWsSaver.setParams(getParams());
					rejectWsSaver.setFileAttributes(attrIncomming);
					rejectWsSaver.setProcess(process);
					//saverWs.setFiles(filesWs);
					rejectWsSaver.save();

				}

			} catch (Exception e) {
				logger.error(e.getMessage(), e);
				invalidCallback = true;
				callInvalidationService(e.getMessage(), sessionId, !fromWs);
				throw e;
			} finally {

				while (!filesQueue.isClosedAndEmpty()) {
					try {
						while (!finishFlag.get() && !filesQueue.isClosed())
							Thread.sleep(500);
						filesQueue.poll();
					} catch (InterruptedException ignored) {
					}
				}
				logger.info("queue is cleared");
				if (Thread.currentThread().isInterrupted()) {
					throw new SystemException(getClass().getSimpleName() + " has been interrupted");
				}

				if (con != null) {
					con.close();
				}
			}
		} finally {
			logger.debug("finally saver " + this.getClass().getName());
			if(!invalidCallback && !reject) {
				CallbackService.removeListener(sessionId.toString());
				CallbackService.removeInvalList(sessionId.toString());
			}
		}
	}

	private boolean sendRequestWs(NotificationListener listener, String endpoint, AtomicBoolean finishFlag, AtomicBoolean failedFlag, AtomicInteger resultCode, StringBuilder errorMsg) throws Exception {
		finishFlag.getAndSet(false);
		failedFlag.getAndSet(false);
		resultCode.getAndSet(0);
		errorMsg.setLength(0);
		CallbackService.addListener(sessionId.toString(), listener);
		WsClient client = new WsClient(endpoint, callbackAddress, sessionId, getDataType());
		client.sendRequest(params);
		int i = 0;
		while (!finishFlag.get() && i++ < getWaitSeconds()) {
			Thread.sleep(1000);
		}

		if (!finishFlag.get()) {
			throw new UserException("Error. Time out of " + getWaitSeconds() +
					" has passed and no data has been received. Session: " + sessionId);
		}

		if (failedFlag.get()) {
			throw new UserException(errorMsg.toString());
		}
		return true;
	}

	protected void initBeans() throws SystemException {
		_processDao = new ProcessDao();
	}

	protected abstract DataTypes getDataType();

	public Integer getWaitSeconds() {
		if (waitSeconds == null) {
			waitSeconds = 30;
		}
		return waitSeconds;
	}


	@Override
	public boolean isRequiredOutFiles() {
		return false;
	}

	protected void initCallBackAddress() {
		callbackAddress = CommonUtils.getWsCallbackUrl(params);
		if (params.containsKey("wsServerName")) {
			params.remove("wsServerName");
		}
		if (params.containsKey("wsPort")) {
			params.remove("wsPort");
		}
	}

	private String rejectedFiles(SyncResultType result) {
		if (result.getRejectedFiles() == null) {
			return "";
		}
		List<SyncResultFileType> files = result.getRejectedFiles().getFile();
		if (files == null || files.size() == 0) {
			return "";
		}
		StringBuilder sb = new StringBuilder();
		sb.append("Rejected files:").append("\n");
		for (SyncResultFileType file : files) {
			sb.append("Rejected file name:").append(file.getName()).append("   Error code:").append(file.getExitCode()).append("\n");
		}
		logger.debug(sb.toString());
		return sb.toString();
	}

	private ProcessFileAttribute getFileInAttributes() throws SystemException {
		ProcessFileAttribute[] result;
		try {
			result = _processDao.getIncomingFilesForProcess(userSessionId,
					sessionId,
					process.getContainerBindId());
		} catch (DataAccessException e) {
			logger.error("", e);
			throw new SystemException(e.getMessage(), e);
		}
		if (result != null && result.length > 0) {
			return result[0];
		}
		return null;
	}

	public boolean isReject() {
		return reject;
	}
}

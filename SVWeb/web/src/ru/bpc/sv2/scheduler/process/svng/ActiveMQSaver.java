package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.sv_sync.SyncResultFileType;
import com.bpcbt.sv.sv_sync.SyncResultType;
import org.apache.commons.io.IOUtils;
import ru.bpc.sv.ws.cup.jms.DataMessageSender;
import ru.bpc.sv.ws.process.svng.CallbackService;
import ru.bpc.sv.ws.process.svng.Invalidation;
import ru.bpc.sv.ws.process.svng.WsClient;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.external.svng.NotificationListener;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.svng.DataTypes;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.*;

import javax.sql.DataSource;
import java.sql.*;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;

public abstract class ActiveMQSaver extends AbstractFileSaver {
	protected String queue;
	private Integer waitSeconds;
	private boolean fromWs;
	protected CloseableBlockingQueue<ProcessFileAttribute> filesQueue;
	private ProcessDao _processDao;
	private boolean reject = false;

	protected String callbackAddress;
	SettingsCache settingParamsCache = SettingsCache.getInstance();

	public Future<Boolean> saveAsync() {
		setupTracelevel();
		logger.info("Start saver: " + this.getClass().getName() + " in async mode");
		ExecutorService executor = Executors.newSingleThreadExecutor();
		return executor.submit(new Callable<Boolean>() {
	@Override
			public Boolean call() throws Exception {
				save();
				return true;
			}
		});
	}

	@Override
	public void save() throws Exception {
		setupTracelevel();
		initCallBackAddress();
		initBeans();
		fromWs = false;
		try {
			logger.info("Start saver: " + this.getClass().getName());
			queue = fileAttributes.getQueueIdentifier();
			waitSeconds = fileAttributes.getTimeWait();
			if (queue == null) {
				throw new UserException("No queue name");
			}
			if (sessionId == null) {
				sessionId = fileAttributes.getSessionId();
			}

			loggerDB.debug(new TraceLogInfo(sessionId, process.getContainerBindId(), getClass().getSimpleName()+": sending files"));

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
						loggerDB.error(new TraceLogInfo(sessionId, process.getContainerBindId(), ActiveMQSaver.this.getClass().getSimpleName() + ": " + logMsg + "\n" + rejectedFiles(result)));
						logger.error(logMsg);
					} else {
						loggerDB.info(new TraceLogInfo(sessionId, process.getContainerBindId(), ActiveMQSaver.this.getClass().getSimpleName() + ": " + logMsg));
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
						loggerDB.warn(new TraceLogInfo(sessionId, process.getContainerBindId(), ActiveMQSaver.this.getClass().getSimpleName() + ": " + logMsg));
						errorMsg.append(logMsg);
					} catch (Exception ex) {
						String logMsg = "Invalidation error: " + ex.getMessage();
						logger.error(logMsg, ex);
						loggerDB.error(new TraceLogInfo(sessionId, process.getContainerBindId(), ActiveMQSaver.this.getClass().getSimpleName() + ": " + logMsg));
						errorMsg.append(logMsg);
					} finally {
						failedFlag.getAndSet(true);
						finishFlag.getAndSet(true);
					}
				}
			};

			CallbackService.addListener(sessionId.toString(), listener);
			CallbackService.addInvalList(sessionId.toString(), invalidationListener);

			ResultSet rs;
			DataMessageSender jmsSender = null;

			try {
				long totalRecords = 0;
				long fetchedFiles = 0;
				while (!filesQueue.isClosedAndEmpty()) {
					ProcessFileAttribute file = null;
					try {
						// Wait until queue has at least 2 elements or is closed. That is needed because when we send
						// a pack to MQ, that pack's records-total may be equal to pack's number only for the last pack
						// and no other packs should have records-total equal to the total packs number
						while (!finishFlag.get() && !filesQueue.isClosed() && filesQueue.size() < 2) {
							Thread.sleep(500);
						}
						file = filesQueue.poll();
					} catch (InterruptedException ignored) {}
					if (Thread.currentThread().isInterrupted()) {
						throw new SystemException(getClass().getSimpleName() + " has been interrupted");
					}
					if (finishFlag.get()) {
						break;
					}
					if (file != null) {
						if(file.getRecordCount() == null || file.getRecordCount().equals(0L)) {
							logger.info("File: " + file.getFileName() + " id: " + file.getId() + " is empty");
							loggerDB.info(new TraceLogInfo(sessionId, process.getContainerBindId(), "File: " + file.getFileName() + " id: " + file.getId() + " is empty"));
							continue;
						}
						// Initialize connection to SOAP-server (SVFE1 adapter usually) because at this moment
						// we already know that there is at least one non-empty file to send
						if (jmsSender == null) {
							jmsSender = sendRequestToWs();
						}
						// Now start to send file data
						fetchedFiles++;
						boolean contentsRead = false;
						try (Connection con = JndiUtils.getConnection();
						     PreparedStatement stmt = con.prepareStatement("SELECT file_contents FROM prc_ui_file_out_vw WHERE id = ?")) {
							stmt.setLong(1, file.getId());
							rs = stmt.executeQuery();
							if (rs.next()) {
								Clob clob = rs.getClob("file_contents");
								if (clob != null) {
									totalRecords += file.getRecordCount();
									String pack = pack(file.getFileName(), totalRecords,
											file.getRecordCount(), fetchedFiles + filesQueue.size(), fetchedFiles,
											IOUtils.toString(clob.getCharacterStream()));
									String msg = "Sent pack with " + file.getRecordCount() + "/" + totalRecords + " records";
									logger.info(msg);
									loggerDB.debug(new TraceLogInfo(sessionId, process.getContainerBindId(), getClass().getSimpleName() + ": " + msg));
									jmsSender.sendOperationsNoPack(pack);
									contentsRead = true;
								}
							}
							if (!contentsRead) {
								String msg = "Could not read contents for file " + file.getId();
								logger.warn(msg);
								loggerDB.warn(new TraceLogInfo(sessionId, process.getContainerBindId(), getClass().getSimpleName() + ": " + msg));
							}
						}
					}
				}

				int i = 0;
				while (jmsSender != null && !finishFlag.get() && i++ < getWaitSeconds()) {
					Thread.sleep(1000);
				}

				if (jmsSender != null && !finishFlag.get()) {
					throw new UserException("Error. Time out of " + getWaitSeconds() +
											" has passed and no data has been received. Session: " + sessionId);
				}

				if (failedFlag.get()) {
					throw new UserException(errorMsg.toString());
				}

				if(resultCode.get() == 1){
					ProcessFileAttribute attrIncomming = getFileInAttributes();
					if(attrIncomming == null){
						throw new UserException("Some of unloaded data has been rejected, but no incoming reject file is configured for process");
					}
					reject = true;
					try (Connection con = JndiUtils.getConnection()) {
						RejectMqSaver rejectMqSaver = new RejectMqSaver();
						rejectMqSaver.setConnection(con);
						rejectMqSaver.setSessionId(sessionId);
						rejectMqSaver.setUserSessionId(userSessionId);
						rejectMqSaver.setUserName(userName);
						rejectMqSaver.setParams(getParams());
						rejectMqSaver.setFileAttributes(attrIncomming);
						rejectMqSaver.setProcess(process);
						rejectMqSaver.save();
					}
				}
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
				callInvalidationService(e.getMessage(), sessionId, !fromWs);
				throw e;
			} finally {
				if (jmsSender != null) {
					jmsSender.close();
				}
				// Close connection if it was set externally
				DBUtils.close(con);
			}
		} finally {
			logger.debug("finally saver " + this.getClass().getName());
			CallbackService.removeListener(sessionId.toString());
			CallbackService.removeInvalList(sessionId.toString());
		}
	}

	protected void initBeans() throws SystemException {
		_processDao = new ProcessDao();
	}

	protected void callInvalidationService(String errorMessage, Long sessionId, boolean isException){
		String message = getClass().getSimpleName() + " error: " + errorMessage + ". Initiating rollback";
		logger.error(errorMessage);
		loggerDB.error(new TraceLogInfo(sessionId, process.getContainerBindId(), message));

		Invalidation inv = new Invalidation(sessionId);
		inv.setCallbackAddress(callbackAddress);
		inv.setException(isException);
		inv.callCancel(userName);
	}

	protected abstract DataTypes getDataType();

	private DataMessageSender sendRequestToWs() throws Exception {
		WsClient client = new WsClient(settingParamsCache.getParameterStringValue(SettingsConstants.BPEL_URL),
									   callbackAddress, sessionId, getDataType());
		client.sendRequest(params);
		String mqUrl = settingParamsCache.getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		logger.info("Using active mq " + mqUrl);
		return new DataMessageSender(mqUrl, sessionId, queue);
	}

	private String pack(String fileName, Long recordsTotal, Long recordsInPack, Long packsTotal, long currentPack,
			String content) {
		StringBuilder sb = new StringBuilder("<?xml version=\"1.0\" encoding=\"UTF-8\"?>");
		sb.append(
			"<pack xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"mq_envelopment.xsd\">");
		sb.append("<header><data-type>");
		sb.append(getDataType().name());
		sb.append("</data-type><session-id>");
		sb.append(sessionId);
		sb.append("</session-id><file-name>");
		sb.append(fileName);
		sb.append("</file-name><number>");
		sb.append(currentPack);
		sb.append("</number><packs-total>");
		sb.append(packsTotal.toString());
		sb.append("</packs-total><records-number>");
		sb.append(recordsInPack);
		sb.append("</records-number><records-total>");
		sb.append(recordsTotal);
		sb.append("</records-total>");
		sb.append("<additional-inf xsi:type=\"anyType\"/></header><body xsi:type=\"anyType\"><![CDATA[");
		sb.append(content);
		sb.append("]]></body></pack>");
		return sb.toString();
	}

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

	public void setFilesQueue(CloseableBlockingQueue<ProcessFileAttribute> filesQueue) {
		this.filesQueue = filesQueue;
			}

	public void setFiles(List<ProcessFileAttribute> files) {
		this.filesQueue = new CloseableArrayBlockingQueue<ProcessFileAttribute>(files.size());
		filesQueue.addAll(files);
	}

	protected void initCallBackAddress(){
		callbackAddress = CommonUtils.getWsCallbackUrl(params);
		if(params.containsKey("wsServerName")){
			params.remove("wsServerName");
		}
		if(params.containsKey("wsPort")){
			params.remove("wsPort");
		}
	}


	private String rejectedFiles(SyncResultType result){
		if (result.getRejectedFiles() == null) {
			return "";
		}
		List<SyncResultFileType> files = result.getRejectedFiles().getFile();
		if(files == null || files.size() == 0){
			return "";
		}
		StringBuilder sb = new StringBuilder();
		sb.append("Rejected files:").append("\n");
		for(SyncResultFileType file : files){
			sb.append("Rejected file name:").append(file.getName()).append("   Error code:").append(file.getExitCode()).append("\n");
		}
		logger.info(sb.toString());
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
		if(result != null && result.length > 0){
			return result[0];
		}
		return null;
	}

	public boolean isReject() {
		return reject;
	}
}

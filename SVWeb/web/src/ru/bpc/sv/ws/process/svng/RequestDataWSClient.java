package ru.bpc.sv.ws.process.svng;

import com.bpcbt.sv.sv_sync.SyncResultType;
import org.apache.log4j.Logger;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.scheduler.process.external.svng.NotificationListener;
import ru.bpc.sv2.svng.DataTypes;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.utils.UserException;

import java.net.MalformedURLException;
import java.net.UnknownHostException;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;


public class RequestDataWSClient {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	protected static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	public static final int DEFAULT_REQUEST_TIMEOUT = 30;
	public static final int CODE_EMPTY_RESULT = 203;
	private Integer waitSeconds;
	private final AtomicBoolean stopFromWs = new AtomicBoolean(false);
	private WsClient client;
	private Long sessionId;

	public RequestDataWSClient(String address, Long sessionId, String callbackAddress, DataTypes type) throws UnknownHostException, MalformedURLException {
		this.sessionId = sessionId;
		client = new WsClient(address, callbackAddress, sessionId, type);
	}

	public boolean sendRequestByUpload(Map<String, Object> parameters) throws UserException {
		logger.info("RequestDataWSClient.sendRequestByUpload");
		final AtomicBoolean finishFlag = new AtomicBoolean(false);
		final AtomicBoolean failedFlag = new AtomicBoolean(false);
		final AtomicBoolean emptyFlag = new AtomicBoolean(false);
		final StringBuilder errorMsg = new StringBuilder();

		NotificationListener listener = new NotificationListener() {
			@Override
			public void notify(Map<String, Object> values) {
				SyncResultType result = (SyncResultType) values.get("result");
				boolean error = result.getCode() != 0 && result.getCode() != CODE_EMPTY_RESULT;
				String logMsg = "Received ws " + (error ? "error " : "") + "result: " + AbstractFileSaver.getSyncResultCodeDesc(result) + "  Session ID:" + sessionId.toString();
				if (error) {
					logger.error(logMsg);
					loggerDB.error(new TraceLogInfo(sessionId, getClass().getSimpleName() + ": " + logMsg));
					errorMsg.append(logMsg);
					failedFlag.getAndSet(true);
				} else {
					logger.info(logMsg);
					loggerDB.info(new TraceLogInfo(sessionId, getClass().getSimpleName() + ": " + logMsg));
				}
				if (result.getCode() == CODE_EMPTY_RESULT) {
					loggerDB.info(new TraceLogInfo(sessionId, getClass().getSimpleName() + ": got empty result"));
					emptyFlag.getAndSet(true);
				}
				finishFlag.getAndSet(true);
			}
		};

		
		try {
			CallbackService.addListener(sessionId.toString(), listener);
			
			client.sendRequest(parameters);

			int i = 0;
			while (!finishFlag.get() && i++ < getWaitSeconds() && !stopFromWs.get() && !emptyFlag.get()) {
				Thread.sleep(1000);
			}
			
			logger.debug("Time out:" + getWaitSeconds() + " Time passed:" + i + " Is empty:" + emptyFlag.get());
			
			if (stopFromWs.get()){
				throw new UserException("Error. Interrupted by WS call");
			}

			if (!finishFlag.get()) {
				throw new UserException("Error. Time out of " + getWaitSeconds() +
						" has passed and no data has been received. Session: " + sessionId);
			}

			if (failedFlag.get()) {
				throw new UserException(errorMsg.toString());
			}
			if (emptyFlag.get()){
				return false;
			}
			return true;

		} catch (Exception e) {
			logger.error("Error ", e);
			throw new UserException(e);
		} finally {
			CallbackService.removeListener(sessionId.toString());
		}
	}
	
	public void sendRequestOnCancelation(Long sessionId) throws UserException {
		logger.info("sendRequestOnCancelation");
		client.cancel();
	}

	public void setWaitSeconds(Integer waitSeconds){
		this.waitSeconds = waitSeconds;
	}
	
	public Integer getWaitSeconds(){
		if(waitSeconds == null){
			waitSeconds = DEFAULT_REQUEST_TIMEOUT;
		}
		return waitSeconds;
	}

	public AtomicBoolean getStopFromWs() {
		return stopFromWs;
	}
}

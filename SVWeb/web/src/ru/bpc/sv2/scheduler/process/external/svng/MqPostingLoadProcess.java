package ru.bpc.sv2.scheduler.process.external.svng;

import org.apache.log4j.Logger;
import ru.bpc.sv.ws.process.svng.CallbackService;
import ru.bpc.sv.ws.process.svng.Invalidation;
import ru.bpc.sv.ws.process.svng.RequestDataWSClient;
import ru.bpc.sv.ws.process.svng.WsClient;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.IbatisExternalProcess;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.svng.DataTypes;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.InputStream;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;


@SuppressWarnings("UnusedDeclaration")
@Deprecated // See PostingMqSaver
public class MqPostingLoadProcess extends IbatisExternalProcess {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	ProcessDao _processDao;
	SettingsDao _settingsDao;
	
	private ExecutorService executor;
	Map<String, Object> parameters;
	ProcessFileAttribute[] attr;
	private Exception exc;
	private boolean fromWs;
	private NotificationListener invalidationListener;
	
	int current = 0;
	int success = 0;
	int fail = 0;
	private String fault_code;
	private String callbackAddress;
	private boolean requestSended;
	private boolean stop;
	private RequestDataWSClient clientPostingReq = null;
	private SettingsCache settingParamsCache = SettingsCache.getInstance();
	private Integer DEFAULT_TIMEOUT = 10;

	@Override
	public void execute() throws SystemException, UserException {
		boolean needInvalidation = false;
		try {
			fromWs = false;
			stop = false;
			exc = null;
			initCallBackAddress();
			initBeans();
			prepareListner();
			requestSended = false;
			getIbatisSession();
			startSession();
			attr = getFileInAttributes();
			if (attr == null || attr.length == 0) {
				throw new UserException("Incoming file attributes are empty");
			}
			fault_code=ProcessConstants.PROCESS_FINISHED_WITH_ERRORS;
			needInvalidation = true;
			executeBody();
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			commit();
		} catch (Exception e) {
			error("Exceptiong happend: " + e.getMessage());
			if (!fromWs && needInvalidation){
				try{
					callInvalidationService();
				}catch (Exception e1){
					// Do not throw this exception in order to not to hide original exception
					// Only log that invalidation was unsuccessful
					error("Could not send invalidation request: " + e1.getMessage(), e1);
				}
			}
			processSession.setResultCode(ProcessConstants.PROCESS_FAILED);
			rollback();
			if (e instanceof UserException) {
				throw (UserException) e;
			} else if (e instanceof SystemException) {
				throw (SystemException) e;
			} else {
				throw new SystemException(e);
			}
		} finally {
			closeConAndSsn();
		}

	}

	private void prepareListner() throws Exception {
		NotificationListener invalidationListener = new NotificationListener() {
			@Override
			public void notify(Map<String, Object> values) {
				try {
					Long sessionIdCancal;
					try {
						sessionIdCancal = Long.parseLong((String) values.get("sessionId"));
					} catch (Exception e) {
						throw new Exception("session id for invalidation is not set");
					}
					fromWs = true;
					warn("Received invalidation for " + sessionIdCancal);
					stop = true;
					exc = new Exception();
					Invalidation inv = new Invalidation(sessionIdCancal);
					inv.setCallbackAddress(callbackAddress);

					inv.setException(((values.get("exception") == null)
									? false
									: (Boolean) (values.get("exception"))));
					inv.callCancel(userName);
					if (clientPostingReq != null) {
						clientPostingReq.getStopFromWs().getAndSet(true);
					}
				} catch (Exception ex) {
					error("invalidation error: " + ex.getMessage(), ex);
				}
			}
		};
		CallbackService.addInvalList(processSessionId().toString(), invalidationListener);
	}

	private void callInvalidationService() throws Exception {
		WsClient client = new WsClient(callbackAddress, callbackAddress, processSessionId(), null);
		client.cancel();
	}
	
	private void executeBody() throws Exception {
		info("Sending get_posting request...");
		if(attr[0] == null || attr[0].getQueueIdentifier() == null){
			throw new UserException("No queue name");
		}
		if(sendRequest()){
			processQueue(attr[0].getQueueIdentifier());
		}

	}
	
	private void initCallBackAddress(){
		callbackAddress = CommonUtils.getWsCallbackUrl(parameters);
		if(parameters.containsKey("wsServerName")){
			parameters.remove("wsServerName");
		}
		if(parameters.containsKey("wsPort")){
			parameters.remove("wsPort");
		}
	}

	private boolean sendRequest() throws Exception {
		String url = settingParamsCache.getParameterStringValue(SettingsConstants.BPEL_URL);
		clientPostingReq = new RequestDataWSClient(url, processSessionId(), callbackAddress, getDataType());
		clientPostingReq.setWaitSeconds((attr[0] == null) ? null : attr[0].getTimeWait());
		requestSended = clientPostingReq.sendRequestByUpload(this.parameters); //parameters
		return requestSended;
	}
	
	@Override
	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;

	}
	public void processQueue(String queueIdentifier) throws UserException {
		UserException resultException = null;
		ProcessQueue mq = ProcessQueue.create(queueIdentifier);
		this.executor = Executors.newFixedThreadPool(threadsNumber);
		info("Receive message from queue:" + queueIdentifier);
		try{
			boolean isSession = false;
			Integer packs = 0;
			InputStream mqis = null;
			
			while(!isSession){
//				mqis = mq.getMessageStream();
				QueueTask queueTask = new QueueTask(mq);
				isSession = queueTask.process();
				packs = queueTask.getTotalPack();
			}
				
			
			Future<?>[] futures = new Future[packs-1];
			for(int i = 0; i < packs-1; i++){
				//mqis = mq.getMessageStream();
				futures[i] = executor.submit(new QueueTask(mq));
			}
			
			
			int countErr = 0;
			logger.debug("processQueue:stop=" + stop);
			logger.debug("processQueue:exc=" + exc);
			for(int j = 0; j < packs-1; j++){
				if(stop && !futures[j].isDone()){
					futures[j].cancel(true);
					if(futures[j].isCancelled()){
						fault_code=ProcessConstants.PROCESS_FAILED;
						logger.debug("--process stoped--");
					}
					continue;
				}
				Object result = futures[j].get();
				if (result instanceof Exception) {
					if (process.isInterruptThreads()){
						stop = true;
					}
					exc = (Exception)result;
					countErr++;
					if(countErr>1){
						fault_code=ProcessConstants.PROCESS_FAILED;
					}	
				}
			}
			if (exc != null)
				throw exc;
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
		}catch(Exception e){
			throw new UserException(e);
		}finally{
			try {
				mq.closeConnection();
			} catch (Exception e) {
				// Do not throw exception in final block in order to not to hide original exception (if any)
				error(e.getMessage(), e);
				resultException = new UserException(e.getMessage(), e);
			}
		}
		if (resultException != null)
			throw resultException;
	}
	
	private void initBeans() throws SystemException{
		_processDao = new ProcessDao();
		_settingsDao = new SettingsDao();
	}
	
	private ProcessFileAttribute[] getFileInAttributes() throws SystemException {
		ProcessFileAttribute[] result;
		try {
			result = _processDao.getIncomingFilesForProcess(userSessionId,
					processSession.getSessionId(),
					process.getContainerBindId());
		} catch (DataAccessException e) {
			error(e.getMessage(), e);
			throw new SystemException(e.getMessage());
		}
		return result;
	}
	
	@SuppressWarnings("SameParameterValue")
	private synchronized void logCurrent(boolean isSuccess) throws Exception {
		current++;
		if (isSuccess) {
			success++;
		} else {
			fail++;
		}
		logCurrent(current, fail);
		con.commit();
	}
	
	private class QueueTask implements Callable {
		private ProcessQueue mq;
		private Integer total_pack;
		private String sessionId;

		public QueueTask(ProcessQueue mq) {
			this.mq = mq;
		}
		
		@Override
		public Object call() {
			try {
				//noinspection StatementWithEmptyBody
				while (!process()) ;
				return "OK";
			} catch (Throwable t) {
				error(t.getMessage(), t);
				try {
					logCurrent(false);
				} catch (Exception e) {
					e.printStackTrace();
				}
				return t;
			}
		}
		public boolean process() throws Exception {
			info("process:begin");
			FileSessionDataSave fsd = new FileSessionDataSave(process.getContainerBindId(), userSessionId, attr[0], null);
			fsd.setConnection(con);
			SvngPackageParser parser;
			try {
				parser = new SvngPackageParser();
				logger.debug("Parsing convert");
				parser.parse(mq.getMessageStream((attr[0] == null) ? DEFAULT_TIMEOUT : attr[0].getTimeWait()));
				if(!processSessionId().toString().equals(parser.getSessionId())) {
					logger.warn("session id from pack :" + parser.getSessionId() + " is not equals process session id:" + processSessionId());
					return false;
				}
				logger.debug("Saving message");
				fsd.createSqlQuery(parser.getMessage(), parser.getFileName(), parser.getRecordsNumber(), -1);
				fsd.executeUpdate();
				this.total_pack = parser.getPacksTotal();
				this.sessionId = parser.getSessionId();
				info("Message " + parser.getNumber() + " out of " + total_pack + " saved. Session id:" + sessionId);
			} catch (Exception e) {
				throw new UserException(e);
			} 
			return true;
		}
		
		public Integer getTotalPack(){
			return total_pack;
		}
		public String getSessionId(){
			return sessionId;
		}
	}
	
	
	
	public void cancelation(Long userSessionId) throws SystemException, UserException{
		try {
			attr = getFileInAttributes();
			prepareCleanQueue(userSessionId);
			
		} catch (Exception e) {
			rollback();
			if (e instanceof UserException) {
				throw new UserException(e);
			} else {
				throw new SystemException(e);
			}
		}
	}
	
	private void prepareCleanQueue(Long userSessionId) throws Exception {
		trace("MqPostingLoadProcess::prepareCleanQueue...");
		if(attr[0] == null || attr[0].getQueueIdentifier() == null){
			throw new UserException("No queue name");
		}
		if(requestSended){
			cleanQueue(attr[0].getQueueIdentifier(), userSessionId);
		}

	}
	private void cleanQueue(String queueIdentifier, Long userSessionId) throws UserException {
		UserException resultException = null;
		ProcessQueue mq = ProcessQueue.create(queueIdentifier);
		this.executor = Executors.newFixedThreadPool(threadsNumber);
		
		try{
			boolean isSession = false;
			Integer packs = 0;
			InputStream mqis = null;
			while(!isSession){
				QueueTaskClean queueTask = new QueueTaskClean(mq, userSessionId);
				isSession = queueTask.process();
				packs = queueTask.getTotalPack();
			}
				
			Future<?>[] futures = new Future[packs-1];
			for(int i = 0; i < packs-1; i++){
				futures[i] = executor.submit(new QueueTask(mq));
			}
			boolean stop = false;
			Exception exc = null;
			int countErr = 0;
			for(int j = 0; j < packs-1; j++){
				if(stop && !futures[j].isDone()){
					futures[j].cancel(true);
					if(futures[j].isCancelled()){
						fault_code=ProcessConstants.PROCESS_FAILED;
						logger.debug("--process stoped--");
					}
					continue;
				}
				Object result = futures[j].get();
				if (result instanceof Exception) {
					if (process.isInterruptThreads()){
						stop = true;
					}
					exc = (Exception)result;
					countErr++;
					if(countErr>1){
						fault_code=ProcessConstants.PROCESS_FAILED;
					}	
				}
			}
			if (exc != null)
				throw exc;
			processSession.setResultCode(ProcessConstants.PROCESS_FINISHED);
			
		}catch(Exception e){
			throw new UserException(e);
		}finally{
			try {
				mq.closeConnection();
			} catch (Exception e) {
				// Do not throw exception in final block in order to not to hide original exception (if any)
				error(e.getMessage(), e);
				resultException = new UserException(e.getMessage(), e);
			}
		}
		if (resultException != null)
			throw resultException;
	}
	
	private class QueueTaskClean implements Callable {
		private ProcessQueue mq;
		private Integer total_pack;
		private String sessionId;
		private Long sessionIdClean;

		public QueueTaskClean(ProcessQueue mq, Long sessionIdClean) {
			this.mq = mq;
			this.sessionIdClean = sessionIdClean;
		}
		
		@Override
		public Object call() {
			try {
				//noinspection StatementWithEmptyBody
				while (!process()) ;
				return "OK";
			} catch (Throwable t) {
				error(t.getMessage(), t);
				try {
					logCurrent(false);
				} catch (Exception e) {
					e.printStackTrace();
				}
				return t;
			}
		}
		public boolean process() throws Exception {

			SvngPackageParser parser;
			try {
				parser = new SvngPackageParser();
				logger.debug("Parsing convert for remove messages");
				parser.remove(mq.getMessageStream((attr[0] == null) ? DEFAULT_TIMEOUT : attr[0].getTimeWait()), sessionIdClean);
				if(!sessionIdClean.toString().equals(parser.getSessionId())){
					return false;
				}
				logger.debug("remove message");
				this.total_pack = parser.getPacksTotal();
				this.sessionId = parser.getSessionId();
				logger.debug("Messages removed. session id:" + sessionId);
			} catch (Exception e) {
				throw new UserException(e);
			} 
			return true;
		}
		
		public Integer getTotalPack(){
			return total_pack;
		}
		public String getSessionId(){
			return sessionId;
		}
	}

	protected DataTypes getDataType() {
		return DataTypes.POSTING;
	}
	
}

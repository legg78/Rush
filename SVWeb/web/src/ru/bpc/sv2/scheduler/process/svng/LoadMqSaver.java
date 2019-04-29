package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv.ws.process.event.EventRegistration;
import ru.bpc.sv.ws.process.svng.CallbackService;
import ru.bpc.sv.ws.process.svng.RequestDataWSClient;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.common.events.RegisteredEvent;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.io.BytesMessageInputStream;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.scheduler.process.external.svng.FileSessionDataSave;
import ru.bpc.sv2.scheduler.process.external.svng.NotificationListener;
import ru.bpc.sv2.scheduler.process.external.svng.SvngPackageParser;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import javax.jms.*;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.util.Date;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.atomic.AtomicBoolean;

@SuppressWarnings("UnusedDeclaration")
public abstract class LoadMqSaver extends ActiveMQSaver {
    private Integer waitSeconds;
    final AtomicBoolean stop = new AtomicBoolean(false);
    private Exception exc;
    public static final int DEFAULT_NUMBER_OF_THREADS = 1;
    private RequestDataWSClient clientReq = null;
    private SettingsCache settingParamsCache = SettingsCache.getInstance();
    private boolean fromWs;

    @Override
    public void save() throws Exception {
        exc = null;
        fromWs = false;
        initCallBackAddress();
        initBeans();
        try {
	        prepareListner();
	        logger.info("start saver: " + this.getClass().getName());
	        queue = fileAttributes.getQueueIdentifier();
	        waitSeconds = fileAttributes.getTimeWait();
	        if (queue == null) {
	            throw new UserException("No queue name");
	        }
	        if (sessionId == null) {
	            sessionId = fileAttributes.getSessionId();
	        }

	        try {
	            if (sendRequest()) {
	                processQueue(queue);
	                registerEvent(EventConstants.SUCCESSFULL_FILE_TRANSMISSION);
	            }
	        } catch (Exception e){
	            try {
	                registerEvent(EventConstants.UNSUCCESSFULL_FILE_TRANSMISSION);
	                callInvalidationService(e.getMessage(), sessionId, true);
	            } catch (Throwable t) {
	                logger.error("Could not send invalidation: " + t.getMessage(), t);
	            }
	            throw e;
	        }
        } finally {
	        logger.debug("finally saver " + this.getClass().getName());
	        CallbackService.removeInvalList(sessionId.toString());
        }
    }

    private void registerEvent(String status) {
        try {
            EventRegistration eventRegistration = new EventRegistration();
            RegisteredEvent event = new RegisteredEvent(status,
                                                        new Date(),
                                                        EntityNames.SESSION,
                                                        sessionId,
                                                        fileAttributes.getInstId());
	        EventsDao eventsDao = new EventsDao();
	        eventsDao.registerEvent(event, sessionId);
        } catch(Exception e) {
            logger.error("Could not register event", e);
        }
    }

    private void prepareListner() throws Exception{
        NotificationListener invalidationListener = new NotificationListener() {
            @Override
            public void notify(Map<String, Object> values) {
                fromWs = true;
                try {
                    Long sessionIdCancal;
                    try {
                        sessionIdCancal = Long.parseLong((String) values.get("sessionId"));
                    } catch (Exception e) {
                        throw new Exception("session id for invalidation is not set");
                    }
                    logger.warn("Received invalidation for " + sessionIdCancal);
                    loggerDB.warn(new TraceLogInfo(sessionId, LoadMqSaver.this.getClass().getSimpleName() + ": " + "Received invalidation for " + sessionIdCancal));
                    exc = new Exception();
                    if (clientReq != null) {
                        clientReq.getStopFromWs().getAndSet(true);
                    }
                } catch (Exception ex) {
                    logger.error("invalidation error: " + ex.getMessage(), ex);
                    loggerDB.warn(new TraceLogInfo(sessionId, LoadMqSaver.this.getClass().getSimpleName() + ": " + "invalidation error: " + ex.getMessage()));
                } finally {
                    stop.getAndSet(true);
                }
            }
        };
        CallbackService.addInvalList(sessionId.toString(), invalidationListener);
    }

    public void processQueue(String queueIdentifier) throws UserException{
        UserException resultException = null;
        ConnectionPool connectionPool = null;
        ConnectionMqPool connectionMqPool = null;
        BigDecimal value = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.MESSAGE_QUEUE_LOAD_CONSUMERS);
        int threadsNumber = value == null || value.intValue() <= 0 ? DEFAULT_NUMBER_OF_THREADS : value.intValue();
        ExecutorService executor = Executors.newFixedThreadPool(threadsNumber);
        logger.info("Receive messages using max of " + threadsNumber + " thread(s) from queue: " + queueIdentifier);
        try{
            connectionPool = new ConnectionPool(threadsNumber);
            String mqurl = settingParamsCache.getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
            connectionMqPool = new ConnectionMqPool(mqurl, queueIdentifier);
            boolean isSession = false;
            Integer packs = 0;

            while(!isSession){
                QueueTask queueTask = new QueueTask(connectionMqPool, sessionId, connectionPool, getWaitSeconds(), getStatusSessionFile());
                isSession = queueTask.process();
                packs = queueTask.getTotalPack();
            }

            Future[] futures = new Future[packs-1];
            for(int i = 0; i < packs-1; i++){
                futures[i] = executor.submit(new QueueTask(connectionMqPool, sessionId, connectionPool, getWaitSeconds(), getStatusSessionFile()));
            }

            logger.debug("processQueue:stop=" + stop);
            logger.debug("processQueue:exc=" + exc);
            for(int j = 0; j < packs-1; j++){
                if(stop.get() && !futures[j].isDone()){
                    futures[j].cancel(true);
                    if(futures[j].isCancelled()){
                        logger.debug("--process stoped--");
                    }
                    continue;
                }
                Object result = futures[j].get();
                if (result instanceof Exception) {
                    stop.getAndSet(true);
                    exc = (Exception)result;
                }
            }
            if (exc != null)
                throw exc;
        }catch(Throwable e){
	        if (e instanceof UserException) {
		        throw (UserException) e;
	        }
            throw resultException = new UserException(e.getMessage(), e);
        }finally{
            try {
                if(connectionPool!=null){
                    connectionPool.closeConnections();
                }
                if(connectionMqPool != null){
                    connectionMqPool.closeConnections();
                }
                executor.shutdown();
            } catch (Exception e) {
                // Do not throw exception in final block in order to not to hide original exception (if any)
                logger.error(e.getMessage(), e);
                if (resultException == null)
                    resultException = new UserException(e.getMessage(), e);
            }
        }
        if (resultException != null)
            throw resultException;
    }

    private class QueueTask implements Callable {
        private ConnectionMqPool connectionMqPool;
        private Integer total_pack;
        private Long sessionId;
        private ConnectionPool connectionPool;
        private Integer timeout;
        private String statusSessionFile;

        public QueueTask(ConnectionMqPool connectionMqPool, Long sessionId, ConnectionPool connectionPool, Integer timeout, String statusSessionFile) {
            this.connectionMqPool = connectionMqPool;
            this.sessionId = sessionId;
            this.connectionPool = connectionPool;
            this.timeout = timeout;
            this.statusSessionFile = statusSessionFile;
        }

        @Override
        public Object call() {
            try {
                while(!process());
                return "OK";
            } catch (Throwable t) {
                loggerDB.error(t.getMessage(), t);
                logger.error(new TraceLogInfo(sessionId, t.getMessage()), t);
                return t;
            }
        }
        public boolean process() throws Exception {
            logger.info("process:begin");
            FileSessionDataSave fsd = new FileSessionDataSave(process.getContainerBindId(), userSessionId, fileAttributes, statusSessionFile);
            fsd.setSessionId(sessionId);

            SvngPackageParser parser;
            Connection connection = null;
            MessageConsumer consumer = null;
            try {
                parser = new SvngPackageParser();
                logger.debug("Parsing convert. Receiving and converting message from queue");
                consumer = connectionMqPool.retrieve();
                parser.parse(getMessageStream(consumer));
                if(!sessionId.toString().equals(parser.getSessionId())){
                    logger.error("session id from pack :" + parser.getSessionId() + " is not equals process session id:" + sessionId);
                    return false;
                }
                logger.debug("Saving message");

                connection = connectionPool.retrieve();
                fsd.setConnection(connection);

                String fileName = parser.getFileName();
                String name = fileName.substring(0, fileName.lastIndexOf("."));
                String ext = fileName.substring(fileName.lastIndexOf("."));
                fileName = name + "_" + parser.getNumber() + ext;

                /**
                 * There was "parser.getRecordsNumber() - 2" before, but then we decided to make adapter to put
                 * record number in xml pack header, not counting tlv file header and footer
                 */
                fsd.createSqlQuery(parser.getMessage(), fileName, parser.getRecordsNumber(), -1);
                fsd.executeUpdate();

                if(!getOutParams().containsKey("expectedFiles")) {
                    getOutParams().put("expectedFiles", parser.getPacksTotal());
                }
                Object processedFilesObj  = getOutParams().get("processedFiles");
                if(processedFilesObj == null){
                    getOutParams().put("processedFiles", 1);
                }else{
                    Integer processedFiles = (Integer) processedFilesObj;
                    getOutParams().put("processedFiles", processedFiles + 1);
                }

                this.total_pack = parser.getPacksTotal();
                logger.info("Message " + parser.getNumber() + " out of " + total_pack + " saved. Session id:" + sessionId);
                connection.commit();
                // Update reject counter only after final commit
                logger.debug("Update reject counter");
                fsd.updateRejectCount();
            } catch (Throwable e) {
                try {
                    if(connection != null){
                        connection.rollback();
                    }
                } catch (Throwable ignored) {
                    logger.error(ignored.getMessage(), ignored);
                }
                throw new UserException(e.getMessage(), e);
            } finally{
                fsd.close();
                try {
                    if(connection != null){
                        connectionPool.putback(connection);
                    }
                    if(consumer != null){
                        connectionMqPool.putback(consumer);
                    }
                } catch (Throwable ignored) {
                    logger.error(ignored.getMessage(), ignored);
                }
            }
            return true;
        }

        public InputStream getMessageStream(MessageConsumer consumer) throws UserException, JMSException, UnsupportedEncodingException, InterruptedException {
            InputStream bmis = null;
            logger.debug("gets inputstream...");
            Message message = null;
            try {
                int i = 0;
                while(message == null && i<timeout && !stop.get()) {
                    message = consumer.receive(1);
                    i++;
                    Thread.sleep(1000);
                }
            } catch (JMSException e) {
                throw new UserException("Can't get data from the queue within " + timeout + " seconds.", e);
            }
            if(message == null){
                throw new UserException("Queue is empty");
            }
            if (message instanceof TextMessage) {
                logger.debug("message instanceof TextMessage");
                TextMessage bMessage = (TextMessage) message;
                bmis = new ByteArrayInputStream(bMessage.getText().getBytes(SystemConstants.DEFAULT_CHARSET));
            } else if (message instanceof BytesMessage) {
                BytesMessage bMessage = (BytesMessage) message;
                bmis = new BytesMessageInputStream(bMessage);
            }
            return bmis;
        }

        public Integer getTotalPack(){
            return total_pack;
        }
    }

    protected boolean sendRequest() throws Exception {
        String url = settingParamsCache.getParameterStringValue(SettingsConstants.BPEL_URL);
        clientReq = new RequestDataWSClient(url, sessionId, callbackAddress, getDataType());
        clientReq.setWaitSeconds(getWaitSeconds());
        return clientReq.sendRequestByUpload(this.params);
    }

    @Override
    public boolean isRequiredInFiles() {
        return false;
    }

    public String getStatusSessionFile(){
        return null;
    }

    public Integer getWaitSeconds() {
        if (waitSeconds == null) {
            waitSeconds = 30;
        }
        return waitSeconds;
    }
}

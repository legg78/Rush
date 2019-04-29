package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv.ws.process.svng.CallbackService;
import ru.bpc.sv.ws.process.svng.Invalidation;
import ru.bpc.sv.ws.process.svng.RequestDataWSClient;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.io.BytesMessageInputStream;
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
import java.sql.Connection;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

@SuppressWarnings("UnusedDeclaration")
public abstract class LoadWsSaver extends WebServiceSaver {
    private Integer waitSeconds;
    private boolean stop;
    private Exception exc;
    private static final Integer threadsNumber = 5;
    private RequestDataWSClient clientReq = null;
    private SettingsCache settingParamsCache = SettingsCache.getInstance();
    private boolean fromWs;

    @Override
    public void save() throws Exception {
        stop = false;
        exc = null;
        fromWs = false;
        initCallBackAddress();
        initBeans();
        prepareListner();
        logger.debug("start saver: " + this.getClass().getName());
        waitSeconds = fileAttributes.getTimeWait();
        if (sessionId == null) {
            sessionId = fileAttributes.getSessionId();
        }

        try {
            if (sendPrepareRequest()) {
                sendLoadRequest();
            }
        } catch (Exception e) {
	        try {
                callInvalidationService(e.getMessage(), sessionId, !fromWs);
	        } catch (Throwable t) {
		        logger.error("Could not send invalidation: " + t.getMessage(), t);
	        }
	        throw e;
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
                    exc = new Exception();
                    if (clientReq != null) {
                        clientReq.getStopFromWs().getAndSet(true);
                    }
                } catch (Exception ex) {
                    logger.error("invalidation error: " + ex.getMessage(), ex);
                }
            }
        };
        CallbackService.addInvalList(sessionId.toString(), invalidationListener);
    }


    /**
     * Send request to "bpel" but really to FO adapter service (and then to STORFROW process by that) to prepare files.
     * Wait callback from FO to BO-web
     *
     * @return result of execution the command
     * @throws Exception on any error
     */
    protected boolean sendPrepareRequest() throws Exception {
        String url = settingParamsCache.getParameterStringValue(SettingsConstants.BPEL_URL);
        clientReq = new RequestDataWSClient(url, sessionId, callbackAddress, getDataType());
        clientReq.setWaitSeconds(getWaitSeconds());
        return clientReq.sendRequestByUpload(this.params);
    }

    /**
     * Send request to "camel" application to convert and load files into DB.
     * Wait callback from "camel" to BO-web
     *
     * @return result of execution the command
     * @throws Exception
     */
    protected boolean sendLoadRequest() throws Exception {
        String url = settingParamsCache.getParameterStringValue(SettingsConstants.APACHE_CAMEL_LOCATION);
        clientReq = new RequestDataWSClient(url + "/services/load", sessionId, callbackAddress, getDataType());
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

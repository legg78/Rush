package ru.bpc.sv.ws.integration;

import com.bpcbt.svng.auth.Sv2ModuleProvider;
import com.bpcbt.svng.auth.cache.LogoutCache;
import com.bpcbt.svng.auth.providers.ModuleDataProvider;
import com.bpcbt.svng.auth.utils.LogUtil;
import com.bpcbt.svng.auth.ws.ModuleWebService;
import com.bpcbt.svng.auth.ws.message.v1.*;
import org.apache.log4j.Logger;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;

@WebService(name = "AuthWS", portName = "AuthWSSoap", serviceName = "AuthWS", targetNamespace = "http://www.bpcbt.com/svng/auth/ws/service/v1/")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso({ObjectFactory.class})
public class AuthWS extends ModuleWebService {
    private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

    @WebResult (name = "logoutResponse", targetNamespace = "http://www.bpcbt.com/svng/auth/ws/message/v1/", partName = "response")
    @WebMethod (operationName = "Logout", action = "http://www.bpcbt.com/svng/auth/ws/service/v1/logout")
    public LogoutResponse logout(@WebParam (partName = "request",name = "logoutRequest",targetNamespace = "http://www.bpcbt.com/svng/auth/ws/message/v1/") LogoutRequest request) {
        logger.trace("Logout initiated");
        LogoutResponse result = null;
        try {
            result = super.logout(request);
        } catch (Exception e) {
            logger.error("Logout finished with error", e);
            throw e;
        }
        logger.trace("Logout finished with result '" + result.getResult().value() + "'");
        return result;
    }

    @WebResult(name = "syncResponse", targetNamespace = "http://www.bpcbt.com/svng/auth/ws/message/v1/", partName = "response")
    @WebMethod(operationName = "Sync", action = "http://www.bpcbt.com/svng/auth/ws/service/v1/sync")
    public SyncResponse sync(@WebParam(partName = "request", name = "syncRequest", targetNamespace = "http://www.bpcbt.com/svng/auth/ws/message/v1/") SyncRequest request) {
        logger.trace("Synchronization initiated");
        SyncResponse result = null;
        try {
            result = super.sync(request);
        } catch (Exception e) {
            logger.error("Default synchronization finished with error", e);
            throw e;
        }
        logger.trace("Synchronization finished successfully");
        return result;
    }
}
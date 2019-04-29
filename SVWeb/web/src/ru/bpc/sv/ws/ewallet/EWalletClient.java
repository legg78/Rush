package ru.bpc.sv.ws.ewallet;

import java.util.Map;
import javax.xml.ws.BindingProvider;
import org.apache.cxf.endpoint.Client;
import org.apache.cxf.frontend.ClientProxy;
import org.apache.cxf.interceptor.LoggingInInterceptor;
import org.apache.cxf.interceptor.LoggingOutInterceptor;
import org.apache.log4j.Logger;
import ru.bpc.svap.Customer;
import ru.bpc.svap.LinksInfo;
import ru.bpc.svap.integration.ApIntService;
import ru.bpc.svap.integration.ApIntService_Service;
import ru.bpc.svap.integration.GetCustomerInfoRequest;
import ru.bpc.svap.integration.SendCardAccountLinksResponse;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class EWalletClient {
    private static final Logger logger = Logger.getLogger("EWALLET_SYNC");
    private static final int WS_TIMEOUT_MILLIS = 10000;
    private final String url;

    public EWalletClient(String url) {
        super();
        this.url = url;
        if (logger.isDebugEnabled()) {
            logger.debug("eWallet webservice client constructed, URL=[" + url + "]");
        }
    }

    public Customer getCustomerInfo(final String customerNumber) throws Exception {
        if (logger.isDebugEnabled()) {
            logger.debug("getCustomerInfo(): customerNumber=[" + customerNumber + "]");
        }
        return (getService().getCustomerInfo(new GetCustomerInfoRequest() {{
            setCustomerId(customerNumber);
        }}));
    }

    public SendCardAccountLinksResponse sendCardAccountLinks(LinksInfo linksInfo) throws Exception {
        if (logger.isDebugEnabled()) {
            logger.debug("sendCardAccountLinks(): customerId=[" + linksInfo.getCustomerId() + "], linksInfo.size=[" + linksInfo.getLinkInfo().size() + "]");
        }
        return (getService().sendCardAccountLinks(linksInfo));
    }

    private ApIntService getService() throws Exception {
        ApIntService ais = new ApIntService_Service(EWalletClient.class.getClassLoader().getResource("META-INF/wsdl/cbs.wsdl")).getApIntServiceSOAP();
        BindingProvider bindingProvider = (BindingProvider) ais;
        setWebserviceProperties(bindingProvider.getRequestContext(), WS_TIMEOUT_MILLIS, url);
        if (logger.isDebugEnabled()) {
            Client c  = ClientProxy.getClient(bindingProvider);
            c.getInInterceptors().add(new LoggingInInterceptor());
            c.getOutInterceptors().add(new LoggingOutInterceptor());
        }
        return (ais);
    }

    private void setWebserviceProperties(Map<String, Object> map, int millis, String url) {
        map.put("com.sun.xml.internal.ws.connect.timeout", millis);
        map.put("com.sun.xml.internal.ws.request.timeout", millis);
        map.put("com.sun.xml.ws.request.timeout", millis);
        map.put("com.sun.xml.ws.connect.timeout", millis);
        map.put("javax.xml.ws.client.connectionTimeout", millis);
        map.put("javax.xml.ws.client.receiveTimeout", millis);
        map.put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, url);
    }
}

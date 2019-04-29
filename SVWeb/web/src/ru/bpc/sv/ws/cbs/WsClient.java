package ru.bpc.sv.ws.cbs;

import org.apache.cxf.endpoint.Client;
import org.apache.cxf.frontend.ClientProxy;
import org.apache.cxf.interceptor.LoggingInInterceptor;
import org.apache.cxf.interceptor.LoggingOutInterceptor;
import org.apache.log4j.Logger;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.svap.Customer;
import ru.bpc.svap.LinksInfo;
import ru.bpc.svap.integration.ApIntService;
import ru.bpc.svap.integration.ApIntService_Service;
import ru.bpc.svap.integration.GetCustomerInfoRequest;
import ru.bpc.svap.integration.SendCardAccountLinksResponse;

import javax.xml.ws.BindingProvider;
import java.util.Map;

/**
 * BPC Group 2017 (c) All Rights Reserved
 */

//XXX: (?) Implement through message queue (?)
public class WsClient {
	private static final Logger logger = Logger.getLogger("CBS_SYNC");
	private static final int WS_TIMEOUT_MILLIS = 10000;
	private final String url;

	public WsClient(String url) {
		super();
		this.url = url;
		if (logger.isDebugEnabled()) {
			logger.debug("CBS webservice client constructed, URL=[" + url + "]");
		}
	}

	public Customer getCustomerInfo(final String customerNumber) throws Exception {
		if (logger.isDebugEnabled()) {
			logger.debug("getCustomerInfo(): customerNumber=[" + customerNumber + "], withoutAccounts=[false]");
		}
		return (getService().getCustomerInfo(new GetCustomerInfoRequest() {{
			setCustomerId(customerNumber);
		}}));
	}

	public Customer getCustomerInfoWithoutAccounts(final String customerNumber) throws Exception {
		if (logger.isDebugEnabled()) {
			logger.debug("getCustomerInfo(): customerNumber=[" + customerNumber + "], withoutAccounts=[true]");
		}
		return (getService().getCustomerInfo(new GetCustomerInfoRequest() {{
			setCustomerId(customerNumber); setWithoutAccounts(true);
		}}));
	}

	public SendCardAccountLinksResponse sendCardAccountLinks(LinksInfo linksInfo) throws Exception {
		if (logger.isDebugEnabled()) {
			logger.debug("sendCardAccountLinks(): customerId=[" + linksInfo.getCustomerId() + "], linksInfo.size=[" + linksInfo.getLinkInfo().size() + "]");
		}
		return (getService().sendCardAccountLinks(linksInfo));
	}

	private ApIntService getService() throws Exception {
		ApIntService ais = new ApIntService_Service(WsClient.class.getClassLoader().getResource("META-INF/wsdl/cbs.wsdl")).getApIntServiceSOAP();
		BindingProvider bindingProvider = (BindingProvider) ais;
		setWebserviceProperties(bindingProvider.getRequestContext(), WS_TIMEOUT_MILLIS, url);
		if (logger.isDebugEnabled()) {
			Client c  = ClientProxy.getClient(bindingProvider);
			c.getInInterceptors().add(new LoggingInInterceptor());
			c.getOutInterceptors().add(new LoggingOutInterceptor());
		}
		return (ais);
	}

	private void setWebserviceProperties(Map<String, Object> map, int millis, String url) throws UserException, IllegalArgumentException {
		if (map == null) {
			throw new IllegalArgumentException("Cannot initialize the request context");
		} else if (url == null) {
			throw new UserException("Missed CBS URL configuration");
		} else {
			map.put("com.sun.xml.internal.ws.connect.timeout", millis);
			map.put("com.sun.xml.internal.ws.request.timeout", millis);
			map.put("com.sun.xml.ws.request.timeout", millis);
			map.put("com.sun.xml.ws.connect.timeout", millis);
			map.put("javax.xml.ws.client.connectionTimeout", millis);
			map.put("javax.xml.ws.client.receiveTimeout", millis);
			map.put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, url);
		}
	}

}

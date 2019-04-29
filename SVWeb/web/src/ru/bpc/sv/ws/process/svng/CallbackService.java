package ru.bpc.sv.ws.process.svng;

import com.bpcbt.sv.sv_sync.*;
import org.apache.cxf.interceptor.InInterceptors;
import org.apache.cxf.interceptor.security.AbstractAuthorizingInInterceptor;
import org.apache.cxf.ws.addressing.ObjectFactory;
import org.apache.log4j.Logger;
import ru.bpc.sv.ws.process.event.EventRegistration;
import ru.bpc.sv2.scheduler.process.external.svng.NotificationListener;

import javax.jws.Oneway;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.soap.Addressing;
import java.util.HashMap;
import java.util.Hashtable;
import java.util.Map;

@WebService(targetNamespace = "urn:com:bpcbt:sv:sv_sync", name = "svsyncAsync", portName = "svsyncPort", serviceName = "CallbackService")
@XmlSeeAlso({org.apache.cxf.ws.addressing.ObjectFactory.class, ObjectFactory.class})
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@InInterceptors(classes = StripWsaHandler.class)
public class CallbackService implements SvsyncAsync {
	private static final Logger logger = Logger.getLogger("PROCESSES");

	private static Map<String, NotificationListener> listeners = new Hashtable<String, NotificationListener>();
	private static Map<String, NotificationListener>invalidationListeners = new Hashtable<String, NotificationListener>();

	public static void addListener(String sessionId, NotificationListener listner){
		listeners.put(sessionId, listner);
	}

	public static void removeListener(String sessionId){
		listeners.remove(sessionId);
	}

	public static void addInvalList(String sessionId, NotificationListener listner){
		invalidationListeners.put(sessionId, listner);
	}

	public static void removeInvalList(String sessionId){
		invalidationListeners.remove(sessionId);
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_cards")
	public SyncResponseHeadType getCards(@WebParam(partName = "parameters", name = "cards-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
										 SyncRequestHeadType parameters) {
		logger.debug("call getCards " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_companies")
	public SyncResponseHeadType getCompanies(@WebParam(partName = "parameters", name = "companies-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
											 SyncRequestHeadType parameters) {
		logger.debug("call getCompanies " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_card_statuses")
	public SyncResponseHeadType getCardStatuses(@WebParam(partName = "parameters", name = "card-statuses-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
												CardStatusesRequest parameters) {
		logger.debug("call getCardStatuses " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_posting")
	public SyncResponseHeadType getPosting( @WebParam(partName = "parameters", name = "posting-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
											PostingRequest parameters) {
		logger.debug("call getPosting " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_balance")
	public SyncResponseHeadType getBalance(@WebParam(partName = "parameters", name = "balance-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
	SyncRequestHeadType parameters) {
		logger.debug("call getBalance " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	private void notifyListener(SyncResponseHeadType parameters) {
		logger.debug("receive response sessionId:" + parameters.getSessionId());
		if (listeners != null) {
			final Map<String, Object> values = new HashMap<String, Object>();
			values.put("result", parameters.getResult());
			values.put("sessionId", parameters.getSessionId());
			if(!listeners.containsKey(parameters.getSessionId())){
				return;
			}
			listeners.get(parameters.getSessionId()).notify(values);
			listeners.remove(parameters.getSessionId());
		}
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_posting_response")
	public void getPostingResult(@WebParam(partName = "parameters", name = "posting-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								 SyncResponseHeadType parameters) {
		notifyListener(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_card_statuses_response")
	public void getCardStatusesResult(@WebParam(partName = "parameters", name = "card-statuses-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
									  SyncResponseHeadType parameters) {
		notifyListener(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_balance_response")
	public void getBalanceResult(@WebParam(partName = "parameters", name = "balance-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								 SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_cards_response")
	public void getCardsResult(@WebParam(partName = "parameters", name = "cards-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
							   SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_merchant_response")
	public void getMerchantResult(@WebParam(partName = "parameters", name = "merchant-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								  SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_merchant")
	public SyncResponseHeadType getMerchant(@WebParam(partName = "parameters", name = "merchant-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
											SyncRequestHeadType parameters) {
		logger.debug("call getMerchant " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_notifications")
	public SyncResponseHeadType getNotifications(@WebParam(partName = "parameters", name = "notifications-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
												 SyncRequestHeadType parameters) {
		logger.debug("call getNotifications " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_companies_response")
	public void getCompaniesResult(@WebParam(partName = "parameters", name = "companies-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								   SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_conv_rate_response")
	public void getConvRateResult(@WebParam(partName = "parameters", name = "conv-rate-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								  SyncResponseHeadType parameters) {
		// TODO Auto-generated method stub
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_persons")
	public SyncResponseHeadType getPersons(@WebParam(partName = "parameters", name = "persons-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
										   SyncRequestHeadType parameters) {
		logger.debug("call getPersons " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_conv_rate")
	public SyncResponseHeadType getConvRate(@WebParam(partName = "parameters", name = "conv-rate-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
											ConvRateRequest parameters) {
		logger.debug("call getConvRate " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_product")
	public SyncResponseHeadType getProduct(
			@WebParam(partName = "parameters", name = "product-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
			SyncRequestHeadType parameters) {
		logger.debug("call getProduct " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_persons_response")
	public void getPersonsResult(@WebParam(partName = "parameters", name = "persons-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								 SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_terminal_response")
	public void getTerminalResult(@WebParam(partName = "parameters", name = "terminal-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								  SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_terminal")
	public SyncResponseHeadType getTerminal(@WebParam(partName = "parameters", name = "terminal-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
											SyncRequestHeadType parameters) {
		// TODO Auto-generated method stub
		logger.debug("call getTerminal " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_notifications_response")
	public void getNotificationsResult(@WebParam(partName = "parameters", name = "notifications-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
									   SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_product_response")
	public void getProductResult(@WebParam(partName = "parameters", name = "product-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								 SyncResponseHeadType parameters) {
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:cancel")
	public void cancel(@WebParam(partName = "parameters", name = "cancellation-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
					   SyncRequestHeadType parameters) {
		notifyInvalidateListener(parameters);
	}

	@Override
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_reject")
	public SyncResponseHeadType getReject(@WebParam(partName = "parameters", name = "reject-request", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
										  SyncRequestHeadType parameters) {
		logger.debug("call getPosting " + new UnsupportedOperationException());
		throw new UnsupportedOperationException();
	}

	@Override
	@Oneway
	@WebMethod(action = "urn:com:bpcbt:sv:sv_sync:get_reject_response")
	public void getRejectResult(@WebParam(partName = "parameters", name = "reject-response", targetNamespace = "urn:com:bpcbt:sv:sv_sync")
								SyncResponseHeadType parameters){
		notifyListener(parameters);
		new EventRegistration().register(parameters);
	}
	
	private void notifyInvalidateListener(SyncRequestHeadType parameters) {
		logger.debug("receive invalidation sessionId:" + parameters.getSessionId());
			final Map<String, Object> values = new HashMap<String, Object>();
			values.put("sessionId", parameters.getSessionId());
			values.put("exception", parameters.isException());
			if(!invalidationListeners.containsKey(parameters.getSessionId())){
				return;
			}
			invalidationListeners.get(parameters.getSessionId()).notify(values);
		invalidationListeners.remove(parameters.getSessionId());
	}
}

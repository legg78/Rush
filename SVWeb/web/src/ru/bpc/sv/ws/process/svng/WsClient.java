package ru.bpc.sv.ws.process.svng;

import com.bpcbt.sv.sv_sync.*;
import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.cxf.common.i18n.Exception;
import org.apache.cxf.endpoint.Client;
import org.apache.cxf.frontend.ClientProxy;
import org.apache.cxf.interceptor.LoggingInInterceptor;
import org.apache.cxf.interceptor.LoggingOutInterceptor;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.http.HTTPConduit;
import org.apache.cxf.transports.http.configuration.HTTPClientPolicy;
import org.apache.cxf.ws.addressing.*;
import org.apache.cxf.ws.addressing.ObjectFactory;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.svng.DataTypes;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.ws.BindingProvider;
import java.net.UnknownHostException;
import java.util.*;

import static org.apache.cxf.ws.addressing.JAXWSAConstants.CLIENT_ADDRESSING_PROPERTIES;

public class WsClient {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static final ObjectFactory WSA_OBJECT_FACTORY = new ObjectFactory();
	private DataTypes type;
	private List<Pair<String, SvsyncAsync>> clients = new ArrayList<Pair<String, SvsyncAsync>>();
	private Long sessionId;
	private static InheritableThreadLocal<Integer> index = new InheritableThreadLocal<Integer>() {
		@Override
		protected Integer initialValue() {
			return 0;
		}
	};

	public WsClient(String url, String callbackAddress, Long sessionId, DataTypes type) throws UnknownHostException {
		this.type = type;
		this.sessionId = sessionId;
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setServiceClass(SvsyncAsync.class);
		factory.getFeatures().add(new WSAddressingFeature());
		for (String address : url.split("\\s+")) {
			factory.setAddress(address);
			clients.add(new ImmutablePair(address, (SvsyncAsync)factory.create()));
			Client clientLog = ClientProxy.getClient(getLastClient());
			if (clientLog != null) {
				HTTPConduit conduit = (HTTPConduit)clientLog.getConduit();
				if (conduit != null) {
					HTTPClientPolicy policy = new HTTPClientPolicy();
					policy.setConnectionTimeout(SystemConstants.ADAPTER_TIMEOUT);
					policy.setReceiveTimeout(SystemConstants.ADAPTER_TIMEOUT);
					conduit.setClient(policy);
				}
				clientLog.getInInterceptors().add(new LoggingInInterceptor());
				clientLog.getOutInterceptors().add(new LoggingOutInterceptor());
				Map<String, Object> requestContext = ((BindingProvider)getLastClient()).getRequestContext();
				requestContext.put(CLIENT_ADDRESSING_PROPERTIES, createMaps(callbackAddress));
			}
		}
		Integer i = getIndex();
		logger.info("Clients successfully created");
	}

	private SvsyncAsync getLastClient() {
		return clients.get(clients.size()-1).getValue();
	}

	private SvsyncAsync getClient(Integer index) {
		return clients.get(index).getValue();
	}

	private AddressingProperties createMaps(String replyTo) {
		AddressingProperties maps = new AddressingProperties();
		AttributedURIType messageID = WSA_OBJECT_FACTORY.createAttributedURIType();
		messageID.setValue("urn:uuid1:" + System.currentTimeMillis());
		maps.setMessageID(messageID);
		EndpointReferenceType ref = EndpointReferenceUtils.getEndpointReference(replyTo);
		maps.setReplyTo(ref);
		return maps;
	}

	private SyncResponseHeadType getRequest(Object req) throws Exception {
		RuntimeException exception = null;
		for (Pair<String, SvsyncAsync> client : clients) {
			try {
				logger.debug("Send request to [" + getIndex() + "][" + client.getKey() + "]");
				switch (type) {
					case DBAL: return client.getValue().getBalance((SyncRequestHeadType)req);
					case CREF: return client.getValue().getCards((SyncRequestHeadType)req);
					case MERCH: return client.getValue().getMerchant((SyncRequestHeadType)req);
					case TERM: return client.getValue().getTerminal((SyncRequestHeadType)req);
					case NTF: return client.getValue().getNotifications((SyncRequestHeadType)req);
					case PRODUCT: return client.getValue().getProduct((SyncRequestHeadType)req);
					case REJECT: return client.getValue().getReject((SyncRequestHeadType)req);
					case RATE: return client.getValue().getConvRate((ConvRateRequest)req);
					case POSTING: return client.getValue().getPosting((PostingRequest)req);
					case CARDS: return client.getValue().getCardStatuses((CardStatusesRequest)req);
					case PERSONS: return client.getValue().getPersons((SyncRequestHeadType)req);
					case COMPANIES: return client.getValue().getCompanies((SyncRequestHeadType)req);
					default: return null;
				}
			} catch (RuntimeException e) {
				logger.debug(e.getMessage());
				exception = e;
				setIndex(getIndex()+1);
			}
		}
		if (exception != null) {
			throw exception;
		}
		return null;
	}

	private void getCancel(Object req) throws Exception {
		RuntimeException exception = null;
		try {
			logger.debug("Send cancellation to [" + getIndex() + "][" + clients.get(getIndex()).getKey() + "]");
			clients.get(getIndex()).getValue().cancel((SyncRequestHeadType) req);
		} catch (RuntimeException e) {
			logger.debug(e.getMessage());
			throw e;
		}
	}

	public void sendRequest(Map<String, Object> params) throws Exception, DatatypeConfigurationException {
		logger.info("WsClient.sendRequest " + type);
		SyncRequestHeadType syncRequestHeadType = new SyncRequestHeadType();
		syncRequestHeadType.setSessionId(sessionId.toString());
		switch (type) {
			case RATE:
				ConvRateRequest convRateRequest = new ConvRateRequest();
				convRateRequest.setHead(syncRequestHeadType);
				if (params != null) {
					if (params.containsKey("I_INST_ID") && params.get("I_INST_ID") != null) {
						convRateRequest.setInstitute(params.get("I_INST_ID").toString());
					}
				}
				getRequest(convRateRequest);
				break;
			case POSTING:
				PostingRequest posting = new PostingRequest();
				posting.setHead(syncRequestHeadType);
				if (params != null) {
					if (params.containsKey("I_INST_ID") && params.get("I_INST_ID") != null) {
						posting.setInstitute(Integer.valueOf(params.get("I_INST_ID").toString()));
					}
					if (params.containsKey("I_START_DATE") && params.get("I_START_DATE") != null) {
						GregorianCalendar cl = new GregorianCalendar();
						cl.setTime((Date) params.get("I_START_DATE"));
						posting.setSttlDateTime(DatatypeFactory.newInstance().newXMLGregorianCalendar(cl));
					}
					if (params.containsKey("I_NETWORK_ID") && params.get("I_NETWORK_ID") != null) {
						posting.setNwIndicator(999);
					}
					if (params.containsKey("I_SVFE_NETWORK") && params.get("I_SVFE_NETWORK") != null) {
						posting.setNwIndicator(Double.valueOf(params.get("I_SVFE_NETWORK").toString()).intValue());
					}
				}
				getRequest(posting);
				break;
			case CARDS:
				CardStatusesRequest cards = new CardStatusesRequest();
				cards.setHead(syncRequestHeadType);
				if (params != null) {
					if (params.containsKey("I_INST_ID") && params.get("I_INST_ID") != null) {
						cards.setInstitute(Integer.valueOf(params.get("I_INST_ID").toString()));
					}
					if (params.containsKey("I_NETWORK_ID") && params.get("I_NETWORK_ID") != null) {
						cards.setNwIndicator(999);
					}
					if (params.containsKey("I_SVFE_NETWORK") && params.get("I_SVFE_NETWORK") != null) {
						cards.setNwIndicator(Double.valueOf(params.get("I_SVFE_NETWORK").toString()).intValue());
					}
				}
				getRequest(cards);
				break;
			default:
				getRequest(syncRequestHeadType);
				break;
		}
	}

	public void sendRequest(Integer instId) throws Exception {
		logger.info("WsClient.sendRequest " + type);
		SyncRequestHeadType syncRequestHeadType = new SyncRequestHeadType();
		syncRequestHeadType.setSessionId(sessionId.toString());
		switch (type) {
			case RATE:
				ConvRateRequest convRateRequest = new ConvRateRequest();
				convRateRequest.setHead(syncRequestHeadType);
				if (instId != null) {
					convRateRequest.setInstitute(instId.toString());
				}
				getRequest(convRateRequest);
				break;
			default:
				getRequest(syncRequestHeadType);
				break;
		}
	}

	public void cancel() {
		logger.info("Sending cancellation");
		SyncRequestHeadType params = new SyncRequestHeadType();
		params.setSessionId(sessionId.toString());
		params.setException(true);
		try {
			getCancel(params);
		} catch (Exception e) {
			logger.error("Failed to send invalidation message", e);
		}
	}

	public Integer getIndex() {
		return index.get();
	}
	public void setIndex(Integer index) {
		this.index.set(index);
	}
}

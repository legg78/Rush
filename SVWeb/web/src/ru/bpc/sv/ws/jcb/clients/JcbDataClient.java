package ru.bpc.sv.ws.jcb.clients;

import com.bpcbt.svxp.modules.jcb.*;
import org.apache.commons.lang3.StringUtils;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.jms.spec.JMSSpecConstants;
import org.apache.log4j.Logger;
import ru.bpc.sv2.interchange.CommonOperation;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.ps.ModuleSession;
import ru.bpc.sv2.ps.ModuleSessionTrace;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.sql.Timestamp;
import java.util.*;

public class JcbDataClient {

	private static final Logger logger = Logger.getLogger(JcbDataClient.class);

	private JcbDataAccessService client;

	public JcbDataClient() {
		String mqUrl = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.MESSAGE_QUEUE_LOCATION);
		if (mqUrl == null) {
			mqUrl = "tcp://localhost:61616";
			logger.warn("No mq address in db, use default: " + mqUrl);
		}
		String address = String.format("jms:jndi:dynamicQueues/%s"
				+ "?jndiInitialContextFactory=org.apache.activemq.jndi.ActiveMQInitialContextFactory"
				+ "&jndiConnectionFactoryName=ConnectionFactory"
				+ "&jndiURL=%s", "JCB_DATA_SERVICE", mqUrl);
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setTransportId(JMSSpecConstants.SOAP_JMS_SPECIFICATION_TRANSPORTID);
		factory.setServiceClass(JcbDataAccessService.class);
		factory.setAddress(address);
		client = (JcbDataAccessService) factory.create();
	}

	public List<ModuleSession> getSessions(ModuleSession filter, SelectionParams params) {
		List<ModuleSession> result = new ArrayList<ModuleSession>();
		try {
			JcbModuleSessionRequest request = new JcbModuleSessionRequest();
			request.setSessionId(filter.getId() != null ? filter.getId().toString() : null);
			request.setCreatedFrom(getCalendar(filter.getCreated()));
			request.setCreatedTo(getCalendar(filter.getCreatedTo()));
			request.setFileName(StringUtils.isNotBlank(filter.getFileName()) ? filter.getFileName() : null);
			request.setProcess(StringUtils.isNotBlank(filter.getProcess()) ? filter.getProcess() : null);
			request.setResult(filter.getResult());
			JcbModuleSessionResponse response = client.getJcbModuleSessionRequest(request);
			if (response != null && response.getSessions() != null && response.getSessions().getSession() != null) {
				for (com.bpcbt.svxp.modules.jcb.ModuleSession next : response.getSessions().getSession()) {
					ModuleSession newSession = new ModuleSession();
					newSession.setId(next.getId());
					newSession.setCreated(next.getCreated().toGregorianCalendar().getTime());
					newSession.setFileName(next.getFileName());
					newSession.setProcess(next.getProcess());
					newSession.setResult(next.isResult());
					newSession.setTotal(next.getTotal());
					newSession.setSucceed(next.getSucceed());
					result.add(newSession);
				}
			}
			if (params != null && params.getRowIndexEnd() > 0) {
				int size = result.size();
				return result.subList(Math.min(size - 1, params.getRowIndexStart()), Math.min(size, params.getRowIndexEnd() + 1));
			} else {
				return result;
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<ModuleSession>();
	}

	public List<ModuleSessionTrace> getJcbSessionTrace(String sessionId, SelectionParams params) {
		List<ModuleSessionTrace> result = new ArrayList<ModuleSessionTrace>();
		try {
			JcbModuleSessionTraceRequest request = new JcbModuleSessionTraceRequest();
			request.setSessionId(sessionId);
			JcbModuleSessionTraceResponse response = client.getJcbModuleSessionTraceRequest(request);
			if (response != null && response.getTraces() != null && response.getTraces().getTrace() != null) {
				for (com.bpcbt.svxp.modules.jcb.ModuleSessionTrace next : response.getTraces().getTrace()) {
					ModuleSessionTrace newTrace = new ModuleSessionTrace();
					newTrace.setId(String.valueOf(next.getId()));
					newTrace.setEventDate(new Timestamp(next.getEventDate().toGregorianCalendar().getTimeInMillis()));
					newTrace.setLogLevel(next.getLogLevel());
					newTrace.setLogger(next.getLogger());
					newTrace.setMessage(next.getMessage());
					result.add(newTrace);
				}
			}
			if (params != null && params.getRowIndexEnd() > 0) {
				int size = result.size();
				return result.subList(Math.min(size - 1, params.getRowIndexStart()), Math.min(size, params.getRowIndexEnd() + 1));
			} else {
				return result;
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<ModuleSessionTrace>();
	}

	public List<CommonOperation> getJcbOperations(CommonOperation operFilter, Date operDateTo,
	                                              Map<String, JcbInterchangeOperation> jcbData, SelectionParams params) {
		jcbData.clear();
		List<CommonOperation> result = new ArrayList<CommonOperation>();
		try {
			JcbDataAccessRequest request = new JcbDataAccessRequest();
			request.setSessionId(operFilter.getId() != null ? operFilter.getId().toString() : null);
			request.setAcqInstId(operFilter.getAcqInstId());
			request.setIssCardNumber(StringUtils.isNotBlank(operFilter.getIssCardNumber()) ? operFilter.getIssCardNumber() : null);
			request.setOperType(operFilter.getOperType());
			request.setOperDate(getCalendar(operFilter.getOperDate()));
			request.setOperDateTo(getCalendar(operDateTo));
			if (params != null) {
				request.setFirstResult(params.getRowIndexStart());
				request.setMaxResults(params.getRowIndexEnd() - params.getRowIndexStart());
			} else {
				request.setFirstResult(0);
				request.setMaxResults(Integer.MAX_VALUE);
			}
			JcbDataAccessResponse response = client.getJcbClearingOperationRequest(request);
			if (response != null && response.getOperations() != null && response.getOperations().getOperation() != null) {
				for (JcbClearingOperation next : response.getOperations().getOperation()) {
					CommonOperation operation = new CommonOperation();
					operation.setId(next.getId());
					operation.setSessionId(next.getSessionId());
					operation.setOperType(next.getOperType());
					operation.setOperDate(next.getOperDate().toGregorianCalendar().getTime());
					operation.setNetworkRefnum(next.getNetworkRefnum());
					operation.setMerchantNumber(next.getMerchantNumber());
					operation.setMcc(next.getMcc());
					operation.setMerchantName(next.getMerchantName());
					operation.setMerchantStreet(next.getMerchantStreet());
					operation.setMerchantCity(next.getMerchantCity());
					operation.setMerchantRegion(next.getMerchantRegion());
					operation.setMerchantCountry(next.getMerchantCountry());
					operation.setMerchantPostcode(next.getMerchantPostcode());
					operation.setTerminalNumber(next.getTerminalNumber());
					operation.setAcqInstId(next.getAcqInstId());
					operation.setIssCardNumber(next.getIssCardNumber());
					operation.setOperAmount(next.getOperAmount());
					operation.setOperCurrency(next.getOperCurrency());
					jcbData.put(String.valueOf(next.getId()), next.getJcbInterchangeOperation());
					result.add(operation);
				}
			}
			return result;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<CommonOperation>();
	}

	private XMLGregorianCalendar getCalendar(Date date) throws DatatypeConfigurationException {
		if (date == null) {
			return null;
		}
		GregorianCalendar c = new GregorianCalendar();
		c.setTime(date);
		return DatatypeFactory.newInstance().newXMLGregorianCalendar(c);
	}
}

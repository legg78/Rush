package ru.bpc.servlet;

import org.apache.log4j.Logger;
import ru.bpc.sv.cyberplatin.*;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import javax.xml.ws.BindingProvider;
import java.io.IOException;
import java.math.BigDecimal;
import java.security.cert.X509Certificate;
import java.util.Map;


public class CyberplatServlet extends HttpServlet{

	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger(CyberplatServlet.class.getName());
	
	private SettingsDao settingsDao = new SettingsDao();
	
	public CyberplatServlet(){
		super();
		logger.info("CyberplatServlet created");
	}
	
	@Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
	
		try {
			processCyberplatRequest(request, response);
		} catch (Exception e){
			errorToResponse(CyberplatConst.ERR_INTERNAL_ERROR, response);
			logger.error(null, e);
		}
	}
	
	private void processCyberplatRequest(HttpServletRequest request, HttpServletResponse response){
		String message = "Client certeficate is not presented";
		
		// getting certeficate and check it
		X509Certificate cert = getCerteficate(request);
		if (cert == null){
			errorToResponse(CyberplatConst.ERR_CERT_NOT_PRESENTED, response, message);
			return;
		}
		
		// getting subject common name from certificate
		String domainName = cert.getSubjectDN().getName();
		String commonName = getCommonName(domainName);
		
		// check request parameters
		Map parameters = request.getParameterMap();
		if (parameters == null){
			errorToResponse(CyberplatConst.ERR_UNKNOW_REQUEST_TYPE, response);
			return;
		}
		
		// check 
		String action = resolveAction(parameters);
		if (action == null){
			errorToResponse(CyberplatConst.ERR_UNKNOW_REQUEST_TYPE, response);
			return;
		}

		String endpoint = getEndPoint();
		if (endpoint == null){
			errorToResponse(CyberplatConst.ERR_INTERNAL_ERROR, response);
			return;
		}
		
		// call web-service 
		ResponseType responseObj = invokeOperation(parameters, commonName, endpoint);
		if (responseObj == null){
			errorToResponse(CyberplatConst.ERR_UNKNOW_REQUEST_TYPE, response);
			return;
		}
		
		resultToResponse(responseObj,response);
	}
	
	private String getEndPoint(){
		String location = settingsDao.getParameterValueV(null,
				SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM,
				null);		
		
		Double port = settingsDao.getParameterValueN(null,
				SettingsConstants.CYBERPLAT_WS_PORT, LevelNames.SYSTEM,
				null);
		
		if (location == null || port == null){
			logger.warn("System parameter FRONT_END_LOCATION or CYBERPLAT_WS_PORT is undefined");
			return null;
		}
		
		int intPort = port.intValue();
		
		return location + ":" + String.valueOf(intPort);
	}
	
	private X509Certificate getCerteficate(HttpServletRequest request){
		X509Certificate[] certs = (X509Certificate[]) request.getAttribute("javax.servlet.request.X509Certificate");
		if (certs == null){
			return null;
		} else {
			return certs[0];
		}
		
	}
	
	private ResponseType invokeOperation(Map parameters, String agentId, String endpoint){
		ResponseType result = null;
		
		// resolving	
		String number = resolveNumber(parameters);
		Integer type = resolveType(parameters);
		BigDecimal amount = resolveAmount(parameters);
		String receipt = resolveReceipt(parameters);
		String date = resolveDate(parameters);
		//String additional = resolveAdditional(parameters); // reserved. you may delete it. 
		String mes = resolveMes(parameters);
		String action = resolveAction(parameters);
		
		ObjectFactory of = new ObjectFactory();
		
		RequestType requestObj = of.createRequestType();		
		
		// configure
		if (action.equals(CyberplatConst.ACTION_PAYMENT)){
			ActionType actionObj = ActionType.PAYMENT;
			requestObj.setAction(actionObj);
			requestObj.setNumber(number);
			requestObj.setType(type);
			requestObj.setAmount(amount);
			requestObj.setReceipt(receipt);
			requestObj.setDate(date);
			requestObj.setAgentIdent(agentId);
			
		} else if (action.equals(CyberplatConst.ACTION_CHECK)){
			ActionType actionObj = ActionType.CHECK;
			requestObj.setAction(actionObj);
			requestObj.setNumber(number);
			requestObj.setType(type);
			requestObj.setAmount(amount);
			requestObj.setAgentIdent(agentId);
		} else if (action.equals(CyberplatConst.ACTION_CANCEL)){
			ActionType actionObj = ActionType.CANCEL;
			requestObj.setAction(actionObj);
			requestObj.setReceipt(receipt);
			requestObj.setMes(mes);
			requestObj.setAgentIdent(agentId);
		} else if (action.equals(CyberplatConst.ACTION_STATUS)){
			ActionType actionObj = ActionType.STATUS;
			requestObj.setAction(actionObj);
			requestObj.setReceipt(receipt);
			requestObj.setAgentIdent(agentId);
		} else {			
			return result;
		}
		
		CyberplatIn_Service service = new CyberplatIn_Service();
		CyberplatIn port = service.getCyberplatInSOAP();
		BindingProvider bp = (BindingProvider)port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, endpoint);
		
		result = port.operation(requestObj);
		return result;
	}
	
	private String getCommonName(String domainName){
		String commonName = null;		
		String[] elements = domainName.split(", ");
		for (int i = 0, length = elements.length; i < length; i++){
			String element = elements[i];
			if (element.startsWith("CN")){
				commonName = element.split("=")[1];
			}
		}
		return commonName;
	}
	
	private void resultToResponse(ResponseType responseObj,
			HttpServletResponse response) {
		response.setContentType("text/xml");
		XMLStreamWriter writer = getXmlStreamWriter(response);
		try{
			writer.writeStartDocument("windows-1251","1.0");
			writer.writeStartElement(CyberplatConst.RESPONSE_ROOT);			
			writer.writeStartElement(CyberplatConst.RESPONSE_CODE);
			writer.writeCharacters(String.valueOf(responseObj.getCode()));
			if (responseObj.getMessage() != null){
				writer.writeStartElement(CyberplatConst.RESPONSE_MESSAGE);
				writer.writeCharacters(String.valueOf(responseObj.getMessage()));
				writer.writeEndElement();
			}
			if (responseObj.getDate() != null){
				writer.writeStartElement(CyberplatConst.RESPONSE_DATE);
				writer.writeCharacters(String.valueOf(responseObj.getDate()));
				writer.writeEndElement();
			}
			if (responseObj.getDate() != null){
				writer.writeStartElement(CyberplatConst.RESPONSE_AUTHCODE);
				writer.writeCharacters(String.valueOf(responseObj.getAuthcode()));
				writer.writeEndElement();
			}
			if (responseObj.getDate() != null){
				writer.writeStartElement(CyberplatConst.RESPONSE_ADD);
				writer.writeCharacters(String.valueOf(responseObj.getAdd()));
				writer.writeEndElement();
			}
			writer.writeEndElement();
			writer.writeEndElement();
			writer.writeEndDocument();
		} catch (XMLStreamException e) {
			e.printStackTrace();
		}
	}

	private void errorToResponse(int code, HttpServletResponse response, String message){
		response.setContentType("text/xml");
		XMLStreamWriter writer = getXmlStreamWriter(response);
		try {
			writer.writeStartDocument("windows-1251","1.0");
			writer.writeStartElement(CyberplatConst.RESPONSE_ROOT);
			writer.writeStartElement(CyberplatConst.RESPONSE_CODE);
			writer.writeCharacters(String.valueOf(code));			
			writer.writeEndElement();
			if (message != null){
				writer.writeStartElement(CyberplatConst.RESPONSE_MESSAGE);
				writer.writeCharacters(message);
				writer.writeEndElement();
			}
			writer.writeEndElement();
			writer.writeEndDocument();
		} catch (XMLStreamException e) {
			e.printStackTrace();
		}
	}
	
	private void errorToResponse(int code, HttpServletResponse response){
		errorToResponse(code, response, null);
	}
	
	private XMLStreamWriter getXmlStreamWriter(HttpServletResponse response){ 
		XMLStreamWriter result = null;
		XMLOutputFactory factory = XMLOutputFactory.newInstance();
		try {
			result = factory.createXMLStreamWriter(response.getWriter());			
		} catch (Exception e) {
			e.printStackTrace();
		}
		return result;
	}
	
	private String resolveAction(Map parameters){
		String result = null;
		if (parameters.containsKey(CyberplatConst.ACTION)){
			result = ((String[])parameters.get(CyberplatConst.ACTION))[0];
		}
		return result;
	}
	
	private String resolveNumber(Map parameters){
		String result = null;
		if (parameters.containsKey(CyberplatConst.NUMBER)){
			result = ((String[])parameters.get(CyberplatConst.NUMBER))[0];
		}
		return result;
	}
	
	private Integer resolveType(Map parameters){
		Integer result = null;
		if (parameters.containsKey(CyberplatConst.TYPE)){
			String resultStr = ((String[])parameters.get(CyberplatConst.TYPE))[0]; 
			result = Integer.parseInt(resultStr);
		}
		return result;
	}	
	
	private BigDecimal resolveAmount(Map parameters){
		BigDecimal result = null;
		if (parameters.containsKey(CyberplatConst.AMOUNT)){
			String resultStr = ((String[])parameters.get(CyberplatConst.AMOUNT))[0];
			result = new BigDecimal(resultStr);
		}
		return result;
	}	
	
	private String resolveReceipt(Map parameters){
		String result = null;
		if (parameters.containsKey(CyberplatConst.RECEIPT)){
			result = ((String[])parameters.get(CyberplatConst.RECEIPT))[0];
		}
		return result;
	}	
	
	private String resolveDate(Map parameters){
		String result = null;
		if (parameters.containsKey(CyberplatConst.DATE)){
			result = ((String[])parameters.get(CyberplatConst.DATE))[0];
		}
		return result;
	}	
	
	private String resolveMes(Map parameters){
		String result = null;
		if (parameters.containsKey(CyberplatConst.MES)){
			result = ((String[])parameters.get(CyberplatConst.MES))[0];
		}
		return result;
	}	
	
	private String resolveAdditional(Map parameters){
		String result = null;
		if (parameters.containsKey(CyberplatConst.ADDITIONAL)){
			result = ((String[])parameters.get(CyberplatConst.ADDITIONAL))[0];
		}
		return result;
	}	
	
}

package ru.bpc.sv.ws.integration;

import in.bpc.sv.svxp.*;
import in.bpc.sv.svxp.integration.AtmDowntimeRequest;
import in.bpc.sv.svxp.integration.AtmTransRequest;
import in.bpc.sv.svxp.integration.CurrencyRateRequest;
import in.bpc.sv.svxp.integration.InstListReques;
import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv.processesws.ObjectFactory;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.svxp.integration.Fault;
import ru.bpc.svxp.integration.Fault_Exception;

import javax.annotation.Resource;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.naming.Context;
import javax.servlet.ServletContext;
import javax.sql.DataSource;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

@WebService(name = "svcmWS", portName = "svcmWSSOAP", serviceName = "svcmWS", targetNamespace = "http://sv.bpc.in/SVXP/integration/")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso( { ObjectFactory.class })

public class SvcmWS implements in.bpc.sv.svxp.integration.SvcmWS {
	@Resource
	private WebServiceContext wsContext;
	private IntegrationDao integDao;
	private static final Logger logger = Logger.getLogger("SvCmWs");

	@Override
	@WebMethod(action = "http://sv.bpc.in/SVXP/integration/getAtmDowntime")
	@WebResult(name = "getAtmDowntimeResponse", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "output")
	public Downtimes getAtmDowntime(
			@WebParam(name = "getAtmDowntimeRequest", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "input") AtmDowntimeRequest input) {
		Downtimes result = new Downtimes();
		Map <String, Object>map = new HashMap<String, Object>();
		XMLGregorianCalendar cal = input.getLastLoadedDate();
		Date date = cal.toGregorianCalendar().getTime();
		map.put("last_date", date);
		try{
			Long userId = initDao();
			result = integDao.getAtmDowntimes(map);
		}catch (UserException e) {
			logger.error("", e);
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			//throw new Fault_Exception("ERROR", fault);
		} catch (Fault_Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		return result;
	}

	@Override
	@WebMethod(action = "http://sv.bpc.in/SVXP/integration/getAtmList")
	@WebResult(name = "getAtmListResponse", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "output")
	public Atms getAtmList() {
		Atms atmsList = new Atms();
		try{
			Long userId = initDao();
			atmsList = integDao.getAtms(userId);
			
		}catch (UserException e) {
			logger.error("", e);
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			//throw new Fault_Exception("ERROR", fault);
		} catch (Fault_Exception e) {
			
			e.printStackTrace();
		}
		return atmsList;
	}

	@Override
	@WebMethod(action = "http://sv.bpc.in/SVXP/integration/getAtmTrans")
	@WebResult(name = "getAtmTransResponse", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "output")
	public Transactions getAtmTrans(
			@WebParam(name = "getAtmTransRequest", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "input") AtmTransRequest input) {
		String operId = input.getLastOperId();
		Integer fretchSize = input.getFetchSize();
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("operId", Long.parseLong(operId));
		map.put("maxCount", fretchSize);
		Transactions transactions = new Transactions();
		try{
			Long userId = initDao();
			transactions = integDao.getAtmTrans(map);
		}catch (UserException e) {
			logger.error("", e);
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			//throw new Fault_Exception("ERROR", fault);
		} catch (Fault_Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		return transactions;
	}

	@Override
	@WebMethod(action = "http://sv.bpc.in/SVXP/integration/getCurrencyRate")
	@WebResult(name = "getCurrencyRateResponse", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "output")
	public CurrencyRates getCurrencyRate(
			@WebParam(name = "getCurrencyRateRequest", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "input") CurrencyRateRequest input) {
		CurrencyRates result = new CurrencyRates();
		List<Integer> instId = input.getInstId();
		Integer[] mas = instId.toArray(new Integer[instId.size()]);
		Map <String, Object> map = new HashMap<String, Object>();
		map.put("instId", mas);
		try{
			Long userId = initDao();
			result = integDao.getCurrencyRates(map);
		}catch (UserException e) {
			logger.error("", e);
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			//throw new Fault_Exception("ERROR", fault);
		} catch (Fault_Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} 
		return result;
	}

	
	
	private long initDao() throws Fault_Exception {
		// getting DAO
		try {
			ServletContext servletContext =
			    (ServletContext) wsContext.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
			MessageContext mc = wsContext.getMessageContext();
	        mc.get(BindingProvider.USERNAME_PROPERTY);
	        mc.get(BindingProvider.PASSWORD_PROPERTY);
			String userFile = servletContext.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
			Properties prop = new Properties();
			String wsUserName;
			String wsPassword;
			try {
				prop.load(new FileInputStream(userFile));
				wsUserName = prop.getProperty(WebServiceConstants.WS_USERNAME_PROPERTY);
				wsPassword = prop.getProperty(WebServiceConstants.WS_PASSWORD_PROPERTY);
			} catch (FileNotFoundException e) {
				logger.error(e.getMessage());
				logger.trace("Using default credentials...");
				wsUserName = wsPassword = WebServiceConstants.WS_DEFAULT_CREDENTIALS;
			}
			
			long userSessionId = registerSession(wsUserName);
			
			Properties p = new Properties();
			p.setProperty(Context.SECURITY_PRINCIPAL, wsUserName);
			p.setProperty(Context.SECURITY_CREDENTIALS, wsPassword);

			//context = new InitialContext(p);
			integDao = new IntegrationDao();
			
			return userSessionId;
		} catch (Exception e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", new Fault());
		}
    }
	
	private Long registerSession(String userName) throws Exception {
		Long sessionId = null;
		Connection con = JndiUtils.getConnection();
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
					"  i_user_name  	=> ?" +
					", io_session_id	=> ?" +
					", i_ip_address		=> ?)}"
					);
			
			cstmt.setString(1, userName);
			cstmt.setObject(2, null, OracleTypes.BIGINT);
			cstmt.setObject(3, null, OracleTypes.VARCHAR);
			cstmt.registerOutParameter(2, OracleTypes.BIGINT);
			cstmt.executeUpdate();
			
			sessionId = cstmt.getLong(2);
			if (sessionId == null) {
				throw new Exception("Couldn't set user context.");
			}
			
			con.commit();
		} catch (Exception e) {
			try {
				con.rollback();
			} catch (SQLException ex) {}
			throw e;
		} finally {
			if (cstmt != null) {
				try {
					cstmt.close();
				} catch (SQLException ex) {}
			}
			if (con != null) {
				try {
					con.close();
				} catch (SQLException ex) {}
			}
		}

		return sessionId;
	}

	@WebMethod(action = "http://sv.bpc.in/SVXP/integration/getInstList")
	@WebResult(name = "getInstListResponse", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "output")
	public Insts getInstList(
	        @WebParam(name = "getInstListRequest", targetNamespace = "http://sv.bpc.in/SVXP/integration", partName = "input")
	        InstListReques input){
		Map <String, Object> map = new HashMap<String, Object>();
		String lang = input.getLang();
		if (lang == null || lang.length() == 0){
			lang = "LANGENG";
		}
		map.put("lang", lang);
		Insts result = new Insts();
		
		try{
			Long userId = initDao();
			result = integDao.getInsts(map);
			
		}catch (UserException e) {
			logger.error("", e);
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			//throw new Fault_Exception("ERROR", fault);
		} catch (Fault_Exception e) {
			
			e.printStackTrace();
		}
		return result;
	}


}

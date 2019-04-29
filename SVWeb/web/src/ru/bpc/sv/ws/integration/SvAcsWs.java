package ru.bpc.sv.ws.integration;

import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.acs.integration.*;
import ru.bpc.sv.processesws.ObjectFactory;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.logic.utility.JndiUtils;

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
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

@WebService(name = "SvACSWS", portName = "SvACSWSSOAP", serviceName = "SvACSWS", targetNamespace = "http://bpc.ru/ACS/integration/")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso( { ObjectFactory.class })
public class SvAcsWs implements SvACSWS{
	private static final Logger logger = Logger.getLogger("SVACS");
	
	IntegrationDao integDao;
	@Resource
	private WebServiceContext wsContext;
	
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

	@Override
	@WebMethod(action = "http://bpc.ru/ACS/integration/generateCavv")
	@WebResult(name = "generateCavvResponse", targetNamespace = "http://bpc.ru/ACS/integration", partName = "output")
	public String generateCavv(
			@WebParam(name = "generateCavvRequest", targetNamespace = "http://bpc.ru/ACS/integration", partName = "input") GenerateCavvRequest request)
			throws Fault_Exception {
		Map <String, Object> filters = new HashMap<String, Object>();
		filters.put("auth_res_code", request.getAuthResCode());
		filters.put("card_number", request.getCardNumber());
		filters.put("key_indicator", request.getKeyIndicator());
		filters.put("sec_factor_auth_code", request.getSecFactorAuthCode());
		filters.put("unpredictable_number", request.getUnpredictableNumber());
		initDao();
		String result = new String();
		try{		
			result = integDao.generateCaav(filters);
		}catch (Exception e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", 
					generateExceprion(e.getMessage()));
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/ACS/integration/isCardInvolved")
	@WebResult(name = "isCardInvolvedResponse", targetNamespace = "http://bpc.ru/ACS/integration", partName = "output")
	public int isCardInvolved(
			@WebParam(name = "isCardInvolvedRequest", targetNamespace = "http://bpc.ru/ACS/integration", partName = "input") IsCardInvolvedRequest request)
			throws Fault_Exception {
		Map <String, Object> filters = new HashMap<String, Object>();
		filters.put("card_number", request.getCardNumber());
		if (request.getEffDate() != null){
			XMLGregorianCalendar cal = request.getEffDate();
			Date date = cal.toGregorianCalendar().getTime();
			filters.put("eff_date", date);
		}
		initDao();
		int result = 0;
		try{		
			result = integDao.isCardInvolved(filters);
		}catch (Exception e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", 
					generateExceprion(e.getMessage()));
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/ACS/integration/getTelNumber")
	@WebResult(name = "getTelNumberResponse", targetNamespace = "http://bpc.ru/ACS/integration", partName = "output")
	public String getTelNumber(
			@WebParam(name = "getTelNumberRequest", targetNamespace = "http://bpc.ru/ACS/integration", partName = "input") GetTelNumberRequest request)
			throws Fault_Exception {
		Map<String, Object> filters = new HashMap<String, Object>();
		filters.put("card_number", request.getCardNumber());
		filters.put("otp", request.getOtp());
		initDao();
		String result = new String();
		try{
			result = integDao.getTelNumber(filters);
		}catch (Exception e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", 
					generateExceprion(e.getMessage()));
		}
		return result;
	}
	
	private Fault generateExceprion(String message){
		Fault fault = new Fault();
		if (message != null && message.startsWith("ORA-")) {
			message = message.replaceFirst("ORA-\\d+: ", "");
			message = message.split("ORA-\\d+:")[0];
		}
		fault.setCode("UNKNOWN");
		fault.setDescription(message);
		return fault;
	}

}

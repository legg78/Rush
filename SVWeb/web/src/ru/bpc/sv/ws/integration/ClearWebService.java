package ru.bpc.sv.ws.integration;

import oracle.jdbc.OracleTypes;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.logic.ClearingDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.sv.svxp.clearing.ObjectFactory;
import ru.bpc.sv.svxp.clearing.Operation;
import ru.bpc.svxp.clearing.ws.*;

import javax.annotation.Resource;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.servlet.ServletContext;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

@SuppressWarnings("unused")
@WebService(name = "ClearingWS", portName = "ClearingWSSOAP", serviceName = "ClearingWS", targetNamespace = "http://bpc.ru/SVXP/clearing/ws")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso({ObjectFactory.class})
public class ClearWebService implements ClearingWS {
	private static final Logger logger = Logger.getLogger("SVAP");

	ClearingDao clearDao = new ClearingDao();

	@Resource
	private WebServiceContext wsContext;

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/clearing/ws/operation")
	public OperationResponse operation(
			@WebParam(name = "operationRequest", targetNamespace = "http://bpc.ru/SVXP/clearing/ws", partName = "request") OperationRequest request)
			throws Fault_Exception {

		initDao();

		OperationResponse result;
		Operation operation = request.getOperation();
		try {
			result = new OperationResponse();
			Long operId = clearDao.performOperation(operation);
			result.setOperation(clearDao.getOperationResult(operId));
		} catch (UserException e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", generateException(e));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			throw new Fault_Exception("ERROR", fault);
		}
		return result;
	}

	@Override
	@WebMethod(action = "http://bpc.ru/SVXP/clearing/ws/operations")
	public OperationsResponse operations(
			@WebParam(name = "operationsRequest", targetNamespace = "http://bpc.ru/SVXP/clearing/ws", partName = "request") OperationsRequest request)
			throws Fault_Exception {

		initDao();

		OperationsResponse result;
		List<Operation> operations = request.getOperations();

		try {
			result = new OperationsResponse();
			List<Long> operIds = new ArrayList<>();
			for (Operation operation : operations) {
				operIds.add(clearDao.performOperation(operation));
			}
			result.getOperation().addAll(clearDao.getOperationResults(operIds));
		} catch (UserException e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", generateException(e));
		} catch (Exception e) {
			Fault fault = new Fault();
			String message = e.getMessage();
			if (message != null && message.startsWith("ORA-")) {
				message = message.replaceFirst("ORA-\\d+: ", "");
				message = message.split("ORA-\\d+:")[0];
			}
			fault.setCode("UNKNOWN");
			fault.setDescription(message);
			throw new Fault_Exception("ERROR", fault);
		}
		return result;
	}

	@WebMethod(exclude = true)
	private void initDao() throws Fault_Exception {
		// getting DAO
		try {
			ServletContext servletContext = (ServletContext) wsContext.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
			MessageContext mc = wsContext.getMessageContext();
			mc.get(BindingProvider.USERNAME_PROPERTY);
			mc.get(BindingProvider.PASSWORD_PROPERTY);
			String userFile = servletContext.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
			Properties prop = new Properties();
			String wsUserName;
			try {
				prop.load(new FileInputStream(userFile));
				wsUserName = prop.getProperty(WebServiceConstants.WS_USERNAME_PROPERTY);
			} catch (FileNotFoundException e) {
				logger.error(e.getMessage());
				logger.trace("Using default credentials...");
				wsUserName = WebServiceConstants.WS_DEFAULT_CREDENTIALS;
			}

			registerSession(wsUserName);
		} catch (Exception e) {
			logger.error("", e);
			throw new Fault_Exception("ERROR", new Fault());
		}
	}

	@WebMethod(exclude = true)
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
			if (sessionId == 0) {
				throw new Exception("Couldn't set user context.");
			}

			con.commit();
		} finally {
			DBUtils.close(cstmt);
			DBUtils.close(con);
		}

		return sessionId;
	}

	@WebMethod(exclude = true)
	private Fault generateException(Exception e) {
		String message = e.getMessage();
		Fault fault = new Fault();
		if (message != null && message.startsWith("ORA-")) {
			message = message.replaceFirst("ORA-\\d+: ", "");
			message = message.split("ORA-\\d+:")[0];
		}
		if (e instanceof UserException)
			fault.setCode(((UserException)e).getErrorCodeText());
		fault.setDescription(message);
		return fault;
	}

}

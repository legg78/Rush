package ru.bpc.sv.ws.process;

import org.apache.log4j.Logger;
import ru.bpc.sv.processesws.*;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessParameter;
import ru.bpc.sv2.scheduler.process.ContainerLauncher;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import ru.bpc.sv2.utils.UserException;

import javax.annotation.Resource;
import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.servlet.ServletContext;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Properties;

@WebService(name = "ProcessesWS", portName = "ProcessesSOAP", serviceName = "Processes", targetNamespace = "http://bpc.ru/sv/processesWS/")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
/* TODO: Below doesn't work in Websphere. Have to find a workaround
@com.sun.xml.ws.developer.SchemaValidation
*/
@XmlSeeAlso({ObjectFactory.class})
public class ProcessesWS implements Processes {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static final Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	@Resource
	private WebServiceContext wsContext;

	/**
	 * @param request
	 * @return returns ru.bpc.sv.processesws.RunProcessResponseType
	 * @throws ProcessesException
	 */
	@WebMethod(action = "http://bpc.ru/sv/processesWS/runProcess")
	@WebResult(name = "runProcessResponse", targetNamespace = "http://bpc.ru/sv/processesWS/", partName = "response")
	public RunProcessResponseType runProcess(
			@WebParam(name = "runProcessRequest", targetNamespace = "http://bpc.ru/sv/processesWS/", partName = "request") RunProcessRequestType request)
			throws ProcessesException {

		if (request.getContainerId() <= 0) {
			FaultType type = new FaultType();
			type.setText("Illegal containerId parameter value specified: " + request.getContainerId());
			throw new ProcessesException("Error", type);
		}

		logger.debug(getClass().getSimpleName() + ".runProcess");

		RequestContextHolder.setResponse((HttpServletResponse) wsContext.getMessageContext().get(MessageContext.SERVLET_RESPONSE));

		ProcessDao processDao;
		Long userSessionId;
		String wsUserName = null;
		try {
			ServletContext servletContext =
					(ServletContext) wsContext.getMessageContext().get(MessageContext.SERVLET_CONTEXT);

			String userFile = servletContext.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
			Properties prop = new Properties();
			try {
				prop.load(new FileInputStream(userFile));
				wsUserName = prop.getProperty(WebServiceConstants.WS_USERNAME_PROPERTY);
			} catch (FileNotFoundException e) {
				logger.error(e.getMessage());
			}

			if (wsUserName == null || wsUserName.trim().isEmpty()) {
				wsUserName = WebServiceConstants.WS_DEFAULT_CREDENTIALS;
				logger.trace("Using default credentials");
			}

			processDao = new ProcessDao();
			RolesDao rolesDao = new RolesDao();
			userSessionId = rolesDao.setInitialUserContext(null, wsUserName, null);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FaultType type = new FaultType();
			type.setText(e.getMessage());
			throw new ProcessesException("Error", type);
		}

		try {
			UserContextHolder.setUserName(wsUserName);

			ProcessBO container = new ProcessBO();
			container.setId(request.getContainerId());

			HashMap<String, Object> paramsMap = null;
			if (request.getProcessParams() != null && !request.getProcessParams().isEmpty()) {
				paramsMap = new HashMap<String, Object>();
				HashMap<String, String> paramDataTypes = getContainerParamsDataTypes(userSessionId,
						request.getContainerId(), processDao);
				for (ProcessParamsType param : request.getProcessParams()) {
					if (DataTypes.CHAR.equals(paramDataTypes.get(param.getParamName()))) {
						paramsMap.put(param.getParamName(), param.getParamValue());
					} else if (DataTypes.NUMBER.equals(paramDataTypes.get(param.getParamName()))) {
						paramsMap.put(param.getParamName(), new BigDecimal(param
								.getParamValue()));
					} else if (DataTypes.DATE.equals(paramDataTypes.get(param.getParamName()))) {
						Date date = parseDate(param.getParamValue());
						if (date == null) {
							String msg = "Couldn't parse date parameter: " + param.getParamName()
									+ " - " + param.getParamValue()
									+ ". Should be yyyy-mm-dd or dd.mm.yyyy";
							logger.error(msg);
							FaultType type = new FaultType();
							type.setText(msg);
							throw new ProcessesException("Error", type);
						}
						paramsMap.put(param.getParamName(), date);
					} else {
						String msg = "Unknown data type for parameter: " + param.getParamName();
						logger.error(msg);
						FaultType type = new FaultType();
						type.setText(msg);
						throw new ProcessesException("Error", type);
					}
				}
			}

			HttpServletRequest req = (HttpServletRequest) wsContext.getMessageContext().get(MessageContext.SERVLET_REQUEST);
			String name = req.getServerName();
			Integer port = req.getServerPort();
			if (paramsMap == null) {
				paramsMap = new HashMap<String, Object>();
			}
			paramsMap.put("wsServerName", name);
			paramsMap.put("wsPort", port);
			paramsMap.put("USER_NAME", wsUserName);

			String msg = String.format("Launching process-ws container %s; user session %s", String.valueOf(container.getId()), userSessionId);
			logger.debug(msg);
			loggerDB.debug(new TraceLogInfo(userSessionId, container.getContainerBindId(), msg));
			ContainerLauncher containerLauncher = new ContainerLauncher();
			containerLauncher.setContainer(container);
			containerLauncher.setProcessDao(processDao);
			containerLauncher.setParameters(paramsMap);
			containerLauncher.setUserSessionId(userSessionId);
			if (request.getEffectiveDate() != null) {
				containerLauncher.setEffectiveDate(request.getEffectiveDate().toGregorianCalendar().getTime());
			}
			RunProcessResponseType resp = new RunProcessResponseType();
			try {
				containerLauncher.launch();
				if (container.isSuccessfullyCompleted()) {
					resp.setResponseCode(ProcessConstants.PROCESS_FINISHED);
				} else if (container.isCompletedWithErrors()) {
					resp.setResponseCode(ProcessConstants.PROCESS_FINISHED_WITH_ERRORS);
				} else if (container.isRunning()) {
					resp.setResponseCode(ProcessConstants.PROCESS_IN_PROGRESS);
				} else {
					resp.setResponseCode(ProcessConstants.PROCESS_FAILED);
				}
			} catch (UserException e) {
				logger.error(e.getMessage(), e);
				loggerDB.error(new TraceLogInfo(userSessionId, container.getContainerBindId(), e.getMessage()), e);
				FaultType type = new FaultType();
				String message = e.getMessage();
				if (message != null && message.startsWith("ORA-")) {
					message = message.replaceFirst("ORA-\\d+: ", "");
					message = message.split("ORA-\\d+:")[0];
				}
				type.setText(message);
				throw new ProcessesException("Error", type);
			} catch (Throwable e) {
				logger.error(e.getMessage(), e);
				loggerDB.error(new TraceLogInfo(userSessionId, container.getContainerBindId(), e.getMessage()), e);
				FaultType type = new FaultType();
				type.setText("Unexpected error has occured");
				throw new ProcessesException("Error", type);
			}

			msg = "Execution complete; result: " + resp.getResponseCode();
			logger.debug(msg);
			loggerDB.debug(new TraceLogInfo(userSessionId, container.getContainerBindId(), msg));
			return resp;
		} finally {
			UserContextHolder.setUserName(null);
		}
	}

	private HashMap<String, String> getContainerParamsDataTypes(Long userSessionId,
	                                                            Integer containerId, ProcessDao processDao) throws ProcessesException {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", SystemConstants.ENGLISH_LANGUAGE);
		filters[1] = new Filter("processId", containerId);

		SelectionParams params = new SelectionParams(filters);
		try {
			ProcessParameter[] containerParams = processDao.getContainerParams(userSessionId, params);
			HashMap<String, String> paramDataTypes = new HashMap<String, String>(
					containerParams.length);
			for (ProcessParameter param : containerParams) {
				paramDataTypes.put(param.getSystemName(), param.getDataType());
			}
			return paramDataTypes;
		} catch (Exception e) {
			logger.error("", e);
			FaultType type = new FaultType();
			type.setText(e.getMessage());
			throw new ProcessesException("Error", type);
		}
	}

	private Date parseDate(String dateString) {
		SimpleDateFormat sdf = new SimpleDateFormat();
		String[] dateFormats = {DatePatterns.ISO_DATE_PATTERN, DatePatterns.DATE_PATTERN};
		Date date = null;

		for (String dateFormat : dateFormats) {
			sdf.applyPattern(dateFormat);

			try {
				// TODO: add other date patterns including time and time zones
				date = sdf.parse(dateString);
				break;
			} catch (ParseException ignored) {
			}
		}
		return date;
	}
}

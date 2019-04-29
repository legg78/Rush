package ru.bpc.sv2.scheduler.process;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessBO.ProcessState;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.ProcessFileInfo;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.scheduler.IncomingFilesGenerator;
import ru.bpc.sv2.scheduler.OutgoingFilesGenerator;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.process.monitoring.OracleTraceLevelActivator;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ExternalProcessExecutor implements ProcessExecutor {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	private ProcessExecutorAdapter listener;
	private ProcessBO process;
	private ProcessBO viewProcess;
	private String className;
	private Map<String, Object> parameters;
	private Long containerSessionId;
	private ProcessSession processSession;
	private ProcessDao processDao;
	private Long userSessionId;
	private Date effectiveDate;
	private boolean running;
	private int threadsNumber = 1;
	private String userName;

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer threadNumber;

	private void prepareParameters() {
		Map<String, Object> parameters1 = processDao.getProcessParamsMap(userSessionId, process
				.getId(), process.getContainerBindId());
		if (parameters == null) {
			parameters = new HashMap<String, Object>();
		}
		for (String key : parameters1.keySet()) {

			Object param = parameters.get(key);
			if (param == null) {
				parameters.put(key, parameters1.get(key));
			}
		}
		processDao.addProcessHistoryParams(userSessionId, processSession.getSessionId(), process.getId(), process.getContainerBindId(), parameters);
	}

	@Override
	public void execute() throws SystemException, UserException {
		if (className == null) {
			throw new SystemException("ClassName property must be defined");
		}

		Class processClass;
		try {
			processClass = Class.forName(className);
		} catch (ClassNotFoundException e) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "wrong_class_name", className);
			throw new UserException(msg, e);
		}

		ExternalProcess process;
		try {
			process = (ExternalProcess) processClass.newInstance();
		} catch (Exception e) {
			throw new SystemException(e.getMessage(), e);
		}

		processSession = new ProcessSession();
		processSession.setSessionId(null);
		processSession.setUpSessionId(containerSessionId);

		List<ProcessFileInfo> files = processDao
				.getProcessFilesInfo(userSessionId, this.process.getId(), this.process.getContainerId());
		if (files != null && !files.isEmpty()) {
			ProcessFileInfo file = files.get(0);
			processSession.setPurpose(file.getFilePurpose());
			processSession.setFileName(file.getFileNameMask());
			processSession.setFileEncoding(file.getCharacterset());
			processSession.setFileType(file.getFileType());
			processSession.setLocation(file.getDirectoryPath());
		}

		preProcess();
		OracleTraceLevelActivator.enable(processDao, userSessionId,
										 processSession.getSessionId(),
										 traceLevel, traceLimit, threadNumber);

		prepareParameters();
		process.setProcess(this.process);
		process.setProcessSession(processSession);
		process.setEffectiveDate(effectiveDate);
		process.setParameters(parameters);
		process.setUserSessionId(userSessionId);
		process.setThreadsNumber(threadsNumber);
		process.setUserName(userName);
		fireProcessRunned();
		running = true;

		try {
			ProcessFileAttribute[] fileAttrs = getFileInAttributes(processSession);
			try {
				IncomingFilesGenerator filesGenerator;
				for (ProcessFileAttribute attr : fileAttrs) {
					filesGenerator = new IncomingFilesGenerator(attr, processSession, this.process,
																processDao, userSessionId, userName,
																traceLevel, traceLimit, threadNumber);
					filesGenerator.generate(parameters);
				}
			} catch (Exception e) {
				String msg = "Error when creating incoming files: " + e.getMessage();
				logger.error(msg, e);
				loggerDB.error(new TraceLogInfo(processSession.getSessionId(), this.process.getContainerBindId(), msg), e);
				throw new UserException(msg, e);
			}

			process.execute();

			ProcessFileAttribute[] outFileAttrs = getFileOutAttributes(processSession);
			logger.trace("Files to generate: " + outFileAttrs.length);
			if (outFileAttrs.length > 0) {
			try {
				OutgoingFilesGenerator outfilesGenerator = new OutgoingFilesGenerator(processDao, outFileAttrs,
																					  userSessionId, userName,
																					  this.process.getContainerBindId(),
																					  traceLevel, traceLimit,
																					  threadNumber);
				outfilesGenerator.setLoggerDb(loggerDB);
					outfilesGenerator.setSessionId(processSession.getSessionId());
				outfilesGenerator.generate();
				} catch (Exception e) {
				String message =
						FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "file_generation_error", e.getMessage());
				TraceLogInfo ti = new TraceLogInfo(processSession.getSessionId(), this.process.getContainerBindId(), message);
				logger.error(message, e);
				loggerDB.error(ti);
				throw new UserException(message, e);
			}
			}
		} catch (SystemException e) {
			logger.error("", e);
			loggerDB.error(new TraceLogInfo(processSession.getSessionId(), this.process.getContainerBindId(), ""), e);
			postProcess(processSession.getSessionId(), ProcessConstants.PROCESS_FAILED,
						ExternalProcessExecutor.this.process.getContainerBindId());
			fireProcessFailed();
			throw e;
		} catch (UserException e) {
			logger.error("", e);
			loggerDB.error(new TraceLogInfo(processSession.getSessionId(), this.process.getContainerBindId(), ""), e);
			postProcess(processSession.getSessionId(), ProcessConstants.PROCESS_FAILED,
					ExternalProcessExecutor.this.process.getContainerBindId());
			fireProcessFailed();
			throw e;
		}

		postProcess(processSession.getSessionId(), processSession.getResultCode(),
				ExternalProcessExecutor.this.process.getContainerBindId());
		if (ProcessConstants.PROCESS_FAILED.equals(processSession.getResultCode())) {
			fireProcessFailed();
		} else {
			fireProcessFinished();
		}
	}

	public ProcessExecutorAdapter getListener() {
		return listener;
	}

	public void setListener(ProcessExecutorAdapter listener) {
		this.listener = listener;
	}

	public ProcessBO getExecProcess() {
		return process;
	}

	public void setExecProcess(ProcessBO process) {
		this.process = process;
	}

	public String getClassName() {
		return className;
	}

	public void setClassName(String className) {
		this.className = className;
	}

	@Override
	public void setViewProcess(ProcessBO viewProcess) {
		this.viewProcess = viewProcess;
	}

	@Override
	public ProcessBO getViewProcess() {
		return viewProcess;
	}

	@Override
	public void updateProgress() throws SystemException {
		// TODO Auto-generated method stub

	}

	@Override
	public ProcessBO getProcess() {
		return process;
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;
	}

	private void fireProcessRunned() {
		process.setState(ProcessState.RUNNING);
		process.getProcessStatSummary().setSessionId(processSession.getSessionId());
		if (viewProcess != null) {
			viewProcess.setState(ProcessState.RUNNING);
			viewProcess.getProcessStatSummary().setSessionId(processSession.getSessionId());
		}
		if (listener != null) {
			listener.processRunned(this);
		}
	}

	private void fireProcessFinished() {
		process.setState(ProcessState.SUCCESSFULLY_COMPLETED);
		if (viewProcess != null) {
			viewProcess.setState(ProcessState.SUCCESSFULLY_COMPLETED);
		}
		if (listener != null) {
			listener.processFinished(this);
		}
	}

	private void fireProcessFailed() {
		if (viewProcess != null) {
			viewProcess.setState(ProcessState.NOT_SUCCESSFULLY_COMPLETED);
		}
		process.setState(ProcessState.NOT_SUCCESSFULLY_COMPLETED);
		if (listener != null) {
			listener.processFailed(this);
		}
	}

	public Long getContainerSessionId() {
		return containerSessionId;
	}

	public void setContainerSessionId(Long containerSessionId) {
		this.containerSessionId = containerSessionId;
	}

	private void preProcess() throws SystemException {
		try {
			processDao.preprocess(userSessionId, process, 0, processSession, null, effectiveDate, userName);
		} catch (DataAccessException e) {
			logger.error("", e);
			postProcess(processSession.getSessionId() != null ? processSession.getSessionId() : null,
						ProcessConstants.PROCESS_FAILED,
						process.getContainerBindId());
			getListener().preProcessFailed(this);
			throw new SystemException(e.getMessage(), e);
		}
	}

	private void postProcess(Long sessionId, String result, Integer containerId) throws SystemException {
		try {
			if (running) {
				running = false;
			}
			processDao.postProcess(userSessionId, sessionId, result, userName, containerId);
		} catch (DataAccessException e) {
			logger.error("", e);
			throw new SystemException(e.getMessage(), e);
		}
	}

	public ProcessDao getProcessDao() {
		return processDao;
	}

	public void setProcessDao(ProcessDao processDao) {
		this.processDao = processDao;
	}

	public Long getUserSessionId() {
		return userSessionId;
	}

	public void setUserSessionId(Long userSessionId) {
		this.userSessionId = userSessionId;
	}

	public Date getEffectiveDate() {
		return effectiveDate;
	}

	public void setEffectiveDate(Date effectiveDate) {
		this.effectiveDate = effectiveDate;
	}

	public int getThreadsNumber() {
		return threadsNumber;
	}

	public void setThreadsNumber(int threadsNumber) {
		this.threadsNumber = threadsNumber;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public void setTraceLimit(Integer traceLimit) {
		this.traceLimit = traceLimit;
	}
	public Integer getTraceLimit() {
		return traceLimit;
	}

	public void setThreadNumber(Integer threadNumber) {
		this.threadNumber = threadNumber;
	}
	public Integer getThreadNumber() {
		return threadNumber;
	}

	public void setTraceLevel(Integer traceLevel) {
		this.traceLevel = traceLevel;
	}
	public Integer getTraceLevel() {
		return traceLevel;
	}

	private ProcessFileAttribute[] getFileInAttributes(
			ProcessSession processSession) throws SystemException {
		ProcessFileAttribute[] result;
		try {
			result = processDao.getIncomingFilesForProcess(userSessionId,
					processSession.getSessionId(),
					process.getContainerBindId());
		} catch (DataAccessException e) {
			logger.error("", e);
			throw new SystemException(e.getMessage(), e);
		}
		return result;
	}

	private ProcessFileAttribute[] getFileOutAttributes(
			ProcessSession processSession) throws SystemException {
		Map<String, Object> params = new HashMap<String, Object>(3);
		params.put("lang", SystemConstants.ENGLISH_LANGUAGE);
		params.put("sessionId", processSession.getSessionId());

		ProcessFileAttribute[] result;
		try {
			result = processDao.getOutgoingProcessFiles(userSessionId, params);
		} catch (DataAccessException e) {
			logger.error("", e);
			throw new SystemException(e.getMessage(), e);
		}
		return result;
	}
}

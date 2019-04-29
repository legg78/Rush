package ru.bpc.sv2.scheduler.process;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessBO.ProcessState;
import ru.bpc.sv2.process.ProcessParameter;
import ru.bpc.sv2.process.ProcessStatSummary;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.TreeUtils;
import ru.bpc.sv2.utils.UserException;

import javax.sql.DataSource;
import java.math.BigDecimal;
import java.util.*;

public class ContainerLauncher {
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");
	private ProcessBO container;
	private ProcessBO viewContainer;
	private int threadsNumber;
	private Map<String, Object> parameters;
	private ProcessDao processDao;
	private Date effectiveDate;
	private Long containerSessionId;
	private Long userSessionId;
	private Long parentSessionId;
	private ProcessParameter[] masParameters;
	private ProcessExecutorAdapter listener;
	private DataSource ds;
	private boolean running = false;
	private List<ContainerLauncher> containers = new ArrayList<ContainerLauncher>();
	private List<ProcessExecutor> executors = new ArrayList<ProcessExecutor>();

	private Integer traceLevel;
	private Integer traceLimit;
	private Integer threadNumber;

	private List<KeyLabelItem> processesToRollback;
	private EventsDao eventsDao;

	private String userName;

	private void fireBeforeLaunching() {
		if (listener != null) {
			listener.beforeContainerLaunching(this);
		}
	}

	private void fireContainerFinished() {
		if (listener != null) {
			listener.containerFinished(this);
		}
	}

	private void fireContainerFailed() {
		if (listener != null) {
			listener.containerFailed(this);
		}
	}

	private void fireContainerLaunched() {
		if (listener != null) {
			listener.containerLaunched(this);
		}
	}

	public void launch() throws SystemException, UserException {
		try {
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			BigDecimal threadsNumberParam = settingParamsCache.getParameterNumberValue(SettingsConstants.PARALLEL_DEGREE);
			threadsNumber = threadsNumberParam.intValue();
		} catch (Exception e1) {
			threadsNumber = 1;
			logger.error("", e1);
		}

		// DataSource obtaining
		ds = JndiUtils.getDataSource();

		// Connection establishment and launching
		try {
			fireBeforeLaunching();
			launchContainer();
			fireContainerFinished();
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			try {
				failContainer();
			} catch (Exception failException) {
				logger.error("Exception on failContainer invocation: " + failException.getMessage(), failException);
			}
			if (e instanceof UserException)
				throw (UserException) e;
			else
				throw e instanceof SystemException ? (SystemException) e : new SystemException(e.getMessage(), e);
		}
	}

	private void failContainer() throws SystemException {
		SystemException exception = null;
		if (running) {
			try {
				stopContainer(ProcessConstants.PROCESS_FAILED);
			} catch (SystemException e) {
				exception = e;
			}
		}
		try {
			fireContainerFailed();
		} catch (Exception e) {
			logger.error("Exception on fireContainerFailed invocation:" + e.getMessage(), e);
		}
		if (exception != null) {
			throw exception;
		}
	}

	private void runContainer() throws SystemException, UserException {
		try {
			containerSessionId = processDao.runContainer(getUserSessionId(), getContainer(),
														   getParentSessionId(), getEffectiveDate(),
														   getUserName());
			running = true;
		} catch (DataAccessException e) {
			throw new SystemException(e.getMessage(), e);
		}
	}

	private List<ProcessBO> getContainerHierarchy() throws SystemException {
		logger.debug(String.format(
				"Get hierarchy of containers. User session id: %d; Container id: %d",
				getUserSessionId(), getContainer().getId()));
		return processDao.getContainerHierarchy(getUserSessionId(), getContainer().getId());
	}

	private void stopContainer(String status) throws SystemException {
		try {
			if (ProcessConstants.PROCESS_FINISHED.equals(status)) {
				container.setState(ProcessState.SUCCESSFULLY_COMPLETED);
			} else if (ProcessConstants.PROCESS_FINISHED_WITH_ERRORS.equals(status)) {
				container.setState(ProcessState.COMPLETED_WITH_ERRORS);
			} else if (ProcessConstants.PROCESS_IN_PROGRESS.equals(status)) {
				container.setState(ProcessState.RUNNING);
			} else {
				container.setState(ProcessState.NOT_SUCCESSFULLY_COMPLETED);
			}
			processDao.postProcess(userSessionId, containerSessionId, status, userName, container.getContainerBindId());
		} finally {
			running = false;
		}
	}

	private void launchContainer() throws SystemException, UserException {
		runContainer();
		List<ProcessBO> containerFloatTree = getContainerHierarchy();
		List<ProcessBO> containerTree;
		containerTree = TreeUtils.fillTree(containerFloatTree);

		fireContainerLaunched();

		boolean finishWithError = false;
		boolean fatalError = false;

		for (int i = 0; i < containerTree.size(); i++) {
			ProcessBO process = containerTree.get(i);
			ProcessBO viewProcess = null;
			prepareParametersByProc(process.getId(), process.getHierExecutionOrder());
			int parallel_degree = (process.getParallelDegree() != null) ? process.getParallelDegree() : threadsNumber;
			if (viewContainer != null) {
				viewProcess = viewContainer.getChildren().get(i);
			}

			processDao.auditContainerRun(userSessionId, process);

			if (process.hasChildren()) {
				ProcessParameter[] childContainerMasParams = prepareParametersByCont(process.getId(), process.getHierExecutionOrder());
				ContainerLauncher cl = new ContainerLauncher();
				cl.setContainer(process);
				cl.setEffectiveDate(effectiveDate);
				cl.setMasParameters(childContainerMasParams);
				cl.setParentSessionId(containerSessionId);
				cl.setProcessDao(processDao);
				cl.setThreadsNumber(parallel_degree);
				cl.setUserSessionId(userSessionId);
				cl.setViewContainer(viewProcess);
				cl.setListener(listener);
				cl.setUserName(userName);
				cl.setThreadNumber(threadNumber);
				cl.setTraceLevel(traceLevel);
				cl.setTraceLimit(traceLimit);
				containers.add(cl);
				cl.launch();
				if (cl.getContainer().isNotSuccessfullyCompleted()) {
					fatalError = true;
					if (process.isStopOnFatal() || getContainer().isStopOnFatal()) {
						break;
					}
				}
				continue;
			}

			ProcessExecutor executor;

			if (!process.isExternal()) {
				InternalProcessExecutor bpe = new InternalProcessExecutor();
				bpe.setExecProcess(process);
				bpe.setViewProcess(viewProcess);
				bpe.setContainerSessionId(containerSessionId);
				bpe.setDataSource(ds);
				bpe.setEffectiveDate(effectiveDate);
				bpe.setListener(listener);
				bpe.setParameters(parameters);
				bpe.setProcessDao(processDao);
				bpe.setThreadsNumber(process.isParallel() ? parallel_degree : 1);
				bpe.setUserSessionId(userSessionId);
				if(parameters != null && parameters.get("USER_NAME") != null && !((String)parameters.get("USER_NAME")).trim().equals(""))
					bpe.setUserName((String) parameters.get("USER_NAME"));
				else
					bpe.setUserName(userName);
				bpe.setThreadNumber(threadNumber);
				bpe.setTraceLevel((traceLevel == null) ? process.getTraceLevel() : traceLevel);
				bpe.setTraceLimit((traceLimit == null) ? process.getTraceLimit() : traceLimit);
				executor = bpe;
			} else {
				Object obj;
				try {
					obj = Class.forName(process.getProcedureName()).newInstance();
				} catch (Exception e) {
					throw new SystemException(e.getMessage(), e);
				}
				if(obj instanceof AsyncProcessHandler) {
					int userId;
					final UsersDao usersDao = new UsersDao();
					final User u = usersDao.getCurrentUserInfo(userSessionId, SelectionParams.build("IS_EXIST", true));
					userId = u.getId();

					final AsyncProcessExecutor epe = new AsyncProcessExecutor();
					epe.setListener(listener);
					epe.setExecProcess(process);
					epe.setHandler((AsyncProcessHandler)obj);
					epe.setViewProcess(viewProcess);
					epe.setContainerSessionId(containerSessionId);
					epe.setProcessDao(processDao);
					epe.setEffectiveDate(effectiveDate);
					epe.setUserSessionId(userSessionId);
					epe.setParameters(parameters);
					epe.setUserName(userName);
					epe.setUserId(userId);
					epe.setThreadsNumber(process.isParallel() ? parallel_degree : 1);
					executor = epe;
				} else {
					ExternalProcessExecutor epe = new ExternalProcessExecutor();
					epe.setListener(listener);
					epe.setExecProcess(process);
					epe.setClassName(process.getProcedureName());
					epe.setViewProcess(viewProcess);
					epe.setContainerSessionId(containerSessionId);
					epe.setProcessDao(processDao);
					epe.setEffectiveDate(effectiveDate);
					epe.setUserSessionId(userSessionId);
					epe.setParameters(parameters);
					epe.setUserName(userName);
					epe.setThreadsNumber(parallel_degree);
					epe.setThreadNumber(threadNumber);
					epe.setTraceLevel((traceLevel == null) ? process.getTraceLevel() : traceLevel);
					epe.setTraceLimit((traceLimit == null) ? process.getTraceLimit() : traceLimit);
					executor = epe;
				}
			}
			executors.add(executor);
			try {
				executor.execute();
				if (viewProcess != null) {
					Long sessionId = viewProcess.getProcessStatSummary().getSessionId();
					ProcessStatSummary processStatSummary = processDao.getStatSummaryBySessionId(userSessionId, sessionId);
					viewProcess.setProcessStatSummary(processStatSummary);
				}
				if (process.getState().equals(ProcessState.COMPLETED_WITH_ERRORS) || process.getState().equals(ProcessState.NOT_SUCCESSFULLY_COMPLETED)) {
					finishWithError = true;
					rollbackEvent(process.getId(), process.getProcessStatSummary().getSessionId());
				}
			} catch (UserException e) {
				logger.error(e.getMessage(), e);
				finishWithError = true;
				rollbackEvent(process.getId(), process.getProcessStatSummary().getSessionId());
				fatalError = true;
				if (process.isStopOnFatal() || getContainer().isStopOnFatal()) {
					break;
				}
			} catch (Throwable e){
				logger.error(e.getMessage(), e);
				finishWithError = true;
				rollbackEvent(process.getId(), process.getProcessStatSummary().getSessionId());
				if (e.getMessage() == null) {
					throw new SystemException(e);
				}
				String err = e.getMessage() != null ? e.getMessage() : "";
				throw new SystemException((!err.contains("\n")) ? err : err.substring(0, err.indexOf("\n")), e);
			}
		}

		try {
			stopContainer((fatalError) ? ProcessConstants.PROCESS_FAILED
									   : ((finishWithError) ? ProcessConstants.PROCESS_FINISHED_WITH_ERRORS
															: ProcessConstants.PROCESS_FINISHED));
		} catch (Exception e) {
			if (finishWithError) {
				// If process failed, we do not want to throw exception in order to not to hide initial error
				String msg = "Exception when invoking stopContainer for failed process: " + e.getMessage();
				logger.error(msg, e);
				loggerDB.error(new TraceLogInfo(containerSessionId, getContainer().getContainerBindId(), msg), e);
			} else {
				throw e instanceof SystemException ? (SystemException) e : new SystemException(e.getMessage(), e);
			}
		}
	}

	private void rollbackEvent(Integer prcId, Long sessionId) {
		try {
			if (processesToRollback == null) {
				CommonDao commonDao = new CommonDao();
				processesToRollback = Arrays.asList(commonDao.getLov(LovConstants.PROCESSES_TO_ROLLBACK));
				eventsDao = new EventsDao();
			}

			if (processesToRollback.contains(new KeyLabelItem(prcId.toString()))) {
				eventsDao.returnStatus(sessionId, userName);
				loggerDB.debug(new TraceLogInfo(sessionId, getContainer().getContainerBindId(), "event rollback was performed"));
			}
		} catch (Exception e) {
			String msg = "Unable to rollback event: " + e.getMessage();
			logger.error(msg, e);
			loggerDB.error(new TraceLogInfo(sessionId, getContainer().getContainerBindId(), msg), e);
		}
	}

	public void updateProgress() throws SystemException {
		for (ContainerLauncher container : new ArrayList<ContainerLauncher>(containers)) {
			// Iterate over copy of containers to avoid concurrent modification
			container.updateProgress();
		}

		for (ProcessExecutor executor : executors) {
			ProcessBO p = executor.getProcess();
			ProcessBO vp = executor.getViewProcess();
			ProcessState pState = p.getState();
			if (ProcessState.RUNNING.equals(pState)) {
				executor.updateProgress();
			} else if (ProcessState.SUCCESSFULLY_COMPLETED.equals(pState) && (p.getProgress() != 100)) {
				p.setProgress(100);
				vp.setProgress(100);
			}
		}
	}

	public ProcessBO getContainer() {
		return container;
	}

	public void setContainer(ProcessBO container) {
		this.container = container;
	}

	public ProcessBO getViewContainer() {
		return viewContainer;
	}

	public void setViewContainer(ProcessBO viewContainer) {
		this.viewContainer = viewContainer;
	}

	public void setThreadsNumber(int threadsNumber) {
		this.threadsNumber = threadsNumber;
	}

	public Map<String, Object> getParameters() {
		return parameters;
	}

	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;
	}

	public void setProcessDao(ProcessDao processDao) {
		this.processDao = processDao;
	}

	public Date getEffectiveDate() {
		return effectiveDate;
	}

	public void setEffectiveDate(Date effectiveDate) {
		this.effectiveDate = effectiveDate;
	}

	public Long getContainerSessionId() {
		return containerSessionId;
	}

	public Long getUserSessionId() {
		return userSessionId;
	}

	public void setUserSessionId(Long userSessionId) {
		this.userSessionId = userSessionId;
	}

	public Long getParentSessionId() {
		return parentSessionId;
	}

	public void setParentSessionId(Long parentSessionId) {
		this.parentSessionId = parentSessionId;
	}

	public ProcessExecutorAdapter getListener() {
		return listener;
	}

	public void setListener(ProcessExecutorAdapter listener) {
		this.listener = listener;
	}

	public boolean isRunning() {
		return running;
	}

	public List<ProcessExecutor> getExecutors() {
		return executors;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public void setMasParameters(ProcessParameter[] masParameters) {
		this.masParameters = masParameters;
	}

	public void setTraceLimit(Integer traceLimit) {
		this.traceLimit = traceLimit;
	}
	@SuppressWarnings("unused")
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

	private void prepareParametersByProc(Integer processId, String execOrder) {
		if (masParameters != null) {
			parameters = new HashMap<String, Object>();
			for (ProcessParameter param : masParameters) {
				if (processId.equals(param.getProcId()) && execOrder.equals(param.getExecOrder()))
					parameters.put(param.getSystemName(), param.getValue());
			}
		}
	}

	private ProcessParameter[] prepareParametersByCont(Integer processId, String execOrder) {
		if (masParameters != null) {
			List<ProcessParameter> childParams = new ArrayList<>();
			for (ProcessParameter param : masParameters) {
				if (param.getExecOrder() == null || !param.getExecOrder().contains("."))
					continue;
				String[] execOrders = param.getExecOrder().split("\\.", 2);
				String parentExecOrder = execOrders[0];
				String childExecOrder = execOrders[1];
				if (execOrder.equals(parentExecOrder)) {
					try {
						ProcessParameter tmp;
						tmp = param.clone();
						tmp.setExecOrder(childExecOrder);
						childParams.add(tmp);
					} catch (CloneNotSupportedException e) {
						logger.error("", e);
					}
				}
			}
			return childParams.toArray(new ProcessParameter[childParams.size()]);
		}
		return null;
	}
}

package ru.bpc.sv2.scheduler.process;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.process.*;
import ru.bpc.sv2.process.ProcessBO.ProcessState;
import ru.bpc.sv2.scheduler.IncomingFilesGenerator;
import ru.bpc.sv2.scheduler.OutgoingFilesGenerator;
import ru.bpc.sv2.scheduler.process.mergeable.PostFileSaver;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.process.monitoring.OracleTraceLevelActivator;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.*;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.sql.DataSource;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;
import java.util.concurrent.*;

@SuppressWarnings("WeakerAccess")
public class InternalProcessExecutor implements ProcessExecutor {

	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	private ProcessBO process;

	private int threadsNumber = 1;
	private Long containerSessionId;
	private DataSource dataSource;
	private ProcessDao processDao;
	private Long userSessionId;
	private Date effectiveDate;
	private Map<String, Object> parameters;
	private ProcessExecutorAdapter listener;
	private ProcessBO viewProcess;
	private ProcessSession processSession;
	private boolean running;
	private String userName;
	private String faultCode;
	private List<Integer> threadsCancel;

	private Integer traceLevel = null;
	private Integer traceLimit = null;
	private Integer threadNumber = null;

	private class ExecutionBody implements Callable<Object> {
		private Long sessionId;
		private int threadNum;
		private int containerId;
		private Map<String, Object> params;
		private Date processDate;
		private Connection connection;
		private Integer traceLevel;
		private Integer threadNumber;

		ExecutionBody(int threadNum, Long sessionId,
		              Integer containerId, Map<String, Object> params,
		              Date processDate, Connection connection,
		              Integer traceLevel, Integer threadNumber) {
			this.sessionId = sessionId;
			this.containerId = containerId;
			this.threadNum = threadNum;
			this.params = params;
			this.processDate = processDate;
			this.connection = connection;
			this.traceLevel = traceLevel;
			this.threadNumber = threadNumber;
		}

		@Override
		public Object call() {
			try {
				logger.info("Starting process. Thread " + threadNum);
				Map<String, Object> localParams = params;
				if (params != null && params.get("I_COUNT") != null && threadNum > 0) {
					localParams = new HashMap<>(params);
					BigDecimal totalCount = (BigDecimal) params.get("I_COUNT");
					long totalCountLong = totalCount.longValue();
					if (threadNum == threadsNumber)
						localParams.put("I_COUNT", new BigDecimal(totalCountLong - (totalCountLong / threadsNumber) * (threadsNumber - 1)));
					else
						localParams.put("I_COUNT", new BigDecimal(totalCountLong / threadsNumber));
				}
				processDao.runProcess(userSessionId, threadNum, sessionId,
						containerId, localParams, processDate,
						connection, traceLevel, threadNumber);
				logger.info("Process stopped. Thread " + threadNum);
				return "OK";
			} catch (Exception e) {
				logger.error("Error running process. Thread " + threadNum + ", Error: " + e.getMessage());
				return e;
			} finally {
				// After process is done, its connection must be closed to commit changes
				DBUtils.close(connection);
			}
		}
	}

	private void executePostSaver() throws Exception {
		try (Connection connect = dataSource.getConnection()) {
			ProcessFileAttribute[] files = getFileOutAttributes(processSession, connect);
			if (files != null && files.length > 0) {
				logger.info("Start post-processing for session " + processSession.getSessionId());
				if (FileSaver.MERGE_FILES_OF_PROCESS.equals(files[0].getMergeFileMode())) {
					if (StringUtils.isNotBlank(files[0].getPostSaverClass())) {
						OutgoingFilesGenerator.initializeSession(connect, processSession.getSessionId(),
																 process.getContainerBindId());
						PostFileSaver saver = (PostFileSaver) OutgoingFilesGenerator.createObject(files[0].getPostSaverClass());
						saver.setUserSessionId(userSessionId);
						saver.setProcess(process);
						saver.setTraceLevel(traceLevel);
						saver.setTraceLimit(traceLimit);
						saver.setConnection(connect);
						saver.setFileAttributes(files[0]);
						saver.setSessionId(processSession.getSessionId());
						saver.setUserName(userName);
						saver.save();
					}
				}
				logger.info("Post-processing is finished for session " + processSession.getSessionId());
			}
		}
	}

	public void execute() throws SystemException, UserException {
		try {
			running = true;
			faultCode = ProcessConstants.PROCESS_FINISHED_WITH_ERRORS;
			threadsCancel = new ArrayList<>();
			executeByConnections();
			executePostSaver();
		} catch (Throwable e) {
			try {
				if (processSession != null && processSession.getSessionId() != null) {
					postProcess(processSession.getSessionId(), faultCode, process.getContainerBindId());
					checkFile(processSession);
					for (Integer thread : threadsCancel) {
						changeThreadStatus(processSession.getSessionId(),
								ProcessConstants.PROCESS_THREAD_INTERRUPT, thread);
					}
				}
			} catch (Exception ex) {
				String message = "Exception when invoking postProcess for failed process: " + ex.getMessage();
				logger.error(message, ex);
				loggerDB.error(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), message), ex);
			}

			try {
				fireProcessFailed();
			} catch (Exception ignored) {
			}
			if (e instanceof UserException) {
				throw (UserException) e;
			}
			if (e instanceof SystemException) {
				throw (SystemException) e;
			}

			throw new SystemException(e.getMessage(), e);
		}
	}

	private void checkFile(ProcessSession process) {
		ProcessFileAttribute[] attr = getProcessFileAttr(
				getExecProcess().getContainerId().longValue(),
				getExecProcess().getId());
		if (attr.length > 0) {
			if (attr[0].getIsCleanupData()) {
				processDao.removeFileConfiguration(userSessionId, process.getSessionId());
			} else {
				processDao.setStatusToSessionFiles(userSessionId, Arrays.asList(getSessionFiles(process)), "PSFS0003");
			}
		}
	}

	private SessionFile[] getSessionFiles(ProcessSession process) {
		SelectionParams params = new SelectionParams(0, Integer.MAX_VALUE,
				new Filter("sessionId", process.getSessionId()));
		return processDao.getSessionFiles(userSessionId, params, false);
	}

	private ProcessFileAttribute[] getProcessFileAttr(Long containerId, Integer processId) {
		SelectionParams params = new SelectionParams(0, Integer.MAX_VALUE,
				new Filter("containerId", containerId),
				new Filter("processId", processId),
				new Filter("lang", SystemConstants.ENGLISH_LANGUAGE));
		return processDao.getFileAttributes(userSessionId, params, false);
	}

	private void fireProcessRunned() {
		process.setState(ProcessState.RUNNING);
		updateProcessesSession();
		if (viewProcess != null) {
			viewProcess.setState(ProcessState.RUNNING);
		}
		if (listener != null) {
			listener.processRunned(this);
		}
	}

	private void updateProcessesSession() {
		process.getProcessStatSummary().setSessionId(processSession.getSessionId());
		if (viewProcess != null) {
			viewProcess.getProcessStatSummary().setSessionId(processSession.getSessionId());
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

	private void fireProcessFinishedWithErrors() {
		process.setState(ProcessState.COMPLETED_WITH_ERRORS);
		if (viewProcess != null) {
			viewProcess.setState(ProcessState.COMPLETED_WITH_ERRORS);
		}
		if (listener != null) {
			listener.processFinished(this);
		}
	}

	private void prepareParameters() {
		Map<String, Object> parameters1 = processDao.getProcessParamsMap(
				userSessionId, process.getId(), process.getContainerBindId());
		if (parameters == null) {
			parameters = new HashMap<>();
		}
		for (String key : parameters1.keySet()) {
			if (parameters.get(key) == null) {
				parameters.put(key, parameters1.get(key));
			}
		}
		parameters.put("USER_NAME", userName);
	}

	private void executeByConnections() throws Throwable {
		// threadsConnections are to be used _only_ for preparing/running processes
		// for other means mainConnection should be used
		// threadsConnections[i] must be closed after each i-th process ends
		Connection[] threadsConnections = new Connection[threadsNumber];
		try {
			// Prepare connections
			for (int i = 0; i < threadsNumber; i++) {
				threadsConnections[i] = dataSource.getConnection();
			}

			processSession = new ProcessSession();
			processSession.setSessionId(null);
			processSession.setUpSessionId(containerSessionId);
			prepareParameters();

			logger.info(String.format("Current starting process id=%d; parallel=%s; upSessionId=%s",
					process.getId(), String.valueOf(process.isParallel()), containerSessionId));

			long curTime = System.currentTimeMillis();

			// Preprocess
			ExecutionBody[] execBodies = new ExecutionBody[threadsNumber];
			for (int i = 0; i < threadsNumber; i++) {
				logger.info("Connection opened for process " + process.getId().toString());
				preprocess(processSession, threadsConnections[i], i + 1, userName);
				int threadNumber = threadsNumber == 1 ? -1 : i + 1;
				execBodies[i] = new ExecutionBody(threadNumber,
						processSession.getSessionId(),
						process.getContainerBindId(), parameters,
						effectiveDate,
						threadsConnections[i],
						process.getTraceLevel(), process.getThreadNumber());
				logger.info("thread = " + (threadNumber) +
						"; sessionId = " + processSession.getSessionId() +
						"; upSessionId = " + processSession.getUpSessionId());
			}

			fireProcessRunned();

			// File loading
			ProcessFileAttribute[] fileAttrs = getFileInAttributes(processSession);
			logger.info("Input files: " + fileAttrs.length);
			try {
				IncomingFilesGenerator filesGenerator;
				for (ProcessFileAttribute attr : fileAttrs) {
					try {
						filesGenerator = new IncomingFilesGenerator(attr, processSession, process,
																	processDao, userSessionId, userName,
																	traceLevel, traceLimit, threadNumber);
						filesGenerator.generate(parameters);
					} catch (Exception e) {
						generateResponseFiles(attr, e);
						throw e;
					}
				}
			} catch (Exception e) {
				String msg = "Error when creating incoming files. ";
				logger.error(msg + e.getMessage(), e);
				loggerDB.error(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), msg), e);
				throw new UserException(msg + e.getMessage(), e);
			}

			logger.trace("Time taken to setup: " + (System.currentTimeMillis() - curTime));

			// Run parallel process threads
			Future[] futures = new Future[threadsNumber];
			ExecutorService pool = Executors.newCachedThreadPool();
			for (int i = 0; i < threadsNumber; i++) {
				futures[i] = pool.submit(execBodies[i]);
			}

			OutgoingFilesGeneratorRunner generatorRunner = new OutgoingFilesGeneratorRunner();
			Future<Boolean> generatorResult = Executors.newSingleThreadExecutor().submit(generatorRunner);

			try {
				boolean stop = false;
				Exception exception = null;
				for (int i = 0; i < threadsNumber; i++) {
					if (stop && !futures[i].isDone()) {
						futures[i].cancel(true);
						if (futures[i].isCancelled()) {
							threadsCancel.add(i);
							faultCode = ProcessConstants.PROCESS_FAILED;
							logger.debug("Process stopped. Thread " + i);
						}
						continue;
					}
					Object result = futures[i].get();
					if (result instanceof Exception) {
						if (process.isInterruptThreads()) {
							stop = true;
						}
						exception = (Exception) result;
						faultCode = ProcessConstants.PROCESS_FAILED;
					}
				}
				if (exception != null)
					throw exception;
			} catch (Exception e) {
				generatorResult.cancel(true);
				String msg = "Error when invoke procedure. ";
				logger.error(msg + e.getMessage());
				loggerDB.error(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), msg), e);
				try {
					generateResponseFiles(null, e);
				} catch (Exception ignored) {
				}
				throw !(e instanceof UserException) && e.getCause() != null ? e.getCause() : e;
			}

			try {
				generatorRunner.processesDone();
				generatorResult.get();
				logger.info("File generation is finished");
			} catch (Throwable t) {
				while (t instanceof ExecutionException) {
					t = t.getCause();
				}
				Exception e = t instanceof Exception ? (Exception) t : new RuntimeException(t.getMessage(), t);
				String message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "file_generation_error", e.getMessage());
				logger.error(message, e);
				loggerDB.error(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), message), e);
				faultCode = ProcessConstants.PROCESS_FAILED;
				try {
					generateResponseFiles(null, e);
				} catch (Exception ignored) {
				}
				throw new UserException(message, e);
			}

			// launch post process procedure
			if (generatorRunner.outfilesGenerator.getUnprocessed() != null && generatorRunner.outfilesGenerator.getUnprocessed().size() > 0) {
				postProcess(processSession.getSessionId(),
						ProcessConstants.PROCESS_FINISHED_WITH_ERRORS,
						process.getContainerBindId());
				fireProcessFinishedWithErrors();
			} else {
				postProcess(processSession.getSessionId(),
						ProcessConstants.PROCESS_FINISHED,
						process.getContainerBindId());
				fireProcessFinished();
			}
		} finally {
			// Close connections even if some (or all) of them are already closed, in case something happened and
			// some processes were not run
			for (Connection con : threadsConnections) {
				DBUtils.close(con);
			}
		}
	}

	private class OutgoingFilesGeneratorRunner implements Callable<Boolean> {
		static final long CYCLE_DELAY_MS = 1000;
		private OutgoingFilesGenerator outfilesGenerator;
		private Future<Boolean> resultFuture;
		private boolean processesDone;

		@Override
		public Boolean call() throws Exception {
			logger.info("Staring OutgoingFilesGeneratorRunner");
			CloseableBlockingQueue<ProcessFileAttribute> filesQueue = new CloseableArrayBlockingQueue<>(100);
			outfilesGenerator = new OutgoingFilesGenerator(processDao, filesQueue, userSessionId,
														   userName, process.getContainerBindId(),
														   traceLevel, traceLimit, threadNumber);
			outfilesGenerator.setLoggerDb(loggerDB);
			outfilesGenerator.setSessionId(processSession.getSessionId());
			resultFuture = outfilesGenerator.generateAsync(parameters);

			Set<Long> processedFiles = new HashSet<>();

			try {
				while (true) {
					try (Connection con = dataSource.getConnection()) {
						boolean shouldBreak = processesDone;
						ProcessFileAttribute[] files = getFileOutAttributes(processSession, con);
						for (ProcessFileAttribute file : files) {
							if (Thread.currentThread().isInterrupted())
								break;
							if (!processedFiles.contains(file.getId())) {
								if (!resultFuture.isDone() && !filesQueue.isClosed()) {
									logger.info(String.format("Putting file to queue, id=%d; name=%s", file.getId(), file.getName()));
									filesQueue.put(file);
									processedFiles.add(file.getId());
								}
							}
						}
						if (shouldBreak || Thread.currentThread().isInterrupted() || resultFuture.isDone()) {
							if (Thread.currentThread().isInterrupted()) {
								resultFuture.cancel(true);
							}
							break;
						}
					}
					synchronized (this) {
						wait(CYCLE_DELAY_MS);
					}
				}
			} catch (InterruptedException e) {
				resultFuture.cancel(true);
				return false;
			} finally {
				filesQueue.close();
				logger.info("OutgoingFilesGeneratorRunner done");
			}

			return !resultFuture.isCancelled() ? resultFuture.get() : false;
		}

		private void processesDone() throws Exception {
			processesDone = true;
			synchronized (this) {
				notifyAll();
			}
		}
	}

	private void preprocess(ProcessSession processSession,
	                        Connection connection, Integer currentThread,
	                        String userName) throws SystemException {
		try {
			processDao.preprocess(userSessionId, process, currentThread, processSession,
					connection, effectiveDate, userName);
			if (threadNumber == null || threadNumber == -1 || Objects.equals(threadNumber, currentThread)) {
				OracleTraceLevelActivator.enable(processDao, userSessionId,
						processSession.getSessionId(),
						traceLevel, traceLimit, threadNumber);
			}
			if (process.getTraceLevel() == null) {
				process.setTraceLevel(traceLevel);
			}
			if (process.getThreadNumber() == null) {
				process.setThreadNumber(threadNumber);
			}
			if (process.getTraceLimit() == null) {
				process.setTraceLimit(traceLimit);
			}
		} catch (DataAccessException e1) {
			updateProcessesSession();
			logger.error(e1.getMessage(), e1);
			try {
				postProcess(processSession.getSessionId(),
						ProcessConstants.PROCESS_FAILED,
						process.getContainerBindId());
			} catch (DataAccessException e2) {
				logger.error(e2.getMessage(), e2);
				throw new SystemException(e1.getMessage(), e2);
			} finally {
				getListener().preProcessFailed(this);
			}
			throw new SystemException(e1.getMessage(), e1);
		}
	}

	private void postProcess(Long processSessionId, String result, Integer containerId) throws SystemException {
		if (running) {
			running = false;
		}
		processDao.postProcess(userSessionId, processSessionId, result, userName, containerId);
	}

	private void changeThreadStatus(Long sessionId, String result, Integer threadNumber) throws SystemException {
		processDao.changeThreadStatus(userSessionId, sessionId, result, threadNumber, userName);
	}

	private void generateResponseFiles(ProcessFileAttribute attr, Exception ex) throws Exception {
		logger.info("Generating response file (if exists)");
		try (Connection con = dataSource.getConnection()) {
			ProcessFileAttribute[] procFiles = getProcessFileAttr(getExecProcess().getContainerId().longValue(), getExecProcess().getId());
			ProcessFileAttribute responseFile = null;
			for (ProcessFileAttribute procFile : procFiles) {
				if (ProcessConstants.FILE_TYPE_RESPONSE.equals(procFile.getFileType())) {
					responseFile = procFile;
					break;
				}
			}
			if (responseFile == null) {
				logger.debug("No response file is configured");
				loggerDB.debug(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), "No response file is configured"));
				return;
			}
			loggerDB.debug(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), "Generating response file"), ex);
			if (attr != null) {
				try {
					processDao.setContainerId(con, getExecProcess().getContainerBindId().longValue());
					processDao.generateResponseFile(con,
							attr.getFileType(), attr.getFileId().longValue(), attr.getFileName(), getExceptionText(ex));
				} catch (Exception e) {
					logger.error(e.getMessage(), e);
					loggerDB.error(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), "Error executing prc_api_file_pkg.generate_response_file"), e);
					return;
				}
			}

			ProcessFileAttribute[] outFileAttrs = getFileOutAttributes(processSession, con);
			List<ProcessFileAttribute> respFiles = new ArrayList<>();
			for (ProcessFileAttribute outFile : outFileAttrs) {
				if (outFile.getFileId().equals(responseFile.getFileId()))
					respFiles.add(outFile);
			}
			if (!respFiles.isEmpty()) {
				OutgoingFilesGenerator outfilesGenerator = new OutgoingFilesGenerator(processDao,
																					  respFiles.toArray(new ProcessFileAttribute[respFiles.size()]),
																					  userSessionId, userName,
																					  process.getContainerBindId(),
																					  traceLevel, traceLimit,
																					  threadNumber);
				outfilesGenerator.setLoggerDb(loggerDB);
				outfilesGenerator.setSessionId(processSession.getSessionId());
				try {
					outfilesGenerator.generate(parameters);
				} catch (Exception e) {
					String message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "file_generation_error", e.getMessage());
					logger.error(message, e);
					loggerDB.error(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), message), e);
					throw new UserException(message, e);
				}
			} else {
				String msg = "Could not generate response file, output files do not have it";
				logger.debug(msg);
				loggerDB.debug(new TraceLogInfo(processSession.getSessionId(), process.getContainerBindId(), msg));
			}
		}
	}

	private ProcessFileAttribute[] getFileInAttributes(ProcessSession processSession) throws SystemException {
		return processDao.getIncomingFilesForProcess(userSessionId,
				processSession.getSessionId(),
				process.getContainerBindId());
	}

	private ProcessFileAttribute[] getFileOutAttributes(ProcessSession processSession, Connection connection) throws SystemException {
		try {
			Map<String, Object> params = new HashMap<>(2);
			params.put("lang", SystemConstants.ENGLISH_LANGUAGE);
			params.put("sessionId", processSession.getSessionId());

			return processDao.getOutgoingProcessFiles(userSessionId, params);
		} catch (DataAccessException e) {
			logger.error(e.getMessage(), e);
			throw new SystemException(e.getMessage(), e);
		}
	}

	public void updateProgress() throws SystemException {
		SelectionParams params = SelectionParams.build("sessionId", processSession.getSessionId(), "containerProcessId", process.getContainerBindId());
		ProgressBar[] result = processDao.getProgressBars(userSessionId, params);
		if (result != null && result.length > 0 && viewProcess != null) {
			Long progress = result[0].getCurrentValue();
			if (progress != null) {
				viewProcess.setProgress(progress.doubleValue());
			}
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

	public void setExecProcess(ProcessBO execProcess) {
		this.process = execProcess;
	}

	public void setThreadsNumber(int threadsNumber) {
		this.threadsNumber = threadsNumber;
	}

	public void setContainerSessionId(Long containerSessionId) {
		this.containerSessionId = containerSessionId;
	}

	public void setDataSource(DataSource dataSource) {
		this.dataSource = dataSource;
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

	@SuppressWarnings("unused")
	public Date getEffectiveDate() {
		return effectiveDate;
	}

	public void setEffectiveDate(Date effectiveDate) {
		this.effectiveDate = effectiveDate;
	}

	public Map<String, Object> getParameters() {
		return parameters;
	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		this.parameters = parameters;
	}

	public void setViewProcess(ProcessBO viewProcess) {
		this.viewProcess = viewProcess;
	}

	public ProcessSession getProcessSession() {
		return processSession;
	}

	@Override
	public ProcessBO getViewProcess() {
		return viewProcess;
	}

	public boolean isRunning() {
		return running;
	}

	public void setRunning(boolean running) {
		this.running = running;
	}

	@Override
	public ProcessBO getProcess() {
		return process;
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

	private String getExceptionText(Exception e) {
		String message = e.getMessage();
		if (message != null && message.startsWith("ORA-")) {
			message = message.replaceFirst("ORA-\\d+: ", "");
			message = message.split("ORA-\\d+:")[0];
		}
		return message;
	}
}

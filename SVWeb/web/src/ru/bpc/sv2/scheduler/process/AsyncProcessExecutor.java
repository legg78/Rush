/*
 * AsyncProcessExecutor.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.scheduler.process;

import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.process.ProcessFileInfo;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.scheduler.process.AsyncProcessHandler.HandlerState;
import ru.bpc.sv2.scheduler.process.utils.FilesProcess;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import java.io.File;
import java.sql.Connection;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Defines a new type of process executors.
 *
 * @author Ilya Yushin, Sergey Rastegaev
 * @version $Id$
 */
public final class AsyncProcessExecutor extends IbatisExternalProcess implements ProcessExecutor {

    private static final long POLLING_DELAY = 1000L;

    private static final Logger logger = Logger.getLogger("PROCESSES");
    private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

    // container parameters
    private Long containerSessionId;
    private Date effectiveDate;

    // user parameters
    private String userName;
    private int userId;
    private Long userSessionId;

    // execution handlers
    private AsyncProcessHandler handler;
    private ProcessExecutorAdapter listener;

    // Process logic and view model
    private ProcessBO viewProcess;
    private ProcessDao processDao;

    // process parameters
    private Map<String, Object> parameters;

    // Status consumer
    private StatusConsumerImpl processStatus;
    private StatusConsumerImpl totalStatus;
    private HandlerState commonState = HandlerState.InProgress;
    private double totalPercent = 0;

    // File walking routes
    private Map<String, Map<String, String>> routes;


    public void setHandler(AsyncProcessHandler handler) {
        this.handler = handler;
    }

    @Override
    public void execute() throws SystemException, UserException {

        routes = new HashMap<String, Map<String, String>>();
        processStatus = new StatusConsumerImpl();
        totalStatus = new StatusConsumerImpl();

        processSession = new ProcessSession();
        processSession.setSessionId(null);
        processSession.setUpSessionId(containerSessionId);
        prepareParameters();

        preprocess(processSession, null, 1, userName);

        try {
            getIbatisSession();
            startSession();
            startLogging();
            fireProcessRunning();
            con.commit();
            process();
        } catch (Exception e) {

            logger.error(e);
            loggerDB.error(e);

            fireProcessFailed();
            FilesProcess.rollback(routes);

            postProcess(processSession.getSessionId(), ProcessConstants.PROCESS_FAILED);
        } finally {
            closeConAndSsn();
        }
    }

    private void preprocess(ProcessSession processSession, Connection connection, int threadNumber, String userName) throws SystemException {
        try {
            processDao.preprocess(userSessionId, process, threadNumber, processSession, connection, effectiveDate, userName);
        } catch (DataAccessException e) {
            logger.error(e.getMessage(), e);
            throw new SystemException(e.getMessage(), e);
        }
    }

    public void process() throws SystemException, UserException {

        setParameters();

        // -------------------------------------------------------------------------------------------------------------
        final List<ProcessFileInfo> files = prepareFile();
        try {
            if (files.isEmpty()) {
                if (handler.isFileRequired())
                    throw new UserException("There are no files configured for this process.");
                else
                    executeNoFile();
            } else {
                final int filesCount = files.size();
                for (final ProcessFileInfo fileInfo : files) {
                    if ("FLPSINCM".equalsIgnoreCase(fileInfo.getFilePurpose())) // incoming
                        executeIncoming(fileInfo, filesCount);
                    else if ("FLPSOUTG".equalsIgnoreCase(fileInfo.getFilePurpose()))// outgoing
                        executeOutgoing(fileInfo, filesCount);
                }
            }
        } finally { // finalization of process work.
            switch (commonState) {
                case InProgress:
                case Failed: {
                    fireProcessFailed();
                    postProcess(processSession.getSessionId(), ProcessConstants.PROCESS_FAILED);
                    break;
                }
                case CompletedWithErrors: {
                    fireProcessFinishedWithErrors();
                    postProcess(processSession.getSessionId(), ProcessConstants.PROCESS_FINISHED_WITH_ERRORS);
                    break;
                }
                default: {
                    fireProcessFinished();
                    postProcess(processSession.getSessionId(), ProcessConstants.PROCESS_FINISHED);
                    break;
                }
            }
            viewProcess.setProgress(100); // finish.
            logEstimated((int) totalStatus.getTotalItems());
            endLogging((int) totalStatus.getProcessedItems(), (int) totalStatus.getFailedItems(), (int) totalStatus.getRejectedItems());
        }
        // -------------------------------------------------------------------------------------------------------------

        handler.destroy();
        fireProcessFinished();
    }

    private void prepareParameters(){
        Map<String, Object> parameters1 = processDao.getProcessParamsMap(
                userSessionId, process.getId(), process.getContainerBindId());
        if (parameters == null) {
            parameters = new HashMap<String, Object>();
        }
        for (String key : parameters1.keySet()) {
            if (parameters.get(key) == null) {
                parameters.put(key, parameters1.get(key));
            }
        }
        parameters.put("USER_NAME", userName);
    }

    private void postProcess(Long sessionId, String result) throws SystemException {
        try {
            processDao.postProcess(userSessionId, sessionId, result, userName,  process != null ? process.getContainerBindId() : null);
        } catch (DataAccessException e) {
            logger.error(e.getMessage(), e);
            throw new SystemException(e.getMessage(), e);
        }
    }

    // -----------------------------------------------------------------------------------------------------------------
    //  Execution logic
    // -----------------------------------------------------------------------------------------------------------------

    private void executeIncoming(ProcessFileInfo fileInfo, int fileMasksCount) throws UserException, SystemException {

        final FileObject[] fileObjects = FilesProcess.getFiles(fileInfo);
        if (fileObjects == null || fileObjects.length == 0)
            throw new UserException("There are no files matching the mask");

        final int chunks = 100 / fileMasksCount;

        // Walk through all files matched the mask.
        for (int i = 0; i < fileObjects.length; i++) {

            final FileObject fileObject = fileObjects[i];

            // Move to in progress
            final String filePath = FilesProcess.moveTo(fileObject, fileInfo, ProcessConstants.IN_PROCESS_FOLDER, routes);

            logger.debug("Processing file:" + filePath);
            loggerDB.debug("Processing file:" + filePath);

            try {
                // prepare context, run process.
                final ExecutionContext context = prepareContext(fileInfo, filePath, true);
                openFile(fileInfo, fileObject.getName().getBaseName());

                handler.execute(context);
                if (handler.getState() == HandlerState.AlreadyRunning)
                    throw new SystemException("Async process is already running.");

                statusPolling(fileObjects.length, chunks, processStatus); // polling process status
                calculateCommonState();

                switch (handler.getState()) {
                    case Cancelled:
                    case Failed: {
                        FilesProcess.moveTo(filePath, fileInfo, ProcessConstants.REJECTED_FOLDER, routes);
                        throw new Exception("Process executor has stopped.");
                    }
                    case CompletedWithErrors:
                    case Completed: {
                        FilesProcess.moveTo(filePath, fileInfo, ProcessConstants.PROCESSED_FOLDER, routes);
                        break;
                    }
                }

                logger.debug("Processed file:" + filePath + " state:" + handler.getState());
                loggerDB.debug("Processed file:" + filePath + " state:" + handler.getState());

            } catch (Exception e) {
                logger.error("", e);
                loggerDB.error(e.getMessage());
                throw new SystemException("Async process execution failed. ", e);
            } finally {
                // update global work status.
                totalStatus.increaseFailedItems(processStatus.getFailedItems());
                totalStatus.increaseProcessedItems(processStatus.getProcessedItems());
                totalStatus.increaseRejectedItems(processStatus.getRejectedItems());
                totalStatus.increaseTotalItems(processStatus.getTotalItems());
                processStatus.reset();
                handler.reset();
            }
        }
    }

    private void executeOutgoing(ProcessFileInfo fileInfo, int fileNameTemplates) throws SystemException, UserException {
        try {
            // prepare context, run process.
            final ExecutionContext context = prepareContext(fileInfo, fileInfo.getDirectoryPath(), false);
            handler.execute(context);
            if (handler.getState() == HandlerState.AlreadyRunning)
                throw new SystemException("Async process is already running.");

            final int chunks = 100 / fileNameTemplates;
            statusPolling(1, chunks, processStatus); // polling process status
            calculateCommonState();

            switch (handler.getState()) {
                case Cancelled:
                case Failed: {
                    throw new Exception("Process executor has stopped.");
                }
            }

            logger.debug("Processed session:" + processSessionId() + ", state: " + handler.getState());
            loggerDB.debug("Processed session:" + processSessionId() + ", state: " + handler.getState());
        } catch (final Exception e) {
            logger.error("", e);
            loggerDB.error(e.getMessage());
            throw new SystemException("Async process execution failed. ", e);
        } finally {
            // update global work status.
            totalStatus.increaseFailedItems(processStatus.getFailedItems());
            totalStatus.increaseProcessedItems(processStatus.getProcessedItems());
            totalStatus.increaseRejectedItems(processStatus.getRejectedItems());
            totalStatus.increaseTotalItems(processStatus.getTotalItems());
            processStatus.reset();
            handler.reset();
        }
    }

    private void executeNoFile() throws SystemException, UserException {
        try {
            // prepare context, run process.
            final ExecutionContext context = prepareContext(null, null, false);

            handler.execute(context);
            if (handler.getState() == HandlerState.AlreadyRunning)
                throw new SystemException("Async process is already running.");

            statusPolling(1, 100, totalStatus); // polling process status
            calculateCommonState();

            switch (handler.getState()) {
                case Cancelled:
                case Failed: {
                    throw new Exception("Process executor has stopped.");
                }
            }

            logger.debug("Processed session:" + processSessionId() + ", state: " + handler.getState());
            loggerDB.debug("Processed session:" + processSessionId() + ", state: " + handler.getState());
        } catch (final Exception e) {
            logger.error("", e);
            loggerDB.error(e.getMessage());
            throw new SystemException("Async process execution failed. ", e);
        }
    }

    // -----------------------------------------------------------------------------------------------------------------
    //  Progress status
    // -----------------------------------------------------------------------------------------------------------------

    private void calculateCommonState() {
        // calculating the worst process state.
        final int commonStateNewOrdinal = Math.max(handler.getState().ordinal(), commonState.ordinal());
        commonState = HandlerState.values()[commonStateNewOrdinal];
    }

    private void statusPolling(int total, int chunks, StatusConsumerImpl consumer) throws SystemException {

        // Fill first status information (including phases count)
        handler.fillStatus(consumer);

        final double localPercent = (chunks / total) / consumer.getPhaseCount();

        int crntPhase = 1;
        do {
            handler.fillStatus(consumer);
            processStatus(consumer);

            final long processed = consumer.getProcessedItems();
            final long failed = consumer.getFailedItems();
            final long rejected = consumer.getRejectedItems();
            final long totalItems = consumer.getTotalItems();
            if (totalItems > 0) {

                double work = ((double) (processed + failed + rejected)) / ((double) totalItems);
                if(crntPhase != consumer.getCurrentPhase()){
                    totalPercent += localPercent;
                    crntPhase = consumer.getCurrentPhase();
                }
                viewProcess.setProgress((int) (totalPercent + (localPercent * work)));
            }
            try {
                Thread.sleep(POLLING_DELAY);
            } catch (InterruptedException ignored) {
            }
        }
        while (handler.getState() == HandlerState.InProgress);
        handler.fillStatus(consumer); // last status
        totalPercent += localPercent;
    }

    private void processStatus(StatusConsumerImpl consumer) throws SystemException {
        if (consumer.estimationChanged())
            logEstimated((int) consumer.getTotalItems());

        logCurrent((int) consumer.getProcessedItems(), (int) consumer.getFailedItems());
    }

    // -----------------------------------------------------------------------------------------------------------------
    //  Configuration preparation.
    // -----------------------------------------------------------------------------------------------------------------

    private ConfigurationProvider prepareProvider() {
        return new ConfigurationProviderImpl(SettingsCache.getInstance());
    }

    private ExecutionContext prepareContext(ProcessFileInfo fileInfo, String filePath, boolean isIncoming) throws UserException {
        ExecutionContextImpl executionContext;
        try {
            executionContext = new ExecutionContextImpl();
            executionContext.setProcessId(process.getId()); // id of the process
            executionContext.setContainerId(process.getContainerId().longValue()); // container id of the process

            if (process.getContainerBindId() == null)
                executionContext.setContainerBindId(-1L);
            else
                executionContext.setContainerBindId(process.getContainerBindId().longValue()); // container id of the container

            executionContext.setSessionId(processSession.getSessionId()); // session id of this process
            executionContext.setUserId(userId);
            executionContext.setParentSessionId(processSession.getUpSessionId()); // session id of the container.

            if (fileInfo != null && filePath != null) {
                final FileInfoImpl info = new FileInfoImpl((new File(filePath)).toURI(), fileInfo.getCharacterset());
                if (isIncoming)
                    executionContext.setSourceFile(info);
                else
                    executionContext.setDestinationFile(info);
            }
            executionContext.setParameters(getParameters());
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            throw new UserException(e);
        }
        return executionContext;
    }

    private List<ProcessFileInfo> prepareFile() {
        return processDao.getProcessFilesInfo(userSessionId, this.process.getId(), this.process.getContainerId());
    }

    private Long openFile(ProcessFileInfo fileInfo, String fileName) {
        final ProcessFileAttribute fileAttributes = new ProcessFileAttribute();
        fileAttributes.setPurpose(fileInfo.getFilePurpose());
        fileAttributes.setFileType(fileInfo.getFileType());
        fileAttributes.setContainerBindId(this.process.getContainerBindId());
        fileAttributes.setFileName(fileName);
        fileAttributes.setSessionId(processSession.getSessionId());
        return processDao.openFile(userSessionId, fileAttributes);
    }


    // -----------------------------------------------------------------------------------------------------------------
    //  Process events firing
    // -----------------------------------------------------------------------------------------------------------------

    private void fireProcessRunning() {
        process.setState(ProcessBO.ProcessState.RUNNING);
        process.getProcessStatSummary().setSessionId(processSession.getSessionId());
        if (viewProcess != null) {
            viewProcess.setState(ProcessBO.ProcessState.RUNNING);
            viewProcess.getProcessStatSummary().setSessionId(processSession.getSessionId());
        }
        if (listener != null) {
            listener.processRunned(this);
        }
    }

    private void fireProcessFinished() {
        process.setState(ProcessBO.ProcessState.SUCCESSFULLY_COMPLETED);
        if (viewProcess != null) {
            viewProcess.setState(ProcessBO.ProcessState.SUCCESSFULLY_COMPLETED);
        }
        if (listener != null) {
            listener.processFinished(this);
        }
    }

    private void fireProcessFailed() {
        if (viewProcess != null) {
            viewProcess.setState(ProcessBO.ProcessState.NOT_SUCCESSFULLY_COMPLETED);
        }
        process.setState(ProcessBO.ProcessState.NOT_SUCCESSFULLY_COMPLETED);
        if (listener != null) {
            listener.processFailed(this);
        }
    }

    private void fireProcessFinishedWithErrors() {
        process.setState(ProcessBO.ProcessState.COMPLETED_WITH_ERRORS);
        if (viewProcess != null) {
            viewProcess.setState(ProcessBO.ProcessState.COMPLETED_WITH_ERRORS);
        }
        if (listener != null) {
            listener.processFinished(this);
        }
    }

    // -----------------------------------------------------------------------------------------------------------------
    //  Getters and Setters
    // -----------------------------------------------------------------------------------------------------------------

    public void setProcessDao(ProcessDao processDao) {
        this.processDao = processDao;
    }

    public void setUserSessionId(Long userSessionId) {
        this.userSessionId = userSessionId;
    }

    public void setExecProcess(ProcessBO execProcess) {
        this.process = execProcess;
    }

    public void setProcess(ProcessBO process) {
        this.process = process;
    }

    public void setContainerSessionId(Long containerSessionId) {
        this.containerSessionId = containerSessionId;
    }

    public void setEffectiveDate(Date effectiveDate) {
        this.effectiveDate = effectiveDate;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public void setViewProcess(ProcessBO viewProcess) {
        this.viewProcess = viewProcess;
    }

    public ProcessBO getViewProcess() {
        return viewProcess;
    }

    public void updateProgress() throws SystemException {
    }

    public ProcessBO getProcess() {
        return viewProcess;
    }

    public void setParameters() {
        handler.configure(prepareProvider());
    }

    public void setListener(ProcessExecutorAdapter listener) {
        this.listener = listener;
    }

    public void setParameters(Map<String, Object> parameters) {
        this.parameters = parameters;
    }

    public Map<String, Object> getParameters() {
        return parameters == null ? parameters = new HashMap<String, Object>() : parameters;
    }

    public ProcessSession getProcessSession() {
        return processSession;
    }
}

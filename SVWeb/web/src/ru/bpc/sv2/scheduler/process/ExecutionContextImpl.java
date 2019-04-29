package ru.bpc.sv2.scheduler.process;

import java.util.Map;

/**
 * Created by Gasanov on 17.03.2016.
 */
public class ExecutionContextImpl implements ExecutionContext {

    private long parentSessionId;
    private long containerId;
    private Long containerBindId;
    private long sessionId;
    private int userId;
    private FileInfo sourceFile;
    private Map<String, Object> parameters;
    private FileInfo destinationFile;
    private Integer processId;

    @Override
    public long getContainerId() {
        return containerId;
    }

    public void setContainerId(Long containerId) {
        this.containerId = containerId;
    }

    @Override
    public long getContainerBindId() {
        return containerBindId;
    }

    public void setContainerBindId(Long containerBindId) {
        this.containerBindId = containerBindId;
    }

    @Override
    public long getSessionId() {
        return sessionId;
    }

    public void setSessionId(long sessionId) {
        this.sessionId = sessionId;
    }

    @Override
    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    @Override
    public FileInfo getSourceFile() {
        return sourceFile;
    }

    public void setSourceFile(FileInfo sourceFile) {
        this.sourceFile = sourceFile;
    }

    @Override
    public Map<String, Object> getParameters() {
        return parameters;
    }

    public void setParameters(Map<String, Object> parameters) {
        this.parameters = parameters;
    }

    @Override
    public FileInfo getDestinationFile() {
        return destinationFile;
    }

    public void setDestinationFile(FileInfo destinationFile) {
        this.destinationFile = destinationFile;
    }

    @Override
    public Integer getProcessId() {
        return processId;
    }

    public void setProcessId(Integer processId) {
        this.processId = processId;
    }

    @Override
    public long getParentSessionId() {
        return this.parentSessionId;
    }

    public void setParentSessionId(long parentSessionId) {
        this.parentSessionId = parentSessionId;
    }
}

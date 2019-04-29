package ru.bpc.sv2.process;

import ru.bpc.sv2.common.TreeNode;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProcessBO implements ModelIdentifiable, Serializable, Cloneable, TreeNode<ProcessBO>, IAuditableObject {

	public static enum ProcessState {
		UNDEFINE,
		RUNNING,
		SUCCESSFULLY_COMPLETED,
		NOT_SUCCESSFULLY_COMPLETED,
		COMPLETED_WITH_ERRORS
	}
	
	private static final long serialVersionUID = 1L;

	private Integer orderNumber;
	private Integer id;
	private String lang;
	private String name;
	private String description;
	private String procedureName;
	private Integer defaultExecOrder;
	private Integer executionOrder;
	private String hierExecutionOrder;
	private boolean parallelAllowed;
	private boolean parallel;
	private boolean external;
	private boolean container;
	private Integer instId;
	private String instName;
	// auxiliary fields for group
	private Integer groupId; 
	private Integer groupBindId;
	// auxiliary fields for process in container	
	private Integer containerId;
	private Integer mainContainerId;
	private Integer containerBindId;
	private Integer errorLimit;
	private Integer trackThreshold;
	private boolean force;
	private String cronString;
	private int level;
	private boolean isLeaf;
	protected List<ProcessBO> children;
	private ProcessStatSummary processStatSummary = new ProcessStatSummary();
	private ProcessState state = ProcessState.UNDEFINE;
	private double progress;
	private Integer parallelDegree;
	private boolean interruptThreads;
	private boolean stopOnFatal;
	private Integer traceLevel;
	private Integer threadNumber;
	private Integer traceLimit;
	private String debugWritingMode;
	private Integer startTraceSize;
	private Integer errorTraceSize;

	public Object getModelId() {
		return getId() + "_" + getContainerBindId();
	}

	public Integer getOrderNumber() {
		return orderNumber;
	}
	public void setOrderNumber(Integer orderNumber) {
		this.orderNumber = orderNumber;
	}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public String getProcedureName() {
		return procedureName;
	}
	public void setProcedureName(String procedureName) {
		this.procedureName = procedureName;
	}

	public Integer getDefaultExecOrder() {
		return defaultExecOrder;
	}
	public void setDefaultExecOrder(Integer defaultExecOrder) {
		this.defaultExecOrder = defaultExecOrder;
	}

	public Integer getExecutionOrder() {
		return executionOrder;
	}
	public void setExecutionOrder(Integer executionOrder) {
		this.executionOrder = executionOrder;
	}

	public String getHierExecutionOrder() {
		return hierExecutionOrder;
	}

	public void setHierExecutionOrder(String hierExecutionOrder) {
		this.hierExecutionOrder = hierExecutionOrder;
	}

	public boolean isParallelAllowed() {
		return parallelAllowed;
	}
	public void setParallelAllowed(boolean parallelAllowed) {
		this.parallelAllowed = parallelAllowed;
	}

	public boolean isParallel() {
		return parallel;
	}
	public void setParallel(boolean parallel) {
		this.parallel = parallel;
	}

	public boolean isExternal() {
		return external;
	}
	public void setExternal(boolean external) {
		this.external = external;
	}

	public boolean isContainer() {
		return container;
	}
	public void setContainer(boolean container) {
		this.container = container;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Integer getGroupId() {
		return groupId;
	}
	public void setGroupId(Integer groupId) {
		this.groupId = groupId;
	}

	public Integer getGroupBindId() {
		return groupBindId;
	}
	public void setGroupBindId(Integer groupBindId) {
		this.groupBindId = groupBindId;
	}

	public Integer getContainerId() {
		return containerId;
	}
	public void setContainerId(Integer containerId) {
		this.containerId = containerId;
	}

	public Integer getMainContainerId() {
		return mainContainerId;
	}
	public void setMainContainerId(Integer mainContainerId) {
		this.mainContainerId = mainContainerId;
	}

	public Integer getContainerBindId() {
		return containerBindId;
	}
	public void setContainerBindId(Integer containerBindId) {
		this.containerBindId = containerBindId;
	}

	public Integer getErrorLimit() {
		return errorLimit;
	}
	public void setErrorLimit(Integer errorLimit) {
		this.errorLimit = errorLimit;
	}

	public Integer getTrackThreshold() {
		return trackThreshold;
	}
	public void setTrackThreshold(Integer trackThreshold) {
		this.trackThreshold = trackThreshold;
	}

	public boolean isForce() {
		return force;
	}
	public void setForce(boolean force) {
		this.force = force;
	}

	public String getCronString() {
		return cronString;
	}
	public void setCronString(String cronString) {
		this.cronString = cronString;
	}

	public int getLevel() {
		return level;
	}
	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}
	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public ArrayList<ProcessBO> getChildren() {
		return (ArrayList<ProcessBO>)children;
	}

	public void setChildren(List<ProcessBO> children) {
		this.children = children;
	}
	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	@Override
	public ProcessBO clone() throws CloneNotSupportedException {
		ProcessBO clone = (ProcessBO) super.clone();
		
		//make deep copy of an array
		if (this.children != null) {
			ArrayList<ProcessBO> children = new ArrayList<ProcessBO>(this.children.size());
			for (ProcessBO child: this.children) {
				children.add(child);
			}
			clone.setChildren(children);
		}
		
		return clone;
	}

	public ProcessStatSummary getProcessStatSummary() {		
		return processStatSummary;
	}
	public void setProcessStatSummary(ProcessStatSummary processStatSummary) {
		this.processStatSummary = processStatSummary;
	}

	public ProcessState getState() {
		return state;
	}
	public void setState(ProcessState state) {
		this.state = state;
	}
	
	public boolean isRunning(){
		return state == ProcessState.RUNNING;
	}
	
	public boolean isSuccessfullyCompleted(){
		return state == ProcessState.SUCCESSFULLY_COMPLETED;
	}
	
	public boolean isNotSuccessfullyCompleted(){
		return state == ProcessState.NOT_SUCCESSFULLY_COMPLETED;
	}

	public boolean isCompletedWithErrors(){
		return state == ProcessState.COMPLETED_WITH_ERRORS;
	}

	public double getProgress() {
		return progress;
	}
	public void setProgress(double progress) {
		this.progress = progress;
	}

	public Integer getParallelDegree() {
		return parallelDegree;
	}
	public void setParallelDegree(Integer parallelDegree) {
		this.parallelDegree = parallelDegree;
	}

	public boolean isInterruptThreads() {
		return interruptThreads;
	}
	public void setInterruptThreads(boolean interruptThreads) {
		this.interruptThreads = interruptThreads;
	}

	public boolean isStopOnFatal() {
		return stopOnFatal;
	}
	public void setStopOnFatal(boolean stopOnFatal) {
		this.stopOnFatal = stopOnFatal;
	}

	public Integer getTraceLevel() {
		return traceLevel;
	}
	public void setTraceLevel(Integer traceLevel) {
		this.traceLevel = traceLevel;
	}

	public Integer getThreadNumber() {
		return threadNumber;
	}
	public void setThreadNumber(Integer threadNumber) {
		this.threadNumber = threadNumber;
	}

	public Integer getTraceLimit() {
		return traceLimit;
	}
	public void setTraceLimit(Integer traceLimit) {
		this.traceLimit = traceLimit;
	}

	public String getDebugWritingMode() {
		return debugWritingMode;
	}
	public void setDebugWritingMode(String debugWritingMode) {
		this.debugWritingMode = debugWritingMode;
	}

	public Integer getStartTraceSize() {
		return startTraceSize;
	}
	public void setStartTraceSize(Integer startTraceSize) {
		this.startTraceSize = startTraceSize;
	}

	public Integer getErrorTraceSize() {
		return errorTraceSize;
	}
	public void setErrorTraceSize(Integer errorTraceSize) {
		this.errorTraceSize = errorTraceSize;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put(AUDIT_PARAM_OBJECT_ID, getId());
		result.put(AUDIT_PARAM_ENTITY_TYPE, EntityNames.PROCESS);
		result.put("id", getId());
		result.put("procedureName", getProcedureName());
		result.put("parallel", isParallel());
		result.put("external", isExternal());
		result.put("container", isContainer());
		result.put("instId", getInstId());
		result.put("name", getName());
		result.put("description", getDescription());
		result.put("lang", getLang());
		result.put("containerBindId", getContainerBindId());
		result.put("containerId", getContainerId());
		result.put("executionOrder", getExecutionOrder());
		result.put("errorLimit", getErrorLimit());
		result.put("trackThreshold", getTrackThreshold());
		result.put("force", isForce());
		result.put("stopOnFatal", isStopOnFatal());
		result.put("traceLevel", getTraceLevel());
		result.put("traceLimit", getTraceLimit());
		result.put("threadNumber", getThreadNumber());
		result.put("debugWritingMode", getDebugWritingMode());
		result.put("startTraceSize", getStartTraceSize());
		result.put("errorTraceSize", getErrorTraceSize());
		return result;
	}
}

package ru.bpc.sv2.process;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

public class ProcessSession implements ModelIdentifiable,  TreeIdentifiable<ProcessSession>, Serializable, Cloneable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long sessionId;
	private Long upSessionId;
	private Integer fileId;
	private String fileName;
	private String fileEncoding;
	private String purpose;
	private String location;
	private String fileType;
	private Integer recordCount;
	private String crc;
	private String result;
	@Deprecated
	private Long containerProcessId;
	private Date startDate;
	private Date endDate;
	private Date fileDate;
	private String resultCode;
	private Long processed;
	private Long rejected;
	private Long excepted;
	private Long estimated;
	private Long containerId;
	private Integer execOrder;
	private Integer isParallel;
	private String procedureName;
	private Integer processId;
	private String processName;
	@Deprecated
	private String processState;
	private Integer threadCount;
	private List<ProcessSession> children;
	private int level;
	
	private String userName;
	private Integer instId;
	private String instName;
	
	private Boolean isContainer;
	private String lang;
	private Long parentId;
	private boolean isLeaf;
	private Integer progress;
	private String sessionIdFilter;
	private int filesCount;
	private String address;

	private Integer traceLevel = 0;
	private Integer traceLimit = 10;
	private Integer threadNumber = -1;
	private String processDesc;

	private String measure;

	private Boolean changeOracleTracePossible = Boolean.FALSE;

	public Object getModelId() {
		return getSessionId()+"_"+getId();
	}

	public String getLocation() {
		return location;
	}
	public void setLocation(String location) {
		this.location = location;
	}

	public boolean hasChildren(){
		return children != null ? !children.isEmpty() : false;
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Integer getFileId() {
		return fileId;
	}
	public void setFileId(Integer fileId) {
		this.fileId = fileId;
	}

	public String getFileName() {
		return fileName;
	}
	public void setFileName(String fileName) {
		this.fileName = fileName;
	}

	public String getFileEncoding() {
		return fileEncoding;
	}
	public void setFileEncoding(String fileEncoding) {
		this.fileEncoding = fileEncoding;
	}

	public Integer getRecordCount() {
		return recordCount;
	}
	public void setRecordCount(Integer recordCount) {
		this.recordCount = recordCount;
	}

	public String getCrc() {
		return crc;
	}
	public void setCrc(String crc) {
		this.crc = crc;
	}

	public String getResult() {
		return result;
	}
	public void setResult(String result) {
		this.result = result;
	}

	public Long getUpSessionId() {
		return upSessionId;
	}
	public void setUpSessionId(Long upSessionId) {
		this.upSessionId = upSessionId;
	}

	public Long getContainerProcessId() {
		return containerProcessId;
	}
	public void setContainerProcessId(Long containerProcessId) {
		this.containerProcessId = containerProcessId;
	}

	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Date getFileDate() {
		return fileDate;
	}
	public void setFileDate(Date fileDate) {
		this.fileDate = fileDate;
	}

	public String getResultCode() {
		return resultCode;
	}
	public void setResultCode(String resultCode) {
		this.resultCode = resultCode;
	}

	public Long getProcessed() {
		return processed;
	}
	public void setProcessed(Long processed) {
		this.processed = processed;
	}

	public Long getRejected() {
		return rejected;
	}
	public void setRejected(Long rejected) {
		this.rejected = rejected;
	}

	public Long getExcepted() {
		return excepted;
	}
	public void setExcepted(Long excepted) {
		this.excepted = excepted;
	}

	public Long getContainerId() {
		return containerId;
	}
	public void setContainerId(Long containerId) {
		this.containerId = containerId;
	}

	public Integer getExecOrder() {
		return execOrder;
	}
	public void setExecOrder(Integer execOrder) {
		this.execOrder = execOrder;
	}

	public Integer getIsParallel() {
		return isParallel;
	}
	public void setIsParallel(Integer isParallel) {
		this.isParallel = isParallel;
	}

	public String getProcedureName() {
		return procedureName;
	}
	public void setProcedureName(String procedureName) {
		this.procedureName = procedureName;
	}

	public String getProcessName() {
		return processName;
	}
	public void setProcessName(String processName) {
		this.processName = processName;
	}

	public String getProcessState() {
		return processState;
	}
	public void setProcessState(String processState) {
		this.processState = processState;
	}

	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getProcessId() {
		return processId;
	}
	public void setProcessId(Integer processId) {
		this.processId = processId;
	}

	public Boolean getIsContainer() {
		return isContainer;
	}
	public void setIsContainer(Boolean isContainer) {
		this.isContainer = isContainer;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public Long getParentId() {
		return parentId;
	}
	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public Integer getThreadCount() {
		return threadCount;
	}
	public void setThreadCount(Integer threadCount) {
		this.threadCount = threadCount;
	}

	public List<ProcessSession> getChildren() {
		return children;
	}
	public void setChildren(List<ProcessSession> children) {
		this.children = children;
	}

	public int getLevel() {
		return level;
	}
	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}
	
	@Override
	public ProcessSession clone() throws CloneNotSupportedException {
		return (ProcessSession) super.clone();
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());		
		return result;
	}
	

	public String getPurpose() {
		return purpose;
	}
	public void setPurpose(String purpose) {
		this.purpose = purpose;
	}

	public String getFileType() {
		return fileType;
	}
	public void setFileType(String fileType) {
		this.fileType = fileType;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ProcessSession other = (ProcessSession) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}

	public Integer getProgress() {
		return progress;
	}
	public void setProgress(Integer progress) {
		this.progress = progress;
	}

	public String getSessionIdFilter() {
		return sessionIdFilter;
	}
	public void setSessionIdFilter(String sessionIdFilter) {
		this.sessionIdFilter = sessionIdFilter;
	}

	public Long getEstimated() {
		return estimated;
	}
	public void setEstimated(Long estimated) {
		this.estimated = estimated;
	}

	public int getFilesCount() {
		return filesCount;
	}
	public void setFilesCount(int filesCount) {
		this.filesCount = filesCount;
	}

	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
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

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Boolean getChangeOracleTracePossible() {
		setChangeOracleTracePossible(Boolean.FALSE);
		if (!this.hasChildren()) {
			if (resultCode != null && resultCode.equals("PRSR0001")) {
				setChangeOracleTracePossible(Boolean.TRUE);
			}
		}
		return changeOracleTracePossible;
	}
	public void setChangeOracleTracePossible(Boolean changeOracleTracePossible) {
		this.changeOracleTracePossible = changeOracleTracePossible;
	}

	public String getProcessDesc() {
		return processDesc;
	}

	public void setProcessDesc(String processDesc) {
		this.processDesc = processDesc;
	}

	public String getMeasure() {
		return measure;
	}

	public void setMeasure(String measure) {
		this.measure = measure;
	}
}
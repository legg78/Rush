package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessTrace implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer threadNumber;
	private String traceLevel;
	private Integer traceLevelFilter;
	private String traceText;
	private Date traceTimestamp;
	private Integer traceLimit;
	private String userId;
	private Long sessionId;
	private String entityType;
	private String entityDescription;
	private Long objectId;
	private String details;
	private String traceSection;
	private Long eventId;
	private Long labelId;
	private Long instId;
	private String whoCalled;
	private String text;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getThreadNumber() {
		return threadNumber;
	}
	public void setThreadNumber(Integer threadNumber) {
		this.threadNumber = threadNumber;
	}

	public String getTraceLevel() {
		return traceLevel;
	}
	public void setTraceLevel(String traceLevel) {
		this.traceLevel = traceLevel;
	}

	public Integer getTraceLevelFilter() {
		return traceLevelFilter;
	}
	public void setTraceLevelFilter(Integer traceLevelFilter) {
		this.traceLevelFilter = traceLevelFilter;
	}

	public String getTraceText() {
		return traceText;
	}
	public void setTraceText(String traceText) {
		this.traceText = traceText;
	}

	public Date getTraceTimestamp() {
		return traceTimestamp;
	}
	public void setTraceTimestamp(Date traceTimestamp) {
		this.traceTimestamp = traceTimestamp;
	}

	public Integer getTraceLimit() {
		return traceLimit;
	}
	public void setTraceLimit(Integer traceLimit) {
		this.traceLimit = traceLimit;
	}

	public String getUserId() {
		return userId;
	}
	public void setUserId(String userId) {
		this.userId = userId;
	}

	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}
	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getDetails() {
		return details;
	}
	public void setDetails(String details) {
		this.details = details;
	}

	public String getEntityDescription() {
		return entityDescription;
	}
	public void setEntityDescription(String entityDescription) {
		this.entityDescription = entityDescription;
	}

	public String getTraceSection() {
		return traceSection;
	}
	public void setTraceSection(String traceSection) {
		this.traceSection = traceSection;
	}

	public Long getEventId() {
		return eventId;
	}
	public void setEventId(Long eventId) {
		this.eventId = eventId;
	}

	public Long getLabelId() {
		return labelId;
	}
	public void setLabelId(Long labelId) {
		this.labelId = labelId;
	}

	public Long getInstId() {
		return instId;
	}
	public void setInstId(Long instId) {
		this.instId = instId;
	}

	public String getWhoCalled() {
		return whoCalled;
	}
	public void setWhoCalled(String whoCalled) {
		this.whoCalled = whoCalled;
	}

	public String getText() {
		return text;
	}
	public void setText(String text) {
		this.text = text;
	}
}
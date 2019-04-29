package ru.bpc.sv2.process;

import java.util.Date;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;

import ru.bpc.sv2.invocation.ModelDTO;

@XmlAccessorType(XmlAccessType.NONE)
@XmlRootElement(name = "ProcessTrace")
public class ProcessTraceDTO implements ModelDTO {

	@XmlElement(name = "id", required = false)
	private Long id;
	@XmlElement(name = "threadNumber", required = false)
	private Integer threadNumber;
	@XmlElement(name = "traceLevel", required = false)
	private String traceLevel;
	@XmlElement(name = "traceLevelFilter", required = false)
	private Integer traceLevelFilter;
	@XmlElement(name = "traceText", required = false)
	private String traceText;
	@XmlElement(name = "traceSection", required = false)
	private String traceSection;
	@XmlElement(name = "traceTimestamp", required = false)
	private Date traceTimestamp;
	@XmlElement(name = "userId", required = false)
	private String userId;
	@XmlElement(name = "sessionId", required = false)
	private Long sessionId;
	@XmlElement(name = "entityType", required = false)
	private String entityType;
	@XmlElement(name = "entityDescription", required = false)
	private String entityDescription;
	@XmlElement(name = "objectId", required = false)
	private Long objectId;
	@XmlElement(name = "eventId", required = false)
	private Long eventId;
	@XmlElement(name = "labelId", required = false)
	private Long labelId;
	@XmlElement(name = "instId", required = false)
	private Long instId;
	@XmlElement(name = "details", required = false)
	private String details;
	@XmlElement(name = "whoCalled", required = false)
	private String whoCalled;
	@XmlElement(name = "text", required = false)
	private String text;
	
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

	public String getTraceSection() {
		return traceSection;
	}

	public void setTraceSection(String traceSection) {
		this.traceSection = traceSection;
	}

	public String getEntityDescription() {
		return entityDescription;
	}

	public void setEntityDescription(String entityDescription) {
		this.entityDescription = entityDescription;
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

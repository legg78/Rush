package ru.bpc.sv2.reports;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReportLog implements ModelIdentifiable, Serializable, Cloneable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Long objectId;
	private String entityType;
	private String text;
	private String userId;
	private Long sessionId;
	private String traceText;
	private String traceLevel;
	private Timestamp traceTimeStape;
	
	public Long getObjectId() {
		return objectId;
	}
	
	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getText() {
		return text;
	}

	public void setText(String text) {
		this.text = text;
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

	public String getTraceText() {
		return traceText;
	}

	public void setTraceText(String traceText) {
		this.traceText = traceText;
	}

	public String getTraceLevel() {
		return traceLevel;
	}

	public void setTraceLevel(String traceLevel) {
		this.traceLevel = traceLevel;
	}

	public Date getTraceTimeStape() {
		return traceTimeStape;
	}

	public void setTraceTimeStape(Timestamp traceTimeStape) {
		this.traceTimeStape = traceTimeStape;
	}

	@Override
	public Object getModelId() {
		return getTraceTimeStape();
	}

}

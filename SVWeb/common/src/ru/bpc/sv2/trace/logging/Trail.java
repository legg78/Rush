package ru.bpc.sv2.trace.logging;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Trail implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private String entityType;
	private Long objectId;
	private String actionType;
	private Date actionDate;
	private Date actionDateFrom;
	private Date actionDateTo;
	private long actionTime;
	private String userId;
	private String sessionId;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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

	public String getActionType() {
		return actionType;
	}

	public void setActionType(String actionType) {
		this.actionType = actionType;
	}

	public Date getActionDate() {
		return actionDate;
	}

	public void setActionDate(Date actionDate) {
		this.actionDate = actionDate;
	}

	public Date getActionDateFrom() {
		return actionDateFrom;
	}

	public void setActionDateFrom(Date actionDateFrom) {
		this.actionDateFrom = actionDateFrom;
	}

	public Date getActionDateTo() {
		return actionDateTo;
	}

	public void setActionDateTo(Date actionDateTo) {
		this.actionDateTo = actionDateTo;
	}

	public long getActionTime() {
		return actionTime;
	}

	public void setActionTime(long actionTime) {
		this.actionTime = actionTime;
	}

	public String getUserId() {
		return userId;
	}

	public void setUserId(String userId) {
		this.userId = userId;
	}

	public String getSessionId() {
		return sessionId;
	}

	public void setSessionId(String sessionId) {
		this.sessionId = sessionId;
	}

	public Object getModelId() {
		return getId();
	}
}

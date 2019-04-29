package ru.bpc.sv2.audit;

import java.io.Serializable;
import java.util.Date;
import java.util.List;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.process.ProcessSession;

public class AuditTrail implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private String entityType;
	private Long objectId;
	private String actionType;
	private Date actionDate;
	private String userId;

	private Date actionDateFrom;
	private Date actionDateTo;
	private long actionTime;

	private Integer privId;
	private Long sessionId;
	private String status;
	private String userName;
	private String privName;
	private TrailDetails trailDetails;
	private ProcessSession processSession;
	private String objectNumber;

	public Object getModelId() {
		return getId();
	}

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

	public Integer getPrivId() {
		return privId;
	}

	public void setPrivId(Integer privId) {
		this.privId = privId;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getPrivName() {
		return privName;
	}

	public void setPrivName(String privName) {
		this.privName = privName;
	}

	public TrailDetails getTrailDetails() {
		return trailDetails;
	}

	public void setTrailDetails(TrailDetails trailDetails) {
		this.trailDetails = trailDetails;
	}

	public ProcessSession getProcessSession() {
		return processSession;
	}

	public void setProcessSession(ProcessSession processSession) {
		this.processSession = processSession;
	}

	public String getObjectNumber() {
		return objectNumber;
	}

	public void setObjectNumber(String objectNumber) {
		this.objectNumber = objectNumber;
	}
}

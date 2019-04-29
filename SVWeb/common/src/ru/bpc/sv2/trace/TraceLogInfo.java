package ru.bpc.sv2.trace;

import java.io.Serializable;

public class TraceLogInfo implements Serializable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Long sessionId;
	private String message;
	private Integer threadNum;
	private String entityType;
	private Long objectId;
	private Integer containerId;
	private String user;
	
	public TraceLogInfo(Long sessionId, String message) {
		this.sessionId = sessionId;
		this.message = message;
	}

	public TraceLogInfo(Long sessionId, Integer containerId, String message) {
		this.sessionId = sessionId;
		this.message = message;
		this.containerId = containerId;
	}
	
	public TraceLogInfo(Long sessionId, String message, Integer threadNum) {
		this.sessionId = sessionId;
		this.message = message;
		this.threadNum = threadNum;
	}
	
	public TraceLogInfo(Long sessionId, String message, String entityType, Long objectId) {
		this.sessionId = sessionId;
		this.message = message;
		this.entityType = entityType;
		this.objectId = objectId;
	}

	public TraceLogInfo(Long sessionId, String message, String entityType, Long objectId, String user) {
		this.sessionId = sessionId;
		this.message = message;
		this.entityType = entityType;
		this.objectId = objectId;
		this.user = user;
	}

	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}
	public String getMessage() {
		return message;
	}
	public void setMessage(String message) {
		this.message = message;
	}

	public Integer getThreadNum() {
		return threadNum;
	}

	public void setThreadNum(Integer threadNum) {
		this.threadNum = threadNum;
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

	public Integer getContainerId() {
		return containerId;
	}

	public void setContainerId(Integer containerId) {
		this.containerId = containerId;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	@Override
	public String toString() {
		return "Session " + sessionId + ": " + getMessage();
	}
}

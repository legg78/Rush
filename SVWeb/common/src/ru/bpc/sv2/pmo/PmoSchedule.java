package ru.bpc.sv2.pmo;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PmoSchedule implements Serializable, ModelIdentifiable, Cloneable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private Long orderId;
	private String eventType;
	private String entityType;
	private Long objectId;
	private String objectNumber;
	private Integer attemptLimit;
	private String amountAlgorithm;
	private Long cycleId;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Long getOrderId() {
		return orderId;
	}

	public void setOrderId(Long orderId) {
		this.orderId = orderId;
	}

	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
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

	public Integer getAttemptLimit() {
		return attemptLimit;
	}

	public void setAttemptLimit(Integer attemptLimit) {
		this.attemptLimit = attemptLimit;
	}

	public String getAmountAlgorithm() {
		return amountAlgorithm;
	}

	public void setAmountAlgorithm(String amountAlgorithm) {
		this.amountAlgorithm = amountAlgorithm;
	}

	public Long getCycleId() {
		return cycleId;
	}

	public void setCycleId(Long cycleId) {
		this.cycleId = cycleId;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public String getObjectNumber() {
		return objectNumber;
	}

	public void setObjectNumber(String objectNumber) {
		this.objectNumber = objectNumber;
	}
}

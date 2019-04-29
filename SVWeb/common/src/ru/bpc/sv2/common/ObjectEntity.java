package ru.bpc.sv2.common;

import java.io.Serializable;

public class ObjectEntity implements Serializable {
	private static final long serialVersionUID = 1L;

	private String entityType;
	private Long objectId;
	private Integer seqNum;

	public ObjectEntity() {}
	public ObjectEntity(Long objectId, String entityType) {
		setObjectId(objectId);
		setEntityType(entityType);
	}
	public ObjectEntity(Long objectId, String entityType, Integer seqNum) {
		setObjectId(objectId);
		setEntityType(entityType);
		setSeqNum(seqNum);
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

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}
}

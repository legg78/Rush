package ru.bpc.sv2.common.events;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class RegisteredEvent implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private String eventType;
	private Date effectiveDate;
	private String entityType;
	private Long objectId;
	private Integer instId;
	private Integer splitHash;
	private Map<String,Object> params;

	public RegisteredEvent(){
	}

	public RegisteredEvent(String eventType, Date effectiveDate, String entityType, Long objectId) {
		this.eventType = eventType;
		this.effectiveDate = effectiveDate;
		this.entityType = entityType;
		this.objectId = objectId;
		this.instId = null;
		this.splitHash = null;
		this.params = new HashMap<String, Object>();
	}

	public RegisteredEvent(String eventType, Date effectiveDate, String entityType, Long objectId, Integer instId) {
		this.eventType = eventType;
		this.effectiveDate = effectiveDate;
		this.entityType = entityType;
		this.objectId = objectId;
		this.instId = instId;
	}

	public Object getModelId() {
		return getId();
	}
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public Date getEffectiveDate() {
		return effectiveDate;
	}

	public void setEffectiveDate(Date effectiveDate) {
		this.effectiveDate = effectiveDate;
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

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Map<String, Object> getParams() {
		return params;
	}

	public void setParams(Map<String, Object> params) {
		this.params = params;
	}

	@Override
	public RegisteredEvent clone() throws CloneNotSupportedException{
		return (RegisteredEvent)super.clone();		
	}
}

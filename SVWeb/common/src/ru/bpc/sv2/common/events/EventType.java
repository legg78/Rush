package ru.bpc.sv2.common.events;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class EventType implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String eventType;
	private String entityType;
	private String name;
	private String description;
	private String lang;
	private Integer reasonLovId;
	private String reasonLovIdName;
	
	public Object getModelId() {
		
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
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

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public EventType clone() throws CloneNotSupportedException {
		
		return (EventType) super.clone();
	}
	
	public EventType() {
	}

	public Integer getReasonLovId() {
		return reasonLovId;
	}

	public void setReasonLovId(Integer reasonLovId) {
		this.reasonLovId = reasonLovId;
	}
	
	public String getReasonLovIdName() {
		return reasonLovIdName;
	}

	public void setReasonLovIdName(String reasonLovIdName) {
		this.reasonLovIdName = reasonLovIdName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("eventType", this.getEventType());
		result.put("entityType", this.getEntityType());
		result.put("reasonLovId", this.getReasonLovId());
		
		return result;
	}
	
}

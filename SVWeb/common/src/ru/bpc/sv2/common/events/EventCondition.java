package ru.bpc.sv2.common.events;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class EventCondition implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer eventId;
	private Integer subscriberId;
	private String procedureName;
	private String eventType;
	private Integer instId;
	private String instName;	
	private String lang;
	private String condition;

	public Object getModelId() {
		return getId();
	}
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getProcedureName() {
		return procedureName;
	}
	public void setProcedureName(String procedureName) {
		this.procedureName = procedureName;
	}
	public String getEventType() {
		return eventType;
	}
	public void setEventType(String eventType) {
		this.eventType = eventType;
	}
	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}
	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}
	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}
	public Integer getEventId() {
		return eventId;
	}
	public void setEventId(Integer eventId) {
		this.eventId = eventId;
	}
	public Integer getSubscriberId() {
		return subscriberId;
	}
	public void setSubscriberId(Integer subscriberId) {
		this.subscriberId = subscriberId;
	}
	public String getCondition() {
		return condition;
	}
	public void setCondition(String condition) {
		this.condition = condition;
	}
	@Override
	public EventCondition clone() throws CloneNotSupportedException{
		return (EventCondition)super.clone();		
	}
}

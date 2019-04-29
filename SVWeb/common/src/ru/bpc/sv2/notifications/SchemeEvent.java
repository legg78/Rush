package ru.bpc.sv2.notifications;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class SchemeEvent implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;
	
	private Integer id;
	private Integer seqNum;
	private Integer schemeId;
	private String eventType;
	private String entityType;
	private String contactType;
	private Integer notificationId;
	private Integer channelId;
	private String deliveryTime;
	private boolean customizable;
	private boolean active;
	private String status;
	private String notificationName;
	private String channelName;
	private Integer fromHour;
	private Integer toHour;
	private Integer scaleId;
	private String scaleName;
	private boolean batchSend;
	private Integer priority;
	
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

	public Integer getSchemeId() {
		return schemeId;
	}

	public void setSchemeId(Integer schemeId) {
		this.schemeId = schemeId;
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

	public String getContactType() {
		return contactType;
	}

	public void setContactType(String contactType) {
		this.contactType = contactType;
	}

	public Integer getNotificationId() {
		return notificationId;
	}

	public void setNotificationId(Integer notificationId) {
		this.notificationId = notificationId;
	}

	public Integer getChannelId() {
		return channelId;
	}

	public void setChannelId(Integer channelId) {
		this.channelId = channelId;
	}

	public String getDeliveryTime() {
		return deliveryTime;
	}

	public void setDeliveryTime(String deliveryTime) {
		this.deliveryTime = deliveryTime;
	}

	public boolean isCustomizable() {
		return customizable;
	}

	public void setCustomizable(boolean customizable) {
		this.customizable = customizable;
	}

	public boolean isActive() {
		return active;
	}

	public void setActive(boolean active) {
		this.active = active;
	}

	public String getNotificationName() {
		return notificationName;
	}

	public void setNotificationName(String notificationName) {
		this.notificationName = notificationName;
	}

	public String getChannelName() {
		return channelName;
	}

	public void setChannelName(String channelName) {
		this.channelName = channelName;
	}

	public Integer getFromHour() {
		if (fromHour == null && deliveryTime != null && deliveryTime.length() > 0) {
			fromHour = Integer.parseInt(deliveryTime.split("-")[0]);
		}
		return fromHour;
	}

	public void setFromHour(Integer fromHour) {
		this.fromHour = fromHour;
	}

	public Integer getToHour() {
		if (toHour == null && deliveryTime != null && deliveryTime.length() > 0) {
			toHour = Integer.parseInt(deliveryTime.split("-")[1]);
		}
		return toHour;
	}

	public void setToHour(Integer toHour) {
		this.toHour = toHour;
	}

	public Integer getScaleId() {
		return scaleId;
	}

	public void setScaleId(Integer scaleId) {
		this.scaleId = scaleId;
	}

	public String getScaleName() {
		return scaleName;
	}

	public void setScaleName(String scaleName) {
		this.scaleName = scaleName;
	}

	public boolean isBatchSend() {
		return batchSend;
	}

	public void setBatchSend(boolean batchSend) {
		this.batchSend = batchSend;
	}

	@Override
	public SchemeEvent clone() throws CloneNotSupportedException {
		
		return (SchemeEvent) super.clone();
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("schemeId", getSchemeId());
		result.put("eventType", getEventType());
		result.put("entityType", getEntityType());
		result.put("contactType", getContactType());
		result.put("notificationId", getNotificationId());
		result.put("channelId", getChannelId());
		result.put("deliveryTime", getDeliveryTime());
		result.put("customizable", isCustomizable());
		result.put("status", getStatus());
		result.put("batchSend", isBatchSend());
		result.put("scaleId", getScaleId());
		result.put("priority", getPriority());
		return result;
	}

}

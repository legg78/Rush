package ru.bpc.sv2.notifications;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CustomEvent implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer schemeEventId;
	private Long objectId;
	private Integer channelId;
	private String deliveryAddress;
	private String deliveryTime;
	private Boolean isActive;
	private Integer instId;
	private String eventType;
	private String entityType;
	private String entityNumber;
	private String instName;
	private String channelName;
	private Integer modId;
	private String modName;
	private Integer fromHour;
	private Integer toHour;
	private Date startDate;
	private Date endDate;
	private String lang;
	private String recepient;
	private Boolean isCustomizable;
	private String status;

	public Object getModelId() {
		return getSchemeEventId() + "_" + getEntityType() + "_" + getId();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSchemeEventId() {
		return schemeEventId;
	}
	public void setSchemeEventId(Integer schemeEventId) {
		this.schemeEventId = schemeEventId;
	}

	public Long getObjectId() {
		return objectId;
	}
	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Integer getChannelId() {
		return channelId;
	}
	public void setChannelId(Integer channelId) {
		this.channelId = channelId;
	}

	public String getDeliveryAddress() {
		return deliveryAddress;
	}
	public void setDeliveryAddress(String deliveryAddress) {
		this.deliveryAddress = deliveryAddress;
	}

	public String getDeliveryTime() {
		return deliveryTime;
	}
	public void setDeliveryTime(String deliveryTime) {
		this.deliveryTime = deliveryTime;
	}

	public Boolean getActive() {
		return isActive;
	}
	public void setActive(Boolean isActive) {
		this.isActive = isActive;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
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

	public String getEntityNumber() {
		return entityNumber;
	}
	public void setEntityNumber(String entityNumber) {
		this.entityNumber = entityNumber;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getChannelName() {
		return channelName;
	}
	public void setChannelName(String channelName) {
		this.channelName = channelName;
	}

	public Integer getModId() {
		return modId;
	}
	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public String getModName() {
		return modName;
	}
	public void setModName(String modName) {
		this.modName = modName;
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

	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getRecepient() {
		return recepient;
	}
	public void setRecepient(String recepient) {
		this.recepient = recepient;
	}

	public Boolean getCustomizable() {
		return isCustomizable;
	}
	public void setCustomizable(Boolean isCustomizable) {
		this.isCustomizable = isCustomizable;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		CustomEvent clone = (CustomEvent) super.clone();
		if (startDate != null) {
			clone.setStartDate(new Date(startDate.getTime()));
		}
		if (endDate != null) {
			clone.setEndDate(new Date(endDate.getTime()));
		}
		return clone;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("eventType", getEventType());
		result.put("entityType", getEntityType());
		result.put("entityNumber", getEntityNumber());
		result.put("objectId", getObjectId());
		result.put("channelId", getChannelId());
		result.put("deliveryAddress", getDeliveryAddress());
		result.put("deliveryTime", getDeliveryTime());
		result.put("status", getStatus());
		result.put("modId", getModId());
		result.put("startDate", getStartDate());
		result.put("endDate", getEndDate());
		return result;
	}
}

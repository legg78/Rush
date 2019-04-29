package ru.bpc.sv2.notifications;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class NotificationCustomEvent implements Serializable, ModelIdentifiable{
	private static final long serialVersionUID = 1L;
	private Long id;
	private Integer schemeId;
	private Integer notifId;
	private Integer reportId;
	private Integer channelId;
	private String deliveryTime;
	private String deliveryAddress;
	private String contactType;
	private Integer priority;
	private String status;
	private String eventType;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSchemeId() {
		return schemeId;
	}
	public void setSchemeId(Integer schemeId) {
		this.schemeId = schemeId;
	}

	public Integer getNotifId() {
		return notifId;
	}
	public void setNotifId(Integer notifId) {
		this.notifId = notifId;
	}

	public Integer getReportId() {
		return reportId;
	}
	public void setReportId(Integer reportId) {
		this.reportId = reportId;
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

	public String getDeliveryAddress() {
		return deliveryAddress;
	}
	public void setDeliveryAddress(String deliveryAddress) {
		this.deliveryAddress = deliveryAddress;
	}

	public String getContactType() {
		return contactType;
	}
	public void setContactType(String contactType) {
		this.contactType = contactType;
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

	public String getEventType() {
		return eventType;
	}
	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	@Override
	public Object getModelId() {
		return getId().toString() + getNotifId().toString();
	}
}

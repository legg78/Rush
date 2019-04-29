package ru.bpc.sv2.notifications;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.issuing.Card;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class CustomObject implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long customEventId;
	private Long objectId;
	private String objectType;
	private String objectNumber;
	private String objectMask;
	private Card activeCard;
	private boolean isActive;
	private String customEventName;

	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Long getCustomEventId() {
		return customEventId;
	}
	public void setCustomEventId(Long customEventId) {
		this.customEventId = customEventId;
	}

	public Long getObjectId() {
		return objectId;
	}
	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getObjectType() {
		return objectType;
	}
	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public String getObjectNumber() {
		return objectNumber;
	}
	public void setObjectNumber(String objectNumber) {
		this.objectNumber = objectNumber;
	}

	public String getObjectMask() {
		return objectMask;
	}
	public void setObjectMask(String objectMask) {
		this.objectMask = objectMask;
	}

	public boolean isActive() {
		return isActive;
	}
	public void setActive(boolean isActive) {
		this.isActive = isActive;
	}

	public String getCustomEventName() {
		return customEventName;
	}
	public void setCustomEventName(String customEventName) {
		this.customEventName = customEventName;
	}

	public Card getActiveCard() {
		return activeCard;
	}
	public void setActiveCard(Card activeCard) {
		this.activeCard = activeCard;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("customEventId", getCustomEventId());
		result.put("objectId", getObjectId());
		result.put("objectType", getObjectType());
		result.put("isActive", isActive());
		return result;
	}
}

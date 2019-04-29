package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Appearance implements Serializable, ModelIdentifiable,Cloneable, IAuditableObject {
		
	private Long id;
	private String entityType;
	private Long seqNum;
	private Long objectId;
	private String cssClass;
	private String objectReference;
	
	public Long getId() {
		return id;
	}
	
	public void setId(Long id) {
		this.id = id;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Long seqNum) {
		this.seqNum = seqNum;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getCssClass() {
		return cssClass;
	}

	public void setCssClass(String cssClass) {
		this.cssClass = cssClass;
	}

	public Object getModelId() {
		return getId();
	}

	public String getObjectReference() {
		return objectReference;
	}

	public void setObjectReference(String objectReference) {
		this.objectReference = objectReference;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("entityType", this.getEntityType());
		result.put("objectId", this.getObjectId());
		result.put("cssClass", this.getCssClass());
		result.put("objectreference", this.getObjectReference());
		return result;
	}

}

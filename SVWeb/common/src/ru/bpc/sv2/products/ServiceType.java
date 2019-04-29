package ru.bpc.sv2.products;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ServiceType implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;
	
	private Integer id;
	private Integer seqNum;
	private String productEntityType;
	private String entityType;
	private String label;
	private String description;
	private String lang;
	private String externalCode;
	private Boolean isInitial;
	private String enableEventType;
	private String disableEventType;
	
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

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
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

	public String getProductEntityType() {
		return productEntityType;
	}

	public void setProductEntityType(String productEntityType) {
		this.productEntityType = productEntityType;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Boolean getIsInitial() {
		return isInitial;
	}

	public void setIsInitial(Boolean isInitial) {
		this.isInitial = isInitial;
	}

	public String getEnableEventType() {
		return enableEventType;
	}

	public void setEnableEventType(String enableEventType) {
		this.enableEventType = enableEventType;
	}

	public String getDisableEventType() {
		return disableEventType;
	}

	public void setDisableEventType(String disableEventType) {
		this.disableEventType = disableEventType;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("productEntityType", getProductEntityType());
		result.put("entityType", getEntityType());
		result.put("enableEventType", getEnableEventType());
		result.put("disableEventType", getDisableEventType());
		result.put("lang", getLang());
		result.put("label", getLabel());
		result.put("description", getDescription());
		result.put("isInitial", getIsInitial());
		return result;
	}

	public String getExternalCode() {
		return externalCode;
	}

	public void setExternalCode(String externalCode) {
		this.externalCode = externalCode;
	}
}

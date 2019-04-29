package ru.bpc.sv2.common;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class FlexField extends Parameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 5172755069072541747L;

	private Integer id;
	private String entityType;
	private String objectType;

	private Object defaultValue;
	private BigDecimal defaultNumberValue;
	private String defaultCharValue;
	private Date defaultDateValue;
	private String defaultLovValue;

	private boolean userDefined;
	private Integer instId;
	private String instName;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Object getModelId() {
		return getId();
	}
	
	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public boolean isUserDefined() {
		return userDefined;
	}

	public void setUserDefined(boolean userDefined) {
		this.userDefined = userDefined;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public BigDecimal getDefaultNumberValue() {
		return defaultNumberValue;
	}

	public void setDefaultNumberValue(BigDecimal defaultNumberValue) {
		if (isNumber()){
			this.defaultValue = defaultNumberValue;
		}
		this.defaultNumberValue = defaultNumberValue;
	}

	public String getDefaultCharValue() {
		return defaultCharValue;
	}

	public void setDefaultCharValue(String defaultCharValue) {
		if (isChar()){
			this.defaultValue = defaultCharValue;
		}
		this.defaultCharValue = defaultCharValue;
	}

	public Date getDefaultDateValue() {
		return defaultDateValue;
	}

	public void setDefaultDateValue(Date defaultDateValue) {
		if (isDate()){
			this.defaultValue = defaultDateValue;
		}
		this.defaultDateValue = defaultDateValue;
	}

	public String getDefaultLovValue() {
		return defaultLovValue;
	}

	public void setDefaultLovValue(String defaultLovValue) {
		this.defaultLovValue = defaultLovValue;
	}

	public Object getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(Object defaultValue) {
		this.defaultValue = defaultValue;
	}

	@Override
	public FlexField clone() throws CloneNotSupportedException {
		return (FlexField) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("systemName", this.getSystemName());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		result.put("instId", this.getInstId());
		result.put("entityType", this.getEntityType());
		result.put("objectType", this.getObjectType());
		result.put("dataType", this.getDataType());
		result.put("lovId", this.getLovId());
		result.put("defaultCharValue", this.getDefaultCharValue());
		result.put("defaultNumberValue", this.getDefaultNumberValue());
		result.put("defaultDateValue", this.getDefaultDateValue());
		
		return result;
	}
}

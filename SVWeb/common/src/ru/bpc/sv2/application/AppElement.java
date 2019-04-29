package ru.bpc.sv2.application;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AppElement extends Parameter implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private String elementType;
	private Integer minLength;
	private Integer maxLength;
	private String minValue;
	private String maxValue;
	private String defaultValue;
	private boolean multiLang;
	private String entityType;
	private String editForm;
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getElementType() {
		return elementType;
	}

	public void setElementType(String elementType) {
		this.elementType = elementType;
	}
	
	public Integer getMinLength() {
		return minLength;
	}

	public void setMinLength(Integer minLength) {
		this.minLength = minLength;
	}

	public Integer getMaxLength() {
		return maxLength;
	}

	public void setMaxLength(Integer maxLength) {
		this.maxLength = maxLength;
	}

	public String getMinValue() {
		return minValue;
	}

	public void setMinValue(String minValue) {
		this.minValue = minValue;
	}

	public String getMaxValue() {
		return maxValue;
	}

	public void setMaxValue(String maxValue) {
		this.maxValue = maxValue;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public boolean isMultiLang() {
		return multiLang;
	}

	public void setMultiLang(boolean multiLang) {
		this.multiLang = multiLang;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Object getModelId() {
		return getId();
	}

	public String getEditForm() {
		return editForm;
	}

	public void setEditForm(String editForm) {
		this.editForm = editForm;
	}

	@Override
	public AppElement clone() throws CloneNotSupportedException {
		return (AppElement) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("elementType", this.getElementType());
		result.put("systemName", this.getSystemName());
		result.put("name", this.getName());
		result.put("dataType", this.getDataType());
		result.put("minLength", this.getMinLength());
		result.put("maxLength", this.getMaxLength());
		result.put("minValue", this.getMinValue());
		result.put("maxValue", this.getMaxValue());
		result.put("lovId", this.getLovId());
		result.put("defaultValue", this.getDefaultValue());
		result.put("multiLang", this.isMultiLang());
		result.put("entityType", this.getEntityType());
		result.put("editForm", this.getEditForm());
		
		return result;
	}

}

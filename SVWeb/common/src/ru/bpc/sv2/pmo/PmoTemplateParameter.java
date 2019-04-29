package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Host tab page.
 */
public class PmoTemplateParameter extends Parameter implements IAuditableObject, ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 9160260928538889903L;
	
	private Long id;
	private Integer paramId;
	private Long templateId;
	private String paramLabel;
	private String paramValue;
	private String oldParamValue;
	private Boolean fixed;
	private Boolean editable;
	
	
	public PmoTemplateParameter()
	{
	}

	public Object getModelId() {
		return getParamId(); 
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public String getParamLabel() {
		return paramLabel;
	}

	public void setParamLabel(String paramLabel) {
		this.paramLabel = paramLabel;
	}

	public String getParamValue() {
		return paramValue;
	}

	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}

	public Boolean getFixed() {
		return fixed;
	}

	public void setFixed(Boolean fixed) {
		this.fixed = fixed;
	}

	public Boolean getEditable() {
		return editable;
	}

	public void setEditable(Boolean editable) {
		this.editable = editable;
	}

	public String getOldParamValue() {
		return oldParamValue;
	}

	public void setOldParamValue(String oldParamValue) {
		this.oldParamValue = oldParamValue;
	}

	public Long getTemplateId() {
		return templateId;
	}

	public void setTemplateId(Long templateId) {
		this.templateId = templateId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("templateId", getTemplateId());
		result.put("paramId", getParamId());
		result.put("paramValue", getParamValue());
		return result;
	}

}
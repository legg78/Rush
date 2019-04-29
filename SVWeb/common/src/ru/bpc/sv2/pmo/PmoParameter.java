package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PmoParameter extends Parameter implements IAuditableObject, ModelIdentifiable, Serializable, Cloneable {
	private static final long serialVersionUID = 9160260928538889903L;

	private Integer id;
	private String pattern;
	private Integer tagId;
	private String tagName;
	private String paramFunction;

	public PmoParameter() {}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getPattern() {
		return pattern;
	}
	public void setPattern(String pattern) {
		this.pattern = pattern;
	}

	public Integer getTagId() {
		return tagId;
	}
	public void setTagId(Integer tagId) {
		this.tagId = tagId;
	}

	public String getTagName() {
		return tagName;
	}
	public void setTagName(String tagName) {
		this.tagName = tagName;
	}

	public String getParamFunction() {
		return paramFunction;
	}
	public void setParamFunction(String paramFunction) {
		this.paramFunction = paramFunction;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		PmoParameter clone = (PmoParameter) super.clone();
		clone.setId(id);
		clone.setPattern(pattern);
		clone.setTagId(tagId);
		clone.setTagName(tagName);
		clone.setParamFunction(paramFunction);
		return clone;
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("systemName", getSystemName());
		result.put("dataType", getDataType());
		result.put("lovId", getLovId());
		result.put("pattern", getPattern());
		result.put("tagId", getTagId());
		result.put("paramFunction", getParamFunction());
		result.put("name", getName());
		result.put("description", getDescription());
		result.put("lang", getLang());
		return result;
	}
}
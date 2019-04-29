package ru.bpc.sv2.survey.configuration;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class SurveyParameterEntity implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Long paramId;
	private String paramName;
	private String entityType;
	private String entityTypeName;
	private String lang;

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("paramName", getParamName());
		result.put("paramId", getParamId());
		result.put("entityType", getEntityType());
		result.put("lang", getLang());
		return result;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

	@Override
	public SurveyParameterEntity clone() throws CloneNotSupportedException {
		return (SurveyParameterEntity) super.clone();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Long getParamId() {
		return paramId;
	}

	public void setParamId(Long paramId) {
		this.paramId = paramId;
	}

	public String getParamName() {
		return paramName;
	}

	public void setParamName(String paramName) {
		this.paramName = paramName;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getEntityTypeName() {
		return entityTypeName;
	}

	public void setEntityTypeName(String entityTypeName) {
		this.entityTypeName = entityTypeName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}
}

package ru.bpc.sv2.survey.configuration;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class SurveyParameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private String paramName;
	private String name;
	private String description;
	private String dataType;
	private String dataTypeName;
	private Integer displayOrder;
	private Integer lovId;
	private String lovName;
	private Boolean multiSelect;
	private Boolean systemParam;
	private String tableName;
	private String lang;

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("paramName", getParamName());
		result.put("name", getName());
		result.put("description", getDescription());
		result.put("dataType", getDataType());
		result.put("displayOrder", getDisplayOrder());
		result.put("lovId", getLovId());
		result.put("multiSelect", getMultiSelect());
		result.put("systemParam", getSystemParam());
		result.put("tableName", getTableName());
		result.put("lang", getLang());
		return result;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

	@Override
	public SurveyParameter clone() throws CloneNotSupportedException {
		return (SurveyParameter) super.clone();
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

	public String getParamName() {
		return paramName;
	}

	public void setParamName(String paramName) {
		this.paramName = paramName;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getDataTypeName() {
		return dataTypeName;
	}

	public void setDataTypeName(String dataTypeName) {
		this.dataTypeName = dataTypeName;
	}

	public Integer getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(Integer displayOrder) {
		this.displayOrder = displayOrder;
	}

	public Integer getLovId() {
		return lovId;
	}

	public void setLovId(Integer lovId) {
		this.lovId = lovId;
	}

	public Boolean getMultiSelect() {
		return multiSelect;
	}

	public void setMultiSelect(Boolean multiSelect) {
		this.multiSelect = multiSelect;
	}

	public Boolean getSystemParam() {
		return systemParam;
	}

	public void setSystemParam(Boolean systemParam) {
		this.systemParam = systemParam;
	}

	public String getTableName() {
		return tableName;
	}

	public void setTableName(String tableName) {
		this.tableName = tableName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getLovName() {
		return lovName;
	}

	public void setLovName(String lovName) {
		this.lovName = lovName;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

}

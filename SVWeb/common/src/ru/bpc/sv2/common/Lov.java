package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Lov implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String dict;
	private String lovQuery;
	private String name;
	private String moduleCode;
	private String lang;
	private String sortMode;
	private String appearance;
	private String dataType;
	private Boolean parametrized;
	
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}

	public String getDict() {
		return dict;
	}

	public void setDict(String dict) {
		this.dict = dict;
	}

	public String getFullDictName() {
		if (dict != null) {
			return DictNames.MAIN_DICTIONARY + dict;
		}
		return "";
	}
	
	public String getLovQuery() {
		return lovQuery;
	}

	public void setLovQuery(String lovQuery) {
		this.lovQuery = lovQuery;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getModuleCode() {
		return moduleCode;
	}

	public void setModuleCode(String moduleCode) {
		this.moduleCode = moduleCode;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Object getModelId() {
		return getId();
	}

	public String getSortMode() {
		return sortMode;
	}

	public void setSortMode(String sortMode) {
		this.sortMode = sortMode;
	}

	public String getAppearance() {
		return appearance;
	}

	public void setAppearance(String appearance) {
		this.appearance = appearance;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public Boolean getParametrized() {
		return parametrized;
	}

	public void setParametrized(Boolean parametrized) {
		this.parametrized = parametrized;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("moduleCode", this.getModuleCode());
		result.put("dataType", this.getDataType());
		result.put("dict", this.getDict());
		result.put("lovQuery", this.getLovQuery());
		result.put("sortMode", this.getSortMode());
		result.put("appearance", this.getAppearance());
		result.put("parametrized", this.getParametrized());
		
		return result;
	}
	
}

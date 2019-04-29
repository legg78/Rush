package ru.bpc.sv2.rules;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class DspCondition implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject{
	private static final long serialVersionUID = 1L;
	
	 private Integer id;
	 private Integer  initRule;
	 private Integer  genRule ;
	 private Integer  funcOrder;
	 private Integer  modId;
	 private boolean  online;
	 private String name;
	 private String lang;
	 private String scaleType;
	  
	@Override
	public Object getModelId() {
		return getId();
	}
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getInitRule() {
		return initRule;
	}

	public void setInitRule(Integer initRule) {
		this.initRule = initRule;
	}

	public Integer getGenRule() {
		return genRule;
	}

	public void setGenRule(Integer genRule) {
		this.genRule = genRule;
	}

	public Integer getFuncOrder() {
		return funcOrder;
	}

	public void setFuncOrder(Integer funcOrder) {
		this.funcOrder = funcOrder;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public String getName() {
		return name;
	}

	public boolean isOnline() {
		return online;
	}

	public void setOnline(boolean online) {
		this.online = online;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getScaleType() {
		return scaleType;
	}

	public void setScaleType(String scaleType) {
		this.scaleType = scaleType;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("initRule", getInitRule());
		result.put("genRule", getGenRule());
		result.put("funcOrder", getFuncOrder());
		result.put("modId", getModId());
		result.put("online", isOnline());
		result.put("name", getName());
		return result;
	}


}

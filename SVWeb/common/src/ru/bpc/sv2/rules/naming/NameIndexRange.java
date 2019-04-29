package ru.bpc.sv2.rules.naming;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class NameIndexRange implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	protected Integer id;
	protected String algorithm;
	protected Long lowValue;
	protected Long highValue;
	protected Long currentValue;
	protected String name;
	protected String lang;
	protected String entityType;
	protected Integer instId;
	protected String instName;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getAlgorithm() {
		return algorithm;
	}

	public void setAlgorithm(String algorithm) {
		this.algorithm = algorithm;
	}

	public Long getLowValue() {
		return lowValue;
	}

	public void setLowValue(Long lowValue) {
		this.lowValue = lowValue;
	}

	public Long getHighValue() {
		return highValue;
	}

	public void setHighValue(Long highValue) {
		this.highValue = highValue;
	}

	public Long getCurrentValue() {
		return currentValue;
	}

	public void setCurrentValue(Long currentValue) {
		this.currentValue = currentValue;
	}

	public String getName() {
		return name;
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

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	@Override
	public NameIndexRange clone() throws CloneNotSupportedException{
		return (NameIndexRange)super.clone();		
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("entityType", getEntityType());
		result.put("algorithm", getAlgorithm());
		result.put("lowValue", getLowValue());
		result.put("highValue", getHighValue());
		result.put("currentValue", getCurrentValue());
		result.put("lang", getLang());
		result.put("name", getName());
		return result;
	}
	
}

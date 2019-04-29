package ru.bpc.sv2.rules.naming;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class NameIndexPool implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;
	
	private Long id;
	private Integer indexRangeId;
	private Long value;
	private Boolean isUsed;
	private Long lowValue;
	private Long highValue;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getIndexRangeId() {
		return indexRangeId;
	}

	public void setIndexRangeId(Integer indexRangeId) {
		this.indexRangeId = indexRangeId;
	}

	public Long getValue() {
		return value;
	}

	public void setValue(Long value) {
		this.value = value;
	}

	public Boolean getIsUsed() {
		return isUsed;
	}

	public void setIsUsed(Boolean isUsed) {
		this.isUsed = isUsed;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
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

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("indexRangeId", getIndexRangeId());
		result.put("lowValue", getLowValue());
		result.put("highValue", getHighValue());
		result.put("value", getValue());
		return result;
	}
}

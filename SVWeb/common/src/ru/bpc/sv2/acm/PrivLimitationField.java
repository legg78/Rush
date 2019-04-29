package ru.bpc.sv2.acm;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class PrivLimitationField implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject{

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer privLimitId;
	private String field;
	private String condition;
	private Integer labelId;
	private String label;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getPrivLimitId() {
		return privLimitId;
	}

	public void setPrivLimitId(Integer privLimitId) {
		this.privLimitId = privLimitId;
	}

	public String getField() {
		return field;
	}   

	public void setField(String field) {
		this.field = field;
	}

	public Integer getLabelId() {
		return labelId;
	}

	public void setLabelId(Integer labelId) {
		this.labelId = labelId;
	}

	public Object getModelId() {
		return getId();
	}


	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();

		result.put("id", getId());
		result.put("privLimitId", getPrivLimitId());
		result.put("field", getField());
		result.put("labelId", getLabelId());
		result.put("condition", getCondition());
		return result;
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}

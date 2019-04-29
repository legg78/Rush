package ru.bpc.sv2.rules;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcedureParam extends ModParam implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer procedureId;
	private Integer paramId;
			

	public Integer getProcedureId() {
		return procedureId;
	}

	public void setProcedureId(Integer procedureId) {
		this.procedureId = procedureId;
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	@Override
	public ProcedureParam clone() throws CloneNotSupportedException {
		return (ProcedureParam)super.clone();
	}
	
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("procedureId", getProcedureId());
		result.put("systemName", getSystemName());
		result.put("lovId", getLovId());
		result.put("displayOrder", getDisplayOrder());
		result.put("mandatory", getMandatory());
		result.put("paramId", getParamId());
		result.put("lang", getLang());
		result.put("name", getName());
		result.put("description", getDescription());
		return result;
	}
}

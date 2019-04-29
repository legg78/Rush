package ru.bpc.sv2.rules;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class RuleParam extends ProcedureParam implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer ruleId;
		
	public Object getModelId() {
//		final int prime = 31;
//		int result = 1;
//		result = prime * result + actionId.hashCode();
//		result = prime * result + paramId.hashCode();
//		return new Integer(result);
		return ruleId + "_" + getParamId();
	}

	public Integer getRuleId() {
		return ruleId;
	}

	public void setRuleId(Integer ruleId) {
		this.ruleId = ruleId;
	}

	@Override
	public RuleParam clone() throws CloneNotSupportedException {
		return (RuleParam)super.clone();
	}
	
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("ruleId", getRuleId());
		result.put("paramId", getParamId());
		result.put("valueV", getValueV());
		result.put("valueN", getValueN());
		result.put("valueD", getValueD());
		return result;
	}
}

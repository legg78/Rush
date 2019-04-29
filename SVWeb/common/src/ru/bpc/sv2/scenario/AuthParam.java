package ru.bpc.sv2.scenario;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AuthParam extends Parameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer paramId;
	private Integer stateId;
	private Integer scenarioId;
	private String defaultValue;
	private String parameterRole;
	private Integer stateSeqNum;
	
	public Object getModelId() {
		return hashCode();
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public Integer getStateId() {
		return stateId;
	}

	public void setStateId(Integer stateId) {
		this.stateId = stateId;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public String getParameterRole() {
		return parameterRole;
	}

	public void setParameterRole(String parameterRole) {
		this.parameterRole = parameterRole;
	}

	public Integer getStateSeqNum() {
		return stateSeqNum;
	}

	public void setStateSeqNum(Integer stateSeqNum) {
		this.stateSeqNum = stateSeqNum;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((paramId == null) ? 0 : paramId.hashCode());
		result = prime * result
				+ ((getSystemName() == null) ? 0 : getSystemName().hashCode());
		result = prime * result
				+ ((getValue() == null) ? 0 : getValue().hashCode());
		result = prime * result + ((stateId == null) ? 0 : stateId.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		AuthParam other = (AuthParam) obj;		
		if (paramId == null) {
			if (other.paramId != null)
				return false;
		} else if (!paramId.equals(other.paramId))
			return false;
		if (getSystemName() == null) {
			if (other.getSystemName() != null)
				return false;
		} else if (!getSystemName().equals(other.getSystemName()))
			return false;
		if (getValue() == null) {
			if (other.getValue() != null)
				return false;
		} else if (!getValue().equals(other.getValue()))
			return false;
		if (stateId == null) {
			if (other.stateId != null)
				return false;
		} else if (!stateId.equals(other.stateId))
			return false;
		return true;
	}

	public Integer getScenarioId() {
		return scenarioId;
	}

	public void setScenarioId(Integer scenarioId) {
		this.scenarioId = scenarioId;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("stateId", getStateId());
		result.put("paramId", getParamId());
		result.put("valueD", getValueD());
		result.put("valueN", getValueN());
		result.put("valueV", getValueV());
		return result;
	}

}

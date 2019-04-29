package ru.bpc.sv2.process;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class ProcessParameter extends Parameter implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer prcParamId;
	
	private String defaultValue;
	
	private boolean format = true;
	
	private Integer processId;
	private String execOrder;
	private String visualExecOrder;
	private Integer containerId;
	private Integer containerBindId;	
	private boolean force;
	private Integer procId;
	private Integer parentId;
	private String parentName;
	private String parentValue;
	private String parentType;
	
	public Object getModelId() {
		if (getPrcParamId() == null)
			return getId();
		
		return getPrcParamId() + "_" + containerId;
	}
	
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getDefaultValue() {
		return defaultValue;
	}
	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public Integer getProcessId() {
		return processId;
	}
	public void setProcessId(Integer processId) {
		this.processId = processId;
	}
	
	public Integer getContainerId() {
		return containerId;
	}
	public void setContainerId(Integer containerId) {
		this.containerId = containerId;
	}

	
	public Integer getPrcParamId() {
		return prcParamId;
	}
	public void setPrcParamId(Integer prcParamId) {
		this.prcParamId = prcParamId;
	}

	public boolean isForce() {
		return force;
	}
	public void setForce(boolean force) {
		this.force = force;
	}

	public Integer getContainerBindId() {
		return containerBindId;
	}
	public void setContainerBindId(Integer containerBindId) {
		this.containerBindId = containerBindId;
	}

	public boolean isFormat() {
		return format;
	}
	public void setFormat(boolean format) {
		this.format = format;
	}

	@Override
	public ProcessParameter clone() throws CloneNotSupportedException {
		return (ProcessParameter)super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("prcParamId", getPrcParamId());
		result.put("containerBindId", getContainerBindId());
		result.put("valueV", getValueV());
		result.put("valueN", getValueN());
		result.put("valueD", getValueD());
		result.put("systemName", getSystemName());
		result.put("dataType", getDataType());
		result.put("lovId", getLovId());
		result.put("description", getDescription());
		result.put("name", getName());
		result.put("lang", getLang());
		result.put("processId", getProcessId());
		result.put("displayOrder", getDisplayOrder());
		result.put("execOrder", getExecOrder());
		result.put("format", isFormat());
		result.put("mandatory", getMandatory());
		return result;
	}
	
	public String toString(){
		StringBuilder result = new StringBuilder();
		result.append(getName()).append(" ");
		if (getValueV() != null){
			result.append(getValueV()).append(" ");
		}else if (getValueN() != null){
			result.append(getValueN().toString()).append(" ");
		}else if (getValueD() != null){
			result.append(getValueD()).append(" ");
		}
		return result.toString();
	}

	public Integer getProcId() {
		return procId;
	}
	public void setProcId(Integer procId) {
		this.procId = procId;
	}

	public String getExecOrder() {
		return execOrder;
	}
	public void setExecOrder(String execOrder) {
		this.execOrder = execOrder;
	}

	public String getVisualExecOrder() {
		return visualExecOrder;
	}

	public void setVisualExecOrder(String visualExecOrder) {
		this.visualExecOrder = visualExecOrder;
	}

	public Integer getParentId() {
		return parentId;
	}

	public void setParentId(Integer parentId) {
		this.parentId = parentId;
	}

	public String getParentName() {
		return parentName;
	}

	public void setParentName(String parentName) {
		this.parentName = parentName;
	}

	public String getParentValue() {
		return parentValue;
	}

	public void setParentValue(String parentValue) {
		this.parentValue = parentValue;
	}

	public String getParentType() {
		return parentType;
	}

	public void setParentType(String parentType) {
		this.parentType = parentType;
	}
}

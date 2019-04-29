package ru.bpc.sv2.rules;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Rule implements Serializable, ModelIdentifiable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer ruleSetId;
	private Integer procedureId;
	private String procedureName;
	private String name;
	private Integer execOrder;
	private Integer seqNum;
	private String category;
	private String description;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getRuleSetId() {
		return ruleSetId;
	}

	public void setRuleSetId(Integer ruleSetId) {
		this.ruleSetId = ruleSetId;
	}

	public Integer getProcedureId() {
		return procedureId;
	}

	public void setProcedureId(Integer procedureId) {
		this.procedureId = procedureId;
	}

	public Integer getExecOrder() {
		return execOrder;
	}

	public void setExecOrder(Integer execOrder) {
		this.execOrder = execOrder;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getProcedureName() {
		return procedureName;
	}

	public void setProcedureName(String procedureName) {
		this.procedureName = procedureName;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("ruleSetId", getRuleSetId());
		result.put("procedureId", getProcedureId());
		result.put("execOrder", getExecOrder());
		return result;
	}

}

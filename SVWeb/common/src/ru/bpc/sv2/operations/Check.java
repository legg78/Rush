package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Check implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer checkGroupId;
	private String checkType;
	private Integer execOrder;
	private String checkGroupName;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getCheckGroupId() {
		return checkGroupId;
	}

	public void setCheckGroupId(Integer checkGroupId) {
		this.checkGroupId = checkGroupId;
	}

	public String getCheckType() {
		return checkType;
	}

	public void setCheckType(String checkType) {
		this.checkType = checkType;
	}

	public Integer getExecOrder() {
		return execOrder;
	}

	public void setExecOrder(Integer execOrder) {
		this.execOrder = execOrder;
	}

	public String getCheckGroupName() {
		return checkGroupName;
	}

	public void setCheckGroupName(String checkGroupName) {
		this.checkGroupName = checkGroupName;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("checkGroupId", getCheckGroupId());
		result.put("checkType", getCheckType());
		result.put("execOrder", getExecOrder());
		return result;
	}
}

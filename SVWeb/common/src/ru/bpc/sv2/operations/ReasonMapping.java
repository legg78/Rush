package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReasonMapping implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String operType;
	private String reasonDict;
	
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

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getReasonDict() {
		return reasonDict;
	}

	public void setReasonDict(String reasonDict) {
		this.reasonDict = reasonDict;
	}
	
	public boolean isAnyOperType() {
		// can be only "%", not null, not anything else
		return operType != null && "%".equals(operType);
	}

	@Override
	public ReasonMapping clone() throws CloneNotSupportedException {
		return (ReasonMapping) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("operType", getOperType());
		result.put("reasonDict", getReasonDict());
		return result;
	}
}

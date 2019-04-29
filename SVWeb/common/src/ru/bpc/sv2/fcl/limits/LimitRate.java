package ru.bpc.sv2.fcl.limits;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class LimitRate implements Serializable, IAuditableObject, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = -4665571321606984711L;

	private Integer id;
	private String seqNum;
	private String limitType;
	private String rateType;
	private Integer instId;
	private String instName;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}

	public String getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(String seqNum) {
		this.seqNum = seqNum;
	}

	public String getLimitType() {
		return limitType;
	}

	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public String getRateType() {
		return rateType;
	}

	public void setRateType(String rateType) {
		this.rateType = rateType;
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
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + id;
		result = prime * result + ((instId == null) ? 0 : instId.hashCode());
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
		LimitRate other = (LimitRate) obj;
		if (id != other.id)
			return false;
		return true;
	}

	@Override
	public LimitRate clone() throws CloneNotSupportedException {
		
		return (LimitRate) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("limitType", getLimitType());
		result.put("rateType", getRateType());
		result.put("instId", getInstId());
		return result;
	}
}

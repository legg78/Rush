package ru.bpc.sv2.fcl.fees;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Fee implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = -4665571321606984711L;

	private Integer id;
	private Integer seqnum;
	private String feeType;
	private String currency;
	private String feeRateCalc;
	private String feeBaseCalc;
	private Integer cycleId;
	private Long limitId;
	private Integer instId;
	private String entityType;
	private String cycleType;
	private String limitType;
	private String description;
	private String instName;
	private String statusReason;

	public Fee() {}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	
	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getFeeRateCalc() {
		return feeRateCalc;
	}

	public void setFeeRateCalc(String feeRateCalc) {
		this.feeRateCalc = feeRateCalc;
	}

	public String getFeeBaseCalc() {
		return feeBaseCalc;
	}

	public void setFeeBaseCalc(String feeBaseCalc) {
		this.feeBaseCalc = feeBaseCalc;
	}

	public Integer getCycleId() {
		return cycleId;
	}

	public void setCycleId(Integer cycleId) {
		this.cycleId = cycleId;
	}

	public Long getLimitId() {
		return limitId;
	}

	public void setLimitId(Long limitId) {
		this.limitId = limitId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Object getModelId()
	{
		return getId();
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getCycleType() {
		return cycleType;
	}

	public void setCycleType(String cycleType) {
		this.cycleType = cycleType;
	}

	public String getLimitType() {
		return limitType;
	}

	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("feeType", this.getFeeType());
		result.put("entityType", this.getEntityType());
		result.put("currency", this.getCurrency());
		result.put("feeBaseCalc", this.getFeeBaseCalc());
		result.put("feeRateCalc", this.getFeeRateCalc());
		result.put("limitType", this.getLimitType());
		result.put("limitId", this.getLimitId());
		result.put("cycleType", this.getCycleType());
		result.put("cycleId", this.getCycleId());
		result.put("instId", this.getInstId());
		
		return result;
	}
}
package ru.bpc.sv2.fcl.cycles;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Cycle implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1169256089606441924L;

	private Integer	id;
	private String	seqNum;
	private String	cycleType;
	private String 	lengthType;
	private String 	truncType;
	private Integer cycleLength;
	private Integer instId;
	private String instName;
	private String description;
	private Boolean workdays;
	private String statusReason;

	public Cycle() {}

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

	public String getCycleType() {
		return cycleType;
	}

	public void setCycleType(String cycleType) {
		this.cycleType = cycleType;
	}

	public String getLengthType() {
		return lengthType;
	}

	public void setLengthType(String lengthType) {
		this.lengthType = lengthType;
	}

	public String getTruncType() {
		return truncType;
	}

	public void setTruncType(String truncType) {
		this.truncType = truncType;
	}

	public Integer getCycleLength() {
		return cycleLength;
	}

	public void setCycleLength(Integer cycleLength) {
		this.cycleLength = cycleLength;
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

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Boolean getWorkdays() {
		return workdays;
	}

	public void setWorkdays(Boolean workdays) {
		this.workdays = workdays;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	public Cycle copy() {
		Cycle copy = new Cycle();
		copy.setId(id);
		copy.setSeqNum(seqNum);
		copy.setCycleType(cycleType);
		copy.setLengthType(lengthType);
		copy.setTruncType(truncType);
		copy.setCycleLength(cycleLength);
		copy.setInstId(instId);
		copy.setInstName(instName);
		copy.setDescription(description);
		
		return copy;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Cycle clone() throws CloneNotSupportedException {
		return (Cycle)super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("cycleType", getCycleType());
		result.put("lengthType", getLengthType());
		result.put("cycleLength", getCycleLength());
		result.put("truncType", getTruncType());
		result.put("instId", getInstId());
		return result;
	}
}
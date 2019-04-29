package ru.bpc.sv2.fcl.cycles;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CycleShift implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject
{
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 4808715205725555143L;
	private Integer	id;
	private Integer	seqnum;
	private Integer	cycleId;
	private String shiftType;
	private Integer priority;
	private Integer shiftSign;
	private String lengthType;
	private Integer shiftLength;

	public Object getModelId(){
		return getId();
	}
	
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

	public Integer getCycleId() {
		return cycleId;
	}

	public void setCycleId(Integer cycleId) {
		this.cycleId = cycleId;
	}

	public String getShiftType() {
		return shiftType;
	}

	public void setShiftType(String shiftType) {
		this.shiftType = shiftType;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public Integer getShiftSign() {
		return shiftSign;
	}

	public void setShiftSign(Integer shiftSign) {
		this.shiftSign = shiftSign;
	}

	public String getShiftLiteralSign() {
		return shiftSign > 0 ? "+" : "-";
	}
	
	public String getLengthType() {
		return lengthType;
	}

	public void setLengthType(String lengthType) {
		this.lengthType = lengthType;
	}

	public Integer getShiftLength() {
		return shiftLength;
	}

	public void setShiftLength(Integer shiftLength) {
		this.shiftLength = shiftLength;
	}

	@Override
	public CycleShift clone() throws CloneNotSupportedException {
		return (CycleShift)super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("issInstId", getCycleId());
		result.put("issNetworkId", getShiftType());
		result.put("modId", getPriority());
		result.put("priority", getShiftSign());
		result.put("sttlType", getLengthType());
		result.put("matchStatus", getShiftLength());
		return result;
	}
}
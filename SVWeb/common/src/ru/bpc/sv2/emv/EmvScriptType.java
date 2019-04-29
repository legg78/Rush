package ru.bpc.sv2.emv;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

@SuppressWarnings("serial")
public class EmvScriptType implements Serializable, ModelIdentifiable,Cloneable, IAuditableObject {

	private Long id;
	private Long seqNum;
	private String type = null;
	private int priority;
	private Boolean mac;
	private Boolean tag71;
	private Boolean tag72;
	private String condition = null;
	private Boolean retransmission;
	private Long repeatCount;
	private String classByte = null;
	private String instructionByte = null;
	private String parameter1 = null;
	private String parameter2= null;
	private Boolean reqLengthData;
	private Boolean isUsedByUser;
	private String formUrl = null;
	private String scriptTypeName = null;
	private String lang = null;

	public Object getModelId() {
		return getId();
	}
	
	public Long getId() {
		return id;
	}
	
	public void setId(Long id){
		this.id = id;
	}

	public Long getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Long seqNum) {
		this.seqNum = seqNum;
	}

	public int getPriority() {
		return priority;
	}

	public void setPriority(int priority) {
		this.priority = priority;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	

	public Long getRepeatCount() {
		return repeatCount;
	}

	public void setRepeatCount(Long repeatCount) {
		this.repeatCount = repeatCount;
	}

	public String getClassByte() {
		return classByte;
	}

	public void setClassByte(String classByte) {
		this.classByte = classByte;
	}

	public String getInstructionByte() {
		return instructionByte;
	}

	public void setInstructionByte(String instructionByte) {
		this.instructionByte = instructionByte;
	}

	public String getParameter1() {
		return parameter1;
	}

	public void setParameter1(String parameter1) {
		this.parameter1 = parameter1;
	}
	
	public String getParameter2() {
		return parameter2;
	}

	public void setParameter2(String parameter2) {
		this.parameter2 = parameter2;
	}
	

	public String getFormUrl() {
		return formUrl;
	}

	public void setFormUrl(String formUrl) {
		this.formUrl = formUrl;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getScriptTypeName() {
		return scriptTypeName;
	}

	public void setScriptTypeName(String scriptTypeName) {
		this.scriptTypeName = scriptTypeName;
	}

	public Boolean getMac() {
		return mac;
	}

	public void setMac(Boolean mac) {
		this.mac = mac;
	}

	public Boolean getTag71() {
		return tag71;
	}

	public void setTag71(Boolean tag71) {
		this.tag71 = tag71;
	}

	public Boolean getTag72() {
		return tag72;
	}

	public void setTag72(Boolean tag72) {
		this.tag72 = tag72;
	}

	public Boolean getRetransmission() {
		return retransmission;
	}

	public void setRetransmission(Boolean retransmission) {
		this.retransmission = retransmission;
	}

	public Boolean getIsUsedByUser() {
		return isUsedByUser;
	}

	public void setIsUsedByUser(Boolean isUsedByUser) {
		this.isUsedByUser = isUsedByUser;
	}

	public Boolean getReqLengthData() {
		return reqLengthData;
	}

	public void setReqLengthData(Boolean reqLengthData) {
		this.reqLengthData = reqLengthData;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("type", this.getType());
		result.put("priority", this.getPriority());
		result.put("mac", this.getMac());
		result.put("tag71", this.getTag71());
		result.put("tag72", this.getTag72());
		result.put("condition", this.getCondition());
		result.put("retransmission", this.getRetransmission());
		result.put("repeatCount", this.getRepeatCount());
		result.put("classByte", this.getClassByte());
		result.put("instructionByte", this.getInstructionByte());
		result.put("parameter1", this.getParameter1());
		result.put("parameter2", this.getParameter2());
		result.put("reqLengthData", this.getReqLengthData());
		result.put("isUsedByUser", this.getIsUsedByUser());
		result.put("formUrl", this.getFormUrl());
		
		return result;
	}
		
}

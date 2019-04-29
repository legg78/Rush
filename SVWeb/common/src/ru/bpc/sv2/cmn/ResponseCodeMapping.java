package ru.bpc.sv2.cmn;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ResponseCodeMapping implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Long standardId;
	private String respCode;
	private String deviceCodeIn;
	private String deviceCodeOut;
	private String respReason;
	
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

	public Long getStandardId() {
		return standardId;
	}

	public void setStandardId(Long standardId) {
		this.standardId = standardId;
	}

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}

	public String getDeviceCodeIn() {
		return deviceCodeIn;
	}

	public void setDeviceCodeIn(String deviceCodeIn) {
		this.deviceCodeIn = deviceCodeIn;
	}

	public String getDeviceCodeOut() {
		return deviceCodeOut;
	}

	public void setDeviceCodeOut(String deviceCodeOut) {
		this.deviceCodeOut = deviceCodeOut;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		
		return super.clone();
	}

	public String getRespReason() {
		return respReason;
	}

	public void setRespReason(String respReason) {
		this.respReason = respReason;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("respCode", this.getRespCode());
		result.put("respReason", this.getRespReason());
		result.put("standardId", this.getStandardId());
		result.put("deviceCodeOut", this.getDeviceCodeOut());
		result.put("deviceCodeIn", this.getDeviceCodeIn());
		
		return result;
	}

}

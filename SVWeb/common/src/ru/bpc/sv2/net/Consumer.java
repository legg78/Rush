package ru.bpc.sv2.net;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Consumer implements Serializable, IAuditableObject, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer hostMemberId;
	private Integer consumerMemberId;
	private Integer consumerInstId;
	private String consumerInstName;
	private Integer mspMemberId;
	private String mspInstName;
	private String lang;
	
	public Object getModelId() {
		return id;
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
	
	public Integer getHostMemberId() {
		return hostMemberId;
	}

	public void setHostMemberId(Integer hostMemberId) {
		this.hostMemberId = hostMemberId;
	}

	public String getConsumerInstName() {
		return consumerInstName;
	}

	public void setConsumerInstName(String consumerInstName) {
		this.consumerInstName = consumerInstName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getConsumerMemberId() {
		return consumerMemberId;
	}

	public void setConsumerMemberId(Integer consumerMemberId) {
		this.consumerMemberId = consumerMemberId;
	}

	public Integer getMspMemberId() {
		return mspMemberId;
	}

	public void setMspMemberId(Integer mspMemberId) {
		this.mspMemberId = mspMemberId;
	}

	public String getMspInstName() {
		return mspInstName;
	}

	public void setMspInstName(String mspInstName) {
		this.mspInstName = mspInstName;
	}

	public Integer getConsumerInstId() {
		return consumerInstId;
	}

	public void setConsumerInstId(Integer consumerInstId) {
		this.consumerInstId = consumerInstId;
	}

	@Override
	public Consumer clone() throws CloneNotSupportedException {
		return (Consumer) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("hostMemberId", getHostMemberId());
		result.put("consumerMemberId", getConsumerMemberId());
		result.put("mspMemberId", getMspMemberId());
		return result;
	}

}

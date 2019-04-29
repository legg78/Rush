package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CheckSelection implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String operType;
	private String msgType;
	private String partyType;
	private String instId;
	private String networkId;
	private Integer checkGroupId;
	private Integer execOrder;
	private String checkGroupName;
	private String instName;
	private String networkName;
	
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

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getPartyType() {
		return partyType;
	}

	public void setPartyType(String partyType) {
		this.partyType = partyType;
	}

	public String getInstId() {
		return instId;
	}

	public void setInstId(String instId) {
		this.instId = instId;
	}

	public String getNetworkId() {
		return networkId;
	}

	public void setNetworkId(String networkId) {
		this.networkId = networkId;
	}

	public Integer getCheckGroupId() {
		return checkGroupId;
	}

	public void setCheckGroupId(Integer checkGroupId) {
		this.checkGroupId = checkGroupId;
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

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getNetworkName() {
		return networkName;
	}

	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	public boolean isAnyInst() {
		// can be only "%", not null, not anything else
		return instId != null && "%".equals(instId);
	}
	
	public boolean isAnyMsgType() {
		// can be only "%", not null, not anything else
		return msgType != null && "%".equals(msgType);
	}

	public boolean isAnyNetwork() {
		// can be only "%", not null, not anything else
		return networkId != null && "%".equals(networkId);
	}

	public boolean isAnyOperType() {
		// can be only "%", not null, not anything else
		return operType != null && "%".equals(operType);
	}

	public boolean isAnyPartyType() {
		// can be only "%", not null, not anything else
		return partyType != null && "%".equals(partyType);
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("operType", getOperType());
		result.put("msgType", getMsgType());
		result.put("partyType", getPartyType());
		result.put("instId", getInstId());
		result.put("networkId", getNetworkId());
		result.put("checkGroupId", getCheckGroupId());
		result.put("execOrder", getExecOrder());
		return result;
	}
}

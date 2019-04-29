package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class SelectionPriority implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;
	public static final String ANY = "%";

	private Integer id;
	private Integer seqNum;
	private String operType;
	private String accountType;
	private String accountStatus;
	private String accountCurrency;
	private Integer priority;
	private String instId;
	private String instName;
	private String partyType;
	private String msgType;
	private Integer modifierId;
	private String modifierName;

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

	public String getAccountType() {
		return accountType;
	}
	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public String getAccountStatus() {
		return accountStatus;
	}
	public void setAccountStatus(String accountStatus) {
		this.accountStatus = accountStatus;
	}

	public String getAccountCurrency() {
		return accountCurrency;
	}
	public void setAccountCurrency(String accountCurrency) {
		this.accountCurrency = accountCurrency;
	}

	public boolean isAnyAccountCurrency(){
		return ANY.equals(accountCurrency);
	}

	public Integer getPriority() {
		return priority;
	}
	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getInstId() {
		return instId;
	}
	public void setInstId(String instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getPartyType() {
		return partyType;
	}
	public void setPartyType(String partyType) {
		this.partyType = partyType;
	}

	public String getMsgType() {
		return msgType;
	}
	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public Integer getModifierId() {
		return modifierId;
	}
	public void setModifierId(Integer modifierId) {
		this.modifierId = modifierId;
	}

	public String getModifierName() {
		return modifierName;
	}
	public void setModifierName(String modifierName) {
		this.modifierName = modifierName;
	}

	public boolean isAnyInst() {
		return "%".equals(instId);
	}
	public boolean isAnyOperType() {
		return "%".equals(operType);
	}
	public boolean isAnyAccountType() {
		return "%".equals(accountType);
	}
	public boolean isAnyAccountStatus() {
		return "%".equals(accountStatus);
	}
	public boolean isAnyPartyType() {
		return "%".equals(partyType);
	}
	public boolean isAnyMsgType() {
		return "%".equals(msgType);
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("operType", this.getOperType());
		result.put("accountType", this.getAccountType());
		result.put("accountStatus", this.getAccountStatus());
		result.put("accountCurrency", this.getAccountCurrency());
		result.put("priority", this.getPriority());
		result.put("partyType", this.getPartyType());
		result.put("msgType", this.getMsgType());
		result.put("modifierId", this.getModifierId());
		return result;
	}
}

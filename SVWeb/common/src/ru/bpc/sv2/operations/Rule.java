package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

// TODO: as it uses view with name "RULE_SELECTION" and it's accessed via 
// menu item named "Processing templates" may be it should be renamed to 
// some more appropriate name to avoid confusion. 
public class Rule implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String msgType;
	private String procStage;
	private String sttlType;
	private String operType;
	private String operReason;
	private String reversal;
	private String issInstId;
	private String acqInstId;
	private String terminalType;
	private String operCurrency;
	private String accountCurrency;
	private String sttlCurrency;
	private Integer modId;
	private String modName;
	private Integer ruleSetId;
	private Integer execOrder;
	private String ruleSetName;
	private String issInstName;
	private String acqInstName;
	
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

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getProcStage() {
		return procStage;
	}

	public void setProcStage(String procStage) {
		this.procStage = procStage;
	}

	public String getSttlType() {
		return sttlType;
	}

	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getOperReason() {
		return operReason;
	}

	public void setOperReason(String operReason) {
		this.operReason = operReason;
	}

	public String getReversal() {
		return reversal;
	}

	public void setReversal(String reversal) {
		this.reversal = reversal;
	}

	public String getIssInstId() {
		return issInstId;
	}

	public void setIssInstId(String issInstId) {
		this.issInstId = issInstId;
	}

	public String getAcqInstId() {
		return acqInstId;
	}

	public void setAcqInstId(String acqInstId) {
		this.acqInstId = acqInstId;
	}

	public String getTerminalType() {
		return terminalType;
	}

	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}

	public String getOperCurrency() {
		return operCurrency;
	}

	public void setOperCurrency(String operCurrency) {
		this.operCurrency = operCurrency;
	}

	public String getAccountCurrency() {
		return accountCurrency;
	}

	public void setAccountCurrency(String accountCurrency) {
		this.accountCurrency = accountCurrency;
	}

	public String getSttlCurrency() {
		return sttlCurrency;
	}

	public void setSttlCurrency(String sttlCurrency) {
		this.sttlCurrency = sttlCurrency;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public Integer getRuleSetId() {
		return ruleSetId;
	}

	public void setRuleSetId(Integer ruleSetId) {
		this.ruleSetId = ruleSetId;
	}

	public Integer getExecOrder() {
		return execOrder;
	}

	public void setExecOrder(Integer execOrder) {
		this.execOrder = execOrder;
	}

	public String getRuleSetName() {
		return ruleSetName;
	}

	public void setRuleSetName(String ruleSetName) {
		this.ruleSetName = ruleSetName;
	}

	public String getIssInstName() {
		return issInstName;
	}

	public void setIssInstName(String issInstName) {
		this.issInstName = issInstName;
	}

	public String getAcqInstName() {
		return acqInstName;
	}

	public void setAcqInstName(String acqInstName) {
		this.acqInstName = acqInstName;
	}

	public String getModName() {
		return modName;
	}

	public void setModName(String modName) {
		this.modName = modName;
	}

	public boolean isAnyOperType() {
		// can be only "%", not null, not anything else
		return operType != null && "%".equals(operType);
	}
	
	public boolean isAnyMsgType() {
		// can be only "%", not null, not anything else
		return msgType != null && "%".equals(msgType);
	}
	
	public boolean isAnySttlType() {
		// can be only "%", not null, not anything else
		return sttlType != null && "%".equals(sttlType);
	}

	public boolean isAnyIssInst() {
		// can be only "%", not null, not anything else
		return issInstId != null && "%".equals(issInstId);
	}
	
	public boolean isAnyAcqInst() {
		// can be only "%", not null, not anything else
		return acqInstId != null && "%".equals(acqInstId);
	}

	public boolean isAnyOperCurrency() {
		// can be only "%", not null, not anything else
		return operCurrency != null && "%".equals(operCurrency);
	}

	public boolean isAnyAccountCurrency() {
		// can be only "%", not null, not anything else
		return accountCurrency != null && "%".equals(accountCurrency);
	}

	public boolean isAnySttlCurrency() {
		// can be only "%", not null, not anything else
		return sttlCurrency != null && "%".equals(sttlCurrency);
	}

	public boolean isAnyOperReason() {
		// can be only "%", not null, not anything else
		return operReason != null && "%".equals(operReason);
	}

	public boolean isAnyTerminalType() {
		// can be only "%", not null, not anything else
		return terminalType != null && "%".equals(terminalType);
	}

	@Override
	public Rule clone() throws CloneNotSupportedException {
		return (Rule)super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("msgType", getMsgType());
		result.put("procStage", getProcStage());
		result.put("acqInstId", getAcqInstId());
		result.put("sttlType", getSttlType());
		result.put("operType", getOperType());
		result.put("operReason", getOperReason());
		result.put("reversal", getReversal());
		result.put("issInstId", getIssInstId());
		result.put("acqInstId", getAcqInstId());
		result.put("terminalType", getTerminalType());
		result.put("operCurrency", getOperCurrency());
		result.put("accountCurrency", getAccountCurrency());
		result.put("sttlCurrency", getSttlCurrency());
		result.put("modId", getModId());
		result.put("ruleSetId", getRuleSetId());
		result.put("execOrder", getExecOrder());
		return result;
	}
}

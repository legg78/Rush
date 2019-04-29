package ru.bpc.sv2.net;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class HostSubstitution implements Cloneable, ModelIdentifiable, Serializable, IAuditableObject {
	private static final long serialVersionUID = 1L;
	
	public static final String ANY = "%";
	
	private Long id;
	private Integer seqNum;
	private String operType;
	private String terminalType;
	private String panLow;
	private String panHigh;
	private String acqInstId;
	private String acqNetworkId;
	private String cardInstId;
	private String cardNetworkId;
	private String issInstId;
	private String issNetworkId;
	private Integer priority;
	private String substitutionInstId;
	private String substitutionNetworkId;
	private String acqInstName;
	private String acqNetworkName;
	private String cardInstName;
	private String cardNetworkName;
	private String issInstName;
	private String issNetworkName;
	private String substitutionInstName;
	private String substitutionNetworkName;
	private String lang;
	private String operationCurrency;
	private String messageType;
	private String merchantArrayId;
	private String terminalArrayId;
	private String operationReason;
    private String cardCountry;
	
	@Override
	public Object getModelId() {
		return id;
	}
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
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

	public String getTerminalType() {
		return terminalType;
	}

	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}

	public String getPanLow() {
		return panLow;
	}

	public void setPanLow(String panLow) {
		this.panLow = panLow;
	}

	public String getPanHigh() {
		return panHigh;
	}

	public void setPanHigh(String panHigh) {
		this.panHigh = panHigh;
	}

	public String getAcqInstId() {
		return acqInstId;
	}

	public void setAcqInstId(String acqInstId) {
		this.acqInstId = acqInstId;
	}

	public String getAcqNetworkId() {
		return acqNetworkId;
	}

	public void setAcqNetworkId(String acqNetworkId) {
		this.acqNetworkId = acqNetworkId;
	}

	public String getCardInstId() {
		return cardInstId;
	}

	public void setCardInstId(String cardInstId) {
		this.cardInstId = cardInstId;
	}

	public String getCardNetworkId() {
		return cardNetworkId;
	}

	public void setCardNetworkId(String cardNetworkId) {
		this.cardNetworkId = cardNetworkId;
	}

	public String getIssInstId() {
		return issInstId;
	}

	public void setIssInstId(String issInstId) {
		this.issInstId = issInstId;
	}

	public String getIssNetworkId() {
		return issNetworkId;
	}

	public void setIssNetworkId(String issNetworkId) {
		this.issNetworkId = issNetworkId;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getSubstitutionInstId() {
		return substitutionInstId;
	}

	public void setSubstitutionInstId(String substitutionInstId) {
		this.substitutionInstId = substitutionInstId;
	}

	public String getSubstitutionNetworkId() {
		return substitutionNetworkId;
	}

	public void setSubstitutionNetworkId(String substitutionNetworkId) {
		this.substitutionNetworkId = substitutionNetworkId;
	}

	public String getAcqInstName() {
		return acqInstName;
	}

	public void setAcqInstName(String acqInstName) {
		this.acqInstName = acqInstName;
	}

	public String getAcqNetworkName() {
		return acqNetworkName;
	}

	public void setAcqNetworkName(String acqNetworkName) {
		this.acqNetworkName = acqNetworkName;
	}

	public String getCardInstName() {
		return cardInstName;
	}

	public void setCardInstName(String cardInstName) {
		this.cardInstName = cardInstName;
	}

	public String getCardNetworkName() {
		return cardNetworkName;
	}

	public void setCardNetworkName(String cardNetworkName) {
		this.cardNetworkName = cardNetworkName;
	}

	public String getIssInstName() {
		return issInstName;
	}

	public void setIssInstName(String issInstName) {
		this.issInstName = issInstName;
	}

	public String getIssNetworkName() {
		return issNetworkName;
	}

	public void setIssNetworkName(String issNetworkName) {
		this.issNetworkName = issNetworkName;
	}

	public String getSubstitutionInstName() {
		return substitutionInstName;
	}

	public void setSubstitutionInstName(String substitutionInstName) {
		this.substitutionInstName = substitutionInstName;
	}

	public String getSubstitutionNetworkName() {
		return substitutionNetworkName;
	}

	public void setSubstitutionNetworkName(String substitutionNetworkName) {
		this.substitutionNetworkName = substitutionNetworkName;
	}
	
	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public boolean isAnyOperType() {
		return ANY.equals(operType);
	}
	
	public boolean isAnyTerminalType() {
		return ANY.equals(terminalType);
	}

	public boolean isAnyAcqInst() {
		return ANY.equals(acqInstId);
	}
	
	public boolean isAnyAcqNetwork() {
		return ANY.equals(acqNetworkId);
	}

	public boolean isAnyCardInst() {
		return ANY.equals(cardInstId);
	}

	public boolean isAnyCardNetwork() {
		return ANY.equals(cardNetworkId);
	}

	public boolean isAnyIssInst() {
		return ANY.equals(issInstId);
	}
	
	public boolean isAnyIssNetwork() {
		return ANY.equals(issNetworkId);
	}
	
	public boolean isAnyMessageType() {
		return ANY.equals(messageType);
	}
	
	public boolean isAnyOperationReason(){
		return ANY.equals(operationReason);
	}
	
	public boolean isAnyOperationCurrency(){
		return ANY.equals(operationCurrency);
	}
	
	public boolean isAnyMerchantArrayId(){
		return ANY.equals(merchantArrayId);
	}
	
	public boolean isAnyTerminalArrayId(){
		return ANY.equals(terminalArrayId);
	}

	public boolean isAnySubstitutionInst() {
		return ANY.equals(substitutionInstId);
	}

	public boolean isAnySubstitutionNetwork() {
		return ANY.equals(substitutionNetworkId);
	}
	
	public boolean isAnyCardCountry() {
		return ANY.equals(cardCountry);
	}

    public String getCardCountry() {
        return cardCountry;
    }

    public void setCardCountry(String cardCountry) {
        this.cardCountry = cardCountry;
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
		result.put("terminalType", getTerminalType());
		result.put("panLow", getPanLow());
		result.put("panHigh", getPanHigh());
		result.put("acqNetworkId", getAcqNetworkId());
		result.put("acqInstId", getAcqInstId());
		result.put("cardNetworkId", getCardNetworkId());
		result.put("cardInstId", getCardInstId());
		result.put("priority", getPriority());
		result.put("issNetworkId", getIssNetworkId());
		result.put("issInstId", getIssInstId());
		result.put("substitutionNetworkId", getSubstitutionNetworkId());
		result.put("substitutionInstId", getSubstitutionInstId());
		result.put("operationCurrency", getOperationCurrency());
		result.put("operationReason", getOperationReason());
		result.put("messageType", getMessageType());
		result.put("merchantArrayId", getMerchantArrayId());
		result.put("terminalArrayId", getTerminalArrayId());
		return result;
	}

	public String getOperationCurrency() {
		return operationCurrency;
	}

	public void setOperationCurrency(String operationCurrency) {
		this.operationCurrency = operationCurrency;
	}

	public String getMessageType() {
		return messageType;
	}

	public void setMessageType(String messageType) {
		this.messageType = messageType;
	}

	public String getMerchantArrayId() {
		return merchantArrayId;
	}

	public void setMerchantArrayId(String merchantArrayId) {
		this.merchantArrayId = merchantArrayId;
	}

	public String getTerminalArrayId() {
		return terminalArrayId;
	}

	public void setTerminalArrayId(String terminalArrayId) {
		this.terminalArrayId = terminalArrayId;
	}

	public String getOperationReason() {
		return operationReason;
	}

	public void setOperationReason(String operationReason) {
		this.operationReason = operationReason;
	}
}

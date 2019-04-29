package ru.bpc.sv2.acquiring;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class BillingScheme implements Serializable, ModelIdentifiable, Cloneable {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer productId;
	private String operType;
	private String currency;
	private String merchantType;
	private String accountType;
	private Integer seqNum;
	private String reason;
	private String sttlType;
	private String terminalType;
	private Integer operSign;
	private Integer priority;
	private Integer instId;
	private String description;
	private String lang;
	
	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getMerchantType() {
		return merchantType;
	}

	public void setMerchantType(String merchantType) {
		this.merchantType = merchantType;
	}

	public String getAccountType() {
		return accountType;
	}

	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getReason() {
		return reason;
	}

	public void setReason(String reason) {
		this.reason = reason;
	}

	public String getSttlType() {
		return sttlType;
	}

	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}

	public String getTerminalType() {
		return terminalType;
	}

	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}

	public Integer getOperSign() {
		return operSign;
	}

	public void setOperSign(Integer operSign) {
		this.operSign = operSign;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public Object getModelId() {
		return getId();
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}

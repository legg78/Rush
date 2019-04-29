package ru.bpc.sv2.acquiring;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AccountPattern implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private Integer schemeId;
	private String operType;
	private String operReason;
	private String sttlType;
	private String terminalType;
	private String currency;
	private Byte operSign;
	private String merchantType;
	private String accountType;
	private String accountCurrency;
	private Integer priority;
	private String schemeName;
	
	public Object getModelId() {
		return getId();
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

	public Integer getSchemeId() {
		return schemeId;
	}

	public void setSchemeId(Integer schemeId) {
		this.schemeId = schemeId;
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

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Byte getOperSign() {
		return operSign;
	}

	public void setOperSign(Byte operSign) {
		this.operSign = operSign;
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

	public String getAccountCurrency() {
		return accountCurrency;
	}

	public void setAccountCurrency(String accountCurrency) {
		this.accountCurrency = accountCurrency;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getSchemeName() {
		return schemeName;
	}

	public void setSchemeName(String schemeName) {
		this.schemeName = schemeName;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public boolean isAnyOperReason() {
		return "%".equals(operReason);
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("operType", this.getOperType());
		result.put("operReason", this.getOperReason());
		result.put("sttlType", this.getSttlType());
		result.put("terminalType", this.getTerminalType());
		result.put("currency", this.getCurrency());
		result.put("operSign", this.getOperSign());
		result.put("merchantType", this.getMerchantType());
		result.put("accountType", this.getAccountType());
		result.put("accountCurrency", this.getAccountCurrency());
		result.put("priority", this.getPriority());
		
		return result;
	}
}

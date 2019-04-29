package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class BalanceType implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable{
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String accountType;
	private String balanceType;
	private Integer instId;
	private String currency;
	private Integer avalImpact;
	private String status;
	private Integer seqNum;
	private String rateType;
	private Integer numberFormatId;
	private String numberFormatName;
	private String numberPrefix;
	private Integer updateMacrosType;
	private String balanceAlgorithm;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getAccountType() {
		return accountType;
	}

	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public String getBalanceType() {
		return balanceType;
	}

	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Integer getAvalImpact() {
		return avalImpact;
	}

	public void setAvalImpact(Integer avalImpact) {
		this.avalImpact = avalImpact;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getRateType() {
		return rateType;
	}

	public void setRateType(String rateType) {
		this.rateType = rateType;
	}

	public Integer getNumberFormatId() {
		return numberFormatId;
	}

	public void setNumberFormatId(Integer numberFormatId) {
		this.numberFormatId = numberFormatId;
	}

	public String getNumberFormatName() {
		return numberFormatName;
	}

	public void setNumberFormatName(String numberFormatName) {
		this.numberFormatName = numberFormatName;
	}

	public String getNumberPrefix() {
		return numberPrefix;
	}

	public void setNumberPrefix(String numberPrefix) {
		this.numberPrefix = numberPrefix;
	}

	@Override
	public BalanceType clone() throws CloneNotSupportedException {
		return (BalanceType)super.clone();
	}

	public Integer getUpdateMacrosType() {
		return updateMacrosType;
	}

	public void setUpdateMacrosType(Integer updateMacrosType) {
		this.updateMacrosType = updateMacrosType;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("accountType", this.getAccountType());
		result.put("balanceType", this.getBalanceType());
		result.put("currency", this.getCurrency());
		result.put("avalImpact", this.getAvalImpact());
		result.put("status", this.getStatus());
		result.put("rateType", this.getRateType());
		result.put("numberFormatId", this.getNumberFormatId());
		result.put("numberPrefix", this.getNumberPrefix());
		result.put("updateMacrosType", this.getUpdateMacrosType());
		
		return result;
	}

	public String getBalanceAlgorithm() {
		return balanceAlgorithm;
	}

	public void setBalanceAlgorithm(String balanceAlgorithm) {
		this.balanceAlgorithm = balanceAlgorithm;
	}
}

package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class EntryTemplate implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer bunchTypeId;
	private String transactionType;
	private Integer transactionNum;
	private String accountName;
	private String amountName;
	private String dateName;
	private String postingMethod;
	private String balanceType;
	private Integer balanceImpact;
	private String destEntityType;
	private String destAccountType;
	private boolean negativeAllowed;
	private String modId;
	
	public Object getModelId() {
		return transactionNum + "_" + transactionType + "_" + amountName;
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

	public Integer getBunchTypeId() {
		return bunchTypeId;
	}

	public void setBunchTypeId(Integer bunchTypeId) {
		this.bunchTypeId = bunchTypeId;
	}

	public String getTransactionType() {
		return transactionType;
	}

	public void setTransactionType(String transactionType) {
		this.transactionType = transactionType;
	}

	public Integer getTransactionNum() {
		return transactionNum;
	}

	public void setTransactionNum(Integer transactionNum) {
		this.transactionNum = transactionNum;
	}

	public String getAccountName() {
		return accountName;
	}

	public void setAccountName(String accountName) {
		this.accountName = accountName;
	}

	public String getAmountName() {
		return amountName;
	}

	public void setAmountName(String amountName) {
		this.amountName = amountName;
	}

	public String getDateName() {
		return dateName;
	}

	public void setDateName(String dateName) {
		this.dateName = dateName;
	}

	public String getPostingMethod() {
		return postingMethod;
	}

	public void setPostingMethod(String postingMethod) {
		this.postingMethod = postingMethod;
	}

	public String getBalanceType() {
		return balanceType;
	}

	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}

	public Integer getBalanceImpact() {
		return balanceImpact;
	}

	public void setBalanceImpact(Integer balanceImpact) {
		this.balanceImpact = balanceImpact;
	}

	public String getDestEntityType() {
		return destEntityType;
	}

	public void setDestEntityType(String destEntityType) {
		this.destEntityType = destEntityType;
	}

	public String getDestAccountType() {
		return destAccountType;
	}

	public void setDestAccountType(String destAccountType) {
		this.destAccountType = destAccountType;
	}

	public boolean isNegativeAllowed() {
		return negativeAllowed;
	}

	public void setNegativeAllowed(boolean negativeAllowed) {
		this.negativeAllowed = negativeAllowed;
	}

	public String getModId() {
		return modId;
	}

	public void setModId(String modId) {
		this.modId = modId;
	}

	@Override
	public Object clone() {
		try {
			return super.clone();
		} catch (CloneNotSupportedException e) {
			return null;
		}
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("transactionType", this.getTransactionType());
		result.put("transactionNum", this.getTransactionNum());
		result.put("accountName", this.getAccountName());
		result.put("amountName", this.getAmountName());
		result.put("dateName", this.getDateName());
		result.put("postingMethod", this.getPostingMethod());
		result.put("balanceType", this.getBalanceType());
		result.put("balanceImpact", this.getBalanceImpact());
		result.put("destEntityType", this.getDestEntityType());
		result.put("destAccountType", this.getDestAccountType());
		
		return result;
	}

}

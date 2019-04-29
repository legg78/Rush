package ru.bpc.sv2.accounts;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class Entry implements Serializable, ModelIdentifiable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long accountId;
	private Long bunchId;
	private BigDecimal amount;
	private BigDecimal balance;
	private Integer balanceImpact;
	private String balanceType;
	private String currency;
	private Long macrosId;
	private Date postingDate;
	private Integer postingOrder;
	private BigDecimal roundingBalance;
	private Date operationDate;
	private Integer splitHash;
	private Integer sttlDay;
	private Date sttlDate;
	private Long transactionId;
	private String transactionType;
	private String merchantName;
	private String merchantStreet;
	private String merchantCity;
	private String merchantCountry;
	private String operationType;
	private String status;
	private String amountPurpose;
	private Date unholdDate;
	private Date hostDate;
	
	@Deprecated
	private String feeType;
	
	private Date operationDateFrom;
	private Date operationDateTo;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public Long getBunchId() {
		return bunchId;
	}

	public void setBunchId(Long bunchId) {
		this.bunchId = bunchId;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public BigDecimal getBalance() {
		return balance;
	}

	public void setBalance(BigDecimal balance) {
		this.balance = balance;
	}

	public Integer getBalanceImpact() {
		return balanceImpact;
	}

	public void setBalanceImpact(Integer balanceImpact) {
		this.balanceImpact = balanceImpact;
	}

	public String getBalanceType() {
		return balanceType;
	}

	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Long getMacrosId() {
		return macrosId;
	}

	public void setMacrosId(Long macrosId) {
		this.macrosId = macrosId;
	}

	public Date getPostingDate() {
		return postingDate;
	}

	public void setPostingDate(Date postingDate) {
		this.postingDate = postingDate;
	}

	public Integer getPostingOrder() {
		return postingOrder;
	}

	public void setPostingOrder(Integer postingOrder) {
		this.postingOrder = postingOrder;
	}

	public BigDecimal getRoundingBalance() {
		return roundingBalance;
	}

	public void setRoundingBalance(BigDecimal roundingBalance) {
		this.roundingBalance = roundingBalance;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Integer getSttlDay() {
		return sttlDay;
	}

	public void setSttlDay(Integer sttlDay) {
		this.sttlDay = sttlDay;
	}

	public Long getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(Long transactionId) {
		this.transactionId = transactionId;
	}

	public String getTransactionType() {
		return transactionType;
	}

	public void setTransactionType(String transactionType) {
		this.transactionType = transactionType;
	}

	public Date getOperationDate() {
		return operationDate;
	}

	public void setOperationDate(Date operationDate) {
		this.operationDate = operationDate;
	}

	public Date getSttlDate() {
		return sttlDate;
	}

	public void setSttlDate(Date sttlDate) {
		this.sttlDate = sttlDate;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getMerchantStreet() {
		return merchantStreet;
	}

	public void setMerchantStreet(String merchantStreet) {
		this.merchantStreet = merchantStreet;
	}

	public String getMerchantCity() {
		return merchantCity;
	}

	public void setMerchantCity(String merchantCity) {
		this.merchantCity = merchantCity;
	}

	public String getMerchantCountry() {
		return merchantCountry;
	}

	public void setMerchantCountry(String merchantCountry) {
		this.merchantCountry = merchantCountry;
	}

	public String getOperationType() {
		return operationType;
	}

	public void setOperationType(String operationType) {
		this.operationType = operationType;
	}

	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public Date getOperationDateFrom() {
		return operationDateFrom;
	}

	public void setOperationDateFrom(Date operationDateFrom) {
		this.operationDateFrom = operationDateFrom;
	}

	public Date getOperationDateTo() {
		return operationDateTo;
	}

	public void setOperationDateTo(Date operationDateTo) {
		this.operationDateTo = operationDateTo;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getAmountPurpose() {
		return amountPurpose;
	}

	public void setAmountPurpose(String amountPurpose) {
		this.amountPurpose = amountPurpose;
	}

	public Date getUnholdDate() {
		return unholdDate;
	}

	public void setUnholdDate(Date unholdDate) {
		this.unholdDate = unholdDate;
	}

	public Date getHostDate() {
		return hostDate;
	}

	public void setHostDate(Date hostDate) {
		this.hostDate = hostDate;
	}
}

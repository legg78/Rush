package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * This is totally a crap!
 * Someone must fix it! 
 */
public class EntryForOperation implements Serializable, ModelIdentifiable{
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long accountId;
	private Double amount;
	private Double balance;
	private Integer balanceImpact;
	private String balanceType;
	private String currency;
	private Long macrosId;
	private Date postingDate;
	private Integer postingOrder;
	private Double roundingBalance;
	private Integer splitHash;
	private Integer sttlDay;
	private Long transactionId;
	private String transactionType;
	private Long debitAccount;
	private Long creditAccount;
	private Double debitAmount;
	private Double creditAmount;
	
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

	public Double getAmount() {
		return amount;
	}

	public void setAmount(Double amount) {
		this.amount = amount;
	}

	public Double getBalance() {
		return balance;
	}

	public void setBalance(Double balance) {
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

	public Double getRoundingBalance() {
		return roundingBalance;
	}

	public void setRoundingBalance(Double roundingBalance) {
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

	public Long getDebitAccount() {
		return debitAccount;
	}

	public void setDebitAccount(Long debitAccount) {
		this.debitAccount = debitAccount;
	}

	public Long getCreditAccount() {
		return creditAccount;
	}

	public void setCreditAccount(Long creditAccount) {
		this.creditAccount = creditAccount;
	}

	public Double getDebitAmount() {
		return debitAmount;
	}

	public void setDebitAmount(Double debitAmount) {
		this.debitAmount = debitAmount;
	}

	public Double getCreditAmount() {
		return creditAmount;
	}

	public void setCreditAmount(Double creditAmount) {
		this.creditAmount = creditAmount;
	}
	

}

package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Balance implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer splitHash;
	private Long accountId;
	private String balanceNumber;
	private String balanceType;
	private BigDecimal balance;
	private BigDecimal roundingBalance;
	private String currency;
	private Integer entryCount;
	private Integer instId;
	private String status;
	private Date openDate;
	private Date closeDate;
	private String statusReason;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Long getAccountId() {
		return accountId;
	}
	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public String getBalanceNumber() {
		return balanceNumber;
	}
	public void setBalanceNumber(String balanceNumber) {
		this.balanceNumber = balanceNumber;
	}

	public String getBalanceType() {
		return balanceType;
	}
	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}

	public BigDecimal getBalance() {
		return balance;
	}
	public void setBalance(BigDecimal balance) {
		this.balance = balance;
	}

	public BigDecimal getRoundingBalance() {
		return roundingBalance;
	}
	public void setRoundingBalance(BigDecimal roundingBalance) {
		this.roundingBalance = roundingBalance;
	}

	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Integer getEntryCount() {
		return entryCount;
	}
	public void setEntryCount(Integer entryCount) {
		this.entryCount = entryCount;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public Date getOpenDate() {
		return openDate;
	}
	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	public Date getCloseDate() {
		return closeDate;
	}
	public void setCloseDate(Date closeDate) {
		this.closeDate = closeDate;
	}

	public String getStatusReason() {
		return statusReason;
	}
	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Balance clone() throws CloneNotSupportedException {
		return (Balance)super.clone();
	}
}

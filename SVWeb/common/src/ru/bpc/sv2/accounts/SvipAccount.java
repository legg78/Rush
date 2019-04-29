package ru.bpc.sv2.accounts;

import java.io.Serializable;
import java.util.Date;

public class SvipAccount implements Serializable {
	
	private static final long serialVersionUID = 1L;
	
	private Long id;
	private String accountNumber;
	private String accountType;
	private String ledgerAccountCurrency;
	private String avalAccountCurrency;
	private String avalRequestCurrency;
	private String holdAccountCurrency;
	private String holdRequestCurrency;
	private String status;
	private String partyStatus;
	private String currency;
	
	private String creditLimitRequestCurrency;
	private String creditLimitAccountCurrency;
	
	private String cycleLimitRequestCurrency;
	private String cycleLimitAccountCurrency;
	
	private String yotaTelecomHeldRequestCurrency;
	private String yotaTelecomHeldAccountCurrency;
	
	private String highThresholdRequestCurrency;
	private String highThresholdAccountCurrency;
	
	private String topUpLimitRequestCurrency;
	private String topUpLimitAccountCurrency;
	
	private Date accountOpenDate;
	private Date accountCloseDate;
	
	private String totalHeldAccountCurrency;
	private String totalHeldRequestCurrency;

	private String p2pHoldAccountCurrency;
	private String p2pHoldRequestCurrency;
	
	private String highThresholdAccountLimit;
	private String highThresholRequestLimit;
	
	private String cycleLimitAccountLimit;
	private String cycleLimitRequestLimit;

	public String getAccountNumber() {
		return accountNumber;
	}
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}
	public String getAccountType() {
		return accountType;
	}
	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}
	public String getLedgerAccountCurrency() {
		return ledgerAccountCurrency;
	}
	public void setLedgerAccountCurrency(String ledgerAccountCurrency) {
		this.ledgerAccountCurrency = ledgerAccountCurrency;
	}
	public String getAvalAccountCurrency() {
		return avalAccountCurrency;
	}
	public void setAvalAccountCurrency(String avalAccountCurrency) {
		this.avalAccountCurrency = avalAccountCurrency;
	}
	public String getAvalRequestCurrency() {
		return avalRequestCurrency;
	}
	public void setAvalRequestCurrency(String avalRequestCurrency) {
		this.avalRequestCurrency = avalRequestCurrency;
	}
	public String getHoldAccountCurrency() {
		return holdAccountCurrency;
	}
	public void setHoldAccountCurrency(String holdAccountCurrency) {
		this.holdAccountCurrency = holdAccountCurrency;
	}
	public String getHoldRequestCurrency() {
		return holdRequestCurrency;
	}
	public void setHoldRequestCurrency(String holdRequestCurrency) {
		this.holdRequestCurrency = holdRequestCurrency;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public String getCycleLimitRequestCurrency() {
		return cycleLimitRequestCurrency;
	}
	public void setCycleLimitRequestCurrency(String cycleLimitRequestCurrency) {
		this.cycleLimitRequestCurrency = cycleLimitRequestCurrency;
	}
	public String getCycleLimitAccountCurrency() {
		return cycleLimitAccountCurrency;
	}
	public void setCycleLimitAccountCurrency(String cycleLimitAccountCurrency) {
		this.cycleLimitAccountCurrency = cycleLimitAccountCurrency;
	}
	public String getHighThresholdRequestCurrency() {
		return highThresholdRequestCurrency;
	}
	public void setHighThresholdRequestCurrency(String highThresholdRequestCurrency) {
		this.highThresholdRequestCurrency = highThresholdRequestCurrency;
	}
	public String getHighThresholdAccountCurrency() {
		return highThresholdAccountCurrency;
	}
	public void setHighThresholdAccountCurrency(String highThresholdAccountCurrency) {
		this.highThresholdAccountCurrency = highThresholdAccountCurrency;
	}
	public String getPartyStatus() {
		return partyStatus;
	}
	public void setPartyStatus(String partyStatus) {
		this.partyStatus = partyStatus;
	}
	public String getCreditLimitRequestCurrency() {
		return creditLimitRequestCurrency;
	}
	public void setCreditLimitRequestCurrency(String creditLimitRequestCurrency) {
		this.creditLimitRequestCurrency = creditLimitRequestCurrency;
	}
	public String getCreditLimitAccountCurrency() {
		return creditLimitAccountCurrency;
	}
	public void setCreditLimitAccountCurrency(String creditLimitAccountCurrency) {
		this.creditLimitAccountCurrency = creditLimitAccountCurrency;
	}
	public String getYotaTelecomHeldRequestCurrency() {
		return yotaTelecomHeldRequestCurrency;
	}
	public void setYotaTelecomHeldRequestCurrency(String yotaTelecomHeldRequestCurrency) {
		this.yotaTelecomHeldRequestCurrency = yotaTelecomHeldRequestCurrency;
	}
	public String getYotaTelecomHeldAccountCurrency() {
		return yotaTelecomHeldAccountCurrency;
	}
	public void setYotaTelecomHeldAccountCurrency(String yotaTelecomHeldAccountCurrency) {
		this.yotaTelecomHeldAccountCurrency = yotaTelecomHeldAccountCurrency;
	}
	public String getTopUpLimitRequestCurrency() {
		return topUpLimitRequestCurrency;
	}
	public void setTopUpLimitRequestCurrency(String topUpLimitRequestCurrency) {
		this.topUpLimitRequestCurrency = topUpLimitRequestCurrency;
	}
	public String getTopUpLimitAccountCurrency() {
		return topUpLimitAccountCurrency;
	}
	public void setTopUpLimitAccountCurrency(String topUpLimitAccountCurrency) {
		this.topUpLimitAccountCurrency = topUpLimitAccountCurrency;
	}

	public Date getAccountOpenDate() {
		return accountOpenDate;
	}
	
	public void setAccountOpenDate(Date accountOpenDate) {
		this.accountOpenDate = accountOpenDate;
	}
	
	public Date getAccountCloseDate() {
		return accountCloseDate;
	}
	
	public void setAccountCloseDate(Date accountCloseDate) {
		this.accountCloseDate = accountCloseDate;
	}
	public String getTotalHeldAccountCurrency() {
		return totalHeldAccountCurrency;
	}
	public void setTotalHeldAccountCurrency(String totalHeldAccountCurrency) {
		this.totalHeldAccountCurrency = totalHeldAccountCurrency;
	}
	public String getTotalHeldRequestCurrency() {
		return totalHeldRequestCurrency;
	}
	public void setTotalHeldRequestCurrency(String totalHeldRequestCurrency) {
		this.totalHeldRequestCurrency = totalHeldRequestCurrency;
	}
	public String getP2pHoldAccountCurrency() {
		return p2pHoldAccountCurrency;
	}
	public void setP2pHoldAccountCurrency(String p2pHoldAccountCurrency) {
		this.p2pHoldAccountCurrency = p2pHoldAccountCurrency;
	}
	public String getP2pHoldRequestCurrency() {
		return p2pHoldRequestCurrency;
	}
	public void setP2pHoldRequestCurrency(String p2pHoldRequestCurrency) {
		this.p2pHoldRequestCurrency = p2pHoldRequestCurrency;
	}
	public String getHighThresholdAccountLimit() {
		return highThresholdAccountLimit;
	}
	public void setHighThresholdAccountLimit(String highThresholdAccountLimit) {
		this.highThresholdAccountLimit = highThresholdAccountLimit;
	}
	public String getHighThresholRequestLimit() {
		return highThresholRequestLimit;
	}
	public void setHighThresholRequestLimit(String highThresholRequestLimit) {
		this.highThresholRequestLimit = highThresholRequestLimit;
	}
	public String getCycleLimitAccountLimit() {
		return cycleLimitAccountLimit;
	}
	public void setCycleLimitAccountLimit(String cycleLimitAccountLimit) {
		this.cycleLimitAccountLimit = cycleLimitAccountLimit;
	}
	public String getCycleLimitRequestLimit() {
		return cycleLimitRequestLimit;
	}
	public void setCycleLimitRequestLimit(String cycleLimitRequestLimit) {
		this.cycleLimitRequestLimit = cycleLimitRequestLimit;
	}
}

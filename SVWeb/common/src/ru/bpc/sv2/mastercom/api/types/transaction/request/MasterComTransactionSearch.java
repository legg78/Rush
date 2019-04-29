package ru.bpc.sv2.mastercom.api.types.transaction.request;

import ru.bpc.sv2.mastercom.api.types.MasterComRequest;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class MasterComTransactionSearch implements MasterComRequest, Serializable {
	private static final long serialVersionUID = -1;

	/**
	 * REQUIRED. Primary Account Number
	 */
	private String primaryAccountNum;

	/**
	 * REQUIRED. Transaction Date min search range. The search range is a maximum of 30 days, and searches can be completed for up to 541 days of history
	 */
	private Date tranStartDate;

	/**
	 * REQUIRED. Transaction Date max search range. The search range is a maximum of 30 days, and searches can be completed for up to 541 days of history
	 */
	private Date tranEndDate;


	/**
	 * Acquirer Reference Number. If provided bankNetRefNumber may not be used.
	 */
	private String acquirerRefNumber;

	/**
	 * Banknet Reference Number. If provided acquirerRefNumber may not be used.
	 */
	private String bankNetRefNumber;

	/**
	 * Transaction amount lower limit value to be searched
	 * Example: 10000
	 */
	private BigDecimal transAmountFrom;


	/**
	 * Transaction amount upper limit value to be searched
	 * Example: 20050
	 */
	private BigDecimal transAmountTo;




	public String getPrimaryAccountNum() {
		return primaryAccountNum;
	}

	public void setPrimaryAccountNum(String primaryAccountNum) {
		this.primaryAccountNum = primaryAccountNum;
	}

	public Date getTranStartDate() {
		return tranStartDate;
	}

	public void setTranStartDate(Date tranStartDate) {
		this.tranStartDate = tranStartDate;
	}

	public Date getTranEndDate() {
		return tranEndDate;
	}

	public void setTranEndDate(Date tranEndDate) {
		this.tranEndDate = tranEndDate;
	}

	public String getAcquirerRefNumber() {
		return acquirerRefNumber;
	}

	public void setAcquirerRefNumber(String acquirerRefNumber) {
		this.acquirerRefNumber = acquirerRefNumber;
	}

	public String getBankNetRefNumber() {
		return bankNetRefNumber;
	}

	public void setBankNetRefNumber(String bankNetRefNumber) {
		this.bankNetRefNumber = bankNetRefNumber;
	}

	public BigDecimal getTransAmountFrom() {
		return transAmountFrom;
	}

	public void setTransAmountFrom(BigDecimal transAmountFrom) {
		this.transAmountFrom = transAmountFrom;
	}

	public BigDecimal getTransAmountTo() {
		return transAmountTo;
	}

	public void setTransAmountTo(BigDecimal transAmountTo) {
		this.transAmountTo = transAmountTo;
	}
}

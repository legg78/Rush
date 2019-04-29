package ru.bpc.sv2.mastercom.api.types.transaction.response;

import ru.bpc.sv2.mastercom.api.format.MasterComDateFormat;
import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class MasterComClearingSummary implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;


	private String primaryAccountNumber;

	/**
	 * Transaction amount in local currency
	 * Example: 2500
	 */
	private BigDecimal transactionAmountLocal;

	@MasterComDateFormat("yyMMddHHmmss")
	private Date dateAndTimeLocal;
	private String cardDataInputCapability;
	private String cardholderAuthenticationCapability;
	private String cardPresent;
	private String acquirerReferenceNumber;
	private String cardAcceptorName;
	private String currencyCode;
	private String transactionId;

	private String switchSerialNumber;

	public String getPrimaryAccountNumber() {
		return primaryAccountNumber;
	}

	public void setPrimaryAccountNumber(String primaryAccountNumber) {
		this.primaryAccountNumber = primaryAccountNumber;
	}

	public BigDecimal getTransactionAmountLocal() {
		return transactionAmountLocal;
	}

	public void setTransactionAmountLocal(BigDecimal transactionAmountLocal) {
		this.transactionAmountLocal = transactionAmountLocal;
	}

	public Date getDateAndTimeLocal() {
		return dateAndTimeLocal;
	}

	public void setDateAndTimeLocal(Date dateAndTimeLocal) {
		this.dateAndTimeLocal = dateAndTimeLocal;
	}

	public String getCardholderAuthenticationCapability() {
		return cardholderAuthenticationCapability;
	}

	public void setCardholderAuthenticationCapability(String cardholderAuthenticationCapability) {
		this.cardholderAuthenticationCapability = cardholderAuthenticationCapability;
	}

	public String getCardPresent() {
		return cardPresent;
	}

	public void setCardPresent(String cardPresent) {
		this.cardPresent = cardPresent;
	}

	public String getAcquirerReferenceNumber() {
		return acquirerReferenceNumber;
	}

	public void setAcquirerReferenceNumber(String acquirerReferenceNumber) {
		this.acquirerReferenceNumber = acquirerReferenceNumber;
	}

	public String getCardAcceptorName() {
		return cardAcceptorName;
	}

	public void setCardAcceptorName(String cardAcceptorName) {
		this.cardAcceptorName = cardAcceptorName;
	}

	public String getCurrencyCode() {
		return currencyCode;
	}

	public void setCurrencyCode(String currencyCode) {
		this.currencyCode = currencyCode;
	}

	public String getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}

	public String getSwitchSerialNumber() {
		return switchSerialNumber;
	}

	public void setSwitchSerialNumber(String switchSerialNumber) {
		this.switchSerialNumber = switchSerialNumber;
	}

	public String getCardDataInputCapability() {
		return cardDataInputCapability;
	}

	public void setCardDataInputCapability(String cardDataInputCapability) {
		this.cardDataInputCapability = cardDataInputCapability;
	}
}

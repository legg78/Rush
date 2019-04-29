package ru.bpc.sv2.mastercom.api.types.claim.response;

import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class MasterComFeeDetails implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	private String cardAcceptorIdCode;
	private String cardNumber;
	private String countryCode;
	private String currency;
	private Date feeDate;
	private String destinationMember;
	private String feeId;

	/**
	 * Amount of the fee
	 * Example: 100.00
	 */
	private BigDecimal feeAmount;
	private Boolean creditSender;
	private Boolean creditReceiver;
	private String message;
	private String reason;

	private String chargebackRefNum;



	public String getCardAcceptorIdCode() {
		return cardAcceptorIdCode;
	}

	public void setCardAcceptorIdCode(String cardAcceptorIdCode) {
		this.cardAcceptorIdCode = cardAcceptorIdCode;
	}

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public String getCountryCode() {
		return countryCode;
	}

	public void setCountryCode(String countryCode) {
		this.countryCode = countryCode;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Date getFeeDate() {
		return feeDate;
	}

	public void setFeeDate(Date feeDate) {
		this.feeDate = feeDate;
	}

	public String getDestinationMember() {
		return destinationMember;
	}

	public void setDestinationMember(String destinationMember) {
		this.destinationMember = destinationMember;
	}

	public String getFeeId() {
		return feeId;
	}

	public void setFeeId(String feeId) {
		this.feeId = feeId;
	}

	public BigDecimal getFeeAmount() {
		return feeAmount;
	}

	public void setFeeAmount(BigDecimal feeAmount) {
		this.feeAmount = feeAmount;
	}

	public Boolean getCreditSender() {
		return creditSender;
	}

	public void setCreditSender(Boolean creditSender) {
		this.creditSender = creditSender;
	}

	public Boolean getCreditReceiver() {
		return creditReceiver;
	}

	public void setCreditReceiver(Boolean creditReceiver) {
		this.creditReceiver = creditReceiver;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getReason() {
		return reason;
	}

	public void setReason(String reason) {
		this.reason = reason;
	}

	public String getChargebackRefNum() {
		return chargebackRefNum;
	}

	public void setChargebackRefNum(String chargebackRefNum) {
		this.chargebackRefNum = chargebackRefNum;
	}
}

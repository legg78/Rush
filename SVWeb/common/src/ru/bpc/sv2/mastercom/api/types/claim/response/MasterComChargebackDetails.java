package ru.bpc.sv2.mastercom.api.types.claim.response;

import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class MasterComChargebackDetails implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	private String chargebackRefNum;
	private String currency;
	private Date createDate;
	private Boolean documentIndicator;
	private String messageText;

	/**
	 * Chargeback Amount
	 * Example: 100.00
	 */
	private BigDecimal amount;
	private String reasonCode;

	private Boolean isPartialChargeback;

	/**
	 * Provide the chargeback type. The following values are valid - CHARGEBACK, SECOND_PRESENTMENT, ARB_CHARGEBACK
	 */
	private ChargebackType chargebackType;
	private String chargebackId;
	private String claimId;
	private Boolean reversed;
	private Boolean reversal;

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Date getCreateDate() {
		return createDate;
	}

	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}

	public Boolean getDocumentIndicator() {
		return documentIndicator;
	}

	public void setDocumentIndicator(Boolean documentIndicator) {
		this.documentIndicator = documentIndicator;
	}

	public String getMessageText() {
		return messageText;
	}

	public void setMessageText(String messageText) {
		this.messageText = messageText;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public String getReasonCode() {
		return reasonCode;
	}

	public void setReasonCode(String reasonCode) {
		this.reasonCode = reasonCode;
	}

	public Boolean getIsPartialChargeback() {
		return isPartialChargeback;
	}

	public void setIsPartialChargeback(Boolean partialChargeback) {
		isPartialChargeback = partialChargeback;
	}

	public ChargebackType getChargebackType() {
		return chargebackType;
	}

	public void setChargebackType(ChargebackType chargebackType) {
		this.chargebackType = chargebackType;
	}

	public String getChargebackId() {
		return chargebackId;
	}

	public void setChargebackId(String chargebackId) {
		this.chargebackId = chargebackId;
	}

	public String getClaimId() {
		return claimId;
	}

	public void setClaimId(String claimId) {
		this.claimId = claimId;
	}

	public Boolean getReversed() {
		return reversed;
	}

	public void setReversed(Boolean reversed) {
		this.reversed = reversed;
	}

	public Boolean getReversal() {
		return reversal;
	}

	public void setReversal(Boolean reversal) {
		this.reversal = reversal;
	}

	public String getChargebackRefNum() {
		return chargebackRefNum;
	}

	public void setChargebackRefNum(String chargebackRefNum) {
		this.chargebackRefNum = chargebackRefNum;
	}


	public enum ChargebackType {
		CHARGEBACK,
		SECOND_PRESENTMENT,
		ARB_CHARGEBACK,
	}
}

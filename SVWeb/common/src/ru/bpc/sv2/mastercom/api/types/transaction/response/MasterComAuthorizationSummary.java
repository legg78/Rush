package ru.bpc.sv2.mastercom.api.types.transaction.response;

import ru.bpc.sv2.mastercom.api.format.impl.MasterComBooleanYNFormatter;
import ru.bpc.sv2.mastercom.api.format.MasterComDateFormat;
import ru.bpc.sv2.mastercom.api.format.MasterComFormatter;
import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

import static ru.bpc.sv2.mastercom.api.MasterComMapper.DATE_NUMBER_FORMAT;

public class MasterComAuthorizationSummary implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	/**
	 * Indicates the Message Type Identifier (MTI) of the original message
	 */
	private String originalMessageTypeIdentifier;

	/**
	 * The date/time when the SAFE record is matched to the Authorization transaction
	 */
	@MasterComDateFormat("yyMMdd")
	private Date banknetDate;

	/**
	 * Transaction amount in USD
	 * Example: 401.17
	 */
	private BigDecimal transactionAmountUsd;

	/**
	 * Primary account number
	 */
	private String primaryAccountNumber;

	/**
	 * A series of digits used to describe the effect of a transaction on the customer account and the type of accounts affected
	 */
	private String processingCode;

	/**
	 * Transaction amount in local currency
	 * Example: 000000010000
	 */
	private BigDecimal transactionAmountLocal;

	/**
	 * The date and time that a message is entered into the Mastercard Network
	 */
	@MasterComDateFormat(DATE_NUMBER_FORMAT)
	private Date authorizationDateAndTime;

	/**
	 * Defined by the Authorization Platform and is passed to the issuer to indicate that the transaction qualified for Authentication service
	 */
	private String authenticationId;

	/**
	 * Name the card acceptor that defines the point of interaction in both local and interchange environments (excluding ATM and Card-Activated Public Phones)
	 */
	private String cardAcceptorName;

	/**
	 * City of the card acceptor that defines the point of interaction in both local and interchange environments (excluding ATM and Card-Activated Public Phones)
	 */
	private String cardAcceptorCity;

	/**
	 * State of the card acceptor that defines the point of interaction in both local and interchange environments (excluding ATM and Card-Activated Public Phones)
	 */
	private String cardAcceptorState;

	/**
	 * Currency code the issuer will be charging the cardholder for repayment
	 */
	private String currencyCode;

	/**
	 * Indicates if chip was present or not
	 */
	@MasterComFormatter(using = MasterComBooleanYNFormatter.class)
	private Boolean chipPresent;

	/**
	 * The host's identifier
	 */
	private String transactionId;

	/**
	 * The information encoded on track 1 of the card's magnetic stripe as defined in the ISO 7813 specification, including data element separators but excluding beginning and ending sentinels and LRC characters as defined in this data element definition
	 */
	private String track1;

	/**
	 * The information encoded on track 2 of the card magnetic stripe as defined in the ISO 7813 specification, including data element separators but excluding beginning and ending sentinels and longitudinal redundancy check (LRC) characters as defined therein
	 */
	private String track2;


	private List<MasterComClearingSummary> clearingSummary;



	public String getOriginalMessageTypeIdentifier() {
		return originalMessageTypeIdentifier;
	}

	public void setOriginalMessageTypeIdentifier(String originalMessageTypeIdentifier) {
		this.originalMessageTypeIdentifier = originalMessageTypeIdentifier;
	}

	public Date getBanknetDate() {
		return banknetDate;
	}

	public void setBanknetDate(Date banknetDate) {
		this.banknetDate = banknetDate;
	}

	public BigDecimal getTransactionAmountUsd() {
		return transactionAmountUsd;
	}

	public void setTransactionAmountUsd(BigDecimal transactionAmountUsd) {
		this.transactionAmountUsd = transactionAmountUsd;
	}

	public String getPrimaryAccountNumber() {
		return primaryAccountNumber;
	}

	public void setPrimaryAccountNumber(String primaryAccountNumber) {
		this.primaryAccountNumber = primaryAccountNumber;
	}

	public String getProcessingCode() {
		return processingCode;
	}

	public void setProcessingCode(String processingCode) {
		this.processingCode = processingCode;
	}

	public BigDecimal getTransactionAmountLocal() {
		return transactionAmountLocal;
	}

	public void setTransactionAmountLocal(BigDecimal transactionAmountLocal) {
		this.transactionAmountLocal = transactionAmountLocal;
	}

	public Date getAuthorizationDateAndTime() {
		return authorizationDateAndTime;
	}

	public void setAuthorizationDateAndTime(Date authorizationDateAndTime) {
		this.authorizationDateAndTime = authorizationDateAndTime;
	}

	public String getAuthenticationId() {
		return authenticationId;
	}

	public void setAuthenticationId(String authenticationId) {
		this.authenticationId = authenticationId;
	}

	public String getCardAcceptorName() {
		return cardAcceptorName;
	}

	public void setCardAcceptorName(String cardAcceptorName) {
		this.cardAcceptorName = cardAcceptorName;
	}

	public String getCardAcceptorCity() {
		return cardAcceptorCity;
	}

	public void setCardAcceptorCity(String cardAcceptorCity) {
		this.cardAcceptorCity = cardAcceptorCity;
	}

	public String getCardAcceptorState() {
		return cardAcceptorState;
	}

	public void setCardAcceptorState(String cardAcceptorState) {
		this.cardAcceptorState = cardAcceptorState;
	}

	public String getCurrencyCode() {
		return currencyCode;
	}

	public void setCurrencyCode(String currencyCode) {
		this.currencyCode = currencyCode;
	}

	public Boolean getChipPresent() {
		return chipPresent;
	}

	public void setChipPresent(Boolean chipPresent) {
		this.chipPresent = chipPresent;
	}

	public String getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}

	public String getTrack1() {
		return track1;
	}

	public void setTrack1(String track1) {
		this.track1 = track1;
	}

	public String getTrack2() {
		return track2;
	}

	public void setTrack2(String track2) {
		this.track2 = track2;
	}

	public List<MasterComClearingSummary> getClearingSummary() {
		return clearingSummary;
	}

	public void setClearingSummary(List<MasterComClearingSummary> clearingSummary) {
		this.clearingSummary = clearingSummary;
	}
}

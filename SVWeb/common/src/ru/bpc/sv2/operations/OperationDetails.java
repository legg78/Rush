package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * Represents data for "Details" tab of "Operations" page
 * @author Alexeev
 * @see ru.bpc.sv2.operations.Operation
 */
public class OperationDetails implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Long authId;
	private Long operationId;
	private Date operationDate;
	private Integer acqNetworkId;	// From network
	private Integer issNetworkId;	// To network
	private Integer instId;
	private Integer cardNetworkId;
	private Long cardId;
	private String cardCountry;
	private String cardNumber;
	private String cardMask;
	private Date cardExpirationDate;
	private String cardSeqNumber;
	private Integer cardInstId;
	private String refnum;
	private String authCode;
	private String acqInstCode;
	private BigDecimal accountAmount;
	private String accountCurrency;
	private String acqNetworkName;
	private String issNetworkName;
	
	public Long getAuthId() {
		return authId;
	}

	public void setAuthId(Long authId) {
		this.authId = authId;
	}

	public Long getOperationId() {
		return operationId;
	}
	
	public void setOperationId(Long operationId) {
		this.operationId = operationId;
	}

	public Date getOperationDate() {
		return operationDate;
	}

	public void setOperationDate(Date operationDate) {
		this.operationDate = operationDate;
	}

	public Integer getAcqNetworkId() {
		return acqNetworkId;
	}

	public void setAcqNetworkId(Integer acqNetworkId) {
		this.acqNetworkId = acqNetworkId;
	}

	public Integer getIssNetworkId() {
		return issNetworkId;
	}

	public void setIssNetworkId(Integer issNetworkId) {
		this.issNetworkId = issNetworkId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getCardNetworkId() {
		return cardNetworkId;
	}

	public void setCardNetworkId(Integer cardNetworkId) {
		this.cardNetworkId = cardNetworkId;
	}

	public Long getCardId() {
		return cardId;
	}

	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}

	public String getCardCountry() {
		return cardCountry;
	}

	public void setCardCountry(String cardCountry) {
		this.cardCountry = cardCountry;
	}

	public String getCardMask() {
		return cardMask;
	}

	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}

	public Date getCardExpirationDate() {
		return cardExpirationDate;
	}

	public void setCardExpirationDate(Date cardExpirationDate) {
		this.cardExpirationDate = cardExpirationDate;
	}

	public String getCardSeqNumber() {
		return cardSeqNumber;
	}

	public void setCardSeqNumber(String cardSeqNumber) {
		this.cardSeqNumber = cardSeqNumber;
	}

	public Integer getCardInstId() {
		return cardInstId;
	}

	public void setCardInstId(Integer cardInstId) {
		this.cardInstId = cardInstId;
	}

	public String getAuthCode() {
		return authCode;
	}

	public void setAuthCode(String authCode) {
		this.authCode = authCode;
	}

	public String getAcqInstCode() {
		return acqInstCode;
	}

	public void setAcqInstCode(String acqInstCode) {
		this.acqInstCode = acqInstCode;
	}

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public String getAcqNetworkName() {
		return acqNetworkName;
	}

	public void setAcqNetworkName(String acqNetworkName) {
		this.acqNetworkName = acqNetworkName;
	}

	public String getIssNetworkName() {
		return issNetworkName;
	}

	public void setIssNetworkName(String issNetworkName) {
		this.issNetworkName = issNetworkName;
	}

	public String getRefnum() {
		return refnum;
	}

	public void setRefnum(String refnum) {
		this.refnum = refnum;
	}

	public BigDecimal getAccountAmount() {
		return accountAmount;
	}

	public void setAccountAmount(BigDecimal accountAmount) {
		this.accountAmount = accountAmount;
	}

	public String getAccountCurrency() {
		return accountCurrency;
	}

	public void setAccountCurrency(String accountCurrency) {
		this.accountCurrency = accountCurrency;
	}

}

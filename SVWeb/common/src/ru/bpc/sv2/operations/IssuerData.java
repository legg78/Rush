package ru.bpc.sv2.operations;

import java.io.Serializable;

/**
 * Represents data for "Issuer data" tab of "Operations" page
 * @author Alexeev
 * @see ru.bpc.sv2.operations.Operation
 */
public class IssuerData implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Integer issInstId; 	// "Issuer"
	private Integer cardTypeId;
	private String accountNumber; // Debit amount
	private Long accountId; // Debit amount
	private String issInstName;
	
	public Integer getIssInstId() {
		return issInstId;
	}
	
	public void setIssInstId(Integer issInstId) {
		this.issInstId = issInstId;
	}
	
	public Integer getCardTypeId() {
		return cardTypeId;
	}
	
	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public String getAccountNumber() {
		return accountNumber;
	}

	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	public String getIssInstName() {
		return issInstName;
	}

	public void setIssInstName(String issInstName) {
		this.issInstName = issInstName;
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}
	
}

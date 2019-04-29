package ru.bpc.sv2.mastercom.api.types.claim.request;

import ru.bpc.sv2.mastercom.api.types.MasterComRequest;

import java.io.Serializable;
import java.math.BigDecimal;

public class MasterComClaimCreate implements MasterComRequest, Serializable {
	private static final long serialVersionUID = -1;

	/**
	 * REQUIRED. Amount disputed in the claim.
	 * Example: 100.00
	 */
	private BigDecimal disputedAmount;

	/**
	 * REQUIRED. Currency of amount disputed in the claim.
	 */
	private String disputedCurrency;

	/**
	 * REQUIRED. Type of claim to be created. The following values are valid - Standard
	 */
	private ClaimType claimType;

	/**
	 * REQUIRED. The Clearing Transaction Identifier from Clearing Summary Results
	 */
	private String clearingTransactionId;

	/**
	 * The Authorization Transaction Identifier from Authorization Summary Results
	 */
	private String authTransactionId;


	public BigDecimal getDisputedAmount() {
		return disputedAmount;
	}

	public void setDisputedAmount(BigDecimal disputedAmount) {
		this.disputedAmount = disputedAmount;
	}

	public String getDisputedCurrency() {
		return disputedCurrency;
	}

	public void setDisputedCurrency(String disputedCurrency) {
		this.disputedCurrency = disputedCurrency;
	}

	public String getClearingTransactionId() {
		return clearingTransactionId;
	}

	public void setClearingTransactionId(String clearingTransactionId) {
		this.clearingTransactionId = clearingTransactionId;
	}

	public String getAuthTransactionId() {
		return authTransactionId;
	}

	public void setAuthTransactionId(String authTransactionId) {
		this.authTransactionId = authTransactionId;
	}

	public ClaimType getClaimType() {
		return claimType;
	}

	public void setClaimType(ClaimType claimType) {
		this.claimType = claimType;
	}


	public enum ClaimType {
		Standard,
	}
}

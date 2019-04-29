package ru.bpc.sv2.mastercom.api.types.claim.request;

import ru.bpc.sv2.mastercom.api.format.MasterComPropertyName;
import ru.bpc.sv2.mastercom.api.types.MasterComRequest;

import java.io.Serializable;
import java.util.Date;

public class MasterComClaimUpdate implements MasterComRequest, Serializable {
	private static final long serialVersionUID = -1;

	/**
	 * REQUIRED. Claim Id
	 */
	@MasterComPropertyName("claim-id")
	private String claimId;

	/**
	 * REQUIRED. Action to perform on claim. The following values are valid - REOPEN, CLOSE
	 */
	private ClaimAction action;

	/**
	 * The due date for opening the claim. Format is yyyy-mm-dd
	 */
	private Date openClaimDueDate;

	/**
	 * Reason code for closing the claim
	 */
	private String closeClaimReasonCode;


	public String getClaimId() {
		return claimId;
	}

	public void setClaimId(String claimId) {
		this.claimId = claimId;
	}

	public ClaimAction getAction() {
		return action;
	}

	public void setAction(ClaimAction action) {
		this.action = action;
	}

	public Date getOpenClaimDueDate() {
		return openClaimDueDate;
	}

	public void setOpenClaimDueDate(Date openClaimDueDate) {
		this.openClaimDueDate = openClaimDueDate;
	}

	public String getCloseClaimReasonCode() {
		return closeClaimReasonCode;
	}

	public void setCloseClaimReasonCode(String closeClaimReasonCode) {
		this.closeClaimReasonCode = closeClaimReasonCode;
	}

	public enum ClaimAction {
		REOPEN,
		CLOSE,
	}
}

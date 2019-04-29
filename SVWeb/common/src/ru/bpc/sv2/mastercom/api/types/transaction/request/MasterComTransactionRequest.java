package ru.bpc.sv2.mastercom.api.types.transaction.request;

import ru.bpc.sv2.mastercom.api.format.MasterComPropertyName;
import ru.bpc.sv2.mastercom.api.types.MasterComRequest;

import java.io.Serializable;

// todo not used. Remove?
public class MasterComTransactionRequest implements MasterComRequest, Serializable {
	private static final long serialVersionUID = -1;

	@MasterComPropertyName("claim-id")
	private String claimId;

	@MasterComPropertyName("transaction-id")
	private String transactionId;


	public String getClaimId() {
		return claimId;
	}

	public void setClaimId(String claimId) {
		this.claimId = claimId;
	}

	public String getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}
}

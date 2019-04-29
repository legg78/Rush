package ru.bpc.sv2.mastercom.api.types.transaction.response;

import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.util.List;

public class MasterComTransactions implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	/**
	 * The number of records returned in the response
	 */
	private Integer authorizationSummaryCount;

	/**
	 * Provides the message receiver with the reason for sending the message
	 */
	private String message;


	private List<MasterComAuthorizationSummary> authorizationSummary;


	public Integer getAuthorizationSummaryCount() {
		return authorizationSummaryCount;
	}

	public void setAuthorizationSummaryCount(Integer authorizationSummaryCount) {
		this.authorizationSummaryCount = authorizationSummaryCount;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public List<MasterComAuthorizationSummary> getAuthorizationSummary() {
		return authorizationSummary;
	}

	public void setAuthorizationSummary(List<MasterComAuthorizationSummary> authorizationSummary) {
		this.authorizationSummary = authorizationSummary;
	}
}

package ru.bpc.sv2.mastercom.api.types.claim.response;

import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.util.Date;

public class MasterComCaseFilingRespHistory implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	private String memo;
	private String action;
	private Date responseDate;

	public String getMemo() {
		return memo;
	}

	public void setMemo(String memo) {
		this.memo = memo;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public Date getResponseDate() {
		return responseDate;
	}

	public void setResponseDate(Date responseDate) {
		this.responseDate = responseDate;
	}
}

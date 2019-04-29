package ru.bpc.sv2.ps.cup;

import java.io.Serializable;
import java.util.Date;

public class CupDisputeFilter implements Serializable {
	private String pan;
	private Long sessionId;
	private Long transAmount;
	private Long transAmountTo;
	private Date transmissionDate;
	private Date transmissionDateTo;
	private String rrn;

	public String getPan() {
		return pan;
	}

	public void setPan(String pan) {
		this.pan = pan;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Long getTransAmount() {
		return transAmount;
	}

	public void setTransAmount(Long transAmount) {
		this.transAmount = transAmount;
	}

	public Long getTransAmountTo() {
		return transAmountTo;
	}

	public void setTransAmountTo(Long transAmountTo) {
		this.transAmountTo = transAmountTo;
	}

	public Date getTransmissionDate() {
		return transmissionDate;
	}

	public void setTransmissionDate(Date transmissionDate) {
		this.transmissionDate = transmissionDate;
	}

	public Date getTransmissionDateTo() {
		return transmissionDateTo;
	}

	public void setTransmissionDateTo(Date transmissionDateTo) {
		this.transmissionDateTo = transmissionDateTo;
	}

	public String getRrn() {
		return rrn;
	}

	public void setRrn(String rrn) {
		this.rrn = rrn;
	}
}

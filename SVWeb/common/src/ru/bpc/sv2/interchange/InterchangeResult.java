package ru.bpc.sv2.interchange;

import java.math.BigDecimal;

public class InterchangeResult {
	private long operId;
	private BigDecimal feeAmount;
	private String feeCurrency;
	private String rrn;
	private String feeType;

	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public String getRrn() {
		return rrn;
	}

	public void setRrn(String rrn) {
		this.rrn = rrn;
	}

	public long getOperId() {
		return operId;
	}

	public void setOperId(long operId) {
		this.operId = operId;
	}

	public BigDecimal getFeeAmount() {
		return feeAmount;
	}

	public void setFeeAmount(BigDecimal feeAmount) {
		this.feeAmount = feeAmount;
	}

	public String getFeeCurrency() {
		return feeCurrency;
	}

	public void setFeeCurrency(String feeCurrency) {
		this.feeCurrency = feeCurrency;
	}
}

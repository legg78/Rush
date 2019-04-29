package ru.bpc.sv2.ps.visa;

import java.math.BigDecimal;

public class VisaVssReportDetailV2 extends AbstractVisaVssReportDetail<VisaVssReportDetailV2> {
	
	private static final long serialVersionUID = 1L;
	
	private String businessMode;
	private String amountType;
	private Long transCount;
	private BigDecimal creditAmount;
	private BigDecimal debitAmount;
	private BigDecimal netAmount;

	public String getBusinessMode() {
		return businessMode;
	}

	public void setBusinessMode(String businessMode) {
		this.businessMode = businessMode;
	}

	public String getAmountType() {
		return amountType;
	}

	public void setAmountType(String amountType) {
		this.amountType = amountType;
	}

	public Long getTransCount() {
		return transCount;
	}

	public void setTransCount(Long transCount) {
		this.transCount = transCount;
	}

	public BigDecimal getCreditAmount() {
		return creditAmount;
	}

	public void setCreditAmount(BigDecimal creditAmount) {
		this.creditAmount = creditAmount;
	}

	public BigDecimal getDebitAmount() {
		return debitAmount;
	}

	public void setDebitAmount(BigDecimal debitAmount) {
		this.debitAmount = debitAmount;
	}

	public BigDecimal getNetAmount() {
		return netAmount;
	}

	public void setNetAmount(BigDecimal netAmount) {
		this.netAmount = netAmount;
	}

	@Override
	public boolean hasValues() {
		return hasValue(getTransCount()) || hasValue(getCreditAmount()) || hasValue(getDebitAmount()) || hasValue(getNetAmount());
	}
}

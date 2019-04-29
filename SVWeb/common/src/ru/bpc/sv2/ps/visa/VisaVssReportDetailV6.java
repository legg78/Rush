package ru.bpc.sv2.ps.visa;

import java.math.BigDecimal;
import java.util.Date;

public class VisaVssReportDetailV6 extends AbstractVisaVssReportDetail<VisaVssReportDetailV6> {

	private static final long serialVersionUID = 1L;
	
	private String businessMode;
	private String summaryLevel;
	private String businessTransType;
	private String businessTransCycle;
	private String transDisposition;
	private BigDecimal transCount;
	private BigDecimal amount;
	private Date crsDate;

	public String getBusinessMode() {
		return businessMode;
	}

	public void setBusinessMode(String businessMode) {
		this.businessMode = businessMode;
	}

	public String getSummaryLevel() {
		return summaryLevel;
	}

	public void setSummaryLevel(String summaryLevel) {
		this.summaryLevel = summaryLevel;
	}

	public String getBusinessTransType() {
		return businessTransType;
	}

	public void setBusinessTransType(String businessTransType) {
		this.businessTransType = businessTransType;
	}

	public String getBusinessTransCycle() {
		return businessTransCycle;
	}

	public void setBusinessTransCycle(String businessTransCycle) {
		this.businessTransCycle = businessTransCycle;
	}

	public String getTransDisposition() {
		return transDisposition;
	}

	public void setTransDisposition(String transDisposition) {
		this.transDisposition = transDisposition;
	}

	public BigDecimal getTransCount() {
		return transCount;
	}

	public void setTransCount(BigDecimal transCount) {
		this.transCount = transCount;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public boolean isSummary() {
		return getSummaryLevel() != null && !getSummaryLevel().equals("08");
	}

	public Date getCrsDate() {
		return crsDate;
	}

	public void setCrsDate(Date crsDate) {
		this.crsDate = crsDate;
	}

	@Override
	public boolean hasValues() {
		return hasValue(getTransCount()) || hasValue(getAmount());
	}
}

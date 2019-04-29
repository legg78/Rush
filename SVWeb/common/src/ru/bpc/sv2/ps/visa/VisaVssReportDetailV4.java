package ru.bpc.sv2.ps.visa;

import java.math.BigDecimal;
import java.util.Date;

public class VisaVssReportDetailV4 extends AbstractVisaVssReportDetail<VisaVssReportDetailV4> {

	private static final long serialVersionUID = 1L;
	
	private String businessMode;
	private String summaryLevel;
	private String businessTransType;
	private String chargeType;
	private String businessTransCycle;
	private String jurisdiction;
	private String routing;
	private String srcCountry;
	private String dstCountry;
	private String srcRegion;
	private String dstRegion;
	private String feeLevel;
	private Long firstCount;
	private BigDecimal firstAmount;
	private BigDecimal secondAmount;
	private BigDecimal thirdAmount;
	private Date currencyTableDate;

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

	public String getJurisdiction() {
		return jurisdiction;
	}

	public void setJurisdiction(String jurisdiction) {
		this.jurisdiction = jurisdiction;
	}

	public String getRouting() {
		return routing;
	}

	public void setRouting(String routing) {
		this.routing = routing;
	}

	public String getSrcCountry() {
		return srcCountry;
	}

	public void setSrcCountry(String srcCountry) {
		this.srcCountry = srcCountry;
	}

	public String getDstCountry() {
		return dstCountry;
	}

	public void setDstCountry(String dstCountry) {
		this.dstCountry = dstCountry;
	}

	public String getSrcRegion() {
		return srcRegion;
	}

	public void setSrcRegion(String srcRegion) {
		this.srcRegion = srcRegion;
	}

	public String getDstRegion() {
		return dstRegion;
	}

	public void setDstRegion(String dstRegion) {
		this.dstRegion = dstRegion;
	}

	public String getFeeLevel() {
		return feeLevel;
	}

	public void setFeeLevel(String feeLevel) {
		this.feeLevel = feeLevel;
	}

	public Long getFirstCount() {
		return firstCount;
	}

	public void setFirstCount(Long firstCount) {
		this.firstCount = firstCount;
	}

	public BigDecimal getFirstAmount() {
		return firstAmount;
	}

	public void setFirstAmount(BigDecimal firstAmount) {
		this.firstAmount = firstAmount;
	}

	public BigDecimal getSecondAmount() {
		return secondAmount;
	}

	public void setSecondAmount(BigDecimal secondAmount) {
		this.secondAmount = secondAmount;
	}

	public BigDecimal getThirdAmount() {
		return thirdAmount;
	}

	public void setThirdAmount(BigDecimal thirdAmount) {
		this.thirdAmount = thirdAmount;
	}

	public Date getCurrencyTableDate() {
		return currencyTableDate;
	}

	public void setCurrencyTableDate(Date currencyTableDate) {
		this.currencyTableDate = currencyTableDate;
	}

	public String getChargeType() {
		return chargeType;
	}

	public void setChargeType(String chargeType) {
		this.chargeType = chargeType;
	}

	public String getCountryOrRegion() {
		if (getSrcCountry() != null)
			return getSrcCountry() + getDstCountry();
		if (getSrcRegion() != null)
			return getSrcRegion() + getDstRegion();
		return null;
	}

	@Override
	public boolean hasValues() {
		return hasValue(getFirstCount()) || hasValue(getFirstAmount()) || hasValue(getSecondAmount()) || hasValue(getThirdAmount());
	}
}

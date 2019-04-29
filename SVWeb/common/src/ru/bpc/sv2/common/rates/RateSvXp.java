package ru.bpc.sv2.common.rates;

import in.bpc.sv.svxp.CurrencyScale;

import java.util.Date;

public class RateSvXp {
	private Integer instId;
	private String rateType;
	private Date effectiveDate;
	private Date expirationDate;
	private CurrencyScale dstCurrency;
	private CurrencyScale srcCurrency;
	private Float rate;
	private Integer inverted;
	
	public Integer getInstId() {
		return instId;
	}
	
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getRateType() {
		return rateType;
	}

	public void setRateType(String rateType) {
		this.rateType = rateType;
	}

	public Date getEffectiveDate() {
		return effectiveDate;
	}

	public void setEffectiveDate(Date effectiveDate) {
		this.effectiveDate = effectiveDate;
	}

	public Date getExpirationDate() {
		return expirationDate;
	}

	public void setExpirationDate(Date expirationDate) {
		this.expirationDate = expirationDate;
	}

	public CurrencyScale getDstCurrency() {
		return dstCurrency;
	}

	public void setDstCurrency(CurrencyScale dstCurrency) {
		this.dstCurrency = dstCurrency;
	}

	public Float getRate() {
		return rate;
	}

	public void setRate(Float rate) {
		this.rate = rate;
	}

	public Integer getInverted() {
		return inverted;
	}

	public void setInverted(Integer inverted) {
		this.inverted = inverted;
	}

	public CurrencyScale getSrcCurrency() {
		return srcCurrency;
	}

	public void setSrcCurrency(CurrencyScale srcCurrency) {
		this.srcCurrency = srcCurrency;
	}
	

}

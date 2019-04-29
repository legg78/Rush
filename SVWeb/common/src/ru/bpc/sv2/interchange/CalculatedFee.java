package ru.bpc.sv2.interchange;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class CalculatedFee {
	private long id;
	private Long criteriaId;
	private String criteriaName;
	private BigDecimal feeAmount;
	private String feeCurrency;
	private Timestamp calcDate;
	private String feeType;

	public String getCriteriaName() {
		return criteriaName;
	}

	public void setCriteriaName(String criteriaName) {
		this.criteriaName = criteriaName;
	}

	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public Long getCriteriaId() {
		return criteriaId;
	}

	public void setCriteriaId(Long criteriaId) {
		this.criteriaId = criteriaId;
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

	public Timestamp getCalcDate() {
		return calcDate;
	}

	public void setCalcDate(Timestamp calcDate) {
		this.calcDate = calcDate;
	}
}

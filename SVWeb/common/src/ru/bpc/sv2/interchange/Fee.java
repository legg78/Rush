package ru.bpc.sv2.interchange;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;


public class Fee implements Serializable, ModelIdentifiable {
	private Long id;
	private Integer type;
	private BigDecimal percent;
	private BigDecimal amount;
	private String currency;
	private Integer sourceAmount;
	private String destinationCurrency;
	private String module;

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getType() {
		return type;
	}

	public void setType(Integer type) {
		this.type = type;
	}

	public BigDecimal getPercent() {
		return percent;
	}

	public void setPercent(BigDecimal percent) {
		this.percent = percent;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Integer getSourceAmount() {
		return sourceAmount;
	}

	public void setSourceAmount(Integer sourceAmount) {
		this.sourceAmount = sourceAmount;
	}

	public String getDestinationCurrency() {
		return destinationCurrency;
	}

	public void setDestinationCurrency(String destinationCurrency) {
		this.destinationCurrency = destinationCurrency;
	}

	public Double getCurrencyAmount() {
		if (amount != null) {
			return amount.divide(new BigDecimal(100.0)).doubleValue();
		}
		return null;
	}

	@Override
	public Object getModelId() {
		return id;
	}
}

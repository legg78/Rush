package ru.bpc.sv2.atm;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AtmCashIn implements Serializable, ModelIdentifiable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer terminalId;
	private Double faceValue;
	private String currency;
	private String denominationCode;
	private Boolean isActive;
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}

	public Double getFaceValue() {
		return faceValue;
	}

	public void setFaceValue(Double faceValue) {
		this.faceValue = faceValue;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getDenominationCode() {
		return denominationCode;
	}

	public void setDenominationCode(String denominationCode) {
		this.denominationCode = denominationCode;
	}

	public Boolean getIsActive() {
		return isActive;
	}

	public void setIsActive(Boolean isActive) {
		this.isActive = isActive;
	}

	public Object getModelId() {
		return getId();
	}

}

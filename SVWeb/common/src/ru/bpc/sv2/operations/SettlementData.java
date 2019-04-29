package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.math.BigDecimal;

/**
 * Represents data for "Settlements" tab of "Operations" page
 * @author Alexeev
 * @see ru.bpc.sv2.operations.Operation
 */
public class SettlementData implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String sttlType;
	private BigDecimal sttlAmount;
	private String sttlCurrency;
	
	public String getSttlType() {
		return sttlType;
	}
	
	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}
	
	public BigDecimal getSttlAmount() {
		return sttlAmount;
	}
	
	public void setSttlAmount(BigDecimal sttlAmount) {
		this.sttlAmount = sttlAmount;
	}
	
	public String getSttlCurrency() {
		return sttlCurrency;
	}
	
	public void setSttlCurrency(String sttlCurrency) {
		this.sttlCurrency = sttlCurrency;
	}
	
}

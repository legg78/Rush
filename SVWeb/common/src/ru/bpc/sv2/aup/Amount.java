package ru.bpc.sv2.aup;

import java.io.Serializable;
import java.math.BigDecimal;

import javax.xml.datatype.XMLGregorianCalendar;

public class Amount implements Serializable {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Long operId;
	protected BigDecimal amountValue;
	protected String amountType;
	protected String amountTypeDesc;
    protected String currency;
    protected XMLGregorianCalendar convertDate;
    protected BigDecimal convertRate;
    
    public BigDecimal getAmountValue() {
		return amountValue;
	}

	public void setAmountValue(BigDecimal amountValue) {
		this.amountValue = amountValue;
	}

	public String getAmountType() {
		return amountType;
	}

	public void setAmountType(String amountType) {
		this.amountType = amountType;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public XMLGregorianCalendar getConvertDate() {
		return convertDate;
	}

	public void setConvertDate(XMLGregorianCalendar convertDate) {
		this.convertDate = convertDate;
	}

	public BigDecimal getConvertRate() {
		return convertRate;
	}

	public void setConvertRate(BigDecimal convertRate) {
		this.convertRate = convertRate;
	}

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public String getAmountTypeDesc() {
		return amountTypeDesc;
	}

	public void setAmountTypeDesc(String amountTypeDesc) {
		this.amountTypeDesc = amountTypeDesc;
	}

	public Object getModelId() {
		return getOperId().toString() + getAmountType() + getCurrency();
	}
}

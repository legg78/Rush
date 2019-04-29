package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditInvoicePayment implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;
	
	private Long id;
	private Long invoiceId;
	private Double amount;
	private String currency;
	private String macrosType;
	private Date operDate;
	private String operType;
	
	private String merchantName;
	private String merchantCity;
	private String merchantCountry;
	private String merchantStreet;
	
	private Double operAmount;
	private String operCurrency;
	
	private Date operDateFrom;
	private Date operDateTo;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getInvoiceId() {
		return invoiceId;
	}

	public void setInvoiceId(Long invoiceId) {
		this.invoiceId = invoiceId;
	}

	public Double getAmount() {
		return amount;
	}

	public void setAmount(Double amount) {
		this.amount = amount;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getMacrosType() {
		return macrosType;
	}

	public void setMacrosType(String macrosType) {
		this.macrosType = macrosType;
	}

	public Date getOperDate() {
		return operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getMerchantCity() {
		return merchantCity;
	}

	public void setMerchantCity(String merchantCity) {
		this.merchantCity = merchantCity;
	}

	public String getMerchantCountry() {
		return merchantCountry;
	}

	public void setMerchantCountry(String merchantCountry) {
		this.merchantCountry = merchantCountry;
	}

	public String getMerchantStreet() {
		return merchantStreet;
	}

	public void setMerchantSreet(String merchantStreet) {
		this.merchantStreet = merchantStreet;
	}

	public Double getOperAmount() {
		return operAmount;
	}

	public void setOperAmount(Double operAmount) {
		this.operAmount = operAmount;
	}

	public String getOperCurrency() {
		return operCurrency;
	}

	public void setOperCurrency(String operCurrency) {
		this.operCurrency = operCurrency;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public Date getOperDateFrom() {
		return operDateFrom;
	}

	public void setOperDateFrom(Date operDateFrom) {
		this.operDateFrom = operDateFrom;
	}

	public Date getOperDateTo() {
		return operDateTo;
	}

	public void setOperDateTo(Date operDateTo) {
		this.operDateTo = operDateTo;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}

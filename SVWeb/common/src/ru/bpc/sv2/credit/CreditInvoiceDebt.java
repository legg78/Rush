package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditInvoiceDebt implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;
	
	private Long id;
	private Long invoiceId;
	private BigDecimal amount;
	private String currency;
	private Integer macrosTypeId;
	private String macrosTypeName;
    private String amountPurpose;
	private Date operDate;
	private String operType;
	private String merchantName;
	private String merchantCity;
	private String merchantCountry;
	private String merchantStreet;
	
	private BigDecimal operAmount;
	private String operCurrency;
	
	private String cardNumber;
	
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
	
	public Integer getMacrosTypeId() {
		return macrosTypeId;
	}

	public void setMacrosTypeId(Integer macrosTypeId) {
		this.macrosTypeId = macrosTypeId;
	}

	public String getMacrosTypeName() {
		return macrosTypeName;
	}

	public void setMacrosTypeName(String macrosTypeName) {
		this.macrosTypeName = macrosTypeName;
	}

	public String getAmountPurpose() {
		return amountPurpose;
	}

	public void setAmountPurpose(String amountPurpose) {
		this.amountPurpose = amountPurpose;
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

	public void setMerchantStreet(String merchantStreet) {
		this.merchantStreet = merchantStreet;
	}

	public BigDecimal getOperAmount() {
		return operAmount;
	}

	public void setOperAmount(BigDecimal operAmount) {
		this.operAmount = operAmount;
	}

	public String getOperCurrency() {
		return operCurrency;
	}

	public void setOperCurrency(String operCurrency) {
		this.operCurrency = operCurrency;
	}

	public String getCardNumber() {
		return cardNumber;
	}

	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
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

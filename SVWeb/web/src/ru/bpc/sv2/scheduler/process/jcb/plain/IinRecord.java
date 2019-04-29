package ru.bpc.sv2.scheduler.process.jcb.plain;

public class IinRecord {
	private Integer iinLength;
	private String iinPrefix;
	private String licenseeId;
	private String issuerName;
	private String brandSign;
	private Integer primaryAccountNumberLength;
	private String cardProduct;
	private String cardGrade;
	private String issuerCountry;
	private String currencyCode;
	private String dccIndicator;
	private String retailIndicator;
	private String atmIndicator;
	private String atmRoute;

	public Integer getIinLength() {
		return iinLength;
	}

	public void setIinLength(Integer iinLength) {
		this.iinLength = iinLength;
	}

	public String getIinPrefix() {
		return iinPrefix;
	}

	public void setIinPrefix(String iinPrefix) {
		this.iinPrefix = iinPrefix;
	}

	public String getLicenseeId() {
		return licenseeId;
	}

	public void setLicenseeId(String licenseeId) {
		this.licenseeId = licenseeId;
	}

	public String getIssuerName() {
		return issuerName;
	}

	public void setIssuerName(String issuerName) {
		this.issuerName = issuerName;
	}

	public String getBrandSign() {
		return brandSign;
	}

	public void setBrandSign(String brandSign) {
		this.brandSign = brandSign;
	}

	public Integer getPrimaryAccountNumberLength() {
		return primaryAccountNumberLength;
	}

	public void setPrimaryAccountNumberLength(Integer primaryAccountNumberLength) {
		this.primaryAccountNumberLength = primaryAccountNumberLength;
	}

	public String getCardProduct() {
		return cardProduct;
	}

	public void setCardProduct(String cardProduct) {
		this.cardProduct = cardProduct;
	}

	public String getCardGrade() {
		return cardGrade;
	}

	public void setCardGrade(String cardGrade) {
		this.cardGrade = cardGrade;
	}

	public String getIssuerCountry() {
		return issuerCountry;
	}

	public void setIssuerCountry(String issuerCountry) {
		this.issuerCountry = issuerCountry;
	}

	public String getCurrencyCode() {
		return currencyCode;
	}

	public void setCurrencyCode(String currencyCode) {
		this.currencyCode = currencyCode;
	}

	public String getDccIndicator() {
		return dccIndicator;
	}

	public void setDccIndicator(String dccIndicator) {
		this.dccIndicator = dccIndicator;
	}

	public String getRetailIndicator() {
		return retailIndicator;
	}

	public void setRetailIndicator(String retailIndicator) {
		this.retailIndicator = retailIndicator;
	}

	public String getAtmIndicator() {
		return atmIndicator;
	}

	public void setAtmIndicator(String atmIndicator) {
		this.atmIndicator = atmIndicator;
	}

	public String getAtmRoute() {
		return atmRoute;
	}

	public void setAtmRoute(String atmRoute) {
		this.atmRoute = atmRoute;
	}
}

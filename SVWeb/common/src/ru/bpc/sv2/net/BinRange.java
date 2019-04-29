package ru.bpc.sv2.net;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class BinRange implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private String rowId; // used for uniqueness
	protected String panLow;
	protected String panHigh;
	protected Integer priority;
	protected Integer cardTypeId;
	protected String country;
	protected Integer panLength;
	protected Integer cardNetworkId;
	protected Integer cardInstId;
	protected Integer issNetworkId;
	protected Integer issInstId;
	protected String countryName;
	protected String cardNetworkName;
	protected String cardInstName;
	protected String issNetworkName;
	protected String issInstName;
	protected String lang;
	protected String issHostName;
	protected String cardTypeName;
	protected String moduleCode;

	public Object getModelId() {
		
		return getRowId();
	}

	public String getRowId() {
		return rowId;
	}

	public void setRowId(String rowId) {
		this.rowId = rowId;
	}

	public String getPanLow() {
		return panLow;
	}

	public void setPanLow(String panLow) {
		this.panLow = panLow;
	}

	public String getPanHigh() {
		return panHigh;
	}

	public void setPanHigh(String panHigh) {
		this.panHigh = panHigh;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public Integer getCardTypeId() {
		return cardTypeId;
	}

	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public String getCountry() {
		return country;
	}

	public void setCountry(String country) {
		this.country = country;
	}

	public Integer getPanLength() {
		return panLength;
	}

	public void setPanLength(Integer panLength) {
		this.panLength = panLength;
	}

	public Integer getCardNetworkId() {
		return cardNetworkId;
	}

	public void setCardNetworkId(Integer cardNetworkId) {
		this.cardNetworkId = cardNetworkId;
	}

	public Integer getCardInstId() {
		return cardInstId;
	}

	public void setCardInstId(Integer cardInstId) {
		this.cardInstId = cardInstId;
	}

	public Integer getIssNetworkId() {
		return issNetworkId;
	}

	public void setIssNetworkId(Integer issNetworkId) {
		this.issNetworkId = issNetworkId;
	}

	public Integer getIssInstId() {
		return issInstId;
	}

	public void setIssInstId(Integer issInstId) {
		this.issInstId = issInstId;
	}

	public String getCountryName() {
		return countryName;
	}

	public void setCountryName(String countryName) {
		this.countryName = countryName;
	}

	public String getCardNetworkName() {
		return cardNetworkName;
	}

	public void setCardNetworkName(String cardNetworkName) {
		this.cardNetworkName = cardNetworkName;
	}

	public String getCardInstName() {
		return cardInstName;
	}

	public void setCardInstName(String cardInstName) {
		this.cardInstName = cardInstName;
	}

	public String getIssNetworkName() {
		return issNetworkName;
	}

	public void setIssNetworkName(String issNetworkName) {
		this.issNetworkName = issNetworkName;
	}

	public String getIssInstName() {
		return issInstName;
	}

	public void setIssInstName(String issInstName) {
		this.issInstName = issInstName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getIssHostName() {
		return issHostName;
	}

	public void setIssHostName(String issHostName) {
		this.issHostName = issHostName;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}

	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public String getModuleCode() {
		return moduleCode;
	}

	public void setModuleCode(String moduleCode) {
		this.moduleCode = moduleCode;
	}

	@Override
	public BinRange clone() throws CloneNotSupportedException {
		
		return (BinRange) super.clone();
	}
}

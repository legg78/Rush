package ru.bpc.sv2.operations;

import java.io.Serializable;

/**
 * Represents data for "Acquirer data" tab of "Operations" page
 * @author Alexeev
 * @see ru.bpc.sv2.operations.Operation
 */
public class AcquirerData implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private Integer acqInstId;
	private Integer terminalId;
	private String terminalNumber;
	private String terminalType;
	private Integer merchantId;
	private String merchantNumber;
	private String merchantName;
	private String merchantPostCode;
	private String merchantCountryCode;
	private String merchantCountryName;
	private String merchantRegion;
	private String merchantCity;
	private String merchantStreet;
	private String mccCode;
	private String mccName;
	private String acqInstName;
	
	public Integer getAcqInstId() {
		return acqInstId;
	}
	
	public void setAcqInstId(Integer acqInstId) {
		this.acqInstId = acqInstId;
	}

	public Integer getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}

	public String getTerminalNumber() {
		return terminalNumber;
	}

	public void setTerminalNumber(String terminalNumber) {
		this.terminalNumber = terminalNumber;
	}

	public String getTerminalType() {
		return terminalType;
	}

	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}

	public Integer getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(Integer merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantNumber() {
		return merchantNumber;
	}

	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getMerchantPostCode() {
		return merchantPostCode;
	}

	public void setMerchantPostCode(String merchantPostCode) {
		this.merchantPostCode = merchantPostCode;
	}

	public String getMerchantCountryCode() {
		return merchantCountryCode;
	}

	public void setMerchantCountryCode(String merchantCountryCode) {
		this.merchantCountryCode = merchantCountryCode;
	}

	public String getMerchantRegion() {
		return merchantRegion;
	}

	public void setMerchantRegion(String merchantRegion) {
		this.merchantRegion = merchantRegion;
	}

	public String getMerchantCity() {
		return merchantCity;
	}

	public void setMerchantCity(String merchantCity) {
		this.merchantCity = merchantCity;
	}

	public String getMerchantStreet() {
		return merchantStreet;
	}

	public void setMerchantStreet(String merchantStreet) {
		this.merchantStreet = merchantStreet;
	}

	public String getMccCode() {
		return mccCode;
	}

	public void setMccCode(String mccCode) {
		this.mccCode = mccCode;
	}

	public String getMccName() {
		return mccName;
	}

	public void setMccName(String mccName) {
		this.mccName = mccName;
	}

	public String getMerchantCountryName() {
		return merchantCountryName;
	}

	public void setMerchantCountryName(String merchantCountryName) {
		this.merchantCountryName = merchantCountryName;
	}

	public String getAcqInstName() {
		return acqInstName;
	}

	public void setAcqInstName(String acqInstName) {
		this.acqInstName = acqInstName;
	}
}

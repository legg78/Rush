package ru.bpc.sv2.acquiring;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Address;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Terminal implements ModelIdentifiable, Serializable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private boolean isTemplate;
	private Integer merchantId;
	private String terminalNumber;
	private String terminalName;
	private Integer standardId;
	private String plasticNumber;
	private String terminalType;
	private String cardDataInputCap;
	private String crdhAuthCap;
	private String cardCaptureCap;
	private String termOperatingEnv;
	private String crdhDataPresent;
	private String cardDataPresent;
	private String cardDataInputMode;
	private String crdhAuthMethod;
	private String crdhAuthEntity;
	private String cardDataOutputCap;
	private String termDataOutputCap;
	private String pinCaptureCap;
	private String status;
	private Integer productId;
	private Integer instId;
	private Integer agentId;
	private Integer seqNum;
	private Boolean isMac;
	private String name;
	private String description;
	private String lang;
	private Integer gmtOffset;
	private String catLevel;
	private Integer deviceId;
	private String merchantName;
	private String institutionName;
	private String productName;
	private Long contractId;
	private String contractNumber;
	private String contractName;
	private Long customerId;
	private String customerNumber;
	private String customerType;
	//for displaying on UI component <bm:selectCustomer>
	private String custInfo;
	private String merchantNumber;
	private String productType;
	
	private Integer profileId;
	private String profileName;
	private String address;
	private Integer ferrNo;
	private Long authId;
	
	private Address addressObj;
	private Merchant merchantObj;
	
	private String mcc;
	private String mccName;
	
	private Boolean cashDispenserPresent;
	private Boolean paymentPossibility;
	private Boolean useCardPossibility;
	private Boolean cashInPresent;
	private Integer availableNetwork;
	private Integer availableOperation;
	private Integer availableCurrency;
	private String availableNetworkName;
	private String availableOperationName;
	private String availableCurrencyName;
	private Long mccTemplateId;
    private String productNumber;
    private String terminalProfile;
    private String  pinBlockFormat;

	private Boolean instalmentSupport;

	private String statusReason;

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getId() {
		return id;
	}

	public boolean isTemplate() {
		return isTemplate;
	}

	public void setTemplate(boolean isTemplate) {
		this.isTemplate = isTemplate;
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

	public String getPlasticNumber() {
		return plasticNumber;
	}

	public void setPlasticNumber(String plasticNumber) {
		this.plasticNumber = plasticNumber;
	}

	public String getCardDataInputCap() {
		return cardDataInputCap;
	}

	public void setCardDataInputCap(String cardDataInputCap) {
		this.cardDataInputCap = cardDataInputCap;
	}

	public String getCrdhAuthCap() {
		return crdhAuthCap;
	}

	public void setCrdhAuthCap(String crdhAuthCap) {
		this.crdhAuthCap = crdhAuthCap;
	}

	public String getCardCaptureCap() {
		return cardCaptureCap;
	}

	public void setCardCaptureCap(String cardCaptureCap) {
		this.cardCaptureCap = cardCaptureCap;
	}

	public String getTermOperatingEnv() {
		return termOperatingEnv;
	}

	public void setTermOperatingEnv(String termOperatingEnv) {
		this.termOperatingEnv = termOperatingEnv;
	}

	public String getCrdhDataPresent() {
		return crdhDataPresent;
	}

	public void setCrdhDataPresent(String crdhDataPresent) {
		this.crdhDataPresent = crdhDataPresent;
	}

	public String getCardDataPresent() {
		return cardDataPresent;
	}

	public void setCardDataPresent(String cardDataPresent) {
		this.cardDataPresent = cardDataPresent;
	}

	public String getCardDataInputMode() {
		return cardDataInputMode;
	}

	public void setCardDataInputMode(String cardDataInputMode) {
		this.cardDataInputMode = cardDataInputMode;
	}

	public String getCrdhAuthMethod() {
		return crdhAuthMethod;
	}

	public void setCrdhAuthMethod(String crdhAuthMethod) {
		this.crdhAuthMethod = crdhAuthMethod;
	}

	public String getCrdhAuthEntity() {
		return crdhAuthEntity;
	}

	public void setCrdhAuthEntity(String crdhAuthEntity) {
		this.crdhAuthEntity = crdhAuthEntity;
	}

	public String getCardDataOutputCap() {
		return cardDataOutputCap;
	}

	public void setCardDataOutputCap(String cardDataOutputCap) {
		this.cardDataOutputCap = cardDataOutputCap;
	}

	public String getTermDataOutputCap() {
		return termDataOutputCap;
	}

	public void setTermDataOutputCap(String termDataOutputCap) {
		this.termDataOutputCap = termDataOutputCap;
	}

	public String getPinCaptureCap() {
		return pinCaptureCap;
	}

	public void setPinCaptureCap(String pinCaptureCap) {
		this.pinCaptureCap = pinCaptureCap;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Object getModelId() {
		return getId();
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getInstitutionName() {
		return institutionName;
	}

	public void setInstitutionName(String institutionName) {
		this.institutionName = institutionName;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public Boolean getIsMac() {
		return isMac;
	}

	public void setIsMac(Boolean isMac) {
		this.isMac = isMac;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getGmtOffset() {
		return gmtOffset;
	}

	public void setGmtOffset(Integer gmtOffset) {
		this.gmtOffset = gmtOffset;
	}

	public String getCatLevel() {
		return catLevel;
	}

	public void setCatLevel(String catLevel) {
		this.catLevel = catLevel;
	}

	public Integer getDeviceId() {
		return deviceId;
	}

	public void setDeviceId(Integer deviceId) {
		this.deviceId = deviceId;
	}

	public Integer getProfileId() {
		return profileId;
	}

	public void setProfileId(Integer profileId) {
		this.profileId = profileId;
	}

	public String getProfileName() {
		return profileName;
	}

	public void setProfileName(String profileName) {
		this.profileName = profileName;
	}

	public Long getContractId() {
		return contractId;
	}

	public void setContractId(Long contractId) {
		this.contractId = contractId;
	}


	public String getContractNumber() {
		return contractNumber;
	}

	public void setContractNumber(String contractNumber) {
		this.contractNumber = contractNumber;
	}

	public String getContractName() {
		return contractName;
	}

	public void setContractName(String contractName) {
		this.contractName = contractName;
	}

	/**
	 * For UI needs
	 * @return
	 */
	public boolean isPositiveOffset() {
		return gmtOffset != null && gmtOffset.intValue() > 0;
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Long getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public String getMerchantNumber() {
		return merchantNumber;
	}

	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getProductType() {
		return productType;
	}

	public void setProductType(String productType) {
		this.productType = productType;
	}

	public Integer getFerrNo() {
		return ferrNo;
	}

	public void setFerrNo(Integer ferrNo) {
		this.ferrNo = ferrNo;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getMcc() {
		return mcc;
	}

	public void setMcc(String mcc) {
		this.mcc = mcc;
	}

	public String getMccName() {
		return mccName;
	}

	public void setMccName(String mccName) {
		this.mccName = mccName;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}

	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public String getCustInfo() {
		return custInfo;
	}

	public void setCustInfo(String custInfo) {
		this.custInfo = custInfo;
	}

	public Integer getAgentId() {
		return agentId;
	}

	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public Long getAuthId() {
		return authId;
	}

	public void setAuthId(Long authId) {
		this.authId = authId;
	}

	public Address getAddressObj() {
		return addressObj;
	}

	public void setAddressObj(Address addressObj) {
		this.addressObj = addressObj;
	}

	public Merchant getMerchantObj() {
		return merchantObj;
	}

	public void setMerchantObj(Merchant merchantObj) {
		this.merchantObj = merchantObj;
	}

	public String getTerminalName() {
		return terminalName;
	}

	public void setTerminalName(String terminalName) {
		this.terminalName = terminalName;
	}

	public String getCustomerType() {
		return customerType;
	}

	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	public Boolean getCashDispenserPresent() {
		return cashDispenserPresent;
	}

	public void setCashDispenserPresent(Boolean cashDispenserPresent) {
		this.cashDispenserPresent = cashDispenserPresent;
	}

	public Boolean getPaymentPossibility() {
		return paymentPossibility;
	}

	public void setPaymentPossibility(Boolean paymentPossibility) {
		this.paymentPossibility = paymentPossibility;
	}

	public Boolean getUseCardPossibility() {
		return useCardPossibility;
	}

	public void setUseCardPossibility(Boolean useCardPossibility) {
		this.useCardPossibility = useCardPossibility;
	}

	public Boolean getCashInPresent() {
		return cashInPresent;
	}

	public void setCashInPresent(Boolean cashInPresent) {
		this.cashInPresent = cashInPresent;
	}

	public Integer getAvailableNetwork() {
		return availableNetwork;
	}

	public void setAvailableNetwork(Integer availableNetwork) {
		this.availableNetwork = availableNetwork;
	}

	public Integer getAvailableOperation() {
		return availableOperation;
	}

	public void setAvailableOperation(Integer availableOperation) {
		this.availableOperation = availableOperation;
	}

	public Integer getAvailableCurrency() {
		return availableCurrency;
	}

	public void setAvailableCurrency(Integer availableCurrency) {
		this.availableCurrency = availableCurrency;
	}

	public String getAvailableNetworkName() {
		return availableNetworkName;
	}

	public void setAvailableNetworkName(String availableNetworkName) {
		this.availableNetworkName = availableNetworkName;
	}

	public String getAvailableOperationName() {
		return availableOperationName;
	}

	public void setAvailableOperationName(String availableOperationName) {
		this.availableOperationName = availableOperationName;
	}

	public String getAvailableCurrencyName() {
		return availableCurrencyName;
	}

	public void setAvailableCurrencyName(String availableCurrencyName) {
		this.availableCurrencyName = availableCurrencyName;
	}

	public Long getMccTemplateId() {
		return mccTemplateId;
	}

	public void setMccTemplateId(Long mccTemplateId) {
		this.mccTemplateId = mccTemplateId;
	}

    public String getProductNumber() {
        return productNumber;
    }

    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }


	public String getTerminalProfile() {
		return terminalProfile;
	}

	public void setTerminalProfile(String terminalProfile) {
		this.terminalProfile = terminalProfile;
	}

	public String getPinBlockFormat() {
		return pinBlockFormat;
	}

	public void setPinBlockFormat(String pinBlockFormat) {
		this.pinBlockFormat = pinBlockFormat;
	}

	public Boolean getInstalmentSupport() {
		return instalmentSupport;
	}

	public void setInstalmentSupport(Boolean instalmentSupport) {
		this.instalmentSupport = instalmentSupport;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		result.put("instId", this.getInstId());
		result.put("terminalType", this.getTerminalType());
		result.put("standardId", this.getStandardId());
		result.put("status", this.getStatus());
		result.put("gmtOffset", this.getGmtOffset());
		result.put("mccTemplateId", this.getMccTemplateId());
		result.put("isMac", this.getIsMac());
		result.put("cardDataPresent", this.getCardDataPresent());
		result.put("crdhDataPresent", this.getCrdhDataPresent());
		result.put("cardDataInputCap", this.getCardDataInputCap());
		result.put("crdhAuthCap", this.getCrdhAuthCap());
		result.put("cardDataInputMode", this.getCardDataInputMode());
		result.put("crdhAuthMethod", this.getCrdhAuthMethod());
		result.put("cardCaptureCap", this.getCardCaptureCap());
		result.put("crdhAuthEntity", this.getCrdhAuthEntity());
		result.put("cardDataOutputCap", this.getCardDataOutputCap());
		result.put("pinCaptureCap", this.getPinCaptureCap());
		result.put("termOperatingEnv", this.getTermOperatingEnv());
		result.put("catLevel", this.getCatLevel());
		result.put("termDataOutputCap", this.getTermDataOutputCap());
		result.put("availableNetwork", this.getAvailableNetwork());
		result.put("availableOperation", this.getAvailableOperation());
		result.put("availableCurrency", this.getAvailableCurrency());
		result.put("cashDispenserPresent", this.getCashDispenserPresent());
		result.put("paymentPossibility", this.getPaymentPossibility());
		result.put("useCardPossibility", this.getUseCardPossibility());
		result.put("cashInPresent", this.getCashInPresent());
		result.put("terminalProfile", this.getTerminalProfile());
		result.put("pinBlockFormat", this.getPinBlockFormat());
		
		return result;
	}
}

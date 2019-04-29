package ru.bpc.sv2.aut;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class Authorization implements ModelIdentifiable, Serializable {
	private static final long serialVersionUID = 1L;

	private Long id;
    private String respCode;
    private String procType;
    private String procMode;
    private Boolean isAdvice;
    private Boolean isRepeat;
    private String isCompleted;
    private BigDecimal binAmount;
    private String binCurrency;
    private BigDecimal binCnvtRate;
    private BigDecimal networkAmount;
    private String networkCurrency;
    private Date networkCnvtDate;
    private BigDecimal networkCnvtRate;
    private BigDecimal accountCnvtRate;
    private Long parentId;
    private String addrVerifResult;
    private Integer issNetworkDeviceId;
    private Integer acqDeviceId;
    private String acqRespCode;
    private String acqDeviceProcResult;
    private String catLevel;
    private String cardDataInputCap;
    private String crdhAuthCap;
    private String cardCaptureCap;
    private String terminalOperatingEnv;
    private String crdhPresence;
    private String cardPresence;
    private String cardDataInputMode;
    private String crdhAuthMethod;
    private String crdhAuthEntity;
    private String cardDataOutputCap;
    private String terminalOutputCap;
    private String pinCaptureCap;
    private String pinPresence;
    private String cvv2Presence;
    private String cvcIndicator;
    private String posEntryMode;
    private String posCondCode;
    private String emvData;
    private String atc;
    private String tvr;
    private String cvr;
    private String addlData;
    private String serviceCode;
    private String deviceDate;
    private String cvv2Result;
    private String certificateMethod;
    private String certificateType;
    private String merchantCertif;
    private String cardholderCertif;
    private String ucafIndicator;
    private Boolean isEarlyEmv;

    private String issDeviceName;
    private String acqDeviceName;
	private String externalAuthId;
	private String externalOrigId;
	private Long authPurposeId;
    
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}

	public String getProcType() {
		return procType;
	}

	public void setProcType(String procType) {
		this.procType = procType;
	}

	public String getProcMode() {
		return procMode;
	}

	public void setProcMode(String procMode) {
		this.procMode = procMode;
	}

	public Boolean getIsAdvice() {
		return isAdvice;
	}

	public void setIsAdvice(Boolean isAdvice) {
		this.isAdvice = isAdvice;
	}

	public Boolean getIsRepeat() {
		return isRepeat;
	}

	public void setIsRepeat(Boolean isRepeat) {
		this.isRepeat = isRepeat;
	}

	public String getIsCompleted() {
		return isCompleted;
	}

	public void setIsCompleted(String isCompleted) {
		this.isCompleted = isCompleted;
	}

	public BigDecimal getBinAmount() {
		return binAmount;
	}

	public void setBinAmount(BigDecimal binAmount) {
		this.binAmount = binAmount;
	}

	public String getBinCurrency() {
		return binCurrency;
	}

	public void setBinCurrency(String binCurrency) {
		this.binCurrency = binCurrency;
	}

	public BigDecimal getBinCnvtRate() {
		return binCnvtRate;
	}

	public void setBinCnvtRate(BigDecimal binCnvtRate) {
		this.binCnvtRate = binCnvtRate;
	}

	public BigDecimal getNetworkAmount() {
		return networkAmount;
	}

	public void setNetworkAmount(BigDecimal networkAmount) {
		this.networkAmount = networkAmount;
	}

	public String getNetworkCurrency() {
		return networkCurrency;
	}

	public void setNetworkCurrency(String networkCurrency) {
		this.networkCurrency = networkCurrency;
	}

	public Date getNetworkCnvtDate() {
		return networkCnvtDate;
	}

	public void setNetworkCnvtDate(Date networkCnvtDate) {
		this.networkCnvtDate = networkCnvtDate;
	}

	public BigDecimal getNetworkCnvtRate() {
		return networkCnvtRate;
	}

	public void setNetworkCnvtRate(BigDecimal networkCnvtRate) {
		this.networkCnvtRate = networkCnvtRate;
	}

	public BigDecimal getAccountCnvtRate() {
		return accountCnvtRate;
	}

	public void setAccountCnvtRate(BigDecimal accountCnvtRate) {
		this.accountCnvtRate = accountCnvtRate;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getAddrVerifResult() {
		return addrVerifResult;
	}

	public void setAddrVerifResult(String addrVerifResult) {
		this.addrVerifResult = addrVerifResult;
	}

	public Integer getIssNetworkDeviceId() {
		return issNetworkDeviceId;
	}

	public void setIssNetworkDeviceId(Integer issNetworkDeviceId) {
		this.issNetworkDeviceId = issNetworkDeviceId;
	}

	public Integer getAcqDeviceId() {
		return acqDeviceId;
	}

	public void setAcqDeviceId(Integer acqDeviceId) {
		this.acqDeviceId = acqDeviceId;
	}

	public String getAcqRespCode() {
		return acqRespCode;
	}

	public void setAcqRespCode(String acqRespCode) {
		this.acqRespCode = acqRespCode;
	}

	public String getAcqDeviceProcResult() {
		return acqDeviceProcResult;
	}

	public void setAcqDeviceProcResult(String acqDeviceProcResult) {
		this.acqDeviceProcResult = acqDeviceProcResult;
	}

	public String getCatLevel() {
		return catLevel;
	}

	public void setCatLevel(String catLevel) {
		this.catLevel = catLevel;
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

	public String getTerminalOperatingEnv() {
		return terminalOperatingEnv;
	}

	public void setTerminalOperatingEnv(String terminalOperatingEnv) {
		this.terminalOperatingEnv = terminalOperatingEnv;
	}

	public String getCrdhPresence() {
		return crdhPresence;
	}

	public void setCrdhPresence(String crdhPresence) {
		this.crdhPresence = crdhPresence;
	}

	public String getCardPresence() {
		return cardPresence;
	}

	public void setCardPresence(String cardPresence) {
		this.cardPresence = cardPresence;
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

	public String getTerminalOutputCap() {
		return terminalOutputCap;
	}

	public void setTerminalOutputCap(String terminalOutputCap) {
		this.terminalOutputCap = terminalOutputCap;
	}

	public String getPinCaptureCap() {
		return pinCaptureCap;
	}

	public void setPinCaptureCap(String pinCaptureCap) {
		this.pinCaptureCap = pinCaptureCap;
	}

	public String getPinPresence() {
		return pinPresence;
	}

	public void setPinPresence(String pinPresence) {
		this.pinPresence = pinPresence;
	}

	public String getCvv2Presence() {
		return cvv2Presence;
	}

	public void setCvv2Presence(String cvv2Presence) {
		this.cvv2Presence = cvv2Presence;
	}

	public String getCvcIndicator() {
		return cvcIndicator;
	}

	public void setCvcIndicator(String cvcIndicator) {
		this.cvcIndicator = cvcIndicator;
	}

	public String getPosEntryMode() {
		return posEntryMode;
	}

	public void setPosEntryMode(String posEntryMode) {
		this.posEntryMode = posEntryMode;
	}

	public String getPosCondCode() {
		return posCondCode;
	}

	public void setPosCondCode(String posCondCode) {
		this.posCondCode = posCondCode;
	}

	public String getEmvData() {
		return emvData;
	}

	public void setEmvData(String emvData) {
		this.emvData = emvData;
	}

	public String getAtc() {
		return atc;
	}

	public void setAtc(String atc) {
		this.atc = atc;
	}

	public String getTvr() {
		return tvr;
	}

	public void setTvr(String tvr) {
		this.tvr = tvr;
	}

	public String getCvr() {
		return cvr;
	}

	public void setCvr(String cvr) {
		this.cvr = cvr;
	}

	public String getAddlData() {
		return addlData;
	}

	public void setAddlData(String addlData) {
		this.addlData = addlData;
	}

	public String getServiceCode() {
		return serviceCode;
	}

	public void setServiceCode(String serviceCode) {
		this.serviceCode = serviceCode;
	}

	public String getDeviceDate() {
		return deviceDate;
	}

	public void setDeviceDate(String deviceDate) {
		this.deviceDate = deviceDate;
	}

	public String getCvv2Result() {
		return cvv2Result;
	}

	public void setCvv2Result(String cvv2Result) {
		this.cvv2Result = cvv2Result;
	}

	public String getCertificateMethod() {
		return certificateMethod;
	}

	public void setCertificateMethod(String certificateMethod) {
		this.certificateMethod = certificateMethod;
	}

	public String getCertificateType() {
		return certificateType;
	}

	public void setCertificateType(String certificateType) {
		this.certificateType = certificateType;
	}

	public String getMerchantCertif() {
		return merchantCertif;
	}

	public void setMerchantCertif(String merchantCertif) {
		this.merchantCertif = merchantCertif;
	}

	public String getCardholderCertif() {
		return cardholderCertif;
	}

	public void setCardholderCertif(String cardholderCertif) {
		this.cardholderCertif = cardholderCertif;
	}

	public String getUcafIndicator() {
		return ucafIndicator;
	}

	public void setUcafIndicator(String ucafIndicator) {
		this.ucafIndicator = ucafIndicator;
	}

	public Boolean getIsEarlyEmv() {
		return isEarlyEmv;
	}

	public void setIsEarlyEmv(Boolean isEarlyEmv) {
		this.isEarlyEmv = isEarlyEmv;
	}

	public String getIssDeviceName() {
		return issDeviceName;
	}

	public void setIssDeviceName(String issDeviceName) {
		this.issDeviceName = issDeviceName;
	}

	public String getAcqDeviceName() {
		return acqDeviceName;
	}

	public void setAcqDeviceName(String acqDeviceName) {
		this.acqDeviceName = acqDeviceName;
	}

	public String getExternalAuthId() {
		return externalAuthId;
	}

	public void setExternalAuthId(String externalAuthId) {
		this.externalAuthId = externalAuthId;
	}

	public String getExternalOrigId() {
		return externalOrigId;
	}

	public void setExternalOrigId(String externalOrigId) {
		this.externalOrigId = externalOrigId;
	}

	public Long getAuthPurposeId() {
		return authPurposeId;
	}

	public void setAuthPurposeId(Long authPurposeId) {
		this.authPurposeId = authPurposeId;
	}
}

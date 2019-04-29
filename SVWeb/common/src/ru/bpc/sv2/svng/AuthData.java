package ru.bpc.sv2.svng;

import javax.xml.datatype.XMLGregorianCalendar;
import java.util.ArrayList;
import java.util.List;

/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class AuthData {

	private Long operId;
	private String respCode;
	private String procType;
	private String procMode;
	private Short isAdvice;
	private Short isRepeat;
	private Long binAmount;
	private String binCurrency;
	private Long binCnvtRate;
	private Long networkAmount;
	private String networkCurrency;
	private String networkCnvtDate;
	private Long networkCnvtRate;
	private Long accountCnvtRate;
	private String addrVerifResult;
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
	private Short isEarlyEmv;
	private String isCompleted;
	private String amounts;
	private String systemTraceAuditNumber;
	private String transactionId;
	private String externalAuthId;
	private String externalOrigId;
	private String agentUniqueId;
	private String nativeRespCode;
	private String traceNumber;
	private Long authPurposeId;

	private List<AuthTag> authTags;
	private List<AupTag> aupTags;

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
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

	public Short getIsAdvice() {
		return isAdvice;
	}

	public void setIsAdvice(Short isAdvice) {
		this.isAdvice = isAdvice;
	}

	public Short getIsRepeat() {
		return isRepeat;
	}

	public void setIsRepeat(Short isRepeat) {
		this.isRepeat = isRepeat;
	}

	public Long getBinAmount() {
		return binAmount;
	}

	public void setBinAmount(Long binAmount) {
		this.binAmount = binAmount;
	}

	public String getBinCurrency() {
		return binCurrency;
	}

	public void setBinCurrency(String binCurrency) {
		this.binCurrency = binCurrency;
	}

	public Long getBinCnvtRate() {
		return binCnvtRate;
	}

	public void setBinCnvtRate(Long binCnvtRate) {
		this.binCnvtRate = binCnvtRate;
	}

	public Long getNetworkAmount() {
		return networkAmount;
	}

	public void setNetworkAmount(Long networkAmount) {
		this.networkAmount = networkAmount;
	}

	public String getNetworkCurrency() {
		return networkCurrency;
	}

	public void setNetworkCurrency(String networkCurrency) {
		this.networkCurrency = networkCurrency;
	}

	public String getNetworkCnvtDate() {
		return networkCnvtDate;
	}

	public void setNetworkCnvtDate(String networkCnvtDate) {
		this.networkCnvtDate = networkCnvtDate;
	}

	public Long getNetworkCnvtRate() {
		return networkCnvtRate;
	}

	public void setNetworkCnvtRate(Long networkCnvtRate) {
		this.networkCnvtRate = networkCnvtRate;
	}

	public Long getAccountCnvtRate() {
		return accountCnvtRate;
	}

	public void setAccountCnvtRate(Long accountCnvtRate) {
		this.accountCnvtRate = accountCnvtRate;
	}

	public String getAddrVerifResult() {
		return addrVerifResult;
	}

	public void setAddrVerifResult(String addrVerifResult) {
		this.addrVerifResult = addrVerifResult;
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

	public Short getIsEarlyEmv() {
		return isEarlyEmv;
	}

	public void setIsEarlyEmv(Short isEarlyEmv) {
		this.isEarlyEmv = isEarlyEmv;
	}

	public String getIsCompleted() {
		return isCompleted;
	}

	public void setIsCompleted(String isCompleted) {
		this.isCompleted = isCompleted;
	}

	public String getAmounts() {
		return amounts;
	}

	public void setAmounts(String amounts) {
		this.amounts = amounts;
	}

	public String getSystemTraceAuditNumber() {
		return systemTraceAuditNumber;
	}

	public void setSystemTraceAuditNumber(String systemTraceAuditNumber) {
		this.systemTraceAuditNumber = systemTraceAuditNumber;
	}

	public String getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
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

	public String getAgentUniqueId() {
		return agentUniqueId;
	}

	public void setAgentUniqueId(String agentUniqueId) {
		this.agentUniqueId = agentUniqueId;
	}

	public String getNativeRespCode() {
		return nativeRespCode;
	}

	public void setNativeRespCode(String nativeRespCode) {
		this.nativeRespCode = nativeRespCode;
	}

	public String getTraceNumber() {
		return traceNumber;
	}

	public void setTraceNumber(String traceNumber) {
		this.traceNumber = traceNumber;
	}

	public Long getAuthPurposeId() {
		return authPurposeId;
	}

	public void setAuthPurposeId(Long authPurposeId) {
		this.authPurposeId = authPurposeId;
	}

	public List<AuthTag> getAuthTags() {
		return authTags;
	}

	public void setAuthTags(List<AuthTag> authTags) {
		this.authTags = authTags;
	}

	public List<AupTag> getAupTags() {
		return aupTags;
	}

	public void setAupTags(List<AupTag> aupTags) {
		this.aupTags = aupTags;
	}

	public static AuthData from(Long operId, ru.bpc.sv.svxp.clearing.AuthData source) {
		AuthData result = new AuthData();

		result.setOperId(operId);
		result.setAccountCnvtRate(source.getAccountCnvtRate());
		result.setAcqDeviceProcResult(source.getAcqDeviceProcResult());
		result.setAcqRespCode(source.getAcqRespCode());
		result.setAddlData(source.getAddlData());
		result.setAddrVerifResult(source.getAddrVerifResult());
		result.setAgentUniqueId(source.getAgentUniqueId());
		result.setAmounts(source.getAmounts());
		//result.setAtc();
		result.setAuthPurposeId(source.getAuthPurposeId());
		result.setBinAmount(source.getBinAmount());
		result.setBinCnvtRate(source.getBinCnvtRate());
		result.setBinCurrency(source.getBinCurrency());
		result.setCardCaptureCap(source.getCardCaptureCap());
		result.setCardDataInputCap(source.getCardDataInputCap());
		result.setCardDataInputMode(source.getCardDataInputMode());
		result.setCardDataOutputCap(source.getCardDataOutputCap());
		//result.setCardholderCertif();
		result.setCardPresence(source.getCardPresence());
		//result.setCatLevel();
		//result.setCertificateMethod();
		//result.setCertificateType();
		result.setCrdhAuthCap(source.getCrdhAuthCap());
		result.setCrdhAuthEntity(source.getCrdhAuthEntity());
		result.setCrdhAuthMethod(source.getCrdhAuthMethod());
		result.setCrdhPresence(source.getCrdhPresence());
		result.setCvcIndicator(source.getCvcIndicator());
		//result.setCvr();
		result.setCvv2Presence(source.getCvv2Presence());
		result.setCvv2Result(source.getCvv2Result());
		result.setDeviceDate(source.getDeviceDate() != null ? source.getDeviceDate().toXMLFormat() : null);
		result.setEmvData(source.getEmvData());
		result.setExternalAuthId(source.getExternalAuthId());
		result.setExternalOrigId(source.getExternalOrigId());
		result.setIsAdvice(source.getIsAdvice() != null ? source.getIsAdvice().shortValue() : null);
		result.setIsCompleted(source.getIsCompleted());
		//result.setIsEarlyEmv();
		result.setIsRepeat(source.getIsRepeat() != null ? source.getIsRepeat().shortValue() : null);
		//result.setMerchantCertif();
		result.setNativeRespCode(source.getNativeRespCode());
		result.setNetworkAmount(source.getNetworkAmount());
		result.setNetworkCnvtDate(source.getNetworkCnvtDate() != null ? source.getNetworkCnvtDate().toXMLFormat() : null);
		result.setNetworkCnvtRate(source.getNetworkCnvtRate());
		result.setNetworkCurrency(source.getNetworkCurrency());
		result.setPinCaptureCap(source.getPinCaptureCap());
		result.setPinPresence(source.getPinPresence());
		result.setPosCondCode(source.getPosCondCode());
		result.setPosEntryMode(source.getPosEntryMode());
		result.setProcMode(source.getProcMode());
		result.setProcType(source.getProcType());
		result.setRespCode(source.getRespCode());
		result.setServiceCode(source.getServiceCode());
		result.setSystemTraceAuditNumber(source.getSystemTraceAuditNumber());
		result.setTerminalOperatingEnv(source.getTerminalOperatingEnv());
		result.setTerminalOutputCap(source.getTerminalOutputCap());
		//result.setTraceNumber();
		result.setTransactionId(source.getAuthTransactionId());
		//result.setTvr();
		//result.setUcafIndicator();

		if (source.getAuthTag() != null) {
			List<AuthTag> tags = new ArrayList<AuthTag>();
			List<AupTag> aupTags = new ArrayList<AupTag>();
			for (ru.bpc.sv.svxp.clearing.AuthTag sourceTag: source.getAuthTag()) {
				AuthTag resultTag = new AuthTag(operId);
				resultTag.setTagId(sourceTag.getTagId());
				resultTag.setTagName(sourceTag.getTagName());
				resultTag.setTagValue(sourceTag.getTagValue());
				tags.add(resultTag);
				AupTag resultAupTag = new AupTag(sourceTag.getTagId()
						, sourceTag.getTagName()
						, sourceTag.getTagValue()
						, sourceTag.getSeqNumber());
				aupTags.add(resultAupTag);
			}
			result.setAuthTags(tags);
			result.setAupTags(aupTags);
		}

		return result;
	}
}

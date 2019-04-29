package ru.bpc.sv2.ps.cup;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class CupFinMessage implements Serializable, ModelIdentifiable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private String acceptorId;
	private String acceptorName;
	private String acceptorTermId;
	private String agencyId;
	private String appAlternChar;
	private String appTransCnt;
	private String appVersionNum;
	private Long authAmount;
	private Date authDate;
	private Long authId;
	private String authMethod;
	private String authRespId;
	private Double billExchRate;
	private String capacityOfTerm;
	private Long cardSerialNum;
	private String cardholderAccCurrency;
	private Long cardholderBillAmount;
	private String cipherTextInfo;
	private String collectOnlyFlag;
	private String cryptogram;
	private Long cupsNotice;
	private String cupsRefNum;
	private String currencyCode;
	private String dedicDocName;
	private Boolean doubleMessageId;
	private Long fileId;
	private String fileName;
	private Integer hostInstId;
	private String icConditionCode;
	private String icPosInputMode;
	private String icTransCurrencyCode;
	private Integer instId;
	private String intOrg;
	private String interfaceSerial;
	private Boolean isIncoming;
	private Boolean isInvalid;
	private Boolean isRejected;
	private Boolean isReversal;
	private String issBankAppData;
	private Boolean issue;
	private String issueCode;
	private Boolean local;
	private String merchantCountry;
	private String merchCat;
	private Integer msgNumber;
	private Integer networkId;
	private Long operId;
	private Long originalId;
	private String origTransData;
	private Long otherAmount;
	private String pan;
	private String paymentServiceType;
	private String posConditionCode;
	private String posInputMode;
	private String readCapacity;
	private String reasonCode;
	private String receiveInstId;
	private String refNum;
	private String scriptResult;
	private String sendInstId;
	private String serviceFeeAmount;
	private String serviceFeeCurrency;
	private Long serviceFeeExchRate;
	private Long sessionId;
	private Long settlementAmount;
	private String settlementCurrency;
	private Double settlementExchRate;
	private String status;
	private Long sysTraceNum;
	private String termCat;
	private Integer termCountryCode;
	private String termVerifResult;
	private Date terminalAuthDate;
	private Boolean transferred;
	private Long transAmount;
	private Long transAmountTo;
	private Long transCat;
	private String transCode;
	private String transCurrencyCode;
	private Date transDate;
	private Date transDateTo;
	private String transFeaturesId;
	private Long transInitChannel;
	private String transRespCode;
	private String transSerialCnt;
	private String unpredNumber;
	private String b2bBusinessType;
	private String b2bPaymentMedium;

	public String getB2bBusinessType() {
	    return b2bBusinessType;
	}

	public void setB2bBusinessType(String b2bBusinessType) {
	    this.b2bBusinessType = b2bBusinessType;
	}

	public String getB2bPaymentMedium() {
	    return b2bPaymentMedium;
	}

	public void setB2bPaymentMedium(String b2bPaymentMedium) {
	    this.b2bPaymentMedium = b2bPaymentMedium;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Boolean getLocal() {
		return local;
	}

	public void setLocal(Boolean local) {
		this.local = local;
	}

	public String getIcTransCurrencyCode() {
		return icTransCurrencyCode;
	}

	public void setIcTransCurrencyCode(String icTransCurrencyCode) {
		this.icTransCurrencyCode = icTransCurrencyCode;
	}

	public String getIcPosInputMode() {
		return icPosInputMode;
	}

	public void setIcPosInputMode(String icPosInputMode) {
		this.icPosInputMode = icPosInputMode;
	}

	public Date getTransDateTo() {
		return transDateTo;
	}

	public void setTransDateTo(Date transDateTo) {
		this.transDateTo = transDateTo;
	}

	public Long getTransAmountTo() {
		return transAmountTo;
	}

	public void setTransAmountTo(Long transAmountTo) {
		this.transAmountTo = transAmountTo;
	}

	public Boolean getTransferred() {
		return transferred;
	}

	public void setTransferred(Boolean transferred) {
		this.transferred = transferred;
	}

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
	}
	
	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Boolean getIssue() {
		return issue;
	}

	public void setIssue(Boolean issue) {
		this.issue = issue;
	}

	public String getTransCode() {
		return transCode;
	}

	public void setTransCode(String transCode) {
		this.transCode = transCode;
	}

	public String getPan() {
		return pan;
	}

	public void setPan(String pan) {
		this.pan = pan;
	}

	public String getAuthRespId() {
		return authRespId;
	}

	public void setAuthRespId(String authRespId) {
		this.authRespId = authRespId;
	}

	public String getAgencyId() {
		return agencyId;
	}

	public void setAgencyId(String agencyId) {
		this.agencyId = agencyId;
	}

	public String getSendInstId() {
		return sendInstId;
	}

	public void setSendInstId(String sendInstId) {
		this.sendInstId = sendInstId;
	}

	public String getReceiveInstId() {
		return receiveInstId;
	}

	public void setReceiveInstId(String receiveInstId) {
		this.receiveInstId = receiveInstId;
	}

	public String getAcceptorTermId() {
		return acceptorTermId;
	}

	public void setAcceptorTermId(String acceptorTermId) {
		this.acceptorTermId = acceptorTermId;
	}

	public String getAcceptorId() {
		return acceptorId;
	}

	public void setAcceptorId(String acceptorId) {
		this.acceptorId = acceptorId;
	}

	public String getAcceptorName() {
		return acceptorName;
	}

	public void setAcceptorName(String acceptorName) {
		this.acceptorName = acceptorName;
	}

	public String getOrigTransData() {
		return origTransData;
	}

	public void setOrigTransData(String origTransData) {
		this.origTransData = origTransData;
	}

	public String getReasonCode() {
		return reasonCode;
	}

	public void setReasonCode(String reasonCode) {
		this.reasonCode = reasonCode;
	}

	public String getIssueCode() {
		return issueCode;
	}

	public void setIssueCode(String issueCode) {
		this.issueCode = issueCode;
	}

	public String getTransFeaturesId() {
		return transFeaturesId;
	}

	public void setTransFeaturesId(String transFeaturesId) {
		this.transFeaturesId = transFeaturesId;
	}

	public String getPosInputMode() {
		return posInputMode;
	}

	public void setPosInputMode(String posInputMode) {
		this.posInputMode = posInputMode;
	}

	public Long getAuthId() {
		return authId;
	}

	public void setAuthId(Long authId) {
		this.authId = authId;
	}

	public String getPaymentServiceType() {
		return paymentServiceType;
	}

	public void setPaymentServiceType(String paymentServiceType) {
		this.paymentServiceType = paymentServiceType;
	}

	public String getServiceFeeAmount() {
		return serviceFeeAmount;
	}

	public void setServiceFeeAmount(String serviceFeeAmount) {
		if (serviceFeeAmount != null && !serviceFeeAmount.isEmpty()) {
			this.serviceFeeAmount = serviceFeeAmount.substring(1);
		}
	}

	public String getIntOrg() {
		return intOrg;
	}

	public void setIntOrg(String intOrg) {
		this.intOrg = intOrg;
	}

	public String getCryptogram() {
		return cryptogram;
	}

	public void setCryptogram(String cryptogram) {
		this.cryptogram = cryptogram;
	}

	public String getReadCapacity() {
		return readCapacity;
	}

	public void setReadCapacity(String readCapacity) {
		this.readCapacity = readCapacity;
	}

	public String getIcConditionCode() {
		return icConditionCode;
	}

	public void setIcConditionCode(String icConditionCode) {
		this.icConditionCode = icConditionCode;
	}

	public String getCapacityOfTerm() {
		return capacityOfTerm;
	}

	public void setCapacityOfTerm(String capacityOfTerm) {
		this.capacityOfTerm = capacityOfTerm;
	}

	public String getTermVerifResult() {
		return termVerifResult;
	}

	public void setTermVerifResult(String termVerifResult) {
		this.termVerifResult = termVerifResult;
	}

	public String getInterfaceSerial() {
		return interfaceSerial;
	}

	public void setInterfaceSerial(String interfaceSerial) {
		this.interfaceSerial = interfaceSerial;
	}

	public String getIssBankAppData() {
		return issBankAppData;
	}

	public void setIssBankAppData(String issBankAppData) {
		this.issBankAppData = issBankAppData;
	}

	public String getAppTransCnt() {
		return appTransCnt;
	}

	public void setAppTransCnt(String appTransCnt) {
		this.appTransCnt = appTransCnt;
	}

	public String getAppAlternChar() {
		return appAlternChar;
	}

	public void setAppAlternChar(String appAlternChar) {
		this.appAlternChar = appAlternChar;
	}

	public String getScriptResult() {
		return scriptResult;
	}

	public void setScriptResult(String scriptResult) {
		this.scriptResult = scriptResult;
	}

	public String getCipherTextInfo() {
		return cipherTextInfo;
	}

	public void setCipherTextInfo(String cipherTextInfo) {
		this.cipherTextInfo = cipherTextInfo;
	}

	public String getAuthMethod() {
		return authMethod;
	}

	public void setAuthMethod(String authMethod) {
		this.authMethod = authMethod;
	}

	public String getTermCat() {
		return termCat;
	}

	public void setTermCat(String termCat) {
		this.termCat = termCat;
	}

	public String getDedicDocName() {
		return dedicDocName;
	}

	public void setDedicDocName(String dedicDocName) {
		this.dedicDocName = dedicDocName;
	}

	public String getAppVersionNum() {
		return appVersionNum;
	}

	public void setAppVersionNum(String appVersionNum) {
		this.appVersionNum = appVersionNum;
	}

	public String getTransSerialCnt() {
		return transSerialCnt;
	}

	public void setTransSerialCnt(String transSerialCnt) {
		this.transSerialCnt = transSerialCnt;
	}

	public Boolean getDoubleMessageId() {
		return doubleMessageId;
	}

	public void setDoubleMessageId(Boolean doubleMessageId) {
		this.doubleMessageId = doubleMessageId;
	}

	public Long getCupsNotice() {
		return cupsNotice;
	}

	public void setCupsNotice(Long cupsNotice) {
		this.cupsNotice = cupsNotice;
	}

	public Long getTransInitChannel() {
		return transInitChannel;
	}

	public void setTransInitChannel(Long transInitChannel) {
		this.transInitChannel = transInitChannel;
	}

	public String getCurrencyCode() {
		return currencyCode;
	}

	public void setCurrencyCode(String currencyCode) {
		this.currencyCode = currencyCode;
	}

	public String getSettlementCurrency() {
		return settlementCurrency;
	}

	public void setSettlementCurrency(String settlementCurrency) {
		this.settlementCurrency = settlementCurrency;
	}

	public String getCardholderAccCurrency() {
		return cardholderAccCurrency;
	}

	public void setCardholderAccCurrency(String cardholderAccCurrency) {
		this.cardholderAccCurrency = cardholderAccCurrency;
	}

	public String getServiceFeeCurrency() {
		return serviceFeeCurrency;
	}

	public void setServiceFeeCurrency(String serviceFeeCurrency) {
		this.serviceFeeCurrency = serviceFeeCurrency;
	}

	public Long getCardSerialNum() {
		return cardSerialNum;
	}

	public void setCardSerialNum(Long cardSerialNum) {
		this.cardSerialNum = cardSerialNum;
	}

	public Integer getTermCountryCode() {
		return termCountryCode;
	}

	public void setTermCountryCode(Integer termCountryCode) {
		this.termCountryCode = termCountryCode;
	}

	public String getTransRespCode() {
		return transRespCode;
	}

	public void setTransRespCode(String transRespCode) {
		this.transRespCode = transRespCode;
	}

	public Long getTransCat() {
		return transCat;
	}

	public void setTransCat(Long transCat) {
		this.transCat = transCat;
	}

	public String getTransCurrencyCode() {
		return transCurrencyCode;
	}

	public void setTransCurrencyCode(String transCurrencyCode) {
		this.transCurrencyCode = transCurrencyCode;
	}

	public Long getTransAmount() {
		return transAmount;
	}

	public void setTransAmount(Long transAmount) {
		this.transAmount = transAmount;
	}

	public Long getSysTraceNum() {
		return sysTraceNum;
	}

	public void setSysTraceNum(Long sysTraceNum) {
		this.sysTraceNum = sysTraceNum;
	}

	public String getRefNum() {
		return refNum;
	}

	public void setRefNum(String refNum) {
		this.refNum = refNum;
	}

	public String getMerchCat() {
		return merchCat;
	}

	public void setMerchCat(String merchCat) {
		this.merchCat = merchCat;
	}

	public String getCupsRefNum() {
		return cupsRefNum;
	}

	public void setCupsRefNum(String cupsRefNum) {
		this.cupsRefNum = cupsRefNum;
	}

	public Long getSettlementAmount() {
		return settlementAmount;
	}

	public void setSettlementAmount(Long settlementAmount) {
		this.settlementAmount = settlementAmount;
	}

	public Double getSettlementExchRate() {
		return settlementExchRate;
	}

	public void setSettlementExchRate(Double settlementExchRate) {
		this.settlementExchRate = settlementExchRate;
	}

	public Long getCardholderBillAmount() {
		return cardholderBillAmount;
	}

	public void setCardholderBillAmount(Long cardholderBillAmount) {
		this.cardholderBillAmount = cardholderBillAmount;
	}

	public Double getBillExchRate() {
		return billExchRate;
	}

	public void setBillExchRate(Double billExchRate) {
		this.billExchRate = billExchRate;
	}

	public Long getServiceFeeExchRate() {
		return serviceFeeExchRate;
	}

	public void setServiceFeeExchRate(Long serviceFeeExchRate) {
		this.serviceFeeExchRate = serviceFeeExchRate;
	}

	public Long getOtherAmount() {
		return otherAmount;
	}

	public void setOtherAmount(Long otherAmount) {
		this.otherAmount = otherAmount;
	}

	public String getUnpredNumber() {
		return unpredNumber;
	}

	public void setUnpredNumber(String unpredNumber) {
		this.unpredNumber = unpredNumber;
	}

	public Long getAuthAmount() {
		return authAmount;
	}

	public void setAuthAmount(Long authAmount) {
		this.authAmount = authAmount;
	}

	public Date getTransDate() {
		return transDate;
	}

	public void setTransDate(Date transDate) {
		this.transDate = transDate;
	}

	public Date getAuthDate() {
		return authDate;
	}

	public void setAuthDate(Date authDate) {
		this.authDate = authDate;
	}

	public Date getTerminalAuthDate() {
		return terminalAuthDate;
	}

	public void setTerminalAuthDate(Date terminalAuthDate) {
		this.terminalAuthDate = terminalAuthDate;
	}

	public String getCardMask() {
		if (pan != null && pan.length() >= 6) {
			StringBuilder sb = new StringBuilder(pan.substring(0, 6));
			while (sb.length() < pan.length() - 4) {
				sb.append('*');
			}
			sb.append(pan.substring(pan.length() - 4));
			return sb.toString();
		}
		return null;
	}

	public Boolean getOutgoing() {
		return isIncoming == null ? null : !isIncoming;
	}

	@Override
	public Object getModelId() {
		return operId == null ? refNum : operId;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Boolean getIsReversal() {
		return isReversal;
	}

	public void setIsReversal(Boolean isReversal) {
		this.isReversal = isReversal;
	}

	public Boolean getIsIncoming() {
		return isIncoming;
	}

	public void setIsIncoming(Boolean isIncoming) {
		this.isIncoming = isIncoming;
	}

	public Boolean getIsRejected() {
		return isRejected;
	}

	public void setIsRejected(Boolean isRejected) {
		this.isRejected = isRejected;
	}

	public Boolean getIsInvalid() {
		return isInvalid;
	}

	public void setIsInvalid(Boolean isInvalid) {
		this.isInvalid = isInvalid;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public Integer getHostInstId() {
		return hostInstId;
	}

	public void setHostInstId(Integer hostInstId) {
		this.hostInstId = hostInstId;
	}

	public String getCollectOnlyFlag() {
		return collectOnlyFlag;
	}

	public void setCollectOnlyFlag(String collectOnlyFlag) {
		this.collectOnlyFlag = collectOnlyFlag;
	}

	public Long getFileId() {
		return fileId;
	}

	public void setFileId(Long fileId) {
		this.fileId = fileId;
	}

	public Integer getMsgNumber() {
		return msgNumber;
	}

	public void setMsgNumber(Integer msgNumber) {
		this.msgNumber = msgNumber;
	}

	public String getMerchantCountry() {
		return merchantCountry;
	}

	public void setMerchantCountry(String merchantCountry) {
		this.merchantCountry = merchantCountry;
	}

	public Long getOriginalId() {
		return originalId;
	}

	public void setOriginalId(Long originalId) {
		this.originalId = originalId;
	}

	public String getPosConditionCode() {
		return posConditionCode;
	}

	public void setPosConditionCode(String posConditionCode) {
		this.posConditionCode = posConditionCode;
	}

	public String getFileName() {
		return fileName;
	}

	public void setFileName(String fileName) {
		this.fileName = fileName;
	}
}
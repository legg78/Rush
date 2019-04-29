package ru.bpc.sv2.ps.cup;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.sql.Timestamp;

public class CupAuth implements Serializable, ModelIdentifiable {
	private String rrn;
	private String acceptorIdCode;
	private String agencyId;
	private Long amtTran;
	private String appVersionNo;
	private String applCharact;
	private String applCrypt;
	private Long authAmount;
	private String authMethod;
	private String authRespId;
	private String capOfTerm;
	private Integer cardSerialNum;
	private String cipherTextInfData;
	private Integer codeOfTransCurrency;
	private Long confirmedSessionId;
	private String countryCodeOfTerm;
	private String dedicDocName;
	private String icCardCondCode;
	private String interfaceSerial;
	private String issBankAppData;
	private Integer mcc;
	private String mrcName;
	private Long operId;
	private Long otherAmount;
	private String pan;
	private String point;
	private String procFuncCode;
	private String readCapOfTerm;
	private String resultTermVerif;
	private Boolean reversal;
	private String scriptResultOfCardIssuer;
	private String sendingInstId;
	private Integer servInputModeCode;
	private Long sysTraceNum;
	private String termCat;
	private String termId;
	private String tranCurrCode;
	private Integer tranInitChannel;
	private Integer transCat;
	private String transCnt;
	private String transDate;
	private String transRespCode;
	private String transSerialCnt;
	private Integer transType;
	private Timestamp transmissionDateTime;
	private String unpredNum;

	public String getRrn() {
		return rrn;
	}

	public void setRrn(String rrn) {
		this.rrn = rrn;
	}

	public String getAcceptorIdCode() {
		return acceptorIdCode;
	}

	public void setAcceptorIdCode(String acceptorIdCode) {
		this.acceptorIdCode = acceptorIdCode;
	}

	public String getAgencyId() {
		return agencyId;
	}

	public void setAgencyId(String agencyId) {
		this.agencyId = agencyId;
	}

	public Long getAmtTran() {
		return amtTran;
	}

	public void setAmtTran(Long amtTran) {
		this.amtTran = amtTran;
	}

	public String getAppVersionNo() {
		return appVersionNo;
	}

	public void setAppVersionNo(String appVersionNo) {
		this.appVersionNo = appVersionNo;
	}

	public String getApplCharact() {
		return applCharact;
	}

	public void setApplCharact(String applCharact) {
		this.applCharact = applCharact;
	}

	public String getApplCrypt() {
		return applCrypt;
	}

	public void setApplCrypt(String applCrypt) {
		this.applCrypt = applCrypt;
	}

	public Long getAuthAmount() {
		return authAmount;
	}

	public void setAuthAmount(Long authAmount) {
		this.authAmount = authAmount;
	}

	public String getAuthMethod() {
		return authMethod;
	}

	public void setAuthMethod(String authMethod) {
		this.authMethod = authMethod;
	}

	public String getAuthRespId() {
		return authRespId;
	}

	public void setAuthRespId(String authRespId) {
		this.authRespId = authRespId;
	}

	public String getCapOfTerm() {
		return capOfTerm;
	}

	public void setCapOfTerm(String capOfTerm) {
		this.capOfTerm = capOfTerm;
	}

	public Integer getCardSerialNum() {
		return cardSerialNum;
	}

	public void setCardSerialNum(Integer cardSerialNum) {
		this.cardSerialNum = cardSerialNum;
	}

	public String getCipherTextInfData() {
		return cipherTextInfData;
	}

	public void setCipherTextInfData(String cipherTextInfData) {
		this.cipherTextInfData = cipherTextInfData;
	}

	public Integer getCodeOfTransCurrency() {
		return codeOfTransCurrency;
	}

	public void setCodeOfTransCurrency(Integer codeOfTransCurrency) {
		this.codeOfTransCurrency = codeOfTransCurrency;
	}

	public Long getConfirmedSessionId() {
		return confirmedSessionId;
	}

	public void setConfirmedSessionId(Long confirmedSessionId) {
		this.confirmedSessionId = confirmedSessionId;
	}

	public String getCountryCodeOfTerm() {
		return countryCodeOfTerm;
	}

	public void setCountryCodeOfTerm(String countryCodeOfTerm) {
		this.countryCodeOfTerm = countryCodeOfTerm;
	}

	public String getDedicDocName() {
		return dedicDocName;
	}

	public void setDedicDocName(String dedicDocName) {
		this.dedicDocName = dedicDocName;
	}

	public String getIcCardCondCode() {
		return icCardCondCode;
	}

	public void setIcCardCondCode(String icCardCondCode) {
		this.icCardCondCode = icCardCondCode;
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

	public Integer getMcc() {
		return mcc;
	}

	public void setMcc(Integer mcc) {
		this.mcc = mcc;
	}

	public String getMrcName() {
		return mrcName;
	}

	public void setMrcName(String mrcName) {
		this.mrcName = mrcName;
	}

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public Long getOtherAmount() {
		return otherAmount;
	}

	public void setOtherAmount(Long otherAmount) {
		this.otherAmount = otherAmount;
	}

	public String getPan() {
		return pan;
	}

	public void setPan(String pan) {
		this.pan = pan;
	}

	public String getPoint() {
		return point;
	}

	public void setPoint(String point) {
		this.point = point;
	}

	public String getProcFuncCode() {
		return procFuncCode;
	}

	public void setProcFuncCode(String procFuncCode) {
		this.procFuncCode = procFuncCode;
	}

	public String getReadCapOfTerm() {
		return readCapOfTerm;
	}

	public void setReadCapOfTerm(String readCapOfTerm) {
		this.readCapOfTerm = readCapOfTerm;
	}

	public String getResultTermVerif() {
		return resultTermVerif;
	}

	public void setResultTermVerif(String resultTermVerif) {
		this.resultTermVerif = resultTermVerif;
	}

	public Boolean getReversal() {
		return reversal;
	}

	public void setReversal(Boolean reversal) {
		this.reversal = reversal;
	}

	public String getScriptResultOfCardIssuer() {
		return scriptResultOfCardIssuer;
	}

	public void setScriptResultOfCardIssuer(String scriptResultOfCardIssuer) {
		this.scriptResultOfCardIssuer = scriptResultOfCardIssuer;
	}

	public String getSendingInstId() {
		return sendingInstId;
	}

	public void setSendingInstId(String sendingInstId) {
		this.sendingInstId = sendingInstId;
	}

	public Integer getServInputModeCode() {
		return servInputModeCode;
	}

	public void setServInputModeCode(Integer servInputModeCode) {
		this.servInputModeCode = servInputModeCode;
	}

	public Long getSysTraceNum() {
		return sysTraceNum;
	}

	public void setSysTraceNum(Long sysTraceNum) {
		this.sysTraceNum = sysTraceNum;
	}

	public String getTermCat() {
		return termCat;
	}

	public void setTermCat(String termCat) {
		this.termCat = termCat;
	}

	public String getTermId() {
		return termId;
	}

	public void setTermId(String termId) {
		this.termId = termId;
	}

	public String getTranCurrCode() {
		return tranCurrCode;
	}

	public void setTranCurrCode(String tranCurrCode) {
		this.tranCurrCode = tranCurrCode;
	}

	public Integer getTranInitChannel() {
		return tranInitChannel;
	}

	public void setTranInitChannel(Integer tranInitChannel) {
		this.tranInitChannel = tranInitChannel;
	}

	public Integer getTransCat() {
		return transCat;
	}

	public void setTransCat(Integer transCat) {
		this.transCat = transCat;
	}

	public String getTransCnt() {
		return transCnt;
	}

	public void setTransCnt(String transCnt) {
		this.transCnt = transCnt;
	}

	public String getTransDate() {
		return transDate;
	}

	public void setTransDate(String transDate) {
		this.transDate = transDate;
	}

	public String getTransRespCode() {
		return transRespCode;
	}

	public void setTransRespCode(String transRespCode) {
		this.transRespCode = transRespCode;
	}

	public String getTransSerialCnt() {
		return transSerialCnt;
	}

	public void setTransSerialCnt(String transSerialCnt) {
		this.transSerialCnt = transSerialCnt;
	}

	public Integer getTransType() {
		return transType;
	}

	public void setTransType(Integer transType) {
		this.transType = transType;
	}

	public Timestamp getTransmissionDateTime() {
		return transmissionDateTime;
	}

	public void setTransmissionDateTime(Timestamp transmissionDateTime) {
		this.transmissionDateTime = transmissionDateTime;
	}

	public String getUnpredNum() {
		return unpredNum;
	}

	public void setUnpredNum(String unpredNum) {
		this.unpredNum = unpredNum;
	}

	@Override
	public Object getModelId() {
		return rrn;
	}
}

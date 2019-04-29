package ru.bpc.sv2.ps.cup;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.utils.PanUtils;

import java.io.Serializable;
import java.sql.Timestamp;

public class CupDispute implements Serializable, ModelIdentifiable {
	private String acceptorsIdCode;
	private String acceptorsName;
	private String acceptorsTermId;
	private String agentIdCode;
	private String authRespCode;
	private String cardholderAccCurrency;
	private Long cardholderBillAmount;
	private Long cardholderBillExchRate;
	private String cardholderServiceFee;
	private Long clearOperId;
	private Long commissionPayable;
	private Long commissionReceivable;
	private Timestamp exchDate;
	private String interchangeServiceFee;
	private Boolean issuer;
	private Integer merchantType;
	private Integer messageType;
	private Integer origSysTraceNum;
	private Timestamp origTransDateTime;
	private String origTransProcCode;
	private String pan;
	private Integer posCondCode;
	private Integer posEntryMode;
	private Integer processingCode;
	private String receivingInnCode;
	private String responseCode;
	private String rrn;
	private String sendersIdCode;
	private Long sessionId;
	private Long sttlAmount;
	private String sttlCurrency;
	private Timestamp sttlDate;
	private Long sttlExchRate;
	private Long sysTraceNum;
	private Long transAmount;
	private String transCurrency;
	private Timestamp transmissionDate;

	public String getCardMask() {
		return PanUtils.mask(pan);
	}

	public String getAcceptorsIdCode() {
		return acceptorsIdCode;
	}

	public void setAcceptorsIdCode(String acceptorsIdCode) {
		this.acceptorsIdCode = acceptorsIdCode;
	}

	public String getAcceptorsName() {
		return acceptorsName;
	}

	public void setAcceptorsName(String acceptorsName) {
		this.acceptorsName = acceptorsName;
	}

	public String getAcceptorsTermId() {
		return acceptorsTermId;
	}

	public void setAcceptorsTermId(String acceptorsTermId) {
		this.acceptorsTermId = acceptorsTermId;
	}

	public String getAgentIdCode() {
		return agentIdCode;
	}

	public void setAgentIdCode(String agentIdCode) {
		this.agentIdCode = agentIdCode;
	}

	public String getAuthRespCode() {
		return authRespCode;
	}

	public void setAuthRespCode(String authRespCode) {
		this.authRespCode = authRespCode;
	}

	public String getCardholderAccCurrency() {
		return cardholderAccCurrency;
	}

	public void setCardholderAccCurrency(String cardholderAccCurrency) {
		this.cardholderAccCurrency = cardholderAccCurrency;
	}

	public Long getCardholderBillAmount() {
		return cardholderBillAmount;
	}

	public void setCardholderBillAmount(Long cardholderBillAmount) {
		this.cardholderBillAmount = cardholderBillAmount;
	}

	public Long getCardholderBillExchRate() {
		return cardholderBillExchRate;
	}

	public void setCardholderBillExchRate(Long cardholderBillExchRate) {
		this.cardholderBillExchRate = cardholderBillExchRate;
	}

	public String getCardholderServiceFee() {
		return cardholderServiceFee;
	}

	public void setCardholderServiceFee(String cardholderServiceFee) {
		this.cardholderServiceFee = cardholderServiceFee;
	}

	public Long getClearOperId() {
		return clearOperId;
	}

	public void setClearOperId(Long clearOperId) {
		this.clearOperId = clearOperId;
	}

	public Long getCommissionPayable() {
		return commissionPayable;
	}

	public void setCommissionPayable(Long commissionPayable) {
		this.commissionPayable = commissionPayable;
	}

	public Long getCommissionReceivable() {
		return commissionReceivable;
	}

	public void setCommissionReceivable(Long commissionReceivable) {
		this.commissionReceivable = commissionReceivable;
	}

	public Timestamp getExchDate() {
		return exchDate;
	}

	public void setExchDate(Timestamp exchDate) {
		this.exchDate = exchDate;
	}

	public String getInterchangeServiceFee() {
		return interchangeServiceFee;
	}

	public void setInterchangeServiceFee(String interchangeServiceFee) {
		this.interchangeServiceFee = interchangeServiceFee;
	}

	public Boolean getIssuer() {
		return issuer;
	}

	public void setIssuer(Boolean issuer) {
		this.issuer = issuer;
	}

	public Integer getMerchantType() {
		return merchantType;
	}

	public void setMerchantType(Integer merchantType) {
		this.merchantType = merchantType;
	}

	public Integer getMessageType() {
		return messageType;
	}

	public void setMessageType(Integer messageType) {
		this.messageType = messageType;
	}

	public Integer getOrigSysTraceNum() {
		return origSysTraceNum;
	}

	public void setOrigSysTraceNum(Integer origSysTraceNum) {
		this.origSysTraceNum = origSysTraceNum;
	}

	public Timestamp getOrigTransDateTime() {
		return origTransDateTime;
	}

	public void setOrigTransDateTime(Timestamp origTransDateTime) {
		this.origTransDateTime = origTransDateTime;
	}

	public String getOrigTransProcCode() {
		return origTransProcCode;
	}

	public void setOrigTransProcCode(String origTransProcCode) {
		this.origTransProcCode = origTransProcCode;
	}

	public String getPan() {
		return pan;
	}

	public void setPan(String pan) {
		this.pan = pan;
	}

	public Integer getPosCondCode() {
		return posCondCode;
	}

	public void setPosCondCode(Integer posCondCode) {
		this.posCondCode = posCondCode;
	}

	public Integer getPosEntryMode() {
		return posEntryMode;
	}

	public void setPosEntryMode(Integer posEntryMode) {
		this.posEntryMode = posEntryMode;
	}

	public Integer getProcessingCode() {
		return processingCode;
	}

	public void setProcessingCode(Integer processingCode) {
		this.processingCode = processingCode;
	}

	public String getReceivingInnCode() {
		return receivingInnCode;
	}

	public void setReceivingInnCode(String receivingInnCode) {
		this.receivingInnCode = receivingInnCode;
	}

	public String getResponseCode() {
		return responseCode;
	}

	public void setResponseCode(String responseCode) {
		this.responseCode = responseCode;
	}

	public String getRrn() {
		return rrn;
	}

	public void setRrn(String rrn) {
		this.rrn = rrn;
	}

	public String getSendersIdCode() {
		return sendersIdCode;
	}

	public void setSendersIdCode(String sendersIdCode) {
		this.sendersIdCode = sendersIdCode;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Long getSttlAmount() {
		return sttlAmount;
	}

	public void setSttlAmount(Long sttlAmount) {
		this.sttlAmount = sttlAmount;
	}

	public String getSttlCurrency() {
		return sttlCurrency;
	}

	public void setSttlCurrency(String sttlCurrency) {
		this.sttlCurrency = sttlCurrency;
	}

	public Timestamp getSttlDate() {
		return sttlDate;
	}

	public void setSttlDate(Timestamp sttlDate) {
		this.sttlDate = sttlDate;
	}

	public Long getSttlExchRate() {
		return sttlExchRate;
	}

	public void setSttlExchRate(Long sttlExchRate) {
		this.sttlExchRate = sttlExchRate;
	}

	public Long getSysTraceNum() {
		return sysTraceNum;
	}

	public void setSysTraceNum(Long sysTraceNum) {
		this.sysTraceNum = sysTraceNum;
	}

	public Long getTransAmount() {
		return transAmount;
	}

	public void setTransAmount(Long transAmount) {
		this.transAmount = transAmount;
	}

	public String getTransCurrency() {
		return transCurrency;
	}

	public void setTransCurrency(String transCurrency) {
		this.transCurrency = transCurrency;
	}

	public Timestamp getTransmissionDate() {
		return transmissionDate;
	}

	public void setTransmissionDate(Timestamp transmissionDate) {
		this.transmissionDate = transmissionDate;
	}

	@Override
	public Object getModelId() {
		return rrn;
	}
}

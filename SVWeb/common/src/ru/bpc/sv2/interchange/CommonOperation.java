package ru.bpc.sv2.interchange;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Date;

public class CommonOperation implements Serializable, ModelIdentifiable {
	private Long id;
	private Long sessionId;
	private String operType;
	private String msgType;
	private String sttlType;
	private Date operDate;
	private Timestamp hostDate;
	private Long operRequestAmount;
	private String networkRefnum;
	private String acqInstBin;
	private String status;
	private Boolean isReversal;
	private String merchantNumber;
	private String mcc;
	private String merchantName;
	private String merchantStreet;
	private String merchantCity;
	private String merchantRegion;
	private String merchantCountry;
	private String merchantPostcode;
	private String terminalType;
	private String terminalNumber;
	private Integer issNetworkId;
	private Integer issInstId;
	private String issCardNumber;
	private String issCardCountry;
	private Integer acqNetworkId;
	private Integer acqInstId;
	private Long operAmount;
	private String operCurrency;
	private Long sttlAmount;
	private String sttlCurrency;
	private Integer calcStatus;
	private Integer feesCnt;

	public Integer getFeesCnt() {
		return feesCnt;
	}

	public void setFeesCnt(Integer feesCnt) {
		this.feesCnt = feesCnt;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getSttlType() {
		return sttlType;
	}

	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}

	public Date getOperDate() {
		return operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	public Timestamp getHostDate() {
		return hostDate;
	}

	public void setHostDate(Timestamp hostDate) {
		this.hostDate = hostDate;
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

	public Long getOperRequestAmount() {
		return operRequestAmount;
	}

	public void setOperRequestAmount(Long operRequestAmount) {
		this.operRequestAmount = operRequestAmount;
	}

	public String getNetworkRefnum() {
		return networkRefnum;
	}

	public void setNetworkRefnum(String networkRefnum) {
		this.networkRefnum = networkRefnum;
	}

	public String getAcqInstBin() {
		return acqInstBin;
	}

	public void setAcqInstBin(String acqInstBin) {
		this.acqInstBin = acqInstBin;
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

	public String getMerchantNumber() {
		return merchantNumber;
	}

	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public String getMcc() {
		return mcc;
	}

	public void setMcc(String mcc) {
		this.mcc = mcc;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getMerchantStreet() {
		return merchantStreet;
	}

	public void setMerchantStreet(String merchantStreet) {
		this.merchantStreet = merchantStreet;
	}

	public String getMerchantCity() {
		return merchantCity;
	}

	public void setMerchantCity(String merchantCity) {
		this.merchantCity = merchantCity;
	}

	public String getMerchantRegion() {
		return merchantRegion;
	}

	public void setMerchantRegion(String merchantRegion) {
		this.merchantRegion = merchantRegion;
	}

	public String getMerchantCountry() {
		return merchantCountry;
	}

	public void setMerchantCountry(String merchantCountry) {
		this.merchantCountry = merchantCountry;
	}

	public String getMerchantPostcode() {
		return merchantPostcode;
	}

	public void setMerchantPostcode(String merchantPostcode) {
		this.merchantPostcode = merchantPostcode;
	}

	public String getTerminalType() {
		return terminalType;
	}

	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}

	public String getTerminalNumber() {
		return terminalNumber;
	}

	public void setTerminalNumber(String terminalNumber) {
		this.terminalNumber = terminalNumber;
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

	public String getIssCardNumber() {
		return issCardNumber;
	}

	public void setIssCardNumber(String issCardNumber) {
		this.issCardNumber = issCardNumber;
	}

	public String getIssCardCountry() {
		return issCardCountry;
	}

	public void setIssCardCountry(String issCardCountry) {
		this.issCardCountry = issCardCountry;
	}

	public Integer getAcqNetworkId() {
		return acqNetworkId;
	}

	public void setAcqNetworkId(Integer acqNetworkId) {
		this.acqNetworkId = acqNetworkId;
	}

	public Integer getAcqInstId() {
		return acqInstId;
	}

	public void setAcqInstId(Integer acqInstId) {
		this.acqInstId = acqInstId;
	}

	public Long getOperAmount() {
		return operAmount;
	}

	public void setOperAmount(Long operAmount) {
		this.operAmount = operAmount;
	}

	public String getOperCurrency() {
		return operCurrency;
	}

	public void setOperCurrency(String operCurrency) {
		this.operCurrency = operCurrency;
	}

	public Integer getCalcStatus() {
		return calcStatus;
	}

	public void setCalcStatus(Integer calcStatus) {
		this.calcStatus = calcStatus;
	}

	@Override
	public Object getModelId() {
		return id;
	}
}

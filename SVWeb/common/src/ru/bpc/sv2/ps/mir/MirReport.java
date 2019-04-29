package ru.bpc.sv2.ps.mir;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class MirReport implements Serializable, ModelIdentifiable, Cloneable{
    private static final long serialVersionUID = 1L;

    private Long id;
    private Integer instId;
    private String instName;
    private Long sessionId;
    private Long fileId;
    private String fileName;
    private Date fileDate;
    private Long recordNumber;
    private String status;
    private String reportType;
    private String activityType;
    private Long origInstId;
    private Integer mti;
    private String cardNumber;
    private Long procCode;
    private BigDecimal transAmount;
    private BigDecimal reconAmount;
    private String reconConvRate;
    private Date dateFrom;
    private Date dateTo;
    private Date localDateTime;
    private String posEntryMode;
    private String funcCode;
    private String msgReason;
    private String mcc;
    private String acqRefData;
    private String rrn;
    private String appCode;
    private String serviceCode;
    private String cardAccTermId;
    private String cardAccIdCode;
    private String cardAccAddress;
    private String cardAccPostCode;
    private String cardAccRegion;
    private String cardAccCountry;
    private String isReversal;
    private Date refFileDate;
    private String feeAmount;
    private String currExponents;
    private String isSettlement;
    private String finData;
    private String origTransAgentId;
    private String sttlData;
    private String transCurrCode;
    private String recontCurrCode;
    private String addlAmount;
    private String transCycleId;
    private String dataRecord;
    private String trailerId;
    private String memberId;
    private String trailerEndpoint;
    private Long recordCount;
    private String lang;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getInstName() {
        return instName;
    }
    public void setInstName(String instName) {
        this.instName = instName;
    }

    public Long getSessionId() {
        return sessionId;
    }
    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public Long getFileId() {
        return fileId;
    }
    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public String getFileName() {
        return fileName;
    }
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Date getFileDate() {
        return fileDate;
    }
    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    public Long getRecordNumber() {
        return recordNumber;
    }
    public void setRecordNumber(Long recordNumber) {
        this.recordNumber = recordNumber;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getReportType() {
        return reportType;
    }
    public void setReportType(String reportType) {
        this.reportType = reportType;
    }

    public String getActivityType() {
        return activityType;
    }
    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public Long getOrigInstId() {
        return origInstId;
    }
    public void setOrigInstId(Long origInstId) {
        this.origInstId = origInstId;
    }

    public Integer getMti() {
        return mti;
    }
    public void setMti(Integer mti) {
        this.mti = mti;
    }

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public Long getProcCode() {
        return procCode;
    }
    public void setProcCode(Long procCode) {
        this.procCode = procCode;
    }

    public BigDecimal getTransAmount() {
        return transAmount;
    }
    public void setTransAmount(BigDecimal transAmount) {
        this.transAmount = transAmount;
    }

    public BigDecimal getReconAmount() {
        return reconAmount;
    }
    public void setReconAmount(BigDecimal reconAmount) {
        this.reconAmount = reconAmount;
    }

    public String getReconConvRate() {
        return reconConvRate;
    }
    public void setReconConvRate(String reconConvRate) {
        this.reconConvRate = reconConvRate;
    }

    public Date getDateFrom() {
        return dateFrom;
    }
    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    public Date getDateTo() {
        return dateTo;
    }
    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }

    public Date getLocalDateTime() {
        return localDateTime;
    }
    public void setLocalDateTime(Date localDateTime) {
        this.localDateTime = localDateTime;
    }

    public String getPosEntryMode() {
        return posEntryMode;
    }
    public void setPosEntryMode(String posEntryMode) {
        this.posEntryMode = posEntryMode;
    }

    public String getFuncCode() {
        return funcCode;
    }
    public void setFuncCode(String funcCode) {
        this.funcCode = funcCode;
    }

    public String getMsgReason() {
        return msgReason;
    }
    public void setMsgReason(String msgReason) {
        this.msgReason = msgReason;
    }

    public String getMcc() {
        return mcc;
    }
    public void setMcc(String mcc) {
        this.mcc = mcc;
    }

    public String getAcqRefData() {
        return acqRefData;
    }
    public void setAcqRefData(String acqRefData) {
        this.acqRefData = acqRefData;
    }

    public String getRrn() {
        return rrn;
    }
    public void setRrn(String rrn) {
        this.rrn = rrn;
    }

    public String getAppCode() {
        return appCode;
    }
    public void setAppCode(String appCode) {
        this.appCode = appCode;
    }

    public String getServiceCode() {
        return serviceCode;
    }
    public void setServiceCode(String serviceCode) {
        this.serviceCode = serviceCode;
    }

    public String getCardAccTermId() {
        return cardAccTermId;
    }
    public void setCardAccTermId(String cardAccTermId) {
        this.cardAccTermId = cardAccTermId;
    }

    public String getCardAccIdCode() {
        return cardAccIdCode;
    }
    public void setCardAccIdCode(String cardAccIdCode) {
        this.cardAccIdCode = cardAccIdCode;
    }

    public String getCardAccAddress() {
        return cardAccAddress;
    }
    public void setCardAccAddress(String cardAccAddress) {
        this.cardAccAddress = cardAccAddress;
    }

    public String getCardAccPostCode() {
        return cardAccPostCode;
    }
    public void setCardAccPostCode(String cardAccPostCode) {
        this.cardAccPostCode = cardAccPostCode;
    }

    public String getCardAccRegion() {
        return cardAccRegion;
    }
    public void setCardAccRegion(String cardAccRegion) {
        this.cardAccRegion = cardAccRegion;
    }

    public String getCardAccCountry() {
        return cardAccCountry;
    }
    public void setCardAccCountry(String cardAccCountry) {
        this.cardAccCountry = cardAccCountry;
    }

    public String getIsReversal() {
        return isReversal;
    }
    public void setIsReversal(String isReversal) {
        this.isReversal = isReversal;
    }

    public Date getRefFileDate() {
        return refFileDate;
    }
    public void setRefFileDate(Date refFileDate) {
        this.refFileDate = refFileDate;
    }

    public String getFeeAmount() {
        return feeAmount;
    }
    public void setFeeAmount(String feeAmount) {
        this.feeAmount = feeAmount;
    }

    public String getCurrExponents() {
        return currExponents;
    }
    public void setCurrExponents(String currExponents) {
        this.currExponents = currExponents;
    }

    public String getIsSettlement() {
        return isSettlement;
    }
    public void setIsSettlement(String isSettlement) {
        this.isSettlement = isSettlement;
    }

    public String getFinData() {
        return finData;
    }
    public void setFinData(String finData) {
        this.finData = finData;
    }

    public String getOrigTransAgentId() {
        return origTransAgentId;
    }
    public void setOrigTransAgentId(String origTransAgentId) {
        this.origTransAgentId = origTransAgentId;
    }

    public String getSttlData() {
        return sttlData;
    }
    public void setSttlData(String sttlData) {
        this.sttlData = sttlData;
    }

    public String getTransCurrCode() {
        return transCurrCode;
    }
    public void setTransCurrCode(String transCurrCode) {
        this.transCurrCode = transCurrCode;
    }

    public String getRecontCurrCode() {
        return recontCurrCode;
    }
    public void setRecontCurrCode(String recontCurrCode) {
        this.recontCurrCode = recontCurrCode;
    }

    public String getAddlAmount() {
        return addlAmount;
    }
    public void setAddlAmount(String addlAmount) {
        this.addlAmount = addlAmount;
    }

    public String getTransCycleId() {
        return transCycleId;
    }
    public void setTransCycleId(String transCycleId) {
        this.transCycleId = transCycleId;
    }

    public String getDataRecord() {
        return dataRecord;
    }
    public void setDataRecord(String dataRecord) {
        this.dataRecord = dataRecord;
    }

    public String getTrailerId() {
        return trailerId;
    }
    public void setTrailerId(String trailerId) {
        this.trailerId = trailerId;
    }

    public String getMemberId() {
        return memberId;
    }
    public void setMemberId(String memberId) {
        this.memberId = memberId;
    }

    public String getTrailerEndpoint() {
        return trailerEndpoint;
    }
    public void setTrailerEndpoint(String trailerEndpoint) {
        this.trailerEndpoint = trailerEndpoint;
    }

    public Long getRecordCount() {
        return recordCount;
    }
    public void setRecordCount(Long recordCount) {
        this.recordCount = recordCount;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
}

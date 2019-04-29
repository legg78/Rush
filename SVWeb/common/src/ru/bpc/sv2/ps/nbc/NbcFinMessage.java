package ru.bpc.sv2.ps.nbc;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

/**
 * Created by Viktorov on 07.12.2016.
 */
public class NbcFinMessage implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 7204592637349588198L;

    private Long id;
    private Long splitHash;
    private String status;
    private String statusDesc;
    private Long instId;
    private String instName;
    private Long networkId;
    private String networkName;
    private Long fileId;
    private Boolean incoming;
    private Boolean invalid;
    private Long originalId;
    private Long disputeId;
    private String cardNumber;
    private String mti;
    private Long recordNumber;
    private String msgFileType;
    private String participantType;
    private String recordType;
    private String cardMask;
    private Long cardHash;
    private String procCode;
    private String nbcRespCode;
    private String acqRespCode;
    private String issRespCode;
    private String bnbRespCode;
    private String disputeTransResult;
    private Double transAmount;
    private Double sttlAmount;
    private Double crdhBillAmount;
    private Double crdhBillFee;
    private Double settlRate;
    private Double crdhBillRate;
    private String systemTraceNumber;
    private String localTransTime;
    private Date localTransDate;
    private Date settlementDate;
    private String merchantType;
    private Double transFeeAmount;
    private String acqInstCode;
    private String issInstCode;
    private String bnbInstCode;
    private String rrn;
    private String authNumber;
    private String respCode;
    private String terminalId;
    private String transCurrency;
    private String settlCurrency;
    private String crdhBillCurrency;
    private String fromAccountId;
    private String toAccountId;
    private Double nbcFee;
    private Double acqFee;
    private Double issFee;
    private Double bnbFee;
    private String lang;
    private String fileName;
    private Date fileDate;
    private Long sessionId;
    private Long sessionFileId;

    private Date dateFrom;
    private Date dateTo;



    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getSplitHash() {
        return splitHash;
    }

    public void setSplitHash(Long splitHash) {
        this.splitHash = splitHash;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDesc() {
        return statusDesc;
    }

    public void setStatusDesc(String statusDesc) {
        this.statusDesc = statusDesc;
    }

    public Long getInstId() {
        return instId;
    }

    public void setInstId(Long instId) {
        this.instId = instId;
    }

    public String getInstName() {
        return instName;
    }

    public void setInstName(String instName) {
        this.instName = instName;
    }

    public Long getNetworkId() {
        return networkId;
    }

    public void setNetworkId(Long networkId) {
        this.networkId = networkId;
    }

    public String getNetworkName() {
        return networkName;
    }

    public void setNetworkName(String networkName) {
        this.networkName = networkName;
    }

    public Long getFileId() {
        return fileId;
    }

    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public Boolean getIncoming() {
        return incoming;
    }

    public void setIncoming(Boolean incoming) {
        this.incoming = incoming;
    }

    public Boolean getInvalid() {
        return invalid;
    }

    public void setInvalid(Boolean invalid) {
        this.invalid = invalid;
    }

    public Long getOriginalId() {
        return originalId;
    }

    public void setOriginalId(Long originalId) {
        this.originalId = originalId;
    }

    public Long getDisputeId() {
        return disputeId;
    }

    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getMti() {
        return mti;
    }

    public void setMti(String mti) {
        this.mti = mti;
    }

    public Long getRecordNumber() {
        return recordNumber;
    }

    public void setRecordNumber(Long recordNumber) {
        this.recordNumber = recordNumber;
    }

    public String getMsgFileType() {
        return msgFileType;
    }

    public void setMsgFileType(String msgFileType) {
        this.msgFileType = msgFileType;
    }

    public String getParticipantType() {
        return participantType;
    }

    public void setParticipantType(String participantType) {
        this.participantType = participantType;
    }

    public String getRecordType() {
        return recordType;
    }

    public void setRecordType(String recordType) {
        this.recordType = recordType;
    }

    public String getCardMask() {
        return cardMask;
    }

    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public Long getCardHash() {
        return cardHash;
    }

    public void setCardHash(Long cardHash) {
        this.cardHash = cardHash;
    }

    public String getProcCode() {
        return procCode;
    }

    public void setProcCode(String procCode) {
        this.procCode = procCode;
    }

    public String getNbcRespCode() {
        return nbcRespCode;
    }

    public void setNbcRespCode(String nbcRespCode) {
        this.nbcRespCode = nbcRespCode;
    }

    public String getAcqRespCode() {
        return acqRespCode;
    }

    public void setAcqRespCode(String acqRespCode) {
        this.acqRespCode = acqRespCode;
    }

    public String getIssRespCode() {
        return issRespCode;
    }

    public void setIssRespCode(String issRespCode) {
        this.issRespCode = issRespCode;
    }

    public String getBnbRespCode() {
        return bnbRespCode;
    }

    public void setBnbRespCode(String bnbRespCode) {
        this.bnbRespCode = bnbRespCode;
    }

    public String getDisputeTransResult() {
        return disputeTransResult;
    }

    public void setDisputeTransResult(String disputeTransResult) {
        this.disputeTransResult = disputeTransResult;
    }

    public Double getTransAmount() {
        return transAmount;
    }

    public void setTransAmount(Double transAmount) {
        this.transAmount = transAmount;
    }

    public Double getSttlAmount() {
        return sttlAmount;
    }

    public void setSttlAmount(Double sttlAmount) {
        this.sttlAmount = sttlAmount;
    }

    public Double getCrdhBillAmount() {
        return crdhBillAmount;
    }

    public void setCrdhBillAmount(Double crdhBillAmount) {
        this.crdhBillAmount = crdhBillAmount;
    }

    public Double getCrdhBillFee() {
        return crdhBillFee;
    }

    public void setCrdhBillFee(Double crdhBillFee) {
        this.crdhBillFee = crdhBillFee;
    }

    public Double getSettlRate() {
        return settlRate;
    }

    public void setSettlRate(Double settlRate) {
        this.settlRate = settlRate;
    }

    public Double getCrdhBillRate() {
        return crdhBillRate;
    }

    public void setCrdhBillRate(Double crdhBillRate) {
        this.crdhBillRate = crdhBillRate;
    }

    public String getSystemTraceNumber() {
        return systemTraceNumber;
    }

    public void setSystemTraceNumber(String systemTraceNumber) {
        this.systemTraceNumber = systemTraceNumber;
    }

    public String getLocalTransTime() {
        return localTransTime;
    }

    public void setLocalTransTime(String localTransTime) {
        this.localTransTime = localTransTime;
    }

    public Date getLocalTransDate() {
        return localTransDate;
    }

    public void setLocalTransDate(Date localTransDate) {
        this.localTransDate = localTransDate;
    }

    public Date getSettlementDate() {
        return settlementDate;
    }

    public void setSettlementDate(Date settlementDate) {
        this.settlementDate = settlementDate;
    }

    public String getMerchantType() {
        return merchantType;
    }

    public void setMerchantType(String merchantType) {
        this.merchantType = merchantType;
    }

    public Double getTransFeeAmount() {
        return transFeeAmount;
    }

    public void setTransFeeAmount(Double transFeeAmount) {
        this.transFeeAmount = transFeeAmount;
    }

    public String getAcqInstCode() {
        return acqInstCode;
    }

    public void setAcqInstCode(String acqInstCode) {
        this.acqInstCode = acqInstCode;
    }

    public String getIssInstCode() {
        return issInstCode;
    }

    public void setIssInstCode(String issInstCode) {
        this.issInstCode = issInstCode;
    }

    public String getBnbInstCode() {
        return bnbInstCode;
    }

    public void setBnbInstCode(String bnbInstCode) {
        this.bnbInstCode = bnbInstCode;
    }

    public String getRrn() {
        return rrn;
    }

    public void setRrn(String rrn) {
        this.rrn = rrn;
    }

    public String getAuthNumber() {
        return authNumber;
    }

    public void setAuthNumber(String authNumber) {
        this.authNumber = authNumber;
    }

    public String getRespCode() {
        return respCode;
    }

    public void setRespCode(String respCode) {
        this.respCode = respCode;
    }

    public String getTerminalId() {
        return terminalId;
    }

    public void setTerminalId(String terminalId) {
        this.terminalId = terminalId;
    }

    public String getTransCurrency() {
        return transCurrency;
    }

    public void setTransCurrency(String transCurrency) {
        this.transCurrency = transCurrency;
    }

    public String getSettlCurrency() {
        return settlCurrency;
    }

    public void setSettlCurrency(String settlCurrency) {
        this.settlCurrency = settlCurrency;
    }

    public String getCrdhBillCurrency() {
        return crdhBillCurrency;
    }

    public void setCrdhBillCurrency(String crdhBillCurrency) {
        this.crdhBillCurrency = crdhBillCurrency;
    }

    public String getFromAccountId() {
        return fromAccountId;
    }

    public void setFromAccountId(String fromAccountId) {
        this.fromAccountId = fromAccountId;
    }

    public String getToAccountId() {
        return toAccountId;
    }

    public void setToAccountId(String toAccountId) {
        this.toAccountId = toAccountId;
    }

    public Double getNbcFee() {
        return nbcFee;
    }

    public void setNbcFee(Double nbcFee) {
        this.nbcFee = nbcFee;
    }

    public Double getAcqFee() {
        return acqFee;
    }

    public void setAcqFee(Double acqFee) {
        this.acqFee = acqFee;
    }

    public Double getIssFee() {
        return issFee;
    }

    public void setIssFee(Double issFee) {
        this.issFee = issFee;
    }

    public Double getBnbFee() {
        return bnbFee;
    }

    public void setBnbFee(Double bnbFee) {
        this.bnbFee = bnbFee;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Object getModelId() {
        return getId();
    }
    public Date getFileDate() {
        return fileDate;
    }

    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public Long getSessionFileId() {
        return sessionFileId;
    }

    public void setSessionFileId(Long sessionFileId) {
        this.sessionFileId = sessionFileId;
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

    @Override
    public NbcFinMessage clone() throws CloneNotSupportedException {
        NbcFinMessage clone = (NbcFinMessage) super.clone();
        return clone;
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        return result;
    }
}

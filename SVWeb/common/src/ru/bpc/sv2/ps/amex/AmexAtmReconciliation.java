package ru.bpc.sv2.ps.amex;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class AmexAtmReconciliation implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String status;
    private String statusDesc;
    private Boolean isInvalid;
    private Long fileId;
    private Integer instId;
    private String instName;
    private String cardNumber;
    private String cardMask;
    private String recordType;
    private String msgSeqNumber;
    private Date transDate;
    private Date systemDate;
    private Date sttlDate;
    private String terminalNumber;
    private String systemTraceAuditNumber;
    private String dispensedCurrency;
    private String amountRequested;
    private String amountInd;
    private String sttlRate;
    private String sttlCurrency;
    private String sttlAmountRequested;
    private String sttlAmountApproved;
    private String sttlAmountDispensed;
    private String sttlNetworkFee;
    private String sttlOtherFee;
    private String terminalCountryCode;
    private String merchantCountryCode;
    private String cardBillingCountryCode;
    private String terminalLocation;
    private String authStatus;
    private String transIndicator;
    private String origActionCode;
    private String approvalCode;
    private String addRefNumber;
    private String transId;
    private String lang;

    private String sessionId;
    private String fileName;
    private Date fileDate;

    private Date dateTo;
    private Date dateFrom;

    @Override
    public Object getModelId() {
        return getId();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
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

    public Boolean getInvalid() {
        return isInvalid;
    }

    public void setInvalid(Boolean invalid) {
        isInvalid = invalid;
    }

    public Long getFileId() {
        return fileId;
    }

    public void setFileId(Long fileId) {
        this.fileId = fileId;
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

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getCardMask() {
        return cardMask;
    }

    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public String getRecordType() {
        return recordType;
    }

    public void setRecordType(String recordType) {
        this.recordType = recordType;
    }

    public String getMsgSeqNumber() {
        return msgSeqNumber;
    }

    public void setMsgSeqNumber(String msgSeqNumber) {
        this.msgSeqNumber = msgSeqNumber;
    }

    public Date getTransDate() {
        return transDate;
    }

    public void setTransDate(Date transDate) {
        this.transDate = transDate;
    }

    public Date getSystemDate() {
        return systemDate;
    }

    public void setSystemDate(Date systemDate) {
        this.systemDate = systemDate;
    }

    public Date getSttlDate() {
        return sttlDate;
    }

    public void setSttlDate(Date sttlDate) {
        this.sttlDate = sttlDate;
    }

    public String getTerminalNumber() {
        return terminalNumber;
    }

    public void setTerminalNumber(String terminalNumber) {
        this.terminalNumber = terminalNumber;
    }

    public String getSystemTraceAuditNumber() {
        return systemTraceAuditNumber;
    }

    public void setSystemTraceAuditNumber(String systemTraceAuditNumber) {
        this.systemTraceAuditNumber = systemTraceAuditNumber;
    }

    public String getDispensedCurrency() {
        return dispensedCurrency;
    }

    public void setDispensedCurrency(String dispensedCurrency) {
        this.dispensedCurrency = dispensedCurrency;
    }

    public String getAmountRequested() {
        return amountRequested;
    }

    public void setAmountRequested(String amountRequested) {
        this.amountRequested = amountRequested;
    }

    public String getAmountInd() {
        return amountInd;
    }

    public void setAmountInd(String amountInd) {
        this.amountInd = amountInd;
    }

    public String getSttlRate() {
        return sttlRate;
    }

    public void setSttlRate(String sttlRate) {
        this.sttlRate = sttlRate;
    }

    public String getSttlCurrency() {
        return sttlCurrency;
    }

    public void setSttlCurrency(String sttlCurrency) {
        this.sttlCurrency = sttlCurrency;
    }

    public String getSttlAmountRequested() {
        return sttlAmountRequested;
    }

    public void setSttlAmountRequested(String sttlAmountRequested) {
        this.sttlAmountRequested = sttlAmountRequested;
    }

    public String getSttlAmountApproved() {
        return sttlAmountApproved;
    }

    public void setSttlAmountApproved(String sttlAmountApproved) {
        this.sttlAmountApproved = sttlAmountApproved;
    }

    public String getSttlAmountDispensed() {
        return sttlAmountDispensed;
    }

    public void setSttlAmountDispensed(String sttlAmountDispensed) {
        this.sttlAmountDispensed = sttlAmountDispensed;
    }

    public String getSttlNetworkFee() {
        return sttlNetworkFee;
    }

    public void setSttlNetworkFee(String sttlNetworkFee) {
        this.sttlNetworkFee = sttlNetworkFee;
    }

    public String getSttlOtherFee() {
        return sttlOtherFee;
    }

    public void setSttlOtherFee(String sttlOtherFee) {
        this.sttlOtherFee = sttlOtherFee;
    }

    public String getTerminalCountryCode() {
        return terminalCountryCode;
    }

    public void setTerminalCountryCode(String terminalCountryCode) {
        this.terminalCountryCode = terminalCountryCode;
    }

    public String getMerchantCountryCode() {
        return merchantCountryCode;
    }

    public void setMerchantCountryCode(String merchantCountryCode) {
        this.merchantCountryCode = merchantCountryCode;
    }

    public String getCardBillingCountryCode() {
        return cardBillingCountryCode;
    }

    public void setCardBillingCountryCode(String cardBillingCountryCode) {
        this.cardBillingCountryCode = cardBillingCountryCode;
    }

    public String getTerminalLocation() {
        return terminalLocation;
    }

    public void setTerminalLocation(String terminalLocation) {
        this.terminalLocation = terminalLocation;
    }

    public String getAuthStatus() {
        return authStatus;
    }

    public void setAuthStatus(String authStatus) {
        this.authStatus = authStatus;
    }

    public String getTransIndicator() {
        return transIndicator;
    }

    public void setTransIndicator(String transIndicator) {
        this.transIndicator = transIndicator;
    }

    public String getOrigActionCode() {
        return origActionCode;
    }

    public void setOrigActionCode(String origActionCode) {
        this.origActionCode = origActionCode;
    }

    public String getApprovalCode() {
        return approvalCode;
    }

    public void setApprovalCode(String approvalCode) {
        this.approvalCode = approvalCode;
    }

    public String getAddRefNumber() {
        return addRefNumber;
    }

    public void setAddRefNumber(String addRefNumber) {
        this.addRefNumber = addRefNumber;
    }

    public String getTransId() {
        return transId;
    }

    public void setTransId(String transId) {
        this.transId = transId;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getSessionId() {
        return sessionId;
    }

    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
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

    public Date getDateTo() {
        return dateTo;
    }

    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }

    public Date getDateFrom() {
        return dateFrom;
    }

    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    @Override
    public AmexAtmReconciliation clone() throws CloneNotSupportedException {
        return (AmexAtmReconciliation)super.clone();
    }

}

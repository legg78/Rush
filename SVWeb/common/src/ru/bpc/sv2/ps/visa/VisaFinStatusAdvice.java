package ru.bpc.sv2.ps.visa;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class VisaFinStatusAdvice implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long sessionId;
    private String fileName;
    private String cardMask;
    private String cardNumber;
    private Integer transactionCode;
    private Integer transCodeQualifier;
    private Integer transComponentSeq;
    private String destBin;
    private String sourceBin;
    private String vcrRecordId;
    private Integer networkId;
    private String disputeCondition;
    private String disputeStatus;
    private Integer posCondCode;
    private String posEntryMode;
    private String vrolFinId;
    private Long vrolCaseNumber;
    private Long vrolBundleCaseNumber;
    private String clientCaseNumber;
    private Integer clearingSeqNumber;
    private Integer clearingSeqCount;
    private String recipientIndicator;
    private String productId;
    private String spendQualifiedIndicator;
    private Integer processCode;
    private Integer sttlFlag;
    private Integer usageCode;
    private Long transId;
    private Long acqBusinessId;
    private String acqRefnum;
    private Long acqInstCode;
    private String cardAcceptorId;
    private BigDecimal origTransAmount;
    private String origTransCurrency;
    private BigDecimal sourceAmount;
    private String sourceCurrency;
    private String chargebackIndicator;
    private Integer reasonCode;
    private String accountNumber;
    private Integer accountNumberExt;
    private String rrn;
    private Date fileDate;
    private Date purchaseDateFrom;
    private Date purchaseDateTo;
    private Date purchaseDate;
    private Date processDate;
    private String merchantNum;
    private Integer mcc;
    private String merchantName;
    private String merchantStreet;
    private String merchantCity;
    private String merchantRegion;
    private String merchantCountry;
    private String merchantPostcode;
    private String paymentService;
    private String authCode;
    private String reimbursement;
    private String disputeReasonCode;
    private String disputeTransCode;
    private String disputeQualifier;
    private String lang;

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

    public String getFileName() {
        return fileName;
    }
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public String getCardMask() {
        return cardMask;
    }
    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public Integer getTransactionCode() {
        return transactionCode;
    }
    public void setTransactionCode(Integer transactionCode) {
        this.transactionCode = transactionCode;
    }

    public Integer getTransCodeQualifier() {
        return transCodeQualifier;
    }
    public void setTransCodeQualifier(Integer transCodeQualifier) {
        this.transCodeQualifier = transCodeQualifier;
    }

    public Integer getTransComponentSeq() {
        return transComponentSeq;
    }
    public void setTransComponentSeq(Integer transComponentSeq) {
        this.transComponentSeq = transComponentSeq;
    }

    public String getDestBin() {
        return destBin;
    }
    public void setDestBin(String destBin) {
        this.destBin = destBin;
    }

    public String getSourceBin() {
        return sourceBin;
    }
    public void setSourceBin(String sourceBin) {
        this.sourceBin = sourceBin;
    }

    public String getVcrRecordId() {
        return vcrRecordId;
    }
    public void setVcrRecordId(String vcrRecordId) {
        this.vcrRecordId = vcrRecordId;
    }

    public Integer getNetworkId() {
        return networkId;
    }
    public void setNetworkId(Integer networkId) {
        this.networkId = networkId;
    }

    public String getDisputeCondition() {
        return disputeCondition;
    }
    public void setDisputeCondition(String disputeCondition) {
        this.disputeCondition = disputeCondition;
    }

    public String getDisputeStatus() {
        return disputeStatus;
    }
    public void setDisputeStatus(String disputeStatus) {
        this.disputeStatus = disputeStatus;
    }

    public Integer getPosCondCode() {
        return posCondCode;
    }
    public void setPosCondCode(Integer posCondCode) {
        this.posCondCode = posCondCode;
    }

    public String getPosEntryMode() {
        return posEntryMode;
    }
    public void setPosEntryMode(String posEntryMode) {
        this.posEntryMode = posEntryMode;
    }

    public String getVrolFinId() {
        return vrolFinId;
    }
    public void setVrolFinId(String vrolFinId) {
        this.vrolFinId = vrolFinId;
    }

    public Long getVrolCaseNumber() {
        return vrolCaseNumber;
    }
    public void setVrolCaseNumber(Long vrolCaseNumber) {
        this.vrolCaseNumber = vrolCaseNumber;
    }

    public Long getVrolBundleCaseNumber() {
        return vrolBundleCaseNumber;
    }
    public void setVrolBundleCaseNumber(Long vrolBundleCaseNumber) {
        this.vrolBundleCaseNumber = vrolBundleCaseNumber;
    }

    public String getClientCaseNumber() {
        return clientCaseNumber;
    }
    public void setClientCaseNumber(String clientCaseNumber) {
        this.clientCaseNumber = clientCaseNumber;
    }

    public Integer getClearingSeqNumber() {
        return clearingSeqNumber;
    }
    public void setClearingSeqNumber(Integer clearingSeqNumber) {
        this.clearingSeqNumber = clearingSeqNumber;
    }

    public Integer getClearingSeqCount() {
        return clearingSeqCount;
    }
    public void setClearingSeqCount(Integer clearingSeqCount) {
        this.clearingSeqCount = clearingSeqCount;
    }

    public String getRecipientIndicator() {
        return recipientIndicator;
    }
    public void setRecipientIndicator(String recipientIndicator) {
        this.recipientIndicator = recipientIndicator;
    }

    public String getProductId() {
        return productId;
    }
    public void setProductId(String productId) {
        this.productId = productId;
    }

    public String getSpendQualifiedIndicator() {
        return spendQualifiedIndicator;
    }
    public void setSpendQualifiedIndicator(String spendQualifiedIndicator) {
        this.spendQualifiedIndicator = spendQualifiedIndicator;
    }

    public Integer getProcessCode() {
        return processCode;
    }
    public void setProcessCode(Integer processCode) {
        this.processCode = processCode;
    }

    public Integer getSttlFlag() {
        return sttlFlag;
    }
    public void setSttlFlag(Integer sttlFlag) {
        this.sttlFlag = sttlFlag;
    }

    public Integer getUsageCode() {
        return usageCode;
    }
    public void setUsageCode(Integer usageCode) {
        this.usageCode = usageCode;
    }

    public Long getTransId() {
        return transId;
    }
    public void setTransId(Long transId) {
        this.transId = transId;
    }

    public Long getAcqBusinessId() {
        return acqBusinessId;
    }
    public void setAcqBusinessId(Long acqBusinessId) {
        this.acqBusinessId = acqBusinessId;
    }

    public String getAcqRefnum() {
        return acqRefnum;
    }
    public void setAcqRefnum(String acqRefnum) {
        this.acqRefnum = acqRefnum;
    }

    public Long getAcqInstCode() {
        return acqInstCode;
    }
    public void setAcqInstCode(Long acqInstCode) {
        this.acqInstCode = acqInstCode;
    }

    public String getCardAcceptorId() {
        return cardAcceptorId;
    }
    public void setCardAcceptorId(String cardAcceptorId) {
        this.cardAcceptorId = cardAcceptorId;
    }

    public BigDecimal getOrigTransAmount() {
        return origTransAmount;
    }
    public void setOrigTransAmount(BigDecimal origTransAmount) {
        this.origTransAmount = origTransAmount;
    }

    public String getOrigTransCurrency() {
        return origTransCurrency;
    }
    public void setOrigTransCurrency(String origTransCurrency) {
        this.origTransCurrency = origTransCurrency;
    }

    public BigDecimal getSourceAmount() {
        return sourceAmount;
    }
    public void setSourceAmount(BigDecimal sourceAmount) {
        this.sourceAmount = sourceAmount;
    }

    public String getSourceCurrency() {
        return sourceCurrency;
    }
    public void setSourceCurrency(String sourceCurrency) {
        this.sourceCurrency = sourceCurrency;
    }

    public String getChargebackIndicator() {
        return chargebackIndicator;
    }
    public void setChargebackIndicator(String chargebackIndicator) {
        this.chargebackIndicator = chargebackIndicator;
    }

    public Integer getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(Integer reasonCode) {
        this.reasonCode = reasonCode;
    }

    public String getAccountNumber() {
        return accountNumber;
    }
    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public Integer getAccountNumberExt() {
        return accountNumberExt;
    }
    public void setAccountNumberExt(Integer accountNumberExt) {
        this.accountNumberExt = accountNumberExt;
    }

    public String getRrn() {
        return rrn;
    }
    public void setRrn(String rrn) {
        this.rrn = rrn;
    }

    public Date getFileDate() {
        return fileDate;
    }
    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    public Date getPurchaseDateFrom() {
        return purchaseDateFrom;
    }
    public void setPurchaseDateFrom(Date purchaseDateFrom) {
        this.purchaseDateFrom = purchaseDateFrom;
    }

    public Date getPurchaseDateTo() {
        return purchaseDateTo;
    }
    public void setPurchaseDateTo(Date purchaseDateTo) {
        this.purchaseDateTo = purchaseDateTo;
    }

    public Date getPurchaseDate() {
        return purchaseDate;
    }
    public void setPurchaseDate(Date purchaseDate) {
        this.purchaseDate = purchaseDate;
    }

    public Date getProcessDate() {
        return processDate;
    }
    public void setProcessDate(Date processDate) {
        this.processDate = processDate;
    }

    public String getMerchantNum() {
        return merchantNum;
    }
    public void setMerchantNum(String merchantNum) {
        this.merchantNum = merchantNum;
    }

    public Integer getMcc() {
        return mcc;
    }
    public void setMcc(Integer mcc) {
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

    public String getPaymentService() {
        return paymentService;
    }
    public void setPaymentService(String paymentService) {
        this.paymentService = paymentService;
    }

    public String getAuthCode() {
        return authCode;
    }
    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    public String getReimbursement() {
        return reimbursement;
    }
    public void setReimbursement(String reimbursement) {
        this.reimbursement = reimbursement;
    }

    public String getDisputeReasonCode() {
        return disputeReasonCode;
    }
    public void setDisputeReasonCode(String disputeReasonCode) {
        this.disputeReasonCode = disputeReasonCode;
    }

    public String getDisputeTransCode() {
        return disputeTransCode;
    }
    public void setDisputeTransCode(String disputeTransCode) {
        this.disputeTransCode = disputeTransCode;
    }

    public String getDisputeQualifier() {
        return disputeQualifier;
    }
    public void setDisputeQualifier(String disputeQualifier) {
        this.disputeQualifier = disputeQualifier;
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
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("session_id", getSessionId());
        result.put("file_name", getFileName());
        result.put("trans_code", getTransactionCode());
        result.put("dispute_status", getDisputeStatus());
        result.put("reason_code", getReasonCode());
        result.put("account_number", getAccountNumber());
        result.put("rrn", getRrn());
        result.put("file_date", getFileDate());
        result.put("purchase_date", getPurchaseDate());
        result.put("auth_code", getAuthCode());
        result.put("process_code", getProcessCode());
        result.put("sttl_flag", getSttlFlag());
        result.put("usage_code", getUsageCode());
        result.put("trans_id", getTransId());
        return result;
    }
}

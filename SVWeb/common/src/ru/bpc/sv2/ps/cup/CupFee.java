package ru.bpc.sv2.ps.cup;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class CupFee implements Serializable, ModelIdentifiable {

    private static final long serialVersionUID = 1L;

    private Long id;
    private String feeType;
    private String acquirerIin;
    private String forwardingIin;
    private Long sysTraceNum;
    private Date transmissionDateTime;
    private String cardNumber;
    private String merchantNumber;
    private String authRespCode;
    private Boolean reversal;
    private Integer transTypeId;
    private String receivingIin;
    private String issuerIin;
    private String sttlCurrency;
    private Integer sttlSign;
    private BigDecimal sttlAmount;
    private Integer interchangeFeeSign;
    private BigDecimal interchangeFeeAmount;
    private Integer reimbursementFeeSign;
    private BigDecimal reimbursementFeeAmount;
    private Integer serviceFeeSign;
    private BigDecimal serviceFeeAmount;
    private Long fileId;
    private Long finMsgId;
    private String matchStatus;
    private String matchStatusDesc;
    private Integer instId;
    private String instName;
    private Integer reasonCode;

    private String operStatus;
    private Long operId;
    private String networkRefnum;
    private BigDecimal operAmount;
    private String operCurrency;
    private String fileName;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getFeeType() {
        return feeType;
    }

    public void setFeeType(String feeType) {
        this.feeType = feeType;
    }

    public String getAcquirerIin() {
        return acquirerIin;
    }

    public void setAcquirerIin(String acquirerIin) {
        this.acquirerIin = acquirerIin;
    }

    public String getForwardingIin() {
        return forwardingIin;
    }

    public void setForwardingIin(String forwardingIin) {
        this.forwardingIin = forwardingIin;
    }

    public Long getSysTraceNum() {
        return sysTraceNum;
    }

    public void setSysTraceNum(Long sysTraceNum) {
        this.sysTraceNum = sysTraceNum;
    }

    public Date getTransmissionDateTime() {
        return transmissionDateTime;
    }

    public void setTransmissionDateTime(Date transmissionDateTime) {
        this.transmissionDateTime = transmissionDateTime;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getMerchantNumber() {
        return merchantNumber;
    }

    public void setMerchantNumber(String merchantNumber) {
        this.merchantNumber = merchantNumber;
    }

    public String getAuthRespCode() {
        return authRespCode;
    }

    public void setAuthRespCode(String authRespCode) {
        this.authRespCode = authRespCode;
    }

    public Boolean getReversal() {
        return reversal;
    }

    public void setReversal(Boolean reversal) {
        this.reversal = reversal;
    }

    public Integer getTransTypeId() {
        return transTypeId;
    }

    public void setTransTypeId(Integer transTypeId) {
        this.transTypeId = transTypeId;
    }

    public String getReceivingIin() {
        return receivingIin;
    }

    public void setReceivingIin(String receivingIin) {
        this.receivingIin = receivingIin;
    }

    public String getIssuerIin() {
        return issuerIin;
    }

    public void setIssuerIin(String issuerIin) {
        this.issuerIin = issuerIin;
    }

    public String getSttlCurrency() {
        return sttlCurrency;
    }

    public void setSttlCurrency(String sttlCurrency) {
        this.sttlCurrency = sttlCurrency;
    }

    public Integer getSttlSign() {
        return sttlSign;
    }

    public void setSttlSign(Integer sttlSign) {
        this.sttlSign = sttlSign;
    }

    public BigDecimal getSttlAmount() {
        return sttlAmount;
    }

    public void setSttlAmount(BigDecimal sttlAmount) {
        this.sttlAmount = sttlAmount;
    }

    public Integer getInterchangeFeeSign() {
        return interchangeFeeSign;
    }

    public void setInterchangeFeeSign(Integer interchangeFeeSign) {
        this.interchangeFeeSign = interchangeFeeSign;
    }

    public BigDecimal getInterchangeFeeAmount() {
        return interchangeFeeAmount;
    }

    public void setInterchangeFeeAmount(BigDecimal interchangeFeeAmount) {
        this.interchangeFeeAmount = interchangeFeeAmount;
    }

    public Integer getReimbursementFeeSign() {
        return reimbursementFeeSign;
    }

    public void setReimbursementFeeSign(Integer reimbursementFeeSign) {
        this.reimbursementFeeSign = reimbursementFeeSign;
    }

    public BigDecimal getReimbursementFeeAmount() {
        return reimbursementFeeAmount;
    }

    public void setReimbursementFeeAmount(BigDecimal reimbursementFeeAmount) {
        this.reimbursementFeeAmount = reimbursementFeeAmount;
    }

    public Integer getServiceFeeSign() {
        return serviceFeeSign;
    }

    public void setServiceFeeSign(Integer serviceFeeSign) {
        this.serviceFeeSign = serviceFeeSign;
    }

    public BigDecimal getServiceFeeAmount() {
        return serviceFeeAmount;
    }

    public void setServiceFeeAmount(BigDecimal serviceFeeAmount) {
        this.serviceFeeAmount = serviceFeeAmount;
    }

    public Long getFileId() {
        return fileId;
    }

    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public Long getFinMsgId() {
        return finMsgId;
    }

    public void setFinMsgId(Long finMsgId) {
        this.finMsgId = finMsgId;
    }

    public String getMatchStatus() {
        return matchStatus;
    }

    public void setMatchStatus(String matchStatus) {
        this.matchStatus = matchStatus;
    }

    public String getMatchStatusDesc() {
        return matchStatusDesc;
    }

    public void setMatchStatusDesc(String matchStatusDesc) {
        this.matchStatusDesc = matchStatusDesc;
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

    public Integer getReasonCode() {
        return reasonCode;
    }

    public void setReasonCode(Integer reasonCode) {
        this.reasonCode = reasonCode;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

    public Long getOperId() {
        return operId;
    }

    public void setOperId(Long operId) {
        this.operId = operId;
    }

    public String getNetworkRefnum() {
        return networkRefnum;
    }

    public void setNetworkRefnum(String networkRefnum) {
        this.networkRefnum = networkRefnum;
    }

    public BigDecimal getOperAmount() {
        return operAmount;
    }

    public void setOperAmount(BigDecimal operAmount) {
        this.operAmount = operAmount;
    }

    public String getOperCurrency() {
        return operCurrency;
    }

    public void setOperCurrency(String operCurrency) {
        this.operCurrency = operCurrency;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    @Override
    public Object getModelId() {
        return id;
    }
}

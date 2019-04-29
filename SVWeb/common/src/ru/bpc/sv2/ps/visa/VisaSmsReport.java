package ru.bpc.sv2.ps.visa;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class VisaSmsReport implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1245092518859296277L;

    private Long id;
    private Long fileId;
    private Long recordNumber;
    private String status;
    private String statusDesc;
    private String recordType;
    private String issAcq;
    private String isaInd;
    private String givFlag;
    private String affiliateBin;
    private Date sttlDate;
    private String valCode;
    private String refnum;
    private String traceNum;
    private String reqMsgType;
    private String respCode;
    private String procCode;
    private String msgReasonCode;
    private String cardNumber;
    private String trxnInd;
    private String sttlCurrCode;
    private BigDecimal sttlAmount;
    private String sttlSign;
    private String reserved;
    private String spendQualifiedInd;
    private BigDecimal surchargeAmount;
    private String surchargeSign;
    private Integer instId;
    private String instName;
    private String lang;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getFileId() {
        return fileId;
    }
    public void setFileId(Long fileId) {
        this.fileId = fileId;
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

    public String getStatusDesc() {
        return statusDesc;
    }
    public void setStatusDesc(String statusDesc) {
        this.statusDesc = statusDesc;
    }

    public String getRecordType() {
        return recordType;
    }
    public void setRecordType(String recordType) {
        this.recordType = recordType;
    }

    public String getIssAcq() {
        return issAcq;
    }
    public void setIssAcq(String issAcq) {
        this.issAcq = issAcq;
    }

    public String getIsaInd() {
        return isaInd;
    }
    public void setIsaInd(String isaInd) {
        this.isaInd = isaInd;
    }

    public String getGivFlag() {
        return givFlag;
    }
    public void setGivFlag(String givFlag) {
        this.givFlag = givFlag;
    }

    public String getAffiliateBin() {
        return affiliateBin;
    }
    public void setAffiliateBin(String affiliateBin) {
        this.affiliateBin = affiliateBin;
    }

    public Date getSttlDate() {
        return sttlDate;
    }
    public void setSttlDate(Date sttlDate) {
        this.sttlDate = sttlDate;
    }

    public String getValCode() {
        return valCode;
    }
    public void setValCode(String valCode) {
        this.valCode = valCode;
    }

    public String getRefnum() {
        return refnum;
    }
    public void setRefnum(String refnum) {
        this.refnum = refnum;
    }

    public String getTraceNum() {
        return traceNum;
    }
    public void setTraceNum(String traceNum) {
        this.traceNum = traceNum;
    }

    public String getReqMsgType() {
        return reqMsgType;
    }
    public void setReqMsgType(String reqMsgType) {
        this.reqMsgType = reqMsgType;
    }

    public String getRespCode() {
        return respCode;
    }
    public void setRespCode(String respCode) {
        this.respCode = respCode;
    }

    public String getProcCode() {
        return procCode;
    }
    public void setProcCode(String procCode) {
        this.procCode = procCode;
    }

    public String getMsgReasonCode() {
        return msgReasonCode;
    }
    public void setMsgReasonCode(String msgReasonCode) {
        this.msgReasonCode = msgReasonCode;
    }

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getTrxnInd() {
        return trxnInd;
    }
    public void setTrxnInd(String trxnInd) {
        this.trxnInd = trxnInd;
    }

    public String getSttlCurrCode() {
        return sttlCurrCode;
    }
    public void setSttlCurrCode(String sttlCurrCode) {
        this.sttlCurrCode = sttlCurrCode;
    }

    public BigDecimal getSttlAmount() {
        return sttlAmount;
    }
    public void setSttlAmount(BigDecimal sttlAmount) {
        this.sttlAmount = sttlAmount;
    }

    public String getSttlSign() {
        return sttlSign;
    }
    public void setSttlSign(String sttlSign) {
        this.sttlSign = sttlSign;
    }

    public String getReserved() {
        return reserved;
    }
    public void setReserved(String reserved) {
        this.reserved = reserved;
    }

    public String getSpendQualifiedInd() {
        return spendQualifiedInd;
    }
    public void setSpendQualifiedInd(String spendQualifiedInd) {
        this.spendQualifiedInd = spendQualifiedInd;
    }

    public BigDecimal getSurchargeAmount() {
        return surchargeAmount;
    }
    public void setSurchargeAmount(BigDecimal surchargeAmount) {
        this.surchargeAmount = surchargeAmount;
    }

    public String getSurchargeSign() {
        return surchargeSign;
    }
    public void setSurchargeSign(String surchargeSign) {
        this.surchargeSign = surchargeSign;
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

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    @Override
    public Object getModelId() {
        return getId() + "_" + getRecordNumber() + "_" + getLang();
    }
}

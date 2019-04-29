package ru.bpc.sv2.ps.visa;


import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class VisaReturn implements Serializable, ModelIdentifiable, Cloneable{

    private static final long serialVersionUID = 4117574739020388185L;

    private Long id;
    private String dstBin;
    private String srcBin;
    private String originalTc;
    private String originalTcq;
    private String originalTcr;
    private Date srcBatchDate;
    private String srcBatchNumber;
    private String itemSeqNumber;
    private Long originalAmount;
    private String originalCurrency;
    private String originalSttlFlag;
    private String crsReturnFlag;
    private String reasonCode1;
    private String reasonCode2;
    private String reasonCode3;
    private String reasonCode4;
    private String reasonCode5;
    private Long originalId;
    private Long fileId;
    private Long batchId;
    private Long recordNumber;

    // PRC_SESSION_FILE
    private String fileName;

    public Object getModelId() {
        return getId();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getDstBin() {
        return dstBin;
    }

    public void setDstBin(String dstBin) {
        this.dstBin = dstBin;
    }

    public String getSrcBin() {
        return srcBin;
    }

    public void setSrcBin(String srcBin) {
        this.srcBin = srcBin;
    }

    public String getOriginalTc() {
        return originalTc;
    }

    public void setOriginalTc(String originalTc) {
        this.originalTc = originalTc;
    }

    public String getOriginalTcq() {
        return originalTcq;
    }

    public void setOriginalTcq(String originalTcq) {
        this.originalTcq = originalTcq;
    }

    public String getOriginalTcr() {
        return originalTcr;
    }

    public void setOriginalTcr(String originalTcr) {
        this.originalTcr = originalTcr;
    }

    public Date getSrcBatchDate() {
        return srcBatchDate;
    }

    public void setSrcBatchDate(Date srcBatchDate) {
        this.srcBatchDate = srcBatchDate;
    }

    public String getSrcBatchNumber() {
        return srcBatchNumber;
    }

    public void setSrcBatchNumber(String srcBatchNumber) {
        this.srcBatchNumber = srcBatchNumber;
    }

    public String getItemSeqNumber() {
        return itemSeqNumber;
    }

    public void setItemSeqNumber(String itemSeqNumber) {
        this.itemSeqNumber = itemSeqNumber;
    }

    public Long getOriginalAmount() {
        return originalAmount;
    }

    public void setOriginalAmount(Long originalAmount) {
        this.originalAmount = originalAmount;
    }

    public String getOriginalCurrency() {
        return originalCurrency;
    }

    public void setOriginalCurrency(String originalCurrency) {
        this.originalCurrency = originalCurrency;
    }

    public String getOriginalSttlFlag() {
        return originalSttlFlag;
    }

    public void setOriginalSttlFlag(String originalSttlFlag) {
        this.originalSttlFlag = originalSttlFlag;
    }

    public String getCrsReturnFlag() {
        return crsReturnFlag;
    }

    public void setCrsReturnFlag(String crsReturnFlag) {
        this.crsReturnFlag = crsReturnFlag;
    }

    public String getReasonCode1() {
        return reasonCode1;
    }

    public void setReasonCode1(String reasonCode1) {
        this.reasonCode1 = reasonCode1;
    }

    public String getReasonCode2() {
        return reasonCode2;
    }

    public void setReasonCode2(String reasonCode2) {
        this.reasonCode2 = reasonCode2;
    }

    public String getReasonCode3() {
        return reasonCode3;
    }

    public void setReasonCode3(String reasonCode3) {
        this.reasonCode3 = reasonCode3;
    }

    public String getReasonCode4() {
        return reasonCode4;
    }

    public void setReasonCode4(String reasonCode4) {
        this.reasonCode4 = reasonCode4;
    }

    public String getReasonCode5() {
        return reasonCode5;
    }

    public void setReasonCode5(String reasonCode5) {
        this.reasonCode5 = reasonCode5;
    }

    public Long getOriginalId() {
        return originalId;
    }

    public void setOriginalId(Long originalId) {
        this.originalId = originalId;
    }

    public Long getFileId() {
        return fileId;
    }

    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public Long getBatchId() {
        return batchId;
    }

    public void setBatchId(Long batchId) {
        this.batchId = batchId;
    }

    public Long getRecordNumber() {
        return recordNumber;
    }

    public void setRecordNumber(Long recordNumber) {
        this.recordNumber = recordNumber;
    }

    public String getFileName() {
        return fileName;
    }

    public void setFileName(String fileName) {
        this.fileName = fileName;
    }
}

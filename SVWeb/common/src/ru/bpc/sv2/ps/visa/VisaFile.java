package ru.bpc.sv2.ps.visa;


import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class VisaFile implements Serializable, ModelIdentifiable, Cloneable{
    private static final long serialVersionUID = 1245092518859296277L;

    // VIS_FILE
    private Long id;
    private Boolean incoming;
    private Boolean returned;
    private Long networkId;
    private String procBin;
    private Date procDate;
    private Date sttlDate;
    private String releaseNumber;
    private String testOption;
    private String securityCode;
    private String visaFileId;
    private Long batchTotal;
    private Long monetaryTotal;
    private Long tcrTotal;
    private Long transTotal;
    private Long srcAmount;
    private Long dstAmount;
    private Long instId;
    private Long sessionFileId;
    //OST_UI_INSTITUTION_SYS_VW
    private String instName;
    // PRC_SESSION_FILE
    private Long sessionId;
    private String fileName;
    private Date fileDate;
    //UI
    private Date dateFrom;
    private Date dateTo;


    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Boolean getIncoming() {
        return incoming;
    }

    public void setIncoming(Boolean incoming) {
        this.incoming = incoming;
    }

    public Boolean getReturned() {
        return returned;
    }

    public void setReturned(Boolean returned) {
        this.returned = returned;
    }

    public Long getNetworkId() {
        return networkId;
    }

    public void setNetworkId(Long networkId) {
        this.networkId = networkId;
    }

    public String getProcBin() {
        return procBin;
    }

    public void setProcBin(String procBin) {
        this.procBin = procBin;
    }

    public Date getProcDate() {
        return procDate;
    }

    public void setProcDate(Date procDate) {
        this.procDate = procDate;
    }

    public Date getSttlDate() {
        return sttlDate;
    }

    public void setSttlDate(Date sttlDate) {
        this.sttlDate = sttlDate;
    }

    public String getReleaseNumber() {
        return releaseNumber;
    }

    public void setReleaseNumber(String releaseNumber) {
        this.releaseNumber = releaseNumber;
    }

    public String getTestOption() {
        return testOption;
    }

    public void setTestOption(String testOption) {
        this.testOption = testOption;
    }

    public String getSecurityCode() {
        return securityCode;
    }

    public void setSecurityCode(String securityCode) {
        this.securityCode = securityCode;
    }

    public String getVisaFileId() {
        return visaFileId;
    }

    public void setVisaFileId(String visaFileId) {
        this.visaFileId = visaFileId;
    }

    public Long getBatchTotal() {
        return batchTotal;
    }

    public void setBatchTotal(Long batchTotal) {
        this.batchTotal = batchTotal;
    }

    public Long getMonetaryTotal() {
        return monetaryTotal;
    }

    public void setMonetaryTotal(Long monetaryTotal) {
        this.monetaryTotal = monetaryTotal;
    }

    public Long getTcrTotal() {
        return tcrTotal;
    }

    public void setTcrTotal(Long tcrTotal) {
        this.tcrTotal = tcrTotal;
    }

    public Long getTransTotal() {
        return transTotal;
    }

    public void setTransTotal(Long transTotal) {
        this.transTotal = transTotal;
    }

    public Long getSrcAmount() {
        return srcAmount;
    }

    public void setSrcAmount(Long srcAmount) {
        this.srcAmount = srcAmount;
    }

    public Long getDstAmount() {
        return dstAmount;
    }

    public void setDstAmount(Long dstAmount) {
        this.dstAmount = dstAmount;
    }

    public Long getInstId() {
        return instId;
    }

    public void setInstId(Long instId) {
        this.instId = instId;
    }

    public Long getSessionFileId() {
        return sessionFileId;
    }

    public void setSessionFileId(Long sessionFileId) {
        this.sessionFileId = sessionFileId;
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

    public Object getModelId() {
        return getId();
    }

}

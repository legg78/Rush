package ru.bpc.sv2.ps.mastercard;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class AbuFileMessage implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -1L;

    private Long id;
    private Boolean isIssuing;
    private String status;
    private Long sessionId;
    private Integer instId;
    private String instName;
    private Integer networkId;
    private String networkName;
    private Date dateFrom;
    private Date dateTo;
    private Date messageDate;
    private Long fileId;
    private String fileName;
    private Long eventObjectId;
    private Long confirmFileId;
    private String ica;
    private String errorCode1;
    private String errorCode2;
    private String errorCode3;
    private String errorCode4;
    private String errorCode5;
    private String errorCode6;
    private String errorCode7;
    private String errorCode8;
    private String lang;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Boolean getIssuing() {
        return (isIssuing == null) ? true : isIssuing;
    }
    public void setIssuing(Boolean issuing) {
        isIssuing = issuing;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public Long getSessionId() {
        return sessionId;
    }
    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
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

    public Integer getNetworkId() {
        return networkId;
    }
    public void setNetworkId(Integer networkId) {
        this.networkId = networkId;
    }

    public String getNetworkName() {
        return networkName;
    }
    public void setNetworkName(String networkName) {
        this.networkName = networkName;
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

    public Date getMessageDate() {
        return messageDate;
    }
    public void setMessageDate(Date messageDate) {
        this.messageDate = messageDate;
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

    public Long getEventObjectId() {
        return eventObjectId;
    }
    public void setEventObjectId(Long eventObjectId) {
        this.eventObjectId = eventObjectId;
    }

    public Long getConfirmFileId() {
        return confirmFileId;
    }
    public void setConfirmFileId(Long confirmFileId) {
        this.confirmFileId = confirmFileId;
    }

    public String getIca() {
        return ica;
    }
    public void setIca(String ica) {
        this.ica = ica;
    }

    public String getErrorCode1() {
        return errorCode1;
    }
    public void setErrorCode1(String errorCode1) {
        this.errorCode1 = errorCode1;
    }

    public String getErrorCode2() {
        return errorCode2;
    }
    public void setErrorCode2(String errorCode2) {
        this.errorCode2 = errorCode2;
    }

    public String getErrorCode3() {
        return errorCode3;
    }
    public void setErrorCode3(String errorCode3) {
        this.errorCode3 = errorCode3;
    }

    public String getErrorCode4() {
        return errorCode4;
    }
    public void setErrorCode4(String errorCode4) {
        this.errorCode4 = errorCode4;
    }

    public String getErrorCode5() {
        return errorCode5;
    }
    public void setErrorCode5(String errorCode5) {
        this.errorCode5 = errorCode5;
    }

    public String getErrorCode6() {
        return errorCode6;
    }
    public void setErrorCode6(String errorCode6) {
        this.errorCode6 = errorCode6;
    }

    public String getErrorCode7() {
        return errorCode7;
    }
    public void setErrorCode7(String errorCode7) {
        this.errorCode7 = errorCode7;
    }

    public String getErrorCode8() {
        return errorCode8;
    }
    public void setErrorCode8(String errorCode8) {
        this.errorCode8 = errorCode8;
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
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("instId", getInstId());
        result.put("networkId", getNetworkId());
        result.put("fileId", getFileId());
        result.put("confirmFileId", getConfirmFileId());
        result.put("date", getMessageDate());
        result.put("ica", getIca());
        result.put("lang", getLang());
        return result;
    }
}

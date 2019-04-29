package ru.bpc.sv2.ps.mastercard;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class AbuFile implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -1L;

    private Long id;
    private Long sessionId;
    private Integer instId;
    private String instName;
    private Integer networkId;
    private String networkName;
    private String fileType;
    private String fileTypeName;
    private String fileName;
    private Boolean isIncoming;
    private String businessIca;
    private String reasonCode;
    private Date procDate;
    private Date dateFrom;
    private Date dateTo;
    private Date fileDate;
    private Integer totalMsgCount;
    private Integer totalAddedCount;
    private Integer totalChangedCount;
    private Integer totalErrorCount;
    private Long recordCount;
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

    public String getFileType() {
        return fileType;
    }
    public void setFileType(String fileType) {
        this.fileType = fileType;
    }

    public String getFileTypeName() {
        return fileTypeName;
    }
    public void setFileTypeName(String fileTypeName) {
        this.fileTypeName = fileTypeName;
    }

    public String getFileName() {
        return fileName;
    }
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Boolean getIncoming() {
        return isIncoming;
    }
    public void setIncoming(Boolean incoming) {
        isIncoming = incoming;
    }

    public String getBusinessIca() {
        return businessIca;
    }
    public void setBusinessIca(String businessIca) {
        this.businessIca = businessIca;
    }

    public String getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public Date getProcDate() {
        return procDate;
    }
    public void setProcDate(Date procDate) {
        this.procDate = procDate;
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

    public Date getFileDate() {
        return fileDate;
    }
    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    public Integer getTotalMsgCount() {
        return totalMsgCount;
    }
    public void setTotalMsgCount(Integer totalMsgCount) {
        this.totalMsgCount = totalMsgCount;
    }

    public Integer getTotalAddedCount() {
        return totalAddedCount;
    }
    public void setTotalAddedCount(Integer totalAddedCount) {
        this.totalAddedCount = totalAddedCount;
    }

    public Integer getTotalChangedCount() {
        return totalChangedCount;
    }
    public void setTotalChangedCount(Integer totalChangedCount) {
        this.totalChangedCount = totalChangedCount;
    }

    public Integer getTotalErrorCount() {
        return totalErrorCount;
    }
    public void setTotalErrorCount(Integer totalErrorCount) {
        this.totalErrorCount = totalErrorCount;
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
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("sessionId", getSessionId());
        result.put("instId", getInstId());
        result.put("fileType", getFileType());
        result.put("fileName", getFileName());
        result.put("fileDate", getFileDate());
        return result;
    }
}

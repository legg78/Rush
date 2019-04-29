package ru.bpc.sv2.ps.mastercard;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class MasterFile implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -367857103126887792L;

    // MCW_FILE
    private Long id;
    private Long instId;
    private Long networkId;
    private Boolean incoming;
    private Date procDate;
    private Long sessionFileId;
    private Boolean rejected;
    private Long rejectId;
    private String p0026;
    private String p0105;
    private String p0110;
    private String p0122;
    private Long p0301;
    private Long p0306;
    private String headerMti;
    private String headerDe024;
    private Long headerDe071;
    private String trailerMti;
    private String trailerDe024;
    private Long trailerDe071;
    private Boolean localFile;
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

    public Long getInstId() {
        return instId;
    }

    public void setInstId(Long instId) {
        this.instId = instId;
    }

    public Long getNetworkId() {
        return networkId;
    }

    public void setNetworkId(Long networkId) {
        this.networkId = networkId;
    }

    public Boolean getIncoming() {
        return incoming;
    }

    public void setIncoming(Boolean incoming) {
        this.incoming = incoming;
    }

    public Date getProcDate() {
        return procDate;
    }

    public void setProcDate(Date procDate) {
        this.procDate = procDate;
    }

    public Long getSessionFileId() {
        return sessionFileId;
    }

    public void setSessionFileId(Long sessionFileId) {
        this.sessionFileId = sessionFileId;
    }

    public Boolean getRejected() {
        return rejected;
    }

    public void setRejected(Boolean rejected) {
        this.rejected = rejected;
    }

    public Long getRejectId() {
        return rejectId;
    }

    public void setRejectId(Long rejectId) {
        this.rejectId = rejectId;
    }

    public String getP0026() {
        return p0026;
    }

    public void setP0026(String p0026) {
        this.p0026 = p0026;
    }

    public String getP0105() {
        return p0105;
    }

    public void setP0105(String p0105) {
        this.p0105 = p0105;
    }

    public String getP0110() {
        return p0110;
    }

    public void setP0110(String p0110) {
        this.p0110 = p0110;
    }

    public String getP0122() {
        return p0122;
    }

    public void setP0122(String p0122) {
        this.p0122 = p0122;
    }

    public Long getP0301() {
        return p0301;
    }

    public void setP0301(Long p0301) {
        this.p0301 = p0301;
    }

    public Long getP0306() {
        return p0306;
    }

    public void setP0306(Long p0306) {
        this.p0306 = p0306;
    }

    public String getHeaderMti() {
        return headerMti;
    }

    public void setHeaderMti(String headerMti) {
        this.headerMti = headerMti;
    }

    public String getHeaderDe024() {
        return headerDe024;
    }

    public void setHeaderDe024(String headerDe024) {
        this.headerDe024 = headerDe024;
    }

    public Long getHeaderDe071() {
        return headerDe071;
    }

    public void setHeaderDe071(Long headerDe071) {
        this.headerDe071 = headerDe071;
    }

    public String getTrailerMti() {
        return trailerMti;
    }

    public void setTrailerMti(String trailerMti) {
        this.trailerMti = trailerMti;
    }

    public String getTrailerDe024() {
        return trailerDe024;
    }

    public void setTrailerDe024(String trailerDe024) {
        this.trailerDe024 = trailerDe024;
    }

    public Long getTrailerDe071() {
        return trailerDe071;
    }

    public void setTrailerDe071(Long trailerDe071) {
        this.trailerDe071 = trailerDe071;
    }

    public Boolean getLocalFile() {
        return localFile;
    }

    public void setLocalFile(Boolean localFile) {
        this.localFile = localFile;
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

    public String getInstName() {
        return instName;
    }

    public void setInstName(String instName) {
        this.instName = instName;
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
        result.put("sessionId", getSessionId());
        result.put("fileName", getFileName());
        result.put("fileDate", getFileDate());
        return result;
    }
}

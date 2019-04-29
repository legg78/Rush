package ru.bpc.sv2.campaign;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class Campaign implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -1L;

    private Long id;
    private Integer seqNum;
    private Integer instId;
    private String instName;
    private String label;
    private String description;
    private Date startDateFrom;
    private Date startDate;
    private Date startDateTo;
    private Date endDateFrom;
    private Date endDate;
    private Date endDateTo;
    private String campaignNumber;
    private String campaignType;
    private String typeDescription;
    private String lang;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Integer getSeqNum() {
        return seqNum;
    }
    public void setSeqNum(Integer seqNum) {
        this.seqNum = seqNum;
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

    public String getLabel() {
        return label;
    }
    public void setLabel(String label) {
        this.label = label;
    }

    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }

    public Date getStartDateFrom() {
        return startDateFrom;
    }
    public void setStartDateFrom(Date startDateFrom) {
        this.startDateFrom = startDateFrom;
    }

    public Date getStartDate() {
        return startDate;
    }
    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getStartDateTo() {
        return startDateTo;
    }
    public void setStartDateTo(Date startDateTo) {
        this.startDateTo = startDateTo;
    }

    public Date getEndDateFrom() {
        return endDateFrom;
    }
    public void setEndDateFrom(Date endDateFrom) {
        this.endDateFrom = endDateFrom;
    }

    public Date getEndDate() {
        return endDate;
    }
    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public Date getEndDateTo() {
        return endDateTo;
    }
    public void setEndDateTo(Date endDateTo) {
        this.endDateTo = endDateTo;
    }

    public String getCampaignNumber() {
        return campaignNumber;
    }
    public void setCampaignNumber(String campaignNumber) {
        this.campaignNumber = campaignNumber;
    }

    public String getCampaignType() {
        return campaignType;
    }
    public void setCampaignType(String campaignType) {
        this.campaignType = campaignType;
    }

    public String getTypeDescription() {
        return typeDescription;
    }
    public void setTypeDescription(String typeDescription) {
        this.typeDescription = typeDescription;
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
    public Object clone() throws CloneNotSupportedException{
        return super.clone();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("instId", getInstId());
        result.put("label", getLabel());
        result.put("startDate", getStartDate());
        result.put("endDate", getEndDate());
        result.put("campaignNumber", getCampaignNumber());
        result.put("campaignType", getCampaignType());
        result.put("lang", getLang());
        return result;
    }
}

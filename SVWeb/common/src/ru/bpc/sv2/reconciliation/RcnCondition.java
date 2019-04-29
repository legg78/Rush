package ru.bpc.sv2.reconciliation;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

public class RcnCondition implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String name;
    private Integer seqNum;
    private Integer instId;
    private String instName;
    private String reconType;
    private String reconTypeName;
    private String condType;
    private String condTypeName;
    private String condition;
    private Long purposeId;
    private String purposeName;
    private String purposeNumber;
    private Long providerId;
    private String providerName;
    private String providerNumber;
    private String lang;
    private String module;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
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

    public String getReconType() {
        return reconType;
    }
    public void setReconType(String reconType) {
        this.reconType = reconType;
    }

    public String getReconTypeName() {
        return reconTypeName;
    }
    public void setReconTypeName(String reconTypeName) {
        this.reconTypeName = reconTypeName;
    }

    public String getCondType() {
        return condType;
    }
    public void setCondType(String condType) {
        this.condType = condType;
    }

    public String getCondTypeName() {
        return condTypeName;
    }
    public void setCondTypeName(String condTypeName) {
        this.condTypeName = condTypeName;
    }

    public String getCondition() {
        return condition;
    }
    public void setCondition(String condition) {
        this.condition = condition;
    }

    public Long getPurposeId() {
        return purposeId;
    }
    public void setPurposeId(Long purposeId) {
        this.purposeId = purposeId;
    }

    public String getPurposeName() {
        return purposeName;
    }
    public void setPurposeName(String purposeName) {
        this.purposeName = purposeName;
    }

    public String getPurposeNumber() {
        return purposeNumber;
    }
    public void setPurposeNumber(String purposeNumber) {
        this.purposeNumber = purposeNumber;
    }

    public Long getProviderId() {
        return providerId;
    }
    public void setProviderId(Long providerId) {
        this.providerId = providerId;
    }

    public String getProviderName() {
        return providerName;
    }
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getProviderNumber() {
        return providerNumber;
    }
    public void setProviderNumber(String providerNumber) {
        this.providerNumber = providerNumber;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
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
        result.put("seqnum", getSeqNum());
        result.put("inst_id", getInstId());
        result.put("recon_type", getReconType());
        result.put("cond_type", getCondType());
        result.put("condition", getCondition());
        result.put("purpose_id", getPurposeId());
        result.put("provider_id", getProviderId());
        return result;
    }
}

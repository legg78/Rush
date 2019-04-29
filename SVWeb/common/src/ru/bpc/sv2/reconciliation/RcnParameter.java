package ru.bpc.sv2.reconciliation;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class RcnParameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long instId;
    private String instName;
    private Integer seqNum;
    private Long providerId;
    private String providerName;
    private Long purposeId;
    private String purposeName;
    private Long paramId;
    private String paramName;
    private String paramValue;
    private String lang;
    private String module;

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

    public String getInstName() {
        return instName;
    }
    public void setInstName(String instName) {
        this.instName = instName;
    }

    public Integer getSeqNum() {
        return seqNum;
    }
    public void setSeqNum(Integer seqNum) {
        this.seqNum = seqNum;
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

    public Long getParamId() {
        return paramId;
    }
    public void setParamId(Long paramId) {
        this.paramId = paramId;
    }

    public String getParamName() {
        return paramName;
    }
    public void setParamName(String paramName) {
        this.paramName = paramName;
    }

    public String getParamValue() {
        return paramValue;
    }
    public void setParamValue(String paramValue) {
        this.paramValue = paramValue;
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
        result.put("purpose_id", getPurposeId());
        result.put("provider_id", getProviderId());
        result.put("param_id", getParamId());
        return result;
    }
}

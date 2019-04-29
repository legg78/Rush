package ru.bpc.sv2.rules;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class RuleAlgorithm implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Integer seqNum;
    private String algorithm;
    private String algorithmName;
    private String entryPoint;
    private String entryPointName;
    private Integer procedureId;
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

    public String getAlgorithm() {
        return algorithm;
    }
    public void setAlgorithm(String algorithm) {
        this.algorithm = algorithm;
    }

    public String getAlgorithmName() {
        return algorithmName;
    }
    public void setAlgorithmName(String algorithmName) {
        this.algorithmName = algorithmName;
    }

    public String getEntryPoint() {
        return entryPoint;
    }
    public void setEntryPoint(String entryPoint) {
        this.entryPoint = entryPoint;
    }

    public String getEntryPointName() {
        return entryPointName;
    }
    public void setEntryPointName(String entryPointName) {
        this.entryPointName = entryPointName;
    }

    public Integer getProcedureId() {
        return procedureId;
    }
    public void setProcedureId(Integer procedureId) {
        this.procedureId = procedureId;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    @Override
    public RuleAlgorithm clone() throws CloneNotSupportedException {
        return (RuleAlgorithm)super.clone();
    }
    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("seqNum", getSeqNum());
        result.put("algorithm", getAlgorithm());
        result.put("entryPoint", getEntryPoint());
        result.put("procId", getProcedureId());
        result.put("lang", getLang());
        return result;
    }
}

package ru.bpc.sv2.scoring;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class ScoringCriteria implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -367857103126887792L;

    private Long id;
    private Integer seqNum;
    private Long evaluationId;
    private Integer order;
    private String name;
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

    public Long getEvaluationId() {
        return evaluationId;
    }
    public void setEvaluationId(Long evaluationId) {
        this.evaluationId = evaluationId;
    }

    public Integer getOrder() {
        return order;
    }
    public void setOrder(Integer order) {
        this.order = order;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>(5);
        result.put("id", getId());
        result.put("seqNum", getSeqNum());
        result.put("name", getName());
        result.put("lang", getLang());
        result.put("order", getOrder());
        return result;
    }
    @Override
    public Object getModelId() {
        return getId();
    }
}

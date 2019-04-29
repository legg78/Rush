package ru.bpc.sv2.scoring;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class ScoringValue implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -367857103126887792L;

    private Long id;
    private Integer seqNum;
    private Long criteriaId;
    private Integer score;
    private Long maxScore;
    private String name;
    private String lang;

    private boolean selected = false;

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

    public Long getCriteriaId() {
        return criteriaId;
    }
    public void setCriteriaId(Long criteriaId) {
        this.criteriaId = criteriaId;
    }

    public Integer getScore() {
        return score;
    }
    public void setScore(Integer score) {
        this.score = score;
    }

    public Long getMaxScore() {
        return maxScore;
    }
    public void setMaxScore(Long maxScore) {
        this.maxScore = maxScore;
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

    public boolean isSelected() {
        return selected;
    }
    public void setSelected(boolean selected) {
        this.selected = selected;
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>(5);
        result.put("id", getId());
        result.put("seqNum", getSeqNum());
        result.put("name", getName());
        result.put("lang", getLang());
        result.put("score", getScore());
        return result;
    }
    @Override
    public Object getModelId() {
        return getId();
    }
}

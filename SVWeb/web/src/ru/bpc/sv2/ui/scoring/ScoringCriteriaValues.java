package ru.bpc.sv2.ui.scoring;

import ru.bpc.sv2.scoring.ScoringCriteria;
import ru.bpc.sv2.scoring.ScoringValue;

import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class ScoringCriteriaValues implements Serializable, Cloneable {
    private ScoringCriteria criteria;
    private List<SelectItem> values;
    private List<ScoringValue> items;
    private Long valueId;
    private Long maxScore;

    public ScoringCriteriaValues() {}
    public ScoringCriteriaValues(ScoringCriteria criteria) {
        setCriteria(criteria);
    }
    public ScoringCriteriaValues(ScoringCriteria criteria, List<ScoringValue> in) {
        setCriteria(criteria);
        if (in != null) {
            setItems(in);
            if (in.size() > 0) {
                setMaxScore((in.get(0).getMaxScore() != null) ? in.get(0).getMaxScore() : 0);
            } else {
                setMaxScore(0L);
            }
            List<SelectItem> values = new ArrayList<SelectItem>(in.size());
            for (ScoringValue item : in) {
                values.add(new SelectItem(item.getId(), item.getName()));
            }
            setValues(values);
        } else {
            setValues(null);
            setMaxScore(null);
        }
    }

    public ScoringCriteria getCriteria() {
        return criteria;
    }
    public void setCriteria(ScoringCriteria criteria) {
        this.criteria = criteria;
    }

    public List<SelectItem> getValues() {
        return values;
    }
    public void setValues(List<SelectItem> values) {
        this.values = values;
    }

    public List<ScoringValue> getItems() {
        return items;
    }
    public void setItems(List<ScoringValue> items) {
        this.items = items;
    }

    public Long getValueId() {
        return valueId;
    }
    public void setValueId(Long valueId) {
        this.valueId = valueId;
    }

    public Long getMaxScore() {
        return maxScore;
    }
    public void setMaxScore(Long maxScore) {
        this.maxScore = maxScore;
    }

    public Integer getScore() throws NumberFormatException {
        if (getItems() != null && getValueId() != null) {
            for (ScoringValue item : getItems()) {
                if (getValueId().equals(item.getId())) {
                    return (item.getScore() != null) ? item.getScore() : 0;
                }
            }
        }
        return 0;
    }

    public String getScoreInfo() throws NumberFormatException {
        return getScore() + "/" + getMaxScore();
    }
}

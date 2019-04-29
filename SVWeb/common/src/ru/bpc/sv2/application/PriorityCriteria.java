package ru.bpc.sv2.application;


import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class PriorityCriteria implements Serializable, ModelIdentifiable, Cloneable{
    private static final long serialVersionUID = 1L;

    private String criteriaName;
    private String criteriaValue;

    @Override
    public Object getModelId() {
        return getCriteriaName() + getCriteriaValue();
    }
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    public String getCriteriaName() {
        return criteriaName;
    }

    public void setCriteriaName(String criteriaName) {
        this.criteriaName = criteriaName;
    }

    public String getCriteriaValue() {
        return criteriaValue;
    }

    public void setCriteriaValue(String criteriaValue) {
        this.criteriaValue = criteriaValue;
    }
}


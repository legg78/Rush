package ru.bpc.sv2.common;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class FlexStandardField extends FlexField {
    private Long fieldId;
    private Integer standardId;
    private String standardName;
    private String standardType;

    public Long getFieldId() {
        return fieldId;
    }
    public void setFieldId(Long fieldId) {
        this.fieldId = fieldId;
    }

    public Integer getStandardId() {
        return standardId;
    }
    public void setStandardId(Integer standardId) {
        this.standardId = standardId;
    }

    public String getStandardName() {
        return standardName;
    }
    public void setStandardName(String standardName) {
        this.standardName = standardName;
    }

    public String getStandardType() {
        return standardType;
    }
    public void setStandardType(String standardType) {
        this.standardType = standardType;
    }

    @Override
    public Object getModelId() {
        return getId() + "_" + getFieldId() + "_" + getStandardId();
    }
    @Override
    public FlexStandardField clone() throws CloneNotSupportedException {
        return (FlexStandardField)super.clone();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = super.getAuditParameters();
        result.put("fieldId", getFieldId());
        result.put("standardId", getStandardId());
        return result;
    }
}

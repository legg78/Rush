package ru.bpc.sv2.common;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class FlexFieldUsage implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private Integer id;
    private Integer flexId;
    private String usage;
    private String usageName;
    private String usageDescription;

    public Integer getId() {
        return id;
    }

    @Override
    public Object getModelId() {
        return getId();
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getUsage() {
        return usage;
    }

    public void setUsage(String usage) {
        this.usage = usage;
    }

    public Integer getFieldId() {
        return flexId;
    }

    public void setFieldId(Integer flexId) {
        this.flexId = flexId;
    }

    public String getUsageName() {
        return usageName;
    }

    public void setUsageName(String usageName) {
        this.usageName = usageName;
    }

    public String getUsageDescription() {
        return usageDescription;
    }

    public void setUsageDescription(String usageDescription) {
        this.usageDescription = usageDescription;
    }


    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", this.getId());
        result.put("fieldId", this.getFieldId());
        result.put("usage", this.getUsage());
        return result;
    }

    @Override
    public FlexFieldUsage clone() throws CloneNotSupportedException {
        return (FlexFieldUsage) super.clone();
    }
}

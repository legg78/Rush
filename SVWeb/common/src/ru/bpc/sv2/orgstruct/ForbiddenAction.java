package ru.bpc.sv2.orgstruct;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class ForbiddenAction implements Cloneable, IAuditableObject, Serializable, ModelIdentifiable {
    private Long id;
    private String instStatus;
    private String dataAction;
    private String lang;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public String getInstStatus() {
        return instStatus;
    }
    public void setInstStatus(String instStatus) {
        this.instStatus = instStatus;
    }

    public String getDataAction() {
        return dataAction;
    }
    public void setDataAction(String dataAction) {
        this.dataAction = dataAction;
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
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", this.getId());
        result.put("instStatus", this.getInstStatus());
        result.put("dataAction", this.getDataAction());
        return result;
    }
    @Override
    public ForbiddenAction clone() throws CloneNotSupportedException{
        return (ForbiddenAction) super.clone();
    }
}

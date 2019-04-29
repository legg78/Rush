package ru.bpc.sv2.issuing;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.Map;

public abstract class BaseCard implements Serializable, ModelIdentifiable, Cloneable {

    private Long id;
    private String pinRequest;
    private String pinMailerRequest;
    private String embossingRequest;
    private String persoPriority;
    private String requestType;
    private String warningMsg;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getPinRequest() {
        return pinRequest;
    }

    public void setPinRequest(String pinRequest) {
        this.pinRequest = pinRequest;
    }

    public String getPinMailerRequest() {
        return pinMailerRequest;
    }

    public void setPinMailerRequest(String pinMailerRequest) {
        this.pinMailerRequest = pinMailerRequest;
    }

    public String getEmbossingRequest() {
        return embossingRequest;
    }

    public void setEmbossingRequest(String embossingRequest) {
        this.embossingRequest = embossingRequest;
    }

    public String getPersoPriority() {
        return persoPriority;
    }

    public void setPersoPriority(String persoPriority) {
        this.persoPriority = persoPriority;
    }

    public String getRequestType() {
        return requestType;
    }

    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }

    public String getWarningMsg() {
        return warningMsg;
    }

    public void setWarningMsg(String warningMsg) {
        this.warningMsg = warningMsg;
    }

    public abstract Map<String, Object> getAuditParameters();

    @Override
    public BaseCard clone() throws CloneNotSupportedException {
        return (BaseCard) super.clone();
    }

    @Override
    public Object getModelId() {
        return getId();
    }
}

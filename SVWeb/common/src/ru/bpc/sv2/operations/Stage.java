package ru.bpc.sv2.operations;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class Stage implements Serializable, ModelIdentifiable {

    private static final long serialVersionUID = 1L;

    private Long operId;
    private String procStage;
    private String procStageDesc;
    private String status;
    private String statusDesc;
    private String lang;

    public Object getModelId() {
        return operId + "_" + procStage;
    }

    public Long getOperId() {
        return operId;
    }

    public void setOperId(Long operId) {
        this.operId = operId;
    }

    public String getProcStage() {
        return procStage;
    }

    public void setProcStage(String procStage) {
        this.procStage = procStage;
    }

    public String getProcStageDesc() {
        return procStageDesc;
    }

    public void setProcStageDesc(String procStageDesc) {
        this.procStageDesc = procStageDesc;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDesc() {
        return statusDesc;
    }

    public void setStatusDesc(String statusDesc) {
        this.statusDesc = statusDesc;
    }

    public String getLang() {
        return lang;
    }

    public void setLang(String lang) {
        this.lang = lang;
    }
}

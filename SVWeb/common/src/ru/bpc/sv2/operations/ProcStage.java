package ru.bpc.sv2.operations;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ProcStage implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private Long id;
    private String msgType;
    private String sttlType;
    private String operType;
    private String procStage;
    private Integer execOrder;
    private String parentStage;
    private String splitMethod;
    private String status;
    private String resultStatus;
    private String name;
    private String description;
    private String lang;
    private String command;

    public Object getModelId() {
        return id;
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public String getMsgType() {
        return msgType;
    }
    public void setMsgType(String msgType) {
        this.msgType = msgType;
    }

    public String getSttlType() {
        return sttlType;
    }
    public void setSttlType(String sttlType) {
        this.sttlType = sttlType;
    }

    public String getOperType() {
        return operType;
    }
    public void setOperType(String operType) {
        this.operType = operType;
    }

    public String getProcStage() {
        return procStage;
    }
    public void setProcStage(String procStage) {
        this.procStage = procStage;
    }

    public Integer getExecOrder() {
        return execOrder;
    }
    public void setExecOrder(Integer execOrder) {
        this.execOrder = execOrder;
    }

    public String getParentStage() {
        return parentStage;
    }
    public void setParentStage(String parentStage) {
        this.parentStage = parentStage;
    }

    public String getSplitMethod() {
        return splitMethod;
    }
    public void setSplitMethod(String splitMethod) {
        this.splitMethod = splitMethod;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getResultStatus() {
        return resultStatus;
    }
    public void setResultStatus(String resultStatus) {
        this.resultStatus = resultStatus;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getCommand() {
        return command;
    }
    public void setCommand(String command) {
        this.command = command;
    }

    @Override
    public ProcStage clone() throws CloneNotSupportedException {
        return (ProcStage)super.clone();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("msgType", msgType);
        result.put("sttlType", sttlType);
        result.put("operType", operType);
        result.put("procStage", procStage);
        result.put("execOrder", execOrder);
        result.put("parentStage", parentStage);
        result.put("splitMethod", splitMethod);
        result.put("status", status);
        result.put("resultStatus", resultStatus);
        result.put("command", command);
        return result;
    }
}

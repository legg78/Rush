package ru.bpc.sv2.ps.mir;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

@SuppressWarnings("unused")
public class MirRejectCode implements Serializable, ModelIdentifiable, Cloneable {

    private static final long serialVersionUID = 1L;

    private Long rejectId;
    private String deNumber;
    private String severityCode;
    private String messageCode;
    private String subfieldId;
    private Integer id;

    public Object getModelId() {
        return id == null ? getRejectId() + "_" + getDeNumber() + "_" + getSubfieldId() : id;
    }

    public Long getRejectId() {
        return this.rejectId;
    }

    public void setRejectId(Long rejectId) {
        this.rejectId = rejectId;
    }

    public String getDeNumber() {
        return this.deNumber;
    }

    public void setDeNumber(String deNumber) {
        this.deNumber = deNumber;
    }

    public String getSeverityCode() {
        return this.severityCode;
    }

    public void setSeverityCode(String severityCode) {
        this.severityCode = severityCode;
    }

    public String getMessageCode() {
        return this.messageCode;
    }

    public void setMessageCode(String messageCode) {
        this.messageCode = messageCode;
    }

    public String getSubfieldId() {
        return this.subfieldId;
    }

    public void setSubfieldId(String subfieldId) {
        this.subfieldId = subfieldId;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Object clone() {
        Object result = null;
        try {
            result = super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return result;
    }
}
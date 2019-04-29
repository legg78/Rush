package ru.bpc.sv2.application;


import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class ApplicationLinkedObjects implements Serializable, ModelIdentifiable, Cloneable{
    private static final long serialVersionUID = -846121659302441691L;

    private Long applId;
    private Long objectId;
    private String entityType;
    private Integer seqnum;
    private String objectDescription;

    @Override
    public Object getModelId() {
        return getEntityType() + getObjectId() + getSeqnum();
    }
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    public Long getApplId() {
        return applId;
    }
    public void setApplId(Long applId) {
        this.applId = applId;
    }

    public Long getObjectId() {
        return objectId;
    }
    public void setObjectId(Long objectId) {
        this.objectId = objectId;
    }

    public String getEntityType() {
        return entityType;
    }
    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public Integer getSeqnum() {
        return seqnum;
    }
    public void setSeqnum(Integer seqnum) {
        this.seqnum = seqnum;
    }

    public String getObjectDescription() {
        return objectDescription;
    }
    public void setObjectDescription(String objectDescription) {
        this.objectDescription = objectDescription;
    }
}


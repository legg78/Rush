package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Purposes page.
 */
public class PmoService implements ModelIdentifiable, IAuditableObject, Serializable, Cloneable {
    private static final long serialVersionUID = 549943522920261631L;

    private Integer id;
    private Integer seqNum;
    private String label;
    private String description;
    private Integer direction;
    private String lang;
    private String hostAlgorithm;
    private String shortName;
    private Integer instId;
    private String instName;

    public PmoService() {}

    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }

    public String getLabel() {
        return label;
    }
    public void setLabel(String label) {
        this.label = label;
    }

    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getDirection() {
        return direction;
    }
    public void setDirection(Integer direction) {
        this.direction = direction;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public Integer getSeqNum() {
        return seqNum;
    }
    public void setSeqNum(Integer seqNum) {
        this.seqNum = seqNum;
    }

    public String getHostAlgorithm() {
        return hostAlgorithm;
    }
    public void setHostAlgorithm(String hostAlgorithm) {
        this.hostAlgorithm = hostAlgorithm;
    }

    public String getShortName() {
        return shortName;
    }
    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getInstName() {
        return instName;
    }
    public void setInstName(String instName) {
        this.instName = instName;
    }

    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", this.id);
        result.put("direction", this.getDirection());
        result.put("label", this.getLabel());
        result.put("description", this.getDescription());
        result.put("lang", this.getLang());
        result.put("shortName", this.getShortName());
        result.put("instId", this.getInstId());
        return result;
    }
}
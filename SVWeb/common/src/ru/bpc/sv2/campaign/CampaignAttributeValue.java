package ru.bpc.sv2.campaign;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.products.AttributeValue;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class CampaignAttributeValue implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -1L;

    private Long id;
    private Long campaignId;
    private Long attributeValueId;
    private String lang;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getCampaignId() {
        return campaignId;
    }
    public void setCampaignId(Long campaignId) {
        this.campaignId = campaignId;
    }

    public Long getAttributeValueId() {
        return attributeValueId;
    }
    public void setAttributeValueId(Long attributeValueId) {
        this.attributeValueId = attributeValueId;
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
    public Object clone() throws CloneNotSupportedException{
        return super.clone();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("campaignId", getCampaignId());
        result.put("attributeValueId", getAttributeValueId());
        result.put("lang", getLang());
        return result;
    }
}

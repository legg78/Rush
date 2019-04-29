package ru.bpc.sv2.campaign;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;
import ru.bpc.sv2.products.Attribute;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class CampaignAttribute implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -1L;
    
    private Long id;
    private Long campaignId;
    private Long productId;
    private String productLabel;
    private Long serviceId;
    private String serviceLabel;
    private Long attributeId;
    private String label;
    private String description;
    private String shortName;
    private String entityType;
    private String objectType;
    private String dataType;
    private String lang;

    private Long parentId;
    private Integer instId;
    private int level;
    private boolean isLeaf;
    private List<CampaignAttribute> children;

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

    public Long getProductId() {
        return productId;
    }
    public void setProductId(Long productId) {
        this.productId = productId;
    }

    public String getProductLabel() {
        return productLabel;
    }
    public void setProductLabel(String productLabel) {
        this.productLabel = productLabel;
    }

    public Long getServiceId() {
        return serviceId;
    }
    public void setServiceId(Long serviceId) {
        this.serviceId = serviceId;
    }
    public void clearServiceId() {
        setServiceId(null);
    }

    public String getServiceLabel() {
        return serviceLabel;
    }
    public void setServiceLabel(String serviceLabel) {
        this.serviceLabel = serviceLabel;
    }

    public Long getAttributeId() {
        return attributeId;
    }
    public void setAttributeId(Long attributeId) {
        this.attributeId = attributeId;
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

    public String getShortName() {
        return shortName;
    }
    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public String getEntityType() {
        return entityType;
    }
    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public String getObjectType() {
        return objectType;
    }
    public void setObjectType(String objectType) {
        this.objectType = objectType;
    }

    public String getDataType() {
        return dataType;
    }
    public void setDataType(String dataType) {
        this.dataType = dataType;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public Long getParentId() {
        return parentId;
    }
    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public int getLevel() {
        return level;
    }
    public void setLevel(int level) {
        this.level = level;
    }

    public int getAttrLevel() {
        return level;
    }
    public void setAttrLevel(int level) {
        this.level = level;
    }

    public boolean isLeaf() {
        return isLeaf;
    }
    public void setLeaf(boolean leaf) {
        isLeaf = leaf;
    }

    public List<CampaignAttribute> getChildren() {
        return children;
    }
    public void setChildren(List<CampaignAttribute> children) {
        this.children = children;
    }
    public boolean hasChildren() {
        return (children != null) ? !children.isEmpty() : false;
    }

    public boolean isProduct() {
        return (id != null) && id.equals(productId);
    }
    public boolean isService() {
        return (id != null) && id.equals(serviceId);
    }
    public boolean isAttribute() {
        return (id != null) && id.equals(attributeId);
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
        result.put("productId", getProductId());
        result.put("serviceId", getServiceId());
        result.put("attributeId", getAttributeId());
        result.put("label", getLabel());
        result.put("lang", getLang());
        return result;
    }
}

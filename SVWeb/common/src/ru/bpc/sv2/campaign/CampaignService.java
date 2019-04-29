package ru.bpc.sv2.campaign;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class CampaignService implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -1L;

    private Long id;
    private Long campaignId;
    private Long productId;
    private String productNumber;
    private String productLabel;
    private String productType;
    private Long serviceId;
    private String serviceNumber;
    private String serviceLabel;
    private String lang;

    private boolean checked;

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

    public String getProductNumber() {
        return productNumber;
    }
    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }

    public String getProductLabel() {
        return productLabel;
    }
    public void setProductLabel(String productLabel) {
        this.productLabel = productLabel;
    }

    public String getProductType() {
        return productType;
    }
    public void setProductType(String productType) {
        this.productType = productType;
    }

    public Long getServiceId() {
        return serviceId;
    }
    public void setServiceId(Long serviceId) {
        this.serviceId = serviceId;
    }

    public String getServiceNumber() {
        return serviceNumber;
    }
    public void setServiceNumber(String serviceNumber) {
        this.serviceNumber = serviceNumber;
    }

    public String getServiceLabel() {
        return serviceLabel;
    }
    public void setServiceLabel(String serviceLabel) {
        this.serviceLabel = serviceLabel;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public boolean isChecked() {
        return checked;
    }
    public void setChecked(boolean checked) {
        this.checked = checked;
    }

    @Override
    public Object getModelId() {
        return getId() + "_" + getServiceId() + "_" + getProductId();
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
        result.put("lang", getLang());
        return result;
    }
}

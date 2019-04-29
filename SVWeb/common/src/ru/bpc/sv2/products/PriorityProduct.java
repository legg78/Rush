package ru.bpc.sv2.products;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class PriorityProduct implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
    private static final long serialVersionUID = 1L;

    @Override
    public Object getModelId() {
        return id;
    }

    private Long id;
    private Integer productId;
    private Integer parentProductId;
    private String productNumber;
    private String productDescription;
    private String productCategory;
    private String productSubcategory;
    private String productLevel3;
    private Date creationDate;
    private String productLevel4;
    private String productLag;

    //UI Filters
    private Date dateFrom;
    private Date dateTo;

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProduct_id(Integer productId) {
        this.productId = productId;
    }

    public Integer getParentProductId() {
        return parentProductId;
    }

    public void setParentProductId(Integer parentProductId) {
        this.parentProductId = parentProductId;
    }

    public String getProductNumber() {
        return productNumber;
    }

    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }

    public String getProductDescription() {
        return productDescription;
    }

    public void setProductDescription(String productDescription) {
        this.productDescription = productDescription;
    }

    public String getProductCategory() {
        return productCategory;
    }

    public void setProductCategory(String productCategory) {
        this.productCategory = productCategory;
    }

    public String getProductSubcategory() {
        return productSubcategory;
    }

    public void setProductSubcategory(String productSubcategory) {
        this.productSubcategory = productSubcategory;
    }

    public String getProductLevel3() {
        return productLevel3;
    }

    public void setProductLevel3(String productLevel3) {
        this.productLevel3 = productLevel3;
    }

    public Date getCreationDate() {
        return creationDate;
    }

    public void setCreationDate(Date creationDate) {
        this.creationDate = creationDate;
    }

    public String getProductLevel4() {
        return productLevel4;
    }

    public void setProductLevel4(String productLevel4) {
        this.productLevel4 = productLevel4;
    }

    public String getProductLag() {
        return productLag;
    }

    public void setProductLag(String productLag) {
        this.productLag = productLag;
    }

    public Date getDateFrom() {
        return dateFrom;
    }

    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    public Date getDateTo() {
        return dateTo;
    }

    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", this.getId());
        result.put("productId", this.getProductId());
        result.put("parentProductId", this.getParentProductId());
        result.put("productNumber", this.getProductNumber());
        result.put("productDescription", this.getProductDescription());
        result.put("productCategory", this.getProductCategory());
        result.put("productSubcategory", this.getProductSubcategory());
        result.put("productLevel3", this.getProductLevel3());
        result.put("creationDate", this.getCreationDate());
        result.put("productLevel4", this.getProductLevel4());
        result.put("productLag", this.getProductLevel4());
        return result;
    }

}

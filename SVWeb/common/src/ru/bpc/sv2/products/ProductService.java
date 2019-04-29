package ru.bpc.sv2.products;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class ProductService implements Serializable, TreeIdentifiable<ProductService>, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private Long parentId;
	private Integer serviceId;
	private Integer productId;
	private Integer minCount;
	private Integer maxCount;
	private String serviceName;
	private String productName;
	private String serviceStatus;
	private Integer avalCount;
	private Integer currentCount;
	private String entityType;
	private int level;
	private boolean isLeaf;
	private List<ProductService> children;
	private Integer productParentId;
	private String serviceNumber;
	private String productNumber;
	private String conditionalGroup;
	private boolean isChecked;
	private boolean isCheckedOld;

	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Long getParentId() {
		return parentId;
	}
	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public Integer getServiceId() {
		return serviceId;
	}
	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
	}

	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Integer getMinCount() {
		return minCount;
	}
	public void setMinCount(Integer minCount) {
		this.minCount = minCount;
	}

	public Integer getMaxCount() {
		return maxCount;
	}
	public void setMaxCount(Integer maxCount) {
		this.maxCount = maxCount;
	}

	public String getServiceName() {
		return serviceName;
	}
	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}

	public boolean isInherited() {
		return productParentId != null;
	}

	public String getServiceStatus() {
		return serviceStatus;
	}
	public void setServiceStatus(String serviceStatus) {
		this.serviceStatus = serviceStatus;
	}

	public Integer getAvalCount() {
		return avalCount;
	}
	public void setAvalCount(Integer avalCount) {
		this.avalCount = avalCount;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getCurrentCount() {
		return currentCount;
	}
	public void setCurrentCount(Integer currentCount) {
		this.currentCount = currentCount;
	}

	public boolean isMandatory() {
		if (minCount != null && minCount > 0) {
			return true;
		}
		return false;
	}
	public void setMandatory(boolean mandatory) {}

	public int getLevel() {
		return level;
	}
	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}
	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public Integer getProductParentId() {
		return productParentId;
	}
	public void setProductParentId(Integer productParentId) {
		this.productParentId = productParentId;
	}

	public boolean isUnlimited() {
		if (getMaxCount()==null) return false;
		return getMaxCount().intValue()==9999;
	}
	public void setUnlimited(boolean unlimited) {
		if(unlimited) setMaxCount(Integer.valueOf(9999));
	}

	public String getServiceNumber() {
		return serviceNumber;
	}
	public void setServiceNumber(String serviceNumber) {
		this.serviceNumber = serviceNumber;
	}

	public String getProductNumber() {
		return productNumber;
	}
	public void setProductNumber(String productNumber) {
		this.productNumber = productNumber;
	}

	public String getConditionalGroup() {
		return conditionalGroup;
	}
	public void setConditionalGroup(String conditionalGroup) {
		this.conditionalGroup = conditionalGroup;
	}

	public boolean isChecked() {
		return isChecked;
	}
	public void setChecked(boolean checked) {
		isChecked = checked;
	}

	public boolean isCheckedOld() {
		return isCheckedOld;
	}
	public void setCheckedOld(boolean checkedOld) {
		isCheckedOld = checkedOld;
	}

	@Override
	public List<ProductService> getChildren() {
		return children;
	}
	@Override
	public void setChildren(List<ProductService> children) {
		this.children = children;
	}
	@Override
	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("parentId", getParentId());
		result.put("serviceId", getServiceId());
		result.put("productId", getProductId());
		result.put("minCount", getMinCount());
		result.put("maxCount", getMaxCount());
		return result;
	}
}

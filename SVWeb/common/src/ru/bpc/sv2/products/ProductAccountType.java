package ru.bpc.sv2.products;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

@SuppressWarnings("serial")
public class ProductAccountType implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private Long id;
	private int productId;
	private String accountType;
	private String accountTypeName;
	private Long schemeId;
	private Long serviceId;
	private String currency;
	private String serviceName;
	private String lang;
	private String avalAlgorithm;

	private String entityType;
	private Integer minCount;
	private Integer avalCount;
	private Integer currentCount;
	private Integer maxCount;
	private boolean isChecked;
	private boolean isCheckedOld;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public int getProductId() {
		return productId;
	}
	public void setProductId(int productId) {
		this.productId = productId;
	}

	public String getAccountType() {
		return accountType;
	}
	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public String getAccountTypeName() {
		return accountTypeName;
	}
	public void setAccountTypeName(String accountTypeName) {
		this.accountTypeName = accountTypeName;
	}

	public Long getServiceId() {
		return serviceId;
	}
	public void setServiceId(Long serviceId) {
		this.serviceId = serviceId;
	}

	public Long getSchemeId() {
		return schemeId;
	}
	public void setSchemeId(Long schemId) {
		this.schemeId = schemId;
	}

	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getServiceName() {
		return serviceName;
	}
	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getAvalAlgorithm() {
		return avalAlgorithm;
	}
	public void setAvalAlgorithm(String avalAlgorithm) {
		this.avalAlgorithm = avalAlgorithm;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getMinCount() {
		return minCount;
	}
	public void setMinCount(Integer minCount) {
		this.minCount = minCount;
	}

	public Integer getAvalCount() {
		return avalCount;
	}
	public void setAvalCount(Integer avalCount) {
		this.avalCount = avalCount;
	}

	public Integer getCurrentCount() {
		return currentCount;
	}
	public void setCurrentCount(Integer currentCount) {
		this.currentCount = currentCount;
	}

	public Integer getMaxCount() {
		return maxCount;
	}
	public void setMaxCount(Integer maxCount) {
		this.maxCount = maxCount;
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
	public Object getModelId() {
		return getId();
	}
	@Override
	public ProductAccountType clone() throws CloneNotSupportedException{
		return ((ProductAccountType)super.clone());
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("productId", getProductId());
		result.put("accountType", getAccountType());
		result.put("currency", getCurrency());
		result.put("schemeId", getSchemeId());
		result.put("serviceId", getServiceId());
		result.put("avalAlgorithm", getAvalAlgorithm());
		return result;
	}
}

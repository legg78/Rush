package ru.bpc.sv2.application;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ApplicationService implements ModelIdentifiable, Serializable{

	/**
	 * 
	 */
	private static final long serialVersionUID = -4991241886310869900L;
	private Integer id;
	private Integer productId;
	private String entityType;
	private Integer serviceTypeId;
	private Short minCount;
	private Short maxCount;
	private boolean initial;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getServiceTypeId() {
		return serviceTypeId;
	}

	public void setServiceTypeId(Integer serviceTypeId) {
		this.serviceTypeId = serviceTypeId;
	}

	public Short getMinCount() {
		return minCount;
	}

	public void setMinCount(Short minCount) {
		this.minCount = minCount;
	}

	public Short getMaxCount() {
		return maxCount;
	}

	public void setMaxCount(Short maxCount) {
		this.maxCount = maxCount;
	}

	public boolean isInitial() {
		return initial;
	}

	public void setInitial(boolean initial) {
		this.initial = initial;
	}
	
}


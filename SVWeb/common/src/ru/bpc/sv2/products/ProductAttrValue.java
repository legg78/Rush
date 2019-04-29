package ru.bpc.sv2.products;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProductAttrValue implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer attrId;
	private Long productId;
	private Long ownerProductId;
	private String ownerProductName;
	private Integer modId;
	private String modName;
	private Integer modPriority;
	private Date startDate;
	private Date endDate;
	private Object value;
	private String valueV;	// varchar value
	private Double valueN;	// number value
	private Date valueD;	// date value
	private String valueDesc;
	private Long valueId;
	private String lang;
	private String objectType;
	private Integer levelPriority;
	private String entityType;
	private String attrName;
	
	//TODO: for Tereshin's product 
	private Integer instId;
	
	public Object getModelId() {
		return attrId + "." + productId + "_" + ownerProductId + "." + valueId;
	}

	public Integer getAttrId() {
		return attrId;
	}

	public void setAttrId(Integer attrId) {
		this.attrId = attrId;
	}

	public Long getProductId() {
		return productId;
	}

	public void setProductId(Long productId) {
		this.productId = productId;
	}

	public Long getOwnerProductId() {
		return ownerProductId;
	}

	public void setOwnerProductId(Long ownerProductId) {
		this.ownerProductId = ownerProductId;
	}

	public String getOwnerProductName() {
		return ownerProductName;
	}

	public void setOwnerProductName(String ownerProductName) {
		this.ownerProductName = ownerProductName;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Object getValue() {
		return value;
	}

	public void setValue(Object value) {
		this.value = value;
	}

	public String getModName() {
		return modName;
	}

	public void setModName(String modName) {
		this.modName = modName;
	}

	public String getValueDesc() {
		return valueDesc;
	}

	public void setValueDesc(String valueDesc) {
		this.valueDesc = valueDesc;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public Integer getLevelPriority() {
		return levelPriority;
	}

	public void setLevelPriority(Integer levelPriority) {
		this.levelPriority = levelPriority;
	}

	public boolean isInherited() {
		return !productId.equals(ownerProductId);
	}

	public Long getValueId() {
		return valueId;
	}

	public void setValueId(Long valueId) {
		this.valueId = valueId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getAttrName() {
		return attrName;
	}

	public void setAttrName(String attrName) {
		this.attrName = attrName;
	}

	public String getValueV() {
		return valueV;
	}

	public void setValueV(String valueV) {
		this.valueV = valueV;
	}

	public Double getValueN() {
		return valueN;
	}

	public void setValueN(Double valueN) {
		this.valueN = valueN;
	}

	public Date getValueD() {
		return valueD;
	}

	public void setValueD(Date valueD) {
		this.valueD = valueD;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}
	
	public Integer getModPriority() {
		return modPriority;
	}

	public void setModPriority(Integer modPriority) {
		this.modPriority = modPriority;
	}

	public String getEffectivePeriod() {
		String period = "";
		if (startDate != null) {
			if (endDate == null) {
				period += "From ";
			}
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
			period += sdf.format(startDate);
			if (endDate != null) {
				period += " - ";
			}
		}
		if (endDate != null) {
			if (startDate == null) {
				period += "Till ";
			}
			SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
			period += sdf.format(endDate);
		}
		return period;

	}
}

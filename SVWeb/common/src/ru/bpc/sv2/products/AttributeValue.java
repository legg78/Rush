package ru.bpc.sv2.products;

import java.io.Serializable;
import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.fees.Fee;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AttributeValue implements Serializable, ModelIdentifiable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer attrId;
	private Long objectId;
	private Integer serviceId;
	private Long ownerProductId;
	private String ownerProductName;
	private Integer modId;
	private String modName;
	private Integer modPriority;
	private Date startDate;
	private Date endDate;
	private Date regDate;
	private Object value;
	private String valueV;	// varchar value
	private BigDecimal valueN;	// number value
	private Date valueD;	// date value
	private String valueDesc;
	private Long valueId;
	private String lang;
	private String objectType;
	private Integer levelPriority;
	private String entityType;
	private String attrName;
	private boolean actual;
	private boolean isCyclic;
	private Long campaignId;
	private String campaignNumber;
	private String campaignName;

	public boolean isActual() {
		return actual;
	}

	public void setActual(boolean actual) {
		this.actual = actual;
	}

	//TODO: for Tereshin's product 
	private Integer instId;
	
	public Object getModelId() {
		return attrId + "." + objectId + "_" + ownerProductId + "." + valueId;
	}

	public Integer getAttrId() {
		return attrId;
	}

	public void setAttrId(Integer attrId) {
		this.attrId = attrId;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Integer getServiceId() {
		return serviceId;
	}

	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
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
		AttributeValue clone = (AttributeValue) super.clone();
		if (startDate != null) {
			clone.setStartDate(new Date(startDate.getTime()));
		}
		if (endDate != null) {
			clone.setEndDate(new Date(endDate.getTime()));
		}
		if (valueD != null) {
			clone.setValueD(new Date(valueD.getTime()));
		}
		
		return clone;
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
		// true only in case of products, otherwise... who knows?
		return !objectId.equals(ownerProductId);
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

	public BigDecimal getValueN() {
		return valueN;
	}

	public void setValueN(BigDecimal valueN) {
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
	
	public Date getRegDate() {
		return regDate;
	}

	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}

	public boolean isProduct() {
		return ProductConstants.ACQUIRING_PRODUCT.equals(entityType)
				|| ProductConstants.ISSUING_PRODUCT.equals(entityType);
	}
	public boolean isCyclic() {
		return isCyclic;
	}

	public void setCyclic(boolean cyclic) {
		isCyclic = cyclic;
	}
	
	public AttributeValue copy() {
		AttributeValue copy = new AttributeValue();
		copy.setAttrId(attrId);
		copy.setObjectId(objectId);
		copy.setOwnerProductId(ownerProductId);
		copy.setOwnerProductName(ownerProductName);
		copy.setModId(modId);
		copy.setModName(modName);
		copy.setModPriority(modPriority);
		copy.setValueV(valueV);
		copy.setValueN(valueN);
		copy.setValueDesc(valueDesc);
		copy.setValueId(valueId);
		copy.setLang(lang);
		copy.setObjectType(objectType);
		copy.setLevelPriority(levelPriority);
		copy.setEntityType(entityType);
		copy.setAttrName(attrName);
		copy.setInstId(instId);
		copy.setServiceId(serviceId);
		if (startDate != null ) copy.setStartDate(new Date(startDate.getTime()));
		if (endDate != null) copy.setEndDate(new Date(endDate.getTime()));
		if (regDate != null) copy.setRegDate(new Date(regDate.getTime()));
		if (valueD != null) copy.setValueD(new Date(valueD.getTime()));
		
		if (value instanceof Fee) {
			try {
				copy.setValue(((Fee) value).clone());
			} catch (CloneNotSupportedException e) {
				copy.setValue(value);
			}
		} else if (value instanceof Limit) {
			try {
				copy.setValue(((Limit) value).clone());
			} catch (CloneNotSupportedException e) {
				copy.setValue(value);
			}
		} else if (value instanceof Cycle) {
			try {
				copy.setValue(((Cycle) value).clone());
			} catch (CloneNotSupportedException e) {
				copy.setValue(value);
			}
		} else {
			copy.setValue(value);
		}
		
		return copy;
	}

	public Long getCampaignId() {
		return campaignId;
	}

	public void setCampaignId(Long campaignId) {
		this.campaignId = campaignId;
	}

	public String getCampaignNumber() {
		return campaignNumber;
	}

	public void setCampaignNumber(String campaignNumber) {
		this.campaignNumber = campaignNumber;
	}

	public String getCampaignName() {
		return campaignName;
	}

	public void setCampaignName(String campaignName) {
		this.campaignName = campaignName;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getValueId());
		result.put("issInstId", getServiceId());
		result.put("issNetworkId", getEntityType());
		result.put("issNetworkId", getObjectId());
		result.put("issNetworkId", getAttrName());
		result.put("modId", getModId());
		result.put("priority", getStartDate());
		result.put("sttlType", getEndDate());
		result.put("matchStatus", getValueV());
		result.put("matchStatus", getValueN());
		result.put("matchStatus", getValueD());
		return result;
	}

}

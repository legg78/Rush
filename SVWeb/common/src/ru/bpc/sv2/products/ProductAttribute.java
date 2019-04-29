package ru.bpc.sv2.products;

import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.*;

public class ProductAttribute implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	public static final String DEF_LEVEL_OBJECT = "SADLOBJT";
	public static final String DEF_LEVEL_PRODUCT = "SADLPRDT";
	public static final String DEF_LEVEL_SERVICE = "SADLSRVC";
	
	private Integer id;
	private Integer parentId;
	private String systemName;
	private String label;
	private String fullDesc;
	private String lang;
	private int level;
	private boolean isLeaf;
	private Short displayOrder;
	private ArrayList<ProductAttribute> children;
	private String scaleName;
	private Integer scaleId;
	private Integer instId; 
	private String instName;
	private String attrEntityType;
	private Short lovId;
	private String dataType;
	private String attrObjectType;
	private String entityType;
	private Integer productId;
	private Integer serviceId;
	private String defLevel;
	private String serviceStatus;
	private boolean visible;
	private String value;
	private String valueV;	// varchar value
	private BigDecimal valueN;	// number value
	private Date valueD;
	private List<AttributeValue> values;
	private boolean readonly;
    private Integer feeId;
	private String feeCurrency;

	public boolean isVisible() {
		return visible;
	}

	public void setVisible(boolean visible) {
		this.visible = visible;
	}

	public Object getModelId() {
		return getId() + "_" + getServiceId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getParentId() {
		return parentId;
	}

	public void setParentId(Integer parentId) {
		this.parentId = parentId;
	}

	public String getSystemName() {
		return systemName;
	}

	public void setSystemName(String systemName) {
		this.systemName = systemName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

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

	public ArrayList<ProductAttribute> getChildren() {
		return children;
	}

	public void setChildren(ArrayList<ProductAttribute> children) {
		this.children = children;
	}

	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getFullDesc() {
		return fullDesc;
	}

	public void setFullDesc(String fullDesc) {
		this.fullDesc = fullDesc;
	}

	public Short getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(Short displayOrder) {
		this.displayOrder = displayOrder;
	}
	
	/**
	 * @return Attribute description if it's defined or attribute name otherwise
	 */
	public String getAttributeName() {
		return (label != null && label.length() > 0) ? label : systemName;
	}

	public String getScaleName() {
		return scaleName;
	}

	public void setScaleName(String scaleName) {
		this.scaleName = scaleName;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Short getLovId() {
		return lovId;
	}

	public void setLovId(Short lovId) {
		this.lovId = lovId;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getAttrEntityType() {
		return attrEntityType;
	}

	public void setAttrEntityType(String attrEntityType) {
		this.attrEntityType = attrEntityType;
	}

	public String getAttrObjectType() {
		return attrObjectType;
	}

	public void setAttrObjectType(String attrObjectType) {
		this.attrObjectType = attrObjectType;
	}

	public Integer getScaleId() {
		return scaleId;
	}

	public void setScaleId(Integer scaleId) {
		this.scaleId = scaleId;
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

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Integer getServiceId() {
		return serviceId;
	}

	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
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

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result
				+ ((displayOrder == null) ? 0 : displayOrder.hashCode());
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + level;
		result = prime * result + ((lovId == null) ? 0 : lovId.hashCode());
		result = prime * result
				+ ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + ((scaleId == null) ? 0 : scaleId.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ProductAttribute other = (ProductAttribute) obj;
		if (displayOrder == null) {
			if (other.displayOrder != null)
				return false;
		} else if (!displayOrder.equals(other.displayOrder))
			return false;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		if (level != other.level)
			return false;
		if (lovId == null) {
			if (other.lovId != null)
				return false;
		} else if (!lovId.equals(other.lovId))
			return false;
		if (parentId == null) {
			if (other.parentId != null)
				return false;
		} else if (!parentId.equals(other.parentId))
			return false;
		if (scaleId == null) {
			if (other.scaleId != null)
				return false;
		} else if (!scaleId.equals(other.scaleId))
			return false;
		return true;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		ProductAttribute clone = (ProductAttribute) super.clone();
		
		//make deep copy of an array
		if (this.children != null) {
			ArrayList<ProductAttribute> children = new ArrayList<ProductAttribute>(this.children.size());
			for (ProductAttribute child: this.children) {
				children.add(child);
			}
			clone.setChildren(children);
		}
		
		return clone;
	}
	
	public String getDefLevel() {
		return defLevel;
	}

	public void setDefLevel(String defLevel) {
		this.defLevel = defLevel;
	}

	public boolean isDefLevelObject() {
		return DEF_LEVEL_OBJECT.equals(defLevel);
	}

	public boolean isDefLevelProduct() {
		return DEF_LEVEL_PRODUCT.equals(defLevel);
	}

	public boolean isDefLevelService() {
		return DEF_LEVEL_SERVICE.equals(defLevel);
	}
	
	public boolean isChar(){
		return (DataTypes.CHAR.equals(dataType) && !isComplex());
	}
	
	public boolean isNumber(){
		return (DataTypes.NUMBER.equals(dataType) && !isComplex());
	}
	
	public boolean isDate(){
		return (DataTypes.DATE.equals(dataType) && !isComplex());
	}
	
	public boolean isCycle(){
		return EntityNames.CYCLE.equals(attrEntityType);
	}
	
	public boolean isLimit(){
		return EntityNames.LIMIT.equals(attrEntityType);
	}
	
	public boolean isFee(){
		return EntityNames.FEE.equals(attrEntityType);
	}
	
	public boolean isComplex(){
		return isCycle() || isLimit() || isFee();
	}

	public String getServiceStatus() {
		return serviceStatus;
	}

	public void setServiceStatus(String serviceStatus) {
		this.serviceStatus = serviceStatus;
	}
	
	public boolean isClosed() {
		return ProductConstants.STATUS_CLOSED_SERVICE.equals(serviceStatus);
	}

	public List<AttributeValue> getValues() {
		return values;
	}

	public void setValues(List<AttributeValue> values) {
		this.values = values;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("serviceId", getServiceId());
		result.put("visible", isVisible());
		return result;
	}

	public boolean isReadonly() {
		return readonly;
	}

	public void setReadonly(boolean readonly) {
		this.readonly = readonly;
	}

    public Integer getFeeId() {
        return feeId;
    }

    public void setFeeId(Integer feeId) {
        this.feeId = feeId;
    }

    public String getFeeCurrency() {
        return feeCurrency;
    }

    public void setFeeCurrency(String feeCurrency) {
        this.feeCurrency = feeCurrency;
    }
}

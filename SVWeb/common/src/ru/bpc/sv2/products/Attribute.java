package ru.bpc.sv2.products;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class Attribute implements Serializable, TreeIdentifiable<Attribute>, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long parentId;
	private Integer serviceTypeId;
	private String name;
	private String dataType;
	private Short lovId;
	private Short displayOrder;
	private String entityType;
	private String objectType;
	private String definitionLevel;
	private String lang;
	private String label;
	private String description;
	private int level;
	private boolean isLeaf;
	private List<Attribute> children;
	private boolean isCyclic;
	private boolean useLimit;
	private boolean isCyclicLimit;
	private boolean repeating;
	private String lovName;
	private String serviceTypeName;
	private Boolean visible;
	private Boolean serviceFee; 
	private String cycleCalcStartDate;
	private String cycleCalcDateType;
	private String postMethod;
	private String counterAlgorithm;
	private boolean isLengthTypeMandatory;
	private String moduleCode;
	private String limitUsage;
	private String statusReason;

	@Override
	public Object getModelId() {
		return getId() + "_" + getServiceTypeId();
	}

	@Override
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	@Override
	public Long getParentId() {
		return parentId;
	}
	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public Integer getServiceTypeId() {
		return serviceTypeId;
	}
	public void setServiceTypeId(Integer serviceTypeId) {
		this.serviceTypeId = serviceTypeId;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getDataType() {
		return dataType;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public Short getLovId() {
		return lovId;
	}
	public void setLovId(Short lovId) {
		this.lovId = lovId;
	}

	public Short getDisplayOrder() {
		return displayOrder;
	}
	public void setDisplayOrder(Short displayOrder) {
		this.displayOrder = displayOrder;
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

	public String getDefinitionLevel() {
		return definitionLevel;
	}
	public void setDefinitionLevel(String definitionLevel) {
		this.definitionLevel = definitionLevel;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
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

	public List<Attribute> getChildren() {
		return children;
	}
	public void setChildren(List<Attribute> children) {
		this.children = children;
	}
	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public boolean isCyclic() {
		return isCyclic;
	}
	public void setCyclic(boolean isCyclic) {
		this.isCyclic = isCyclic;
	}

	public boolean isUseLimit() {
		return useLimit;
	}
	public void setUseLimit(boolean useLimit) {
		this.useLimit = useLimit;
	}

	public boolean isCyclicLimit() {
		return isCyclicLimit;
	}
	public void setCyclicLimit(boolean isCyclicLimit) {
		this.isCyclicLimit = isCyclicLimit;
	}

	public String getLovName() {
		return lovName;
	}
	public void setLovName(String lovName) {
		this.lovName = lovName;
	}

	public String getServiceTypeName() {
		return serviceTypeName;
	}
	public void setServiceTypeName(String serviceTypeName) {
		this.serviceTypeName = serviceTypeName;
	}

	public Boolean getVisible() {
		return visible;
	}
	public void setVisible(Boolean visible) {
		this.visible = visible;
	}

	public String getAttributeName() {
		return (label != null && label.length() > 0) ? label : name;
	}
	public String getAttributeType() {
		if (entityType != null) {
			if (EntityNames.ATTRIBUTE_GROUP.equals(entityType) ||
					EntityNames.SERVICE_TYPE.equals(entityType)) {
				return "";
			}
			return entityType;
		} else {
			return dataType;
		}
	}

	public boolean isServiceType() {
		return EntityNames.SERVICE_TYPE.equals(entityType);
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((displayOrder == null) ? 0 : displayOrder.hashCode());
		result = prime * result + ((entityType == null) ? 0 : entityType.hashCode());
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((label == null) ? 0 : label.hashCode());
		result = prime * result + level;
		result = prime * result + ((name == null) ? 0 : name.hashCode());
		result = prime * result + ((objectType == null) ? 0 : objectType.hashCode());
		result = prime * result + ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + ((serviceTypeId == null) ? 0 : serviceTypeId.hashCode());
		return result;
	}
	@Override
	public boolean equals(Object obj) {
		if (this == obj) {
			return true;
		}
		if (obj == null) {
			return false;
		}
		if (getClass() != obj.getClass()) {
			return false;
		}
		Attribute other = (Attribute) obj;
		if (displayOrder == null) {
			if (other.displayOrder != null) {
				return false;
			}
		} else if (!displayOrder.equals(other.displayOrder)) {
			return false;
		}
		if (entityType == null) {
			if (other.entityType != null) {
				return false;
			}
		} else if (!entityType.equals(other.entityType)) {
			return false;
		}
		if (id == null) {
			if (other.id != null) {
				return false;
			}
		} else if (!id.equals(other.id)) {
			return false;
		}
		if (label == null) {
			if (other.label != null) {
				return false;
			}
		} else if (!label.equals(other.label)) {
			return false;
		}
		if (level != other.level) {
			return false;
		}
		if (name == null) {
			if (other.name != null) {
				return false;
			}
		} else if (!name.equals(other.name)) {
			return false;
		}
		if (objectType == null) {
			if (other.objectType != null) {
				return false;
			}
		} else if (!objectType.equals(other.objectType)) {
			return false;
		}
		if (parentId == null) {
			if (other.parentId != null) {
				return false;
			}
		} else if (!parentId.equals(other.parentId)) {
			return false;
		}
		if (serviceTypeId == null) {
			if (other.serviceTypeId != null) {
				return false;
			}
		} else if (!serviceTypeId.equals(other.serviceTypeId)) {
			return false;
		}
		return true;
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		Attribute clone = (Attribute) super.clone();
		
		//make deep copy of an array
		if (this.children != null) {
			List<Attribute> children = new ArrayList<Attribute>(this.children.size());
			for (Attribute child: this.children) {
				children.add(child);
			}
			clone.setChildren(children);
		}
		
		return clone;
	}

	public boolean isGroup() {
		return EntityNames.ATTRIBUTE_GROUP.equals(dataType);
	}

	public Boolean getServiceFee() {
		return serviceFee;
	}
	public void setServiceFee(Boolean serviceFee) {
		this.serviceFee = serviceFee;
	}

	public String getCycleCalcStartDate() {
		return cycleCalcStartDate;
	}
	public void setCycleCalcStartDate(String cycleCalcStartDate) {
		this.cycleCalcStartDate = cycleCalcStartDate;
	}

	public String getCycleCalcDateType() {
		return cycleCalcDateType;
	}
	public void setCycleCalcDateType(String cycleCalcDateType) {
		this.cycleCalcDateType = cycleCalcDateType;
	}

	public String getPostMethod() {
		return postMethod;
	}
	public void setPostMethod(String postMethod) {
		this.postMethod = postMethod;
	}

	public String getCounterAlgorithm() {
		return counterAlgorithm;
	}
	public void setCounterAlgorithm(String counterAlgorithm) {
		this.counterAlgorithm = counterAlgorithm;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("serviceTypeId", getServiceTypeId());
		result.put("parentId", getParentId());
		result.put("name", getName());
		result.put("dataType", getDataType());
		result.put("lovId", getLovId());
		result.put("displayOrder", getDisplayOrder());
		result.put("lang", getLang());
		result.put("label", getLabel());
		result.put("description", getDescription());
		result.put("entityType", getEntityType());
		result.put("objectType", getObjectType());
		result.put("definitionLevel", getDefinitionLevel());
		result.put("isCyclic", isCyclic());
		result.put("useLimit", isUseLimit());
		result.put("isCyclicLimit", isCyclicLimit());
		result.put("visible", getVisible());
		result.put("serviceFee", getServiceFee());
		result.put("postMethod", getPostMethod());
		result.put("counterAlgorithm", getCounterAlgorithm());
		return result;
	}

	public boolean isRepeating() {
		return repeating;
	}
	public void setRepeating(boolean repeating) {
		this.repeating = repeating;
	}

	public boolean isLengthTypeMandatory() {
		return isLengthTypeMandatory;
	}
	public void setLengthTypeMandatory(boolean isLengthTypeMandatory) {
		this.isLengthTypeMandatory = isLengthTypeMandatory;
	}

	public String getModuleCode() {
		return moduleCode;
	}
	public void setModuleCode(String moduleCode) {
		this.moduleCode = moduleCode;
	}

    public String getLimitUsage() {
        return limitUsage;
    }

    public void setLimitUsage(String limitUsage) {
        this.limitUsage = limitUsage;
    }

	public String getStatusReason() {
		return statusReason;
	}
	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}
}

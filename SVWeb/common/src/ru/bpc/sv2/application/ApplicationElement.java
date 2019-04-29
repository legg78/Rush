package ru.bpc.sv2.application;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;
import ru.bpc.sv2.utils.AppStructureUtils;

import javax.swing.text.NumberFormatter;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.*;

public class ApplicationElement extends Parameter implements ModelIdentifiable,
															 TreeIdentifiable<ApplicationElement>,
															 Serializable,
															 Comparable<ApplicationElement>,
															 Cloneable {
	private static final long serialVersionUID = -4991241886310869900L;
	private Long appId;
	private Long id;
	private String shortDesc;
	private String type;
	private String defaultValue;
	private Integer minLength;
	private Integer maxLength;
	private String minValue;
	private String maxValue;
	private String incomingFormat;
	private String displayFormat;
	private String name;
	private Long parentId;
	private String appType;
	private Integer innerId;
	private Integer count;
	private Integer orderNum;
	private Integer maxCount;
	private Integer minCount;
	private Boolean content;
	private Integer copyCount;
	private Integer stId;
	private Long dataId;
	private Long parentDataId;
	private boolean valid;
	private boolean required;
	private boolean validRequired;
	private ApplicationElement parent;
	private ApplicationElement contentBlock;
	private Boolean visible;
	private Boolean updatable;
	private Boolean insertable;
	private Boolean dependence;
	private Boolean dependent;
	private Boolean info;
	private String valueText;
	private boolean auto;
	private String lang;
	private boolean multiLang;
	private String valueLang;
	private String blockName;

	private String path;

	private int maxCopy;
	private String entityType;
	private boolean isFake;
	private boolean isWizard;
	
	private Integer flowFilterId;
	private Integer flowFilterSeqnum;
	private int level;
	private boolean isLeaf;
	private List<ApplicationElement> children;
	private String editForm;
	private Boolean effectsOnDesc;
	private String additionalDesc;
	private String errorDetails;
	private String valueMask;
	private boolean filled;

	private int curMode = EDIT_MODE;
	public static final int VIEW_MODE = 1;
	public static final int EDIT_MODE = 2;
	public static final int NEW_MODE = 4;

	public ApplicationElement() {
		children = new ArrayList<ApplicationElement>();
		innerId = 1;
		content = false;
		copyCount = 0;
		orderNum = 0;
		valid = true;
		validRequired = true;

	}

	public Integer getOrderNum() {
		return orderNum;
	}
	public void setOrderNum(Integer orderNum) {
		this.orderNum = orderNum;
	}

	public Integer getInnerId() {
		return innerId;
	}
	public void setInnerId(Integer innerId) {
		this.innerId = innerId;
	}

	public Integer getCount() {
		return count;
	}
	public void setCount(Integer count) {
		this.count = count;
	}

	public Long getParentId() {
		return parentId;
	}
	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getAppType() {
		return appType;
	}
	public void setAppType(String appType) {
		this.appType = appType;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public List<ApplicationElement> getChildren() {
		return children;
	}
	public void setChildren(List<ApplicationElement> children) {
		this.children = children;
	}
	public void addChildren(ApplicationElement child) {
	    this.children.add(child);
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}

	public String getDefaultValue() {
		return defaultValue;
	}
	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public Integer getMinLength() {
		return minLength;
	}
	public void setMinLength(Integer minLength) {
		this.minLength = minLength;
	}

	public String getMinValue() {
		return minValue;
	}
	public void setMinValue(String minValue) {
		this.minValue = minValue;
	}

	public String getMaxValue() {
		return maxValue;
	}
	public void setMaxValue(String maxValue) {
		this.maxValue = maxValue;
	}

	public String getIncomingFormat() {
		return incomingFormat;
	}
	public void setIncomingFormat(String incomingFormat) {
		this.incomingFormat = incomingFormat;
	}

	public String getDisplayFormat() {
		return displayFormat;
	}
	public void setDisplayFormat(String displayFormat) {
		this.displayFormat = displayFormat;
	}

	public Object getModelId() {
		return getId() + "_" + getDataId();
	}

	@Override
	public boolean equals(Object obj) {
		if (obj instanceof ApplicationElement) {
			return (((getName().equals(((ApplicationElement) obj).getName()))) && ((getInnerId() == null && ((ApplicationElement) obj)
					.getInnerId() == null) || (getInnerId() != null && getInnerId().equals(
					((ApplicationElement) obj).getInnerId()))));
		}
		return false;
	}

	public void removeChild(String name, int innerId) {
		ApplicationElement element = new ApplicationElement();
		element.setName(name);
		element.setInnerId(innerId);
		this.getChildren().remove(element);
	}

	public void removeLastChild(String name) {
		int innerId = 1;
		if (getChildByName(name, 0) != null) {
			innerId = getChildByName(name, 0).getMaxCopy();
		}
		removeChild(name, innerId);
	}

	public void addValue(String name, Object value) {
		if (StringUtils.isNotBlank(name) && value != null) {
			ApplicationElement element = this.getChildByName(name);
			if (value instanceof String) {
				element.setValueV((String)value);
			} else if (value instanceof Date) {
				element.setValueD((Date)value);
			} else if (value instanceof Integer) {
				element.setValueN((Integer)value);
			} else if (value instanceof Long) {
				element.setValueN((Long)value);
			} else if (value instanceof BigDecimal) {
				element.setValueN((BigDecimal)value);
			}
		}
	}

	public ApplicationElement getChildByName(String name) {
		int innerId = 1;
		if (getChildByName(name, 0) != null) {
			innerId = getChildByName(name, 0).getMaxCopy();
		}
		ApplicationElement element = getChildByName(name, innerId);
		if (element == null) {
			element = getChildByName(name, 0);
		}
		return element;
	}

	public ApplicationElement getChildByName(String name, Integer innerId) {
		ApplicationElement el = new ApplicationElement();
		el.setName(name);
		el.setInnerId(innerId);

		int index = this.getChildren().indexOf(el);
		if (index < 0) {
			return null;
		} else {
			return this.getChildren().get(index);
		}
	}

	public List<ApplicationElement> getChildrenByName(String name) {
		if (name == null) {
			return new ArrayList<ApplicationElement>(0);
		}
		List<ApplicationElement> childrenByName = new ArrayList<ApplicationElement>();
		for (ApplicationElement el : getChildren()) {
			if (name.equals(el.getName()) && el.getInnerId() != null && el.getInnerId() > 0) {
				childrenByName.add(el);
			}
		}
		return childrenByName;
	}

	public void clone(ApplicationElement clone) {
		if (clone == null) {
			clone = new ApplicationElement();
		}

		clone.setAppType(appType);
		clone.setDataType(getDataType());
		clone.setDefaultValue(defaultValue);
		clone.setDisplayFormat(displayFormat);
		clone.setId(id);
		clone.setIncomingFormat(incomingFormat);
		clone.setLovId(getLovId());
		clone.setLov(getLov());
		clone.setMaxLength(maxLength);
		clone.setMaxValue(maxValue);
		clone.setMinLength(minLength);
		clone.setMinValue(minValue);
		clone.setName(name);
		clone.setParentId(parentId);
		clone.setType(type);
		clone.setValue(getValue());
		clone.setValueN(getValueN());
		clone.setValueV(getValueV());
		clone.setValueD(getValueD());
		clone.setLovValue(getLovValue());
		clone.setMultiLang(multiLang);
		clone.setValueLang(valueLang);

		clone.setChildren(children);
		clone.setInnerId(innerId);
		clone.setOrderNum(orderNum);
		clone.setMaxCount(maxCount);
		clone.setMaxCopy(maxCopy);
		clone.setMinCount(minCount);
		clone.setCopyCount(copyCount);
		clone.setStId(stId);
		clone.setParentDataId(parentDataId);
		clone.setDataId(dataId);
		clone.setVisible(visible);
		clone.setUpdatable(updatable);
		clone.setInsertable(insertable);
		clone.setDependence(dependence);
		clone.setDependent(dependent);
		clone.setParent(parent);
		clone.setShortDesc(shortDesc);
		clone.setRequired(required);
		clone.setPath(path);
		clone.setEntityType(entityType);
		clone.setFake(isFake);
		clone.setEditForm(editForm);
		clone.setEffectsOnDesc(effectsOnDesc);
		clone.setMask(valueMask);
	}

	public Integer getMaxLength() {
		return maxLength;
	}
	public void setMaxLength(Integer maxLength) {
		this.maxLength = maxLength;
	}

	/**
	 * Get the upper bound of copies' count. This property has sense only for Content block. 
	 */
	public Integer getMaxCount() {
		return maxCount;
	}
	/**
	 * Set the upper bound of copies' count. This property has sense only for Content block. 
	 */
	public void setMaxCount(Integer maxCount) {
		this.maxCount = maxCount;
	}
	
	/**
	 * Get the lower bound of copies' count. This property has sense only for Content block. 
	 */
	public Integer getMinCount() {
		return minCount;
	}
	/**
	 * Set the lower bound of copies' count. This property has sense only for Content block.
	 */
	public void setMinCount(Integer minCount) {
		this.minCount = minCount;
	}

	/**
	 * @return Return boolean value that signals either the element is content element or not. 
	 * If content=true an element is 'content/fake' element. Content element always have innerId=0, so
	 * this property just duplicate innerId purpose
	 */
	public Boolean getContent() {
		return content;
	}
	/**
	 * @param content - boolean value that signals either the element is content element or not. 
	 * If content=true an element is 'content/fake' element. Content element always have innerId=0, so
	 * this property just duplicate innerId purpose
	 */
	public void setContent(Boolean content) {
		this.content = content;
	}

	/**
	 * Get the current count of copies of this block. This property has sense only for Content block. 
	 */
	public Integer getCopyCount() {
		return copyCount;
	}
	/**
	 * Set the current count of copies of this block. This property has sense only for Content block. 
	 */
	public void setCopyCount(Integer copyCount) {
		this.copyCount = copyCount;
	}

	public Integer getStId() {
		return stId;
	}
	public void setStId(Integer stId) {
		this.stId = stId;
	}

	public int compareTo(ApplicationElement el) {
		if(this.orderNum == null && el.getOrderNum() == null)
			return 0;
		if(this.orderNum == null)
			return -1;
		if(el.getOrderNum() == null)
			return 1;
		if (this.orderNum < el.getOrderNum())
			return -1;
		else if (this.orderNum > el.getOrderNum())
			return 1;
		else {
			if(this.innerId == null && el.getInnerId() == null)
				return 0;
			if (el.getInnerId() == null)
				return 1;
			if (this.innerId == null)
				return -1;
			return (this.innerId - el.getInnerId());
		}
	}

	public Long getDataId() {
		if (dataId == null)
			dataId = new Long(0);
		return dataId;
	}
	public void setDataId(Long dataId) {
		this.dataId = dataId;
	}

	public Long getParentDataId() {
		return parentDataId;
	}
	public void setParentDataId(Long parentDataId) {
		this.parentDataId = parentDataId;
	}

	public void merge(ApplicationElement el) {
		// el.setAppType(appType);
		// el.setDataType(dataType);
		// // el.setDefaultValue(defaultValue);
		// el.setDescId(descId);
		// el.setDisplayFormat(displayFormat);
		// el.setId(id);
		// el.setIncomingFormat(incomingFormat);
		// el.setLovId(lovId);
		// el.setMaxLength(maxLength);
		// el.setMaxValue(maxValue);
		// el.setMinLength(minLength);
		// el.setMinValue(minValue);
		// el.setName(name);
		// el.setParentId(parentId);
		// el.setType(type);
		el.setValue(getValue());
		el.setValueD(getValueD());
		el.setValueN(getValueN());
		el.setValueV(getValueV());
		el.setMask(valueMask);
		el.setValueLang(valueLang);
		// el.setLov(lov);
		/*
		 * el.setChilds(childs); el.setInnerId(innerId); el.setOrderNum(orderNum);
		 * el.setMaxCount(maxCount); el.setMinCount(minCount); el.setCopyCount(copyCount);
		 * el.setParent(parent); el.setStId(stId);
		 */

		el.setParentDataId(parentDataId);
		el.setDataId(dataId);

	}

	/**
	 * Nonrecursive validation
	 * @deprecated Saved only for using in ApplicationBean::validate(). Use new validate() method
	 */
	@Deprecated
	public boolean validateB() {
		valid = true;
		if (visible == null || Boolean.FALSE.equals(visible)) {
			return valid;
		}

		if (this.getDataType() == null || this.content) {
			return valid;
		}

		// if (value == null && minCount == 0)
		// {
		// valid = true;
		// return valid;
		// }
		//
		// if (value == null){
		// if (this.dataType.equals(DataTypes.CHAR))
		// valueV="";
		// }

		if (isChar()) {

			int length = 0;
			if (getValueV() != null) {
				length = getValueV().length();
			}

			if (!required && length == 0)
				return true;

			if (minLength == null || minLength == 0) {
				// nothing to do
			} else {
				if (length < minLength)
					valid = false;
			}

			if (maxLength == null || maxLength == 0) {
				// nothing to do
			} else {
				if (length > maxLength)
					valid = false;
			}
		}
		NumberFormatter nf = new NumberFormatter();
		nf.setValueClass(Integer.class);

		if (isNumber()) {
			
			if (getValueN() == null && !isRequired()){
				return valid;
			}
			if (minValue != null && !minValue.equals("")) {
				BigDecimal minV = new BigDecimal(minValue);
				if (minV != null) {
					if (getValueN() == null || getValueN().compareTo(minV) == -1)
						valid = false;
				}
			}
			if (maxValue != null && !maxValue.equals("")) {
				BigDecimal maxV = new BigDecimal(maxValue);
				if (maxV != null) {
					if (getValueN() == null || getValueN().compareTo(maxV) == 1)
						valid = false;
				}
			}
		}
		if (!valid)
			System.out.println(this.getName() + " is not valid");
		return valid;
	}
	/**
	 * Recursive validation of the element and its children. 
	 * @return
	 */
	public boolean validate(){
		valid = true;
		if (visible == null || Boolean.FALSE.equals(visible)) {
			return valid = true;
		}
		if (ApplicationConstants.ELEMENT_TYPE_SIMPLE.equals(type)){
			if (required){
				boolean empty = (isNumber() && getValueN() == null)
						|| (isDate() && getValueD() == null)
						|| (isChar() && ((getValueV() == null)
								|| (getValueV() != null && getValueV().trim().isEmpty())));
				if (empty){
					return valid = false;
				}
			}			
			if (isChar() && getValueV() != null && minLength != null && maxLength != null) {
				int length = getValueV().length();
				if (length < minLength || length > maxLength){
					valid = false;
				}
			} else if (isNumber() && getValueN() != null && minValue != null && maxValue != null){
				NumberFormatter nf = new NumberFormatter();
				nf.setValueClass(Integer.class);
				BigDecimal minV = new BigDecimal(minValue);
				BigDecimal maxV = new BigDecimal(maxValue);
				if (getValueN().compareTo(maxV) == 1 || getValueN().compareTo(minV) == -1){
					valid = false;
				}
			}
		} else {			
			if (!children.isEmpty() && innerId != 0){
				for (ApplicationElement child : children){
					valid &= child.validate();
				}
			}
		}
		return valid;
	}
	
	public boolean isValid() {
		return valid;
	}
	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public ApplicationElement getParent() {
		return parent;
	}
	public void setParent(ApplicationElement parent) {
		this.parent = parent;
	}

	public String getShortDesc() {
		return shortDesc;
	}
	public void setShortDesc(String shortDesc) {
		this.shortDesc = shortDesc;
	}

	public Boolean getVisible() {
		return visible;
	}
	public void setVisible(Boolean visible) {
		this.visible = visible;
	}

	public Boolean getUpdatable() {
		return updatable;
	}
	public void setUpdatable(Boolean updatable) {
		this.updatable = updatable;
	}

	public Boolean getInfo() {
		return info;
	}
	public void setInfo(Boolean info) {
		this.info = info;
	}

	public Long getAppId() {
		return appId;
	}
	public void setAppId(Long appId) {
		this.appId = appId;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	/**
	 * @return Content block of the element. 
	 * @see getContent(), setContent()
	 */
	public ApplicationElement getContentBlock() {
		return contentBlock;
	}
	/**
	 * @param contentBlock - Content block of the element
	 * @see getContent(), setContent()
	 */
	public void setContentBlock(ApplicationElement contentBlock) {
		this.contentBlock = contentBlock;
	}

	public boolean isAuto() {
		return auto;
	}
	public void setAuto(boolean auto) {
		this.auto = auto;
	}
	
	/**
	 * Get the maximum value of innerId among the values of the copies of this element. 
	 * This property has sense only for Content block. 
	 */
	public int getMaxCopy() {
		return maxCopy;
	}
	/**
	 * Set the maximum value of innerId among the values of the copies of this element. 
	 * This property has sense only for Content block. 
	 */
	public void setMaxCopy(int maxCopy) {
		this.maxCopy = maxCopy;
	}
	
	public Boolean getInsertable() {
		return insertable;
	}
	public void setInsertable(Boolean insertable) {
		this.insertable = insertable;
	}

	/**
	 * Returns <code>true</code> if this element has an influence 
	 * to any other object in the application structure
	 */
	public Boolean getDependence() {
		return dependence;
	}
	public void setDependence(Boolean dependence) {
		this.dependence = dependence;
	}

	public Boolean getDeletable() {
		if (parent != null && !parent.getUpdatable()) {
			//If parent is not updatable, than we can't delete it's child
			return false;
		} else if (updatable == null || !updatable) {
			//If element is not updatable, than we can't delete it
			return false;
		} else if (contentBlock != null && contentBlock.getCopyCount() != null) {
			if (contentBlock.getCopyCount().compareTo(contentBlock.getMinCount()) > 0) {
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}

	public String getUniqueId() {
		return getPath() + getInnerId();
	}

	public boolean isMultiLang() {
		return multiLang;
	}
	public void setMultiLang(boolean multiLang) {
		this.multiLang = multiLang;
	}

	public String getValueLang() {
		return valueLang;
	}
	public void setValueLang(String valueLang) {
		this.valueLang = valueLang;
	}

	public Boolean getDependent() {
		return dependent;
	}
	public void setDependent(Boolean dependent) {
		this.dependent = dependent;
	}

	public boolean isRequired() {
		return required;
	}
	public void setRequired(boolean required) {
		this.required = required;
	}

	public boolean isValidRequired() {
		return validRequired;
	}
	public void setValidRequired(boolean validRequired) {
		this.validRequired = validRequired;
	}

	public String getValueText() {
		boolean found = false;
		if (getValue() != null && getLov() != null) {
			for (int i = 0; i < getLov().length; i++) {
				if (getLov()[i].getValue() == null) {
					continue;
				}
				if (isChar()) {
					if (getLov()[i].getValue().toString().equals(getValueV())) {
						valueText = getLov()[i].getLabel();
						found = true;
						break;
					}
				} else if (isNumber()) {
					if (new BigDecimal((String) getLov()[i].getValue()).equals(getValueN())) {
						valueText = getLov()[i].getLabel();
						found = true;
						break;
					}
				} else if (isDate()) {
					if (getValueD().compareTo((Date)getLov()[i].getValue()) == 0) {
						valueText = getLov()[i].getLabel();
						found = true;
						break;
					}
				}
			}
			if (!found) {
				if (valueMask != null && !valueMask.isEmpty()) {
					valueText = valueMask;
				} else {
					valueText = null;
					valueV = null;
				}
				valueN = null;
				valueD = null;
			}
		}

		return valueText;
	}
	public void setValueText(String valueText) {
		this.valueText = valueText;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		result = prime * result + ((parentId == null) ? 0 : parentId.hashCode());
		result = prime * result + innerId;
		result = prime * result + ((stId == null) ? 0 : stId);
		result = prime * result + (path + innerId).hashCode();
		return result;
	}

	public String getPath() {
		return path;
	}
	public void setPath(String path) {
		this.path = path;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public boolean isFake() {
		return isFake;
	}
	public void setFake(boolean isFake) {
		this.isFake = isFake;
	}

	public boolean isComplex() {
		return ApplicationConstants.ELEMENT_TYPE_COMPLEX.equals(type);
	}
	public boolean isSimple() {
		return ApplicationConstants.ELEMENT_TYPE_SIMPLE.equals(type);
	}

	public String getBlockName() {
		if (blockName != null && blockName.length() > 0){
			return blockName;
		}
		if (parent != null && parent.getName() != null && parent.getName().equals(this.name)) {
			String name = parent.getBlockName();
			return name + "_" + getInnerId();
		}
		
		if (getValueV() != null){
			return(getValueV());
		}
		
		return getShortDesc() + "_" + getInnerId();
	}
	public void setBlockName(String blockName){
		this.blockName = blockName;
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

	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public boolean isHasComplexChildren() {
		boolean hasComplexChildred = false;
		if (children == null || children.size() == 0) {
			return false;
		}
		for (ApplicationElement el : children) {
			if (el.isComplex() && el.getVisible()) {
				hasComplexChildred = true;
				break;
			}
		}
		return hasComplexChildred;
	}

	public Integer getFlowFilterId() {
		return flowFilterId;
	}
	public void setFlowFilterId(Integer flowFilterId) {
		this.flowFilterId = flowFilterId;
	}

	public Integer getFlowFilterSeqnum() {
		return flowFilterSeqnum;
	}
	public void setFlowFilterSeqnum(Integer flowFilterSeqnum) {
		this.flowFilterSeqnum = flowFilterSeqnum;
	}

	public String getEditForm() {
		return editForm;
	}
	public void setEditForm(String editForm) {
		this.editForm = editForm;
	}

	public boolean isWizard() {
		return isWizard;
	}
	public void setWizard(boolean isWizard) {
		this.isWizard = isWizard;
	}

	@Override
	public ApplicationElement clone() throws CloneNotSupportedException {
		ApplicationElement clone = (ApplicationElement) super.clone();

		/*if (parent != null) {
			clone.setParent((ApplicationElement) parent.clone());
		}
		if (contentBlock != null) {
			clone.setContentBlock((ApplicationElement) contentBlock.clone());
		}*/

		// make deep copy of an array
		if (this.children != null) {
			List<ApplicationElement> children = new ArrayList<ApplicationElement>(this.children
					.size());
			for (ApplicationElement child : this.children) {
				ApplicationElement childClone = (ApplicationElement) child.clone();
				childClone.setParent(clone);
				children.add(childClone);
			}
			clone.setChildren(children);
		}

		return clone;
	}

	public void apply(ApplicationElement destination) {
		if (destination == null)
			destination = new ApplicationElement();

		destination.setLovId(getLovId());
		destination.setLov(getLov());
		destination.setValue(getValueN());
		destination.setValueN(getValueN());
		destination.setValueV(getValueV());
		destination.setValueD(getValueD());
		destination.setLovValue(getLovValue());
		destination.setValueLang(valueLang);
		destination.setInnerId(innerId);
		destination.setMaxCopy(maxCopy);
		destination.setMinCount(minCount);
		destination.setCopyCount(copyCount);
		destination.setDataId(dataId);
		destination.setVisible(visible);
		destination.setUpdatable(updatable);
		destination.setInsertable(insertable);
		destination.setRequired(required);
		destination.setPath(path);
		destination.setAdditionalDesc(additionalDesc);
		destination.setMask(valueMask);

		for (ApplicationElement el : getChildren()) {
			ApplicationElement destChild = null;
			Integer inner = el.getInnerId();
			if (inner >= 0) {
				destChild = destination.getChildByName(el.getName(), el.getInnerId());
			} else {
				// inner is now < 0
				// this means that a block was deleted in custom form
				// first look through the nodes that are not deleted (innerId > 0)
				destChild = destination.getChildByName(el.getName(), inner * (-1));
				if (destChild == null) {
					// if not found in existing blocks, look through deleted (innerId < 0)
					destChild = destination.getChildByName(el.getName(), inner);
				}
			}
			if (destChild == null) {
				continue;
			}
			el.apply(destChild);
		}
	}

	public boolean isPossibleToAdd() {
		boolean possibleToAdd = getContent() &&
				//(getInsertable() == null || getInsertable().equals(Boolean.TRUE)) &&
				//getCopyCount().compareTo(getMaxCount()) < 0 &&
				(getVisible() == null || getVisible().equals(Boolean.TRUE));
		return possibleToAdd;
	}
	public boolean isPossibleToInsert(){
		boolean possibleToInser = getContent() &&
				(getInsertable() == null || getInsertable().equals(Boolean.TRUE)) &&
				//getCopyCount().compareTo(getMaxCount()) < 0 &&
				(getVisible() == null || getVisible().equals(Boolean.TRUE));
		return possibleToInser;
	}

	public boolean isEffectsOnDesc() {
		return effectsOnDesc == null ? false : effectsOnDesc.booleanValue();
	}
	public void setEffectsOnDesc(Boolean effectsOnDesc) {
		this.effectsOnDesc = effectsOnDesc;
	}

	public String getAdditionalDesc() {
		return additionalDesc;
	}
	public void setAdditionalDesc(String additionalDesc) {
		this.additionalDesc = additionalDesc;
	}

	public String getErrorDetails() {
		return errorDetails;
	}
	public void setErrorDetails(String errorDetails) {
		this.errorDetails = errorDetails;
	}
	
	@Override
	public String toString(){
		String result = String.format("[name: %s, value: %s, innerId: %d, path: %s]", name, getValue(), innerId, path);
		return result;
	}
	
	/**
	 * Returns an existing element with the name equals to the last name of 
	 * the passed <code>elementNames</code> array. Firstly the method search an element 
	 * with <code>elementNames[0]</code> name in <code>parent</code> element. 
	 * Then, founded element becomes parent and operation repeats until the element with
	 * <code>elementNames[n-1]</code> (where n - length of the array) is founded.
	 * 
	 * @param elementNames - an array of element names. The last name of the array is the searching element. 
	 * @return
	 * @throws IllegalArgumentException - if the parent don't contain an element with name %elementName%
	 */	
	public ApplicationElement retrive(String... elementNames){
		return AppStructureUtils.retrive(this, elementNames);
	}
	/**
	 * Returns an element with the name equals to the last name of 
	 * the passed <code>elementNames</code> array and innerId=<code>1</code>. Firstly the method search an element 
	 * with <code>elementNames[0]</code> name in <code>parent</code> element. 
	 * Then, founded element becomes parent and operation repeats until the element with
	 * <code>elementNames[n-1]</code> (where n - length of the array) is founded. In opposite 
	 * to <code>retrive</code> method, <code>tryRetrive</code> don't throw an exception.
	 * 
	 * @param elementNames - an array of element names. The last name of the array is the searching element. 
	 */	
	public ApplicationElement tryRetrive(String... elementNames){
		return AppStructureUtils.tryRetrive(this, elementNames);
	}
	/**
	 * Returns an element with the name equals to the last name of 
	 * the passed <code>elementNames</code> array and innerId=<code>innerId</code>. Firstly the method search an element 
	 * with <code>elementNames[0]</code> name in <code>parent</code> element. 
	 * Then, founded element becomes parent and operation repeats until the element with
	 * <code>elementNames[n-1]</code> (where n - length of the array) is founded. In opposite 
	 * to <code>retrive</code> method, <code>tryRetrive</code> don't throw an exception.
	 * 
	 * @param elementNames - an array of element names. The last name of the array is the searching element. 
	 */
	public ApplicationElement tryRetrive(String elementName, int innerId){
		return AppStructureUtils.tryRetrive(this, elementName, innerId);
	}
	
	public void set(String value){
		setValueV(value);
	}
	public void set(Integer value){
		setValueN(new BigDecimal(value));
	}
	public void set(Double value){
		setValueN(new BigDecimal(value));
	}
	public void set(Long value){
		setValueN(new BigDecimal(value));
	}
	public void set(Date value){
		setValueD(value);
	}
	
	public boolean isFixValue(){
		if (getName() != null){
			return (getName().contains("FIXED"));
		}
		return false;
	}

	public String getValueMask() {
		if (updatable != null && updatable && !isViewMode()) {
			return getValueV();
		} else {
			return valueMask;
		}
	}
	public void setValueMask(String valueMask) {
		if (updatable != null && updatable) {
			setValueV(valueMask);
		}
		else {
			this.valueMask = valueMask;
		}
	}

	public void setMask(String mask) {
		this.valueMask = mask;
	}
	public String getMask() {
		return (this.valueMask);
	}
	public boolean isHasMask() {
		return !(getValueMask() == null || getValueMask().trim().length() == 0);
	}

	public int getCurMode() {
		return curMode;
	}
	public void setCurMode(int curMode) {
		this.curMode = curMode;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}
	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}
	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isFilled() {
		return filled;
	}

	public void setFilled(boolean filled) {
		this.filled = filled;
	}
}

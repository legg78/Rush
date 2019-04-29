package ru.bpc.sv2.application;

import ru.bpc.sv2.common.TreeNode;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;



public class ContractObject implements ModelIdentifiable, Serializable, Comparable<Object>, TreeNode<ContractObject>{
	private static final long serialVersionUID = -4991241886310869900L;

	private Long id;
	private Integer seqNum;
	private String number;
	private String name;
	private String mask;
	private String label;
	private Long contractId;
	private String contractNumber;
	private String customerNumber;
	private String contractType;
	private boolean isChecked;
	private boolean isCheckedOld;
	private Short minCount;
	private Short maxCount;
	private Short avalCount;
	private Short currentCount;
	private String objectId;
	private Integer productId;
	private String product;
	private String entityType;
	private Long parentId;
	private String parentNumber;
	private String currency;
	private Long schemeId;
	private Long serviceId;

	private boolean initial;
	private Integer serviceTypeId;
	private String accountType;

	private Long dataId;
	private Integer level;
	private boolean isLeaf;
	private List<ContractObject> children = new ArrayList<ContractObject>();
	private boolean disabled;
	private boolean edit;
	private Integer serviceExist;
	private Date endDate;
	private Date startDate;

	private Integer networkId;
	private String networkName;
	private Integer instId;
	private String instName;
	private Integer numberFormatId;
	private String numberFormatName;
	private String numberPrefix;
	private String productType;

	private String lang;
	private String partnerIdCode;

	public ContractObject() {
		
	}
	
	public ContractObject(String entityType, String number) {
		this.entityType = entityType;
		this.number = number;
	}
	
	public ContractObject(String entityType, String number, boolean initial) {
		this.entityType = entityType;
		this.number = number;
		this.initial = initial;
	}

	public ContractObject(String entityType, String number, String numberMask, boolean initial) {
		this(entityType, number, initial);
		this.mask = numberMask;
	}

	public Object getModelId() {
		return getId();
	}
	
	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public String getNumber() {
		return number;
	}
	public void setNumber(String number) {
		this.number = number;
	}

	public Long getContractId() {
		return contractId;
	}
	public void setContractId(Long contractId) {
		this.contractId = contractId;
	}

	public String getContractNumber() {
		return contractNumber;
	}
	public void setContractNumber(String contractNumber) {
		this.contractNumber = contractNumber;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public boolean isChecked() {
		return isChecked;
	}
	public void setChecked(boolean isChecked) {
		this.isChecked = isChecked;
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

	public Short getAvalCount() {
		return avalCount;
	}
	public void setAvalCount(Short avalCount) {
		this.avalCount = avalCount;
	}

	public Short getCurrentCount() {
		return currentCount;
	}
	public void setCurrentCount(Short currentCount) {
		this.currentCount = currentCount;
	}

	public String getObjectId() {
		return objectId;
	}
	public void setObjectId(String objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public boolean isCanEnable() {
		if (maxCount == null || currentCount == null) {
			return true;
		}
		if (!isChecked && (maxCount.shortValue() > currentCount.shortValue())) {
			return true;
		}
		return false;
	}
	public boolean isCanDisable() {
		if (minCount == null || currentCount == null) {
			return true;
		}
		if (isChecked && (minCount.shortValue() < currentCount.shortValue())) {
			return true;
		}
		return false;
	}

	public boolean isInitial() {
		return initial;
	}
	public void setInitial(boolean initial) {
		this.initial = initial;
	}

	public Integer getServiceTypeId() {
		return serviceTypeId;
	}
	public void setServiceTypeId(Integer serviceTypeId) {
		this.serviceTypeId = serviceTypeId;
	}

	public boolean isCheckedOld() {
		return isCheckedOld;
	}
	public void setCheckedOld(boolean isCheckedOld) {
		this.isCheckedOld = isCheckedOld;
	}

	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}

	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Long getDataId() {
		return dataId;
	}
	public void setDataId(Long dataId) {
		this.dataId = dataId;
	}

	public String getParentNumber() {
		return parentNumber;
	}
	public void setParentNumber(String parentNumber) {
		this.parentNumber = parentNumber;
	}

	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Long getSchemeId() {
		return schemeId;
	}
	public void setSchemeId(Long schemeId) {
		this.schemeId = schemeId;
	}

	public Long getServiceId() {
		return serviceId;
	}
	public void setServiceId(Long serviceId) {
		this.serviceId = serviceId;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public Long getParentId() {
		return parentId;
	}
	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getAccountType() {
		return accountType;
	}
	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public void setLevel(Integer level) {
		this.level = level;
	}
	public Integer getServiceExist() {
		return serviceExist;
	}

	public Integer getNetworkId() {
		return networkId;
	}
	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public String getNetworkName() {
		return networkName;
	}
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
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

	public Integer getNumberFormatId() {
		return numberFormatId;
	}
	public void setNumberFormatId(Integer numberFormatId) {
		this.numberFormatId = numberFormatId;
	}

	public String getNumberFormatName() {
		return numberFormatName;
	}
	public void setNumberFormatName(String numberFormatName) {
		this.numberFormatName = numberFormatName;
	}

	public String getNumberPrefix() {
		return numberPrefix;
	}
	public void setNumberPrefix(String numberPrefix) {
		this.numberPrefix = numberPrefix;
	}

	public String getProductType() {
		return productType;
	}
	public void setProductType(String productType) {
		this.productType = productType;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ContractObject other = (ContractObject) obj;
				//ids = null
				if (entityType != null && other.entityType != null && entityType.equals(other.entityType)) {
					if (id != null && other.id != null && id.equals(other.id)) {
						return true;
					} else if (number != null && other.number != null && number.equals(other.number)) {
						//compare number
						return true;
					} else if (dataId != null && other.dataId != null && dataId.equals(other.dataId)) {
						//if numbers are not the same, check dataId
						return true;
					} else {
						return false;
					}
				} else {
					//entity types are not the same. objects of different kinds. Can't be equal 
					return false;
				}
		
	}

	public void setLevel(int level) {
		this.level = level;
	}
	public int getLevel() {
		if (level == null) {
			return 0;
		}
		return level;
	}

	public int compareTo(Object obj) {
		if (this == obj)
			return 0;
		if (obj == null)
			return 1;
		if (getClass() != obj.getClass())
			return 0;
		ContractObject other = (ContractObject) obj;
		if (entityType != null) {
			if (entityType.equals(other.entityType)) {
				if (other.level == null) {
					return 1;
				}
				if (level == null) {
					return -1;
				}
				return level.compareTo(other.level);
			} else {
				if (other.entityType == null) {
					return 1;
				}
				return entityType.compareTo(other.entityType);
			}
		} else {
			return -1;
		}
//		return 0;
	}

	public boolean isLeaf() {
		return isLeaf;
	}
	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public List<ContractObject> getChildren() {
		return children;
	}
	public void setChildren(List<ContractObject> children) {
		this.children = children;
	}
	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}
	
	public static int addNodes(int startIndex, List<ContractObject> branches, ContractObject[] items) {
		int i;
		int level = items[startIndex].getLevel();

		for (i = startIndex; i < items.length; i++) {
			if (items[i].getLevel() != level) {
				break;
			}
			branches.add(items[i]);
			if ((i + 1) != items.length && items[i + 1].getLevel() > level) {
				items[i].setChildren(new ArrayList<ContractObject>());
				i = addNodes(i + 1, items[i].getChildren(), items);
			}
		}
		return i - 1;
	}

	public boolean isDisabled() {
		return disabled;
	}
	public void setDisabled(boolean disabled) {
		this.disabled = disabled;
	}

	public boolean isEdit() {
		return edit;
	}
	public void setEdit(boolean edit) {
		this.edit = edit;
	}
	
	@Override
	public String toString(){
		return String.format("{entityType:%s, number: %s}", entityType, getMaskedNumber());
	}

	public String getMaskedNumber() {
		if (EntityNames.CARD.equals(entityType) || mask != null) {
			return getMask();
		}
		return number;
	}
	
	public void setServiceExist(Integer serviceExist) {
		this.serviceExist = serviceExist;
	}
	public Integer getServiceExists(){
		return serviceExist;
	}

	public String getMask() {
		return mask;
	}
	public void setMask(String mask) {
		this.mask = mask;
	}

	public Date getEndDate() {
		return endDate;
	}
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Date getStartDate(){
		return startDate;
	}
	public void setStartDate( Date startDate ){
		this.startDate = startDate;
	}

	public String getProduct(){
		return product;
	}
	public void setProduct( String product ){
		this.product = product;
	}

	public String getContractType(){
		return contractType;
	}
	public void setContractType( String contractType ){
		this.contractType = contractType;
	}

	public String getPartnerIdCode(){
		return partnerIdCode;
	}
	public void setPartnerIdCode( String partnerIdCode ){
		this.partnerIdCode = partnerIdCode;
	}
}

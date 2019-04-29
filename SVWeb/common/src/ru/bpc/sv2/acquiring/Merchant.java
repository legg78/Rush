package ru.bpc.sv2.acquiring;

import java.io.Serializable;
import java.util.List;

import ru.bpc.sv2.invocation.TreeIdentifiable;

public class Merchant implements Serializable, TreeIdentifiable<Merchant> {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private String merchantNumber;
	private String merchantName;
	private String merchantType;
	private Long parentId;
	private String mcc;
	private String status;
//	private String reportType;
	private Long contractId;
	private Integer productId;
	private Integer instId;
	private Integer agentId;
	private Integer splitHash;
	private String label;
	private String description;
	private String lang;
	private int level;
	private boolean isLeaf;
	private String mccName;
	private String instName;
	private String productName;
	private String customerNumber;
	private String customerType;
	//for displaying on UI component <bm:selectCustomer>
	private String custInfo;
	private Long customerId;
	private String companyName;
	private String contractNumber;
	private Long accountId;
	private String productType;
	private Integer ferrNo;
	private String productNumber;
	private String partnerIdCode;
	private String riskIndicator;
	private String mcAssignedId;

	private String statusReason;

	private List<Merchant> children;

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

	public String getMerchantNumber() {
		return merchantNumber;
	}

	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public String getMerchantName() {
		return merchantName;
	}

	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getMerchantType() {
		return merchantType;
	}

	public void setMerchantType(String merchantType) {
		this.merchantType = merchantType;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getMcc() {
		return mcc;
	}

	public void setMcc(String mcc) {
		this.mcc = mcc;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Long getContractId() {
		return contractId;
	}

	public void setContractId(Long contractId) {
		this.contractId = contractId;
	}

	public Integer getProductId() {
		return productId;
	}

	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
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

	public String getMccName() {
		return mccName;
	}

	public void setMccName(String mccName) {
		this.mccName = mccName;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getProductName() {
		return productName;
	}

	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}

	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public String getCompanyName() {
		return companyName;
	}

	public void setCompanyName(String companyName) {
		this.companyName = companyName;
	}

	public String getContractNumber() {
		return contractNumber;
	}

	public void setContractNumber(String contractNumber) {
		this.contractNumber = contractNumber;
	}

	public List<Merchant> getChildren() {
		return children;
	}

	@Override
	public void setChildren(List<Merchant> children) {
		this.children = children;
	}

	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}
	
	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
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
		Merchant other = (Merchant) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}

	public Object getModelId() {
		return getId();
	}

	public String getProductType() {
		return productType;
	}

	public void setProductType(String productType) {
		this.productType = productType;
	}

	public Long getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public String getCustInfo() {
		return custInfo;
	}

	public void setCustInfo(String custInfo) {
		this.custInfo = custInfo;
	}

	public Integer getAgentId() {
		return agentId;
	}

	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public String getCustomerType() {
		return customerType;
	}

	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	public Integer getFerrNo() {
		return ferrNo;
	}

	public void setFerrNo(Integer ferrNo) {
		this.ferrNo = ferrNo;
	}

    public String getProductNumber() {
        return productNumber;
    }

    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }

	public String getPartnerIdCode() {
		return partnerIdCode;
	}

	public void setPartnerIdCode(String partnerIdCode) {
		this.partnerIdCode = partnerIdCode;
	}

	public String getRiskIndicator() {
		return riskIndicator;
	}

	public void setRiskIndicator(String riskIndicator) {
		this.riskIndicator = riskIndicator;
	}

    public String getMcAssignedId() {
        return mcAssignedId;
    }

    public void setMcAssignedId(String mcAssignedId) {
        this.mcAssignedId = mcAssignedId;
    }

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}
}

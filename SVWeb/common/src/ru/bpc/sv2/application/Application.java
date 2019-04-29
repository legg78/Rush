package ru.bpc.sv2.application;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class Application implements ModelIdentifiable, Serializable{
	private static final long serialVersionUID = -4991241886310869900L;
	private Long id;
	private String appType;
	private String appSubType;
	private String rejectCode;
	private Integer instId;
	private String instName;
	private Integer agentId;
	private String status;
	private String newStatus;
	private String oldStatus;
	private String oldRejectCode;
	private Integer flowId;
	private Integer stageId;
	private String flowName;
	private String extCustomerType;
	private Long extObjectId;
	private Date regDateFrom;
	private Date regDateTo;
	private Integer fileRecNum;
	private Long sessionFileId;
	private String terminalNumber;
	private String merchantNumber;
	private String accountNumber;
	private Integer productId;
	private String productName;
	private String productNumber;
	private String productFullName;
	private String productType;
	private String productStatus;
	private Integer productParentId;
	private Long contractId;
	private String contractNumber;
	private Long objectId;
	private String entityType;
	private Long customerId;
	private String customerNumber;
	private String cardNumber;
	private String customerType;
	private String contractType;
	private Integer seqNum;
	private String applNumber;
	private String comment;
	private String description;
	private Date created;
	private Date lastUpdated;
	private Date appDateFrom;
	private Date appDateTo;
	private Integer splitHash;
	private String idFilter;
	private Long operId;
	private Integer userId;
	private String userName;
	private String eventType;
	private Boolean prioritized;
	private Boolean skipProcessing;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public String getAppType() {
		return appType;
	}
	public void setAppType(String appType) {
		this.appType = appType;
	}

	public String getAppSubType() {
		return appSubType;
	}
	public void setAppSubType(String appSubType) {
		this.appSubType = appSubType;
	}

	public String getRejectCode() {
		return rejectCode;
	}
	public void setRejectCode(String rejectCode) {
		setOldRejectCode(this.rejectCode);
		this.rejectCode = rejectCode;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getAgentId() {
		return agentId;
	}
	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public Date getRegDateFrom() {
		return regDateFrom;
	}
	public void setRegDateFrom(Date regDateFrom) {
		this.regDateFrom = regDateFrom;
	}

	public Date getRegDateTo() {
		return regDateTo;
	}
	public void setRegDateTo(Date regDateTo) {
		this.regDateTo = regDateTo;
	}

	public Integer getFlowId() {
		return flowId;
	}
	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}

	public Integer getStageId() {
		return stageId;
	}
	public void setStageId(Integer stageId) {
		this.stageId = stageId;
	}

	public String getNewStatus() {
		return newStatus;
	}
	public void setNewStatus(String newStatus) {
		setOldStatus(this.newStatus);
		this.newStatus = newStatus;
	}

	public String getOldStatus() {
		return oldStatus;
	}
	public void setOldStatus(String oldStatus) {
		this.oldStatus = oldStatus;
	}

	public String getNewStatusRejectCode() {
		String result = getNewStatus();
		if (StringUtils.isNotEmpty(result) && StringUtils.isNotEmpty(getRejectCode())) {
			result += getRejectCode();
		}
		return result;
	}

	public void setNewStatusRejectCode(String value) {
		if (StringUtils.isEmpty(value)) {
			setNewStatus(value);
			setRejectCode(value);
			return;
		}

		if (value.length() > ApplicationStatuses.VALUE_LENGTH) {
			setNewStatus(value.substring(0, ApplicationStatuses.VALUE_LENGTH));
			setRejectCode(value.substring(ApplicationStatuses.VALUE_LENGTH));
		} else {
			setNewStatus(value);
			setRejectCode(null);
		}
	}

	public String getOldRejectCode() {
		return oldRejectCode;
	}
	public void setOldRejectCode(String oldRejectCode) {
		this.oldRejectCode = oldRejectCode;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Integer getFileRecNum() {
		return fileRecNum;
	}
	public void setFileRecNum(Integer fileRecNum) {
		this.fileRecNum = fileRecNum;
	}

	public Long getSessionFileId() {
		return sessionFileId;
	}
	public void setSessionFileId(Long sessionFileId) {
		this.sessionFileId = sessionFileId;
	}

	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}

	public String getProductName() {
		return productName;
	}
	public void setProductName(String productName) {
		this.productName = productName;
	}

	public String getProductFullName() {
		setProductFullName("");
		return productFullName;
	}
	public void setProductFullName(String productFullName) {
		if (productId != null && productName != null) {
			this.productFullName = productId.toString() + " - " + productName;
		} else {
			this.productFullName = "";
		}
	}

	public String getProductNumber() {
		return productNumber;
	}
	public void setProductNumber(String productNumber) {
		this.productNumber = productNumber;
	}

	public String getProductType() {
		return productType;
	}
	public void setProductType(String productType) {
		this.productType = productType;
	}

	public String getProductStatus() {
		return productStatus;
	}
	public void setProductStatus(String productStatus) {
		this.productStatus = productStatus;
	}

	public Integer getProductParentId() {
		return productParentId;
	}
	public void setProductParentId(Integer productParentId) {
		this.productParentId = productParentId;
	}

	public String getTerminalNumber() {
		return terminalNumber;
	}
	public void setTerminalNumber(String terminalNumber) {
		this.terminalNumber = terminalNumber;
	}

	public String getMerchantNumber() {
		return merchantNumber;
	}
	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public String getFlowName() {
		return flowName;
	}
	public void setFlowName(String flowName) {
		this.flowName = flowName;
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

	public Long getCustomerId() {
		return customerId;
	}
	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public String getCustomerType() {
		return customerType;
	}
	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	public String getContractType() {
		return contractType;
	}
	public void setContractType(String contractType) {
		this.contractType = contractType;
	}

	public boolean isIssuing() {
		return ApplicationConstants.TYPE_ISSUING.equals(appType) || ApplicationConstants.TYPE_ISS_PRODUCT.equals(appType);
	}
	public boolean isAcquiring() {
		return ApplicationConstants.TYPE_ACQUIRING.equals(appType) || ApplicationConstants.TYPE_ACQ_PRODUCT.equals(appType);
	}
	public boolean isProduct() {
		return ApplicationConstants.TYPE_ISS_PRODUCT.equals(appType) ||
			   ApplicationConstants.TYPE_ACQ_PRODUCT.equals(appType) ||
			   ApplicationConstants.TYPE_PRODUCT.equals(appType);
	}
	public boolean isFinancialRequest() {
		return ApplicationConstants.TYPE_FIN_REQUEST.equals(appType);
	}
	public boolean isDisputes() {
		return ApplicationConstants.TYPE_DISPUTES.equals(appType);
	}
	public boolean isPaymentOrders() {
		return ApplicationConstants.TYPE_PAYMENT_ORDERS.equals(appType);
	}
	public boolean isUserManagement() {
		return ApplicationConstants.TYPE_USER_MNG.equals(appType);
	}
	public boolean isInstitution() {
		return ApplicationConstants.TYPE_INSTITUTION.equals(appType);
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getApplNumber() {
		return applNumber;
	}
	public void setApplNumber(String applNumber) {
		this.applNumber = applNumber;
	}

	public String getComment() {
		return comment;
	}
	public void setComment(String comment) {
		this.comment = comment;
	}	

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public Date getCreated() {
		return created;
	}
	public void setCreated(Date created) {
		this.created = created;
	}

	public Date getLastUpdated() {
		return lastUpdated;
	}
	public void setLastUpdated(Date lastUpdated) {
		this.lastUpdated = lastUpdated;
	}

	public Date getAppDateFrom() {
		return appDateFrom;
	}
	public void setAppDateFrom(Date appDateFrom) {
		this.appDateFrom = appDateFrom;
	}

	public Date getAppDateTo() {
		return appDateTo;
	}
	public void setAppDateTo(Date appDateTo) {
		this.appDateTo = appDateTo;
	}

	public String getAccountNumber() {
		return accountNumber;
	}
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	public Long getObjectId() {
		return objectId;
	}
	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public String getIdFilter() {
		return idFilter;
	}
	public void setIdFilter(String idFilter) {
		this.idFilter = idFilter;
	}

	public String getExtCustomerType() {
		return extCustomerType;
	}
	public void setExtCustomerType(String extCustomerType) {
		this.extCustomerType = extCustomerType;
	}

	public Long getExtObjectId() {
		return extObjectId;
	}
	public void setExtObjectId(Long extObjectId) {
		this.extObjectId = extObjectId;
	}

	public Long getOperId() {
		return operId;
	}
	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public Integer getUserId() {
		return userId;
	}
	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public String getUserName() {
		return userName;
	}
	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getEventType() {
		return eventType;
	}
	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public Boolean getPrioritized() {
		return prioritized;
	}
	public void setPrioritized(Boolean prioritized) {
		this.prioritized = prioritized;
	}
	public void setPrioritized(String prioritized) {
		if (prioritized != null && !prioritized.isEmpty()) {
			if ("1".equalsIgnoreCase(prioritized) || "true".equalsIgnoreCase(prioritized)) {
				this.prioritized = true;
			} else {
				this.prioritized = false;
			}
		} else {
			this.prioritized = null;
		}
	}
	public void setPrioritized(Long prioritized) {
		if (prioritized != null) {
			this.prioritized = (prioritized != 0) ? true : false;
		} else {
			this.prioritized = null;
		}
	}
	public void setPrioritized(Integer prioritized) {
		setPrioritized(prioritized.longValue());
	}

	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("appType", this.getAppType());
		result.put("rejectCode", this.getRejectCode());
		result.put("instId", this.getInstId());
		result.put("instName", this.getInstName());
		result.put("agentId", this.getAgentId());
		result.put("status", this.getStatus());
		result.put("newStatus", this.getNewStatus());
		result.put("flowId", this.getFlowId());
		result.put("stageId", this.getStageId());
		result.put("flowName", this.getFlowName());
		result.put("extCustomerType", this.getExtCustomerType());
		result.put("extObjectId", this.getExtObjectId());
		result.put("regDateFrom", this.getRegDateFrom());
		result.put("regDateTo", this.getRegDateTo());
		result.put("fileRecNum", this.getFileRecNum());
		result.put("sessionFileId", this.getSessionFileId());
		result.put("terminalNumber", this.getTerminalNumber());
		result.put("merchantNumber", this.getMerchantNumber());
		result.put("accountNumber", this.getAccountNumber());
		result.put("productId", this.getProductId());
		result.put("contractId", this.getContractId());
		result.put("contractNumber", this.getContractNumber());
		result.put("objectId", this.getObjectId());
		result.put("entityType", this.getEntityType());
		result.put("customerId", this.getCustomerId());
		result.put("customerNumber", this.getCustomerNumber());
		result.put("cardNumber", this.getCardNumber());
		result.put("customerType", this.getCustomerType());
		result.put("contractType", this.getContractType());
		result.put("applNumber", this.getApplNumber());
		result.put("comment", this.getComment());
		result.put("description", this.getDescription());
		result.put("created", this.getCreated());
		result.put("lastUpdated", this.getLastUpdated());
		result.put("appDateFrom", this.getAppDateFrom());
		result.put("appDateTo", this.getAppDateTo());
		result.put("userId", this.getUserId());
		result.put("eventType", this.getEventType());
		result.put("applPrioritized", this.getPrioritized());
		return result;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

    public Boolean getSkipProcessing() {
        return skipProcessing;
    }

    public void setSkipProcessing(Boolean skipProcessing) {
        this.skipProcessing = skipProcessing;
    }


    public ApplicationFlowTransition createTransition(Map<String, String> descriptions) {
	    return ApplicationFlowTransition.createByStatusReject(getStatus(), getRejectCode(), descriptions);
    }
}


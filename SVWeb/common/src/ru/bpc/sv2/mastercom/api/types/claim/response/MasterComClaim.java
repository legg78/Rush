package ru.bpc.sv2.mastercom.api.types.claim.response;

import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.io.Serializable;
import java.util.Date;

public class MasterComClaim implements MasterComResponse, Serializable {
	private static final long serialVersionUID = -1;

	private String acquirerId;
	private String acquirerRefNum;
	private String primaryAccountNum;
	private String claimId;
	private String claimType;
	private String claimValue;
	private Date clearingDueDate;
	private String clearingNetwork;
	private Date createDate;
	private Date dueDate;
	private String transactionId;
	private Boolean isAccurate;
	private Boolean isAcquirer;
	private Boolean isIssuer;
	private Boolean isOpen;
	private String issuerId;
	private String lastModifiedBy;
	private Date lastModifiedDate;
	private String merchantId;
	private String progressState;
	private String queueName;

	public String getAcquirerId() {
		return acquirerId;
	}

	public void setAcquirerId(String acquirerId) {
		this.acquirerId = acquirerId;
	}

	public String getAcquirerRefNum() {
		return acquirerRefNum;
	}

	public void setAcquirerRefNum(String acquirerRefNum) {
		this.acquirerRefNum = acquirerRefNum;
	}

	public String getPrimaryAccountNum() {
		return primaryAccountNum;
	}

	public void setPrimaryAccountNum(String primaryAccountNum) {
		this.primaryAccountNum = primaryAccountNum;
	}

	public String getClaimId() {
		return claimId;
	}

	public void setClaimId(String claimId) {
		this.claimId = claimId;
	}

	public String getClaimType() {
		return claimType;
	}

	public void setClaimType(String claimType) {
		this.claimType = claimType;
	}

	public String getClaimValue() {
		return claimValue;
	}

	public void setClaimValue(String claimValue) {
		this.claimValue = claimValue;
	}

	public Date getClearingDueDate() {
		return clearingDueDate;
	}

	public void setClearingDueDate(Date clearingDueDate) {
		this.clearingDueDate = clearingDueDate;
	}

	public String getClearingNetwork() {
		return clearingNetwork;
	}

	public void setClearingNetwork(String clearingNetwork) {
		this.clearingNetwork = clearingNetwork;
	}

	public Date getCreateDate() {
		return createDate;
	}

	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}

	public Date getDueDate() {
		return dueDate;
	}

	public void setDueDate(Date dueDate) {
		this.dueDate = dueDate;
	}

	public String getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(String transactionId) {
		this.transactionId = transactionId;
	}

	public Boolean getIsAccurate() {
		return isAccurate;
	}

	public void setIsAccurate(Boolean isAccurate) {
		this.isAccurate = isAccurate;
	}

	public Boolean getIsAcquirer() {
		return isAcquirer;
	}

	public void setIsAcquirer(Boolean isAcquirer) {
		this.isAcquirer = isAcquirer;
	}

	public Boolean getIsIssuer() {
		return isIssuer;
	}

	public void setIsIssuer(Boolean isIssuer) {
		this.isIssuer = isIssuer;
	}

	public Boolean getIsOpen() {
		return isOpen;
	}

	public void setIsOpen(Boolean isOpen) {
		this.isOpen = isOpen;
	}

	public String getIssuerId() {
		return issuerId;
	}

	public void setIssuerId(String issuerId) {
		this.issuerId = issuerId;
	}

	public String getLastModifiedBy() {
		return lastModifiedBy;
	}

	public void setLastModifiedBy(String lastModifiedBy) {
		this.lastModifiedBy = lastModifiedBy;
	}

	public Date getLastModifiedDate() {
		return lastModifiedDate;
	}

	public void setLastModifiedDate(Date lastModifiedDate) {
		this.lastModifiedDate = lastModifiedDate;
	}

	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	public String getProgressState() {
		return progressState;
	}

	public void setProgressState(String progressState) {
		this.progressState = progressState;
	}

	public String getQueueName() {
		return queueName;
	}

	public void setQueueName(String queueName) {
		this.queueName = queueName;
	}
}

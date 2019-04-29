package ru.bpc.sv2.application;

import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.rules.DspApplicationFile;
import ru.bpc.sv2.utils.AppStructureUtils;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class DspApplication implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private Long id;
    private Long disputeId;
    private Long caseId;
    private Long claimId;
    private String applicationNumber;
    private String type;
    private String subType;
    private String typeDesc;
    private String cardMask;
    private String cardNumber;
    private Long cardId;
    private Date cardExpDate;
    private String operCardMask;
    private String cardType;
    private Integer agentId;
    private String agentNumber;
    private String agentName;
    private Integer seqNum;
    private Date created;
    private String status;
    private String newStatus;
    private String oldStatus;
    private Date operDate;
    private String currency;
    private BigDecimal amount;
    private List<DspApplicationFile> files;
    private String comment;
    private String rejectCode;
    private String rejectCodeName;
    private String rejectComment;
    private Boolean visible;
    private String terminalId;
    private String terminalNumber;
    private String merchantId;
    private String merchantName;
    private String merchantNumber;
    private String referenceNumber;
    private Integer flowId;
    private String flowName;
    private Integer userId;
    private Integer instId;
    private String instNumber;
    private String instName;
    private String userName;
    private String authCode;
    private Boolean userChanged;
    private String accountNumber;
    private Long customerId;
    private String customerNumber;
    private String customerInfo;
    private Date applicationDate;
    private Long operId;
    private String disputeReason;
    private String disputeReasonName;
    private String disputeProgress;
    private Date dueDate;
    private Boolean expiryNotification;
    private String eventType;
    private String messageType;
    private BigDecimal writeOffAmount;
    private String writeOffCurrency;
    private Date transactionDate;
    private BigDecimal disputedAmount;
    private String disputedCurrency;
    private Date dspAppDateFrom;
    private Date dspAppDateTo;
    private String caseStatus;
    private String applStatusName;
    private String caseStatusName;
    private String caseOwner;
    private String caseOwnerName;
    private String caseState;
    private String caseProgress;
    private String caseProgressName;
    private String reasonCode;
    private String chargebackLovId;
    private Integer reassignUser;
    private Long createdByUserId;
    private String createdByUserName;
    private String acquirerInstBin;
    private String transactionCode;
    private BigDecimal sttlAmount;
    private String sttlCurrency;
    private BigDecimal baseAmount;
    private String baseCurrency;
    private Date hideDate;
    private Date unhideDate;
    private Long teamId;
    private String teamName;
    private String mmt;
    private String lang;

    private String mcc;
    private String arn;
    private String rrn;
    private String merchantStreet;
    private String merchantCity;
    private String merchantRegion;
    private String merchantCountry;
    private String merchantPostCode;
    private String forwInstBin;
	private String extClaimId;

    @Override
    public Object getModelId() {
        return getId();
    }

    public String getType() {
        if (type == null) {
            setType(ApplicationConstants.TYPE_DISPUTES);
        }
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    public String getSubType() {
        return subType;
    }
    public void setSubType(String subType) {
        this.subType = subType;
    }

    public String getTypeDesc() {
        return typeDesc;
    }
    public void setTypeDesc(String typeDesc) {
        this.typeDesc = typeDesc;
    }

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getDisputeId() {
        return disputeId;
    }
    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public String getApplicationNumber() {
        return applicationNumber;
    }
    public void setApplicationNumber(String applicationNumber) {
        this.applicationNumber = applicationNumber;
    }

    public String getCardMask() {
        return cardMask;
    }
    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public Long getCardId() {
        return cardId;
    }
    public void setCardId(Long cardId) {
        this.cardId = cardId;
    }

    public Date getCardExpDate() {
        return cardExpDate;
    }
    public void setCardExpDate(Date cardExpDate) {
        this.cardExpDate = cardExpDate;
    }

    public Integer getAgentId() {
        return agentId;
    }
    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public Date getCreated() {
        return created;
    }
    public void setCreated(Date created) {
        this.created = created;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }
    public boolean isUnchangeableStatus() {
        if (status != null) {
            return (/*status.equals("APST0001") ||*/ status.equals("APST0007"));
        }
        return true;
    }

    public Date getOperDate() {
        return operDate;
    }
    public void setOperDate(Date operDate) {
        this.operDate = operDate;
    }

    public String getCurrency() {
        return currency;
    }
    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public List<DspApplicationFile> getFiles() {
        return files;
    }
    public void setFiles(List<DspApplicationFile> files) {
        this.files = files;
    }

    public Integer getSeqNum() {
        return seqNum;
    }
    public void setSeqNum(Integer seqNum) {
        this.seqNum = seqNum;
    }

    public String getComment() {
        return comment;
    }
    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getRejectCode() {
        return rejectCode;
    }
    public void setRejectCode(String rejectCode) {
        this.rejectCode = rejectCode;
    }

    public Boolean getVisible() {
        if (visible == null) {
            setVisible(true);
        }
        return visible;
    }
    public Boolean isVisible() {
        return getVisible();
    }
    public void setVisible(Boolean visible) {
        this.visible = visible;
    }

    public String getTerminalNumber() {
        return terminalNumber;
    }
    public void setTerminalNumber(String terminalNumber) {
        this.terminalNumber = terminalNumber;
    }

    public String getMerchantName() {
        return merchantName;
    }

    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getMerchantNumber() {
        return merchantNumber;
    }
    public void setMerchantNumber(String merchantNumber) {
        this.merchantNumber = merchantNumber;
    }

    public String getReferenceNumber() {
        return referenceNumber;
    }
    public void setReferenceNumber(String referenceNumber) {
        this.referenceNumber = referenceNumber;
    }

    public Integer getFlowId() {
        return flowId;
    }
    public void setFlowId(Integer flowId) {
        this.flowId = flowId;
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

    public String getAuthCode() {
        return authCode;
    }
    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
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

    public Boolean getUserChanged() {
        return userChanged;
    }
    public void setUserChanged(Boolean userChanged) {
        this.userChanged = userChanged;
    }

    public String getAccountNumber() {
        return accountNumber;
    }
    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
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

    public String getCustomerInfo() {
        return customerInfo;
    }
    public void setCustomerInfo(String customerInfo) {
        this.customerInfo = customerInfo;
    }

    public Date getApplicationDate() {
        if (applicationDate == null) {
            setApplicationDate(new Date());
        }
        return applicationDate;
    }
    public void setApplicationDate(Date applicationDate) {
        this.applicationDate = applicationDate;
    }

    public String getCardType() {
        return cardType;
    }
    public void setCardType(String cardType) {
        this.cardType = cardType;
    }

    public String getAgentName() {
        return agentName;
    }
    public void setAgentName(String agentName) {
        this.agentName = agentName;
    }

    public String getInstName() {
        return instName;
    }
    public void setInstName(String instName) {
        this.instName = instName;
    }

    public Long getOperId() {
        return operId;
    }
    public void setOperId(Long operId) {
        this.operId = operId;
    }

    public String getAgentNumber() {
        return agentNumber;
    }
    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }

    public String getInstNumber() {
        return instNumber;
    }
    public void setInstNumber(String instNumber) {
        this.instNumber = instNumber;
    }

    public String getDisputeReason() {
        return disputeReason;
    }
    public void setDisputeReason(String disputeReason) {
        this.disputeReason = disputeReason;
    }

    public String getDisputeReasonName() {
        return disputeReasonName;
    }

    public void setDisputeReasonName(String disputeReasonName) {
        this.disputeReasonName = disputeReasonName;
    }

    public String getDisputeProgress() {
        return disputeProgress;
    }
    public void setDisputeProgress(String disputeProgress) {
        this.disputeProgress = disputeProgress;
    }

    public String getTerminalId() {
        return terminalId;
    }
    public void setTerminalId(String terminalId) {
        this.terminalId = terminalId;
    }

    public String getMerchantId() {
        return merchantId;
    }
    public void setMerchantId(String merchantId) {
        this.merchantId = merchantId;
    }

    public String getOperCardMask() {
        return operCardMask;
    }
    public void setOperCardMask(String operCardMask) {
        this.operCardMask = operCardMask;
    }

    public String getFlowName() {
        return flowName;
    }
    public void setFlowName(String flowName) {
        this.flowName = flowName;
    }

    public Date getDueDate() {
        return dueDate;
    }
    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }

    public Boolean getExpiryNotification() {
        return expiryNotification;
    }
    public void setExpiryNotification(Boolean expiryNotification) {
        this.expiryNotification = expiryNotification;
    }

    public String getEventType() {
        return eventType;
    }
    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getMessageType() {
        return messageType;
    }
    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public BigDecimal getWriteOffAmount() {
        return writeOffAmount;
    }
    public void setWriteOffAmount(BigDecimal writeOffAmount) {
        this.writeOffAmount = writeOffAmount;
    }

    public String getWriteOffCurrency() {
        return writeOffCurrency;
    }
    public void setWriteOffCurrency(String writeOffCurrency) {
        this.writeOffCurrency = writeOffCurrency;
    }

    public BigDecimal getDisputedAmount() {
        return disputedAmount;
    }
    public void setDisputedAmount(BigDecimal disputedAmount) {
        this.disputedAmount = disputedAmount;
    }

    public String getDisputedCurrency() {
        return disputedCurrency;
    }
    public void setDisputedCurrency(String disputedCurrency) {
        this.disputedCurrency = disputedCurrency;
    }

    public Date getTransactionDate() {
        return transactionDate;
    }
    public void setTransactionDate(Date transactionDate) {
        this.transactionDate = transactionDate;
    }

    public Date getDspAppDateFrom() {
        return dspAppDateFrom;
    }
    public void setDspAppDateFrom(Date dspAppDateFrom) {
        this.dspAppDateFrom = dspAppDateFrom;
    }

    public Date getDspAppDateTo() {
        return dspAppDateTo;
    }
    public void setDspAppDateTo(Date dspAppDateTo) {
        this.dspAppDateTo = dspAppDateTo;
    }

    public String getCaseStatus() {
        return caseStatus;
    }
    public void setCaseStatus(String caseStatus) {
        this.caseStatus = caseStatus;
    }

    public String getApplStatusName() {
        return applStatusName;
    }
    public void setApplStatusName(String applStatusName) {
        this.applStatusName = applStatusName;
    }

    public String getCaseStatusName() {
        return caseStatusName;
    }
    public void setCaseStatusName(String caseStatusName) {
        this.caseStatusName = caseStatusName;
    }

    public String getCaseOwner() {
        return caseOwner;
    }
    public void setCaseOwner(String caseOwner) {
        this.caseOwner = caseOwner;
    }

    public String getCaseOwnerName() {
        return caseOwnerName;
    }
    public void setCaseOwnerName(String caseOwnerName) {
        this.caseOwnerName = caseOwnerName;
    }

    public String getCaseState() {
        return caseState;
    }
    public void setCaseState(String caseState) {
        this.caseState = caseState;
    }

    public String getCaseProgress() {
        return caseProgress;
    }
    public void setCaseProgress(String caseProgress) {
        this.caseProgress = caseProgress;
    }

    public String getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public String getChargebackLovId() {
        return chargebackLovId;
    }
    public void setChargebackLovId(String chargebackLovId) {
        this.chargebackLovId = chargebackLovId;
    }

    public Long getCaseId() {
        return caseId;
    }
    public void setCaseId(Long caseId) {
        this.caseId = caseId;
    }

    public Long getClaimId() {
        return claimId;
    }
    public void setClaimId(Long claimId) {
        this.claimId = claimId;
    }

    public String getRejectCodeName() {
        return rejectCodeName;
    }
    public void setRejectCodeName(String rejectCodeName) {
        this.rejectCodeName = rejectCodeName;
    }

    public String getRejectComment() {
        return rejectComment;
    }
    public void setRejectComment(String rejectComment) {
        this.rejectComment = rejectComment;
    }

    public Integer getReassignUser() {
        return reassignUser;
    }
    public void setReassignUser(Integer reassignUser) {
        this.reassignUser = reassignUser;
    }

    public String getCaseProgressName() {
        return caseProgressName;
    }
    public void setCaseProgressName(String caseProgressName) {
        this.caseProgressName = caseProgressName;
    }

    public Long getCreatedByUserId() {
        return createdByUserId;
    }
    public void setCreatedByUserId(Long createdByUserId) {
        this.createdByUserId = createdByUserId;
    }

    public String getCreatedByUserName() {
        return createdByUserName;
    }

    public void setCreatedByUserName(String createdByUserName) {
        this.createdByUserName = createdByUserName;
    }

    public String getAcquirerInstBin() {
        return acquirerInstBin;
    }
    public void setAcquirerInstBin(String acquirerInstBin) {
        this.acquirerInstBin = acquirerInstBin;
    }

    public String getTransactionCode() {
        return transactionCode;
    }
    public void setTransactionCode(String transactionCode) {
        this.transactionCode = transactionCode;
    }

    public BigDecimal getSttlAmount() {
        return sttlAmount;
    }
    public void setSttlAmount(BigDecimal sttlAmount) {
        this.sttlAmount = sttlAmount;
    }

    public String getSttlCurrency() {
        return sttlCurrency;
    }
    public void setSttlCurrency(String sttlCurrency) {
        this.sttlCurrency = sttlCurrency;
    }

    public BigDecimal getBaseAmount() {
        return baseAmount;
    }
    public void setBaseAmount(BigDecimal baseAmount) {
        this.baseAmount = baseAmount;
    }

    public String getBaseCurrency() {
        return baseCurrency;
    }
    public void setBaseCurrency(String baseCurrency) {
        this.baseCurrency = baseCurrency;
    }

    public Date getHideDate() {
        return hideDate;
    }
    public void setHideDate(Date hideDate) {
        this.hideDate = hideDate;
    }

    public Date getUnhideDate() {
        return unhideDate;
    }
    public void setUnhideDate(Date unhideDate) {
        this.unhideDate = unhideDate;
    }

    public Long getTeamId() {
        return teamId;
    }
    public void setTeamId(Long teamId) {
        this.teamId = teamId;
    }

    public String getTeamName() {
        return teamName;
    }

    public void setTeamName(String teamName) {
        this.teamName = teamName;
    }

    public String getMmt() {
        return mmt;
    }
    public void setMmt(String mmt) {
        this.mmt = mmt;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getMcc() {
        return mcc;
    }

    public void setMcc(String mcc) {
        this.mcc = mcc;
    }

    public String getArn() {
        return arn;
    }

    public void setArn(String arn) {
        this.arn = arn;
    }

    public String getRrn() {
        return rrn;
    }

    public void setRrn(String rrn) {
        this.rrn = rrn;
    }

    public String getMerchantStreet() {
        return merchantStreet;
    }

    public void setMerchantStreet(String merchantStreet) {
        this.merchantStreet = merchantStreet;
    }

    public String getMerchantCity() {
        return merchantCity;
    }

    public void setMerchantCity(String merchantCity) {
        this.merchantCity = merchantCity;
    }

    public String getMerchantRegion() {
        return merchantRegion;
    }

    public void setMerchantRegion(String merchantRegion) {
        this.merchantRegion = merchantRegion;
    }

    public String getMerchantCountry() {
        return merchantCountry;
    }

    public void setMerchantCountry(String merchantCountry) {
        this.merchantCountry = merchantCountry;
    }

    public String getMerchantPostCode() {
        return merchantPostCode;
    }

    public void setMerchantPostCode(String merchantPostCode) {
        this.merchantPostCode = merchantPostCode;
    }

    public String getForwInstBin() {
        return forwInstBin;
    }

    public void setForwInstBin(String forwInstBin) {
        this.forwInstBin = forwInstBin;
    }

    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("cardMask", getCardMask());
        result.put("instId", getInstId());
        result.put("agentId", getAgentId());
        result.put("flowId", getFlowId());
        result.put("userId", getUserId());
        result.put("created", getCreated());
        result.put("status", getStatus());
        result.put("eventType", getStatus());
        result.put("messageType", getMessageType());
        return result;
    }

    public Application toApplication() {
        Application out = new Application();
        out.setId(id);
        out.setApplNumber(applicationNumber);
        out.setAppType(type);
        out.setAppSubType(subType);
        out.setDescription(typeDesc);
        out.setCreated(applicationDate);
        out.setCardNumber(cardMask);
        out.setRejectCode(rejectCode);
        out.setAccountNumber(accountNumber);
        out.setAgentId(agentId);
        out.setSeqNum(seqNum);
        out.setComment(comment);
        out.setCustomerId(customerId);
        out.setCustomerNumber(customerNumber);
        out.setFlowId(flowId);
        out.setFlowName(flowName);
        out.setStatus(status);
        out.setInstId(instId);
        out.setOldStatus(oldStatus);
        out.setNewStatus(newStatus);
        out.setInstName(instName);
        out.setTerminalNumber(terminalNumber);
        out.setMerchantNumber(merchantNumber);
        out.setUserId(userId);
        out.setUserName(userName);
        out.setOperId(operId);
        out.setEventType(eventType);
        return out;
    }
    public void fromApplication(Application app) {
        id = app.getId();
        applicationNumber = app.getApplNumber();
        type = app.getAppType();
        subType = app.getAppSubType();
        typeDesc = app.getDescription();
        applicationDate = app.getCreated();
        cardMask = app.getCardNumber();
        rejectCode = app.getRejectCode();
        accountNumber = app.getAccountNumber();
        agentId = app.getAgentId();
        seqNum = app.getSeqNum();
        comment = app.getComment();
        customerId = app.getCustomerId();
        customerNumber = app.getCustomerNumber();
        flowId = app.getFlowId();
        flowName = app.getFlowName();
        status = app.getStatus();
        instId = app.getInstId();
        oldStatus = app.getOldStatus();
        newStatus = app.getNewStatus();
        instName = app.getInstName();
        terminalNumber = app.getTerminalNumber();
        merchantNumber = app.getMerchantNumber();
        userId = app.getUserId();
        userName = app.getUserName();
        operId = app.getOperId();
        eventType = app.getEventType();
    }

	public String getExtClaimId() {
		return extClaimId;
	}

	public void setExtClaimId(String extClaimId) {
		this.extClaimId = extClaimId;
	}
}

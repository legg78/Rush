package ru.bpc.sv2.application;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class ManualCaseCreation implements Serializable, Cloneable {
    private static final long serialVersionUID = 1L;

    private Long applId;
    private Integer seqnum;
    private Long instId;
    private String merchantName;
    private String customerNumber;
    private String disputeReason;
    private Date operDate;
    private BigDecimal operAmount;
    private String operCurrency;
    private Long disputeId;
    private String disputeProgress;
    private BigDecimal writeOffAmount;
    private String writeOffCurrency;
    private Date dueDate;
    private String reasonCode;
    private BigDecimal disputedAmount;
    private String disputedCurrency;
    private Date createdDate;
    private Long createdByUserId;
    private String createdByUserName;
    private String arn;
    private Long claimId;
    private String authCode;
    private String caseProgress;
    private String acquirerInstBin;
    private String transactionCode;
    private String caseSource;
    private BigDecimal sttlAmount;
    private String sttlCurrency;
    private BigDecimal baseAmount;
    private String baseCurrency;
    private Date hideDate;
    private Date unhideDate;
    private Long teamId;
    private String cardNumber;
    private Long flowId;
    private Long caseId;
    private String owner;
    private String ownerName;
    private Date closedOn;
    private String closedBy;
    private String application;
    private String caseStatus;
    private String forwardingInstBin;
    private String caseState;
    private String terminalNumber;
    private String merchantNumber;
    private String rrn;
    private String caseResolution;
    private String mcc;
    private String merchantCountryCode;
    private String merchantLocation;
    private String flow;
    private String disputeTeam;
    private Integer agentId;
    private String agentNumber;
    private String agentName;
    private Long duplicatedFromCaseId;

    public ManualCaseCreation() {}

    public Long getApplId() {
        return applId;
    }
    public void setApplId(Long applId) {
        this.applId = applId;
    }

    public Integer getSeqnum() {
        return seqnum;
    }
    public void setSeqnum(Integer seqnum) {
        this.seqnum = seqnum;
    }

    public Long getInstId() {
        return instId;
    }
    public void setInstId(Long instId) {
        this.instId = instId;
    }

    public String getMerchantName() {
        return merchantName;
    }
    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getCustomerNumber() {
        return customerNumber;
    }
    public void setCustomerNumber(String customerNumber) {
        this.customerNumber = customerNumber;
    }

    public String getDisputeReason() {
        return disputeReason;
    }
    public void setDisputeReason(String disputeReason) {
        this.disputeReason = disputeReason;
    }

    public Date getOperDate() {
        return operDate;
    }
    public void setOperDate(Date operDate) {
        this.operDate = operDate;
    }

    public BigDecimal getOperAmount() {
        return operAmount;
    }
    public void setOperAmount(BigDecimal operAmount) {
        this.operAmount = operAmount;
    }

    public String getOperCurrency() {
        return operCurrency;
    }
    public void setOperCurrency(String operCurrency) {
        this.operCurrency = operCurrency;
    }

    public Long getDisputeId() {
        return disputeId;
    }
    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public String getDisputeProgress() {
        return disputeProgress;
    }
    public void setDisputeProgress(String disputeProgress) {
        this.disputeProgress = disputeProgress;
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

    public Date getDueDate() {
        return dueDate;
    }
    public void setDueDate(Date dueDate) {
        this.dueDate = dueDate;
    }

    public String getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
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

    public Date getCreatedDate() {
        return createdDate;
    }
    public void setCreatedDate(Date createdDate) {
        this.createdDate = createdDate;
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

    public String getArn() {
        return arn;
    }
    public void setArn(String arn) {
        this.arn = arn;
    }

    public Long getClaimId() {
        return claimId;
    }
    public void setClaimId(Long claimId) {
        this.claimId = claimId;
    }

    public String getAuthCode() {
        return authCode;
    }
    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    public String getCaseProgress() {
        return caseProgress;
    }
    public void setCaseProgress(String caseProgress) {
        this.caseProgress = caseProgress;
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

    public String getCaseSource() {
        return caseSource;
    }
    public void setCaseSource(String caseSource) {
        this.caseSource = caseSource;
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

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public Long getFlowId() {
        return flowId;
    }
    public void setFlowId(Long flowId) {
        this.flowId = flowId;
    }

    public Long getCaseId() {
        return caseId;
    }
    public void setCaseId(Long caseId) {
        this.caseId = caseId;
    }

    public String getOwner() {
        return owner;
    }
    public void setOwner(String owner) {
        this.owner = owner;
    }

    public String getOwnerName() {
        return ownerName;
    }
    public void setOwnerName(String ownerName) {
        this.ownerName = ownerName;
    }

    public Date getClosedOn() {
        return closedOn;
    }
    public void setClosedOn(Date closedOn) {
        this.closedOn = closedOn;
    }

    public String getClosedBy() {
        return closedBy;
    }
    public void setClosedBy(String closedBy) {
        this.closedBy = closedBy;
    }

    public String getApplication() {
        return application;
    }
    public void setApplication(String application) {
        this.application = application;
    }

    public String getCaseStatus() {
        return caseStatus;
    }
    public void setCaseStatus(String caseStatus) {
        this.caseStatus = caseStatus;
    }

    public String getForwardingInstBin() {
        return forwardingInstBin;
    }
    public void setForwardingInstBin(String forwardingInstBin) {
        this.forwardingInstBin = forwardingInstBin;
    }

    public String getCaseState() {
        return caseState;
    }
    public void setCaseState(String caseState) {
        this.caseState = caseState;
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

    public String getRrn() {
        return rrn;
    }
    public void setRrn(String rrn) {
        this.rrn = rrn;
    }

    public String getCaseResolution() {
        return caseResolution;
    }
    public void setCaseResolution(String caseResolution) {
        this.caseResolution = caseResolution;
    }

    public String getMcc() {
        return mcc;
    }
    public void setMcc(String mcc) {
        this.mcc = mcc;
    }

    public String getMerchantCountryCode() {
        return merchantCountryCode;
    }
    public void setMerchantCountryCode(String merchantCountryCode) {
        this.merchantCountryCode = merchantCountryCode;
    }

    public String getMerchantLocation() {
        return merchantLocation;
    }
    public void setMerchantLocation(String merchantLocation) {
        this.merchantLocation = merchantLocation;
    }

    public String getFlow() {
        return flow;
    }
    public void setFlow(String flow) {
        this.flow = flow;
    }

    public String getDisputeTeam() {
        return disputeTeam;
    }
    public void setDisputeTeam(String disputeTeam) {
        this.disputeTeam = disputeTeam;
    }

    public Integer getAgentId() {
        return agentId;
    }
    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public String getAgentNumber() {
        return agentNumber;
    }
    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }

    public String getAgentName() {
        return agentName;
    }
    public void setAgentName(String agentName) {
        this.agentName = agentName;
    }

    public Long getDuplicatedFromCaseId() {
        return duplicatedFromCaseId;
    }

    public void setDuplicatedFromCaseId(Long duplicatedFromCaseId) {
        this.duplicatedFromCaseId = duplicatedFromCaseId;
    }

    @Override
    public ManualCaseCreation clone() {
        try {
            return (ManualCaseCreation)super.clone();
        } catch (CloneNotSupportedException e) {
            return this;
        }
    }

    public void fromDspApplication(DspApplication app) {
        setApplId(app.getId());
        setCaseId((app.getCaseId() != null) ? app.getCaseId() : app.getId());
        setSeqnum(app.getSeqNum());
        setInstId(app.getInstId().longValue());
        setCustomerNumber(app.getCustomerNumber());
        setCreatedDate(app.getCreated());
        setCreatedByUserId(app.getUserId().longValue());
        setCardNumber(app.getCardNumber());
        setFlowId(app.getFlowId().longValue());
        setApplication(app.getApplicationNumber());
        setTerminalNumber(app.getTerminalNumber());
        setMerchantNumber(app.getMerchantNumber());
        setFlow(app.getFlowName());
        setAgentId(app.getAgentId());
        setReasonCode(app.getReasonCode());
        
        setMerchantName(app.getMerchantName());
        setOperDate(app.getTransactionDate());
        setOperAmount(app.getAmount());
        setOperCurrency(app.getCurrency());
        setDisputeId(app.getDisputeId());
        setDisputeProgress(app.getDisputeProgress());
        setWriteOffAmount(app.getWriteOffAmount());
        setWriteOffCurrency(app.getWriteOffCurrency());
        setCaseResolution(app.getCaseStatus());
        setDisputeReason(app.getDisputeReason());
        setDisputedAmount(app.getDisputedAmount());
        setDisputedCurrency(app.getDisputedCurrency());
        setCaseProgress(app.getCaseProgress());
        setAcquirerInstBin(app.getAcquirerInstBin());
        setCaseSource(app.getCaseState());
        setSttlAmount(app.getSttlAmount());
        setSttlCurrency(app.getSttlCurrency());
        setBaseAmount(app.getBaseAmount());
        setBaseCurrency(app.getBaseCurrency());
        setOwner(app.getCaseOwner());
        setCaseStatus(app.getCaseStatus());
        setRrn(app.getReferenceNumber());
    }
}

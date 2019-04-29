package ru.bpc.sv2.operations;

import org.apache.commons.lang3.StringEscapeUtils;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.invocation.TreeIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

public class Operation implements Serializable, TreeIdentifiable<Operation> {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long sessionId;
    private Long sessionFileId;
	private Boolean isReversal;
	private Boolean isReversalExists;
	private Long originalId;
	private String operType;
	private String operReason;
	private String msgType;
	private String status;
	private String statusReason;
	private String accountNumber;
	private String operationAmount;
	private String operationType;
	private String operationCurrency;
	private String authCode;
    private String newOperStatus;
	private String sttlType;
	private BigDecimal sttlAmount;
	private String sttlCurrency;

	private String acqInstBin;
	private String forwInstBin;
	private String terminalNumber;
	private String merchantNumber;
	private String merchantName;
	private String merchantStreet;
	private String merchantCity;
	private String merchantRegion;
	private String merchantCountry;
	private String merchantPostCode;
	private String mccCode;
	private String mccName;

	private String originatorRefnum;
	private String networkRefnum;
	private Long operCount;
	private BigDecimal operRequestAmount;
	private String operAmountAlgorithm;
	private BigDecimal operAmount;
	private String operCurrency;
	private BigDecimal operCashbackAmount;
	private BigDecimal operReplacementAmount;
	private BigDecimal operSurchargeAmount;
	private Date operDate;
	private Date hostDate;
	private Date unholdDate;
    private Date hostDateFrom;
    private Date hostDateTo;
	private String matchStatus;
	private Long matchId;
	private Long disputeId;
	private Long paymentOrderId;
	private Integer paymentHostId;
	private Boolean forcedProcessing;
	private String paymentHostName;
	private List<Participant> participants;
	private Long authId;
	private int level;
	private List<Operation> children;
	private boolean disputeAllowed;
	private Participant participantData;
	private String clientIdType;	
	private String clientIdValue;
	private String balance;
	private String cardMask;
	private String cardToken;
	private String cardNumber;
	private String cardSeqNumber;
	private String cardType;
	private String currency;
	private String currencyName;
	private String operationTypeName;
	private String statusName;
	private String condition;
	private Integer terminalId;
	private String accountAmount;
	private String accountCurrency;
	private Integer acqInstId;
	private String acqInstName;
	private Integer issInstId;
	private String issInstName;
	private Integer issNetworkId;
	private Integer cardNetworkId;
	private Integer acqNetworkId;
	private String issNetworkName;
	private String cardNetworkName;
	private String acqNetworkName;
	private String terminalType;
	private String terminalTypeName;
	private String externalAuthId;

	private Boolean documentsUnloaded;
	private String reasonCode;
	private String memberMessageText;
	private Long customerId;

	private String debitCreditSign;
	private String command;

	private String respCode;
	private Boolean isAdvice;
	private String catLevel;
	private String cardDataInputCap;
	private String crdhAuthCap;
	private String cardCaptureCap;
	private String terminalOperatingEnv;
	private String crdhPresence;
	private String cardPresence;
	private String cardDataInputMode;
	private String crdhAuthMethod;
	private String crdhAuthEntity;
	private String cardDataOutputCap;
	private String terminalOutputCap;
	private String pinCaptureCap;
	private String pinPresence;

	private String dispMessageType;
	private Boolean incoming;
	private String memberText;
	private String docInd;
	private String fraudType;
	private Boolean rejected;
	private String createdBy;
	private String clearingMessageStatus;

	public Object getModelId() {
		return id;
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Boolean getIsReversal() {
		return isReversal;
	}
	public void setIsReversal(Boolean isReversal) {
		this.isReversal = isReversal;
	}

	public Long getOriginalId() {
		return originalId;
	}
	public void setOriginalId(Long originalId) {
		this.originalId = originalId;
	}

	public String getOperType() {
		return operType;
	}
	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getOperReason() {
		return operReason;
	}
	public void setOperReason(String operReason) {
		this.operReason = operReason;
	}

	public String getMsgType() {
		return msgType;
	}
	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public String getStatusReason() {
		return statusReason;
	}
	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	public String getSttlType() {
		return sttlType;
	}
	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
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

	public String getAcqInstBin() {
		return acqInstBin;
	}
	public void setAcqInstBin(String acqInstBin) {
		this.acqInstBin = acqInstBin;
	}

	public String getForwInstBin() {
		return forwInstBin;
	}
	public void setForwInstBin(String forwInstBin) {
		this.forwInstBin = forwInstBin;
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

	public String getMerchantName() {
		return merchantName;
	}
	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
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

	public String getMccCode() {
		return mccCode;
	}
	public void setMccCode(String mccCode) {
		this.mccCode = mccCode;
	}

	public String getMccName() {
		return mccName;
	}
	public void setMccName(String mccName) {
		this.mccName = mccName;
	}

	public String getOriginatorRefnum() {
		return originatorRefnum;
	}
	public void setOriginatorRefnum(String originatorRefnum) {
		this.originatorRefnum = originatorRefnum;
	}

	public String getNetworkRefnum() {
		return networkRefnum;
	}
	public void setNetworkRefnum(String networkRefnum) {
		this.networkRefnum = networkRefnum;
	}

	public Long getOperCount() {
		return operCount;
	}
	public void setOperCount(Long operCount) {
		this.operCount = operCount;
	}

	public BigDecimal getOperRequestAmount() {
		return operRequestAmount;
	}
	public void setOperRequestAmount(BigDecimal operRequestAmount) {
		this.operRequestAmount = operRequestAmount;
	}

	public String getOperAmountAlgorithm() {
		return operAmountAlgorithm;
	}
	public void setOperAmountAlgorithm(String operAmountAlgorithm) {
		this.operAmountAlgorithm = operAmountAlgorithm;
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

	public BigDecimal getOperCashbackAmount() {
		return operCashbackAmount;
	}
	public void setOperCashbackAmount(BigDecimal operCashbackAmount) {
		this.operCashbackAmount = operCashbackAmount;
	}

	public BigDecimal getOperReplacementAmount() {
		return operReplacementAmount;
	}
	public void setOperReplacementAmount(BigDecimal operReplacementAmount) {
		this.operReplacementAmount = operReplacementAmount;
	}

	public BigDecimal getOperSurchargeAmount() {
		return operSurchargeAmount;
	}
	public void setOperSurchargeAmount(BigDecimal operSurchargeAmount) {
		this.operSurchargeAmount = operSurchargeAmount;
	}

	public Date getOperDate() {
		return operDate;
	}
	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	public Date getHostDate() {
		return hostDate;
	}
	public void setHostDate(Date hostDate) {
		this.hostDate = hostDate;
	}

	public Date getUnholdDate() {
		return unholdDate;
	}
	public void setUnholdDate(Date unholdDate) {
		this.unholdDate = unholdDate;
	}

	public String getMatchStatus() {
		return matchStatus;
	}
	public void setMatchStatus(String matchStatus) {
		this.matchStatus = matchStatus;
	}

	public Long getMatchId() {
		return matchId;
	}
	public void setMatchId(Long matchId) {
		this.matchId = matchId;
	}

	public Long getDisputeId() {
		return disputeId;
	}
	public void setDisputeId(Long disputeId) {
		this.disputeId = disputeId;
	}

	public Long getPaymentOrderId() {
		return paymentOrderId;
	}
	public void setPaymentOrderId(Long paymentOrderId) {
		this.paymentOrderId = paymentOrderId;
	}

	public Integer getPaymentHostId() {
		return paymentHostId;
	}
	public void setPaymentHostId(Integer paymentHostId) {
		this.paymentHostId = paymentHostId;
	}

	public Boolean getForcedProcessing() {
		return forcedProcessing;
	}
	public void setForcedProcessing(Boolean forcedProcessing) {
		this.forcedProcessing = forcedProcessing;
	}

	public String getPaymentHostName() {
		return paymentHostName;
	}
	public void setPaymentHostName(String paymentHostName) {
		this.paymentHostName = paymentHostName;
	}

	public Long getAuthId() {
		return authId;
	}
	public void setAuthId(Long authId) {
		this.authId = authId;
	}

	public String getAccountNumber() {
		return accountNumber;
	}
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	public String getOperationAmount() {
		return operationAmount;
	}
	public void setOperationAmount(String operationAmount) {
		this.operationAmount = operationAmount;
	}

	public String getOperationType() {
		return operationType;
	}
	public void setOperationType(String operationType) {
		this.operationType = operationType;
	}

	public String getOperationCurrency() {
		return operationCurrency;
	}
	public void setOperationCurrency(String operationCurrency) {
		this.operationCurrency = operationCurrency;
	}

	public List<Participant> getParticipants() {
		return participants;
	}
	public void setParticipants(List<Participant> participants) {
		this.participants = participants;
	}

	public void setLevel(int level) {
		this.level = level;
	}
	@Override
	public int getLevel() {
		return level;
	}

	@Override
	public List<Operation> getChildren() {
		return children;
	}
	@Override
	public void setChildren(List<Operation> children) {
		this.children = children;
	}
	@Override
	public boolean isHasChildren() {
		return children != null && !children.isEmpty();
	}

	@Override
	public Long getParentId() {
		return originalId;
	}

	public boolean isDisputeAllowed() {
		return disputeAllowed;
	}
	public void setDisputeAllowed(boolean disputeAllowed) {
		this.disputeAllowed = disputeAllowed;
	}

	public Participant getParticipantData() {
		return participantData;
	}
	public void setParticipantData(Participant participantData) {
		this.participantData = participantData;
	}

	public Boolean getIsReversalExists() {
		return isReversalExists;
	}
	public void setIsReversalExists(Boolean isReversalExists) {
		this.isReversalExists = isReversalExists;
	}

	public String getClientIdType() {
		return clientIdType;
	}
	public void setClientIdType(String clientIdType) {
		this.clientIdType = clientIdType;
	}

	public String getClientIdValue() {
		return clientIdValue;
	}
	public void setClientIdValue(String clientIdValue) {
		this.clientIdValue = clientIdValue;
	}

	public String getBalance() {
		return balance;
	}
	public void setBalance(String balance) {
		this.balance = balance;
	}

	public String getCardMask() {
		return cardMask;
	}
	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}

	public String getCardToken() {
		return cardToken;
	}
	public void setCardToken(String cardToken) {
		this.cardToken = cardToken;
	}

	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getCardSeqNumber() {
		return cardSeqNumber;
	}
	public void setCardSeqNumber(String cardSeqNumber) {
		this.cardSeqNumber = cardSeqNumber;
	}

	public String getCardType() {
		return cardType;
	}
	public void setCardType(String cardType) {
		this.cardType = cardType;
	}

	public String getCurrencyName() {
		return currencyName;
	}
	public void setCurrencyName(String currencyName) {
		this.currencyName = currencyName;
	}

	public String getOperationTypeName() {
		return operationTypeName;
	}
	public void setOperationTypeName(String operationTypeName) {
		this.operationTypeName = operationTypeName;
	}

	public String getStatusName() {
		return statusName;
	}
	public void setStatusName(String statusName) {
		this.statusName = statusName;
	}

	public String getCondition() {
		return condition;
	}
	public void setCondition(String condition) {
		this.condition = condition;
	}

	public Integer getTerminalId() {
		return terminalId;
	}
	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}

	public String getAccountAmount() {
		return accountAmount;
	}
	public void setAccountAmount(String accountAmount) {
		this.accountAmount = accountAmount;
	}

	public String getAccountCurrency() {
		return accountCurrency;
	}
	public void setAccountCurrency(String accountCurrency) {
		this.accountCurrency = accountCurrency;
	}

	public Integer getAcqInstId() {
		return acqInstId;
	}
	public void setAcqInstId(Integer acqInstId) {
		this.acqInstId = acqInstId;
	}

	public String getAcqInstName() {
		return acqInstName;
	}
	public void setAcqInstName(String acqInstName) {
		this.acqInstName = acqInstName;
	}

	public Integer getIssInstId() {
		return issInstId;
	}
	public void setIssInstId(Integer issInstId) {
		this.issInstId = issInstId;
	}

	public String getIssInstName() {
		return issInstName;
	}
	public void setIssInstName(String issInstName) {
		this.issInstName = issInstName;
	}

	public Integer getIssNetworkId() {
		return issNetworkId;
	}
	public void setIssNetworkId(Integer issNetworkId) {
		this.issNetworkId = issNetworkId;
	}

	public Integer getAcqNetworkId() {
		return acqNetworkId;
	}
	public void setAcqNetworkId(Integer acqNetworkId) {
		this.acqNetworkId = acqNetworkId;
	}

	public String getIssNetworkName() {
		return issNetworkName;
	}
	public void setIssNetworkName(String issNetworkName) {
		this.issNetworkName = issNetworkName;
	}

	public String getAcqNetworkName() {
		return acqNetworkName;
	}
	public void setAcqNetworkName(String acqNetworkName) {
		this.acqNetworkName = acqNetworkName;
	}

	public Integer getCardNetworkId() {
		return cardNetworkId;
	}
	public void setCardNetworkId(Integer cardNetworkId) {
		this.cardNetworkId = cardNetworkId;
	}

	public String getCardNetworkName() {
		return cardNetworkName;
	}
	public void setCardNetworkName(String cardNetworkName) {
		this.cardNetworkName = cardNetworkName;
	}

	public String getAuthCode() {
		return authCode;
	}
	public void setAuthCode(String authCode) {
		this.authCode = authCode;
	}

	public String getTerminalType() {
		return terminalType;
	}
	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}

	public String getTerminalTypeName() {
		return terminalTypeName;
	}
	public void setTerminalTypeName(String terminalTypeName) {
		this.terminalTypeName = terminalTypeName;
	}

	public String getExternalAuthId() {
		return externalAuthId;
	}
	public void setExternalAuthId(String externalAuthId) {
		this.externalAuthId = externalAuthId;
	}

	public Boolean getDocumentsUnloaded() {
		return documentsUnloaded;
	}
	public void setDocumentsUnloaded(Boolean documentsUnloaded) {
		this.documentsUnloaded = documentsUnloaded;
	}

	public String getReasonCode() {
		return reasonCode;
	}
	public void setReasonCode(String reasonCode) {
		this.reasonCode = reasonCode;
	}

	public String getMemberMessageText() {
		return memberMessageText;
	}
	public void setMemberMessageText(String memberMessageText) {
		this.memberMessageText = memberMessageText;
	}

	public Long getCustomerId() {
		return customerId;
	}
	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public String getDebitCreditSign() {
		return debitCreditSign;
	}
	public void setDebitCreditSign(String debitCreditSign) {
		this.debitCreditSign = debitCreditSign;
	}

    public String getCommand() {
        return command;
    }

    public void setCommand(String command) {
        this.command = command;
    }

    public Long getSessionFileId() {
        return sessionFileId;
    }

    public void setSessionFileId(Long sessionFileId) {
        this.sessionFileId = sessionFileId;
    }

    public String getNewOperStatus() {
        return newOperStatus;
    }

    public void setNewOperStatus(String newOperStatus) {
        this.newOperStatus = newOperStatus;
    }

    public Date getHostDateFrom() {
        return hostDateFrom;
    }

    public void setHostDateFrom(Date hostDateFrom) {
        this.hostDateFrom = hostDateFrom;
    }

    public Date getHostDateTo() {
        return hostDateTo;
    }

    public void setHostDateTo(Date hostDateTo) {
        this.hostDateTo = hostDateTo;
    }

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}

	public String getCatLevel() {
		return catLevel;
	}

	public void setCatLevel(String catLevel) {
		this.catLevel = catLevel;
	}

	public String getCardDataInputCap() {
		return cardDataInputCap;
	}

	public void setCardDataInputCap(String cardDataInputCap) {
		this.cardDataInputCap = cardDataInputCap;
	}

	public String getCrdhAuthCap() {
		return crdhAuthCap;
	}

	public void setCrdhAuthCap(String crdhAuthCap) {
		this.crdhAuthCap = crdhAuthCap;
	}

	public String getCardCaptureCap() {
		return cardCaptureCap;
	}

	public void setCardCaptureCap(String cardCaptureCap) {
		this.cardCaptureCap = cardCaptureCap;
	}

	public String getTerminalOperatingEnv() {
		return terminalOperatingEnv;
	}

	public void setTerminalOperatingEnv(String terminalOperatingEnv) {
		this.terminalOperatingEnv = terminalOperatingEnv;
	}

	public String getCrdhPresence() {
		return crdhPresence;
	}

	public void setCrdhPresence(String crdhPresence) {
		this.crdhPresence = crdhPresence;
	}

	public String getCardPresence() {
		return cardPresence;
	}

	public void setCardPresence(String cardPresence) {
		this.cardPresence = cardPresence;
	}

	public String getCardDataInputMode() {
		return cardDataInputMode;
	}

	public void setCardDataInputMode(String cardDataInputMode) {
		this.cardDataInputMode = cardDataInputMode;
	}

	public String getCrdhAuthMethod() {
		return crdhAuthMethod;
	}

	public void setCrdhAuthMethod(String crdhAuthMethod) {
		this.crdhAuthMethod = crdhAuthMethod;
	}

	public String getCrdhAuthEntity() {
		return crdhAuthEntity;
	}

	public void setCrdhAuthEntity(String crdhAuthEntity) {
		this.crdhAuthEntity = crdhAuthEntity;
	}

	public String getCardDataOutputCap() {
		return cardDataOutputCap;
	}

	public void setCardDataOutputCap(String cardDataOutputCap) {
		this.cardDataOutputCap = cardDataOutputCap;
	}

	public String getTerminalOutputCap() {
		return terminalOutputCap;
	}

	public void setTerminalOutputCap(String terminalOutputCap) {
		this.terminalOutputCap = terminalOutputCap;
	}

	public String getPinCaptureCap() {
		return pinCaptureCap;
	}

	public void setPinCaptureCap(String pinCaptureCap) {
		this.pinCaptureCap = pinCaptureCap;
	}

	public String getPinPresence() {
		return pinPresence;
	}

	public void setPinPresence(String pinPresence) {
		this.pinPresence = pinPresence;
	}

	public Boolean getIsAdvice() {
		return isAdvice;
	}

	public void setIsAdvice(Boolean isAdvice) {
		this.isAdvice = isAdvice;
	}

	public String getDispMessageType() {
		return dispMessageType;
	}

	public void setDispMessageType(String dispMessageType) {
		this.dispMessageType = dispMessageType;
	}

	public Boolean getIncoming() {
		return incoming;
	}

	public void setIncoming(Boolean incoming) {
		this.incoming = incoming;
	}

	public String getMemberText() {
		return memberText;
	}

	public void setMemberText(String memberText) {
		this.memberText = memberText;
	}

	public String getDocInd() {
		return docInd;
	}

	public void setDocInd(String docInd) {
		this.docInd = docInd;
	}

	public String getFraudType() {
		return fraudType;
	}

	public void setFraudType(String fraudType) {
		this.fraudType = fraudType;
	}

	public Boolean getRejected() {
		return rejected;
	}

	public void setRejected(Boolean rejected) {
		this.rejected = rejected;
	}

	public String getCreatedBy() {
		return createdBy;
	}

	public void setCreatedBy(String createdBy) {
		this.createdBy = createdBy;
	}

	public String getClearingMessageStatus() {
		return clearingMessageStatus;
	}

	public void setClearingMessageStatus(String clearingMessageStatus) {
		this.clearingMessageStatus = clearingMessageStatus;
	}

	private ru.bpc.sv2.operations.incoming.Operation getIncomingOperation(String participantType) {
		ru.bpc.sv2.operations.incoming.Operation operation = new ru.bpc.sv2.operations.incoming.Operation();

		operation.setId(id);
		operation.setSessionId(sessionId);
		operation.setReversal(Boolean.TRUE.equals(isReversal));
		operation.setOriginalId(originalId);
		operation.setOperType(operType);
		operation.setOperReason(operReason);
		operation.setMsgType(msgType);
		operation.setStatus(status);
		operation.setStatusReason(statusReason);
		operation.setSttlType(sttlType);
		operation.setTerminalType(terminalType);
		operation.setAcqInstBin(acqInstBin);
		operation.setForwInstBin(forwInstBin);
		operation.setMerchantNumber(merchantNumber);
		operation.setTerminalNumber(terminalNumber);
		operation.setMerchantName(merchantName);
		operation.setMerchantStreet(merchantStreet);
		operation.setMerchantCity(merchantCity);
		operation.setMerchantRegion(merchantRegion);
		operation.setMerchantCountryCode(merchantCountry);
		operation.setMerchantPostCode(merchantPostCode);
		operation.setMccCode(mccCode);
		operation.setRefnum(originatorRefnum);
		operation.setNetworkRefnum(networkRefnum);
		operation.setOperCount(operCount);
		operation.setOperationRequestAmount(operRequestAmount);
		operation.setOperationAmount(operAmount);
		operation.setOperationCurrency(operCurrency);
		operation.setOperationCashbackAmount(operCashbackAmount);
		operation.setOperationReplacementAmount(operReplacementAmount);
		operation.setOperationSurchargeAmount(operSurchargeAmount);
		operation.setOperationDate(operDate);
		operation.setSourceHostDate(hostDate);
		operation.setMatchStatus(matchStatus);
		operation.setSttlAmount(sttlAmount);
		operation.setSttlCurrency(sttlCurrency);
		operation.setDisputeId(disputeId);

		copyParticipantToIncomingOperation(operation, participantType);
		return operation;
	}

	public ru.bpc.sv2.operations.incoming.Operation toOperation(String participantType) {
		return getIncomingOperation(participantType);
	}

	public ru.bpc.sv2.operations.incoming.Operation toAcqOperation() {
		return getIncomingOperation(Participant.ACQ_PARTICIPANT);
	}

	public ru.bpc.sv2.operations.incoming.Operation toIssOperation() {
		return getIncomingOperation(Participant.ISS_PARTICIPANT);
	}

	public ru.bpc.sv2.operations.incoming.Operation toDestOperation() {
		return getIncomingOperation(Participant.DESTINATION_PARTICIPANT);
	}

	public ru.bpc.sv2.operations.incoming.Operation toAggrOperation() {
		return getIncomingOperation(Participant.PAYMENT_AGGREGATOR_PARTICIPANT);
	}

	public ru.bpc.sv2.operations.incoming.Operation toOperation() {
		return getIncomingOperation(null);
	}

	public void copyParticipantToIncomingOperation(ru.bpc.sv2.operations.incoming.Operation operation, String participantType) {
		if (StringUtils.isBlank(participantType)) {
			return;
		}

		Participant participant = findParticipant(participantType);
		if (participant == null) {
			operation.setParticipantType(participantType);
			operation.setClientIdValue(getClientIdValue());
			operation.setClientIdType(getClientIdType());
			operation.setIssInstId(getIssInstId());
			operation.setIssNetworkId(getIssNetworkId());

			operation.setCardNetworkId(getCardNetworkId());

			operation.setCustomerId(getCustomerId());
			operation.setAccountNumber(getAccountNumber());
			operation.setMerchantNumber(getMerchantNumber());
		} else {
			operation.setParticipantType(participant.getParticipantType());
			operation.setClientIdValue(participant.getClientIdValue());
			operation.setClientIdType(participant.getClientIdType());
			operation.setIssInstId(participant.getInstId());
			operation.setIssNetworkId(participant.getNetworkId());

			operation.setCardInstId(participant.getCardInstId());
			operation.setCardNetworkId(participant.getCardNetworkId());
			operation.setCardId(participant.getCardId());
			operation.setCardInstanceId(participant.getCardInstanceId());
			operation.setCardTypeId(participant.getCardTypeId());
			operation.setCardNumber(participant.getCardNumber());
			operation.setCardMask(participant.getCardMask());
			operation.setCardHash(participant.getCardHash());
			operation.setCardSeqNumber(participant.getCardSeqNumber());
			operation.setCardExpirationDate(participant.getCardExpirDate());
			operation.setCardCountry(participant.getCardCountry());

			operation.setCustomerId(participant.getCustomerId());
			operation.setAccountId(participant.getAccountId());
			operation.setAccountType(participant.getAccountType());
			operation.setAccountNumber(participant.getAccountNumber());
			operation.setAccountAmount(participant.getAccountAmount());
			operation.setAccountCurrency(participant.getAccountCurrency());
			operation.setSplitHash(participant.getSplitHash());
			operation.setMerchantId(participant.getMerchantId());
		}
	}

	private Participant findParticipant(String participantType) {
		Participant p = getParticipantData();
		if (p != null && participantType.equals(p.getParticipantType())) {
			return p;
		}

		if (getParticipants() == null) {
			return null;
		}

		for(Participant participant: getParticipants()) {
			if (participant != null && participantType.equals(participant.getParticipantType())) {
				return participant;
			}
		}
		return null;
	}
}

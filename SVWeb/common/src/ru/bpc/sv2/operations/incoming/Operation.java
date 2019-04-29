package ru.bpc.sv2.operations.incoming;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.xml.bind.annotation.XmlType;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.operations.Participant;

@XmlType(name = "oper", namespace = "ru.bpc.sv2.operations.incoming")
public class Operation implements Serializable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer splitHash;
	private Long sessionId;
    private Long sessionFileId;
	private boolean reversal;
	private Long originalId;
	private String operType;
	private String operReason;
	private String msgType;
	private String status;
	private String statusReason;
	private String sttlType;
	
	private Integer acqInstId;
	private Integer acqNetworkId;
	private Integer splitHashAcq;

	private String newOperStatus;
    private Date hostDateFrom;
    private Date hostDateTo;
    private String externalAuthId;

	private String terminalType;
	
	private String acqInstBin;	
	private String forwInstBin;
	
	private Integer merchantId;
	private String merchantNumber;
	private Integer terminalId;
	private String terminalNumber;
	private String merchantName;
	private String merchantStreet;
	private String merchantCity;
	private String merchantRegion;
	private String merchantCountryCode;
	private String merchantPostCode;
	private String mccCode;
	
	private String refnum;
	private String networkRefnum;
	private String authCode;
	
	private BigDecimal operationRequestAmount;
	private BigDecimal operationAmount;
	private String operationCurrency;
	
	private BigDecimal operationCashbackAmount;
	private BigDecimal operationReplacementAmount;
	private BigDecimal operationSurchargeAmount;
	
	private Date operationDate;
	private Date sourceHostDate;
	private Date sttlDate;
	
	private Integer issInstId;
	private Integer issNetworkId;
	private Integer splitHashIss;
	
	private Long cardInstanceId;
	private Integer cardInstId;
	private Integer cardNetworkId;
	private String cardNumber;
	private Long cardId;
	private Integer cardTypeId;
	private String cardMask;
	private Long cardHash;
	private Integer cardSeqNumber;
	private Date cardExpirationDate;
	private String cardCountry;
	
	private Long accountId;
	private String participantType;
	private String accountType;
	private String accountNumber;
	private BigDecimal accountAmount;
	private String accountCurrency;
	private String matchStatus;
	private Long matchId;
	private Long authId;
	
	private Long operCount;
	private BigDecimal sttlAmount;
	private String sttlCurrency;	
	private Long disputeId;
	private Long customerId;
	
	private String clientIdType;
	private String clientIdValue;
	private String command;
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public boolean isReversal() {
		return reversal;
	}

	public void setReversal(boolean reversal) {
		this.reversal = reversal;
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

	public Integer getAcqInstId() {
		return acqInstId;
	}

	public void setAcqInstId(Integer acqInstId) {
		this.acqInstId = acqInstId;
	}

	public Integer getAcqNetworkId() {
		return acqNetworkId;
	}

	public void setAcqNetworkId(Integer acqNetworkId) {
		this.acqNetworkId = acqNetworkId;
	}

	public Integer getSplitHashAcq() {
		return splitHashAcq;
	}

	public void setSplitHashAcq(Integer splitHashAcq) {
		this.splitHashAcq = splitHashAcq;
	}

	public String getTerminalType() {
		return terminalType;
	}

	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
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

	public Integer getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(Integer merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantNumber() {
		return merchantNumber;
	}

	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public Integer getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
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

	public String getMerchantCountryCode() {
		return merchantCountryCode;
	}

	public void setMerchantCountryCode(String merchantCountryCode) {
		this.merchantCountryCode = merchantCountryCode;
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

	public String getRefnum() {
		return refnum;
	}

	public void setRefnum(String refnum) {
		this.refnum = refnum;
	}

	public String getNetworkRefnum() {
		return networkRefnum;
	}

	public void setNetworkRefnum(String networkRefnum) {
		this.networkRefnum = networkRefnum;
	}

	public String getAuthCode() {
		return authCode;
	}

	public void setAuthCode(String authCode) {
		this.authCode = authCode;
	}

	public BigDecimal getOperationRequestAmount() {
		return operationRequestAmount;
	}

	public void setOperationRequestAmount(BigDecimal operationRequestAmount) {
		this.operationRequestAmount = operationRequestAmount;
	}

	public BigDecimal getOperationAmount() {
		return operationAmount;
	}

	public void setOperationAmount(BigDecimal operationAmount) {
		this.operationAmount = operationAmount;
	}

	public String getOperationCurrency() {
		return operationCurrency;
	}

	public void setOperationCurrency(String operationCurrency) {
		this.operationCurrency = operationCurrency;
	}

	public BigDecimal getOperationCashbackAmount() {
		return operationCashbackAmount;
	}

	public void setOperationCashbackAmount(BigDecimal operationCashbackAmount) {
		this.operationCashbackAmount = operationCashbackAmount;
	}

	public BigDecimal getOperationReplacementAmount() {
		return operationReplacementAmount;
	}

	public void setOperationReplacementAmount(BigDecimal operationReplacementAmount) {
		this.operationReplacementAmount = operationReplacementAmount;
	}

	public BigDecimal getOperationSurchargeAmount() {
		return operationSurchargeAmount;
	}

	public void setOperationSurchargeAmount(BigDecimal operationSurchargeAmount) {
		this.operationSurchargeAmount = operationSurchargeAmount;
	}

	public Date getOperationDate() {
		return operationDate;
	}

	public void setOperationDate(Date operationDate) {
		this.operationDate = operationDate;
	}

	public Date getSourceHostDate() {
		return sourceHostDate;
	}

	public void setSourceHostDate(Date sourceHostDate) {
		this.sourceHostDate = sourceHostDate;
	}

	public Date getSttlDate() {
		return sttlDate;
	}

	public void setSttlDate(Date sttlDate) {
		this.sttlDate = sttlDate;
	}

	public Integer getIssInstId() {
		return issInstId;
	}

	public void setIssInstId(Integer issInstId) {
		this.issInstId = issInstId;
	}

	public Integer getIssNetworkId() {
		return issNetworkId;
	}

	public void setIssNetworkId(Integer issNetworkId) {
		this.issNetworkId = issNetworkId;
	}

	public Integer getSplitHashIss() {
		return splitHashIss;
	}

	public void setSplitHashIss(Integer splitHashIss) {
		this.splitHashIss = splitHashIss;
	}

	public Integer getCardInstId() {
		return cardInstId;
	}

	public void setCardInstId(Integer cardInstId) {
		this.cardInstId = cardInstId;
	}

	public Integer getCardNetworkId() {
		return cardNetworkId;
	}

	public void setCardNetworkId(Integer cardNetworkId) {
		this.cardNetworkId = cardNetworkId;
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

	public Integer getCardTypeId() {
		return cardTypeId;
	}

	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public String getCardMask() {
		return cardMask;
	}

	public void setCardMask(String cardMask) {
		this.cardMask = cardMask;
	}

	public Long getCardHash() {
		return cardHash;
	}

	public void setCardHash(Long cardHash) {
		this.cardHash = cardHash;
	}

	public Integer getCardSeqNumber() {
		return cardSeqNumber;
	}

	public void setCardSeqNumber(Integer cardSeqNumber) {
		this.cardSeqNumber = cardSeqNumber;
	}

	public Date getCardExpirationDate() {
		return cardExpirationDate;
	}

	public void setCardExpirationDate(Date cardExpirationDate) {
		this.cardExpirationDate = cardExpirationDate;
	}

	public String getCardCountry() {
		return cardCountry;
	}

	public void setCardCountry(String cardCountry) {
		this.cardCountry = cardCountry;
	}

	public String getAccountType() {
		return accountType;
	}

	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public String getAccountNumber() {
		return accountNumber;
	}

	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	public BigDecimal getAccountAmount() {
		return accountAmount;
	}

	public void setAccountAmount(BigDecimal accountAmount) {
		this.accountAmount = accountAmount;
	}

	public String getAccountCurrency() {
		return accountCurrency;
	}

	public void setAccountCurrency(String accountCurrency) {
		this.accountCurrency = accountCurrency;
	}

	public String getMatchStatus() {
		return matchStatus;
	}

	public void setMatchStatus(String matchStatus) {
		this.matchStatus = matchStatus;
	}

	public Long getAuthId() {
		return authId;
	}

	public void setAuthId(Long authId) {
		this.authId = authId;
	}

	public Long getOperCount() {
		return operCount;
	}

	public void setOperCount(Long operCount) {
		this.operCount = operCount;
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

	public Long getDisputeId() {
		return disputeId;
	}

	public void setDisputeId(Long disputeId) {
		this.disputeId = disputeId;
	}

	public Long getCardInstanceId() {
		return cardInstanceId;
	}

	public void setCardInstanceId(Long cardInstanceId) {
		this.cardInstanceId = cardInstanceId;
	}

	public Long getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public String getParticipantType() {
		return participantType;
	}

	public void setParticipantType(String participantType) {
		this.participantType = participantType;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("msgType", getMsgType());
		result.put("operType", getOperType());
		result.put("participantType", getParticipantType());
		result.put("sourceHostDate", getSourceHostDate());
		result.put("issInstId", getIssInstId());
		result.put("issNetworkId", getIssNetworkId());
		result.put("cardInstId", getCardInstId());
		result.put("cardNetworkId", getCardNetworkId());
		result.put("cardId", getCardId());
		result.put("cardInstanceId", getCardInstanceId());
		result.put("cardTypeId", getCardTypeId());
		result.put("cardNumber", getCardNumber());
		result.put("cardMask", getCardMask());
		result.put("cardHash", getCardHash());
		result.put("cardSeqNumber", getCardSeqNumber());
		result.put("cardExpirationDate", getCardExpirationDate());
		result.put("cardCountry", getCardCountry());
		result.put("customerId", getCustomerId());
		result.put("accountId", getAccountId());
		result.put("accountType", getAccountType());
		result.put("accountNumber", getAccountNumber());
		result.put("accountAmount", getAccountAmount());
		result.put("splitHash", getSplitHash());
		
		result.put("reversal", isReversal());
		result.put("originalId", getOriginalId());
		result.put("operReason", getOperReason());
		result.put("status", getStatus());
		result.put("statusReason", getStatusReason());
		result.put("sttlType", getSttlType());
		result.put("terminalType", getTerminalType());
		result.put("acqInstBin", getAcqInstBin());
		result.put("forwInstBin", getForwInstBin());
		result.put("merchantNumber", getMerchantNumber());
		result.put("terminalNumber", getTerminalNumber());
		result.put("merchantName", getMerchantName());
		result.put("merchantStreet", getMerchantStreet());
		result.put("merchantCity", getMerchantCity());
		result.put("merchantRegion", getMerchantRegion());
		result.put("merchantCountryCode", getMerchantCountryCode());
		result.put("merchantPostCode", getMerchantPostCode());
		result.put("mccCode", getMccCode());
		result.put("refnum", getRefnum());
		result.put("networkRefnum", getNetworkRefnum());
		result.put("operCount", getOperCount());
		result.put("operationRequestAmount", getOperationRequestAmount());
		result.put("operationAmount", getOperationAmount());
		result.put("operationCurrency", getOperationCurrency());
		result.put("operationCashbackAmount", getOperationCashbackAmount());
		result.put("operationReplacementAmount", getOperationReplacementAmount());
		result.put("operationSurchargeAmount", getOperationSurchargeAmount());
		result.put("operationDate", getOperationDate());
		result.put("sourceHostDate", getSourceHostDate());
		result.put("matchStatus", getMatchStatus());
        result.put("matchId", getMatchId());
		result.put("sttlAmount", getSttlAmount());
		result.put("sttlCurrency", getSttlCurrency());
		result.put("disputeId", getDisputeId());
        result.put("command", getCommand());

		return result;
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

    public Long getMatchId() {
        return matchId;
    }

    public void setMatchId(Long matchId) {
        this.matchId = matchId;
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

    public String getExternalAuthId() {
        return externalAuthId;
    }

    public void setExternalAuthId(String externalAuthId) {
        this.externalAuthId = externalAuthId;
    }


    public void fillParticipant(Participant participant) {
	    setParticipantType(participant.getParticipantType());
	    setClientIdType(participant.getClientIdType());
	    setClientIdValue(participant.getClientIdValue());
	    setIssInstId(participant.getInstId());
	    setIssNetworkId(participant.getNetworkId());
	    setCardInstId(participant.getCardInstId());
	    setCardNetworkId(participant.getCardNetworkId());
	    setCardId(participant.getCardId());
	    setCardInstanceId(participant.getCardInstanceId());
	    setCardTypeId(participant.getCardTypeId());
	    setCardNumber(participant.getCardNumber());
	    setCardHash(participant.getCardHash());
	    setCardSeqNumber(participant.getCardSeqNumber());
	    setCardExpirationDate(participant.getCardExpirDate());
	    setCardCountry(participant.getCardCountry());
	    setCustomerId(participant.getCustomerId());
	    setAccountId(participant.getAccountId());
    }
}

package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Participant implements Serializable, ModelIdentifiable {
	private static final long serialVersionUID = 1L;

	public static final String ACQ_PARTICIPANT = "PRTYACQ";
	public static final String ISS_PARTICIPANT = "PRTYISS";
	public static final String DESTINATION_PARTICIPANT = "PRTYDST";
	public static final String PAYMENT_AGGREGATOR_PARTICIPANT = "PRTYPAGR";

	private Long operId;
	private String participantType;
	private Integer instId;
	private Integer networkId;
	private Integer splitHash;
	private String clientIdType;
	private String clientIdValue;
	private Long customerId;
	private String customerName;
	private String customerNumber;
	private String authCode;
	private Long cardId;
	private Long cardInstanceId;
	private Integer cardTypeId;
	private String cardMask;
	private String cardToken;
	private Long cardHash;
	private Integer cardSeqNumber;
	private Date cardExpirDate;
	private String cardServiceCode;
	private String cardCountry;
	private Integer cardNetworkId;
	private Integer cardInstId;
	private Long accountId;
	private String accountType;
	private String accountNumber;
	private BigDecimal accountAmount;
	private String accountCurrency;
	private Integer merchantId;
	private Integer terminalId;

	private String instName;
	private String networkName;
	private String cardInstName;
	private String cardNetworkName;
	private String cardTypeName;
	private String cardNumber;

	public Object getModelId() {
		return operId + participantType;
	}

	public Long getOperId() {
		return operId;
	}
	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public String getParticipantType() {
		return participantType;
	}
	public void setParticipantType(String participantType) {
		this.participantType = participantType;
	}

	public boolean isAcquirer() {
		return ACQ_PARTICIPANT.equals(getParticipantType());
	}
	public boolean isIssuer() {
		return ISS_PARTICIPANT.equals(getParticipantType());
	}
	public boolean isDestination() {
		return DESTINATION_PARTICIPANT.equals(getParticipantType());
	}
	public boolean isAggregator() {
		return PAYMENT_AGGREGATOR_PARTICIPANT.equals(getParticipantType());
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getNetworkId() {
		return networkId;
	}
	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
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

	public Long getCustomerId() {
		return customerId;
	}
	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public String getAuthCode() {
		return authCode;
	}
	public void setAuthCode(String authCode) {
		this.authCode = authCode;
	}

	public Long getCardId() {
		return cardId;
	}
	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}

	public Long getCardInstanceId() {
		return cardInstanceId;
	}
	public void setCardInstanceId(Long cardInstanceId) {
		this.cardInstanceId = cardInstanceId;
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

	public String getCardToken() {
		return cardToken;
	}
	public void setCardToken(String cardToken) {
		this.cardToken = cardToken;
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

	public Date getCardExpirDate() {
		return cardExpirDate;
	}
	public void setCardExpirDate(Date cardExpirDate) {
		this.cardExpirDate = cardExpirDate;
	}

	public String getCardServiceCode() {
		return cardServiceCode;
	}
	public void setCardServiceCode(String cardServiceCode) {
		this.cardServiceCode = cardServiceCode;
	}

	public String getCardCountry() {
		return cardCountry;
	}
	public void setCardCountry(String cardCountry) {
		this.cardCountry = cardCountry;
	}

	public Integer getCardNetworkId() {
		return cardNetworkId;
	}
	public void setCardNetworkId(Integer cardNetworkId) {
		this.cardNetworkId = cardNetworkId;
	}

	public Integer getCardInstId() {
		return cardInstId;
	}
	public void setCardInstId(Integer cardInstId) {
		this.cardInstId = cardInstId;
	}

	public Long getAccountId() {
		return accountId;
	}
	public void setAccountId(Long accountId) {
		this.accountId = accountId;
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

	public Integer getMerchantId() {
		return merchantId;
	}
	public void setMerchantId(Integer merchantId) {
		this.merchantId = merchantId;
	}

	public Integer getTerminalId() {
		return terminalId;
	}
	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getNetworkName() {
		return networkName;
	}
	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	public String getCardInstName() {
		return cardInstName;
	}
	public void setCardInstName(String cardInstName) {
		this.cardInstName = cardInstName;
	}

	public String getCardNetworkName() {
		return cardNetworkName;
	}
	public void setCardNetworkName(String cardNetworkName) {
		this.cardNetworkName = cardNetworkName;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}
	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public String getCustomerNumber(){
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber){
		this.customerNumber = customerNumber;
	}
}

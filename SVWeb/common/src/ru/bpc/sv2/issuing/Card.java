package ru.bpc.sv2.issuing;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class Card implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer splitHash;
	private Long cardHash;
	private String mask;

	private Integer instId;
	private String instName;
	private Integer agentId;
	private String agentName;
	private String agentNumber;

	private Integer cardTypeId;
	private String cardTypeName;
	private String country;
	private Long cardholderId;
	private String cardholderName;
	private String cardholderNumber;
	private Integer productId;
	private String productName;
	private Date regDate;
	private Date expDate;
	private Long customerId;
	private Long merchantId;
	private String merchantName;
	private String category;
	private String cardNumber;
	private String cardUid;
	private Long contractId;
	private String contractNumber;
	private String contractType;
	private String customerNumber;
	private String customerType;
	private String custInfo;
	private String productType;

	private Long accountId;
	private String accountNumber;
	private Long authId;
	private String productNumber;
	private String surname;
	private String firstName;
	private String posDefaultAccount;
	private String atmDefaultAccount;
	private String cardStateDescr;
	private String cardStatusDescr;
	private String statusReason;

	private String deliveryAgentNumber;

	private Long cardInstanceId;

	@Deprecated
	private Cardholder holder;

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

	public Long getCardHash() {
		return cardHash;
	}
	public void setCardHash(Long cardHash) {
		this.cardHash = cardHash;
	}

	public String getMask() {
		return mask;
	}
	public void setMask(String mask) {
		this.mask = mask;
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

	public Integer getCardTypeId() {
		return cardTypeId;
	}
	public void setCardTypeId(Integer cardTypeId) {
		this.cardTypeId = cardTypeId;
	}

	public String getCardTypeName() {
		return cardTypeName;
	}
	public void setCardTypeName(String cardTypeName) {
		this.cardTypeName = cardTypeName;
	}

	public String getCountry() {
		return country;
	}
	public void setCountry(String country) {
		this.country = country;
	}

	public Long getCardholderId() {
		return cardholderId;
	}
	public void setCardholderId(Long cardholderId) {
		this.cardholderId = cardholderId;
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

	public Date getRegDate() {
		return regDate;
	}
	public void setRegDate(Date regDate) {
		this.regDate = regDate;
	}

	public Long getCustomerId() {
		return customerId;
	}
	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public Long getMerchantId() {
		return merchantId;
	}
	public void setMerchantId(Long merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantName() {
		return merchantName;
	}
	public void setMerchantName(String merchantName) {
		this.merchantName = merchantName;
	}

	public String getCategory() {
		return category;
	}
	public void setCategory(String category) {
		this.category = category;
	}

	public String getCardholderName() {
		return cardholderName;
	}
	public void setCardholderName(String cardholderName) {
		this.cardholderName = cardholderName;
	}

	public String getCardNumber() {
		return cardNumber;
	}
	public void setCardNumber(String cardNumber) {
		this.cardNumber = cardNumber;
	}

	public String getCardUid() {
		return cardUid;
	}
	public void setCardUid(String cardUid) {
		this.cardUid = cardUid;
	}

	public Long getAccountId() {
		return accountId;
	}
	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public String getAccountNumber() {
		return accountNumber;
	}
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
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

	public String getContractType() {
		return contractType;
	}
	public void setContractType(String contractType) {
		this.contractType = contractType;
	}

	public String getCardholderNumber() {
		return cardholderNumber;
	}
	public void setCardholderNumber(String cardholderNumber) {
		this.cardholderNumber = cardholderNumber;
	}

	@Deprecated
	public Cardholder getHolder() {
		return holder;
	}
	@Deprecated
	public void setHolder(Cardholder holder) {
		this.holder = holder;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}
	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}

	public String getProductType() {
		return productType;
	}
	public void setProductType(String productType) {
		this.productType = productType;
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

	public String getAgentName() {
		return agentName;
	}

	public void setAgentName(String agentName) {
		this.agentName = agentName;
	}

	public String getAgentNumber() {
		return agentNumber;
	}

	public void setAgentNumber(String agentNumber) {
		this.agentNumber = agentNumber;
	}

	public Date getExpDate() {
		return expDate;
	}
	public void setExpDate(Date expDate) {
		this.expDate = expDate;
	}

	public Long getAuthId() {
		return authId;
	}
	public void setAuthId(Long authId) {
		this.authId = authId;
	}

	public String getCustomerType() {
		return customerType;
	}
	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	public String getProductNumber() {
		return productNumber;
	}
	public void setProductNumber(String productNumber) {
		this.productNumber = productNumber;
	}

	public String getSurname() {
		return surname;
	}
	public void setSurname(String surname) {
		this.surname = surname;
	}

	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getPosDefaultAccount() {
		return posDefaultAccount;
	}
	public void setPosDefaultAccount(String posDefaultAccount) {
		this.posDefaultAccount = posDefaultAccount;
	}

	public String getAtmDefaultAccount() {
		return atmDefaultAccount;
	}
	public void setAtmDefaultAccount(String atmDefaultAccount) {
		this.atmDefaultAccount = atmDefaultAccount;
	}

	public String getCardStateDescr() {
		return cardStateDescr;
	}
	public void setCardStateDescr(String cardStateDescr) {
		this.cardStateDescr = cardStateDescr;
	}

	public String getCardStatusDescr() {
		return cardStatusDescr;
	}
	public void setCardStatusDescr(String cardStatusDescr) {
		this.cardStatusDescr = cardStatusDescr;
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	public String getDeliveryAgentNumber() {
		return deliveryAgentNumber;
	}

	public void setDeliveryAgentNumber(String deliveryAgentNumber) {
		this.deliveryAgentNumber = deliveryAgentNumber;
	}

	@Override
	public Object getModelId() {
		return getId() + getCardUid() + getInstId() + getAccountId();
	}
	@Override
	public Card clone() throws CloneNotSupportedException {
		return (Card) super.clone();
	}

	public Long getCardInstanceId() {
		return cardInstanceId;
	}

	public void setCardInstanceId(Long cardInstanceId) {
		this.cardInstanceId = cardInstanceId;
	}
}

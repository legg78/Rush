package ru.bpc.sv2.issuing;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CardDetails implements Serializable, ModelIdentifiable, Cloneable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Long id;
	private Long cardInstanceId;
	private String cardNumber;
	private String cardMask;
	private String seqNumber;
	private String expirDate;
	private String personName;
	private Long cardTypeId;
	private String nameCardType;
	private Long networkId;
	private String networkName;
	private String category;
	private String categoryName;
	private String status;
	private String statusName;
	private String state;
	private String stateName;
	private Date issDate;
	private Long agentId;
	private String agentName;
	private boolean isVirtual;
	private Long counterInvalidPin;

	@Override
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getCardInstanceId() {
		return cardInstanceId;
	}

	public void setCardInstanceId(Long cardInstanceId) {
		this.cardInstanceId = cardInstanceId;
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

	public String getSeqNumber() {
		return seqNumber;
	}

	public void setSeqNumber(String seqNumber) {
		this.seqNumber = seqNumber;
	}

	public String getExpirDate() {
		return expirDate;
	}

	public void setExpirDate(String expirDate) {
		this.expirDate = expirDate;
	}

	public String getPersonName() {
		return personName;
	}

	public void setPersonName(String personName) {
		this.personName = personName;
	}

	public Long getCardTypeId() {
		return cardTypeId;
	}

	public void setCardTypeId(Long card_type_id) {
		this.cardTypeId = card_type_id;
	}

	public String getNameCardType() {
		return nameCardType;
	}

	public void setNameCardType(String nameCardType) {
		this.nameCardType = nameCardType;
	}

	public Long getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Long networkId) {
		this.networkId = networkId;
	}

	public String getNetworkName() {
		return networkName;
	}

	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getCategoryName() {
		return categoryName;
	}

	public void setCategoryName(String categoryName) {
		this.categoryName = categoryName;
	}

	public String getStatusName() {
		return statusName;
	}

	public void setStatusName(String statusName) {
		this.statusName = statusName;
	}

	public String getState() {
		return state;
	}

	public void setState(String state) {
		this.state = state;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getStateName() {
		return stateName;
	}

	public void setStateName(String stateName) {
		this.stateName = stateName;
	}

	public Long getAgentId() {
		return agentId;
	}

	public void setAgentId(Long agentId) {
		this.agentId = agentId;
	}

	public Date getIssDate() {
		return issDate;
	}

	public void setIssDate(Date issDate) {
		this.issDate = issDate;
	}

	public String getAgentName() {
		return agentName;
	}

	public void setAgentName(String agentName) {
		this.agentName = agentName;
	}

	public boolean isVirtual() {
		return isVirtual;
	}

	public void setVirtual(boolean isVirtual) {
		this.isVirtual = isVirtual;
	}

	public Long getCounterInvalidPin() {
		return counterInvalidPin;
	}

	public void setCounterInvalidPin(Long counterInvalidPin) {
		this.counterInvalidPin = counterInvalidPin;
	}

}
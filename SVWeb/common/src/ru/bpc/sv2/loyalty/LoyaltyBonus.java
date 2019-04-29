package ru.bpc.sv2.loyalty;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class LoyaltyBonus implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;
	
	private Long id;
	private Long accountId;
	private Long cardId;
	private Long productId;
	private Long serviceId;	
	private Date operDate;
	private Date postingDate;
	private Date startDate;
	private Date expireDate;
	private Double amount;
	private Double spentAmount;
	private String status;
	private Integer instId;
	private Integer splitHash;
	private Long customerId;
	private String currency;
	
	private String serviceLabel; // prd_ui_service_vw
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public Date getOperDate() {
		return operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	public Date getPostingDate() {
		return postingDate;
	}

	public void setPostingDate(Date postingDate) {
		this.postingDate = postingDate;
	}

	public Date getExpireDate() {
		return expireDate;
	}

	public void setExpireDate(Date expireDate) {
		this.expireDate = expireDate;
	}

	public Double getAmount() {
		return amount;
	}

	public void setAmount(Double amount) {
		this.amount = amount;
	}

	public Double getSpentAmount() {
		return spentAmount;
	}

	public void setSpentAmount(Double spentAmount) {
		this.spentAmount = spentAmount;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
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

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Long getCardId() {
		return cardId;
	}

	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}

	public Long getProductId() {
		return productId;
	}

	public void setProductId(Long productId) {
		this.productId = productId;
	}

	public Long getServiceId() {
		return serviceId;
	}

	public void setServiceId(Long serviceId) {
		this.serviceId = serviceId;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Long getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Long custumerId) {
		this.customerId = custumerId;
	}

	public String getServiceLabel() {
		return serviceLabel;
	}

	public void setServiceLabel(String serviceLabel) {
		this.serviceLabel = serviceLabel;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}
	
}


package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditPayment implements Serializable, ModelIdentifiable, Cloneable{
	private static final long serialVersionUID = 3482568244033666742L;

	private Long id;
	private Long operId;
	private Boolean isReversal;
	private Long originalOperId;
	private Long accountId;
	private Long cardId;
	private Integer productId;
	private Date postingDate;
	private Integer sttlDay;
	private String currency;
	private Double amount;
	private Double payAmount;
	private Boolean isNew;
	private String status;
	private Integer instId;
	private Integer agentId;
	private Integer splitHash;
	private String accountNumber;
	private String cardMask;
	private String cardNumber;
	private String institutionName;
	private Date operDate;
	private BigDecimal revertedAmount;

	private Date dateFrom;
	private Date dateTo;


	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getOperId() {
		return operId;
	}
	public void setOperId(Long operId) {
		this.operId = operId;
	}
	public Boolean getIsReversal() {
		return isReversal;
	}
	public void setIsReversal(Boolean isReversal) {
		this.isReversal = isReversal;
	}
	public Long getOriginalOperId() {
		return originalOperId;
	}
	public void setOriginalOperId(Long originalOperId) {
		this.originalOperId = originalOperId;
	}
	public Long getAccountId() {
		return accountId;
	}
	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}
	public Long getCardId() {
		return cardId;
	}
	public void setCardId(Long cardId) {
		this.cardId = cardId;
	}
	public Integer getProductId() {
		return productId;
	}
	public void setProductId(Integer productId) {
		this.productId = productId;
	}
	public Date getPostingDate() {
		return postingDate;
	}
	public void setPostingDate(Date postingDate) {
		this.postingDate = postingDate;
	}
	public Integer getSttlDay() {
		return sttlDay;
	}
	public void setSttlDay(Integer sttlDay) {
		this.sttlDay = sttlDay;
	}
	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}
	public Double getAmount() {
		return amount;
	}
	public void setAmount(Double amount) {
		this.amount = amount;
	}
	public Double getPayAmount() {
		return payAmount;
	}
	public void setPayAmount(Double payAmount) {
		this.payAmount = payAmount;
	}
	public Boolean getIsNew() {
		return isNew;
	}
	public void setIsNew(Boolean isNew) {
		this.isNew = isNew;
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
	public Integer getAgentId() {
		return agentId;
	}
	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}
	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}
	public String getAccountNumber() {
		return accountNumber;
	}
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
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
	public Object getModelId() {
		return getId();
	}
	public Date getDateFrom() {
		return dateFrom;
	}
	public void setDateFrom(Date dateFrom) {
		this.dateFrom = dateFrom;
	}
	public Date getDateTo() {
		return dateTo;
	}
	public void setDateTo(Date dateTo) {
		this.dateTo = dateTo;
	}
	public String getInstitutionName() {
		return institutionName;
	}
	public void setInstitutionName(String institutionName) {
		this.institutionName = institutionName;
	}
	public Date getOperDate() {
		return operDate;
	}
	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}
	public BigDecimal getRevertedAmount() {
		return revertedAmount;
	}
	public void setRevertedAmount(BigDecimal revertedAmount) {
		this.revertedAmount = revertedAmount;
	}
}

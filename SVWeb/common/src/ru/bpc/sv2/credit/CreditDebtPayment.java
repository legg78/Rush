package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditDebtPayment implements Serializable, ModelIdentifiable, Cloneable{
	private static final long serialVersionUID = 4082928901257728079L;

	private Long id;
	private Long debtId;
	private String balanceType;
	private Double paymentAmount;
	private Date effDate;
	private Integer splitHash;
	private Double debtPaymentAmount;
	private Boolean reversal;
	private Long originalOperationId;
	private Date postingDate;
	private Integer settlementDay;
	private String currency;
	private Double amount;
	private Boolean _new;
	private String status;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}
	public Long getDebtId() {
		return debtId;
	}
	public void setDebtId(Long debtId) {
		this.debtId = debtId;
	}
	public String getBalanceType() {
		return balanceType;
	}
	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}
	public Double getPaymentAmount() {
		return paymentAmount;
	}
	public void setPaymentAmount(Double paymentAmount) {
		this.paymentAmount = paymentAmount;
	}
	public Date getEffDate() {
		return effDate;
	}
	public void setEffDate(Date effDate) {
		this.effDate = effDate;
	}
	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}
	public Object getModelId() {
		return getId();
	}
	public Double getDebtPaymentAmount() {
		return debtPaymentAmount;
	}
	public void setDebtPaymentAmount(Double debtPaymentAmount) {
		this.debtPaymentAmount = debtPaymentAmount;
	}
	public Boolean getReversal() {
		return reversal;
	}
	public void setReversal(Boolean reversal) {
		this.reversal = reversal;
	}
	public Long getOriginalOperationId() {
		return originalOperationId;
	}
	public void setOriginalOperationId(Long originalOperationId) {
		this.originalOperationId = originalOperationId;
	}
	public Date getPostingDate() {
		return postingDate;
	}
	public void setPostingDate(Date postingDate) {
		this.postingDate = postingDate;
	}
	public Integer getSettlementDay() {
		return settlementDay;
	}
	public void setSettlementDay(Integer settlementDay) {
		this.settlementDay = settlementDay;
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
	public Boolean getNew() {
		return _new;
	}
	public void setNew(Boolean new1) {
		_new = new1;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}
	public static long getSerialversionuid() {
		return serialVersionUID;
	}

}

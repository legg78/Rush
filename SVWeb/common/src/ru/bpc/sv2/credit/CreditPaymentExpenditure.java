package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditPaymentExpenditure implements Serializable, ModelIdentifiable, Cloneable{
	private static final long serialVersionUID = -3489979004185105262L;

	private Long id;
	private Long debtId;
	private String balanceType;
	private Long payId;
	private Long debtPayAmount;
	private Date effDate;
	private String operType;
	private Date operDate;
	private Date postingDate;
	private Integer sttlDay;
	private String currency;
	private Long amount;
	private Long debtAmount;
	private String status;
	private Long operId;

	public Object getModelId() {
		return getId();
	}

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
	public Long getPayId() {
		return payId;
	}
	public void setPayId(Long payId) {
		this.payId = payId;
	}
	public Long getDebtPayAmount() {
		return debtPayAmount;
	}
	public void setDebtPayAmount(Long debtPayAmount) {
		this.debtPayAmount = debtPayAmount;
	}
	public Date getEffDate() {
		return effDate;
	}
	public void setEffDate(Date effDate) {
		this.effDate = effDate;
	}
	public String getOperType() {
		return operType;
	}
	public void setOperType(String operType) {
		this.operType = operType;
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
	public Long getAmount() {
		return amount;
	}
	public void setAmount(Long amount) {
		this.amount = amount;
	}
	public Long getDebtAmount() {
		return debtAmount;
	}
	public void setDebtAmount(Long debtAmount) {
		this.debtAmount = debtAmount;
	}
	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
	}

}

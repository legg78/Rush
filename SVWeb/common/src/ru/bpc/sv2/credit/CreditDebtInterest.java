package ru.bpc.sv2.credit;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class CreditDebtInterest implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = -4117715606709062538L;

	private Long id;
	private Long debtId;
	private String balanceType;
	private Date startDate;
	private Date endDate;
	private BigDecimal duration;
	private Double amount;
	private Double minAmountDue;
	private Double interestAmount;
	private Integer feeId;
	private Integer addFeeId;
	private String feeDesc;
	private String addFeeDesc;
	private Boolean charged;
	private Boolean graceEnable;
	private Long accountId;
	private Long invoiceId;
	private Integer splitHash;
	private Date invoiceDate;
	private String currency;
	private Long operId;
	private String operType;
	private Date operationDate;
	private Boolean waived ;

	public static long getSerialversionuid() {
		return serialVersionUID;
	}
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

	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public BigDecimal getDuration() {
		return duration;
	}
	public void setDuration(BigDecimal duration) {
		this.duration = duration;
	}

	public Date getEndDate() {
		return endDate;
	}
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public Double getAmount() {
		return amount;
	}
	public void setAmount(Double amount) {
		this.amount = amount;
	}

	public Double getMinAmountDue() {
		return minAmountDue;
	}
	public void setMinAmountDue(Double minAmountDue) {
		this.minAmountDue = minAmountDue;
	}

	public Double getInterestAmount() {
		return interestAmount;
	}
	public void setInterestAmount(Double interestAmount) {
		this.interestAmount = interestAmount;
	}

	public Integer getFeeId() {
		return feeId;
	}
	public void setFeeId(Integer feeId) {
		this.feeId = feeId;
	}

	public String getFeeDesc() {
		return feeDesc;
	}
	public void setFeeDesc(String feeDesc) {
		this.feeDesc = feeDesc;
	}

	public Boolean getCharged() {
		return charged;
	}
	public void setCharged(Boolean charged) {
		this.charged = charged;
	}

	public Boolean getGraceEnable() {
		return graceEnable;
	}
	public void setGraceEnable(Boolean graceEnable) {
		this.graceEnable = graceEnable;
	}

	public Long getAccountId() {
		return accountId;
	}
	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public Long getInvoiceId() {
		return invoiceId;
	}
	public void setInvoiceId(Long invoiceId) {
		this.invoiceId = invoiceId;
	}

	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Date getInvoiceDate() {
		return invoiceDate;
	}
	public void setInvoiceDate(Date invoiceDate) {
		this.invoiceDate = invoiceDate;
	}

	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Integer getAddFeeId() {
		return addFeeId;
	}
	public void setAddFeeId(Integer addFeeId) {
		this.addFeeId = addFeeId;
	}

	public String getAddFeeDesc() {
		return addFeeDesc;
	}
	public void setAddFeeDesc(String addFeeDesc) {
		this.addFeeDesc = addFeeDesc;
	}

	public Long getOperId() {
		return operId;
	}
	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public String getOperType() {
		return operType;
	}
	public void setOperType(String operType) {
		this.operType = operType;
	}

	public Date getOperationDate() {
		return operationDate;
	}
	public void setOperationDate(Date operationDate) {
		this.operationDate = operationDate;
	}

	public Boolean getWaived() {
		return waived;
	}
	public void setWaived(Boolean waived) {
		this.waived = waived;
	}
}

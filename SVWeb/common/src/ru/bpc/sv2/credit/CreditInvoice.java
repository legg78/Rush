package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditInvoice implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long accountId;
	private String accountNumber;
	private String currency;
	private Integer serialNumber;
	private Date invoiceDate;
	private String type;
	private BigDecimal minAmountDue;
	private BigDecimal totalAmountDue;
	private BigDecimal ownFunds;
	private BigDecimal exceedLimit;
	private Date dueDate;
	private Date graceDate;
	private Date penaltyDate;
	private Date startDate;
	private Boolean madPaid;
	private Boolean tadPaid;
	private Integer agentId;
	private Integer instId;
	private Integer aging;
	private String agingName;
	private Date invoiceDateFrom;
	private Date invoiceDateTo;
	private Date statementDate;
	private String customerName;
	private String customerAddress;
	private Date beginDate;
	private Date endDate;
	private BigDecimal totalIncome;
	private BigDecimal totalExpenses;
	private BigDecimal interestAmount;
	private BigDecimal feeAmount;
	private BigDecimal overdueAmount;
	private BigDecimal overdueInterestAmount;
	private BigDecimal penaltyFeeAmount;
	private BigDecimal incomingDebt;
	private BigDecimal outgoingDebt;
	private BigDecimal annualPercentageRate;
	private BigDecimal internalRateReturn;

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

	public String getAccountNumber() {
		return accountNumber;
	}
	public void setAccountNumber(String accountNumber) {
		this.accountNumber = accountNumber;
	}

	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Integer getSerialNumber() {
		return serialNumber;
	}
	public void setSerialNumber(Integer serialNumber) {
		this.serialNumber = serialNumber;
	}

	public Date getInvoiceDate() {
		return invoiceDate;
	}
	public void setInvoiceDate(Date invoiceDate) {
		this.invoiceDate = invoiceDate;
	}

	public String getType() {
		return type;
	}
	public void setType(String type) {
		this.type = type;
	}

	public BigDecimal getMinAmountDue() {
		return minAmountDue;
	}
	public void setMinAmountDue(BigDecimal minAmountDue) {
		this.minAmountDue = minAmountDue;
	}

	public BigDecimal getTotalAmountDue() {
		return totalAmountDue;
	}
	public void setTotalAmountDue(BigDecimal totalAmountDue) {
		this.totalAmountDue = totalAmountDue;
	}

	public BigDecimal getOwnFunds() {
		return ownFunds;
	}
	public void setOwnFunds(BigDecimal ownFunds) {
		this.ownFunds = ownFunds;
	}

	public Date getDueDate() {
		return dueDate;
	}
	public void setDueDate(Date dueDate) {
		this.dueDate = dueDate;
	}

	public Date getGraceDate() {
		return graceDate;
	}
	public void setGraceDate(Date graceDate) {
		this.graceDate = graceDate;
	}

	public Date getPenaltyDate() {
		return penaltyDate;
	}
	public void setPenaltyDate(Date penaltyDate) {
		this.penaltyDate = penaltyDate;
	}

	public Boolean getMadPaid() {
		return madPaid;
	}
	public void setMadPaid(Boolean madPaid) {
		this.madPaid = madPaid;
	}

	public Boolean getTadPaid() {
		return tadPaid;
	}
	public void setTadPaid(Boolean tadPaid) {
		this.tadPaid = tadPaid;
	}

	public Integer getAgentId() {
		return agentId;
	}
	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Date getInvoiceDateFrom() {
		return invoiceDateFrom;
	}
	public void setInvoiceDateFrom(Date invoiceDateFrom) {
		this.invoiceDateFrom = invoiceDateFrom;
	}

	public Date getInvoiceDateTo() {
		return invoiceDateTo;
	}
	public void setInvoiceDateTo(Date invoiceDateTo) {
		this.invoiceDateTo = invoiceDateTo;
	}
	
	public Integer getAging() {
		return aging;
	}
	public void setAging(Integer aging) {
		this.aging = aging;
	}

	public String getAgingName() {
		if(agingName == null || agingName.trim().isEmpty())
			return null;
		return agingName;
	}

	public void setAgingName(String agingName) {
		this.agingName = agingName;
	}

	public BigDecimal getExceedLimit() {
		return exceedLimit;
	}
	public void setExceedLimit(BigDecimal exceedLimit) {
		this.exceedLimit = exceedLimit;
	}

	public Date getStartDate() {
		return startDate;
	}
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getStatementDate() {
		return statementDate;
	}
	public void setStatementDate(Date statementDate) {
		this.statementDate = statementDate;
	}

	public String getCustomerName() {
		return customerName;
	}
	public void setCustomerName(String customerName) {
		this.customerName = customerName;
	}

	public String getCustomerAddress() {
		return customerAddress;
	}
	public void setCustomerAddress(String customerAddress) {
		this.customerAddress = customerAddress;
	}

	public Date getBeginDate() {
		return beginDate;
	}
	public void setBeginDate(Date beginDate) {
		this.beginDate = beginDate;
	}

	public Date getEndDate() {
		return endDate;
	}
	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public BigDecimal getTotalIncome() {
		return totalIncome;
	}
	public void setTotalIncome(BigDecimal totalIncome) {
		this.totalIncome = totalIncome;
	}

	public BigDecimal getTotalExpenses() {
		return totalExpenses;
	}
	public void setTotalExpenses(BigDecimal totalExpenses) {
		this.totalExpenses = totalExpenses;
	}

	public BigDecimal getInterestAmount() {
		return interestAmount;
	}
	public void setInterestAmount(BigDecimal interestAmount) {
		this.interestAmount = interestAmount;
	}

	public BigDecimal getFeeAmount() {
		return feeAmount;
	}
	public void setFeeAmount(BigDecimal feeAmount) {
		this.feeAmount = feeAmount;
	}

	public BigDecimal getOverdueAmount() {
		return overdueAmount;
	}
	public void setOverdueAmount(BigDecimal overdueAmount) {
		this.overdueAmount = overdueAmount;
	}

	public BigDecimal getOverdueInterestAmount() {
		return overdueInterestAmount;
	}
	public void setOverdueInterestAmount(BigDecimal overdueInterestAmount) {
		this.overdueInterestAmount = overdueInterestAmount;
	}

	public BigDecimal getPenaltyFeeAmount() {
		return penaltyFeeAmount;
	}
	public void setPenaltyFeeAmount(BigDecimal penaltyFeeAmount) {
		this.penaltyFeeAmount = penaltyFeeAmount;
	}

	public BigDecimal getIncomingDebt() {
		return incomingDebt;
	}
	public void setIncomingDebt(BigDecimal incomingDebt) {
		this.incomingDebt = incomingDebt;
	}

	public BigDecimal getOutgoingDebt() {
		return outgoingDebt;
	}
	public void setOutgoingDebt(BigDecimal outgoingDebt) {
		this.outgoingDebt = outgoingDebt;
	}

	public BigDecimal getAnnualPercentageRate() {
		return annualPercentageRate;
	}

	public void setAnnualPercentageRate(BigDecimal annualPercentageRate) {
		this.annualPercentageRate = annualPercentageRate;
	}

	public BigDecimal getInternalRateReturn() {
		return internalRateReturn;
	}

	public void setInternalRateReturn(BigDecimal internalRateReturn) {
		this.internalRateReturn = internalRateReturn;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}

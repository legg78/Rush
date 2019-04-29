package ru.bpc.sv2.credit;


import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class CreditDebtBalance implements Serializable, ModelIdentifiable, Cloneable{
    private static final long serialVersionUID = 6407196769404361552L;

    private Long id;
    private Long debtId;
    private String balanceType;
    private BigDecimal balanceAmount;
    private Long debtIntrId;
    private Integer repayPriority;
    private BigDecimal minAmountDue;
    private Integer splitHash;
    private String currency;
    
    private Long operationId;
	private String operType;
    private Date settlementDate;
    private Date operDate;
	private BigDecimal amount;
	private BigDecimal debtAmount;
    private Integer macrosTypeId;
    private String macrosTypeName;
    private String amountPurpose;
    private String status;
    private BigDecimal operAmount;
    private String operCurrency;
    private Long accountId;
	private String feeType;
	private Long invoiceId;
    
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

	public BigDecimal getBalanceAmount() {
		return balanceAmount;
	}

	public void setBalanceAmount(BigDecimal balanceAmount) {
		this.balanceAmount = balanceAmount;
	}

	public Long getDebtIntrId() {
		return debtIntrId;
	}

	public void setDebtIntrId(Long debtIntrId) {
		this.debtIntrId = debtIntrId;
	}

	public Integer getRepayPriority() {
		return repayPriority;
	}

	public void setRepayPriority(Integer repayPriority) {
		this.repayPriority = repayPriority;
	}

	public BigDecimal getMinAmountDue() {
		return minAmountDue;
	}

	public void setMinAmountDue(BigDecimal minAmountDue) {
		this.minAmountDue = minAmountDue;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Long getOperationId() {
		return operationId;
	}

	public void setOperationId(Long operationId) {
		this.operationId = operationId;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public Date getSettlementDate() {
		return settlementDate;
	}

	public void setSettlementDate(Date settlementDate) {
		this.settlementDate = settlementDate;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	public BigDecimal getDebtAmount() {
		return debtAmount;
	}

	public void setDebtAmount(BigDecimal debtAmount) {
		this.debtAmount = debtAmount;
	}

	public Integer getMacrosTypeId() {
		return macrosTypeId;
	}

	public void setMacrosTypeId(Integer macrosTypeId) {
		this.macrosTypeId = macrosTypeId;
	}

	public String getMacrosTypeName() {
		return macrosTypeName;
	}

	public void setMacrosTypeName(String macrosTypeName) {
		this.macrosTypeName = macrosTypeName;
	}

	public String getAmountPurpose() {
		return amountPurpose;
	}

	public void setAmountPurpose(String amountPurpose) {
		this.amountPurpose = amountPurpose;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public BigDecimal getOperAmount() {
		return operAmount;
	}

	public void setOperAmount(BigDecimal operAmount) {
		this.operAmount = operAmount;
	}

	public String getOperCurrency() {
		return operCurrency;
	}

	public void setOperCurrency(String operCurrency) {
		this.operCurrency = operCurrency;
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

	public Object getModelId() {
        return getId();
    }
	
	public String getFeeType() {
		return feeType;
	}

	public void setFeeType(String feeType) {
		this.feeType = feeType;
	}

	public Long getInvoiceId() {
		return invoiceId;
	}

	public void setInvoiceId(Long invoiceId) {
		this.invoiceId = invoiceId;
	}
}

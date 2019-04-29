package ru.bpc.sv2.credit;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class CreditInvoiceOperation implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;

    private Long invoiceId;
    private Date date;
    private String type;
    private BigDecimal income;
    private BigDecimal expenses;
    private BigDecimal credit;
    private BigDecimal repayment;
    private BigDecimal percent;
    private String description;

    public Long getInvoiceId() {
        return invoiceId;
    }
    public void setInvoiceId(Long invoiceId) {
        this.invoiceId = invoiceId;
    }

    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }

    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    public BigDecimal getIncome() {
        return income;
    }
    public void setIncome(BigDecimal income) {
        this.income = income;
    }

    public BigDecimal getExpenses() {
        return expenses;
    }
    public void setExpenses(BigDecimal expenses) {
        this.expenses = expenses;
    }

    public BigDecimal getCredit() {
        return credit;
    }
    public void setCredit(BigDecimal credit) {
        this.credit = credit;
    }

    public BigDecimal getRepayment() {
        return repayment;
    }
    public void setRepayment(BigDecimal repayment) {
        this.repayment = repayment;
    }

    public BigDecimal getPercent() {
        return percent;
    }
    public void setPercent(BigDecimal percent) {
        this.percent = percent;
    }

    public String getDescription() {
        return description;
    }
    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public Object getModelId() {
        return null;
    }
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
}

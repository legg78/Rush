package ru.bpc.sv2.credit;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;

public class CreditInvoiceAggregation implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;

    private Long invoiceId;
    private String type;
    private String typeName;
    private String currency;
    private Integer count;
    private BigDecimal amount;

    public Long getInvoiceId() {
        return invoiceId;
    }
    public void setInvoiceId(Long invoiceId) {
        this.invoiceId = invoiceId;
    }

    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    public String getTypeName() {
        return typeName;
    }
    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getCurrency() {
        return currency;
    }
    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public Integer getCount() {
        return count;
    }
    public void setCount(Integer count) {
        this.count = count;
    }

    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
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

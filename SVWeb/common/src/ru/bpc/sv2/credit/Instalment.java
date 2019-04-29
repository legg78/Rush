package ru.bpc.sv2.credit;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class Instalment implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;

    private Integer number;
    private Date date;
    private BigDecimal amount;
    private BigDecimal interest;

    public Integer getNumber() {
        return number;
    }
    public void setNumber(Integer number) {
        this.number = number;
    }

    public Date getDate() {
        return date;
    }
    public void setDate(Date date) {
        this.date = date;
    }

    public BigDecimal getAmount() {
        return amount;
    }
    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public BigDecimal getInterest() {
        return interest;
    }
    public void setInterest(BigDecimal interest) {
        this.interest = interest;
    }

    @Override
    public Object getModelId() {
        return getDate().getTime() + getNumber();
    }
}

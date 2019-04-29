package ru.bpc.sv2.ps.diners;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;

public class DinersFee implements Serializable, ModelIdentifiable, Cloneable{
    private static final long serialVersionUID = 1L;

    private Long id;
    private BigDecimal amount;
    private String currency;
    private String destinationCurrency;
    private BigDecimal percent;
    private Long sourceAmount;
    private Long type;

    public Long getId(){
        return this.id;
    }
    public void setId(Long id){
        this.id = id;
    }


    public BigDecimal getAmount(){
        return amount;
    }
    public void setAmount( BigDecimal amount ){
        this.amount = amount;
    }

    public String getCurrency(){
        return currency;
    }
    public void setCurrency( String currency ){
        this.currency = currency;
    }

    public String getDestinationCurrency(){
        return destinationCurrency;
    }
    public void setDestinationCurrency( String destinationCurrency ){
        this.destinationCurrency = destinationCurrency;
    }

    public BigDecimal getPercent(){
        return percent;
    }
    public void setPercent( BigDecimal percent ){
        this.percent = percent;
    }

    public Long getSourceAmount(){
        return sourceAmount;
    }
    public void setSourceAmount( Long sourceAmount ){
        this.sourceAmount = sourceAmount;
    }

    public Long getType(){
        return type;
    }
    public void setType( Long type ){
        this.type = type;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Object clone(){
        Object result = null;
        try {
            result = super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return result;
    }
}
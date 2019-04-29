package ru.bpc.sv2.application;


import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

public class ApplicationPriorityProduct implements Serializable, ModelIdentifiable, Cloneable{
    private static final long serialVersionUID = 1L;

    private String productNumber;
    private String productDescription;

    @Override
    public Object getModelId() {
        return getProductNumber() + getProductDescription();
    }
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }

    public String getProductNumber() {
        return productNumber;
    }

    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }

    public String getProductDescription() {
        return productDescription;
    }

    public void setProductDescription(String productDescription) {
        this.productDescription = productDescription;
    }

}


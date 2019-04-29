package ru.bpc.sv2.deliveries;

import java.io.Serializable;

/**
 * Created by Viktorov on 28.02.2017.
 */
public class DeliveryAmount implements Serializable {
    private static final long serialVersionUID = 1L;

    private String deliveryStatus;
    private Integer amount;

    public String getDeliveryStatus() {
        return deliveryStatus;
    }

    public void setDeliveryStatus(String deliveryStatus) {
        this.deliveryStatus = deliveryStatus;
    }

    public Integer getAmount() {
        return amount;
    }

    public void setAmount(Integer amount) {
        this.amount = amount;
    }
}

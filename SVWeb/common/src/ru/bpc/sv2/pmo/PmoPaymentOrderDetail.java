package ru.bpc.sv2.pmo;

import java.io.Serializable;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PmoPaymentOrderDetail implements ModelIdentifiable, Serializable, Cloneable  {

    private static final long serialVersionUID = 1L;

    private Long id;
    private Long orderId;
    private String entityType;
    private Long objectId;

    public Object getModelId() {
        return getId();
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getOrderId() {
        return orderId;
    }

    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public Long getObjectId() {
        return objectId;
    }

    public void setObjectId(Long objectId) {
        this.objectId = objectId;
    }

}

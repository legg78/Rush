package ru.bpc.sv2.loyalty;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class LoyaltyOperationRequest implements Serializable, ModelIdentifiable, Cloneable{

    private static final long serialVersionUID = 1L;

    private Integer instId;
    private Long merchantId;
    private String status;
    private String cardNumber;
    private String authCode;
    private Date startDate;
    private Date endDate;
    private Long spentOperationId;

    @Override
    public Object getModelId() {
        return merchantId + " " + cardNumber;
    }

    public Integer getInstId() {
        return instId;
    }

    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public Long getMerchantId() {
        return merchantId;
    }

    public void setMerchantId(Long merchantId) {
        this.merchantId = merchantId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getAuthCode() {
        return authCode;
    }

    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getEndDate() {
        return endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

    public Long getSpentOperationId() {
        return spentOperationId;
    }

    public void setSpentOperationId(Long spentOperationId) {
        this.spentOperationId = spentOperationId;
    }
}

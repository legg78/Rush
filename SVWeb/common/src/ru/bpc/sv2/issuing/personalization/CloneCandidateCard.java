package ru.bpc.sv2.issuing.personalization;

import java.io.Serializable;


public class CloneCandidateCard implements Serializable, Cloneable {
    private boolean checked; //need for UI.

    private Long batchId;
    private Long cardInstanceId;
    private String cardMask;
    private Long cardId;
    private boolean isRenewal;
    private String cardNumber;
    private String cardholderName;
    private Integer agentId;
    private Integer productId;
    private Integer cardTypeId;
    private Integer blankTypeId;
    private String persoPriority;

    public Long getBatchId() {
        return batchId;
    }

    public void setBatchId(Long batchId) {
        this.batchId = batchId;
    }

    public Long getCardInstanceId() {
        return cardInstanceId;
    }

    public void setCardInstanceId(Long cardInstanceId) {
        this.cardInstanceId = cardInstanceId;
    }

    public String getCardMask() {
        return cardMask;
    }

    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public Long getCardId() {
        return cardId;
    }

    public void setCardId(Long cardId) {
        this.cardId = cardId;
    }

    public boolean isRenewal() {
        return isRenewal;
    }

    public void setRenewal(boolean isRenewal) {
        this.isRenewal = isRenewal;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getCardholderName() {
        return cardholderName;
    }

    public void setCardholderName(String cardholderName) {
        this.cardholderName = cardholderName;
    }

    public Integer getAgentId() {
        return agentId;
    }

    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public Integer getCardTypeId() {
        return cardTypeId;
    }

    public void setCardTypeId(Integer cardTypeId) {
        this.cardTypeId = cardTypeId;
    }

    public Integer getBlankTypeId() {
        return blankTypeId;
    }

    public void setBlankTypeId(Integer blankTypeId) {
        this.blankTypeId = blankTypeId;
    }

    public String getPersoPriority() {
        return persoPriority;
    }

    public void setPersoPriority(String persoPriority) {
        this.persoPriority = persoPriority;
    }

    @Override
    public CloneCandidateCard clone() throws CloneNotSupportedException {
        return (CloneCandidateCard) super.clone();
    }

    public boolean getChecked() {
        return checked;
    }

    public void setChecked(boolean checked) {
        this.checked = checked;
    }
}

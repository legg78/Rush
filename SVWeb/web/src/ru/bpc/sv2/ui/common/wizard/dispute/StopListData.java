package ru.bpc.sv2.ui.common.wizard.dispute;

import java.util.Date;

public class StopListData implements Cloneable {
    private String cardNumber;
    private String cardMask;
    private String actionCode;
    private Integer purgeInDays;
    private Date purgeDate;
    private Boolean doNotPurge;
    private String eventType;
    private Long cardInstanceId;
    private String stopListType;
    private String regionList;
    private String product;

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getCardMask() {
        return cardMask;
    }
    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public String getActionCode() {
        return actionCode;
    }
    public void setActionCode(String actionCode) {
        this.actionCode = actionCode;
    }

    public Integer getPurgeInDays() {
        return purgeInDays;
    }
    public void setPurgeInDays(Integer purgeInDays) {
        this.purgeInDays = purgeInDays;
    }

    public Date getPurgeDate() {
        return purgeDate;
    }
    public void setPurgeDate(Date purgeDate) {
        this.purgeDate = purgeDate;
    }

    public Boolean getDoNotPurge() {
        return doNotPurge;
    }
    public void setDoNotPurge(Boolean doNotPurge) {
        this.doNotPurge = doNotPurge;
    }

    public String getEventType() {
        return eventType;
    }
    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public Long getCardInstanceId() {
        return cardInstanceId;
    }
    public void setCardInstanceId(Long cardInstanceId) {
        this.cardInstanceId = cardInstanceId;
    }

    public String getStopListType() {
        return stopListType;
    }
    public void setStopListType(String stopListType) {
        this.stopListType = stopListType;
    }

    public String getRegionList() {
        return regionList;
    }
    public void setRegionList(String regionList) {
        this.regionList = regionList;
    }

    public Boolean validate() {
        if (cardInstanceId == null) {
            return Boolean.FALSE;
        }
        if (stopListType == null || stopListType.isEmpty()) {
            return Boolean.FALSE;
        }
        if (eventType == null || eventType.isEmpty()) {
            return Boolean.FALSE;
        }
        if (actionCode == null || actionCode.isEmpty()) {
            return Boolean.FALSE;
        }
        if (purgeDate == null && !Boolean.TRUE.equals(doNotPurge)) {
            return Boolean.FALSE;
        }
        if (regionList != null && regionList.isEmpty()) {
            return Boolean.FALSE;
        }
        if (product != null && product.isEmpty()) {
            return Boolean.FALSE;
        }
        return Boolean.TRUE;
    }

    public String getProduct() {
        return product;
    }

    public void setProduct(String product) {
        this.product = product;
    }

    @Override
    public StopListData clone() throws CloneNotSupportedException {
        return (StopListData)super.clone();
    }
}

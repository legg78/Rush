package ru.bpc.sv2.application;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class StopList implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long cardInstanceId;
    private String cardNumber;
    private String cardMask;
    private Date cardExpDate;
    private Date purgeDate;
    private Date eventDate;
    private String regionList;
    private String eventType;
    private String eventTypeDesc;
    private String stopListType;
    private String stopListTypeDesc;
    private String reasonCode;
    private String reasonCodeDesc;
    private String status;
    private String statusDesc;
    private String lang;
    private String product;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getCardInstanceId() {
        return cardInstanceId;
    }
    public void setCardInstanceId(Long cardInstanceId) {
        this.cardInstanceId = cardInstanceId;
    }

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

    public Date getCardExpDate() {
        return cardExpDate;
    }
    public void setCardExpDate(Date cardExpDate) {
        this.cardExpDate = cardExpDate;
    }

    public Date getPurgeDate() {
        return purgeDate;
    }
    public void setPurgeDate(Date purgeDate) {
        this.purgeDate = purgeDate;
    }

    public Date getEventDate() {
        return eventDate;
    }
    public void setEventDate(Date eventDate) {
        this.eventDate = eventDate;
    }

    public String getRegionList() {
        return regionList;
    }
    public void setRegionList(String regionList) {
        this.regionList = regionList;
    }

    public String getEventType() {
        return eventType;
    }
    public void setEventType(String eventType) {
        this.eventType = eventType;
    }

    public String getEventTypeDesc() {
        return eventTypeDesc;
    }
    public void setEventTypeDesc(String eventTypeDesc) {
        this.eventTypeDesc = eventTypeDesc;
    }

    public String getStopListType() {
        return stopListType;
    }
    public void setStopListType(String stopListType) {
        this.stopListType = stopListType;
    }

    public String getStopListTypeDesc() {
        return stopListTypeDesc;
    }
    public void setStopListTypeDesc(String stopListTypeDesc) {
        this.stopListTypeDesc = stopListTypeDesc;
    }

    public String getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public String getReasonCodeDesc() {
        return reasonCodeDesc;
    }
    public void setReasonCodeDesc(String reasonCodeDesc) {
        this.reasonCodeDesc = reasonCodeDesc;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDesc() {
        return statusDesc;
    }
    public void setStatusDesc(String statusDesc) {
        this.statusDesc = statusDesc;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getProduct() {
        return product;
    }

    public void setProduct(String product) {
        this.product = product;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("cardMask", getCardMask());
        result.put("reasonCode", getReasonCode());
        result.put("stopListType", getStopListType());
        result.put("status", getStatus());
        result.put("eventType", getEventType());
        result.put("purgeDate", getPurgeDate());
        return result;
    }
}

package ru.bpc.sv2.ps.mastercard;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class AbuIssMessage extends AbuFileMessage {
    private String oldCardNumber;
    private String oldCardMask;
    private Date oldExpirationDate;
    private String newCardNumber;
    private String newCardMask;
    private Date newExpirationDate;
    private String reasonCode;

    public String getOldCardNumber() {
        return oldCardNumber;
    }
    public void setOldCardNumber(String oldCardNumber) {
        this.oldCardNumber = oldCardNumber;
    }

    public String getOldCardMask() {
        return oldCardMask;
    }
    public void setOldCardMask(String oldCardMask) {
        this.oldCardMask = oldCardMask;
    }

    public Date getOldExpirationDate() {
        return oldExpirationDate;
    }
    public void setOldExpirationDate(Date oldExpirationDate) {
        this.oldExpirationDate = oldExpirationDate;
    }

    public String getNewCardNumber() {
        return newCardNumber;
    }
    public void setNewCardNumber(String newCardNumber) {
        this.newCardNumber = newCardNumber;
    }

    public String getNewCardMask() {
        return newCardMask;
    }
    public void setNewCardMask(String newCardMask) {
        this.newCardMask = newCardMask;
    }

    public Date getNewExpirationDate() {
        return newExpirationDate;
    }
    public void setNewExpirationDate(Date newExpirationDate) {
        this.newExpirationDate = newExpirationDate;
    }

    public String getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }
}

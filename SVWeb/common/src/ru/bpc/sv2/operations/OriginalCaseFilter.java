package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class OriginalCaseFilter implements Serializable {

    private static final long serialVersionUID = -7395898296027594004L;

    private String cardMask;
    private String merchantName;
    private String authCode;
    private String terminalNumber;
    private String merchantNumber;
    private String arn;
    private Date operDateFrom;
    private Date operDateTo;
    private Date hostDateFrom;
    private Date hostDateTo;

    public String getCardMask() {
        return cardMask;
    }

    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public String getMerchantName() {
        return merchantName;
    }

    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getAuthCode() {
        return authCode;
    }

    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    public String getTerminalNumber() {
        return terminalNumber;
    }

    public void setTerminalNumber(String terminalNumber) {
        this.terminalNumber = terminalNumber;
    }

    public String getMerchantNumber() {
        return merchantNumber;
    }

    public void setMerchantNumber(String merchantNumber) {
        this.merchantNumber = merchantNumber;
    }

    public String getArn() {
        return arn;
    }

    public void setArn(String arn) {
        this.arn = arn;
    }

    public Date getOperDateFrom() {
        return operDateFrom;
    }

    public void setOperDateFrom(Date operDateFrom) {
        this.operDateFrom = operDateFrom;
    }

    public Date getOperDateTo() {
        return operDateTo;
    }

    public void setOperDateTo(Date operDateTo) {
        this.operDateTo = operDateTo;
    }

    public Date getHostDateFrom() {
        if (hostDateFrom == null) {
            Calendar calendar = new GregorianCalendar();
            calendar.set(Calendar.HOUR_OF_DAY, 0);
            calendar.set(Calendar.MINUTE, 0);
            calendar.set(Calendar.SECOND, 0);
            calendar.set(Calendar.MILLISECOND, 0);
            hostDateFrom = new Date(calendar.getTimeInMillis());
        }
        return hostDateFrom;
    }

    public void setHostDateFrom(Date hostDateFrom) {
        this.hostDateFrom = hostDateFrom;
    }

    public Date getHostDateTo() {
        return hostDateTo;
    }

    public void setHostDateTo(Date hostDateTo) {
        this.hostDateTo = hostDateTo;
    }
}

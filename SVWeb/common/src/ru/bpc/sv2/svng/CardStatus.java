package ru.bpc.sv2.svng;

import ru.bpc.sv2.issuing.Card;
import java.util.Date;

public class CardStatus extends Card {
    private Integer seqNumber;
    private Date changeDate;
    private String status;
    private String state;
    private String initiator;
    private String statusReason;
    private String changeId;
    private String resultCode;
    private String errorCode;

    public Integer getSeqNumber() {
        return seqNumber;
    }
    public void setSeqNumber(Integer seqNumber) {
        this.seqNumber = seqNumber;
    }

    public Date getChangeDate() {
        return changeDate;
    }
    public void setChangeDate(Date changeDate) {
        this.changeDate = changeDate;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getState() {
        return state;
    }
    public void setState(String state) {
        this.state = state;
    }

    public String getInitiator() {
        return initiator;
    }
    public void setInitiator(String initiator) {
        this.initiator = initiator;
    }

    public String getStatusReason() {
        return statusReason;
    }
    public void setStatusReason(String statusReason) {
        this.statusReason = statusReason;
    }

    public String getChangeId() {
        return changeId;
    }
    public void setChangeId(String changeId) {
        this.changeId = changeId;
    }

    public String getResultCode() {
        return resultCode;
    }
    public void setResultCode(String resultCode) {
        this.resultCode = resultCode;
    }

    public String getErrorCode() {
        return errorCode;
    }
    public void setErrorCode(String errorCode) {
        this.errorCode = errorCode;
    }
}

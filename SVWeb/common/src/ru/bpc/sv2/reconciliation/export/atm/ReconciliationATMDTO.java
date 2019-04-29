package ru.bpc.sv2.reconciliation.export.atm;

import ru.bpc.sv2.invocation.ModelDTO;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.math.BigDecimal;
import java.util.Date;

@XmlAccessorType (XmlAccessType.NONE)
@XmlRootElement (name = "operation")
public class ReconciliationATMDTO implements ModelDTO {
    @XmlElement(name = "reconciliation_type")
    private String reconciliationType;

    @XmlElement(name = "operation_date")
    private Date operDate;

    @XmlElement(name = "card_number")
    private String cardMask;

    @XmlElement(name = "acquirer_institution")
    private Integer acqInstId;

    @XmlElement(name = "atm_number")
    private String terminalNum;

    @XmlElement(name = "oper_amount")
    private BigDecimal operAmount;

    @XmlElement(name = "oper_currency")
    private String operCurrency;

    @XmlElement(name = "trace_number")
    private String traceNumber;

    @XmlElement(name = "auth_code")
    private String authCode;

    @XmlElement(name = "account_from")
    private String accFrom;

    @XmlElement(name = "account_to")
    private String accTo;

    @XmlElement(name = "reconciliation_status")
    private String reconStatus;

    @XmlElement(name = "reconciliation_date")
    private Date reconLastDateTime;

    public String getReconciliationType() {
        return reconciliationType;
    }
    public void setReconciliationType(String reconciliationType) {
        this.reconciliationType = reconciliationType;
    }

    public String getReconStatus() {
        return reconStatus;
    }
    public void setReconStatus(String reconStatus) {
        this.reconStatus = reconStatus;
    }

    public Date getReconLastDateTime() {
        return reconLastDateTime;
    }
    public void setReconLastDateTime(Date reconLastDateTime) {
        this.reconLastDateTime = reconLastDateTime;
    }

    public Date getOperDate() {
        return operDate;
    }
    public void setOperDate(Date operDate) {
        this.operDate = operDate;
    }

    public BigDecimal getOperAmount() {
        return operAmount;
    }
    public void setOperAmount(BigDecimal operAmount) {
        this.operAmount = operAmount;
    }

    public String getOperCurrency() {
        return operCurrency;
    }
    public void setOperCurrency(String operCurrency) {
        this.operCurrency = operCurrency;
    }

    public String getTraceNumber() {
        return traceNumber;
    }
    public void setTraceNumber(String traceNumber) {
        this.traceNumber = traceNumber;
    }

    public Integer getAcqInstId() {
        return acqInstId;
    }
    public void setAcqInstId(Integer acqInstId) {
        this.acqInstId = acqInstId;
    }

    public String getCardMask() {
        return cardMask;
    }
    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public String getAuthCode() {
        return authCode;
    }
    public void setAuthCode(String authCode) {
        this.authCode = authCode;
    }

    public String getTerminalNum() {
        return terminalNum;
    }
    public void setTerminalNum(String terminalNum) {
        this.terminalNum = terminalNum;
    }

    public String getAccFrom() {
        return accFrom;
    }
    public void setAccFrom(String accFrom) {
        this.accFrom = accFrom;
    }

    public String getAccTo() {
        return accTo;
    }
    public void setAccTo(String accTo) {
        this.accTo = accTo;
    }
}

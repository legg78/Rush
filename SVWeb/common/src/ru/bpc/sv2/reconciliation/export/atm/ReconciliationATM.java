package ru.bpc.sv2.reconciliation.export.atm;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class ReconciliationATM  implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String msgSource;
    private Date msgDateTime;
    private Date msgDateFrom;
    private Date msgDateTo;
    private Long operationId;
    private Long reconMsgRef;
    private String reconStatus;
    private String reconType;
    private Date reconLastDateTime;
    private Integer reconInstId;
    private String operType;
    private Date operDate;
    private Long operAmount;
    private String operCurrency;
    private String traceNumber;
    private Integer acqInstId;
    private String cardMask;
    private String authCode;
    private boolean reversal;
    private String terminalType;
    private String terminalNum;
    private Long issFee;
    private String accFrom;
    private String accTo;
    private String cardNumber;
    private String lang;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public String getMsgSource() {
        return msgSource;
    }
    public void setMsgSource(String msgSource) {
        this.msgSource = msgSource;
    }

    public Date getMsgDateTime() {
        return msgDateTime;
    }
    public void setMsgDateTime(Date msgDateTime) {
        this.msgDateTime = msgDateTime;
    }

    public Date getMsgDateFrom() {
        return msgDateFrom;
    }
    public void setMsgDateFrom(Date msgDateFrom) {
        this.msgDateFrom = msgDateFrom;
    }

    public Date getMsgDateTo() {
        return msgDateTo;
    }
    public void setMsgDateTo(Date msgDateTo) {
        this.msgDateTo = msgDateTo;
    }

    public Long getOperationId() {
        return operationId;
    }
    public void setOperationId(Long operationId) {
        this.operationId = operationId;
    }

    public Long getReconMsgRef() {
        return reconMsgRef;
    }
    public void setReconMsgRef(Long reconMsgRef) {
        this.reconMsgRef = reconMsgRef;
    }

    public String getReconStatus() {
        return reconStatus;
    }
    public void setReconStatus(String reconStatus) {
        this.reconStatus = reconStatus;
    }

    public String getReconType() {
        return reconType;
    }
    public void setReconType(String reconType) {
        this.reconType = reconType;
    }

    public Date getReconLastDateTime() {
        return reconLastDateTime;
    }
    public void setReconLastDateTime(Date reconLastDateTime) {
        this.reconLastDateTime = reconLastDateTime;
    }

    public Integer getReconInstId() {
        return reconInstId;
    }
    public void setReconInstId(Integer reconInstId) {
        this.reconInstId = reconInstId;
    }

    public String getOperType() {
        return operType;
    }
    public void setOperType(String operType) {
        this.operType = operType;
    }

    public Date getOperDate() {
        return operDate;
    }
    public void setOperDate(Date operDate) {
        this.operDate = operDate;
    }

    public Long getOperAmount() {
        return operAmount;
    }
    public void setOperAmount(Long operAmount) {
        this.operAmount = operAmount;
    }

    public String getOperCurrency() {
        return operCurrency;
    }
    public void setOperCurrency(String operCurrency) {
        this.operCurrency = operCurrency;
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

    public boolean isReversal() {
        return reversal;
    }
    public void setReversal(boolean reversal) {
        this.reversal = reversal;
    }

    public String getTerminalType() {
        return terminalType;
    }
    public void setTerminalType(String terminalType) {
        this.terminalType = terminalType;
    }

    public String getTerminalNum() {
        return terminalNum;
    }
    public void setTerminalNum(String terminalNum) {
        this.terminalNum = terminalNum;
    }

    public Long getIssFee() {
        return issFee;
    }
    public void setIssFee(Long issFee) {
        this.issFee = issFee;
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

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getTraceNumber() {
        return traceNumber;
    }
    public void setTraceNumber(String traceNumber) {
        this.traceNumber = traceNumber;
    }

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("oper_date", getOperDate());
        result.put("oper_type", getOperType());
        result.put("card_mask", getCardMask());
        result.put("msg_date", getMsgDateTime());
        result.put("recon_status", getReconStatus());
        result.put("terminal_num", getTerminalNum());
        result.put("oper_id", getOperationId());
        result.put("oper_amount", getOperAmount());
        result.put("oper_currency", getOperCurrency());
        result.put("trace_number", getTraceNumber());
        return result;
    }
}

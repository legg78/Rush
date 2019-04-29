package ru.bpc.sv2.scheduler.process.svng.reconciliation;

public class ReconciliationAMK {

    private String branchCode;
    private String channel;
    private String systemTraceAuditNumber;
    private String dateAndTime;
    private String transactionDate;
    private String valueDate;
    private String amount;
    private String totalChargeAmount;
    private String currency;
    private String creditOrDebitIndicator;
    private String operationIdentifier;
    private String messageType;
    private String terminalNumber;

    public ReconciliationAMK(String[] operation) {
        this.branchCode = operation[0];
        this.channel = operation[1];
        this.systemTraceAuditNumber = operation[2];
        this.dateAndTime = operation[3];
        this.transactionDate = operation[4];
        this.valueDate = operation[5];
        this.amount = operation[6];
        this.totalChargeAmount = operation[7];
        this.currency = operation[8];
        this.creditOrDebitIndicator = operation[9];
        this.operationIdentifier = operation[10];
        this.messageType = operation[11];
        this.terminalNumber = operation[12];
    }

    public String getBranchCode() {
        return branchCode;
    }

    public void setBranchCode(String branchCode) {
        this.branchCode = branchCode;
    }

    public String getChannel() {
        return channel;
    }

    public void setChannel(String channel) {
        this.channel = channel;
    }

    public String getSystemTraceAuditNumber() {
        return systemTraceAuditNumber;
    }

    public void setSystemTraceAuditNumber(String systemTraceAuditNumber) {
        this.systemTraceAuditNumber = systemTraceAuditNumber;
    }

    public String getDateAndTime() {
        return dateAndTime;
    }

    public void setDateAndTime(String dateAndTime) {
        this.dateAndTime = dateAndTime;
    }

    public String getTransactionDate() {
        return transactionDate;
    }

    public void setTransactionDate(String transactionDate) {
        this.transactionDate = transactionDate;
    }

    public String getValueDate() {
        return valueDate;
    }

    public void setValueDate(String valueDate) {
        this.valueDate = valueDate;
    }

    public String getAmount() {
        return amount;
    }

    public void setAmount(String amount) {
        this.amount = amount;
    }

    public String getTotalChargeAmount() {
        return totalChargeAmount;
    }

    public void setTotalChargeAmount(String totalChargeAmount) {
        this.totalChargeAmount = totalChargeAmount;
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public String getCreditOrDebitIndicator() {
        return creditOrDebitIndicator;
    }

    public void setCreditOrDebitIndicator(String creditOrDebitIndicator) {
        this.creditOrDebitIndicator = creditOrDebitIndicator;
    }

    public String getOperationIdentifier() {
        return operationIdentifier;
    }

    public void setOperationIdentifier(String operationIdentifier) {
        this.operationIdentifier = operationIdentifier;
    }

    public String getMessageType() {
        return messageType;
    }

    public void setMessageType(String messageType) {
        this.messageType = messageType;
    }

    public String getTerminalNumber() {
        return terminalNumber;
    }

    public void setTerminalNumber(String terminalNumber) {
        this.terminalNumber = terminalNumber;
    }
}

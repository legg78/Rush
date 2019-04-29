package ru.bpc.sv2.operations;

import ru.bpc.sv2.invocation.TreeIdentifiable;

import java.math.BigDecimal;
import java.util.Date;
import java.util.List;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class OperationUnpaidDebt implements TreeIdentifiable<Operation> {

    private Long debtId;
    private Long dppId;
    private Long operId;
    private Date operDate;
    private Double operAmount;
    private String operCurrency;
    private String operType;
    private String operTypeName;
    private String operReason;
    private String operReasonName;
    private String msgType;
    private String msgTypeName;
    private String operStatus;
    private String operStatusName;
    private Integer installmentNumber;
    private Date installmentDate;
    private Double installmentAmount;
    private Long feeId;
    private Double monthlyRate;
    private Double interestAmount;
    private String dppCurrency;
    private BigDecimal repaymentAmount;
    private BigDecimal repaymentAmountView;
    private Integer newCount;
    private String accelerationType;

    public OperationUnpaidDebt() {
    }

    public Long getDebtId() {
        return debtId;
    }

    public void setDebtId(Long debtId) {
        this.debtId = debtId;
    }

    public Long getDppId() {
        return dppId;
    }

    public void setDppId(Long dppId) {
        this.dppId = dppId;
    }

    public Long getOperId() {
        return operId;
    }

    public void setOperId(Long operId) {
        this.operId = operId;
    }

    public Date getOperDate() {
        return operDate;
    }

    public void setOperDate(Date operDate) {
        this.operDate = operDate;
    }

    public Double getOperAmount() {
        return operAmount;
    }

    public void setOperAmount(Double operAmount) {
        this.operAmount = operAmount;
    }

    public String getOperCurrency() {
        return operCurrency;
    }

    public void setOperCurrency(String operCurrency) {
        this.operCurrency = operCurrency;
    }

    public String getOperType() {
        return operType;
    }

    public void setOperType(String operType) {
        this.operType = operType;
    }

    public String getOperTypeName() {
        return operTypeName;
    }

    public void setOperTypeName(String operTypeName) {
        this.operTypeName = operTypeName;
    }

    public String getOperReason() {
        return operReason;
    }

    public void setOperReason(String operReason) {
        this.operReason = operReason;
    }

    public String getOperReasonName() {
        return operReasonName;
    }

    public void setOperReasonName(String operReasonName) {
        this.operReasonName = operReasonName;
    }

    public String getMsgType() {
        return msgType;
    }

    public void setMsgType(String msgType) {
        this.msgType = msgType;
    }

    public String getMsgTypeName() {
        return msgTypeName;
    }

    public void setMsgTypeName(String msgTypeName) {
        this.msgTypeName = msgTypeName;
    }

    public String getOperStatus() {
        return operStatus;
    }

    public void setOperStatus(String operStatus) {
        this.operStatus = operStatus;
    }

    public String getOperStatusName() {
        return operStatusName;
    }

    public void setOperStatusName(String operStatusName) {
        this.operStatusName = operStatusName;
    }

    public Integer getInstallmentNumber() {
        return installmentNumber;
    }

    public void setInstallmentNumber(Integer installmentNumber) {
        this.installmentNumber = installmentNumber;
    }

    public Date getInstallmentDate() {
        return installmentDate;
    }

    public void setInstallmentDate(Date installmentDate) {
        this.installmentDate = installmentDate;
    }

    public Double getInstallmentAmount() {
        return installmentAmount;
    }

    public void setInstallmentAmount(Double installmentAmount) {
        this.installmentAmount = installmentAmount;
    }

    public Long getFeeId() {
        return feeId;
    }

    public void setFeeId(Long feeId) {
        this.feeId = feeId;
    }

    public Double getMonthlyRate() {
        return monthlyRate;
    }

    public void setMonthlyRate(Double monthlyRate) {
        this.monthlyRate = monthlyRate;
    }

    public Double getInterestAmount() {
        return interestAmount;
    }

    public void setInterestAmount(Double interestAmount) {
        this.interestAmount = interestAmount;
    }

    public String getDppCurrency() {
        return dppCurrency;
    }

    public void setDppCurrency(String dppCurrency) {
        this.dppCurrency = dppCurrency;
    }

    public BigDecimal getRepaymentAmount() {
        return repaymentAmount;
    }

    public void setRepaymentAmount(BigDecimal repaymentAmount) {
        this.repaymentAmount = repaymentAmount;
    }

    public BigDecimal getRepaymentAmountView() {
        if (repaymentAmount == null) { return null; }
        Double factor = Math.pow(new Double(10.0), repaymentAmount.scale());
        return  repaymentAmount.multiply(new BigDecimal(factor));
    }

    public void setRepaymentAmountView(BigDecimal repaymentAmountView) {
        this.repaymentAmountView = repaymentAmountView;
    }

    public Integer getNewCount() {
        return newCount;
    }

    public void setNewCount(Integer newCount) {
        this.newCount = newCount;
    }

    public String getAccelerationType() {
        return accelerationType;
    }

    public void setAccelerationType(String accelerationType) {
        this.accelerationType = accelerationType;
    }

    @Override
    public int getLevel() {
        return 0;
    }

    @Override
    public List<Operation> getChildren() {
        return null;
    }

    @Override
    public void setChildren(List<Operation> children) {

    }

    @Override
    public boolean isHasChildren() {
        return false;
    }

    @Override
    public Long getParentId() {
        return null;
    }

    @Override
    public Long getId() {
        return dppId;
    }

    @Override
    public Object getModelId() {
        return dppId;
    }

    @Override
    public String toString() {
        return "OperationUnpaidDebt{" +
                "debtId=" + debtId +
                ", dppId=" + dppId +
                ", operId=" + operId +
                ", operDate=" + operDate +
                ", operAmount=" + operAmount +
                ", operCurrency='" + operCurrency + '\'' +
                ", operType='" + operType + '\'' +
                ", operTypeName='" + operTypeName + '\'' +
                ", operReason='" + operReason + '\'' +
                ", operReasonName='" + operReasonName + '\'' +
                ", msgType='" + msgType + '\'' +
                ", msgTypeName='" + msgTypeName + '\'' +
                ", operStatus='" + operStatus + '\'' +
                ", operStatusName='" + operStatusName + '\'' +
                ", installmentNumber=" + installmentNumber +
                ", installmentDate=" + installmentDate +
                ", installmentAmount=" + installmentAmount +
                ", feeId=" + feeId +
                ", monthlyRate=" + monthlyRate +
                ", interestAmount=" + interestAmount +
                ", dppCurrency='" + dppCurrency + '\'' +
                ", repaymentAmount=" + repaymentAmount +
                ", repaymentAmountView=" + repaymentAmountView +
                ", newCount=" + newCount +
                ", accelerationType='" + accelerationType + '\'' +
                '}';
    }
}

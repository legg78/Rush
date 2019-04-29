package ru.bpc.sv2.credit;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class DppCalculation implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;

    private Long accountId;
    private String accountNumber;
    private String currency;
    private BigDecimal dppAmount;
    private Long feeId;
    private Integer instalmentPeriod;
    private Date firstInstalmentDate;
    private Date settlementDate;
    private Integer instId;
    private Integer instalmentCount;
    private BigDecimal instalmentAmount;
    private String calcAlgorithm;
    private BigDecimal interestRate;
    private List<Instalment> instalments;

    public Long getAccountId() {
        return accountId;
    }
    public void setAccountId(Long accountId) {
        this.accountId = accountId;
    }

    public String getAccountNumber() {
        return accountNumber;
    }
    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public String getCurrency() {
        return currency;
    }
    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public BigDecimal getDppAmount() {
        return dppAmount;
    }
    public void setDppAmount(BigDecimal dppAmount) {
        this.dppAmount = dppAmount;
    }

    public Long getFeeId() {
        return feeId;
    }
    public void setFeeId(Long feeId) {
        this.feeId = feeId;
    }

    public Integer getInstalmentPeriod() {
        return instalmentPeriod;
    }
    public void setInstalmentPeriod(Integer instalmentPeriod) {
        this.instalmentPeriod = instalmentPeriod;
    }

    public Date getFirstInstalmentDate() {
        return firstInstalmentDate;
    }
    public void setFirstInstalmentDate(Date firstInstalmentDate) {
        this.firstInstalmentDate = firstInstalmentDate;
    }

    public Date getSettlementDate() {
        return settlementDate;
    }
    public void setSettlementDate(Date settlementDate) {
        this.settlementDate = settlementDate;
    }

    public Integer getInstId() {
        return instId;
    }
    public String getInstIdString() {
        if(instId != null) {
            return instId.toString();
        }
        return null;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public Integer getInstalmentCount() {
        return instalmentCount;
    }
    public void setInstalmentCount(Integer instalmentCount) {
        this.instalmentCount = instalmentCount;
    }

    public BigDecimal getInstalmentAmount() {
        return instalmentAmount;
    }
    public void setInstalmentAmount(BigDecimal instalmentAmount) {
        this.instalmentAmount = instalmentAmount;
    }

    public String getCalcAlgorithm() {
        return calcAlgorithm;
    }
    public void setCalcAlgorithm(String calcAlgorithm) {
        this.calcAlgorithm = calcAlgorithm;
    }

    public BigDecimal getInterestRate() {
        return interestRate;
    }
    public void setInterestRate(BigDecimal interestRate) {
        this.interestRate = interestRate;
    }

    public List<Instalment> getInstalments() {
        if (instalments == null) {
            instalments = new ArrayList<Instalment>();
        }
        return instalments;
    }
    public void setInstalments(List<Instalment> instalments) {
        this.instalments = instalments;
    }

    @Override
    public Object getModelId() {
        return getInstId() + getAccountId() + getFeeId() + getFirstInstalmentDate().getTime();
    }
}

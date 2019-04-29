package ru.bpc.sv2.accounts;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class PriorityAccount implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable  {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Date fileDate;
    private String customerNumber;
    private String accountNumber;
    private BigDecimal accountBalance;
    private BigDecimal customerBalance;
    private String agentNumber;
    private String productNumber;
    private String priorityFlag;

    //UI Filters
    private Date dateFrom;
    private Date dateTo;

    @Override
    public Object getModelId() {
        return id;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Date getFileDate() {
        return fileDate;
    }

    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    public String getCustomerNumber() {
        return customerNumber;
    }

    public void setCustomerNumber(String customerNumber) {
        this.customerNumber = customerNumber;
    }

    public String getAccountNumber() {
        return accountNumber;
    }

    public void setAccountNumber(String accountNumber) {
        this.accountNumber = accountNumber;
    }

    public BigDecimal getAccountBalance() {
        return accountBalance;
    }

    public void setAccountBalance(BigDecimal accountBalance) {
        this.accountBalance = accountBalance;
    }

    public BigDecimal getCustomerBalance() {
        return customerBalance;
    }

    public void setCustomerBalance(BigDecimal customerBalance) {
        this.customerBalance = customerBalance;
    }

    public String getAgentNumber() {
        return agentNumber;
    }

    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }

    public String getProductNumber() {
        return productNumber;
    }

    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }

    public String getPriorityFlag() {
        return priorityFlag;
    }

    public void setPriorityFlag(String priorityFlag) {
        this.priorityFlag = priorityFlag;
    }

    public Date getDateFrom() {
        return dateFrom;
    }

    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    public Date getDateTo() {
        return dateTo;
    }

    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }

    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", this.getId());
        result.put("fileDate", this.getFileDate());
        result.put("customerNumber", this.getCustomerNumber());
        result.put("accountNumber", this.getAccountNumber());
        result.put("accountBalance", this.getAccountBalance());
        result.put("customerBalance", this.getCustomerBalance());
        result.put("agentNumber", this.getAgentNumber());
        result.put("productNumber", this.getProductNumber());
        result.put("priorityFlag", this.getPriorityFlag());
        return result;
    }

}

package ru.bpc.sv2.operations;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;

/**
 * Created by Gasanov on 21.07.2016.
 */
public class PosBatch implements ModelIdentifiable, Serializable, Cloneable{

    private Long operId;
    private String voucherNumber;
    private String debitCredit;
    private String transType;
    private String posDataCode;
    private String transStatus;
    private String addData;
    private String emvData;
    private String serviceId;
    private String paymentDetails;
    private String serviceProviderId;
    private String uniqueNumberPayment;
    private String addAmounts;
    private String svfeTraceNumber;

    public Long getOperId() {
        return operId;
    }

    public void setOperId(Long operId) {
        this.operId = operId;
    }

    public String getVoucherNumber() {
        return voucherNumber;
    }

    public void setVoucherNumber(String voucherNumber) {
        this.voucherNumber = voucherNumber;
    }

    public String getDebitCredit() {
        return debitCredit;
    }

    public void setDebitCredit(String debitCredit) {
        this.debitCredit = debitCredit;
    }

    public String getTransType() {
        return transType;
    }

    public void setTransType(String transType) {
        this.transType = transType;
    }

    public String getPosDataCode() {
        return posDataCode;
    }

    public void setPosDataCode(String posDataCode) {
        this.posDataCode = posDataCode;
    }

    public String getTransStatus() {
        return transStatus;
    }

    public void setTransStatus(String transStatus) {
        this.transStatus = transStatus;
    }

    public String getAddData() {
        return addData;
    }

    public void setAddData(String addData) {
        this.addData = addData;
    }

    public String getEmvData() {
        return emvData;
    }

    public void setEmvData(String emvData) {
        this.emvData = emvData;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getPaymentDetails() {
        return paymentDetails;
    }

    public void setPaymentDetails(String paymentDetails) {
        this.paymentDetails = paymentDetails;
    }

    public String getServiceProviderId() {
        return serviceProviderId;
    }

    public void setServiceProviderId(String serviceProviderId) {
        this.serviceProviderId = serviceProviderId;
    }

    public String getUniqueNumberPayment() {
        return uniqueNumberPayment;
    }

    public void setUniqueNumberPayment(String uniqueNumberPayment) {
        this.uniqueNumberPayment = uniqueNumberPayment;
    }

    public String getAddAmounts() {
        return addAmounts;
    }

    public void setAddAmounts(String addAmounts) {
        this.addAmounts = addAmounts;
    }

    public String getSvfeTraceNumber() {
        return svfeTraceNumber;
    }

    public void setSvfeTraceNumber(String svfeTraceNumber) {
        this.svfeTraceNumber = svfeTraceNumber;
    }

    @Override
    public Object getModelId() {
        return getOperId();
    }
}

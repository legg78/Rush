package ru.bpc.sv2.reconciliation.export.sp;

import ru.bpc.sv2.invocation.ModelDTO;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlRootElement;
import java.math.BigDecimal;
import java.util.Date;

@XmlAccessorType (XmlAccessType.NONE)
@XmlRootElement (name = "payment_order")
public class ReconciliationSRVPDTO implements ModelDTO {
    @XmlElement (name = "recon_type")
    private String reconType;
    @XmlElement (name = "recon_status")
    private String reconStatus;
    @XmlElement (name = "recon_date")
    private Date reconLastDateTime;
    @XmlElement (name = "message_source")
    private String msgSource;
    @XmlElement (name = "msg_date")
    private Date msgDateTime;
    @XmlElement (name = "order_id")
    private Long orderId;
    @XmlElement (name = "order_status")
    private String orderStatus;
    @XmlElement (name = "payment_order_number")
    private String paymentOrderNumber;
    @XmlElement (name = "order_date")
    private Date orderDate;
    @XmlElement (name = "order_amount")
    private BigDecimal orderAmount;
    @XmlElement (name = "order_currency")
    private String orderCurrency;
    @XmlElement (name = "customer_id")
    private Long customerId;
    @XmlElement (name = "customer_number")
    private String customerNumber;
    @XmlElement (name = "purpose_id")
    private Long purposeId;
    @XmlElement (name = "purpose_number")
    private String purposeNumber;
    @XmlElement (name = "provider_id")
    private Long providerId;
    @XmlElement (name = "provider_number")
    private String providerNumber;

    public String getReconType() {
        return reconType;
    }
    public void setReconType(String reconType) {
        this.reconType = reconType;
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

    public Long getOrderId() {
        return orderId;
    }
    public void setOrderId(Long orderId) {
        this.orderId = orderId;
    }

    public String getOrderStatus() {
        return orderStatus;
    }
    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getPaymentOrderNumber() {
        return paymentOrderNumber;
    }
    public void setPaymentOrderNumber(String paymentOrderNumber) {
        this.paymentOrderNumber = paymentOrderNumber;
    }

    public Date getOrderDate() {
        return orderDate;
    }
    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public BigDecimal getOrderAmount() {
        return orderAmount;
    }
    public void setOrderAmount(BigDecimal orderAmount) {
        this.orderAmount = orderAmount;
    }

    public String getOrderCurrency() {
        return orderCurrency;
    }
    public void setOrderCurrency(String orderCurrency) {
        this.orderCurrency = orderCurrency;
    }

    public Long getCustomerId() {
        return customerId;
    }
    public void setCustomerId(Long customerId) {
        this.customerId = customerId;
    }

    public String getCustomerNumber() {
        return customerNumber;
    }
    public void setCustomerNumber(String customerNumber) {
        this.customerNumber = customerNumber;
    }

    public Long getPurposeId() {
        return purposeId;
    }
    public void setPurposeId(Long purposeId) {
        this.purposeId = purposeId;
    }

    public String getPurposeNumber() {
        return purposeNumber;
    }
    public void setPurposeNumber(String purposeNumber) {
        this.purposeNumber = purposeNumber;
    }

    public Long getProviderId() {
        return providerId;
    }
    public void setProviderId(Long providerId) {
        this.providerId = providerId;
    }

    public String getProviderNumber() {
        return providerNumber;
    }
    public void setProviderNumber(String providerNumber) {
        this.providerNumber = providerNumber;
    }
}

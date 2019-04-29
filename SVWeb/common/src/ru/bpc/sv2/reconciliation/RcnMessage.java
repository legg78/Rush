package ru.bpc.sv2.reconciliation;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.operations.incoming.Operation;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class RcnMessage implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String reconType;
    private String msgSource;
    private Date msgDateTime;
    private Date msgDateFrom;
    private Date msgDateTo;
    private Long operationId;
    private Long reconMsgRef;
    private String reconStatus;
    private Date reconLastDateTime;
    private Integer reconInstId;
    private String reconInstName;
    private String operType;
    private String msgType;
    private String sttlType;
    private Date hostDate;
    private Date operDate;
    private Long operAmount;
    private String operCurrency;
    private Long operRequestAmount;
    private String operRequestCurrency;
    private Long operSurchargeAmount;
    private String operSurchargeCurrency;
    private String originatorRefnum;
    private String networkRefnum;
    private String acqInstBin;
    private String status;
    private boolean reversal;
    private String merchantNum;
    private Integer mcc;
    private String merchantName;
    private String merchantStreet;
    private String merchantCity;
    private String merchantRegion;
    private String merchantCountry;
    private String merchantPostcode;
    private String terminalType;
    private String terminalNum;
    private Integer acqInstId;
    private String cardNumber;
    private String cardMask;
    private Integer cardSeqNum;
    private Date cardExpirDate;
    private String cardCountry;
    private Integer issInstId;
    private String authCode;
    private Long issFee;
    private String accFrom;
    private String accTo;
    private String traceNumber;
    private Long orderId;
    private String paymentOrderNumber;
    private Date orderDate;
    private Long orderAmount;
    private String orderCurrency;
    private Long customerId;
    private String customerNumber;
    private Long purposeId;
    private String purposeName;
    private String purposeNumber;
    private Long providerId;
    private String providerName;
    private String providerNumber;
    private String lang;
    private String module;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public String getReconType() {
        return reconType;
    }
    public void setReconType(String reconType) {
        this.reconType = reconType;
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

    public String getReconInstName() {
        return reconInstName;
    }
    public void setReconInstName(String reconInstName) {
        this.reconInstName = reconInstName;
    }

    public String getOperType() {
        return operType;
    }
    public void setOperType(String operType) {
        this.operType = operType;
    }

    public String getMsgType() {
        return msgType;
    }
    public void setMsgType(String msgType) {
        this.msgType = msgType;
    }

    public String getSttlType() {
        return sttlType;
    }
    public void setSttlType(String sttlType) {
        this.sttlType = sttlType;
    }

    public Date getHostDate() {
        return hostDate;
    }
    public void setHostDate(Date hostDate) {
        this.hostDate = hostDate;
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

    public Long getOperRequestAmount() {
        return operRequestAmount;
    }
    public void setOperRequestAmount(Long operRequestAmount) {
        this.operRequestAmount = operRequestAmount;
    }

    public String getOperRequestCurrency() {
        return operRequestCurrency;
    }
    public void setOperRequestCurrency(String operRequestCurrency) {
        this.operRequestCurrency = operRequestCurrency;
    }

    public Long getOperSurchargeAmount() {
        return operSurchargeAmount;
    }
    public void setOperSurchargeAmount(Long operSurchargeAmount) {
        this.operSurchargeAmount = operSurchargeAmount;
    }

    public String getOperSurchargeCurrency() {
        return operSurchargeCurrency;
    }
    public void setOperSurchargeCurrency(String operSurchargeCurrency) {
        this.operSurchargeCurrency = operSurchargeCurrency;
    }

    public String getOriginatorRefnum() {
        return originatorRefnum;
    }
    public void setOriginatorRefnum(String originatorRefnum) {
        this.originatorRefnum = originatorRefnum;
    }

    public String getNetworkRefnum() {
        return networkRefnum;
    }
    public void setNetworkRefnum(String networkRefnum) {
        this.networkRefnum = networkRefnum;
    }

    public String getAcqInstBin() {
        return acqInstBin;
    }
    public void setAcqInstBin(String acqInstBin) {
        this.acqInstBin = acqInstBin;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public boolean getReversal() {
        return reversal;
    }
    public void setReversal(Boolean reversal) {
        if (reversal == null) {
            this.reversal = false;
        } else {
            this.reversal = reversal.booleanValue();
        }
    }
    public void setReversal(boolean reversal) {
        this.reversal = reversal;
    }

    public String getMerchantNum() {
        return merchantNum;
    }
    public void setMerchantNum(String merchantNum) {
        this.merchantNum = merchantNum;
    }

    public Integer getMcc() {
        return mcc;
    }
    public void setMcc(Integer mcc) {
        this.mcc = mcc;
    }

    public String getMerchantName() {
        return merchantName;
    }
    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getMerchantStreet() {
        return merchantStreet;
    }
    public void setMerchantStreet(String merchantStreet) {
        this.merchantStreet = merchantStreet;
    }

    public String getMerchantCity() {
        return merchantCity;
    }
    public void setMerchantCity(String merchantCity) {
        this.merchantCity = merchantCity;
    }

    public String getMerchantRegion() {
        return merchantRegion;
    }
    public void setMerchantRegion(String merchantRegion) {
        this.merchantRegion = merchantRegion;
    }

    public String getMerchantCountry() {
        return merchantCountry;
    }
    public void setMerchantCountry(String merchantCountry) {
        this.merchantCountry = merchantCountry;
    }

    public String getMerchantPostcode() {
        return merchantPostcode;
    }
    public void setMerchantPostcode(String merchantPostcode) {
        this.merchantPostcode = merchantPostcode;
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

    public Integer getAcqInstId() {
        return acqInstId;
    }
    public void setAcqInstId(Integer acqInstId) {
        this.acqInstId = acqInstId;
    }

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public String getCardMask() {
        return cardMask;
    }
    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public Integer getCardSeqNum() {
        return cardSeqNum;
    }
    public void setCardSeqNum(Integer cardSeqNum) {
        this.cardSeqNum = cardSeqNum;
    }

    public Date getCardExpirDate() {
        return cardExpirDate;
    }
    public void setCardExpirDate(Date cardExpirDate) {
        this.cardExpirDate = cardExpirDate;
    }

    public String getCardCountry() {
        return cardCountry;
    }
    public void setCardCountry(String cardCountry) {
        this.cardCountry = cardCountry;
    }

    public Integer getIssInstId() {
        return issInstId;
    }
    public void setIssInstId(Integer issInstId) {
        this.issInstId = issInstId;
    }

    public String getAuthCode() {
        return authCode;
    }
    public void setAuthCode(String authCode) {
        this.authCode = authCode;
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

    public String getTraceNumber() {
        return traceNumber;
    }
    public void setTraceNumber(String traceNumber) {
        this.traceNumber = traceNumber;
    }

    public Long getOrderId() {
        return orderId;
    }
    public void setOrderId(Long orderId) {
        this.orderId = orderId;
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

    public Long getOrderAmount() {
        return orderAmount;
    }
    public void setOrderAmount(Long orderAmount) {
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

    public String getPurposeName() {
        return purposeName;
    }
    public void setPurposeName(String purposeName) {
        this.purposeName = purposeName;
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

    public String getProviderName() {
        return providerName;
    }
    public void setProviderName(String providerName) {
        this.providerName = providerName;
    }

    public String getProviderNumber() {
        return providerNumber;
    }
    public void setProviderNumber(String providerNumber) {
        this.providerNumber = providerNumber;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getModule() {
        return module;
    }
    public void setModule(String module) {
        this.module = module;
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
        result.put("recon_type", getReconType());
        result.put("oper_type", getOperType());
        result.put("msg_type", getMsgType());
        result.put("msg_dt", getMsgDateTime());
        result.put("card_mask", getCardMask());
        result.put("terminal_num", getTerminalNum());
        result.put("merch_num", getMerchantNum());
        result.put("status", getStatus());
        result.put("oper_amount", getOperAmount());
        result.put("oper_currency", getOperCurrency());
        return result;
    }


    public Operation toIncomingOperation() {
    	Operation operation = new Operation();

	    operation.setOperType(getOperType());
		operation.setMsgType(StringUtils.isNotBlank(getMsgType()) ? getMsgType() : OperationsConstants.MESSAGE_TYPE_AUTHORIZATION);
	    operation.setStatus(getStatus());
	    operation.setSttlType(StringUtils.isNotBlank(getSttlType()) ? getSttlType() : OperationsConstants.SETTLEMENT_INTERNAL_INTRAINST);
	    operation.setOperCount(1L);
	    operation.setOperationDate(getOperDate());
	    operation.setSourceHostDate(new Date());

	    operation.setIssInstId(getReconInstId());
	    operation.setAcqInstId(getAcqInstId());
	    if (getReconInstId() != null || getAcqInstId() == null) {
		    operation.setParticipantType(Participant.ISS_PARTICIPANT);
	    } else {
		    operation.setParticipantType(Participant.ACQ_PARTICIPANT);
	    }

		operation.setCardNumber(getCardNumber());

		operation.setCustomerId(getCustomerId());
		if (getOperAmount() != null) {
			operation.setOperationAmount(new BigDecimal(getOperAmount()));
		}
		operation.setOperationCurrency(getOperCurrency());
		operation.setCardMask(getCardMask());
		operation.setTerminalNumber(getTerminalNum());
		operation.setTerminalType(getTerminalType());

		operation.setMerchantNumber(getMerchantNum());
		operation.setMerchantName(getMerchantName());

	    return operation;
    }
}

package ru.bpc.sv2.svng;

import ru.bpc.sv2.operations.Operation;

import java.math.BigDecimal;
import java.util.Date;

/**
 * Created by Gasanov on 19.08.2016.
 */
public class ClearingOperation extends Operation {
    private Integer instId;
    private String reconType;
    private String operRequestAmountCurrency;
    private String operSurchargeAmountCurrency;
    private String operCashbackAmountCurrency;
    private BigDecimal interchangeFee;
    private String interchangeFeeCurrency;
    private Date sttlData;
    private Date acqSttlDate;
    private String externalOrigId;
    private String traceNumber;

    private String paymentOrderStatus;
    private String paymentOrderNumber;
    private Integer purposeId;
    private String purposeNumber;
    private BigDecimal paymentOrderAmount;
    private String paymentOrderCurrency;
    private String paymentOrderPrtyType;
    private String paymentParameters;

    private String issClientIdType;
    private String issClientIdValue;
    private String issCardNumber;
    private Long issCardId;
    private Integer issCardSeqNumber;
    private Date issCardExpirDate;


    private String issAuthCode;
    private Long issAccountAmount;
    private String issAccountCurrency;
    private String issAccountNumber;

    private String AcqClientIdType;
    private String AcqClientIdvalue;
    private String AcqCardNumber;
    private Integer AcqCardSeqNumber;
    private Date acqCardExpirDate;


    private String acqAuthCode;
    private Long acqAccountAmount;
    private String acqAccountCurrency;
    private String acqAccountNumber;

    private String destinationClientIdType;
    private String destinationClientIdvalue;
    private String destinationCardNumber;
    private Long destinationCardId;
    private Integer destinationCardSeqNumber;
    private Date destinationCardExpirDate;
    private Integer destinationInstId;
    private Integer destinationNetworkId;
    private String destinationAuthCode;
    private Long destinationAccountAmount;
    private String destinationAccountCurrency;
    private String destinationAccountNumber;

    private String aggregatorClientIdType;
    private String aggregatorClientIdvalue;
    private String aggregatorCardNumber;
    private Integer aggregatorCardSeqNumber;
    private Date aggregatorCardExpirDate;
    private Integer aggregatorInstId;
    private Integer aggregatorNetworkId;
    private String aggregatorAuthCode;
    private BigDecimal aggregatorAccountAmount;
    private String aggregatorAccountCurrency;
    private String aggregatorAccountNumber;

    private String srvpClientIdType;
    private String srvpClientIdvalue;
    private String srvpCardNumber;
    private String srvpCardSeqNumber;
    private Date srvpCardExpirDate;
    private Integer srvpInstId;
    private Integer srvpNetworkId;
    private String srvpAuthCode;
    private BigDecimal srvpAccountAmount;
    private String srvpAccountCurrency;
    private String srvpAccountNumber;

    private String participant;

    private boolean paymentOrderExists;
    private boolean issuerExists;
    private boolean acquirerExists;
    private boolean destinationExists;
    private boolean aggregatorExists;
    private boolean serviceProviderExists;
    private String incomSessFileId;

    private String note;
    private String authData;
    private String ipmData;
    private String baseiiData;
    private String additionalAmount;
    private String processingStage;

    private Long operIdBatch;
    
    private transient AuthData authDataObject;

    public Integer getInstId() {
        return instId;
    }

    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getReconType() {
        return reconType;
    }

    public void setReconType(String reconType) {
        this.reconType = reconType;
    }

    public String getOperRequestAmountCurrency() {
        return operRequestAmountCurrency;
    }

    public void setOperRequestAmountCurrency(String operRequestAmountCurrency) {
        this.operRequestAmountCurrency = operRequestAmountCurrency;
    }

    public String getOperSurchargeAmountCurrency() {
        return operSurchargeAmountCurrency;
    }

    public void setOperSurchargeAmountCurrency(String operSurchargeAmountCurrency) {
        this.operSurchargeAmountCurrency = operSurchargeAmountCurrency;
    }

    public String getOperCashbackAmountCurrency() {
        return operCashbackAmountCurrency;
    }

    public void setOperCashbackAmountCurrency(String operCashbackAmountCurrency) {
        this.operCashbackAmountCurrency = operCashbackAmountCurrency;
    }

    public BigDecimal getInterchangeFee() {
        return interchangeFee;
    }

    public void setInterchangeFee(BigDecimal interchangeFee) {
        this.interchangeFee = interchangeFee;
    }

    public String getInterchangeFeeCurrency() {
        return interchangeFeeCurrency;
    }

    public void setInterchangeFeeCurrency(String interchangeFeeCurrency) {
        this.interchangeFeeCurrency = interchangeFeeCurrency;
    }

    public Date getSttlData() {
        return sttlData;
    }

    public void setSttlData(Date sttlData) {
        this.sttlData = sttlData;
    }

    public Date getAcqSttlDate() {
        return acqSttlDate;
    }

    public void setAcqSttlDate(Date acqSttlDate) {
        this.acqSttlDate = acqSttlDate;
    }

    public String getExternalOrigId() {
        return externalOrigId;
    }

    public void setExternalOrigId(String externalOrigId) {
        this.externalOrigId = externalOrigId;
    }

    public String getTraceNumber() {
        return traceNumber;
    }

    public void setTraceNumber(String traceNumber) {
        this.traceNumber = traceNumber;
    }

    public String getPaymentOrderStatus() {
        return paymentOrderStatus;
    }

    public void setPaymentOrderStatus(String paymentOrderStatus) {
        this.paymentOrderStatus = paymentOrderStatus;
    }

    public String getPaymentOrderNumber() {
        return paymentOrderNumber;
    }

    public void setPaymentOrderNumber(String paymentOrderNumber) {
        this.paymentOrderNumber = paymentOrderNumber;
    }

    public Integer getPurposeId() {
        return purposeId;
    }

    public void setPurposeId(Integer purposeId) {
        this.purposeId = purposeId;
    }

    public String getPurposeNumber() {
        return purposeNumber;
    }

    public void setPurposeNumber(String purposeNumber) {
        this.purposeNumber = purposeNumber;
    }

    public BigDecimal getPaymentOrderAmount() {
        return paymentOrderAmount;
    }

    public void setPaymentOrderAmount(BigDecimal paymentOrderAmount) {
        this.paymentOrderAmount = paymentOrderAmount;
    }

    public String getPaymentOrderCurrency() {
        return paymentOrderCurrency;
    }

    public void setPaymentOrderCurrency(String paymentOrderCurrency) {
        this.paymentOrderCurrency = paymentOrderCurrency;
    }

    public String getPaymentOrderPrtyType() {
        return paymentOrderPrtyType;
    }

    public void setPaymentOrderPrtyType(String paymentOrderPrtyType) {
        this.paymentOrderPrtyType = paymentOrderPrtyType;
    }

    public String getPaymentParameters() {
        return paymentParameters;
    }

    public void setPaymentParameters(String paymentParameters) {
        this.paymentParameters = paymentParameters;
    }

    public String getIssClientIdType() {
        return issClientIdType;
    }

    public void setIssClientIdType(String issClientIdType) {
        this.issClientIdType = issClientIdType;
    }

    public String getIssClientIdValue() {
        return issClientIdValue;
    }

    public void setIssClientIdValue(String issClientIdValue) {
        this.issClientIdValue = issClientIdValue;
    }

    public String getIssCardNumber() {
        return issCardNumber;
    }

    public void setIssCardNumber(String issCardNumber) {
        this.issCardNumber = issCardNumber;
    }

    public Long getIssCardId() {
        return issCardId;
    }

    public void setIssCardId(Long issCardId) {
        this.issCardId = issCardId;
    }

    public Integer getIssCardSeqNumber() {
        return issCardSeqNumber;
    }

    public void setIssCardSeqNumber(Integer issCardSeqNumber) {
        this.issCardSeqNumber = issCardSeqNumber;
    }

    public Date getIssCardExpirDate() {
        return issCardExpirDate;
    }

    public void setIssCardExpirDate(Date issCardExpirDate) {
        this.issCardExpirDate = issCardExpirDate;
    }

    public String getIssAuthCode() {
        return issAuthCode;
    }

    public void setIssAuthCode(String issAuthCode) {
        this.issAuthCode = issAuthCode;
    }

    public Long getIssAccountAmount() {
        return issAccountAmount;
    }

    public void setIssAccountAmount(Long issAccountAmount) {
        this.issAccountAmount = issAccountAmount;
    }

    public String getIssAccountCurrency() {
        return issAccountCurrency;
    }

    public void setIssAccountCurrency(String issAccountCurrency) {
        this.issAccountCurrency = issAccountCurrency;
    }

    public String getIssAccountNumber() {
        return issAccountNumber;
    }

    public void setIssAccountNumber(String issAccountNumber) {
        this.issAccountNumber = issAccountNumber;
    }

    public String getAcqClientIdType() {
        return AcqClientIdType;
    }

    public void setAcqClientIdType(String acqClientIdType) {
        AcqClientIdType = acqClientIdType;
    }

    public String getAcqClientIdvalue() {
        return AcqClientIdvalue;
    }

    public void setAcqClientIdvalue(String acqClientIdvalue) {
        AcqClientIdvalue = acqClientIdvalue;
    }

    public String getAcqCardNumber() {
        return AcqCardNumber;
    }

    public void setAcqCardNumber(String acqCardNumber) {
        AcqCardNumber = acqCardNumber;
    }

    public Integer getAcqCardSeqNumber() {
        return AcqCardSeqNumber;
    }

    public void setAcqCardSeqNumber(Integer acqCardSeqNumber) {
        AcqCardSeqNumber = acqCardSeqNumber;
    }

    public Date getAcqCardExpirDate() {
        return acqCardExpirDate;
    }

    public void setAcqCardExpirDate(Date acqCardExpirDate) {
        this.acqCardExpirDate = acqCardExpirDate;
    }

    public String getAcqAuthCode() {
        return acqAuthCode;
    }

    public void setAcqAuthCode(String acqAuthCode) {
        this.acqAuthCode = acqAuthCode;
    }

    public Long getAcqAccountAmount() {
        return acqAccountAmount;
    }

    public void setAcqAccountAmount(Long acqAccountAmount) {
        this.acqAccountAmount = acqAccountAmount;
    }

    public String getAcqAccountCurrency() {
        return acqAccountCurrency;
    }

    public void setAcqAccountCurrency(String acqAccountCurrency) {
        this.acqAccountCurrency = acqAccountCurrency;
    }

    public String getAcqAccountNumber() {
        return acqAccountNumber;
    }

    public void setAcqAccountNumber(String acqAccountNumber) {
        this.acqAccountNumber = acqAccountNumber;
    }

    public String getDestinationClientIdType() {
        return destinationClientIdType;
    }

    public void setDestinationClientIdType(String destinationClientIdType) {
        this.destinationClientIdType = destinationClientIdType;
    }

    public String getDestinationClientIdvalue() {
        return destinationClientIdvalue;
    }

    public void setDestinationClientIdvalue(String destinationClientIdvalue) {
        this.destinationClientIdvalue = destinationClientIdvalue;
    }

    public String getDestinationCardNumber() {
        return destinationCardNumber;
    }

    public void setDestinationCardNumber(String destinationCardNumber) {
        this.destinationCardNumber = destinationCardNumber;
    }

    public Long getDestinationCardId() {
        return destinationCardId;
    }

    public void setDestinationCardId(Long destinationCardId) {
        this.destinationCardId = destinationCardId;
    }

    public Integer getDestinationCardSeqNumber() {
        return destinationCardSeqNumber;
    }

    public void setDestinationCardSeqNumber(Integer destinationCardSeqNumber) {
        this.destinationCardSeqNumber = destinationCardSeqNumber;
    }

    public Date getDestinationCardExpirDate() {
        return destinationCardExpirDate;
    }

    public void setDestinationCardExpirDate(Date destinationCardExpirDate) {
        this.destinationCardExpirDate = destinationCardExpirDate;
    }

    public Integer getDestinationInstId() {
        return destinationInstId;
    }

    public void setDestinationInstId(Integer destinationInstId) {
        this.destinationInstId = destinationInstId;
    }

    public Integer getDestinationNetworkId() {
        return destinationNetworkId;
    }

    public void setDestinationNetworkId(Integer destinationNetworkId) {
        this.destinationNetworkId = destinationNetworkId;
    }

    public String getDestinationAuthCode() {
        return destinationAuthCode;
    }

    public void setDestinationAuthCode(String destinationAuthCode) {
        this.destinationAuthCode = destinationAuthCode;
    }

    public Long getDestinationAccountAmount() {
        return destinationAccountAmount;
    }

    public void setDestinationAccountAmount(Long destinationAccountAmount) {
        this.destinationAccountAmount = destinationAccountAmount;
    }

    public String getDestinationAccountCurrency() {
        return destinationAccountCurrency;
    }

    public void setDestinationAccountCurrency(String destinationAccountCurrency) {
        this.destinationAccountCurrency = destinationAccountCurrency;
    }

    public String getDestinationAccountNumber() {
        return destinationAccountNumber;
    }

    public void setDestinationAccountNumber(String destinationAccountNumber) {
        this.destinationAccountNumber = destinationAccountNumber;
    }

    public String getAggregatorClientIdType() {
        return aggregatorClientIdType;
    }

    public void setAggregatorClientIdType(String aggregatorClientIdType) {
        this.aggregatorClientIdType = aggregatorClientIdType;
    }

    public String getAggregatorClientIdvalue() {
        return aggregatorClientIdvalue;
    }

    public void setAggregatorClientIdvalue(String aggregatorClientIdvalue) {
        this.aggregatorClientIdvalue = aggregatorClientIdvalue;
    }

    public String getAggregatorCardNumber() {
        return aggregatorCardNumber;
    }

    public void setAggregatorCardNumber(String aggregatorCardNumber) {
        this.aggregatorCardNumber = aggregatorCardNumber;
    }

    public Integer getAggregatorCardSeqNumber() {
        return aggregatorCardSeqNumber;
    }

    public void setAggregatorCardSeqNumber(Integer aggregatorCardSeqNumber) {
        this.aggregatorCardSeqNumber = aggregatorCardSeqNumber;
    }

    public Date getAggregatorCardExpirDate() {
        return aggregatorCardExpirDate;
    }

    public void setAggregatorCardExpirDate(Date aggregatorCardExpirDate) {
        this.aggregatorCardExpirDate = aggregatorCardExpirDate;
    }

    public Integer getAggregatorInstId() {
        return aggregatorInstId;
    }

    public void setAggregatorInstId(Integer aggregatorInstId) {
        this.aggregatorInstId = aggregatorInstId;
    }

    public Integer getAggregatorNetworkId() {
        return aggregatorNetworkId;
    }

    public void setAggregatorNetworkId(Integer aggregatorNetworkId) {
        this.aggregatorNetworkId = aggregatorNetworkId;
    }

    public String getAggregatorAuthCode() {
        return aggregatorAuthCode;
    }

    public void setAggregatorAuthCode(String aggregatorAuthCode) {
        this.aggregatorAuthCode = aggregatorAuthCode;
    }

    public BigDecimal getAggregatorAccountAmount() {
        return aggregatorAccountAmount;
    }

    public void setAggregatorAccountAmount(BigDecimal aggregatorAccountAmount) {
        this.aggregatorAccountAmount = aggregatorAccountAmount;
    }

    public String getAggregatorAccountCurrency() {
        return aggregatorAccountCurrency;
    }

    public void setAggregatorAccountCurrency(String aggregatorAccountCurrency) {
        this.aggregatorAccountCurrency = aggregatorAccountCurrency;
    }

    public String getAggregatorAccountNumber() {
        return aggregatorAccountNumber;
    }

    public void setAggregatorAccountNumber(String aggregatorAccountNumber) {
        this.aggregatorAccountNumber = aggregatorAccountNumber;
    }

    public String getSrvpClientIdType() {
        return srvpClientIdType;
    }

    public void setSrvpClientIdType(String srvpClientIdType) {
        this.srvpClientIdType = srvpClientIdType;
    }

    public String getSrvpClientIdvalue() {
        return srvpClientIdvalue;
    }

    public void setSrvpClientIdvalue(String srvpClientIdvalue) {
        this.srvpClientIdvalue = srvpClientIdvalue;
    }

    public String getSrvpCardNumber() {
        return srvpCardNumber;
    }

    public void setSrvpCardNumber(String srvpCardNumber) {
        this.srvpCardNumber = srvpCardNumber;
    }

    public String getSrvpCardSeqNumber() {
        return srvpCardSeqNumber;
    }

    public void setSrvpCardSeqNumber(String srvpCardSeqNumber) {
        this.srvpCardSeqNumber = srvpCardSeqNumber;
    }

    public Date getSrvpCardExpirDate() {
        return srvpCardExpirDate;
    }

    public void setSrvpCardExpirDate(Date srvpCardExpirDate) {
        this.srvpCardExpirDate = srvpCardExpirDate;
    }

    public Integer getSrvpInstId() {
        return srvpInstId;
    }

    public void setSrvpInstId(Integer srvpInstId) {
        this.srvpInstId = srvpInstId;
    }

    public Integer getSrvpNetworkId() {
        return srvpNetworkId;
    }

    public void setSrvpNetworkId(Integer srvpNetworkId) {
        this.srvpNetworkId = srvpNetworkId;
    }

    public String getSrvpAuthCode() {
        return srvpAuthCode;
    }

    public void setSrvpAuthCode(String srvpAuthCode) {
        this.srvpAuthCode = srvpAuthCode;
    }

    public BigDecimal getSrvpAccountAmount() {
        return srvpAccountAmount;
    }

    public void setSrvpAccountAmount(BigDecimal srvpAccountAmount) {
        this.srvpAccountAmount = srvpAccountAmount;
    }

    public String getSrvpAccountCurrency() {
        return srvpAccountCurrency;
    }

    public void setSrvpAccountCurrency(String srvpAccountCurrency) {
        this.srvpAccountCurrency = srvpAccountCurrency;
    }

    public String getSrvpAccountNumber() {
        return srvpAccountNumber;
    }

    public void setSrvpAccountNumber(String srvpAccountNumber) {
        this.srvpAccountNumber = srvpAccountNumber;
    }

    public String getParticipant() {
        return participant;
    }

    public void setParticipant(String participant) {
        this.participant = participant;
    }

    public boolean isPaymentOrderExists() {
        return paymentOrderExists;
    }

    public void setPaymentOrderExists(boolean paymentOrderExists) {
        this.paymentOrderExists = paymentOrderExists;
    }

    public boolean isIssuerExists() {
        return issuerExists;
    }

    public void setIssuerExists(boolean issuerExists) {
        this.issuerExists = issuerExists;
    }

    public boolean isAcquirerExists() {
        return acquirerExists;
    }

    public void setAcquirerExists(boolean acquirerExists) {
        this.acquirerExists = acquirerExists;
    }

    public boolean isDestinationExists() {
        return destinationExists;
    }

    public void setDestinationExists(boolean destinationExists) {
        this.destinationExists = destinationExists;
    }

    public boolean isAggregatorExists() {
        return aggregatorExists;
    }

    public void setAggregatorExists(boolean aggregatorExists) {
        this.aggregatorExists = aggregatorExists;
    }

    public boolean isServiceProviderExists() {
        return serviceProviderExists;
    }

    public void setServiceProviderExists(boolean serviceProviderExists) {
        this.serviceProviderExists = serviceProviderExists;
    }

    public String getIncomSessFileId() {
        return incomSessFileId;
    }

    public void setIncomSessFileId(String incomSessFileId) {
        this.incomSessFileId = incomSessFileId;
    }

    public String getNote() {
        return note;
    }

    public void setNote(String note) {
        this.note = note;
    }

    public String getAuthData() {
        return authData;
    }

    public void setAuthData(String authData) {
        this.authData = authData;
    }

    public String getIpmData() {
        return ipmData;
    }

    public void setIpmData(String ipmData) {
        this.ipmData = ipmData;
    }

    public String getBaseiiData() {
        return baseiiData;
    }

    public void setBaseiiData(String baseiiData) {
        this.baseiiData = baseiiData;
    }

    public String getAdditionalAmount() {
        return additionalAmount;
    }

    public void setAdditionalAmount(String additionalAmount) {
        this.additionalAmount = additionalAmount;
    }

    public String getProcessingStage() {
        return processingStage;
    }

    public void setProcessingStage(String processingStage) {
        this.processingStage = processingStage;
    }

    public AuthData getAuthDataObject() {
        return authDataObject;
    }

    public void setAuthDataObject(AuthData authDataObject) {
        this.authDataObject = authDataObject;
    }

    public Long getOperIdBatch() {
        return operIdBatch;
    }

    public void setOperIdBatch(Long operIdBatch) {
        this.operIdBatch = operIdBatch;
    }
}

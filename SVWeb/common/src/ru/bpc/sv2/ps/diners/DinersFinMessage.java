package ru.bpc.sv2.ps.diners;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class DinersFinMessage implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private String status;
    private String statusDesc;
    private Long fileId;
    private Integer recordNumber;
    private Boolean isReversal;
    private Boolean isIncoming;
    private Boolean isReturned;
    private Boolean isInvalid;
    private Long batchId;
    private Integer sequenceNumber;
    private Integer networkId;
    private String networkName;
    private Integer instituteId;
    private String instituteName;
    private String sendInstitute;
    private String recvInstitute;
    private Long disputeId;
    private String originatorRefnum;
    private String networkRefnum;
    private Long cardId;
    private String cardNumber;
    private String typeOfCharge;
    private String chargeType;
    private String dateType;
    private Date chargeDate;
    private Date sttlDate;
    private Date hostDate;
    private String authCode;
    private Integer actionCode;
    private BigDecimal operAmount;
    private String operCurrency;
    private BigDecimal sttlAmount;
    private String sttlCurrency;
    private String mcc;
    private String merchantNumber;
    private String merchantName;
    private String merchantStreet;
    private String merchantCity;
    private String merchantState;
    private String merchantCountry;
    private String merchantPostalCode;
    private String merchantPhone;
    private Integer merchantCode;
    private String terminalNumber;
    private BigDecimal transAmount;
    private String alternativeCurrency;
    private BigDecimal taxAmount1;
    private BigDecimal taxAmount2;
    private String documentNumber;
    private String lang;
    private String fileName;

    public Long getId(){
        return this.id;
    }
    public void setId(Long id){
        this.id = id;
    }

    public String getStatus(){
        return status;
    }
    public void setStatus( String status ){
        this.status = status;
    }

    public Long getFileId(){
        return fileId;
    }
    public void setFileId( Long fileId ){
        this.fileId = fileId;
    }

    public Integer getRecordNumber(){
        return recordNumber;
    }
    public void setRecordNumber( Integer recordNumber ){
        this.recordNumber = recordNumber;
    }

    public Boolean getIsReversal(){
        return isReversal;
    }
    public void setIsReversal( Boolean reversal ){
        isReversal = reversal;
    }

    public Boolean getIsIncoming(){
        return isIncoming;
    }
    public void setIsIncoming( Boolean incoming ){
        isIncoming = incoming;
    }

    public Boolean getIsReturned(){
        return isReturned;
    }
    public void setIsReturned( Boolean returned ){
        isReturned = returned;
    }

    public Boolean getIsInvalid(){
        return isInvalid;
    }
    public void setIsInvalid( Boolean invalid ){
        isInvalid = invalid;
    }

    public Long getBatchId(){
        return batchId;
    }
    public void setBatchId( Long batchId ){
        this.batchId = batchId;
    }

    public Integer getSequenceNumber(){
        return sequenceNumber;
    }
    public void setSequenceNumber( Integer sequenceNumber ){
        this.sequenceNumber = sequenceNumber;
    }

    public Integer getNetworkId(){
        return networkId;
    }
    public void setNetworkId( Integer networkId ){
        this.networkId = networkId;
    }

    public String getNetworkName(){
        return networkName;
    }
    public void setNetworkName( String networkName ){
        this.networkName = networkName;
    }

    public Integer getInstituteId(){
        return instituteId;
    }
    public void setInstituteId( Integer instituteId ){
        this.instituteId = instituteId;
    }

    public String getInstituteName(){
        return instituteName;
    }
    public void setInstituteName( String instituteName ){
        this.instituteName = instituteName;
    }

    public String getRecvInstitute(){
        return recvInstitute;
    }
    public void setRecvInstitute( String recvInstitute ){
        this.recvInstitute = recvInstitute;
    }

    public String getSendInstitute(){
        return sendInstitute;
    }
    public void setSendInstitute( String sendInstitute ){
        this.sendInstitute = sendInstitute;
    }

    public Long getDisputeId(){
        return disputeId;
    }
    public void setDisputeId( Long disputeId ){
        this.disputeId = disputeId;
    }

    public String getOriginatorRefnum(){
        return originatorRefnum;
    }
    public void setOriginatorRefnum( String originatorRefnum ){
        this.originatorRefnum = originatorRefnum;
    }

    public String getNetworkRefnum(){
        return networkRefnum;
    }
    public void setNetworkRefnum( String networkRefnum ){
        this.networkRefnum = networkRefnum;
    }

    public Long getCardId(){
        return cardId;
    }
    public void setCardId( Long cardId ){
        this.cardId = cardId;
    }

    public String getCardNumber(){
        return cardNumber;
    }
    public void setCardNumber( String cardNumber ){
        this.cardNumber = cardNumber;
    }

    public String getTypeOfCharge(){
        return typeOfCharge;
    }
    public void setTypeOfCharge( String typeOfCharge ){
        this.typeOfCharge = typeOfCharge;
    }

    public String getChargeType(){
        return chargeType;
    }
    public void setChargeType( String chargeType ){
        this.chargeType = chargeType;
    }

    public String getDateType(){
        return dateType;
    }
    public Date getChargeDate(){
        return chargeDate;
    }

    public void setChargeDate( Date chargeDate ){
        this.chargeDate = chargeDate;
    }
    public void setDateType( String dateType ){
        this.dateType = dateType;
    }

    public Date getSttlDate(){
        return sttlDate;
    }
    public void setSttlDate( Date sttlDate ){
        this.sttlDate = sttlDate;
    }

    public Date getHostDate(){
        return hostDate;
    }
    public void setHostDate( Date hostDate ){
        this.hostDate = hostDate;
    }

    public String getAuthCode(){
        return authCode;
    }
    public void setAuthCode( String authCode ){
        this.authCode = authCode;
    }

    public Integer getActionCode(){
        return actionCode;
    }
    public void setActionCode( Integer actionCode ){
        this.actionCode = actionCode;
    }

    public BigDecimal getOperAmount(){
        return operAmount;
    }
    public void setOperAmount( BigDecimal operAmount ){
        this.operAmount = operAmount;
    }

    public String getOperCurrency(){
        return operCurrency;
    }
    public void setOperCurrency( String operCurrency ){
        this.operCurrency = operCurrency;
    }

    public BigDecimal getSttlAmount(){
        return sttlAmount;
    }
    public void setSttlAmount( BigDecimal sttlAmount ){
        this.sttlAmount = sttlAmount;
    }

    public String getSttlCurrency(){
        return sttlCurrency;
    }
    public void setSttlCurrency( String sttlCurrency ){
        this.sttlCurrency = sttlCurrency;
    }

    public String getMcc(){
        return mcc;
    }
    public void setMcc( String mcc ){
        this.mcc = mcc;
    }

    public String getMerchantNumber(){
        return merchantNumber;
    }
    public void setMerchantNumber( String merchantNumber ){
        this.merchantNumber = merchantNumber;
    }

    public String getMerchantName(){
        return merchantName;
    }
    public void setMerchantName( String merchantName ){
        this.merchantName = merchantName;
    }

    public String getMerchantCity(){
        return merchantCity;
    }
    public void setMerchantCity( String merchantCity ){
        this.merchantCity = merchantCity;
    }

    public String getMerchantCountry(){
        return merchantCountry;
    }
    public void setMerchantCountry( String merchantCountry ){
        this.merchantCountry = merchantCountry;
    }

    public String getMerchantState(){
        return merchantState;
    }
    public void setMerchantState( String merchantState ){
        this.merchantState = merchantState;
    }

    public String getMerchantPostalCode(){
        return merchantPostalCode;
    }
    public void setMerchantPostalCode( String merchantPostalCode ){
        this.merchantPostalCode = merchantPostalCode;
    }

    public String getMerchantPhone(){
        return merchantPhone;
    }
    public void setMerchantPhone( String merchantPhone ){
        this.merchantPhone = merchantPhone;
    }

    public Integer getMerchantCode(){
        return merchantCode;
    }
    public void setMerchantCode( Integer merchantCode ){
        this.merchantCode = merchantCode;
    }

    public String getTerminalNumber(){
        return terminalNumber;
    }
    public void setTerminalNumber( String terminalNumber ){
        this.terminalNumber = terminalNumber;
    }

    public BigDecimal getTransAmount(){
        return transAmount;
    }
    public void setTransAmount( BigDecimal transAmount ){
        this.transAmount = transAmount;
    }

    public String getAlternativeCurrency(){
        return alternativeCurrency;
    }
    public void setAlternativeCurrency( String alternativeCurrency ){
        this.alternativeCurrency = alternativeCurrency;
    }

    public BigDecimal getTaxAmount1(){
        return taxAmount1;
    }
    public void setTaxAmount1( BigDecimal taxAmount1 ){
        this.taxAmount1 = taxAmount1;
    }

    public BigDecimal getTaxAmount2(){
        return taxAmount2;
    }
    public void setTaxAmount2( BigDecimal taxAmount2 ){
        this.taxAmount2 = taxAmount2;
    }

    public String getDocumentNumber(){
        return documentNumber;
    }
    public void setDocumentNumber( String documentNumber ){
        this.documentNumber = documentNumber;
    }

    public String getLang(){
        return this.lang;
    }
    public void setLang(String lang){
        this.lang = lang;
    }

    public String getFileName(){
        return fileName;
    }
    public void setFileName( String fileName ){
        this.fileName = fileName;
    }

    public String getMerchantStreet(){
        return merchantStreet;
    }
    public void setMerchantStreet( String merchantStreet ){
        this.merchantStreet = merchantStreet;
    }

    public String getStatusDesc(){
        return statusDesc;
    }
    public void setStatusDesc( String statusDesc ){
        this.statusDesc = statusDesc;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Object clone(){
        Object result = null;
        try {
            result = super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return result;
    }
}

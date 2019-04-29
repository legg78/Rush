package ru.bpc.sv2.reconciliation.export.operations;

import ru.bpc.sv2.invocation.ModelDTO;

import javax.xml.bind.annotation.*;
import java.math.BigDecimal;
import java.util.Date;

@XmlAccessorType (XmlAccessType.NONE)
@XmlRootElement (name = "operation")
public class ReconciliationDTO implements ModelDTO {
    @XmlElement (name = "oper_type", required = true)
    private String operType;
    @XmlElement(name = "msg_type")
    private String msgType;
    @XmlElement(name = "sttl_type")
    private String sttlType;
    @XmlElement(name = "oper_date", required = true)
    private Date operDate;
    @XmlElement(name = "oper_amount", required = true)
    private BigDecimal operAmount;
    @XmlElement(name = "oper_currency", required = true)
    private String operCurrency;
    @XmlElement(name = "oper_request_amount")
    private BigDecimal operRequestAmount;
    @XmlElement(name = "oper_request_currency")
    private String operRequestCurrency;
    @XmlElement(name = "oper_surcharge_amount")
    private BigDecimal operSurchargeAmount;
    @XmlElement(name = "oper_surcharge_currency")
    private String operSurchargeCurrency;
    @XmlElement(name = "originator_refnum")
    private String originatorRefnum;
    @XmlElement(name = "network_refnum")
    private String networkRefnum;
    @XmlElement(name = "acq_inst_bin")
    private String acqInstBin;
    @XmlElement(name = "status")
    private String status;
    @XmlElement(name = "is_reversal")
    private Boolean isReversal;
    @XmlElement(name = "mcc")
    private Integer mcc;
    @XmlElement(name = "merchant_number")
    private String merchantNumber;
    @XmlElement(name = "merchant_name")
    private String merchantName;
    @XmlElement(name = "merchant_street")
    private String merchantStreet;
    @XmlElement(name = "merchant_city")
    private String merchantCity;
    @XmlElement(name = "merchant_region")
    private String merchantRegion;
    @XmlElement(name = "merchant_country")
    private String merchantCountry;
    @XmlElement(name = "merchant_postcode")
    private String merchantPostcode;
    @XmlElement(name = "terminal_type")
    private String terminalType;
    @XmlElement(name = "terminal_number")
    private String terminalNumber;
    @XmlElement(name = "card_number")
    private String cardNumber;
    @XmlElement(name = "card_seq_number")
    private Integer cardSeqNumber;
    @XmlElement(name = "card_expir_date")
    private Date cardExpirDate;
    @XmlElement(name = "card_country")
    private String cardCountry;
    @XmlElement(name = "acq_inst_id")
    private Integer acqInstId;
    @XmlElement(name = "iss_inst_id")
    private Integer issInstId;
    @XmlElement(name = "auth_code")
    private String authCode;
    @XmlElement(name = "reconciliation_date")
    private Date reconLastDateTime;

    public String getOperType() {
        return operType;
    }
    public void setOperType(String value) {
        this.operType = value;
    }

    public String getMsgType() {
        return msgType;
    }
    public void setMsgType(String value) {
        this.msgType = value;
    }

    public String getSttlType() {
        return sttlType;
    }
    public void setSttlType(String value) {
        this.sttlType = value;
    }

    public Date getOperDate() {
        return operDate;
    }
    public void setOperDate(Date value) {
        this.operDate = value;
    }

    public BigDecimal getOperAmount() {
        return operAmount;
    }
    public void setOperAmount(BigDecimal value) {
        this.operAmount = value;
    }

    public String getOperCurrency() {
        return operCurrency;
    }
    public void setOperCurrency(String value) {
        this.operCurrency = value;
    }

    public BigDecimal getOperRequestAmount() {
        return operRequestAmount;
    }
    public void setOperRequestAmount(BigDecimal value) {
        this.operRequestAmount = value;
    }

    public String getOperRequestCurrency() {
        return operRequestCurrency;
    }
    public void setOperRequestCurrency(String value) {
        this.operRequestCurrency = value;
    }

    public BigDecimal getOperSurchargeAmount() {
        return operSurchargeAmount;
    }
    public void setOperSurchargeAmount(BigDecimal value) {
        this.operSurchargeAmount = value;
    }

    public String getOperSurchargeCurrency() {
        return operSurchargeCurrency;
    }
    public void setOperSurchargeCurrency(String value) {
        this.operSurchargeCurrency = value;
    }

    public String getOriginatorRefnum() {
        return originatorRefnum;
    }
    public void setOriginatorRefnum(String value) {
        this.originatorRefnum = value;
    }

    public String getNetworkRefnum() {
        return networkRefnum;
    }
    public void setNetworkRefnum(String value) {
        this.networkRefnum = value;
    }

    public String getAcqInstBin() {
        return acqInstBin;
    }
    public void setAcqInstBin(String value) {
        this.acqInstBin = value;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String value) {
        this.status = value;
    }

    public Boolean getIsReversal() {
        return isReversal;
    }
    public void setIsReversal(Boolean value) {
        this.isReversal = value;
    }

    public Integer getMcc() {
        return mcc;
    }
    public void setMcc(Integer value) {
        this.mcc = value;
    }

    public String getMerchantNumber() {
        return merchantNumber;
    }
    public void setMerchantNumber(String value) {
        this.merchantNumber = value;
    }

    public String getMerchantName() {
        return merchantName;
    }
    public void setMerchantName(String value) {
        this.merchantName = value;
    }

    public String getMerchantStreet() {
        return merchantStreet;
    }
    public void setMerchantStreet(String value) {
        this.merchantStreet = value;
    }

    public String getMerchantCity() {
        return merchantCity;
    }
    public void setMerchantCity(String value) {
        this.merchantCity = value;
    }

    public String getMerchantRegion() {
        return merchantRegion;
    }
    public void setMerchantRegion(String value) {
        this.merchantRegion = value;
    }

    public String getMerchantCountry() {
        return merchantCountry;
    }
    public void setMerchantCountry(String value) {
        this.merchantCountry = value;
    }

    public String getMerchantPostcode() {
        return merchantPostcode;
    }
    public void setMerchantPostcode(String value) {
        this.merchantPostcode = value;
    }

    public String getTerminalType() {
        return terminalType;
    }
    public void setTerminalType(String value) {
        this.terminalType = value;
    }

    public String getTerminalNumber() {
        return terminalNumber;
    }
    public void setTerminalNumber(String value) {
        this.terminalNumber = value;
    }

    public String getCardNumber() {
        return cardNumber;
    }
    public void setCardNumber(String value) {
        this.cardNumber = value;
    }

    public Integer getCardSeqNumber() {
        return cardSeqNumber;
    }
    public void setCardSeqNumber(Integer value) {
        this.cardSeqNumber = value;
    }

    public Date getCardExpirDate() {
        return cardExpirDate;
    }
    public void setCardExpirDate(Date value) {
        this.cardExpirDate = value;
    }

    public String getCardCountry() {
        return cardCountry;
    }
    public void setCardCountry(String value) {
        this.cardCountry = value;
    }

    public Integer getAcqInstId() {
        return acqInstId;
    }
    public void setAcqInstId(Integer value) {
        this.acqInstId = value;
    }

    public Integer getIssInstId() {
        return issInstId;
    }
    public void setIssInstId(Integer value) {
        this.issInstId = value;
    }

    public String getAuthCode() {
        return authCode;
    }
    public void setAuthCode(String value) {
        this.authCode = value;
    }

    public Date getReconLastDateTime() {
        return reconLastDateTime;
    }
    public void setReconLastDateTime(Date reconLastDateTime) {
        this.reconLastDateTime = reconLastDateTime;
    }
}

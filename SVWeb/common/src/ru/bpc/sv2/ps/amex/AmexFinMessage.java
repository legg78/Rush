package ru.bpc.sv2.ps.amex;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.Map;

public class AmexFinMessage implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = -367857103126887792L;

    private Long id;
    private Long splitHash;
    private String status;
    private String statusDesc;
    private Integer instId;
    private String instName;
    private Integer networkId;
    private String networkName;
    private Long fileId;
    private boolean isInvalid;
    private boolean isIncoming;
    private boolean isReversal;
    private boolean isCollectionOnly;
    private boolean isRejected;
    private Long rejectId;
    private Long disputeId;
    private String impact;
    private String mtid;
    private String funcCode;
    private Integer panLength;
    private Long cardHash;
    private String cardNumber;
    private String cardMask;
    private String procCode;
    private BigDecimal transAmount;
    private Date dateFrom;
    private Date dateTo;
    private Date transDate;
    private String cardExpirDate;
    private Date captureDate;
    private String mcc;
    private String pdc1;
    private String pdc2;
    private String pdc3;
    private String pdc4;
    private String pdc5;
    private String pdc6;
    private String pdc7;
    private String pdc8;
    private String pdc9;
    private String pdc10;
    private String pdc11;
    private String pdc12;
    private String reasonCode;
    private String approvalCodeLength;
    private Date issSttlDate;
    private String eci;
    private BigDecimal fpTransAmount;
    private String ain;
    private String apn;
    private String arn;
    private String approvalCode;
    private String terminalNumber;
    private String merchantNumber;
    private String merchantName;
    private String merchantAddr1;
    private String merchantAddr2;
    private String merchantCity;
    private String merchantPostalCode;
    private String merchantCountry;
    private String merchantRegion;
    private BigDecimal issGrossSttlAmount;
    private BigDecimal issRateAmount;
    private String matchingKeyType;
    private String matchingKey;
    private BigDecimal issNetSttlAmount;
    private String issSttlCurrency;
    private String issSttlDecimalization;
    private String fpTransCurrency;
    private String transDecimalization;
    private String fpTransDecimalization;
    private BigDecimal fpPresAmount;
    private String fpPresConversionRate;
    private String fpPresCurrency;
    private String fpPresDecimalization;
    private String merchantMultinational;
    private String transCurrency;
    private String addAccEffType1;
    private BigDecimal addAmount1;
    private BigDecimal addAmountType1;
    private String addAccEffType2;
    private BigDecimal addAmount2;
    private BigDecimal addAmountType2;
    private String addAccEffType3;
    private BigDecimal addAmount3;
    private BigDecimal addAmountType3;
    private String addAccEffType4;
    private BigDecimal addAmount4;
    private BigDecimal addAmountType4;
    private String addAccEffType5;
    private BigDecimal addAmount5;
    private BigDecimal addAmountType5;
    private Integer altMerchantNumberLength;
    private String altMerchantNumber;
    private Date fpTransDate;
    private String iccPinIndicator;
    private String cardCapability;
    private Date networkProcDate;
    private String programIndicator;
    private String taxReasonCode;
    private Date fpNetworkProcDate;
    private String formatCode;
    private String iin;
    private String mediaCode;
    private Integer messageSeqNumber;
    private String merchantLocationText;
    private String itemizedDocCode;
    private String itemizedDocRefNumber;
    private String transactionId;
    private String extPaymentData;
    private Long messageNumber;
    private String ipn;
    private String invoiceNumber;
    private String rejectReasonCode;
    private String chbckReasonText;
    private String chbckReasonCode;
    private String validBillUnitCode;
    private Date sttlDate;
    private String forwInstCode;
    private String feeReasonText;
    private String feeTypeCode;
    private String receivingInstCode;
    private String sendInstCode;
    private String sendProcCode;
    private String receivingProcCode;
    private String merchantDiscountRate;
    private String lang;
    private String sessionId;
    private String fileName;
    private Date fileDate;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getSplitHash() {
        return splitHash;
    }
    public void setSplitHash(Long splitHash) {
        this.splitHash = splitHash;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getStatusDesc() {
        return statusDesc;
    }
    public void setStatusDesc(String statusDesc) {
        this.statusDesc = statusDesc;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getInstName() {
        return instName;
    }
    public void setInstName(String instName) {
        this.instName = instName;
    }

    public Integer getNetworkId() {
        return networkId;
    }
    public void setNetworkId(Integer networkId) {
        this.networkId = networkId;
    }

    public String getNetworkName() {
        return networkName;
    }
    public void setNetworkName(String networkName) {
        this.networkName = networkName;
    }

    public Long getFileId() {
        return fileId;
    }
    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public boolean isInvalid() {
        return isInvalid;
    }
    public void setInvalid(boolean invalid) {
        isInvalid = invalid;
    }

    public boolean isIncoming() {
        return isIncoming;
    }
    public void setIncoming(boolean incoming) {
        isIncoming = incoming;
    }

    public boolean isReversal() {
        return isReversal;
    }
    public void setReversal(boolean reversal) {
        isReversal = reversal;
    }

    public boolean isCollectionOnly() {
        return isCollectionOnly;
    }
    public void setCollectionOnly(boolean collectionOnly) {
        isCollectionOnly = collectionOnly;
    }

    public boolean isRejected() {
        return isRejected;
    }
    public void setRejected(boolean rejected) {
        isRejected = rejected;
    }

    public Long getRejectId() {
        return rejectId;
    }
    public void setRejectId(Long rejectId) {
        this.rejectId = rejectId;
    }

    public Long getDisputeId() {
        return disputeId;
    }
    public void setDisputeId(Long disputeId) {
        this.disputeId = disputeId;
    }

    public String getImpact() {
        return impact;
    }
    public void setImpact(String impact) {
        this.impact = impact;
    }

    public String getMtid() {
        return mtid;
    }
    public void setMtid(String mtid) {
        this.mtid = mtid;
    }

    public String getFuncCode() {
        return funcCode;
    }
    public void setFuncCode(String funcCode) {
        this.funcCode = funcCode;
    }

    public Integer getPanLength() {
        return panLength;
    }
    public void setPanLength(Integer panLength) {
        this.panLength = panLength;
    }

    public Long getCardHash() {
        return cardHash;
    }
    public void setCardHash(Long cardHash) {
        this.cardHash = cardHash;
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

    public String getProcCode() {
        return procCode;
    }
    public void setProcCode(String procCode) {
        this.procCode = procCode;
    }

    public BigDecimal getTransAmount() {
        return transAmount;
    }
    public void setTransAmount(BigDecimal transAmount) {
        this.transAmount = transAmount;
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

    public Date getTransDate() {
        return transDate;
    }
    public void setTransDate(Date transDate) {
        this.transDate = transDate;
    }

    public String getCardExpirDate() {
        return cardExpirDate;
    }
    public void setCardExpirDate(String cardExpirDate) {
        this.cardExpirDate = cardExpirDate;
    }

    public Date getCaptureDate() {
        return captureDate;
    }
    public void setCaptureDate(Date captureDate) {
        this.captureDate = captureDate;
    }

    public String getMcc() {
        return mcc;
    }
    public void setMcc(String mcc) {
        this.mcc = mcc;
    }

    public String getPdc1() {
        return pdc1;
    }
    public void setPdc1(String pdc1) {
        this.pdc1 = pdc1;
    }

    public String getPdc2() {
        return pdc2;
    }
    public void setPdc2(String pdc2) {
        this.pdc2 = pdc2;
    }

    public String getPdc3() {
        return pdc3;
    }
    public void setPdc3(String pdc3) {
        this.pdc3 = pdc3;
    }

    public String getPdc4() {
        return pdc4;
    }
    public void setPdc4(String pdc4) {
        this.pdc4 = pdc4;
    }

    public String getPdc5() {
        return pdc5;
    }
    public void setPdc5(String pdc5) {
        this.pdc5 = pdc5;
    }

    public String getPdc6() {
        return pdc6;
    }
    public void setPdc6(String pdc6) {
        this.pdc6 = pdc6;
    }

    public String getPdc7() {
        return pdc7;
    }
    public void setPdc7(String pdc7) {
        this.pdc7 = pdc7;
    }

    public String getPdc8() {
        return pdc8;
    }
    public void setPdc8(String pdc8) {
        this.pdc8 = pdc8;
    }

    public String getPdc9() {
        return pdc9;
    }
    public void setPdc9(String pdc9) {
        this.pdc9 = pdc9;
    }

    public String getPdc10() {
        return pdc10;
    }
    public void setPdc10(String pdc10) {
        this.pdc10 = pdc10;
    }

    public String getPdc11() {
        return pdc11;
    }
    public void setPdc11(String pdc11) {
        this.pdc11 = pdc11;
    }

    public String getPdc12() {
        return pdc12;
    }
    public void setPdc12(String pdc12) {
        this.pdc12 = pdc12;
    }

    public String getReasonCode() {
        return reasonCode;
    }
    public void setReasonCode(String reasonCode) {
        this.reasonCode = reasonCode;
    }

    public String getApprovalCodeLength() {
        return approvalCodeLength;
    }
    public void setApprovalCodeLength(String approvalCodeLength) {
        this.approvalCodeLength = approvalCodeLength;
    }

    public Date getIssSttlDate() {
        return issSttlDate;
    }
    public void setIssSttlDate(Date issSttlDate) {
        this.issSttlDate = issSttlDate;
    }

    public String getEci() {
        return eci;
    }
    public void setEci(String eci) {
        this.eci = eci;
    }

    public BigDecimal getFpTransAmount() {
        return fpTransAmount;
    }
    public void setFpTransAmount(BigDecimal fpTransAmount) {
        this.fpTransAmount = fpTransAmount;
    }

    public String getAin() {
        return ain;
    }
    public void setAin(String ain) {
        this.ain = ain;
    }

    public String getApn() {
        return apn;
    }
    public void setApn(String apn) {
        this.apn = apn;
    }

    public String getArn() {
        return arn;
    }
    public void setArn(String arn) {
        this.arn = arn;
    }

    public String getApprovalCode() {
        return approvalCode;
    }
    public void setApprovalCode(String approvalCode) {
        this.approvalCode = approvalCode;
    }

    public String getTerminalNumber() {
        return terminalNumber;
    }
    public void setTerminalNumber(String terminalNumber) {
        this.terminalNumber = terminalNumber;
    }

    public String getMerchantNumber() {
        return merchantNumber;
    }
    public void setMerchantNumber(String merchantNumber) {
        this.merchantNumber = merchantNumber;
    }

    public String getMerchantName() {
        return merchantName;
    }
    public void setMerchantName(String merchantName) {
        this.merchantName = merchantName;
    }

    public String getMerchantAddr1() {
        return merchantAddr1;
    }
    public void setMerchantAddr1(String merchantAddr1) {
        this.merchantAddr1 = merchantAddr1;
    }

    public String getMerchantAddr2() {
        return merchantAddr2;
    }
    public void setMerchantAddr2(String merchantAddr2) {
        this.merchantAddr2 = merchantAddr2;
    }

    public String getMerchantCity() {
        return merchantCity;
    }
    public void setMerchantCity(String merchantCity) {
        this.merchantCity = merchantCity;
    }

    public String getMerchantPostalCode() {
        return merchantPostalCode;
    }
    public void setMerchantPostalCode(String merchantPostalCode) {
        this.merchantPostalCode = merchantPostalCode;
    }

    public String getMerchantCountry() {
        return merchantCountry;
    }
    public void setMerchantCountry(String merchantCountry) {
        this.merchantCountry = merchantCountry;
    }

    public String getMerchantRegion() {
        return merchantRegion;
    }
    public void setMerchantRegion(String merchantRegion) {
        this.merchantRegion = merchantRegion;
    }

    public BigDecimal getIssGrossSttlAmount() {
        return issGrossSttlAmount;
    }
    public void setIssGrossSttlAmount(BigDecimal issGrossSttlAmount) {
        this.issGrossSttlAmount = issGrossSttlAmount;
    }

    public BigDecimal getIssRateAmount() {
        return issRateAmount;
    }
    public void setIssRateAmount(BigDecimal issRateAmount) {
        this.issRateAmount = issRateAmount;
    }

    public String getMatchingKeyType() {
        return matchingKeyType;
    }
    public void setMatchingKeyType(String matchingKeyType) {
        this.matchingKeyType = matchingKeyType;
    }

    public String getMatchingKey() {
        return matchingKey;
    }
    public void setMatchingKey(String matchingKey) {
        this.matchingKey = matchingKey;
    }

    public BigDecimal getIssNetSttlAmount() {
        return issNetSttlAmount;
    }
    public void setIssNetSttlAmount(BigDecimal issNetSttlAmount) {
        this.issNetSttlAmount = issNetSttlAmount;
    }

    public String getIssSttlCurrency() {
        return issSttlCurrency;
    }
    public void setIssSttlCurrency(String issSttlCurrency) {
        this.issSttlCurrency = issSttlCurrency;
    }

    public String getIssSttlDecimalization() {
        return issSttlDecimalization;
    }
    public void setIssSttlDecimalization(String issSttlDecimalization) {
        this.issSttlDecimalization = issSttlDecimalization;
    }

    public String getFpTransCurrency() {
        return fpTransCurrency;
    }
    public void setFpTransCurrency(String fpTransCurrency) {
        this.fpTransCurrency = fpTransCurrency;
    }

    public String getTransDecimalization() {
        return transDecimalization;
    }
    public void setTransDecimalization(String transDecimalization) {
        this.transDecimalization = transDecimalization;
    }

    public String getFpTransDecimalization() {
        return fpTransDecimalization;
    }
    public void setFpTransDecimalization(String fpTransDecimalization) {
        this.fpTransDecimalization = fpTransDecimalization;
    }

    public BigDecimal getFpPresAmount() {
        return fpPresAmount;
    }
    public void setFpPresAmount(BigDecimal fpPresAmount) {
        this.fpPresAmount = fpPresAmount;
    }

    public String getFpPresConversionRate() {
        return fpPresConversionRate;
    }
    public void setFpPresConversionRate(String fpPresConversionRate) {
        this.fpPresConversionRate = fpPresConversionRate;
    }

    public String getFpPresCurrency() {
        return fpPresCurrency;
    }
    public void setFpPresCurrency(String fpPresCurrency) {
        this.fpPresCurrency = fpPresCurrency;
    }

    public String getFpPresDecimalization() {
        return fpPresDecimalization;
    }
    public void setFpPresDecimalization(String fpPresDecimalization) {
        this.fpPresDecimalization = fpPresDecimalization;
    }

    public String getMerchantMultinational() {
        return merchantMultinational;
    }
    public void setMerchantMultinational(String merchantMultinational) {
        this.merchantMultinational = merchantMultinational;
    }

    public String getTransCurrency() {
        return transCurrency;
    }
    public void setTransCurrency(String transCurrency) {
        this.transCurrency = transCurrency;
    }

    public String getAddAccEffType1() {
        return addAccEffType1;
    }
    public void setAddAccEffType1(String addAccEffType1) {
        this.addAccEffType1 = addAccEffType1;
    }

    public BigDecimal getAddAmount1() {
        return addAmount1;
    }
    public void setAddAmount1(BigDecimal addAmount1) {
        this.addAmount1 = addAmount1;
    }

    public BigDecimal getAddAmountType1() {
        return addAmountType1;
    }
    public void setAddAmountType1(BigDecimal addAmountType1) {
        this.addAmountType1 = addAmountType1;
    }

    public String getAddAccEffType2() {
        return addAccEffType2;
    }
    public void setAddAccEffType2(String addAccEffType2) {
        this.addAccEffType2 = addAccEffType2;
    }

    public BigDecimal getAddAmount2() {
        return addAmount2;
    }
    public void setAddAmount2(BigDecimal addAmount2) {
        this.addAmount2 = addAmount2;
    }

    public BigDecimal getAddAmountType2() {
        return addAmountType2;
    }
    public void setAddAmountType2(BigDecimal addAmountType2) {
        this.addAmountType2 = addAmountType2;
    }

    public String getAddAccEffType3() {
        return addAccEffType3;
    }
    public void setAddAccEffType3(String addAccEffType3) {
        this.addAccEffType3 = addAccEffType3;
    }

    public BigDecimal getAddAmount3() {
        return addAmount3;
    }
    public void setAddAmount3(BigDecimal addAmount3) {
        this.addAmount3 = addAmount3;
    }

    public BigDecimal getAddAmountType3() {
        return addAmountType3;
    }
    public void setAddAmountType3(BigDecimal addAmountType3) {
        this.addAmountType3 = addAmountType3;
    }

    public String getAddAccEffType4() {
        return addAccEffType4;
    }
    public void setAddAccEffType4(String addAccEffType4) {
        this.addAccEffType4 = addAccEffType4;
    }

    public BigDecimal getAddAmount4() {
        return addAmount4;
    }
    public void setAddAmount4(BigDecimal addAmount4) {
        this.addAmount4 = addAmount4;
    }

    public BigDecimal getAddAmountType4() {
        return addAmountType4;
    }
    public void setAddAmountType4(BigDecimal addAmountType4) {
        this.addAmountType4 = addAmountType4;
    }

    public String getAddAccEffType5() {
        return addAccEffType5;
    }
    public void setAddAccEffType5(String addAccEffType5) {
        this.addAccEffType5 = addAccEffType5;
    }

    public BigDecimal getAddAmount5() {
        return addAmount5;
    }
    public void setAddAmount5(BigDecimal addAmount5) {
        this.addAmount5 = addAmount5;
    }

    public BigDecimal getAddAmountType5() {
        return addAmountType5;
    }
    public void setAddAmountType5(BigDecimal addAmountType5) {
        this.addAmountType5 = addAmountType5;
    }

    public Integer getAltMerchantNumberLength() {
        return altMerchantNumberLength;
    }
    public void setAltMerchantNumberLength(Integer altMerchantNumberLength) {
        this.altMerchantNumberLength = altMerchantNumberLength;
    }

    public String getAltMerchantNumber() {
        return altMerchantNumber;
    }
    public void setAltMerchantNumber(String altMerchantNumber) {
        this.altMerchantNumber = altMerchantNumber;
    }

    public Date getFpTransDate() {
        return fpTransDate;
    }
    public void setFpTransDate(Date fpTransDate) {
        this.fpTransDate = fpTransDate;
    }

    public String getIccPinIndicator() {
        return iccPinIndicator;
    }
    public void setIccPinIndicator(String iccPinIndicator) {
        this.iccPinIndicator = iccPinIndicator;
    }

    public String getCardCapability() {
        return cardCapability;
    }
    public void setCardCapability(String cardCapability) {
        this.cardCapability = cardCapability;
    }

    public Date getNetworkProcDate() {
        return networkProcDate;
    }
    public void setNetworkProcDate(Date networkProcDate) {
        this.networkProcDate = networkProcDate;
    }

    public String getProgramIndicator() {
        return programIndicator;
    }
    public void setProgramIndicator(String programIndicator) {
        this.programIndicator = programIndicator;
    }

    public String getTaxReasonCode() {
        return taxReasonCode;
    }
    public void setTaxReasonCode(String taxReasonCode) {
        this.taxReasonCode = taxReasonCode;
    }

    public Date getFpNetworkProcDate() {
        return fpNetworkProcDate;
    }
    public void setFpNetworkProcDate(Date fpNetworkProcDate) {
        this.fpNetworkProcDate = fpNetworkProcDate;
    }

    public String getFormatCode() {
        return formatCode;
    }
    public void setFormatCode(String formatCode) {
        this.formatCode = formatCode;
    }

    public String getIin() {
        return iin;
    }
    public void setIin(String iin) {
        this.iin = iin;
    }

    public String getMediaCode() {
        return mediaCode;
    }
    public void setMediaCode(String mediaCode) {
        this.mediaCode = mediaCode;
    }

    public Integer getMessageSeqNumber() {
        return messageSeqNumber;
    }
    public void setMessageSeqNumber(Integer messageSeqNumber) {
        this.messageSeqNumber = messageSeqNumber;
    }

    public String getMerchantLocationText() {
        return merchantLocationText;
    }
    public void setMerchantLocationText(String merchantLocationText) {
        this.merchantLocationText = merchantLocationText;
    }

    public String getItemizedDocCode() {
        return itemizedDocCode;
    }
    public void setItemizedDocCode(String itemizedDocCode) {
        this.itemizedDocCode = itemizedDocCode;
    }

    public String getItemizedDocRefNumber() {
        return itemizedDocRefNumber;
    }
    public void setItemizedDocRefNumber(String itemizedDocRefNumber) {
        this.itemizedDocRefNumber = itemizedDocRefNumber;
    }

    public String getTransactionId() {
        return transactionId;
    }
    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public String getExtPaymentData() {
        return extPaymentData;
    }
    public void setExtPaymentData(String extPaymentData) {
        this.extPaymentData = extPaymentData;
    }

    public Long getMessageNumber() {
        return messageNumber;
    }
    public void setMessageNumber(Long messageNumber) {
        this.messageNumber = messageNumber;
    }

    public String getIpn() {
        return ipn;
    }
    public void setIpn(String ipn) {
        this.ipn = ipn;
    }

    public String getInvoiceNumber() {
        return invoiceNumber;
    }
    public void setInvoiceNumber(String invoiceNumber) {
        this.invoiceNumber = invoiceNumber;
    }

    public String getRejectReasonCode() {
        return rejectReasonCode;
    }
    public void setRejectReasonCode(String rejectReasonCode) {
        this.rejectReasonCode = rejectReasonCode;
    }

    public String getChbckReasonText() {
        return chbckReasonText;
    }
    public void setChbckReasonText(String chbckReasonText) {
        this.chbckReasonText = chbckReasonText;
    }

    public String getChbckReasonCode() {
        return chbckReasonCode;
    }
    public void setChbckReasonCode(String chbckReasonCode) {
        this.chbckReasonCode = chbckReasonCode;
    }

    public String getValidBillUnitCode() {
        return validBillUnitCode;
    }
    public void setValidBillUnitCode(String validBillUnitCode) {
        this.validBillUnitCode = validBillUnitCode;
    }

    public Date getSttlDate() {
        return sttlDate;
    }
    public void setSttlDate(Date sttlDate) {
        this.sttlDate = sttlDate;
    }

    public String getForwInstCode() {
        return forwInstCode;
    }
    public void setForwInstCode(String forwInstCode) {
        this.forwInstCode = forwInstCode;
    }

    public String getFeeReasonText() {
        return feeReasonText;
    }
    public void setFeeReasonText(String feeReasonText) {
        this.feeReasonText = feeReasonText;
    }

    public String getFeeTypeCode() {
        return feeTypeCode;
    }
    public void setFeeTypeCode(String feeTypeCode) {
        this.feeTypeCode = feeTypeCode;
    }

    public String getReceivingInstCode() {
        return receivingInstCode;
    }
    public void setReceivingInstCode(String receivingInstCode) {
        this.receivingInstCode = receivingInstCode;
    }

    public String getSendInstCode() {
        return sendInstCode;
    }
    public void setSendInstCode(String sendInstCode) {
        this.sendInstCode = sendInstCode;
    }

    public String getSendProcCode() {
        return sendProcCode;
    }
    public void setSendProcCode(String sendProcCode) {
        this.sendProcCode = sendProcCode;
    }

    public String getReceivingProcCode() {
        return receivingProcCode;
    }
    public void setReceivingProcCode(String receivingProcCode) {
        this.receivingProcCode = receivingProcCode;
    }

    public String getMerchantDiscountRate() {
        return merchantDiscountRate;
    }
    public void setMerchantDiscountRate(String merchantDiscountRate) {
        this.merchantDiscountRate = merchantDiscountRate;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getSessionId() {
        return sessionId;
    }
    public void setSessionId(String sessionId) {
        this.sessionId = sessionId;
    }

    public String getFileName() {
        return fileName;
    }
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Date getFileDate() {
        return fileDate;
    }
    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        return null;
    }
    @Override
    public AmexFinMessage clone() throws CloneNotSupportedException {
        return (AmexFinMessage)super.clone();
    }
}

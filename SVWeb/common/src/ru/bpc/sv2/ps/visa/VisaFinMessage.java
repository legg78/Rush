package ru.bpc.sv2.ps.visa;

import java.util.Date;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.math.BigDecimal;

public class VisaFinMessage implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private String status;
	private String statusDesc;
	private Long fileId;
	private Long batchId;
	private Integer recordNumber;
	private Boolean isReversal;
	private Boolean isIncoming;
	private Boolean isReturned;
	private Boolean isInvalid;
	private Long disputeId;
	private String rrn;
	private Integer instId;
	private String instName;
	private Integer networkId;
	private String networkName;
	private String transCode;
	private String transCodeQualifier;
	private Long cardId;
	private String cardMask;
	private Long cardHash;
	private BigDecimal operAmount;
	private String operCurrency;
	private Date operDate;
	private BigDecimal sttlAmount;
	private String sttlCurrency;
	private BigDecimal networkAmount;
	private String networkCurrency;
	private String floorLimitInd;
	private String exeptFileInd;
	private String pcasInd;
	private String arn;
	private String acquirerBin;
	private String acqBusinessId;
	private String merchantName;
	private String merchantCity;
	private String merchantCountry;
	private String merchantPostalCode;
	private String merchantRegion;
	private String merchantStreet;
	private String mcc;
	private String reqPayService;
	private String usageCode;
	private String reasonCode;
	private String settlementFlag;
	private String authCharInd;
	private String authCode;
	private String posTerminalCap;
	private String interFeeInd;
	private String crdhIdMethod;
	private String collectOnlyFlag;
	private String posEntryMode;
	private String centralProcDate;
	private String reimburstAttr;
	private String issWorkstBin;
	private String acqWorkstBin;
	private String chargebackRefNum;
	private String documInd;
	private String memberMsgText;
	private String specCondInd;
	private String feeProgramInd;
	private String issuerCharge;
	private String merchantNumber;
	private String terminalNumber;
	private String nationalReimbFee;
	private String electrCommInd;
	private String specChargebackInd;
	private String interfaceTraceNum;
	private String unattAcceptTermInd;
	private String prepaidCardInd;
	private String serviceDevelopment;
	private String avsRespCode;
	private String authSourceCode;
	private String purchIdFormat;
	private String accountSelection;
	private String installmentPayCount;
	private String purchId;
	private String cashback;
	private String chipCondCode;
	private String posEnvironment;
	private String transactionType;
	private String cardSeqNumber;
	private String terminalProfile;
	private String unpredictNumber;
	private String applTransCounter;
	private String applInterchProfile;
	private String cryptogram;
	private String cardVerifResult;
	private String issuerApplData;
	private String issuerScriptResult;
	private String cardExpirDate;
	private String cryptogramVersion;
	private String cvv2ResultCode;
	private String authRespCode;
	private String cryptogramInfoData;
	private String transactionId;
	private String merchantVerifValue;
	private Integer hostInstId;
	private String procBin;
	private String chargebackReasonCode;
	private String destinationChannel;
	private String sourceChannel;
	private String acqInstBin;
	private String spendQualifiedInd;
	private String lang;
	private String recipientName;
	
	private String merchantLocation;
    private Date dateFrom;
    private Date dateTo;
    private Date operDateFrom;
    private Date operDateTo;
    private Long sessionId;
    private Long sessionFileId;
    private String fileName;
    private Date fileDate;

	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public String getStatus(){
		return this.status;
	}
	
	public void setStatus(String status){
		this.status = status;
	}
	
	public String getStatusDesc(){
		return this.statusDesc;
	}
	
	public void setStatusDesc(String statusDesc){
		this.statusDesc = statusDesc;
	}
	
	public Long getFileId(){
		return this.fileId;
	}
	
	public void setFileId(Long fileId){
		this.fileId = fileId;
	}
	
	public Long getBatchId(){
		return this.batchId;
	}
	
	public void setBatchId(Long batchId){
		this.batchId = batchId;
	}
	
	public Integer getRecordNumber(){
		return this.recordNumber;
	}
	
	public void setRecordNumber(Integer recordNumber){
		this.recordNumber = recordNumber;
	}
	
	public Boolean getIsReversal(){
		return this.isReversal;
	}
	
	public void setIsReversal(Boolean isReversal){
		this.isReversal = isReversal;
	}
	
	public Boolean getIsIncoming(){
		return this.isIncoming;
	}
	
	public void setIsIncoming(Boolean isIncoming){
		this.isIncoming = isIncoming;
	}
	
	public Boolean getIsReturned(){
		return this.isReturned;
	}
	
	public void setIsReturned(Boolean isReturned){
		this.isReturned = isReturned;
	}
	
	public Boolean getIsInvalid(){
		return this.isInvalid;
	}
	
	public void setIsInvalid(Boolean isInvalid){
		this.isInvalid = isInvalid;
	}
	
	public Long getDisputeId(){
		return this.disputeId;
	}
	
	public void setDisputeId(Long disputeId){
		this.disputeId = disputeId;
	}
	
	public String getRrn(){
		return this.rrn;
	}
	
	public void setRrn(String rrn){
		this.rrn = rrn;
	}
	
	public Integer getInstId(){
		return this.instId;
	}
	
	public void setInstId(Integer instId){
		this.instId = instId;
	}
	
	public String getInstName(){
		return this.instName;
	}
	
	public void setInstName(String instName){
		this.instName = instName;
	}
	
	public Integer getNetworkId(){
		return this.networkId;
	}
	
	public void setNetworkId(Integer networkId){
		this.networkId = networkId;
	}
	
	public String getNetworkName(){
		return this.networkName;
	}
	
	public void setNetworkName(String networkName){
		this.networkName = networkName;
	}
	
	public String getTransCode(){
		return this.transCode;
	}
	
	public void setTransCode(String transCode){
		this.transCode = transCode;
	}
	
	public String getTransCodeQualifier(){
		return this.transCodeQualifier;
	}
	
	public void setTransCodeQualifier(String transCodeQualifier){
		this.transCodeQualifier = transCodeQualifier;
	}
	
	public Long getCardId(){
		return this.cardId;
	}
	
	public void setCardId(Long cardId){
		this.cardId = cardId;
	}
	
	public String getCardMask(){
		return this.cardMask;
	}
	
	public void setCardMask(String cardMask){
		this.cardMask = cardMask;
	}
	
	public Long getCardHash(){
		return this.cardHash;
	}
	
	public void setCardHash(Long cardHash){
		this.cardHash = cardHash;
	}
	
	public BigDecimal getOperAmount(){
		return this.operAmount;
	}
	
	public void setOperAmount(BigDecimal operAmount){
		this.operAmount = operAmount;
	}
	
	public String getOperCurrency(){
		return this.operCurrency;
	}
	
	public void setOperCurrency(String operCurrency){
		this.operCurrency = operCurrency;
	}
	
	public Date getOperDate(){
		return this.operDate;
	}
	
	public void setOperDate(Date operDate){
		this.operDate = operDate;
	}
	
	public BigDecimal getSttlAmount(){
		return this.sttlAmount;
	}
	
	public void setSttlAmount(BigDecimal sttlAmount){
		this.sttlAmount = sttlAmount;
	}
	
	public String getSttlCurrency(){
		return this.sttlCurrency;
	}
	
	public void setSttlCurrency(String sttlCurrency){
		this.sttlCurrency = sttlCurrency;
	}
	
	public BigDecimal getNetworkAmount(){
		return this.networkAmount;
	}
	
	public void setNetworkAmount(BigDecimal networkAmount){
		this.networkAmount = networkAmount;
	}
	
	public String getNetworkCurrency(){
		return this.networkCurrency;
	}
	
	public void setNetworkCurrency(String networkCurrency){
		this.networkCurrency = networkCurrency;
	}
	
	public String getFloorLimitInd(){
		return this.floorLimitInd;
	}
	
	public void setFloorLimitInd(String floorLimitInd){
		this.floorLimitInd = floorLimitInd;
	}
	
	public String getExeptFileInd(){
		return this.exeptFileInd;
	}
	
	public void setExeptFileInd(String exeptFileInd){
		this.exeptFileInd = exeptFileInd;
	}
	
	public String getPcasInd(){
		return this.pcasInd;
	}
	
	public void setPcasInd(String pcasInd){
		this.pcasInd = pcasInd;
	}
	
	public String getArn(){
		return this.arn;
	}
	
	public void setArn(String arn){
		this.arn = arn;
	}
	
	public String getAcquirerBin(){
		return this.acquirerBin;
	}
	
	public void setAcquirerBin(String acquirerBin){
		this.acquirerBin = acquirerBin;
	}
	
	public String getAcqBusinessId(){
		return this.acqBusinessId;
	}
	
	public void setAcqBusinessId(String acqBusinessId){
		this.acqBusinessId = acqBusinessId;
	}
	
	public String getMerchantName(){
		return this.merchantName;
	}
	
	public void setMerchantName(String merchantName){
		this.merchantName = merchantName;
	}
	
	public String getMerchantCity(){
		return this.merchantCity;
	}
	
	public void setMerchantCity(String merchantCity){
		this.merchantCity = merchantCity;
	}
	
	public String getMerchantCountry(){
		return this.merchantCountry;
	}
	
	public void setMerchantCountry(String merchantCountry){
		this.merchantCountry = merchantCountry;
	}
	
	public String getMerchantPostalCode(){
		return this.merchantPostalCode;
	}
	
	public void setMerchantPostalCode(String merchantPostalCode){
		this.merchantPostalCode = merchantPostalCode;
	}
	
	public String getMerchantRegion(){
		return this.merchantRegion;
	}
	
	public void setMerchantRegion(String merchantRegion){
		this.merchantRegion = merchantRegion;
	}
	
	public String getMerchantStreet(){
		return this.merchantStreet;
	}
	
	public void setMerchantStreet(String merchantStreet){
		this.merchantStreet = merchantStreet;
	}
	
	public String getMcc(){
		return this.mcc;
	}
	
	public void setMcc(String mcc){
		this.mcc = mcc;
	}
	
	public String getReqPayService(){
		return this.reqPayService;
	}
	
	public void setReqPayService(String reqPayService){
		this.reqPayService = reqPayService;
	}
	
	public String getUsageCode(){
		return this.usageCode;
	}
	
	public void setUsageCode(String usageCode){
		this.usageCode = usageCode;
	}
	
	public String getReasonCode(){
		return this.reasonCode;
	}
	
	public void setReasonCode(String reasonCode){
		this.reasonCode = reasonCode;
	}
	
	public String getSettlementFlag(){
		return this.settlementFlag;
	}
	
	public void setSettlementFlag(String settlementFlag){
		this.settlementFlag = settlementFlag;
	}
	
	public String getAuthCharInd(){
		return this.authCharInd;
	}
	
	public void setAuthCharInd(String authCharInd){
		this.authCharInd = authCharInd;
	}
	
	public String getAuthCode(){
		return this.authCode;
	}
	
	public void setAuthCode(String authCode){
		this.authCode = authCode;
	}
	
	public String getPosTerminalCap(){
		return this.posTerminalCap;
	}
	
	public void setPosTerminalCap(String posTerminalCap){
		this.posTerminalCap = posTerminalCap;
	}
	
	public String getInterFeeInd(){
		return this.interFeeInd;
	}
	
	public void setInterFeeInd(String interFeeInd){
		this.interFeeInd = interFeeInd;
	}
	
	public String getCrdhIdMethod(){
		return this.crdhIdMethod;
	}
	
	public void setCrdhIdMethod(String crdhIdMethod){
		this.crdhIdMethod = crdhIdMethod;
	}
	
	public String getCollectOnlyFlag(){
		return this.collectOnlyFlag;
	}
	
	public void setCollectOnlyFlag(String collectOnlyFlag){
		this.collectOnlyFlag = collectOnlyFlag;
	}
	
	public String getPosEntryMode(){
		return this.posEntryMode;
	}
	
	public void setPosEntryMode(String posEntryMode){
		this.posEntryMode = posEntryMode;
	}
	
	public String getCentralProcDate(){
		return this.centralProcDate;
	}
	
	public void setCentralProcDate(String centralProcDate){
		this.centralProcDate = centralProcDate;
	}
	
	public String getReimburstAttr(){
		return this.reimburstAttr;
	}
	
	public void setReimburstAttr(String reimburstAttr){
		this.reimburstAttr = reimburstAttr;
	}
	
	public String getIssWorkstBin(){
		return this.issWorkstBin;
	}
	
	public void setIssWorkstBin(String issWorkstBin){
		this.issWorkstBin = issWorkstBin;
	}
	
	public String getAcqWorkstBin(){
		return this.acqWorkstBin;
	}
	
	public void setAcqWorkstBin(String acqWorkstBin){
		this.acqWorkstBin = acqWorkstBin;
	}
	
	public String getChargebackRefNum(){
		return this.chargebackRefNum;
	}
	
	public void setChargebackRefNum(String chargebackRefNum){
		this.chargebackRefNum = chargebackRefNum;
	}
	
	public String getDocumInd(){
		return this.documInd;
	}
	
	public void setDocumInd(String documInd){
		this.documInd = documInd;
	}
	
	public String getMemberMsgText(){
		return this.memberMsgText;
	}
	
	public void setMemberMsgText(String memberMsgText){
		this.memberMsgText = memberMsgText;
	}
	
	public String getSpecCondInd(){
		return this.specCondInd;
	}
	
	public void setSpecCondInd(String specCondInd){
		this.specCondInd = specCondInd;
	}
	
	public String getFeeProgramInd(){
		return this.feeProgramInd;
	}
	
	public void setFeeProgramInd(String feeProgramInd){
		this.feeProgramInd = feeProgramInd;
	}
	
	public String getIssuerCharge(){
		return this.issuerCharge;
	}
	
	public void setIssuerCharge(String issuerCharge){
		this.issuerCharge = issuerCharge;
	}
	
	public String getMerchantNumber(){
		return this.merchantNumber;
	}
	
	public void setMerchantNumber(String merchantNumber){
		this.merchantNumber = merchantNumber;
	}
	
	public String getTerminalNumber(){
		return this.terminalNumber;
	}
	
	public void setTerminalNumber(String terminalNumber){
		this.terminalNumber = terminalNumber;
	}
	
	public String getNationalReimbFee(){
		return this.nationalReimbFee;
	}
	
	public void setNationalReimbFee(String nationalReimbFee){
		this.nationalReimbFee = nationalReimbFee;
	}
	
	public String getElectrCommInd(){
		return this.electrCommInd;
	}
	
	public void setElectrCommInd(String electrCommInd){
		this.electrCommInd = electrCommInd;
	}
	
	public String getSpecChargebackInd(){
		return this.specChargebackInd;
	}
	
	public void setSpecChargebackInd(String specChargebackInd){
		this.specChargebackInd = specChargebackInd;
	}
	
	public String getInterfaceTraceNum(){
		return this.interfaceTraceNum;
	}
	
	public void setInterfaceTraceNum(String interfaceTraceNum){
		this.interfaceTraceNum = interfaceTraceNum;
	}
	
	public String getUnattAcceptTermInd(){
		return this.unattAcceptTermInd;
	}
	
	public void setUnattAcceptTermInd(String unattAcceptTermInd){
		this.unattAcceptTermInd = unattAcceptTermInd;
	}
	
	public String getPrepaidCardInd(){
		return this.prepaidCardInd;
	}
	
	public void setPrepaidCardInd(String prepaidCardInd){
		this.prepaidCardInd = prepaidCardInd;
	}
	
	public String getServiceDevelopment(){
		return this.serviceDevelopment;
	}
	
	public void setServiceDevelopment(String serviceDevelopment){
		this.serviceDevelopment = serviceDevelopment;
	}
	
	public String getAvsRespCode(){
		return this.avsRespCode;
	}
	
	public void setAvsRespCode(String avsRespCode){
		this.avsRespCode = avsRespCode;
	}
	
	public String getAuthSourceCode(){
		return this.authSourceCode;
	}
	
	public void setAuthSourceCode(String authSourceCode){
		this.authSourceCode = authSourceCode;
	}
	
	public String getPurchIdFormat(){
		return this.purchIdFormat;
	}
	
	public void setPurchIdFormat(String purchIdFormat){
		this.purchIdFormat = purchIdFormat;
	}
	
	public String getAccountSelection(){
		return this.accountSelection;
	}
	
	public void setAccountSelection(String accountSelection){
		this.accountSelection = accountSelection;
	}
	
	public String getInstallmentPayCount(){
		return this.installmentPayCount;
	}
	
	public void setInstallmentPayCount(String installmentPayCount){
		this.installmentPayCount = installmentPayCount;
	}
	
	public String getPurchId(){
		return this.purchId;
	}
	
	public void setPurchId(String purchId){
		this.purchId = purchId;
	}
	
	public String getCashback(){
		return this.cashback;
	}
	
	public void setCashback(String cashback){
		this.cashback = cashback;
	}
	
	public String getChipCondCode(){
		return this.chipCondCode;
	}
	
	public void setChipCondCode(String chipCondCode){
		this.chipCondCode = chipCondCode;
	}
	
	public String getPosEnvironment(){
		return this.posEnvironment;
	}
	
	public void setPosEnvironment(String posEnvironment){
		this.posEnvironment = posEnvironment;
	}
	
	public String getTransactionType(){
		return this.transactionType;
	}
	
	public void setTransactionType(String transactionType){
		this.transactionType = transactionType;
	}
	
	public String getCardSeqNumber(){
		return this.cardSeqNumber;
	}
	
	public void setCardSeqNumber(String cardSeqNumber){
		this.cardSeqNumber = cardSeqNumber;
	}
	
	public String getTerminalProfile(){
		return this.terminalProfile;
	}
	
	public void setTerminalProfile(String terminalProfile){
		this.terminalProfile = terminalProfile;
	}
	
	public String getUnpredictNumber(){
		return this.unpredictNumber;
	}
	
	public void setUnpredictNumber(String unpredictNumber){
		this.unpredictNumber = unpredictNumber;
	}
	
	public String getApplTransCounter(){
		return this.applTransCounter;
	}
	
	public void setApplTransCounter(String applTransCounter){
		this.applTransCounter = applTransCounter;
	}
	
	public String getApplInterchProfile(){
		return this.applInterchProfile;
	}
	
	public void setApplInterchProfile(String applInterchProfile){
		this.applInterchProfile = applInterchProfile;
	}
	
	public String getCryptogram(){
		return this.cryptogram;
	}
	
	public void setCryptogram(String cryptogram){
		this.cryptogram = cryptogram;
	}
	
	public String getCardVerifResult(){
		return this.cardVerifResult;
	}
	
	public void setCardVerifResult(String cardVerifResult){
		this.cardVerifResult = cardVerifResult;
	}
	
	public String getIssuerApplData(){
		return this.issuerApplData;
	}
	
	public void setIssuerApplData(String issuerApplData){
		this.issuerApplData = issuerApplData;
	}
	
	public String getIssuerScriptResult(){
		return this.issuerScriptResult;
	}
	
	public void setIssuerScriptResult(String issuerScriptResult){
		this.issuerScriptResult = issuerScriptResult;
	}
	
	public String getCardExpirDate(){
		return this.cardExpirDate;
	}
	
	public void setCardExpirDate(String cardExpirDate){
		this.cardExpirDate = cardExpirDate;
	}
	
	public String getCryptogramVersion(){
		return this.cryptogramVersion;
	}
	
	public void setCryptogramVersion(String cryptogramVersion){
		this.cryptogramVersion = cryptogramVersion;
	}
	
	public String getCvv2ResultCode(){
		return this.cvv2ResultCode;
	}
	
	public void setCvv2ResultCode(String cvv2ResultCode){
		this.cvv2ResultCode = cvv2ResultCode;
	}
	
	public String getAuthRespCode(){
		return this.authRespCode;
	}
	
	public void setAuthRespCode(String authRespCode){
		this.authRespCode = authRespCode;
	}
	
	public String getCryptogramInfoData(){
		return this.cryptogramInfoData;
	}
	
	public void setCryptogramInfoData(String cryptogramInfoData){
		this.cryptogramInfoData = cryptogramInfoData;
	}
	
	public String getTransactionId(){
		return this.transactionId;
	}
	
	public void setTransactionId(String transactionId){
		this.transactionId = transactionId;
	}
	
	public String getMerchantVerifValue(){
		return this.merchantVerifValue;
	}
	
	public void setMerchantVerifValue(String merchantVerifValue){
		this.merchantVerifValue = merchantVerifValue;
	}
	
	public Integer getHostInstId(){
		return this.hostInstId;
	}
	
	public void setHostInstId(Integer hostInstId){
		this.hostInstId = hostInstId;
	}
	
	public String getProcBin(){
		return this.procBin;
	}
	
	public void setProcBin(String procBin){
		this.procBin = procBin;
	}
	
	public String getChargebackReasonCode(){
		return this.chargebackReasonCode;
	}
	
	public void setChargebackReasonCode(String chargebackReasonCode){
		this.chargebackReasonCode = chargebackReasonCode;
	}
	
	public String getDestinationChannel(){
		return this.destinationChannel;
	}
	
	public void setDestinationChannel(String destinationChannel){
		this.destinationChannel = destinationChannel;
	}
	
	public String getSourceChannel(){
		return this.sourceChannel;
	}
	
	public void setSourceChannel(String sourceChannel){
		this.sourceChannel = sourceChannel;
	}
	
	public String getAcqInstBin(){
		return this.acqInstBin;
	}
	
	public void setAcqInstBin(String acqInstBin){
		this.acqInstBin = acqInstBin;
	}
	
	public String getSpendQualifiedInd(){
		return this.spendQualifiedInd;
	}
	
	public void setSpendQualifiedInd(String spendQualifiedInd){
		this.spendQualifiedInd = spendQualifiedInd;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}

	public String getRecipientName() {
		return recipientName;
	}

	public void setRecipientName(String recipientName) {
		this.recipientName = recipientName;
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

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
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

	public Date getOperDateFrom() {
		return operDateFrom;
	}

	public void setOperDateFrom(Date operDateFrom) {
		this.operDateFrom = operDateFrom;
	}

	public Date getOperDateTo() {
		return operDateTo;
	}

	public void setOperDateTo(Date operDateTo) {
		this.operDateTo = operDateTo;
	}

	public Long getSessionFileId() {
		return sessionFileId;
	}

	public void setSessionFileId(Long sessionFileId) {
		this.sessionFileId = sessionFileId;
	}

	public String getMerchantLocation() {
		return merchantLocation;
	}

	public void setMerchantLocation(String merchantLocation) {
		this.merchantLocation = merchantLocation;
	}

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
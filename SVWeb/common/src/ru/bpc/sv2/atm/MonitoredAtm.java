package ru.bpc.sv2.atm;

import java.util.Date;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class MonitoredAtm implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Integer id;
	private String atmType;
	private String atmTypeName;
	private String atmModel;
	private String serialNumber;
	private String placementType;
	private String placementTypeName;
	private String availabilityType;
	private String availabilityTypeName;
	private String operatingHours;
	private Integer localDateGap;
	private Integer cassetteCount;
	private String keyChangeAlgo;
	private String keyChangeAlgoName;
	private String counterSyncCond;
	private Integer rejectDispWarn;
	private Integer dispRestWarn;
	private Integer receiptWarn;
	private Integer cardCaptureWarn;
	private Integer noteMaxCount;
	private Integer scenarioId;
	private Integer hopperCount;
	private String manualSynch;
	private String establConnSynch;
	private String counterMismatchSynch;
	private String onlineInSynch;
	private String onlineOutSynch;
	private String safeCloseSynch;
	private String dispErrorSynch;
	private String periodicSynch;
	private Boolean periodicAllOper;
	private Integer periodicOperCount;
	private Long collId;
	private Integer collOperCount;
	private Long lastOperId;
	private Date lastOperDate;
	private Integer receiptLoaded;
	private Integer receiptPrinted;
	private Integer receiptRemained;
	private Integer cardCaptured;
	private String cardReaderStatus;
	private String cardReaderStatusName;
	private String rcptStatus;
	private String rcptStatusName;
	private String rcptPaperStatus;
	private String rcptPaperStatusName;
	private String rcptRibbonStatus;
	private String rcptRibbonStatusName;
	private String rcptHeadStatus;
	private String rcptHeadStatusName;
	private String rcptKnifeStatus;
	private String rcptKnifeStatusName;
	private String jrnlStatus;
	private String jrnlStatusName;
	private String jrnlPaperStatus;
	private String jrnlPaperStatusName;
	private String jrnlRibbonStatus;
	private String jrnlRibbonStatusName;
	private String jrnlHeadStatus;
	private String jrnlHeadStatusName;
	private String ejrnlStatus;
	private String ejrnlStatusName;
	private String ejrnlSpaceStatus;
	private String ejrnlSpaceStatusName;
	private String stmtStatus;
	private String stmtStatusName;
	private String stmtPaperStatus;
	private String stmtPaperStatusName;
	private String stmtRibbonStat;
	private String stmtRibbonStatName;
	private String stmtHeadStatus;
	private String stmtHeadStatusName;
	private String stmtKnifeStatus;
	private String stmtKnifeStatusName;
	private String stmtCaptBinStatus;
	private String stmtCaptBinStatusName;
	private String todClockStatus;
	private String todClockStatusName;
	private String depositoryStatus;
	private String depositoryStatusName;
	private String nightSafeStatus;
	private String nightSafeStatusName;
	private String encryptorStatus;
	private String encryptorStatusName;
	private String tscreenKeybStatus;
	private String tscreenKeybStatusName;
	private String voiceGuidanceStatus;
	private String voiceGuidanceStatusName;
	private String cameraStatus;
	private String cameraStatusName;
	private String bunchAcptStatus;
	private String bunchAcptStatusName;
	private String envelopeDispStatus;
	private String envelopeDispStatusName;
	private String chequeModuleStatus;
	private String chequeModuleStatusName;
	private String barcodeReaderStatus;
	private String barcodeReaderStatusName;
	private String coinDispStatus;
	private String coinDispStatusName;
	private String dispenserStatus;
	private String dispenserStatusName;
	private String workflowStatus;
	private String workflowStatusName;
	private String serviceStatus;
	private String serviceStatusName;
	private String lang;
	private Integer instId;
	private Integer agentId;
	private String agentName;
	private Integer standardId;
	private String standardName;
	private String financeStatus;
	private String financeStatusName;
	private String techStatus;
	private String techStatusName;
	private String consumablesStatus;
	private String atmAddress;
	private Date atmDate;
	private Long workTime;
	private Boolean cashInPresent;
	private String initiator;
	private String format;
	private Boolean isEnabled;
	private String communicationPlugin;
	private String remoteAddress;
	private String remotePort;
	private Boolean monitorConnection;
	private String localPort;
	private String terminalNumber;
	private String terminalDescription;
	private Integer merchantId;
	private String merchantNumber;
	private String merchantDescription;
	private String connectionStatus;
    private Integer groupId;
    private String agentNumber;
	
	public Object getModelId() {
		return getId();
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	public String getAtmType(){
		return this.atmType;
	}
	
	public void setAtmType(String atmType){
		this.atmType = atmType;
	}
	
	public String getAtmTypeName(){
		return this.atmTypeName;
	}
	
	public void setAtmTypeName(String atmTypeName){
		this.atmTypeName = atmTypeName;
	}
	
	public String getAtmModel(){
		return this.atmModel;
	}
	
	public void setAtmModel(String atmModel){
		this.atmModel = atmModel;
	}
	
	public String getSerialNumber(){
		return this.serialNumber;
	}
	
	public void setSerialNumber(String serialNumber){
		this.serialNumber = serialNumber;
	}
	
	public String getPlacementType(){
		return this.placementType;
	}
	
	public void setPlacementType(String placementType){
		this.placementType = placementType;
	}
	
	public String getPlacementTypeName(){
		return this.placementTypeName;
	}
	
	public void setPlacementTypeName(String placementTypeName){
		this.placementTypeName = placementTypeName;
	}
	
	public String getAvailabilityType(){
		return this.availabilityType;
	}
	
	public void setAvailabilityType(String availabilityType){
		this.availabilityType = availabilityType;
	}
	
	public String getAvailabilityTypeName(){
		return this.availabilityTypeName;
	}
	
	public void setAvailabilityTypeName(String availabilityTypeName){
		this.availabilityTypeName = availabilityTypeName;
	}
	
	public String getOperatingHours(){
		return this.operatingHours;
	}
	
	public void setOperatingHours(String operatingHours){
		this.operatingHours = operatingHours;
	}
	
	public Integer getLocalDateGap(){
		return this.localDateGap;
	}
	
	public void setLocalDateGap(Integer localDateGap){
		this.localDateGap = localDateGap;
	}
	
	public Integer getCassetteCount(){
		return this.cassetteCount;
	}
	
	public void setCassetteCount(Integer cassetteCount){
		this.cassetteCount = cassetteCount;
	}
	
	public String getKeyChangeAlgo(){
		return this.keyChangeAlgo;
	}
	
	public void setKeyChangeAlgo(String keyChangeAlgo){
		this.keyChangeAlgo = keyChangeAlgo;
	}
	
	public String getKeyChangeAlgoName(){
		return this.keyChangeAlgoName;
	}
	
	public void setKeyChangeAlgoName(String keyChangeAlgoName){
		this.keyChangeAlgoName = keyChangeAlgoName;
	}
	
	public String getCounterSyncCond(){
		return this.counterSyncCond;
	}
	
	public void setCounterSyncCond(String counterSyncCond){
		this.counterSyncCond = counterSyncCond;
	}
	
	public Integer getRejectDispWarn(){
		return this.rejectDispWarn;
	}
	
	public void setRejectDispWarn(Integer rejectDispWarn){
		this.rejectDispWarn = rejectDispWarn;
	}
	
	public Integer getDispRestWarn(){
		return this.dispRestWarn;
	}
	
	public void setDispRestWarn(Integer dispRestWarn){
		this.dispRestWarn = dispRestWarn;
	}
	
	public Integer getReceiptWarn(){
		return this.receiptWarn;
	}
	
	public void setReceiptWarn(Integer receiptWarn){
		this.receiptWarn = receiptWarn;
	}
	
	public Integer getCardCaptureWarn(){
		return this.cardCaptureWarn;
	}
	
	public void setCardCaptureWarn(Integer cardCaptureWarn){
		this.cardCaptureWarn = cardCaptureWarn;
	}
	
	public Integer getNoteMaxCount(){
		return this.noteMaxCount;
	}
	
	public void setNoteMaxCount(Integer noteMaxCount){
		this.noteMaxCount = noteMaxCount;
	}
	
	public Integer getScenarioId(){
		return this.scenarioId;
	}
	
	public void setScenarioId(Integer scenarioId){
		this.scenarioId = scenarioId;
	}
	
	public Integer getHopperCount(){
		return this.hopperCount;
	}
	
	public void setHopperCount(Integer hopperCount){
		this.hopperCount = hopperCount;
	}
	
	public String getManualSynch(){
		return this.manualSynch;
	}
	
	public void setManualSynch(String manualSynch){
		this.manualSynch = manualSynch;
	}
	
	public String getEstablConnSynch(){
		return this.establConnSynch;
	}
	
	public void setEstablConnSynch(String establConnSynch){
		this.establConnSynch = establConnSynch;
	}
	
	public String getCounterMismatchSynch(){
		return this.counterMismatchSynch;
	}
	
	public void setCounterMismatchSynch(String counterMismatchSynch){
		this.counterMismatchSynch = counterMismatchSynch;
	}
	
	public String getOnlineInSynch(){
		return this.onlineInSynch;
	}
	
	public void setOnlineInSynch(String onlineInSynch){
		this.onlineInSynch = onlineInSynch;
	}
	
	public String getOnlineOutSynch(){
		return this.onlineOutSynch;
	}
	
	public void setOnlineOutSynch(String onlineOutSynch){
		this.onlineOutSynch = onlineOutSynch;
	}
	
	public String getSafeCloseSynch(){
		return this.safeCloseSynch;
	}
	
	public void setSafeCloseSynch(String safeCloseSynch){
		this.safeCloseSynch = safeCloseSynch;
	}
	
	public String getDispErrorSynch(){
		return this.dispErrorSynch;
	}
	
	public void setDispErrorSynch(String dispErrorSynch){
		this.dispErrorSynch = dispErrorSynch;
	}
	
	public String getPeriodicSynch(){
		return this.periodicSynch;
	}
	
	public void setPeriodicSynch(String periodicSynch){
		this.periodicSynch = periodicSynch;
	}
	
	public Boolean getPeriodicAllOper(){
		return this.periodicAllOper;
	}
	
	public void setPeriodicAllOper(Boolean periodicAllOper){
		this.periodicAllOper = periodicAllOper;
	}
	
	public Integer getPeriodicOperCount(){
		return this.periodicOperCount;
	}
	
	public void setPeriodicOperCount(Integer periodicOperCount){
		this.periodicOperCount = periodicOperCount;
	}
	
	public Long getCollId(){
		return this.collId;
	}
	
	public void setCollId(Long collId){
		this.collId = collId;
	}
	
	public Integer getCollOperCount(){
		return this.collOperCount;
	}
	
	public void setCollOperCount(Integer collOperCount){
		this.collOperCount = collOperCount;
	}
	
	public Long getLastOperId(){
		return this.lastOperId;
	}
	
	public void setLastOperId(Long lastOperId){
		this.lastOperId = lastOperId;
	}
	
	public Date getLastOperDate(){
		return this.lastOperDate;
	}
	
	public void setLastOperDate(Date lastOperDate){
		this.lastOperDate = lastOperDate;
	}
	
	public Integer getReceiptLoaded(){
		return this.receiptLoaded;
	}
	
	public void setReceiptLoaded(Integer receiptLoaded){
		this.receiptLoaded = receiptLoaded;
	}
	
	public Integer getReceiptPrinted(){
		return this.receiptPrinted;
	}
	
	public void setReceiptPrinted(Integer receiptPrinted){
		this.receiptPrinted = receiptPrinted;
	}
	
	public Integer getReceiptRemained(){
		return this.receiptRemained;
	}
	
	public void setReceiptRemained(Integer receiptRemained){
		this.receiptRemained = receiptRemained;
	}
	
	public Integer getCardCaptured(){
		return this.cardCaptured;
	}
	
	public void setCardCaptured(Integer cardCaptured){
		this.cardCaptured = cardCaptured;
	}
	
	public String getCardReaderStatus(){
		return this.cardReaderStatus;
	}
	
	public void setCardReaderStatus(String cardReaderStatus){
		this.cardReaderStatus = cardReaderStatus;
	}
	
	public String getCardReaderStatusName(){
		return this.cardReaderStatusName;
	}
	
	public void setCardReaderStatusName(String cardReaderStatusName){
		this.cardReaderStatusName = cardReaderStatusName;
	}
	
	public String getRcptStatus(){
		return this.rcptStatus;
	}
	
	public void setRcptStatus(String rcptStatus){
		this.rcptStatus = rcptStatus;
	}
	
	public String getRcptStatusName(){
		return this.rcptStatusName;
	}
	
	public void setRcptStatusName(String rcptStatusName){
		this.rcptStatusName = rcptStatusName;
	}
	
	public String getRcptPaperStatus(){
		return this.rcptPaperStatus;
	}
	
	public void setRcptPaperStatus(String rcptPaperStatus){
		this.rcptPaperStatus = rcptPaperStatus;
	}
	
	public String getRcptPaperStatusName(){
		return this.rcptPaperStatusName;
	}
	
	public void setRcptPaperStatusName(String rcptPaperStatusName){
		this.rcptPaperStatusName = rcptPaperStatusName;
	}
	
	public String getRcptRibbonStatus(){
		return this.rcptRibbonStatus;
	}
	
	public void setRcptRibbonStatus(String rcptRibbonStatus){
		this.rcptRibbonStatus = rcptRibbonStatus;
	}
	
	public String getRcptRibbonStatusName(){
		return this.rcptRibbonStatusName;
	}
	
	public void setRcptRibbonStatusName(String rcptRibbonStatusName){
		this.rcptRibbonStatusName = rcptRibbonStatusName;
	}
	
	public String getRcptHeadStatus(){
		return this.rcptHeadStatus;
	}
	
	public void setRcptHeadStatus(String rcptHeadStatus){
		this.rcptHeadStatus = rcptHeadStatus;
	}
	
	public String getRcptHeadStatusName(){
		return this.rcptHeadStatusName;
	}
	
	public void setRcptHeadStatusName(String rcptHeadStatusName){
		this.rcptHeadStatusName = rcptHeadStatusName;
	}
	
	public String getRcptKnifeStatus(){
		return this.rcptKnifeStatus;
	}
	
	public void setRcptKnifeStatus(String rcptKnifeStatus){
		this.rcptKnifeStatus = rcptKnifeStatus;
	}
	
	public String getRcptKnifeStatusName(){
		return this.rcptKnifeStatusName;
	}
	
	public void setRcptKnifeStatusName(String rcptKnifeStatusName){
		this.rcptKnifeStatusName = rcptKnifeStatusName;
	}
	
	public String getJrnlStatus(){
		return this.jrnlStatus;
	}
	
	public void setJrnlStatus(String jrnlStatus){
		this.jrnlStatus = jrnlStatus;
	}
	
	public String getJrnlStatusName(){
		return this.jrnlStatusName;
	}
	
	public void setJrnlStatusName(String jrnlStatusName){
		this.jrnlStatusName = jrnlStatusName;
	}
	
	public String getJrnlPaperStatus(){
		return this.jrnlPaperStatus;
	}
	
	public void setJrnlPaperStatus(String jrnlPaperStatus){
		this.jrnlPaperStatus = jrnlPaperStatus;
	}
	
	public String getJrnlPaperStatusName(){
		return this.jrnlPaperStatusName;
	}
	
	public void setJrnlPaperStatusName(String jrnlPaperStatusName){
		this.jrnlPaperStatusName = jrnlPaperStatusName;
	}
	
	public String getJrnlRibbonStatus(){
		return this.jrnlRibbonStatus;
	}
	
	public void setJrnlRibbonStatus(String jrnlRibbonStatus){
		this.jrnlRibbonStatus = jrnlRibbonStatus;
	}
	
	public String getJrnlRibbonStatusName(){
		return this.jrnlRibbonStatusName;
	}
	
	public void setJrnlRibbonStatusName(String jrnlRibbonStatusName){
		this.jrnlRibbonStatusName = jrnlRibbonStatusName;
	}
	
	public String getJrnlHeadStatus(){
		return this.jrnlHeadStatus;
	}
	
	public void setJrnlHeadStatus(String jrnlHeadStatus){
		this.jrnlHeadStatus = jrnlHeadStatus;
	}
	
	public String getJrnlHeadStatusName(){
		return this.jrnlHeadStatusName;
	}
	
	public void setJrnlHeadStatusName(String jrnlHeadStatusName){
		this.jrnlHeadStatusName = jrnlHeadStatusName;
	}
	
	public String getEjrnlStatus(){
		return this.ejrnlStatus;
	}
	
	public void setEjrnlStatus(String ejrnlStatus){
		this.ejrnlStatus = ejrnlStatus;
	}
	
	public String getEjrnlStatusName(){
		return this.ejrnlStatusName;
	}
	
	public void setEjrnlStatusName(String ejrnlStatusName){
		this.ejrnlStatusName = ejrnlStatusName;
	}
	
	public String getEjrnlSpaceStatus(){
		return this.ejrnlSpaceStatus;
	}
	
	public void setEjrnlSpaceStatus(String ejrnlSpaceStatus){
		this.ejrnlSpaceStatus = ejrnlSpaceStatus;
	}
	
	public String getEjrnlSpaceStatusName(){
		return this.ejrnlSpaceStatusName;
	}
	
	public void setEjrnlSpaceStatusName(String ejrnlSpaceStatusName){
		this.ejrnlSpaceStatusName = ejrnlSpaceStatusName;
	}
	
	public String getStmtStatus(){
		return this.stmtStatus;
	}
	
	public void setStmtStatus(String stmtStatus){
		this.stmtStatus = stmtStatus;
	}
	
	public String getStmtStatusName(){
		return this.stmtStatusName;
	}
	
	public void setStmtStatusName(String stmtStatusName){
		this.stmtStatusName = stmtStatusName;
	}
	
	public String getStmtPaperStatus(){
		return this.stmtPaperStatus;
	}
	
	public void setStmtPaperStatus(String stmtPaperStatus){
		this.stmtPaperStatus = stmtPaperStatus;
	}
	
	public String getStmtPaperStatusName(){
		return this.stmtPaperStatusName;
	}
	
	public void setStmtPaperStatusName(String stmtPaperStatusName){
		this.stmtPaperStatusName = stmtPaperStatusName;
	}
	
	public String getStmtRibbonStat(){
		return this.stmtRibbonStat;
	}
	
	public void setStmtRibbonStat(String stmtRibbonStat){
		this.stmtRibbonStat = stmtRibbonStat;
	}
	
	public String getStmtRibbonStatName(){
		return this.stmtRibbonStatName;
	}
	
	public void setStmtRibbonStatName(String stmtRibbonStatName){
		this.stmtRibbonStatName = stmtRibbonStatName;
	}
	
	public String getStmtHeadStatus(){
		return this.stmtHeadStatus;
	}
	
	public void setStmtHeadStatus(String stmtHeadStatus){
		this.stmtHeadStatus = stmtHeadStatus;
	}
	
	public String getStmtHeadStatusName(){
		return this.stmtHeadStatusName;
	}
	
	public void setStmtHeadStatusName(String stmtHeadStatusName){
		this.stmtHeadStatusName = stmtHeadStatusName;
	}
	
	public String getStmtKnifeStatus(){
		return this.stmtKnifeStatus;
	}
	
	public void setStmtKnifeStatus(String stmtKnifeStatus){
		this.stmtKnifeStatus = stmtKnifeStatus;
	}
	
	public String getStmtKnifeStatusName(){
		return this.stmtKnifeStatusName;
	}
	
	public void setStmtKnifeStatusName(String stmtKnifeStatusName){
		this.stmtKnifeStatusName = stmtKnifeStatusName;
	}
	
	public String getStmtCaptBinStatus(){
		return this.stmtCaptBinStatus;
	}
	
	public void setStmtCaptBinStatus(String stmtCaptBinStatus){
		this.stmtCaptBinStatus = stmtCaptBinStatus;
	}
	
	public String getStmtCaptBinStatusName(){
		return this.stmtCaptBinStatusName;
	}
	
	public void setStmtCaptBinStatusName(String stmtCaptBinStatusName){
		this.stmtCaptBinStatusName = stmtCaptBinStatusName;
	}
	
	public String getTodClockStatus(){
		return this.todClockStatus;
	}
	
	public void setTodClockStatus(String todClockStatus){
		this.todClockStatus = todClockStatus;
	}
	
	public String getTodClockStatusName(){
		return this.todClockStatusName;
	}
	
	public void setTodClockStatusName(String todClockStatusName){
		this.todClockStatusName = todClockStatusName;
	}
	
	public String getDepositoryStatus(){
		return this.depositoryStatus;
	}
	
	public void setDepositoryStatus(String depositoryStatus){
		this.depositoryStatus = depositoryStatus;
	}
	
	public String getDepositoryStatusName(){
		return this.depositoryStatusName;
	}
	
	public void setDepositoryStatusName(String depositoryStatusName){
		this.depositoryStatusName = depositoryStatusName;
	}
	
	public String getNightSafeStatus(){
		return this.nightSafeStatus;
	}
	
	public void setNightSafeStatus(String nightSafeStatus){
		this.nightSafeStatus = nightSafeStatus;
	}
	
	public String getNightSafeStatusName(){
		return this.nightSafeStatusName;
	}
	
	public void setNightSafeStatusName(String nightSafeStatusName){
		this.nightSafeStatusName = nightSafeStatusName;
	}
	
	public String getEncryptorStatus(){
		return this.encryptorStatus;
	}
	
	public void setEncryptorStatus(String encryptorStatus){
		this.encryptorStatus = encryptorStatus;
	}
	
	public String getEncryptorStatusName(){
		return this.encryptorStatusName;
	}
	
	public void setEncryptorStatusName(String encryptorStatusName){
		this.encryptorStatusName = encryptorStatusName;
	}
	
	public String getTscreenKeybStatus(){
		return this.tscreenKeybStatus;
	}
	
	public void setTscreenKeybStatus(String tscreenKeybStatus){
		this.tscreenKeybStatus = tscreenKeybStatus;
	}
	
	public String getTscreenKeybStatusName(){
		return this.tscreenKeybStatusName;
	}
	
	public void setTscreenKeybStatusName(String tscreenKeybStatusName){
		this.tscreenKeybStatusName = tscreenKeybStatusName;
	}
	
	public String getVoiceGuidanceStatus(){
		return this.voiceGuidanceStatus;
	}
	
	public void setVoiceGuidanceStatus(String voiceGuidanceStatus){
		this.voiceGuidanceStatus = voiceGuidanceStatus;
	}
	
	public String getVoiceGuidanceStatusName(){
		return this.voiceGuidanceStatusName;
	}
	
	public void setVoiceGuidanceStatusName(String voiceGuidanceStatusName){
		this.voiceGuidanceStatusName = voiceGuidanceStatusName;
	}
	
	public String getCameraStatus(){
		return this.cameraStatus;
	}
	
	public void setCameraStatus(String cameraStatus){
		this.cameraStatus = cameraStatus;
	}
	
	public String getCameraStatusName(){
		return this.cameraStatusName;
	}
	
	public void setCameraStatusName(String cameraStatusName){
		this.cameraStatusName = cameraStatusName;
	}
	
	public String getBunchAcptStatus(){
		return this.bunchAcptStatus;
	}
	
	public void setBunchAcptStatus(String bunchAcptStatus){
		this.bunchAcptStatus = bunchAcptStatus;
	}
	
	public String getBunchAcptStatusName(){
		return this.bunchAcptStatusName;
	}
	
	public void setBunchAcptStatusName(String bunchAcptStatusName){
		this.bunchAcptStatusName = bunchAcptStatusName;
	}
	
	public String getEnvelopeDispStatus(){
		return this.envelopeDispStatus;
	}
	
	public void setEnvelopeDispStatus(String envelopeDispStatus){
		this.envelopeDispStatus = envelopeDispStatus;
	}
	
	public String getEnvelopeDispStatusName(){
		return this.envelopeDispStatusName;
	}
	
	public void setEnvelopeDispStatusName(String envelopeDispStatusName){
		this.envelopeDispStatusName = envelopeDispStatusName;
	}
	
	public String getChequeModuleStatus(){
		return this.chequeModuleStatus;
	}
	
	public void setChequeModuleStatus(String chequeModuleStatus){
		this.chequeModuleStatus = chequeModuleStatus;
	}
	
	public String getChequeModuleStatusName(){
		return this.chequeModuleStatusName;
	}
	
	public void setChequeModuleStatusName(String chequeModuleStatusName){
		this.chequeModuleStatusName = chequeModuleStatusName;
	}
	
	public String getBarcodeReaderStatus(){
		return this.barcodeReaderStatus;
	}
	
	public void setBarcodeReaderStatus(String barcodeReaderStatus){
		this.barcodeReaderStatus = barcodeReaderStatus;
	}
	
	public String getBarcodeReaderStatusName(){
		return this.barcodeReaderStatusName;
	}
	
	public void setBarcodeReaderStatusName(String barcodeReaderStatusName){
		this.barcodeReaderStatusName = barcodeReaderStatusName;
	}
	
	public String getCoinDispStatus(){
		return this.coinDispStatus;
	}
	
	public void setCoinDispStatus(String coinDispStatus){
		this.coinDispStatus = coinDispStatus;
	}
	
	public String getCoinDispStatusName(){
		return this.coinDispStatusName;
	}
	
	public void setCoinDispStatusName(String coinDispStatusName){
		this.coinDispStatusName = coinDispStatusName;
	}
	
	public String getDispenserStatus(){
		return this.dispenserStatus;
	}
	
	public void setDispenserStatus(String dispenserStatus){
		this.dispenserStatus = dispenserStatus;
	}
	
	public String getDispenserStatusName(){
		return this.dispenserStatusName;
	}
	
	public void setDispenserStatusName(String dispenserStatusName){
		this.dispenserStatusName = dispenserStatusName;
	}
	
	public String getWorkflowStatus(){
		return this.workflowStatus;
	}
	
	public void setWorkflowStatus(String workflowStatus){
		this.workflowStatus = workflowStatus;
	}
	
	public String getWorkflowStatusName(){
		return this.workflowStatusName;
	}
	
	public void setWorkflowStatusName(String workflowStatusName){
		this.workflowStatusName = workflowStatusName;
	}
	
	public String getServiceStatus(){
		return this.serviceStatus;
	}
	
	public void setServiceStatus(String serviceStatus){
		this.serviceStatus = serviceStatus;
	}
	
	public String getServiceStatusName(){
		return this.serviceStatusName;
	}
	
	public void setServiceStatusName(String serviceStatusName){
		this.serviceStatusName = serviceStatusName;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
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

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getAgentId() {
		return agentId;
	}

	public void setAgentId(Integer agentId) {
		this.agentId = agentId;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public String getStandardIdAsString(){
		return standardId.toString();
	}
	
	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}

	public String getStandardName() {
		return standardName;
	}

	public void setStandardName(String standardName) {
		this.standardName = standardName;
	}

	public String getFinanceStatus() {
		return financeStatus;
	}

	public void setFinanceStatus(String financeStatus) {
		this.financeStatus = financeStatus;
	}

	public String getFinanceStatusName() {
		return financeStatusName;
	}

	public void setFinanceStatusName(String financeStatusName) {
		this.financeStatusName = financeStatusName;
	}

	public String getTechStatus() {
		return techStatus;
	}

	public void setTechStatus(String techStatus) {
		this.techStatus = techStatus;
	}

	public String getTechStatusName() {
		return techStatusName;
	}

	public void setTechStatusName(String techStatusName) {
		this.techStatusName = techStatusName;
	}

	public String getConsumablesStatus() {
		return consumablesStatus;
	}

	public void setConsumablesStatus(String consumablesStatus) {
		this.consumablesStatus = consumablesStatus;
	}

	public String getAtmAddress() {
		return atmAddress;
	}

	public void setAtmAddress(String atmAddress) {
		this.atmAddress = atmAddress;
	}

	public Date getAtmDate() {
		return atmDate;
	}

	public void setAtmDate(Date atmDate) {
		this.atmDate = atmDate;
	}

	public Long getWorkTime() {
		return workTime;
	}

	public void setWorkTime(Long workTime) {
		this.workTime = workTime;
	}

	public Boolean getCashInPresent() {
		return cashInPresent;
	}

	public void setCashInPresent(Boolean cashInPresent) {
		this.cashInPresent = cashInPresent;
	}

	public String getInitiator() {
		return initiator;
	}

	public void setInitiator(String initiator) {
		this.initiator = initiator;
	}

	public String getFormat() {
		return format;
	}

	public void setFormat(String format) {
		this.format = format;
	}

	public Boolean getIsEnabled() {
		return isEnabled;
	}

	public void setIsEnabled(Boolean isEnabled) {
		this.isEnabled = isEnabled;
	}

	public String getCommunicationPlugin() {
		return communicationPlugin;
	}

	public void setCommunicationPlugin(String communicationPlugin) {
		this.communicationPlugin = communicationPlugin;
	}

	public String getRemoteAddress() {
		return remoteAddress;
	}

	public void setRemoteAddress(String remoteAddress) {
		this.remoteAddress = remoteAddress;
	}

	public String getRemotePort() {
		return remotePort;
	}

	public void setRemotePort(String remotePort) {
		this.remotePort = remotePort;
	}

	public String getLocalPort() {
		return localPort;
	}

	public void setLocalPort(String localPort) {
		this.localPort = localPort;
	}

	public Boolean getMonitorConnection() {
		return monitorConnection;
	}

	public void setMonitorConnection(Boolean monitorConnection) {
		this.monitorConnection = monitorConnection;
	}

	public String getTerminalNumber() {
		return terminalNumber;
	}

	public void setTerminalNumber(String terminalNumber) {
		this.terminalNumber = terminalNumber;
	}

	public String getTerminalDescription() {
		return terminalDescription;
	}

	public void setTerminalDescription(String terminalDescription) {
		this.terminalDescription = terminalDescription;
	}

	public Integer getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(Integer merchantId) {
		this.merchantId = merchantId;
	}

	public String getMerchantNumber() {
		return merchantNumber;
	}

	public void setMerchantNumber(String merchantNumber) {
		this.merchantNumber = merchantNumber;
	}

	public String getMerchantDescription() {
		return merchantDescription;
	}

	public void setMerchantDescription(String merchantDescription) {
		this.merchantDescription = merchantDescription;
	}

	public String getConnectionStatus() {
		return connectionStatus;
	}

	public void setConnectionStatus(String connectionStatus) {
		this.connectionStatus = connectionStatus;
	}

	public String getAgentName() {
		return agentName;
	}

	public void setAgentName(String agentName) {
		this.agentName = agentName;
	}

    public Integer getGroupId() {
        return groupId;
    }

    public void setGroupId(Integer groupId) {
        this.groupId = groupId;
    }

    public String getAgentNumber() {
        return agentNumber;
    }

    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }
}
package ru.bpc.sv2.atm;

import java.io.Serializable;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AtmTerminalDynamic implements ModelIdentifiable, Serializable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Long collId;
	private Short collOperCount;
	private Long lastOperId;
	private String lastOperDate;
	private Short receiptLoaded;
	private Short receiptPrinted;
	private Short receiptRemained;
	private Short cardCaptured;
	private String cardReaderStatus;
	private String rcptStatus;
	private String rcptPaperStatus;
	private String rcptRibbonStatus;
	private String rcptHeadStatus;
	private String rcptKnifeStatus;
	private String jrnlStatus;
	private String jrnlPaperStatus;
	private String jrnlRibbonStatus;
	private String jrnlHeadStatus;
	private String ejrnlStatus;
	private String ejrnlSpaceStatus;
	private String stmtStatus;
	private String stmtPaperStatus;
	private String stmtRibbonStat;
	private String stmtHeadStatus;
	private String stmtKnifeStatus;
	private String stmtCaptBinStatus;
	private String todClockStatus;
	private String depositoryStatus;
	private String nightSafeStatus;
	private String encryptorStatus;
	private String tscreenKeybStatus;
	private String voiceGuidanceStatus;
	private String cameraStatus;
	private String bunchAcptStatus;
	private String envelopeDispStatus;
	private String chequeModuleStatus;
	private String barcodeReaderStatus;
	private String coinDispStatus;
	private String dispenserStatus;
	private String workflowStatus;
	private String serviceStatus;
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Long getCollId() {
		return collId;
	}

	public void setCollId(Long collId) {
		this.collId = collId;
	}

	public Short getCollOperCount() {
		return collOperCount;
	}

	public void setCollOperCount(Short collOperCount) {
		this.collOperCount = collOperCount;
	}

	public Long getLastOperId() {
		return lastOperId;
	}

	public void setLastOperId(Long lastOperId) {
		this.lastOperId = lastOperId;
	}

	public String getLastOperDate() {
		return lastOperDate;
	}

	public void setLastOperDate(String lastOperDate) {
		this.lastOperDate = lastOperDate;
	}

	public Short getReceiptLoaded() {
		return receiptLoaded;
	}

	public void setReceiptLoaded(Short receiptLoaded) {
		this.receiptLoaded = receiptLoaded;
	}

	public Short getReceiptPrinted() {
		return receiptPrinted;
	}

	public void setReceiptPrinted(Short receiptPrinted) {
		this.receiptPrinted = receiptPrinted;
	}

	public Short getReceiptRemained() {
		return receiptRemained;
	}

	public void setReceiptRemained(Short receiptRemained) {
		this.receiptRemained = receiptRemained;
	}

	public Short getCardCaptured() {
		return cardCaptured;
	}

	public void setCardCaptured(Short cardCaptured) {
		this.cardCaptured = cardCaptured;
	}

	public String getCardReaderStatus() {
		return cardReaderStatus;
	}

	public void setCardReaderStatus(String cardReaderStatus) {
		this.cardReaderStatus = cardReaderStatus;
	}

	public String getRcptStatus() {
		return rcptStatus;
	}

	public void setRcptStatus(String rcptStatus) {
		this.rcptStatus = rcptStatus;
	}

	public String getRcptPaperStatus() {
		return rcptPaperStatus;
	}

	public void setRcptPaperStatus(String rcptPaperStatus) {
		this.rcptPaperStatus = rcptPaperStatus;
	}

	public String getRcptRibbonStatus() {
		return rcptRibbonStatus;
	}

	public void setRcptRibbonStatus(String rcptRibbonStatus) {
		this.rcptRibbonStatus = rcptRibbonStatus;
	}

	public String getRcptHeadStatus() {
		return rcptHeadStatus;
	}

	public void setRcptHeadStatus(String rcptHeadStatus) {
		this.rcptHeadStatus = rcptHeadStatus;
	}

	public String getRcptKnifeStatus() {
		return rcptKnifeStatus;
	}

	public void setRcptKnifeStatus(String rcptKnifeStatus) {
		this.rcptKnifeStatus = rcptKnifeStatus;
	}

	public String getJrnlStatus() {
		return jrnlStatus;
	}

	public void setJrnlStatus(String jrnlStatus) {
		this.jrnlStatus = jrnlStatus;
	}

	public String getJrnlPaperStatus() {
		return jrnlPaperStatus;
	}

	public void setJrnlPaperStatus(String jrnlPaperStatus) {
		this.jrnlPaperStatus = jrnlPaperStatus;
	}

	public String getJrnlRibbonStatus() {
		return jrnlRibbonStatus;
	}

	public void setJrnlRibbonStatus(String jrnlRibbonStatus) {
		this.jrnlRibbonStatus = jrnlRibbonStatus;
	}

	public String getJrnlHeadStatus() {
		return jrnlHeadStatus;
	}

	public void setJrnlHeadStatus(String jrnlHeadStatus) {
		this.jrnlHeadStatus = jrnlHeadStatus;
	}

	public String getEjrnlStatus() {
		return ejrnlStatus;
	}

	public void setEjrnlStatus(String ejrnlStatus) {
		this.ejrnlStatus = ejrnlStatus;
	}

	public String getEjrnlSpaceStatus() {
		return ejrnlSpaceStatus;
	}

	public void setEjrnlSpaceStatus(String ejrnlSpaceStatus) {
		this.ejrnlSpaceStatus = ejrnlSpaceStatus;
	}

	public String getStmtStatus() {
		return stmtStatus;
	}

	public void setStmtStatus(String stmtStatus) {
		this.stmtStatus = stmtStatus;
	}

	public String getStmtPaperStatus() {
		return stmtPaperStatus;
	}

	public void setStmtPaperStatus(String stmtPaperStatus) {
		this.stmtPaperStatus = stmtPaperStatus;
	}

	public String getStmtRibbonStat() {
		return stmtRibbonStat;
	}

	public void setStmtRibbonStat(String stmtRibbonStat) {
		this.stmtRibbonStat = stmtRibbonStat;
	}

	public String getStmtHeadStatus() {
		return stmtHeadStatus;
	}

	public void setStmtHeadStatus(String stmtHeadStatus) {
		this.stmtHeadStatus = stmtHeadStatus;
	}

	public String getStmtKnifeStatus() {
		return stmtKnifeStatus;
	}

	public void setStmtKnifeStatus(String stmtKnifeStatus) {
		this.stmtKnifeStatus = stmtKnifeStatus;
	}

	public String getStmtCaptBinStatus() {
		return stmtCaptBinStatus;
	}

	public void setStmtCaptBinStatus(String stmtCaptBinStatus) {
		this.stmtCaptBinStatus = stmtCaptBinStatus;
	}

	public String getTodClockStatus() {
		return todClockStatus;
	}

	public void setTodClockStatus(String todClockStatus) {
		this.todClockStatus = todClockStatus;
	}

	public String getDepositoryStatus() {
		return depositoryStatus;
	}

	public void setDepositoryStatus(String depositoryStatus) {
		this.depositoryStatus = depositoryStatus;
	}

	public String getNightSafeStatus() {
		return nightSafeStatus;
	}

	public void setNightSafeStatus(String nightSafeStatus) {
		this.nightSafeStatus = nightSafeStatus;
	}

	public String getEncryptorStatus() {
		return encryptorStatus;
	}

	public void setEncryptorStatus(String encryptorStatus) {
		this.encryptorStatus = encryptorStatus;
	}

	public String getTscreenKeybStatus() {
		return tscreenKeybStatus;
	}

	public void setTscreenKeybStatus(String tscreenKeybStatus) {
		this.tscreenKeybStatus = tscreenKeybStatus;
	}

	public String getVoiceGuidanceStatus() {
		return voiceGuidanceStatus;
	}

	public void setVoiceGuidanceStatus(String voiceGuidanceStatus) {
		this.voiceGuidanceStatus = voiceGuidanceStatus;
	}

	public String getCameraStatus() {
		return cameraStatus;
	}

	public void setCameraStatus(String cameraStatus) {
		this.cameraStatus = cameraStatus;
	}

	public String getBunchAcptStatus() {
		return bunchAcptStatus;
	}

	public void setBunchAcptStatus(String bunchAcptStatus) {
		this.bunchAcptStatus = bunchAcptStatus;
	}

	public String getEnvelopeDispStatus() {
		return envelopeDispStatus;
	}

	public void setEnvelopeDispStatus(String envelopeDispStatus) {
		this.envelopeDispStatus = envelopeDispStatus;
	}

	public String getChequeModuleStatus() {
		return chequeModuleStatus;
	}

	public void setChequeModuleStatus(String chequeModuleStatus) {
		this.chequeModuleStatus = chequeModuleStatus;
	}

	public String getBarcodeReaderStatus() {
		return barcodeReaderStatus;
	}

	public void setBarcodeReaderStatus(String barcodeReaderStatus) {
		this.barcodeReaderStatus = barcodeReaderStatus;
	}

	public String getCoinDispStatus() {
		return coinDispStatus;
	}

	public void setCoinDispStatus(String coinDispStatus) {
		this.coinDispStatus = coinDispStatus;
	}

	public String getDispenserStatus() {
		return dispenserStatus;
	}

	public void setDispenserStatus(String dispenserStatus) {
		this.dispenserStatus = dispenserStatus;
	}

	public String getWorkflowStatus() {
		return workflowStatus;
	}

	public void setWorkflowStatus(String workflowStatus) {
		this.workflowStatus = workflowStatus;
	}

	public String getServiceStatus() {
		return serviceStatus;
	}

	public void setServiceStatus(String serviceStatus) {
		this.serviceStatus = serviceStatus;
	}

	public Object getModelId() {
		return getId();
	}
	
}

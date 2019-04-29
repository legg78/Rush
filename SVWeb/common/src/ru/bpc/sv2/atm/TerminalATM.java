package ru.bpc.sv2.atm;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class TerminalATM implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
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
	private String operationHours;
	private Integer localDateGap;
	private Short cassetteCount;
	private String keyChangeAlgo;
	private String keyChangeAlgoName;
	private String counterSyncCond;
	private Short rejectDispWarn;
	private Short dispRestWarn;
	private Short receiptWarn;
	private Short cardCaptureWarn;
	private Short noteMaxCount;
	private Short scenarioId;
	private String scenarioName;
	private Short hopperCount;
	private Integer terminalProfile;
	private String manualSynch;
	private String establConnSynch;
	private String counterMismatchSynch;
	private String onlineInSynch;
	private String onlineOutSynch;
	private String safeCloseSynch;
	private String dispErrorSynch;
	private String periodicSynch;
	private Integer periodicAllOper;
	private Integer periodicOperCount;
	private String lang;
	private Integer rejectDispMinWarn;
	private Boolean cashInPresent;
	private Integer cashInMinWarn;
	private Integer cashInMaxWarn;
	private String dispenseAlg;
	private String dispenseAlgName;
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getId() {
		return id;
	}

	public Object getModelId() {
		return id;
	}

	public String getAtmType() {
		return atmType;
	}

	public void setAtmType(String atmType) {
		this.atmType = atmType;
	}

	public String getAtmTypeName() {
		return atmTypeName;
	}

	public void setAtmTypeName(String atmTypeName) {
		this.atmTypeName = atmTypeName;
	}

	public Short getCassetteCount() {
		return cassetteCount;
	}

	public void setCassetteCount(Short cassetteCount) {
		this.cassetteCount = cassetteCount;
	}

	public String getKeyChangeAlgo() {
		return keyChangeAlgo;
	}

	public void setKeyChangeAlgo(String keyChangeAlgo) {
		this.keyChangeAlgo = keyChangeAlgo;
	}

	public String getKeyChangeAlgoName() {
		return keyChangeAlgoName;
	}

	public void setKeyChangeAlgoName(String keyChangeAlgoName) {
		this.keyChangeAlgoName = keyChangeAlgoName;
	}

	public Short getRejectDispWarn() {
		return rejectDispWarn;
	}

	public void setRejectDispWarn(Short rejectDispWarn) {
		this.rejectDispWarn = rejectDispWarn;
	}

	public Short getDispRestWarn() {
		return dispRestWarn;
	}

	public void setDispRestWarn(Short dispRestWarn) {
		this.dispRestWarn = dispRestWarn;
	}

	public Short getReceiptWarn() {
		return receiptWarn;
	}

	public void setReceiptWarn(Short receiptWarn) {
		this.receiptWarn = receiptWarn;
	}

	public Short getCardCaptureWarn() {
		return cardCaptureWarn;
	}

	public void setCardCaptureWarn(Short cardCaptureWarn) {
		this.cardCaptureWarn = cardCaptureWarn;
	}

	public Short getNoteMaxCount() {
		return noteMaxCount;
	}

	public void setNoteMaxCount(Short noteMaxCount) {
		this.noteMaxCount = noteMaxCount;
	}

	public Short getScenarioId() {
		return scenarioId;
	}

	public void setScenarioId(Short scenarioId) {
		this.scenarioId = scenarioId;
	}

	public String getScenarioName() {
		return scenarioName;
	}

	public void setScenarioName(String scenarioName) {
		this.scenarioName = scenarioName;
	}

	public Short getHopperCount() {
		return hopperCount;
	}

	public void setHopperCount(Short hopperCount) {
		this.hopperCount = hopperCount;
	}

	public Integer getTerminalProfile() {
		return terminalProfile;
	}

	public void setTerminalProfile(Integer terminalProfile) {
		this.terminalProfile = terminalProfile;
	}

	public String getManualSynch() {
		return manualSynch;
	}

	public void setManualSynch(String manualSynch) {
		this.manualSynch = manualSynch;
	}

	public String getEstablConnSynch() {
		return establConnSynch;
	}

	public void setEstablConnSynch(String establConnSynch) {
		this.establConnSynch = establConnSynch;
	}

	public String getCounterMismatchSynch() {
		return counterMismatchSynch;
	}

	public void setCounterMismatchSynch(String counterMismatchSynch) {
		this.counterMismatchSynch = counterMismatchSynch;
	}

	public String getOnlineInSynch() {
		return onlineInSynch;
	}

	public void setOnlineInSynch(String onlineInSynch) {
		this.onlineInSynch = onlineInSynch;
	}

	public String getOnlineOutSynch() {
		return onlineOutSynch;
	}

	public void setOnlineOutSynch(String onlineOutSynch) {
		this.onlineOutSynch = onlineOutSynch;
	}

	public String getSafeCloseSynch() {
		return safeCloseSynch;
	}

	public void setSafeCloseSynch(String safeCloseSynch) {
		this.safeCloseSynch = safeCloseSynch;
	}

	public String getDispErrorSynch() {
		return dispErrorSynch;
	}

	public void setDispErrorSynch(String dispErrorSynch) {
		this.dispErrorSynch = dispErrorSynch;
	}

	public String getPeriodicSynch() {
		return periodicSynch;
	}

	public void setPeriodicSynch(String periodicSynch) {
		this.periodicSynch = periodicSynch;
	}

	public Integer getPeriodicAllOper() {
		return periodicAllOper;
	}

	public void setPeriodicAllOper(Integer periodicAllOper) {
		this.periodicAllOper = periodicAllOper;
	}

	public Integer getPeriodicOperCount() {
		return periodicOperCount;
	}

	public void setPeriodicOperCount(Integer periodicOperCount) {
		this.periodicOperCount = periodicOperCount;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getAtmModel() {
		return atmModel;
	}

	public void setAtmModel(String atmModel) {
		this.atmModel = atmModel;
	}

	public String getSerialNumber() {
		return serialNumber;
	}

	public void setSerialNumber(String serialNumber) {
		this.serialNumber = serialNumber;
	}

	public String getPlacementType() {
		return placementType;
	}

	public void setPlacementType(String placementType) {
		this.placementType = placementType;
	}

	public String getPlacementTypeName() {
		return placementTypeName;
	}

	public void setPlacementTypeName(String placementTypeName) {
		this.placementTypeName = placementTypeName;
	}

	public String getAvailabilityType() {
		return availabilityType;
	}

	public void setAvailabilityType(String availabilityType) {
		this.availabilityType = availabilityType;
	}

	public String getAvailabilityTypeName() {
		return availabilityTypeName;
	}

	public void setAvailabilityTypeName(String availabilityTypeName) {
		this.availabilityTypeName = availabilityTypeName;
	}

	public String getOperationHours() {
		return operationHours;
	}

	public void setOperationHours(String operationHours) {
		this.operationHours = operationHours;
	}

	public Integer getLocalDateGap() {
		return localDateGap;
	}

	public void setLocalDateGap(Integer localDateGap) {
		this.localDateGap = localDateGap;
	}

	public String getCounterSyncCond() {
		return counterSyncCond;
	}

	public void setCounterSyncCond(String counterSyncCond) {
		this.counterSyncCond = counterSyncCond;
	}

	public Integer getRejectDispMinWarn() {
		return rejectDispMinWarn;
	}

	public void setRejectDispMinWarn(Integer rejectDispMinWarn) {
		this.rejectDispMinWarn = rejectDispMinWarn;
	}

	public Boolean getCashInPresent() {
		return cashInPresent;
	}

	public void setCashInPresent(Boolean cashInPresent) {
		this.cashInPresent = cashInPresent;
	}

	public Integer getCashInMinWarn() {
		return cashInMinWarn;
	}

	public void setCashInMinWarn(Integer cashInMinWarn) {
		this.cashInMinWarn = cashInMinWarn;
	}

	public Integer getCashInMaxWarn() {
		return cashInMaxWarn;
	}

	public void setCashInMaxWarn(Integer cashInMaxWarn) {
		this.cashInMaxWarn = cashInMaxWarn;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("atmType", this.getAtmType());
		result.put("cassetteCount", this.getCassetteCount());
		result.put("keyChangeAlgo", this.getKeyChangeAlgo());
		result.put("rejectDispWarn", this.getRejectDispWarn());
		result.put("dispRestWarn", this.getDispRestWarn());
		result.put("receiptWarn", this.getReceiptWarn());
		result.put("cardCaptureWarn", this.getCardCaptureWarn());
		result.put("noteMaxCount", this.getNoteMaxCount());
		result.put("scenarioId", this.getScenarioId());
		result.put("hopperCount", this.getHopperCount());
		result.put("manualSynch", this.getManualSynch());
		result.put("establConnSynch", this.getEstablConnSynch());
		result.put("counterMismatchSynch", this.getCounterMismatchSynch());
		result.put("onlineInSynch", this.getOnlineInSynch());
		result.put("onlineOutSynch", this.getOnlineOutSynch());
		result.put("safeCloseSynch", this.getSafeCloseSynch());
		
		result.put("dispErrorSynch", this.getDispErrorSynch());
		result.put("periodicSynch", this.getPeriodicSynch());
		result.put("periodicAllOper", this.getPeriodicAllOper());
		result.put("periodicOperCount", this.getPeriodicOperCount());
		result.put("rejectDispMinWarn", this.getRejectDispMinWarn());
		result.put("cashInPresent", this.getCashInPresent());
		result.put("cashInMinWarn", this.getCashInMinWarn());
		result.put("cashInMaxWarn", this.getCashInMaxWarn());
		
		return result;
	}

	public String getDispenseAlg() {
		return dispenseAlg;
	}

	public void setDispenseAlg(String dispenseAlg) {
		this.dispenseAlg = dispenseAlg;
	}

	public String getDispenseAlgName() {
		return dispenseAlgName;
	}

	public void setDispenseAlgName(String dispenseAlgName) {
		this.dispenseAlgName = dispenseAlgName;
	}
}

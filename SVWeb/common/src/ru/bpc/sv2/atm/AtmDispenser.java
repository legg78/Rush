package ru.bpc.sv2.atm;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AtmDispenser implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer terminalId;
	private Short dispNumber;
	private BigDecimal faceValue;
	private String faceValueName;
	private String currency;
	private String denominationId;
	private String dispenserType;
	private String dispenserTypeName;
	private Integer noteLoaded;
	private String sumLoaded;
	private Integer noteDispensed;
	private String sumDispensed;
	private Integer noteRejected;
	private String sumRejected;
	private Integer noteRemained;
	private String sumRemained;
	private String cassetteStatus;
	private String cassetteStatusName;
	private Integer fullnessRatio;
	private Integer dispRestWarn;

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Object getModelId() {
		if (id != null) {
			return id;
		} else {
			return getTerminalId() + "_" + getCurrency();
		}
	}

	public Integer getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}

	public Short getDispNumber() {
		return dispNumber;
	}

	public void setDispNumber(Short dispNumber) {
		this.dispNumber = dispNumber;
	}

	public BigDecimal getFaceValue() {
		return faceValue;
	}

	public void setFaceValue(BigDecimal faceValue) {
		this.faceValue = faceValue;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getDenominationId() {
		return denominationId;
	}

	public void setDenominationId(String denominationId) {
		this.denominationId = denominationId;
	}

	public String getDispenserType() {
		return dispenserType;
	}

	public void setDispenserType(String dispenserType) {
		this.dispenserType = dispenserType;
	}

	public String getDispenserTypeName() {
		return dispenserTypeName;
	}

	public void setDispenserTypeName(String dispenserTypeName) {
		this.dispenserTypeName = dispenserTypeName;
	}

	public String getFaceValueName() {
		return faceValueName;
	}

	public void setFaceValueName(String faceValueName) {
		this.faceValueName = faceValueName;
	}

	public Integer getNoteLoaded() {
		return noteLoaded;
	}

	public void setNoteLoaded(Integer noteLoaded) {
		this.noteLoaded = noteLoaded;
		computeFullnessRation();
	}

	public String getSumLoaded() {
		return sumLoaded;
	}

	public void setSumLoaded(String sumLoaded) {
		this.sumLoaded = sumLoaded;
	}

	public Integer getNoteDispensed() {
		return noteDispensed;
	}

	public void setNoteDispensed(Integer noteDispensed) {
		this.noteDispensed = noteDispensed;
		computeFullnessRation();
	}

	public String getSumDispensed() {
		return sumDispensed;
	}

	public void setSumDispensed(String sumDispensed) {
		this.sumDispensed = sumDispensed;
	}

	public Integer getNoteRejected() {
		return noteRejected;
	}

	public void setNoteRejected(Integer noteRejected) {
		this.noteRejected = noteRejected;
	}

	public String getSumRejected() {
		return sumRejected;
	}

	public void setSumRejected(String sumRejected) {
		this.sumRejected = sumRejected;
	}

	public Integer getNoteRemained() {
		return noteRemained;
	}

	public void setNoteRemained(Integer noteRemained) {
		this.noteRemained = noteRemained;
	}

	public String getSumRemained() {
		return sumRemained;
	}

	public void setSumRemained(String sumRemained) {
		this.sumRemained = sumRemained;
	}

	public String getCassetteStatus() {
		return cassetteStatus;
	}

	public void setCassetteStatus(String cassetteStatus) {
		this.cassetteStatus = cassetteStatus;
	}

	public String getCassetteStatusName() {
		return cassetteStatusName;
	}

	public void setCassetteStatusName(String cassetteStatusName) {
		this.cassetteStatusName = cassetteStatusName;
	}

	private void computeFullnessRation(){
		if (noteLoaded == null || noteDispensed == null || noteLoaded <= 0 || noteDispensed < 0) return;
		fullnessRatio = (int)(((double)noteDispensed / noteLoaded) * 100);
	}
	
	public Integer getFullnessRatio(){
		if (fullnessRatio == null){
			computeFullnessRation();
		}
		return fullnessRatio;
	}

	public Integer getDispRestWarn() {
		return dispRestWarn;
	}

	public void setDispRestWarn(Integer dispRestWarn) {
		this.dispRestWarn = dispRestWarn;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("terminalId", this.getTerminalId());
		result.put("dispNumber", this.getDispNumber());
		result.put("faceValue", this.getFaceValue());
		result.put("currency", this.getCurrency());
		result.put("denominationId", this.getDenominationId());
		result.put("dispenserType", this.getDispenserType());
		
		return result;
	}
	
}

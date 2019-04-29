package ru.bpc.sv2.atm;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Unsolicited implements ModelIdentifiable, Serializable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private String techId; 
	private Integer messageType; 
	private String deviceId; 
	private String deviceStatus;
	private String deviceName;
	private String errorSeverity;
	private String diagStatus; 
	private String suppliesStatus;
	private Long  lastOperId;
	private Integer  terminalId;
	
	@Override
	public Object getModelId() {
		if(id == null)
			return getTechId();
		return getId();
	}
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
	
	public String getTechId() {
		return techId;
	}

	public void setTechId(String techId) {
		this.techId = techId;
	}

	public Integer getMessageType() {
		return messageType;
	}

	public void setMessageType(Integer messageType) {
		this.messageType = messageType;
	}

	public String getDeviceId() {
		return deviceId;
	}

	public void setDeviceId(String deviceId) {
		this.deviceId = deviceId;
	}

	public String getDeviceStatus() {
		return deviceStatus;
	}

	public void setDeviceStatus(String deviceStatus) {
		this.deviceStatus = deviceStatus;
	}

	public String getErrorSeverity() {
		return errorSeverity;
	}

	public void setErrorSeverity(String errorSeverity) {
		this.errorSeverity = errorSeverity;
	}

	public String getDiagStatus() {
		return diagStatus;
	}

	public void setDiagStatus(String diagStatus) {
		this.diagStatus = diagStatus;
	}

	public String getSuppliesStatus() {
		return suppliesStatus;
	}

	public void setSuppliesStatus(String suppliesStatus) {
		this.suppliesStatus = suppliesStatus;
	}

	public Long getLastOperId() {
		return lastOperId;
	}

	public void setLastOperId(Long lastOperId) {
		this.lastOperId = lastOperId;
	}

	public Integer getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}
	
	public String getDeviceName() {
		return deviceName;
	}

	public void setDeviceName(String deviceName) {
		this.deviceName = deviceName;
	}
}

package ru.bpc.sv2.hsm;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class HsmDynamicConnection implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;
	
	private Integer deviceId;
	private Short connectNumber;
	private String status;
	private String action;
	
	public Object getModelId() {
		return deviceId + "_" + connectNumber;
	}

	public Integer getDeviceId() {
		return deviceId;
	}

	public void setDeviceId(Integer deviceId) {
		this.deviceId = deviceId;
	}

	public Short getConnectNumber() {
		return connectNumber;
	}

	public void setConnectNumber(Short connectNumber) {
		this.connectNumber = connectNumber;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}

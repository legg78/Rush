package ru.bpc.sv2.cmn;

import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;

public class TcpIpDevice extends Device implements Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private String remoteAddress;
	private String localPort;
	private String remotePort;
	private String initiator;
	private String format;
	private Boolean keepAlive;
	private Boolean enabled;
	private Boolean monitorConnection;
	private Boolean multipleConnection;
	private Integer statusOk;	// number of properly working connections
	
	public Object getModelId() {
		return getId() + ":" + remoteAddress + ":" + remotePort;
	}

	public String getRemoteAddress() {
		return remoteAddress;
	}

	public void setRemoteAddress(String remoteAddress) {
		this.remoteAddress = remoteAddress;
	}

	public String getLocalPort() {
		return localPort;
	}

	public void setLocalPort(String localPort) {
		this.localPort = localPort;
	}

	public String getRemotePort() {
		return remotePort;
	}

	public void setRemotePort(String remotePort) {
		this.remotePort = remotePort;
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

	public Boolean getKeepAlive() {
		return keepAlive;
	}

	public void setKeepAlive(Boolean keepAlive) {
		this.keepAlive = keepAlive;
	}

	@Override
	public TcpIpDevice clone() throws CloneNotSupportedException {
		return (TcpIpDevice)super.clone();
	}

	public Boolean getEnabled() {
		return enabled;
	}

	public void setEnabled(Boolean enabled) {
		this.enabled = enabled;
	}

	public Boolean getMonitorConnection() {
		return monitorConnection;
	}

	public void setMonitorConnection(Boolean monitorConnection) {
		this.monitorConnection = monitorConnection;
	}

	public Integer getStatusOk() {
		return statusOk;
	}

	public void setStatusOk(Integer statusOk) {
		this.statusOk = statusOk;
	}

	public Boolean getMultipleConnection() {
		return multipleConnection;
	}

	public void setMultipleConnection(Boolean multipleConnection) {
		this.multipleConnection = multipleConnection;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("commPlugin", this.getCommPlugin());
		result.put("standardId", this.getStandardId());
		result.put("lang", this.getLang());
		result.put("caption", this.getCaption());
		result.put("description", this.getDescription());
		
		return result;
	}
}

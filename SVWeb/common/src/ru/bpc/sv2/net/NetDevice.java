package ru.bpc.sv2.net;

import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.cmn.Device;
import ru.bpc.sv2.invocation.IAuditableObject;

public class NetDevice extends Device implements Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	public Integer hostMemberId;
	public boolean signedOn;
	public boolean connected;
	private String remoteAddress;
	private String remotePort;
	private String protocolType;
	
	public Integer getHostMemberId() {
		return hostMemberId;
	}

	public void setHostMemberId(Integer hostMemberId) {
		this.hostMemberId = hostMemberId;
	}

	public boolean isSignedOn() {
		return signedOn;
	}

	public void setSignedOn(boolean signedOn) {
		this.signedOn = signedOn;
	}

	public boolean isConnected() {
		return connected;
	}

	public void setConnected(boolean connected) {
		this.connected = connected;
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

	public String getProtocolType() {
		if (protocolType == null) return "TCP/IP";		// TODO: temporarily, while we don't have any other protocols
		return protocolType;
	}

	public void setProtocolType(String protocolType) {
		this.protocolType = protocolType;
	}

	public String getAddress() {
		String address = "";
		if (remoteAddress != null) {
			address = remoteAddress;
			if (remotePort != null) {
				address += ":" + remotePort;
			}
		}
		return address;
	}
	
	@Override
	public NetDevice clone() throws CloneNotSupportedException {
		return (NetDevice) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("hostMemberId", getHostMemberId());
		return result;
	}
}

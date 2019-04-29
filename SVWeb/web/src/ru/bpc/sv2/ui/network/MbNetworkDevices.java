package ru.bpc.sv2.ui.network;

import java.io.Serializable;

import ru.bpc.sv2.net.NetDevice;
import ru.bpc.sv2.net.NetworkMember;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbNetworkDevices")
public class MbNetworkDevices implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private NetDevice savedFilter;
	private NetDevice savedActiveNetDevice;
	private String savedBackLink;
	private NetDevice savedNewNetDevice;
	private int savedCurMode;
	private boolean searching;
	private boolean keepState;
	private NetworkMember host;
	
	public MbNetworkDevices() {
	}

	public NetDevice getSavedFilter() {
		return savedFilter;
	}

	public void setSavedFilter(NetDevice savedFilter) {
		this.savedFilter = savedFilter;
	}

	public NetDevice getSavedActiveNetDevice() {
		return savedActiveNetDevice;
	}

	public void setSavedActiveNetDevice(NetDevice savedActiveNetDevice) {
		this.savedActiveNetDevice = savedActiveNetDevice;
	}

	public String getSavedBackLink() {
		return savedBackLink;
	}

	public void setSavedBackLink(String savedBackLink) {
		this.savedBackLink = savedBackLink;
	}

	public NetDevice getSavedNewNetDevice() {
		return savedNewNetDevice;
	}

	public void setSavedNewNetDevice(NetDevice savedNewNetDevice) {
		this.savedNewNetDevice = savedNewNetDevice;
	}

	public int getSavedCurMode() {
		return savedCurMode;
	}

	public void setSavedCurMode(int savedCurMode) {
		this.savedCurMode = savedCurMode;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public NetworkMember getHost() {
		return host;
	}

	public void setHost(NetworkMember host) {
		this.host = host;
	}

	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}
	
}

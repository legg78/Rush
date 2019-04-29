package ru.bpc.sv2.ui.session;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import java.io.Serializable;
@SessionScoped
@ManagedBean(name = "MbUserSessionInformation")
public class MbUserSessionInformation implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private String remoteAddr;
	private boolean initialized;
	
	public String getRemoteAddr() {
		return remoteAddr;
	}
	
	public void setRemoteAddr(String remoteAddr) {
		this.remoteAddr = remoteAddr;
	}
	
	public boolean isInitialized() {
		return initialized;
	}
	
	public void setInitialized(boolean initialized) {
		this.initialized = initialized;
	}
}

package ru.bpc.sv2.cmn;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Device implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	
	private static final long serialVersionUID = 1L;

	public static final String TCP_IP_CMN_PLUGIN = "CMPLTCIP";

	private Integer id;
	private Integer seqNum;
	private String commPlugin;
	private Integer instId;
	private Integer standardId;
	private String caption;
	private String description;
	private String lang;
	private String standardName;
	private String instName;
	private TcpIpDevice tcpDevice;
	private Boolean enabled;
	
	private Integer ferrNo;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getCommPlugin() {
		return commPlugin;
	}

	public void setCommPlugin(String commPlugin) {
		this.commPlugin = commPlugin;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getStandardId() {
		return standardId;
	}

	public void setStandardId(Integer standardId) {
		this.standardId = standardId;
	}

	public String getCaption() {
		return caption;
	}

	public void setCaption(String caption) {
		this.caption = caption;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getStandardName() {
		return standardName;
	}

	public void setStandardName(String standardName) {
		this.standardName = standardName;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public TcpIpDevice getTcpDevice() {
		return tcpDevice;
	}

	public void setTcpDevice(TcpIpDevice tcpDevice) {
		this.tcpDevice = tcpDevice;
	}

	/**
	 * Gets <code>tcpDevice</code> and if <code>copyDevice</code> is <i>true</i>
	 * then device's properties are copied to <code>tcpDevice</code>.
	 */
	public TcpIpDevice getTcpDevice(boolean copyDevice) {
		if (tcpDevice != null && copyDevice) {
			tcpDevice.setId(id);
			tcpDevice.setCommPlugin(commPlugin);
			tcpDevice.setInstId(instId);
			tcpDevice.setStandardId(standardId);
			tcpDevice.setCaption(caption);
			tcpDevice.setDescription(description);
			tcpDevice.setLang(lang);
			tcpDevice.setStandardName(standardName);
			tcpDevice.setInstName(instName);
		}
		return tcpDevice;
	}
	
	/**
	 * Fully copies <code>tcpDevice</code>'s properties and sets it as
	 * current <code>tcpDevice</code>.
	 * @param tcpDevice
	 */
	public void setAsTcpDevice(TcpIpDevice tcpDevice) {
		id = tcpDevice.getId();
		seqNum = tcpDevice.getSeqNum();
		commPlugin = tcpDevice.getCommPlugin();
		instId = tcpDevice.getInstId();
		standardId = tcpDevice.getStandardId();
		caption = tcpDevice.getCaption();
		description = tcpDevice.getDescription();
		lang = tcpDevice.getLang();
		standardName = tcpDevice.getStandardName();
		instName = tcpDevice.getInstName();
		this.tcpDevice = tcpDevice; 
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		Device clone = (Device) super.clone();
		if (tcpDevice != null) {
			TcpIpDevice tcpClone = tcpDevice.clone();
			clone.setTcpDevice(tcpClone);
		}
		return clone;
	}
	
	/**
	 * Double "is" to evade ambiguity for jsf parser which doesn't know if
	 * device.tcpDevice means device.getTcpDevice() or device.isTcpDevice().
	 * @return
	 */
	public boolean isIsTcpDevice() {
		return TCP_IP_CMN_PLUGIN.equals(commPlugin);
	}

	public Integer getFerrNo() {
		return ferrNo;
	}

	public void setFerrNo(Integer ferrNo) {
		this.ferrNo = ferrNo;
	}

	public Boolean getEnabled() {
		return enabled;
	}

	public void setEnabled(Boolean enabled) {
		this.enabled = enabled;
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
		result.put("tcpDevice.remoteAddress", this.getTcpDevice().getRemoteAddress());
		result.put("tcpDevice.initiator", this.getTcpDevice().getInitiator());
		result.put("tcpDevice.localPort", this.getTcpDevice().getLocalPort());
		result.put("tcpDevice.remotePort", this.getTcpDevice().getRemotePort());
		result.put("tcpDevice.format", this.getTcpDevice().getFormat());
		result.put("tcpDevice.keepAlive", this.getTcpDevice().getKeepAlive());
		result.put("tcpDevice.monitorConnection", this.getTcpDevice().getMonitorConnection());
		result.put("tcpDevice.multipleConnection", this.getTcpDevice().getMultipleConnection());
		
		return result;
	}
	
}

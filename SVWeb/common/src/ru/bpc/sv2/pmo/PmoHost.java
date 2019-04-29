package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Host tab page.
 */
public class PmoHost implements ModelIdentifiable, IAuditableObject, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 9160260928538889903L;
	
	private Integer	hostId;
	private String hostName;
	private Integer networkId;
	private String networkName;
	private Integer offlineStandardId;
	private String offlineStandardName;
	private Integer onlineStandardId;
	private String onlineStandardName;
	private String	executionType;
	private Integer priority;
	private Integer providerId;
	private String providerName;
	private Integer modId;
	private String modName;
	private Date inactiveTill;
	private String lang;
	private String status;
	
	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public PmoHost()
	{
	}

	public Object getModelId() {
		return getHostId() + "-" + getProviderId(); 
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}


	public Integer getHostId() {
		return hostId;
	}


	public void setHostId(Integer hostId) {
		this.hostId = hostId;
	}


	public String getHostName() {
		return hostName;
	}


	public void setHostName(String hostName) {
		this.hostName = hostName;
	}


	public Integer getNetworkId() {
		return networkId;
	}


	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}


	public String getNetworkName() {
		return networkName;
	}


	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}


	public Integer getOfflineStandardId() {
		return offlineStandardId;
	}


	public void setOfflineStandardId(Integer offlineStandardId) {
		this.offlineStandardId = offlineStandardId;
	}


	public String getOfflineStandardName() {
		return offlineStandardName;
	}


	public void setOfflineStandardName(String offlineStandardName) {
		this.offlineStandardName = offlineStandardName;
	}


	public Integer getOnlineStandardId() {
		return onlineStandardId;
	}


	public void setOnlineStandardId(Integer onlineStandardId) {
		this.onlineStandardId = onlineStandardId;
	}


	public String getOnlineStandardName() {
		return onlineStandardName;
	}


	public void setOnlineStandardName(String onlineStandardName) {
		this.onlineStandardName = onlineStandardName;
	}


	public String getExecutionType() {
		return executionType;
	}


	public void setExecutionType(String executionType) {
		this.executionType = executionType;
	}


	public Integer getPriority() {
		return priority;
	}


	public void setPriority(Integer priority) {
		this.priority = priority;
	}


	public Integer getProviderId() {
		return providerId;
	}


	public void setProviderId(Integer providerId) {
		this.providerId = providerId;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getProviderName() {
		return providerName;
	}

	public void setProviderName(String providerName) {
		this.providerName = providerName;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public String getModName() {
		return modName;
	}

	public void setModName(String modName) {
		this.modName = modName;
	}

	public Date getInactiveTill() {
		return inactiveTill;
	}

	public void setInactiveTill(Date inactiveTill) {
		this.inactiveTill = inactiveTill;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("hostId", getHostId());
		result.put("providerId", getProviderId());
		result.put("executionType", getExecutionType());
		result.put("priority", getPriority());
		result.put("modId", getModId());
		result.put("inactiveTill", getInactiveTill());
		result.put("status", getStatus());
		return result;
	}

}
package ru.bpc.sv2.net;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class NetworkMember implements Serializable, IAuditableObject, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer networkId;
	private Integer instId;
	private Integer onlineStdId;	// Authorization interface ID
	private Integer offlineStdId;	// Clearing interface ID
	private String onlineStdName;	// Authorization interface name
	private String offlineStdName;	// Clearing interface name
	private String hostName;
	private String lang;
	private String instName;
	private String networkName;
	private Integer networkInstId; 	// default institution for network which this member belongs to
	private boolean isDefault;
	private String participantType;
	
	private Integer ferrNo;
	private String onlineAppPlugin;
	
	private String status;
	private Date inactiveTill;
	
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

	public Integer getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Integer getOnlineStdId() {
		return onlineStdId;
	}

	public void setOnlineStdId(Integer onlineStdId) {
		this.onlineStdId = onlineStdId;
	}

	public Integer getOfflineStdId() {
		return offlineStdId;
	}

	public void setOfflineStdId(Integer offlineStdId) {
		this.offlineStdId = offlineStdId;
	}

	public String getOnlineStdName() {
		return onlineStdName;
	}

	public void setOnlineStdName(String onlineStdName) {
		this.onlineStdName = onlineStdName;
	}

	public String getOfflineStdName() {
		return offlineStdName;
	}

	public void setOfflineStdName(String offlineStdName) {
		this.offlineStdName = offlineStdName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getHostName() {
		return hostName;
	}

	public void setHostName(String hostName) {
		this.hostName = hostName;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getNetworkName() {
		return networkName;
	}

	public void setNetworkName(String networkName) {
		this.networkName = networkName;
	}

	@Override
	public NetworkMember clone() throws CloneNotSupportedException {
		
		return (NetworkMember) super.clone();
	}

	public Integer getNetworkInstId() {
		return networkInstId;
	}

	public void setNetworkInstId(Integer networkInstId) {
		this.networkInstId = networkInstId;
	}

	public boolean isDefault() {
		return isDefault;
	}

	public void setDefault(boolean isDefault) {
		this.isDefault = isDefault;
	}

	public Integer getFerrNo() {
		return ferrNo;
	}

	public void setFerrNo(Integer ferrNo) {
		this.ferrNo = ferrNo;
	}

	public String getOnlineAppPlugin() {
		return onlineAppPlugin;
	}

	public void setOnlineAppPlugin(String onlineAppPlugin) {
		this.onlineAppPlugin = onlineAppPlugin;
	}

	public String getParticipantType() {
		return participantType;
	}

	public void setParticipantType(String participantType) {
		this.participantType = participantType;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
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
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("networkId", getNetworkId());
		result.put("onlineStdId", getOnlineStdId());
		result.put("offlineStdId", getOfflineStdId());
		result.put("participantType", getParticipantType());
		result.put("hostName", getHostName());
		result.put("status", getStatus());
		result.put("lang", getLang());
		return result;
	}
}

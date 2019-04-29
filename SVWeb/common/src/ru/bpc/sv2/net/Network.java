package ru.bpc.sv2.net;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Network implements Serializable, IAuditableObject, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String binTable;
	private Integer binTableScanPriority;
	private Integer offlineStandardId;
	private Integer seqNum;
	private Integer instId;
	private String instName;
	private String name;
	private String lang;
	private String description;
	private String statusReason;

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getBinTable() {
		return binTable;
	}
	public void setBinTable(String binTable) {
		this.binTable = binTable;
	}

	public Integer getBinTableScanPriority() {
		return binTableScanPriority;
	}
	public void setBinTableScanPriority(Integer binTableScanPriority) {
		this.binTableScanPriority = binTableScanPriority;
	}

	public Integer getOfflineStandardId() {
		return offlineStandardId;
	}
	public void setOfflineStandardId(Integer offlineStandardId) {
		this.offlineStandardId = offlineStandardId;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public String getStatusReason() {
		return statusReason;
	}
	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Object getModelId() {
		return id;
	}
	@Override
	public Network clone() throws CloneNotSupportedException {
		return (Network) super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("binTableScanPriority", getBinTableScanPriority());
		result.put("lang", getLang());
		result.put("name", getName());
		result.put("description", getDescription());
		return result;
	}
}

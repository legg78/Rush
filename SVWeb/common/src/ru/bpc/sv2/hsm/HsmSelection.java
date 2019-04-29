package ru.bpc.sv2.hsm;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class HsmSelection implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String description;
	private String lang;
	private String action;
	private Integer maxConnections;
	
	private Integer hsmId;
	private String hsmDescription;
	private Integer instId;
	private String instName;
	private Integer modId;
	private String modName;
	
	private Boolean isDeviceEnabled;
	private String hsmFirmware;
	
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

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public Integer getHsmId() {
		return hsmId;
	}

	public void setHsmId(Integer hsmId) {
		this.hsmId = hsmId;
	}

	public String getHsmDescription() {
		return hsmDescription;
	}

	public void setHsmDescription(String hsmDescription) {
		this.hsmDescription = hsmDescription;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
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

	public Integer getMaxConnections() {
		return maxConnections;
	}

	public void setMaxConnections(Integer maxConnections) {
		this.maxConnections = maxConnections;
	}

	public Boolean getIsDeviceEnabled() {
		return isDeviceEnabled;
	}

	public void setIsDeviceEnabled(Boolean isDeviceEnabled) {
		this.isDeviceEnabled = isDeviceEnabled;
	}

	public String getHsmFirmware() {
		return hsmFirmware;
	}

	public void setHsmFirmware(String hsmFirmware) {
		this.hsmFirmware = hsmFirmware;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public void incrementSeqnum(){
		this.seqNum++;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("action", getAction());
		result.put("modId", getModId());
		result.put("hsmId", getHsmId());
		result.put("maxConnections", getMaxConnections());
		result.put("hsmFirmware", getHsmFirmware());
		result.put("lang", getLang());
		result.put("description", getDescription());
		return result;
	}
}

package ru.bpc.sv2.hsm;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class HsmDevice implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private boolean enabled;
	private String type;
	private String plugin;
	private Integer statusOk;
	private Integer statusConfError;
	private Integer statusCommError;
	private Integer statusUnknown;
	private int seqNum;
	private String description;
	private String lang;
	private String manufacturer;
	private String serialNumber;
	private Integer lmkId;
	private String lmkDescription;
	private HsmConnection hsmTcp;
	private String modelNumber;
	@Deprecated
	private Integer nodeCount;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getPlugin() {
		return plugin;
	}

	public void setPlugin(String plugin) {
		this.plugin = plugin;
	}

	public Integer getStatusOk() {
		return statusOk;
	}

	public void setStatusOk(Integer statusOk) {
		this.statusOk = statusOk;
	}

	public Integer getStatusConfError() {
		return statusConfError;
	}

	public void setStatusConfError(Integer statusConfError) {
		this.statusConfError = statusConfError;
	}

	public Integer getStatusCommError() {
		return statusCommError;
	}

	public void setStatusCommError(Integer statusCommError) {
		this.statusCommError = statusCommError;
	}

	public Integer getStatusUnknown() {
		return statusUnknown;
	}

	public void setStatusUnknown(Integer statusUnknown) {
		this.statusUnknown = statusUnknown;
	}

	public int getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(int seqNum) {
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

	public String getManufacturer() {
		return manufacturer;
	}

	public void setManufacturer(String manufacturer) {
		this.manufacturer = manufacturer;
	}

	public String getSerialNumber() {
		return serialNumber;
	}

	public void setSerialNumber(String serialNumber) {
		this.serialNumber = serialNumber;
	}

	public Integer getLmkId() {
		return lmkId;
	}

	public void setLmkId(Integer lmkId) {
		this.lmkId = lmkId;
	}

	public String getLmkDescription() {
		return lmkDescription;
	}

	public void setLmkDescription(String lmkDescription) {
		this.lmkDescription = lmkDescription;
	}

	public HsmConnection getHsmTcp() {
		if (hsmTcp == null) {
			hsmTcp = new HsmConnection();
		}
		return hsmTcp;
	}

	public void setHsmTcp(HsmConnection hsmTcp) {
		this.hsmTcp = hsmTcp;
	}

	public String getModelNumber() {
		return modelNumber;
	}

	public void setModelNumber(String modelNumber) {
		this.modelNumber = modelNumber;
	}

	public Integer getNodeCount() {
		return nodeCount;
	}

	public void setNodeCount(Integer nodeCount) {
		this.nodeCount = nodeCount;
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
		result.put("enabled", isEnabled());
		result.put("type", getType());
		result.put("plugin", getPlugin());
		result.put("manufacturer", getManufacturer());
		result.put("serialNumber", getSerialNumber());
		result.put("lang", getLang());
		result.put("description", getDescription());
		result.put("lmkId", getLmkId());
		result.put("modelNumber", getModelNumber());
		return result;
	}
}

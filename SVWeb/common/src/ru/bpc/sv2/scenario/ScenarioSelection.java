package ru.bpc.sv2.scenario;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ScenarioSelection implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer scenarioId;
	private String name;
	private String description;
	private Integer modId;
	private String modName;
	private String lang;
	private String operType;
	private Boolean reversal;
	private String sttlType;
	private Integer priority;
	private String msgType;
	private String operReason;
	private String terminalType;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getScenarioId() {
		return scenarioId;
	}

	public void setScenarioId(Integer scenarioId) {
		this.scenarioId = scenarioId;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
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

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Object getModelId() {
		return getId();
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public Boolean getReversal() {
		return reversal;
	}

	public void setReversal(Boolean reversal) {
		this.reversal = reversal;
	}

	public String getSttlType() {
		return sttlType;
	}

	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getOperReason() {
		return operReason;
	}

	public void setOperReason(String operReason) {
		this.operReason = operReason;
	}

	public String getTerminalType() {
		return terminalType;
	}

	public void setTerminalType(String terminalType) {
		this.terminalType = terminalType;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("scenarioId", getScenarioId());
		result.put("modId", getModId());
		result.put("operType", getOperType());
		result.put("reversal", getReversal());
		result.put("sttlType", getSttlType());
		result.put("priority", getPriority());
		result.put("msgType", getMsgType());
		result.put("terminalType", getTerminalType());
		result.put("operReason", getOperReason());
		return result;
	}

}

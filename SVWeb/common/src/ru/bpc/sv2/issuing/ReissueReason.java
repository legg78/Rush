package ru.bpc.sv2.issuing;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReissueReason implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private Integer instId;
	private String instName;
	private String reissueReason;
	private String reissueCommand;
	private String pinRequest;
	private String pinMailerRequest;
	private String embossingRequest;
	private String reissStartDateRule;
	private String reissExpirDateRule;
	private String persoPriority;
	private Boolean cloneOptionalServices;
	private String cloneOptionalServicesValue;
	private String lang;

	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getReissueReason() {
		return reissueReason;
	}
	public void setReissueReason(String reissueReason) {
		this.reissueReason = reissueReason;
	}

	public String getReissueCommand() {
		return reissueCommand;
	}
	public void setReissueCommand(String reissueCommand) {
		this.reissueCommand = reissueCommand;
	}

	public String getPinRequest() {
		return pinRequest;
	}
	public void setPinRequest(String pinRequest) {
		this.pinRequest = pinRequest;
	}

	public String getPinMailerRequest() {
		return pinMailerRequest;
	}
	public void setPinMailerRequest(String pinMailerRequest) {
		this.pinMailerRequest = pinMailerRequest;
	}

	public String getEmbossingRequest() {
		return embossingRequest;
	}
	public void setEmbossingRequest(String embossingRequest) {
		this.embossingRequest = embossingRequest;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getReissStartDateRule() {
		return reissStartDateRule;
	}
	public void setReissStartDateRule(String reissStartDateRule) {
		this.reissStartDateRule = reissStartDateRule;
	}

	public String getReissExpirDateRule() {
		return reissExpirDateRule;
	}
	public void setReissExpirDateRule(String reissExpirDateRule) {
		this.reissExpirDateRule = reissExpirDateRule;
	}

	public String getPersoPriority() {
		return persoPriority;
	}
	public void setPersoPriority(String persoPriority) {
		this.persoPriority = persoPriority;
	}

	public Boolean getCloneOptionalServices() {
		return cloneOptionalServices;
	}
	public void setCloneOptionalServices(Boolean cloneOptionalServices) {
		this.cloneOptionalServices = cloneOptionalServices;
	}

	public String getCloneOptionalServicesValue() {
		return (getCloneOptionalServices() == null) ? null : getCloneOptionalServices() ? "1" : "0";
	}
	public void setCloneOptionalServicesValue(String cloneOptionalServicesValue) {
		if (cloneOptionalServicesValue != null) {
			setCloneOptionalServices(cloneOptionalServicesValue.equalsIgnoreCase("1"));
		} else {
			setCloneOptionalServices(null);
		}
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("reissueReason", getReissueReason());
		result.put("reissueCommand", getReissueCommand());
		result.put("pinRequest", getPinRequest());
		result.put("pinMailerRequest", getPinMailerRequest());
		result.put("embossingRequest", getEmbossingRequest());
		result.put("reissStartDateRule", getReissStartDateRule());
		result.put("reissExpirDateRule", getReissExpirDateRule());
		result.put("persoPriority", getPersoPriority());
		result.put("cloneOptionalServices", getCloneOptionalServices());
		return result;
	}
}

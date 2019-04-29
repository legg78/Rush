package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO Purposes tab.
 */
public class PmoPurpose implements ModelIdentifiable, IAuditableObject, Serializable, Cloneable {
	private static final long serialVersionUID = 549943522920261631L;

	private Integer id;
	private Integer providerId;
	private Integer serviceId;
	private String label;
	private Boolean direction;
	private String lang;
	private String hostAlgorithm;
	private String operType;
	private String mcc;
	private String purposeNumber;
	private Integer terminalId;
	private Integer modifierId;
	private String amountAlgorithm;
	private Integer instId;
	private String instName;

	public PmoPurpose() {}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}

	public Boolean getDirection() {
		return direction;
	}
	public void setDirection(Boolean direction) {
		this.direction = direction;
	}

	public String getHostAlgorithm() {
		return hostAlgorithm;
	}
	public void setHostAlgorithm(String hostAlgorithm) {
		this.hostAlgorithm = hostAlgorithm;
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

	public Integer getServiceId() {
		return serviceId;
	}
	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
	}

	public String getOperType() {
		return operType;
	}
	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getMcc() {
		return mcc;
	}
	public void setMcc(String mcc) {
		this.mcc = mcc;
	}

	public Integer getTerminalId() {
		return terminalId;
	}
	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}

	public String getPurposeNumber() {
		return purposeNumber;
	}
	public void setPurposeNumber(String purposeNumber) {
		this.purposeNumber = purposeNumber;
	}

	public Integer getModifierId() {
		return modifierId;
	}
	public void setModifierId(Integer modifierId) {
		this.modifierId = modifierId;
	}

	public String getAmountAlgorithm() {
		return amountAlgorithm;
	}
	public void setAmountAlgorithm(String amountAlgorithm) {
		this.amountAlgorithm = amountAlgorithm;
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

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("providerId", getProviderId());
		result.put("serviceId", getServiceId());
		result.put("hostAlgorithm", getHostAlgorithm());
		result.put("operType", getOperType());
		result.put("terminalId", getTerminalId());
		result.put("mcc", getMcc());
		result.put("purposeNumber", getPurposeNumber());
		result.put("modifierId", getModifierId());
		result.put("amountAlgorithm", getAmountAlgorithm());
		result.put("instId", getInstId());
		return result;
	}
}
package ru.bpc.sv2.application;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;


public class FlowStep implements Serializable, ModelIdentifiable,Cloneable {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private Long id;
	private String applStatus;
	private Integer displayOrder;
	private Integer flowId;
	private String lang;
	private Boolean readOnly;
	private Integer seqnum;
	private String stepLabel;
	private String stepSource;
	
	public Long getId() {
		return id;
	}
	
	public void setId(Long id) {
		this.id = id;
	}

	public String getApplStatus() {
		return applStatus;
	}

	public void setApplStatus(String applStatus) {
		this.applStatus = applStatus;
	}

	public Integer getDisplayOrder() {
		return displayOrder;
	}

	public void setDisplayOrder(Integer displayOrder) {
		this.displayOrder = displayOrder;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getFlowId() {
		return flowId;
	}

	public void setFlowId(Integer flowId) {
		this.flowId = flowId;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Boolean getReadOnly() {
		return readOnly;
	}

	public void setReadOnly(Boolean readOnly) {
		this.readOnly = readOnly;
	}

	public String getStepLabel() {
		return stepLabel;
	}

	public void setStepLabel(String stepLabel) {
		this.stepLabel = stepLabel;
	}

	public String getStepSource() {
		return stepSource;
	}

	public void setStepSource(String stepSource) {
		this.stepSource = stepSource;
	}

	@Override
	public Object getModelId() {
		return getId();
	}

}

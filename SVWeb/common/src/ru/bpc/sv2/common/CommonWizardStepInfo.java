package ru.bpc.sv2.common;

import java.io.Serializable;

public class CommonWizardStepInfo implements Serializable {
	private Long id;
	private Integer order;
	private String source;
	private String name;
	private Long wizardId;
	private String lang;
	private Integer seqnum;

	public CommonWizardStepInfo(){}
	public CommonWizardStepInfo(String source, String name){
		this.source = source;
		this.name = name;
	}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getOrder() {
		return order;
	}
	public void setOrder(Integer order) {
		this.order = order;
	}

	public String getSource() {
		return source;
	}
	public void setSource(String source) {
		this.source = source;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public Long getWizardId() {
		return wizardId;
	}
	public void setWizardId(Long wizardId) {
		this.wizardId = wizardId;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}
}

package ru.bpc.sv2.common;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Company implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private String embossedName;
	private Integer seqNum;
	private Integer splitHash;
	private String lang;
	private String label;
	private String description;
	private String incorp_form;
	private String statusReason;

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getEmbossedName() {
		return embossedName;
	}
	public void setEmbossedName(String embossedName) {
		this.embossedName = embossedName;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getSplitHash() {
		return splitHash;
	}
	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getLabel() {
		return label;
	}
	public void setLabel(String label) {
		this.label = label;
	}

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public String getIncorp_form() {
		return incorp_form;
	}
	public void setIncorp_form(String incorp_form) {
		this.incorp_form = incorp_form;
	}

	public String getStatusReason() {
		return statusReason;
	}
	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	
}

package ru.bpc.sv2.aup;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class TagValue implements Serializable, ModelIdentifiable {

	private static final long serialVersionUID = 1L;

	private Long authId;
	private Integer tag;
	private String tagValue;
	private String tagName;
	private String lang;
	private Integer seqNumber;
	
	public Object getModelId() {
		return authId + "_" + tag + "_" + seqNumber;
	}

	public Long getAuthId() {
		return authId;
	}

	public void setAuthId(Long authId) {
		this.authId = authId;
	}

	public Integer getTag() {
		return tag;
	}

	public void setTag(Integer tag) {
		this.tag = tag;
	}

	public String getTagValue() {
		return tagValue;
	}

	public void setTagValue(String tagValue) {
		this.tagValue = tagValue;
	}

	public String getTagName() {
		return tagName;
	}

	public void setTagName(String tagName) {
		this.tagName = tagName;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getSeqNumber() {
		return seqNumber;
	}

	public void setSeqNumber(Integer seqNumber) {
		this.seqNumber = seqNumber;
	}
}

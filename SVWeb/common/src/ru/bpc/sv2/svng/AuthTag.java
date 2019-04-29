package ru.bpc.sv2.svng;

/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class AuthTag {

	private Long operId;
	private Integer tagId;
	private String tagValue;
	private String tagName;

	public AuthTag(Long operId) {
		super();
		this.operId = operId;
	}

	public AuthTag(Long operId, String tagName, String tagValue) {
		this.operId = operId;
		this.tagName = tagName;
		this.tagValue = tagValue;
	}

	public AuthTag(String tagName, String tagValue) {
		this.tagName = tagName;
		this.tagValue = tagValue;
	}

	public Long getOperId() {
		return operId;
	}

	public void setOperId(Long operId) {
		this.operId = operId;
	}

	public Integer getTagId() {
		return tagId;
	}

	public void setTagId(Integer tagId) {
		this.tagId = tagId;
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
}

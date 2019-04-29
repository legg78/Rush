package ru.bpc.sv2.svng;

/**
 * BPC Group 2019 (c) All Rights Reserved
 */
public class AupTag {

	private Integer tagId;
	private String tagValue;
	private String tagName;
	private Integer seqNumber;

	public AupTag() {
		super();
	}

	public AupTag(Integer tagId, String tagName, String tagValue, Integer seqNumber) {
		this.tagId = tagId;
		this.tagName = tagName;
		this.tagValue = tagValue;
		this.seqNumber = seqNumber;
	}

	public AupTag(String tagName, String tagValue) {
		this.tagName = tagName;
		this.tagValue = tagValue;
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

	public Integer getSeqNumber() {
		return seqNumber;
	}

	public void setSeqNumber(Integer seqNumber) {
		this.seqNumber = seqNumber;
	}
}

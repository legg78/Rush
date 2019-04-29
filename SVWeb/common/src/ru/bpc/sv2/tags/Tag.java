package ru.bpc.sv2.tags;

import java.io.Serializable;

public class Tag implements Serializable {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private String tagType;
	private String tagValue;
	public String getTagType() {
		return tagType;
	}
	public void setTagType(String tagType) {
		this.tagType = tagType;
	}
	public String getTagValue() {
		return tagValue;
	}
	public void setTagValue(String tagValue) {
		this.tagValue = tagValue;
	}
	
	

}


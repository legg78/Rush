package ru.bpc.sv2.application;

import java.io.Serializable;

public class ApplicationError implements Serializable, Cloneable {

	private static final long serialVersionUID = 1L;

	private Long dataId;
	private Long parentDataId;
	private String elementName;
	private String code;
	private String message;
	private String details;
	private Long applicationId;
	
	public Long getDataId() {
		return dataId;
	}

	public void setDataId(Long dataId) {
		this.dataId = dataId;
	}

	public Long getParentDataId() {
		return parentDataId;
	}

	public void setParentDataId(Long parentDataId) {
		this.parentDataId = parentDataId;
	}

	public String getElementName() {
		return elementName;
	}

	public void setElementName(String elementName) {
		this.elementName = elementName;
	}

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getMessage() {
		return message;
	}

	public void setMessage(String message) {
		this.message = message;
	}

	public String getDetails() {
		return details;
	}

	public void setDetails(String details) {
		this.details = details;
	}

	public Long getApplicationId() {
		return applicationId;
	}

	public void setApplicationId(Long applicationId) {
		this.applicationId = applicationId;
	}

	@Override
	public ApplicationError clone() throws CloneNotSupportedException {
		return (ApplicationError) super.clone();
	}

}

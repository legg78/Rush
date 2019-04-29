package ru.bpc.sv2.ps;

import java.io.Serializable;

public class McRejectCode implements Serializable{
	private Long id;
	private String deNumber;
	private String severityCode;
	private String messageCode;
	private String subfieldId;
	private Boolean fromOrigMsg;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getDeNumber() {
		return deNumber;
	}

	public void setDeNumber(String deNumber) {
		this.deNumber = deNumber;
	}

	public String getSeverityCode() {
		return severityCode;
	}

	public void setSeverityCode(String severityCode) {
		this.severityCode = severityCode;
	}

	public String getMessageCode() {
		return messageCode;
	}

	public void setMessageCode(String messageCode) {
		this.messageCode = messageCode;
	}

	public String getSubfieldId() {
		return subfieldId;
	}

	public void setSubfieldId(String subfieldId) {
		this.subfieldId = subfieldId;
	}

	public Boolean getFromOrigMsg() {
		return fromOrigMsg;
	}

	public void setFromOrigMsg(Boolean fromOrigMsg) {
		this.fromOrigMsg = fromOrigMsg;
	}
}

package ru.bpc.sv2.process;

import java.io.Serializable;

import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessSessionFile implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer processId;
	private Date startDate;
	private Date endDate;
	private String resultCode;
	private Long processed;
	private Long rejected;
	private Long containerSessionId;
	private String crc;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getProcessId() {
		return processId;
	}

	public void setProcessId(Integer processId) {
		this.processId = processId;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	public String getResultCode() {
		return resultCode;
	}

	public void setResultCode(String resultCode) {
		this.resultCode = resultCode;
	}

	public Long getProcessed() {
		return processed;
	}

	public void setProcessed(Long processed) {
		this.processed = processed;
	}

	public Long getRejected() {
		return rejected;
	}

	public void setRejected(Long rejected) {
		this.rejected = rejected;
	}

	public Long getContainerSessionId() {
		return containerSessionId;
	}

	public void setContainerSessionId(Long containerSessionId) {
		this.containerSessionId = containerSessionId;
	}

	public String getCrc() {
		return crc;
	}

	public void setCrc(String crc) {
		this.crc = crc;
	}
	
}

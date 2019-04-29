package ru.bpc.sv2.process;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class ProcessStat implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long sessionId;
	private Integer threadNumber;
	private Integer traceLevel;
	private Date startTime;
	private Date currentTime;
	private Date endTime;
	private Long estimatedCount;
	private Long currentCount;
	private Long processedTotal;
	private Long exceptedTotal;
	private Long rejectedTotal;
	private String resultCode;
	private Integer progress;

	public Object getModelId() {
		return getSessionId() + "_" + getThreadNumber();
	}

	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Integer getThreadNumber() {
		return threadNumber;
	}
	public void setThreadNumber(Integer threadNumber) {
		this.threadNumber = threadNumber;
	}

	public Date getStartTime() {
		return startTime;
	}
	public void setStartTime(Date startTime) {
		this.startTime = startTime;
	}

	public Date getCurrentTime() {
		return currentTime;
	}
	public void setCurrentTime(Date currentTime) {
		this.currentTime = currentTime;
	}

	public Date getEndTime() {
		return endTime;
	}
	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	public Long getEstimatedCount() {
		return estimatedCount;
	}
	public void setEstimatedCount(Long estimatedCount) {
		this.estimatedCount = estimatedCount;
	}

	public Long getCurrentCount() {
		return currentCount;
	}
	public void setCurrentCount(Long currentCount) {
		this.currentCount = currentCount;
	}

	public Long getProcessedTotal() {
		return processedTotal;
	}
	public void setProcessedTotal(Long processedTotal) {
		this.processedTotal = processedTotal;
	}

	public Long getExceptedTotal() {
		return exceptedTotal;
	}
	public void setExceptedTotal(Long exceptedTotal) {
		this.exceptedTotal = exceptedTotal;
	}

	public String getResultCode() {
		return resultCode;
	}
	public void setResultCode(String resultCode) {
		this.resultCode = resultCode;
	}

	public Integer getProgress() {
		return progress;
	}
	public void setProgress(Integer progress) {
		this.progress = progress;
	}

	public Long getRejectedTotal() {
		return rejectedTotal;
	}
	public void setRejectedTotal(Long rejectedTotal) {
		this.rejectedTotal = rejectedTotal;
	}

	public Integer getTraceLevel() {
		return traceLevel;
	}
	public void setTraceLevel(Integer traceLevel) {
		this.traceLevel = traceLevel;
	}
}
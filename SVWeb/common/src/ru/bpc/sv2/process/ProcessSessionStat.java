package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessSessionStat implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long sessionId;
	private Long parentSessionId;
	private Integer threadNum;
	private Integer threadCount;
	private Date startTime;
	private Date endTime;
	private Date currentTime;
	private Long spendTime;
	private Long wasteTime;
	private Long estimatedCount;
	private Long currentCount;
	private Long processedTotal;
	private Long rejectedTotal;
	private Long exceptedTotal;
	private String resultCode;
	
	public Object getModelId() {
		return getSessionId() + "_" + getThreadNum();
	}

	public Long getSessionId() {
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}

	public Integer getThreadNum() {
		return threadNum;
	}

	public void setThreadNum(Integer threadNum) {
		this.threadNum = threadNum;
	}

	public Date getStartTime() {
		return startTime;
	}

	public void setStartTime(Date startTime) {
		this.startTime = startTime;
	}

	public Date getEndTime() {
		return endTime;
	}

	public void setEndTime(Date endTime) {
		this.endTime = endTime;
	}

	public Date getCurrentTime() {
		return currentTime;
	}

	public void setCurrentTime(Date currentTime) {
		this.currentTime = currentTime;
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

	public Long getParentSessionId() {
		return parentSessionId;
	}

	public void setParentSessionId(Long parentSessionId) {
		this.parentSessionId = parentSessionId;
	}

	public Integer getThreadCount() {
		return threadCount;
	}

	public void setThreadCount(Integer threadCount) {
		this.threadCount = threadCount;
	}

	public Long getSpendTime() {
		return spendTime;
	}

	public void setSpendTime(Long spendTime) {
		this.spendTime = spendTime;
	}

	public Long getWasteTime() {
		return wasteTime;
	}

	public void setWasteTime(Long wasteTime) {
		this.wasteTime = wasteTime;
	}

	public Long getRejectedTotal() {
		return rejectedTotal;
	}

	public void setRejectedTotal(Long rejectedTotal) {
		this.rejectedTotal = rejectedTotal;
	}
	
}

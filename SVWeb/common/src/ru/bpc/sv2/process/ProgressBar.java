package ru.bpc.sv2.process;

import java.io.Serializable;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProgressBar implements Serializable, ModelIdentifiable {

	private static final long serialVersionUID = 1L;

	private Long sessionId;
	private Integer containerProcessId;
	private Integer processId;
	private int threadNum;	
	private Long currentValue;
	private Long maxValue;
	
	public Long getSessionId() {
		return sessionId;
	}
	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
	}
	public int getThreadNum() {
		return threadNum;
	}
	public void setThreadNum(int threadNum) {
		this.threadNum = threadNum;
	}
	public Long getCurrentValue() {
		return currentValue;
	}
	public void setCurrentValue(Long currentValue) {
		this.currentValue = currentValue;
	}
	public Long getMaxValue() {
		return maxValue;
	}
	public void setMaxValue(Long maxValue) {
		this.maxValue = maxValue;
	}
	
	public Integer getProcessId() {
		return processId;
	}
	public void setProcessId(Integer processId) {
		this.processId = processId;
	}
	
	public Integer getContainerProcessId() {
		return containerProcessId;
	}
	public void setContainerProcessId(Integer containerProcessId) {
		this.containerProcessId = containerProcessId;
	}
	public Object getModelId() {
		return containerProcessId + "_" + processId + "_" + threadNum;
	}
}

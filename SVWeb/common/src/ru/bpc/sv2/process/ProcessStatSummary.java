package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.ArrayList;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessStatSummary extends ProcessStat implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Long spendTime;
	private Long wasteTime;
	private Integer threadCount;
	private Long parentSessionId;
	private String processName;
	private Integer processId;
	private int level;
	private boolean isLeaf;
	private ArrayList<ProcessStatSummary> children;
	private String recType;
	private Integer threadNumber;
	
	public Object getModelId() {
		return getSessionId();
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

	public Integer getThreadCount() {
		return threadCount;
	}

	public void setThreadCount(Integer threadCount) {
		this.threadCount = threadCount;
	}

	public Long getParentSessionId() {
		return parentSessionId;
	}

	public void setParentSessionId(Long parentSessionId) {
		this.parentSessionId = parentSessionId;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public ArrayList<ProcessStatSummary> getChildren() {
		return children;
	}

	public void setChildren(ArrayList<ProcessStatSummary> children) {
		this.children = children;
	}
	
	public boolean hasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public Integer getProcessId() {
		return processId;
	}

	public void setProcessId(Integer processId) {
		this.processId = processId;
	}

	public String getProcessName() {
		return processName;
	}

	public void setProcessName(String processName) {
		this.processName = processName;
	}

	public String getRecType() {
		return recType;
	}

	public void setRecType(String recType) {
		this.recType = recType;
	}
	
	public String getUnique() {
		return getSessionId() + "_" + getThreadNumber();
	}

	public Integer getThreadNumber() {
		return threadNumber;
	}

	public void setThreadNumber(Integer threadNumber) {
		this.threadNumber = threadNumber;
	}
	
}
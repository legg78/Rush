package ru.bpc.sv2.operations.incoming;

import java.io.Serializable;

public class OperationReconciliation implements Serializable{
	private static final long serialVersionUID = 1L;
	
	private String operType;
	private String terminalNumber;
	private Double operationAmount;
	private Long operCount;
	
	public String getOperType() {
		return operType;
	}
	public void setOperType(String operType) {
		this.operType = operType;
	}
	public String getTerminalNumber() {
		return terminalNumber;
	}
	public void setTerminalNumber(String terminalNumber) {
		this.terminalNumber = terminalNumber;
	}
	public Double getOperationAmount() {
		return operationAmount;
	}
	public void setOperationAmount(Double operationAmount) {
		this.operationAmount = operationAmount;
	}
	public Long getOperCount() {
		return operCount;
	}
	public void setOperCount(Long operCount) {
		this.operCount = operCount;
	}
	
}

package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.math.BigDecimal;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class OperationStat implements Serializable, ModelIdentifiable {
	private static final long serialVersionUID = 1L;

	private int rownum;
	private int records;
	private String msgType;
	private String operType;
	private String status;
	private String sttlType;
	private BigDecimal operAmount;
	private String operCurrency;
	private Boolean reversal;
	
	public Object getModelId(){
		return rownum;
	}

	public int getRownum() {
		return rownum;
	}

	public void setRownum(int rownum) {
		this.rownum = rownum;
	}

	public int getRecords() {
		return records;
	}

	public void setRecords(int records) {
		this.records = records;
	}

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getSttlType() {
		return sttlType;
	}

	public void setSttlType(String sttlType) {
		this.sttlType = sttlType;
	}

	public BigDecimal getOperAmount() {
		return operAmount;
	}

	public void setOperAmount(BigDecimal operAmount) {
		this.operAmount = operAmount;
	}

	public Boolean getReversal() {
		return reversal;
	}

	public void setReversal(Boolean reversal) {
		this.reversal = reversal;
	}

	public String getOperCurrency() {
		return operCurrency;
	}

	public void setOperCurrency(String operCurrency) {
		this.operCurrency = operCurrency;
	}
	
}

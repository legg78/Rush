package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.math.BigDecimal;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class EntryStat implements Serializable, ModelIdentifiable {
	private static final long serialVersionUID = 1L;

	private int rownum;
	private int records;
	private String transType;
	private String accountType;
	private String amountPurpose;
	private String balanceType;
	private BigDecimal amountDebit;
	private BigDecimal amountCredit;
	private String currency;
	private int countDebit;
	private int countCredit;
		
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

	public String getTransType() {
		return transType;
	}

	public void setTransType(String transType) {
		this.transType = transType;
	}

	public String getAccountType() {
		return accountType;
	}

	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public String getAmountPurpose() {
		return amountPurpose;
	}

	public void setAmountPurpose(String amountPurpose) {
		this.amountPurpose = amountPurpose;
	}

	public String getBalanceType() {
		return balanceType;
	}

	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}
	public BigDecimal getAmountDebit() {
		return amountDebit;
	}

	public void setAmountDebit(BigDecimal amountDebit) {
		this.amountDebit = amountDebit;
	}

	public BigDecimal getAmountCredit() {
		return amountCredit;
	}

	public void setAmountCredit(BigDecimal amountCredit) {
		this.amountCredit = amountCredit;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public int getCountDebit() {
		return countDebit;
	}

	public void setCountDebit(int countDebit) {
		this.countDebit = countDebit;
	}

	public int getCountCredit() {
		return countCredit;
	}

	public void setCountCredit(int countCredit) {
		this.countCredit = countCredit;
	}
	
}

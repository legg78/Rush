package ru.bpc.sv2.loyalty;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class LoyaltyProgram implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;
	private Integer id;
	private int seqNum;
	private String name;
	private String lang;
	private String currency;
	private String accountType;
	private Integer spendOrder;
	private Integer instId;
	private String instName;
	
	private Integer spendEntrySetId;
	private String spendEntrySetName;
	private Integer outdEntrySetId;
	private String outdEntrySetName;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public int getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(int seqNum) {
		this.seqNum = seqNum;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getAccountType() {
		return accountType;
	}

	public void setAccountType(String accountType) {
		this.accountType = accountType;
	}

	public Integer getSpendOrder() {
		return spendOrder;
	}

	public void setSpendOrder(Integer spendOrder) {
		this.spendOrder = spendOrder;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public Integer getSpendEntrySetId() {
		return spendEntrySetId;
	}

	public void setSpendEntrySetId(Integer spendEntrySetId) {
		this.spendEntrySetId = spendEntrySetId;
	}

	public String getSpendEntrySetName() {
		return spendEntrySetName;
	}

	public void setSpendEntrySetName(String spendEntrySetName) {
		this.spendEntrySetName = spendEntrySetName;
	}

	public Integer getOutdEntrySetId() {
		return outdEntrySetId;
	}

	public void setOutdEntrySetId(Integer outdEntrySetId) {
		this.outdEntrySetId = outdEntrySetId;
	}

	public String getOutdEntrySetName() {
		return outdEntrySetName;
	}

	public void setOutdEntrySetName(String outdEntrySetName) {
		this.outdEntrySetName = outdEntrySetName;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public void incrementSeqnum(){
		this.seqNum++;
	}
}

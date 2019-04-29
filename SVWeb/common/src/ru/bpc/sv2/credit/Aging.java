package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Aging implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;
	
	private Long id;
	private Long invoiceId;
	private Integer agingPeriod;
	private Date agingDate;
	private Double agingAmount;
	private Integer splitHash;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getInvoiceId() {
		return invoiceId;
	}

	public void setInvoiceId(Long invoiceId) {
		this.invoiceId = invoiceId;
	}

	public Integer getAgingPeriod() {
		return agingPeriod;
	}

	public void setAgingPeriod(Integer agingPeriod) {
		this.agingPeriod = agingPeriod;
	}

	public Date getAgingDate() {
		return agingDate;
	}

	public void setAgingDate(Date agingDate) {
		this.agingDate = agingDate;
	}

	public Double getAgingAmount() {
		return agingAmount;
	}

	public void setAgingAmount(Double agingAmount) {
		this.agingAmount = agingAmount;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}

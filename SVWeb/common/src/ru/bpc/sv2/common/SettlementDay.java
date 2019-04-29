package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class SettlementDay implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;
	private Integer id;
	private Integer sttlDay;
	private Date openDate;
	private Date sttlDate;
	private boolean isOpen;
	private Integer instId;
	private String instName;
	private Integer seqNum;
	
	//filter fields
	private Date sttlDateFrom;
	private Date sttlDateTo;

	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSttlDay() {
		return sttlDay;
	}

	public void setSttlDay(Integer sttlDay) {
		this.sttlDay = sttlDay;
	}

	public Date getOpenDate() {
		return openDate;
	}

	public void setOpenDate(Date openDate) {
		this.openDate = openDate;
	}

	public Date getSttlDate() {
		return sttlDate;
	}

	public void setSttlDate(Date sttlDate) {
		this.sttlDate = sttlDate;
	}

	public boolean isOpen() {
		return isOpen;
	}

	public void setOpen(boolean isOpen) {
		this.isOpen = isOpen;
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

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Date getSttlDateFrom() {
		return sttlDateFrom;
	}

	public void setSttlDateFrom(Date sttlDateFrom) {
		this.sttlDateFrom = sttlDateFrom;
	}

	public Date getSttlDateTo() {
		return sttlDateTo;
	}

	public void setSttlDateTo(Date sttlDateTo) {
		this.sttlDateTo = sttlDateTo;
	}
	
}

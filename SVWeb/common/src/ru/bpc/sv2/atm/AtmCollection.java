package ru.bpc.sv2.atm;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AtmCollection implements Serializable, ModelIdentifiable, Cloneable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer terminalId;
	private Date startDate;
	private Date endDate;
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getTerminalId() {
		return terminalId;
	}

	public void setTerminalId(Integer terminalId) {
		this.terminalId = terminalId;
	}
	public Object getModelId() {
		return getId();
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
}

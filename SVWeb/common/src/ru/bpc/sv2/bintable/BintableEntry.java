package ru.bpc.sv2.bintable;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class BintableEntry implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private String hpan;
	private String code;
	private Date startDate;
	private Date endDate;
	
	public Object getModelId() {
		return getId();
	}
	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}
	public String getHpan() {
		return hpan;
	}
	public void setHpan(String hpan) {
		this.hpan = hpan;
	}
	public String getCode() {
		return code;
	}
	public void setCode(String code) {
		this.code = code;
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
	
}

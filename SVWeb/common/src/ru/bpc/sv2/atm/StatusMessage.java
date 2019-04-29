package ru.bpc.sv2.atm;

import java.util.Date;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class StatusMessage implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Integer terminalId;
	private Date changeDate;
	private String status;
	private String statusName;
	private String lang;
	private Long id;
	
	public Object getModelId() {
		return getId();
	}
	
	public Integer getTerminalId(){
		return this.terminalId;
	}
	
	public void setTerminalId(Integer terminalId){
		this.terminalId = terminalId;
	}
	
	public Date getChangeDate(){
		return this.changeDate;
	}
	
	public void setChangeDate(Date changeDate){
		this.changeDate = changeDate;
	}
	
	public String getStatus(){
		return this.status;
	}
	
	public void setStatus(String status){
		this.status = status;
	}
	
	public String getStatusName(){
		return this.statusName;
	}
	
	public void setStatusName(String statusName){
		this.statusName = statusName;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
}
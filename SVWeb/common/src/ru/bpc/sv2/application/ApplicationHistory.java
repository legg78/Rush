package ru.bpc.sv2.application;

import java.util.Date;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class ApplicationHistory implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Long applId;
	private Date changeDate;
	private Integer changeUser;
	private String changeAction;
	private String applStatus;
	private String comments;
	private String userName;
	private String changeActionName;
	private String personName;

	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Long getApplId(){
		return this.applId;
	}
	
	public void setApplId(Long applId){
		this.applId = applId;
	}
	
	public Date getChangeDate(){
		return this.changeDate;
	}
	
	public void setChangeDate(Date changeDate){
		this.changeDate = changeDate;
	}
	
	public Integer getChangeUser(){
		return this.changeUser;
	}
	
	public void setChangeUser(Integer changeUser){
		this.changeUser = changeUser;
	}
	
	public String getApplStatus(){
		return this.applStatus;
	}
	
	public void setApplStatus(String applStatus){
		this.applStatus = applStatus;
	}
	
	public String getComments(){
		return this.comments;
	}
	
	public void setComments(String comments){
		this.comments = comments;
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

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public String getChangeAction() {
		return changeAction;
	}

	public void setChangeAction(String changeAction) {
		this.changeAction = changeAction;
	}

	public String getChangeActionName() {
		return changeActionName;
	}

	public void setChangeActionName(String changeActionName) {
		this.changeActionName = changeActionName;
	}

	public String getPersonName() {
		if (personName == null) {
			return getUserName();
		}
		return personName;
	}

	public void setPersonName(String personName) {
		this.personName = personName;
	}
}
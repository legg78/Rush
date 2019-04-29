package ru.bpc.sv2.atm;

import java.util.Date;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;

public class AdminOperation implements Serializable, ModelIdentifiable, Cloneable{

	private static final long serialVersionUID = 1L;

	private Integer terminalId;
	private Date commandDate;
	private String command;
	private String commandName;
	private String commandResult;
	private String commandResultName;
	private Integer userId;
	private String userName;
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
	
	public Date getCommandDate(){
		return this.commandDate;
	}
	
	public void setCommandDate(Date commandDate){
		this.commandDate = commandDate;
	}
	
	public String getCommand(){
		return this.command;
	}
	
	public void setCommand(String command){
		this.command = command;
	}
	
	public String getCommandName(){
		return this.commandName;
	}
	
	public void setCommandName(String commandName){
		this.commandName = commandName;
	}
	
	public String getCommandResult(){
		return this.commandResult;
	}
	
	public void setCommandResult(String commandResult){
		this.commandResult = commandResult;
	}
	
	public String getCommandResultName(){
		return this.commandResultName;
	}
	
	public void setCommandResultName(String commandResultName){
		this.commandResultName = commandResultName;
	}
	
	public Integer getUserId(){
		return this.userId;
	}
	
	public void setUserId(Integer userId){
		this.userId = userId;
	}
	
	public String getUserName(){
		return this.userName;
	}
	
	public void setUserName(String userName){
		this.userName = userName;
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
package ru.bpc.sv2.process;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ProcessUserSession implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private String userName;
	private Date startDate;
	private Date lastUsed;
	private String firstName;
	private String secondName;
	private String surname;
	private String lang;
	private String ipAddress;
	private String loginStatus;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getUserName() {
		return userName;
	}

	public void setUserName(String userName) {
		this.userName = userName;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getLastUsed() {
		return lastUsed;
	}

	public void setLastUsed(Date lastUsed) {
		this.lastUsed = lastUsed;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getSecondName() {
		return secondName;
	}

	public void setSecondName(String secondName) {
		this.secondName = secondName;
	}

	public String getSurname() {
		return surname;
	}

	public void setSurname(String surname) {
		this.surname = surname;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getIpAddress() {
		return ipAddress;
	}

	public void setIpAddress(String ipAddress) {
		this.ipAddress = ipAddress;
	}

	public String getLoginStatus() {
		return loginStatus;
	}

	public void setLoginStatus(String loginStatus) {
		this.loginStatus = loginStatus;
	}

	public ProcessUserSession copy() {
		ProcessUserSession copy = new ProcessUserSession();
		copy.setId(id);
		copy.setIpAddress(ipAddress);
		copy.setUserName(userName);
		copy.setFirstName(firstName);
		copy.setSecondName(secondName);
		copy.setSurname(surname);
		copy.setLang(lang);
		copy.setLoginStatus(loginStatus);
		if (startDate != null) {
			copy.setStartDate(new Date(startDate.getTime()));
		}
		if (lastUsed != null) {
			copy.setLastUsed(new Date(lastUsed.getTime()));
		}
		
		return copy;
	}

	@Override
	public ProcessUserSession clone() throws CloneNotSupportedException {
		return (ProcessUserSession)super.clone();
	}
}

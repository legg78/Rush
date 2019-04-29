package ru.bpc.sv2.administrative.users;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;


import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class User implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 6051216974761594368L;

	private Integer id;
	private String status;
	private String name;
	private String password;
	private Long personId;
	private boolean force;
	private Person person;
	private Integer instId;
	private boolean passwordChangeNeeded;
	private Date creationDate;
	private Date unlockDate;
	private String authScheme;
	private String statusReason;

	public User() {}
	public User(Integer id) {
		setId(id);
	}
	public User(Integer id, String name) {
		setId(id);
		setName(name);
	}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public String getStatus() {
		return status;
	}
	public void setStatus(String status) {
		this.status = status;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getPassword() {
		return password;
	}
	public void setPassword(String password) {
		this.password = password;
	}

	public Long getPersonId() {
		return personId;
	}
	public void setPersonId(Long personId) {
		this.personId = personId;
	}

	public boolean isForce() {
		return force;
	}
	public void setForce(boolean force) {
		this.force = force;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public boolean isPasswordChangeNeeded() {
		return passwordChangeNeeded;
	}
	public void setPasswordChangeNeeded(boolean passwordChangeNeeded) {
		this.passwordChangeNeeded = passwordChangeNeeded;
	}

	public Person getPerson() {
		if (person == null)
			person = new Person();
		return person;
	}
	public void setPerson(Person person) {
		this.person = person;
	}

	public Date getCreationDate() { return creationDate; }
	public void setCreationDate(Date creationDate) { this.creationDate = creationDate; }

	public Date getUnlockDate() {
		return unlockDate;
	}
	public void setUnlockDate(Date unlockDate) {
		this.unlockDate = unlockDate;
	}

	public String getAuthScheme() {
		return authScheme;
	}
	public void setAuthScheme(String authScheme) {
		this.authScheme = authScheme;
	}

	public String getStatusReason() {
		return statusReason;
	}
	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Object getModelId() {
		return getId();
	}
	@Override
	public User clone() throws CloneNotSupportedException {
		return (User)super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("name", getName());
		result.put("personId", getPersonId());
		result.put("passwordChangeNeeded", isPasswordChangeNeeded());
		result.put("authScheme", getAuthScheme());
		result.put("unlockDate", getUnlockDate());
		return result;
	}
}

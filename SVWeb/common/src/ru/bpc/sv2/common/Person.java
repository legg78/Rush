package ru.bpc.sv2.common;

import java.io.Serializable;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Person implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long personId; // unique person Id (paired with lang)
	private String lang;
	private String title;
	private String firstName;
	private String secondName;
	private String surname;
	private String suffix;
	private String gender;
	private Date birthday;
	private String placeOfBirth;
	private Integer seqNum;
	private Integer instId;
	private String statusReason;

	public Long getPersonId() {
		return personId;
	}

	public void setPersonId(Long personId) {
		this.personId = personId;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
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

	public String getSuffix() {
		return suffix;
	}

	public void setSuffix(String suffix) {
		this.suffix = suffix;
	}

	public String getGender() {
		return gender;
	}

	public void setGender(String gender) {
		this.gender = gender;
	}

	public Date getBirthday() {
		return birthday;
	}

	public void setBirthday(Date birthday) {
		this.birthday = birthday;
	}

	public String getPlaceOfBirth() {
		return placeOfBirth;
	}

	public void setPlaceOfBirth(String placeOfBirth) {
		this.placeOfBirth = placeOfBirth;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public void setFullName(String fullName) {
		// blank
	}

	public String getFullName() {
		return (surname == null ? "" : surname)
				+ (firstName == null ? "" : " " + firstName)
				+ (secondName == null ? "" : " " + secondName);
	}

	public String getStatusReason() {
		return statusReason;
	}

	public void setStatusReason(String statusReason) {
		this.statusReason = statusReason;
	}

	@Override
	public Object getModelId() {
		return getPersonId();
	}
	@Override
	public Person clone() throws CloneNotSupportedException {
		return (Person) super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("lang", this.getLang());
		result.put("title", this.getTitle());
		result.put("surname", this.getSurname());
		result.put("firstName", this.getFirstName());
		result.put("secondName", this.getSecondName());
		result.put("suffix", this.getSuffix());
		result.put("gender", this.getGender());
		result.put("birthday", this.getBirthday());
		result.put("instId", this.getInstId());
		return result;
	}
}

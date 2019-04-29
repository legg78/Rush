package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Contact implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long contactDataId;
	private Long personId;
	private String jobTitle;
	private Integer seqNum;
	private Long relationId;
	private Person person;
	private String contactType;
	private String type;
	private String address;
	private String preferredLang;
	private Integer instId;
	private Date startDate;
	private Date endDate;

	private String imType;
	private String imNumber;
	private String email;
	private String phone;
	private String mobile;
	private String fax;
	private String statusReason;

	private List<ContactData> contactData;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getContactDataId() {
		return contactDataId;
	}

	public void setContactDataId(Long contactDataId) {
		this.contactDataId = contactDataId;
	}

	public Long getPersonId() {
		return personId;
	}

	public void setPersonId(Long personId) {
		this.personId = personId;
	}

	public String getJobTitle() {
		return jobTitle;
	}

	public void setJobTitle(String jobTitle) {
		this.jobTitle = jobTitle;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Long getRelationId() {
		return relationId;
	}

	public void setRelationId(Long relationId) {
		this.relationId = relationId;
	}

	public Person getPerson() {
		return person;
	}

	public void setPerson(Person person) {
		this.person = person;
	}

	public String getContactType() {
		return contactType;
	}

	public void setContactType(String contactType) {
		this.contactType = contactType;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public String getAddress() {
		return address;
	}

	public void setAddress(String address) {
		this.address = address;
	}

	public String getPreferredLang() {
		return preferredLang;
	}

	public void setPreferredLang(String preferredLang) {
		this.preferredLang = preferredLang;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
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

	public String getImType() {
		return imType;
	}

	public void setImType(String imType) {
		this.imType = imType;
	}

	public String getImNumber() {
		return imNumber;
	}

	public void setImNumber(String imNumber) {
		this.imNumber = imNumber;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPhone() {
		return phone;
	}

	public void setPhone(String phone) {
		this.phone = phone;
	}

	public String getMobile() {
		return mobile;
	}

	public void setMobile(String mobile) {
		this.mobile = mobile;
	}

	public String getFax() {
		return fax;
	}

	public void setFax(String fax) {
		this.fax = fax;
	}

	public List<ContactData> getContactData() {
		return contactData;
	}

	public void setContactData(List<ContactData> contactData) {
		this.contactData = contactData;
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
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("preferredLang", this.getPreferredLang());
		result.put("contactType", this.getContactType());
		result.put("personId", this.getPersonId());
		result.put("jobTitle", this.getJobTitle());
		result.put("type", this.getType());
		result.put("address", this.getAddress());
		return result;
	}
}

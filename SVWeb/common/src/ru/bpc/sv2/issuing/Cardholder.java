package ru.bpc.sv2.issuing;

import java.io.Serializable;

import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Cardholder implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long personId;
	private Integer seqNum;
	private String cardholderNumber;
	private String cardholderName;
	private String relation;
	private Boolean resident;
	private String nationality;
	private String maritalStatus;
	private Integer instId;
	private String instName;
	private Person person;

	private String statusReason;

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Long getPersonId() {
		return personId;
	}
	public void setPersonId(Long personId) {
		this.personId = personId;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getCardholderNumber() {
		return cardholderNumber;
	}
	public void setCardholderNumber(String cardholderNumber) {
		this.cardholderNumber = cardholderNumber;
	}

	public String getCardholderName() {
		return cardholderName;
	}
	public void setCardholderName(String cardholderName) {
		this.cardholderName = cardholderName;
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

	public String getRelation() {
		return relation;
	}
	public void setRelation(String relation) {
		this.relation = relation;
	}

	public Boolean getResident() {
		return resident;
	}
	public void setResident(Boolean resident) {
		this.resident = resident;
	}

	public String getNationality() {
		return nationality;
	}
	public void setNationality(String nationality) {
		this.nationality = nationality;
	}

	public String getMaritalStatus() {
		return maritalStatus;
	}
	public void setMaritalStatus(String maritalStatus) {
		this.maritalStatus = maritalStatus;
	}

	public Person getPerson() {
		if (person == null)
			person = new Person();
		return person;
	}
	public void setPerson(Person person) {
		this.person = person;
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
	public Cardholder clone() throws CloneNotSupportedException {
		return (Cardholder) super.clone();
	}
}

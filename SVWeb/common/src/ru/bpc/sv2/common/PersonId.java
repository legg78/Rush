package ru.bpc.sv2.common;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PersonId implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long objectId;
	private Integer instId;
	private String entityType;
	private String idType;
	private String idSeries;
	private String idNumber;
	private String idIssuer;
	private Date issueDate;
	private Date expireDate;
	private Integer seqNum;
	private String description;
	private String idCountry;
	private String lang;
	private String idTypeName;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getIdType() {
		return idType;
	}

	public void setIdType(String idType) {
		this.idType = idType;
	}

	public String getIdSeries() {
		return idSeries;
	}

	public void setIdSeries(String idSeries) {
		this.idSeries = idSeries;
	}

	public String getIdNumber() {
		return idNumber;
	}

	public void setIdNumber(String idNumber) {
		this.idNumber = idNumber;
	}

	public String getIdIssuer() {
		return idIssuer;
	}

	public void setIdIssuer(String idIssuer) {
		this.idIssuer = idIssuer;
	}

	public Date getIssueDate() {
		return issueDate;
	}

	public void setIssueDate(Date issueDate) {
		this.issueDate = issueDate;
	}

	public Date getExpireDate() {
		return expireDate;
	}

	public void setExpireDate(Date expireDate) {
		this.expireDate = expireDate;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getIdCountry() {
		return idCountry;
	}

	public void setIdCountry(String idCountry) {
		this.idCountry = idCountry;
	}
	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		PersonId clone = (PersonId) super.clone();
		if (expireDate != null) {
			clone.setExpireDate(new Date(expireDate.getTime()));
		}
		if (issueDate != null) {
			clone.setIssueDate(new Date(issueDate.getTime()));
		}
		
		return clone;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("idType", this.getIdType());
		result.put("idSeries", this.getIdSeries());
		result.put("idNumber", this.getIdNumber());
		result.put("idIssuer", this.getIdIssuer());
		result.put("issueDate", this.getIssueDate());
		result.put("expireDate", this.getExpireDate());
		result.put("lang", this.getLang());
		result.put("description", this.getDescription());
		result.put("instId", this.getInstId());
		result.put("idCountry", this.getIdCountry());
		return result;
	}

	public String getIdTypeName() {
		return idTypeName;
	}

	public void setIdTypeName(String idTypeName) {
		this.idTypeName = idTypeName;
	}

}

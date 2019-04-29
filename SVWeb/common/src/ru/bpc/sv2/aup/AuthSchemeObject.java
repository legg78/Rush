package ru.bpc.sv2.aup;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AuthSchemeObject implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private Integer schemeId;
	private String entityType;
	private Long objectId;
	private Date startDate;
	private Date endDate;
	private String objectName;
	private String schemeName;
	private Boolean active;
	
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Integer getSchemeId() {
		return schemeId;
	}

	public void setSchemeId(Integer schemeId) {
		this.schemeId = schemeId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
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

	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	public String getObjectName() {
		return objectName;
	}

	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}

	public String getSchemeName() {
		return schemeName;
	}

	public void setSchemeName(String schemeName) {
		this.schemeName = schemeName;
	}

	@Override
	public AuthSchemeObject clone() throws CloneNotSupportedException {
		return (AuthSchemeObject) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", this.getId());
		result.put("schemeId", this.getSchemeId());
		result.put("entityType", this.getEntityType());
		result.put("objectId", this.getObjectId());
		result.put("startDate", this.getStartDate());
		result.put("endDate", this.getEndDate());
		
		return result;
	}

	public Boolean getActive() {
		return active;
	}

	public void setActive(Boolean active) {
		this.active = active;
	}

}

package ru.bpc.sv2.fraud;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class FraudObject implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject{

	private static final long serialVersionUID = 1L;
	
	private Long id;
	private String entityType;
	private Long objectId;
	private Date startDate;
	private Date endDate;
	private Integer seqnum;
	private Integer suiteId;
	private String suiteName;
	
	@Override
	public Object getModelId() {
		return getId();
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
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

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Integer getSuiteId() {
		return suiteId;
	}

	public void setSuiteId(Integer suiteId) {
		this.suiteId = suiteId;
	}

	public String getSuiteName() {
		return suiteName;
	}

	public void setSuiteName(String suiteName) {
		this.suiteName = suiteName;
	}

	@Override
	public FraudObject clone() throws CloneNotSupportedException {
		return (FraudObject) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", this.getId());
		result.put("entityType", this.getEntityType());
		result.put("objectId", this.getObjectId());
		result.put("startDate", this.getStartDate());
		result.put("endDate", this.getEndDate());
		
		return result;
	}
}

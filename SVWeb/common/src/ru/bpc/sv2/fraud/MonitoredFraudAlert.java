package ru.bpc.sv2.fraud;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class MonitoredFraudAlert implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Long authId;
	private Integer caseId;
	private String entityType;
	private Long objectId;
	private String resolution;
	private Integer resolutionUserId;
	private Date operDate;
	private BigDecimal operAmount;
	private String operCurrency;
	private String operType;
	private String objectDesc;
	private String caseName;
	private String caseDesc;
	private String resolutionName;
	private String resolutionUser;
	private Integer seqnum;
	
	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public Object getModelId() {
		return getId();
	}

	public Long getAuthId() {
		return authId;
	}

	public void setAuthId(Long authId) {
		this.authId = authId;
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

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Date getOperDate() {
		return operDate;
	}

	public void setOperDate(Date operDate) {
		this.operDate = operDate;
	}

	public BigDecimal getOperAmount() {
		return operAmount;
	}

	public void setOperAmount(BigDecimal operAmount) {
		this.operAmount = operAmount;
	}

	public String getOperCurrency() {
		return operCurrency;
	}

	public void setOperCurrency(String operCurrency) {
		this.operCurrency = operCurrency;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getObjectDesc() {
		return objectDesc;
	}

	public void setObjectDesc(String objectDesc) {
		this.objectDesc = objectDesc;
	}

	public Integer getCaseId() {
		return caseId;
	}

	public void setCaseId(Integer caseId) {
		this.caseId = caseId;
	}

	public String getResolution() {
		return resolution;
	}

	public void setResolution(String resolution) {
		this.resolution = resolution;
	}

	public Integer getResolutionUserId() {
		return resolutionUserId;
	}

	public void setResolutionUserId(Integer resolutionUserId) {
		this.resolutionUserId = resolutionUserId;
	}

	public String getCaseName() {
		return caseName;
	}

	public void setCaseName(String caseName) {
		this.caseName = caseName;
	}

	public String getCaseDesc() {
		return caseDesc;
	}

	public void setCaseDesc(String caseDesc) {
		this.caseDesc = caseDesc;
	}

	public String getResolutionName() {
		return resolutionName;
	}

	public void setResolutionName(String resolutionName) {
		this.resolutionName = resolutionName;
	}

	public String getResolutionUser() {
		return resolutionUser;
	}

	public void setResolutionUser(String resolutionUser) {
		this.resolutionUser = resolutionUser;
	}
	
	@Override
	public Object clone() {
		try {
			return super.clone();
		} catch (CloneNotSupportedException e) {
			return null;
		}
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", this.getId());
		result.put("authId", this.getAuthId());
		result.put("caseId", this.getCaseId());
		result.put("entityType", this.getEntityType());
		result.put("objectId", this.getObjectId());
		result.put("resolution", this.getResolution());
		result.put("resolutionUserId", this.getResolutionUserId());
		result.put("operDate", this.getOperDate());
		result.put("operAmount", this.getOperAmount());
		result.put("operCurrency", this.getOperCurrency());
		result.put("operType", this.getOperType());
		result.put("objectDesc", this.getObjectDesc());
		result.put("caseName", this.getCaseName());
		result.put("caseDesc", this.getCaseDesc());
		result.put("resolutionName", this.getResolutionName());
		result.put("resolutionUser", this.getResolutionUser());
		result.put("seqnum", this.getSeqnum());
		return result;
	}
}
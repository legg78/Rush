package ru.bpc.sv2.fcl.limits;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class Limit implements IAuditableObject, ModelIdentifiable, Serializable, Cloneable {
	private static final long serialVersionUID = 323402049380004460L;

	private Long id;
	private Integer seqnum;
	private String limitType;
	private Integer cycleId;
	private Long countLimit;
	private Long countBound;
	private BigDecimal sumLimit;
	private BigDecimal sumBound;
	private Integer instId;
	private String instName;
	private String entityType;
	private String cycleType;
	private String cycleLength;
	private String lengthType;
	private String truncType;
	private String currency;
	private String boundCurrency;
	private String postMethod;
	private String description;
	private String counterAlgorithm;
	private String checkType;
	private Boolean isCustom;
	private String limitBase;
	private BigDecimal limitRate;
	private Date startDate;
	private Date endDate;
	private Long modifierId;
	private String modifierName;
	private String modifierCondition;
	private String statusReason;

	public Limit() {}

	public Long getId() {
		return id;
	}
	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}
	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public String getLimitType() {
		return limitType;
	}
	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public Integer getCycleId() {
		return cycleId;
	}
	public void setCycleId(Integer cycleId) {
		this.cycleId = cycleId;
	}

	public Long getCountLimit() {
		return countLimit;
	}
	public void setCountLimit(Long countLimit) {
		this.countLimit = countLimit;
	}

	public Long getCountBound() {
		return countBound;
	}
	public void setCountBound(Long countBound) {
		this.countBound = countBound;
	}

	public BigDecimal getSumLimit() {
		return sumLimit;
	}
	public void setSumLimit(BigDecimal sumLimit) {
		this.sumLimit = sumLimit;
	}

	public BigDecimal getSumBound() {
		return sumBound;
	}
	public void setSumBound(BigDecimal sumBound) {
		this.sumBound = sumBound;
	}

	public Integer getInstId() {
		return instId;
	}
	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getCycleType() {
		return cycleType;
	}
	public void setCycleType(String cycleType) {
		this.cycleType = cycleType;
	}

	public String getCycleLength() {
		return cycleLength;
	}
	public void setCycleLength(String cycleLength) {
		this.cycleLength = cycleLength;
	}

	public String getLengthType() {
		return lengthType;
	}
	public void setLengthType(String lengthType) {
		this.lengthType = lengthType;
	}

	public String getTruncType() {
		return truncType;
	}
	public void setTruncType(String truncType) {
		this.truncType = truncType;
	}

	public String getCurrency() {
		return currency;
	}
	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public String getBoundCurrency() {
		return boundCurrency;
	}
	public void setBoundCurrency(String boundCurrency) {
		this.boundCurrency = boundCurrency;
	}

	public String getPostMethod() {
		return postMethod;
	}
	public void setPostMethod(String postMethod) {
		this.postMethod = postMethod;
	}

	public String getInstName() {
		return instName;
	}
	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public Boolean getIsCustom() {
		return isCustom;
	}
	public void setIsCustom(Boolean isCustom) {
		this.isCustom = isCustom;
	}

	public String getLimitBase() {
		return limitBase;
	}
	public void setLimitBase(String limitBase) {
		this.limitBase = limitBase;
	}

	public BigDecimal getLimitRate() {
		return limitRate;
	}
	public void setLimitRate(BigDecimal limitRate) {
		this.limitRate = limitRate;
	}

	public String getCheckType() {
		return checkType;
	}
	public void setCheckType(String checkType) {
		this.checkType = checkType;
	}

	public String getCounterAlgorithm() {
		return counterAlgorithm;
	}
	public void setCounterAlgorithm(String counterAlgorithm) {
		this.counterAlgorithm = counterAlgorithm;
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

	public Long getModifierId() {
		return modifierId;
	}
	public void setModifierId(Long modifierId) {
		this.modifierId = modifierId;
	}

	public String getModifierName() {
		return modifierName;
	}
	public void setModifierName(String modifierName) {
		this.modifierName = modifierName;
	}

	public String getModifierCondition() {
		return modifierCondition;
	}
	public void setModifierCondition(String modifierCondition) {
		this.modifierCondition = modifierCondition;
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
		result.put("id", getId());
		result.put("cycleId", getCycleId());
		result.put("countLimit", getCountLimit());
		result.put("countBound", getCountBound());
		result.put("sumLimit", getSumLimit());
		result.put("sumBound", getSumBound());
		result.put("currency", getCurrency());
		result.put("postMethod", getPostMethod());
		result.put("instId", getInstId());
		result.put("isCustom", getIsCustom());
		result.put("limitBase", getLimitBase());
		result.put("limitRate", getLimitRate());
		result.put("limitType", getLimitType());
		result.put("checkType", getCheckType());
		return result;
	}
}
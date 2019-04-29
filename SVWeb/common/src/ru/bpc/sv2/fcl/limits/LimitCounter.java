package ru.bpc.sv2.fcl.limits;

import java.io.Serializable;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class LimitCounter implements Serializable, ModelIdentifiable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private String entityType;
	private Long objectId;
	private String limitType;
	private Long countValue;
	private Double sumValue;
	private Long prevCountValue;
	private Double prevSumValue;
	private Date lastResetDate;
	private Integer splitHash;
	private Integer instId;
	private Double sumLimit;
	private String currency;
	private Long countLimit;
	private Date startDate;
	private Date endDate;
	private Long attrId;
	
	// from cycle counter
	private Date nextDate;
	private String cycleType;
	
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

	public String getLimitType() {
		return limitType;
	}

	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public Long getCountValue() {
		return countValue;
	}

	public void setCountValue(Long countValue) {
		this.countValue = countValue;
	}

	public Double getSumValue() {
		return sumValue;
	}

	public void setSumValue(Double sumValue) {
		this.sumValue = sumValue;
	}

	public Long getPrevCountValue() {
		return prevCountValue;
	}

	public void setPrevCountValue(Long prevCountValue) {
		this.prevCountValue = prevCountValue;
	}

	public Double getPrevSumValue() {
		return prevSumValue;
	}

	public void setPrevSumValue(Double prevSumValue) {
		this.prevSumValue = prevSumValue;
	}

	public Date getLastResetDate() {
		return lastResetDate;
	}

	public void setLastResetDate(Date lastResetDate) {
		this.lastResetDate = lastResetDate;
	}

	public Integer getSplitHash() {
		return splitHash;
	}

	public void setSplitHash(Integer splitHash) {
		this.splitHash = splitHash;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Date getNextDate() {
		return nextDate;
	}

	public void setNextDate(Date nextDate) {
		this.nextDate = nextDate;
	}

	public String getCycleType() {
		return cycleType;
	}

	public void setCycleType(String cycleType) {
		this.cycleType = cycleType;
	}

	public Double getSumLimit() {
		return sumLimit;
	}

	public void setSumLimit(Double sumLimit) {
		this.sumLimit = sumLimit;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public Long getCountLimit() {
		return countLimit;
	}

	public void setCountLimit(Long countLimit) {
		this.countLimit = countLimit;
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

	public Long getAttrId() {
		return attrId;
	}

	public void setAttrId(Long attrId) {
		this.attrId = attrId;
	}

}

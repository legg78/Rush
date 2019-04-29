package ru.bpc.sv2.fcl.limits;

import java.util.Date;

public class ObjectLimits {
	private String entityType;
	private Long objectId;
	private String limitType;
	private String limitName;
	private String limitCurrency;
	private Long countValue;
	private Long sumValue;
	private Long sumLimit;
	private Long countLimit;
	private Date lastResetDate;
	private Date nextDate;
	
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

	public String getLimitName() {
		return limitName;
	}

	public void setLimitName(String limitName) {
		this.limitName = limitName;
	}

	public String getLimitType() {
		return limitType;
	}

	public void setLimitType(String limitType) {
		this.limitType = limitType;
	}

	public String getLimitCurrency() {
		return limitCurrency;
	}

	public void setLimitCurrency(String limitCurrency) {
		this.limitCurrency = limitCurrency;
	}

	public Long getCountValue() {
		return countValue;
	}

	public void setCountValue(Long countValue) {
		this.countValue = countValue;
	}

	public Long getSumValue() {
		return sumValue;
	}

	public void setSumValue(Long sumValue) {
		this.sumValue = sumValue;
	}

	public Long getSumLimit() {
		return sumLimit;
	}

	public void setSumLimit(Long sumLimit) {
		this.sumLimit = sumLimit;
	}

	public Long getCountLimit() {
		return countLimit;
	}

	public void setCountLimit(Long countLimit) {
		this.countLimit = countLimit;
	}

	public Date getNextDate() {
		return nextDate;
	}

	public void setNextDate(Date nextDate) {
		this.nextDate = nextDate;
	}

	public Date getLastResetDate() {
		return lastResetDate;
	}

	public void setLastResetDate(Date lastResetDate) {
		this.lastResetDate = lastResetDate;
	}

}

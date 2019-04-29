package ru.bpc.sv2.fraud;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class FraudAlert implements Serializable, ModelIdentifiable {

	private static final long serialVersionUID = 1L;

	private Long id;
	private Long authId;
	private String entityType;
	private Long objectId;
	private Integer checkId;
	private Date operDate;
	private BigDecimal operAmount;
	private String operCurrency;
	private String operType;
	private String objectDesc;
	private String checkName;
	private String checkDesc;
	
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

	public Integer getCheckId() {
		return checkId;
	}

	public void setCheckId(Integer checkId) {
		this.checkId = checkId;
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

	public String getCheckName() {
		return checkName;
	}

	public void setCheckName(String checkName) {
		this.checkName = checkName;
	}

	public String getCheckDesc() {
		return checkDesc;
	}

	public void setCheckDesc(String checkDesc) {
		this.checkDesc = checkDesc;
	}

}

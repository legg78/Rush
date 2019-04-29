package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for PMO Templates.
 */
public class PmoTemplate implements ModelIdentifiable, IAuditableObject, Serializable, Cloneable {
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 549943522920261631L;
	
	public static final int ADD_SCHEDULE = 1;
	public static final int EDIT_SCHEDULE = 0;
	public static final int DELETE_SCHEDULE = -1;
	
	private Long id;
	private Long customerId;
	private String label;
	private String description;
	private Integer purposeId;
	private String providerName;
	private String serviceName;
	private Integer instId;
	private String status;
	private String instName;
	private String lang;
	private Boolean isPreparedOrder;
	private String currency;
	private BigDecimal amount;
	private String customerNumber;
	private String entityType;
	private Long objectId;
	private String objectNumber;
	
	private PmoSchedule schedule;
	private int scheduleAction;
	
	public PmoTemplate() {
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Object getModelId() {
		if(schedule != null && schedule.getId() != null){
			return getId().toString() + "|" + schedule.getId().toString();
		}
		return getId().toString();
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		PmoTemplate clone = (PmoTemplate) super.clone();
		if (schedule != null) {
			clone.setSchedule((PmoSchedule) schedule.clone());
		}
		return clone;
	}

	public Long getCustomerId() {
		return customerId;
	}

	public void setCustomerId(Long customerId) {
		this.customerId = customerId;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Integer getPurposeId() {
		return purposeId;
	}

	public void setPurposeId(Integer purposeId) {
		this.purposeId = purposeId;
	}

	public String getProviderName() {
		return providerName;
	}

	public void setProviderName(String providerName) {
		this.providerName = providerName;
	}

	public String getServiceName() {
		return serviceName;
	}

	public void setServiceName(String serviceName) {
		this.serviceName = serviceName;
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

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getStatus() {
		return status;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public Boolean getIsPreparedOrder() {
		return isPreparedOrder;
	}

	public void setIsPreparedOrder(Boolean isPreparedOrder) {
		this.isPreparedOrder = isPreparedOrder;
	}

	public PmoSchedule getSchedule() {
		return schedule;
	}

	public void setSchedule(PmoSchedule schedule) {
		this.schedule = schedule;
	}

	public int getScheduleAction() {
		return scheduleAction;
	}

	public void setScheduleAction(int scheduleAction) {
		this.scheduleAction = scheduleAction;
	}
	
	public boolean isAddSchedule() {
		return ADD_SCHEDULE == scheduleAction;
	}

	public boolean isEditSchedule() {
		return EDIT_SCHEDULE == scheduleAction;
	}

	public boolean isDeleteSchedule() {
		return DELETE_SCHEDULE == scheduleAction;
	}

	public String getCurrency() {
		return currency;
	}

	public void setCurrency(String currency) {
		this.currency = currency;
	}

	public BigDecimal getAmount() {
		return amount;
	}

	public void setAmount(BigDecimal amount) {
		this.amount = amount;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("customerId", getCustomerId());
		result.put("purposeId", getPurposeId());
		result.put("status", getStatus());
		result.put("instId", getInstId());
		result.put("isPreparedOrder", getIsPreparedOrder());
		result.put("label", getLabel());
		result.put("description", getDescription());
		result.put("lang", getLang());
		result.put("currency", getCurrency());
		result.put("amount", getAmount());
		result.put("customerNumber", getCustomerNumber());
		result.put("entityType", getEntityType());
		result.put("objectId", getObjectId());
		result.put("objectNumber", getObjectNumber());
		
		result.put("schedule.id", (getSchedule()!=null)?getSchedule().getId():null);
		result.put("schedule.orderId", (getSchedule()!=null)?getSchedule().getOrderId():null);
		result.put("schedule.eventType", (getSchedule()!=null)?getSchedule().getEventType():null);
		result.put("schedule.entityType", (getSchedule()!=null)?getSchedule().getEntityType():null);
		result.put("schedule.objectId", (getSchedule()!=null)?getSchedule().getObjectId():null);
		result.put("schedule.attemptLimit", (getSchedule()!=null)?getSchedule().getAttemptLimit():null);
		result.put("schedule.amountAlgorithm", (getSchedule()!=null)?getSchedule().getAmountAlgorithm():null);
		result.put("schedule.cycleId", (getSchedule()!=null)?getSchedule().getCycleId():null);
		
		return result;
	}

	public String getCustomerNumber() {
		return customerNumber;
	}

	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
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

	public String getObjectNumber() {
		return objectNumber;
	}

	public void setObjectNumber(String objectNumber) {
		this.objectNumber = objectNumber;
	}
}
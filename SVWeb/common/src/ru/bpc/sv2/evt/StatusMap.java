package ru.bpc.sv2.evt;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class StatusMap implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String eventType;
	private String eventTypeText;
	private String initiator;
	private String initiatorText;
	private String initialStatus;
	private String initialStatusText;
	private String resultStatus;
	private String resultStatusText;
	private Integer priority;
	private Integer instId;
	private String instName;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public String getEventTypeText() {
		return eventTypeText;
	}

	public void setEventTypeText(String eventTypeText) {
		this.eventTypeText = eventTypeText;
	}

	public String getInitiator() {
		return initiator;
	}

	public void setInitiator(String initiator) {
		this.initiator = initiator;
	}

	public String getInitiatorText() {
		return initiatorText;
	}

	public void setInitiatorText(String initiatorText) {
		this.initiatorText = initiatorText;
	}

	public String getInitialStatus() {
		return initialStatus;
	}

	public void setInitialStatus(String initialStatus) {
		this.initialStatus = initialStatus;
	}

	public String getInitialStatusText() {
		return initialStatusText;
	}

	public void setInitialStatusText(String initialStatusText) {
		this.initialStatusText = initialStatusText;
	}

	public String getResultStatus() {
		return resultStatus;
	}

	public void setResultStatus(String resultStatus) {
		this.resultStatus = resultStatus;
	}

	public String getResultStatusText() {
		return resultStatusText;
	}

	public void setResultStatusText(String resultStatusText) {
		this.resultStatusText = resultStatusText;
	}

	public Object getModelId() {
		return getId();
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
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

	@Override
	public StatusMap clone() throws CloneNotSupportedException {
		return (StatusMap) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("eventType", this.getEventType());
		result.put("initiator", this.getInitiator());
		result.put("initialStatus", this.getInitialStatus());
		result.put("resultStatus", this.getResultStatus());
		
		return result;
	}

}

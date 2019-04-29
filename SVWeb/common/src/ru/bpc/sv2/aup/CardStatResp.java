package ru.bpc.sv2.aup;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CardStatResp implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = -606706547906229906L;

	private Integer id;
	private Integer seqnum;
	private String instId;
	private String operType;
	private String cardState;
	private String cardStatus;
	private String pinPresence;
	private String respCode;
	private Integer priority;
	
	private String msgType;
	private String participantType;
	
	private String instName;
	
	public Object getModelId() {
		return id;
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getSeqnum() {
		return seqnum;
	}

	public void setSeqnum(Integer seqnum) {
		this.seqnum = seqnum;
	}

	public String getInstId() {
		return instId;
	}

	public void setInstId(String instId) {
		this.instId = instId;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getCardState() {
		return cardState;
	}

	public void setCardState(String cardState) {
		this.cardState = cardState;
	}

	public String getCardStatus() {
		return cardStatus;
	}

	public void setCardStatus(String cardStatus) {
		this.cardStatus = cardStatus;
	}

	public String getPinPresence() {
		return pinPresence;
	}

	public void setPinPresence(String pinPresence) {
		this.pinPresence = pinPresence;
	}

	public String getRespCode() {
		return respCode;
	}

	public void setRespCode(String respCode) {
		this.respCode = respCode;
	}

	public Integer getPriority() {
		return priority;
	}

	public void setPriority(Integer priority) {
		this.priority = priority;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String institutionName) {
		this.instName = institutionName;
	}

	public String getMsgType() {
		return msgType;
	}

	public void setMsgType(String msgType) {
		this.msgType = msgType;
	}

	public String getParticipantType() {
		return participantType;
	}

	public void setParticipantType(String participantType) {
		this.participantType = participantType;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("instId", this.getInstId());
		result.put("operType", this.getOperType());
		result.put("cardState", this.getCardState());
		result.put("cardStatus", this.getCardStatus());
		result.put("pinPresence", this.getPinPresence());
		result.put("respCode", this.getRespCode());
		result.put("priority", this.getPriority());
		result.put("msgType", this.getMsgType());
		result.put("participantType", this.getParticipantType());
		
		return result;
	}
	
	
}
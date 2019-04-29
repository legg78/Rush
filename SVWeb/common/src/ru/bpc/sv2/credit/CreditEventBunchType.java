package ru.bpc.sv2.credit;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CreditEventBunchType implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = -4784144976305669217L;

	private Integer id;
	private Integer seqnum;
	private String eventType;
	private String balanceType;
	private Integer bunchTypeId;
	private String bunchTypeName;
	private Integer addBunchTypeId;
	private String addBunchTypeName;
	private Integer instId;
	private String instName;

	public Object getModelId() {
		return getId();
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

	public String getEventType() {
		return eventType;
	}
	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public String getBalanceType() {
		return balanceType;
	}
	public void setBalanceType(String balanceType) {
		this.balanceType = balanceType;
	}

	public Integer getBunchTypeId() {
		return bunchTypeId;
	}
	public void setBunchTypeId(Integer bunchTypeId) {
		this.bunchTypeId = bunchTypeId;
	}

	public String getBunchTypeName() {
		return bunchTypeName;
	}
	public void setBunchTypeName(String bunchTypeName) {
		this.bunchTypeName = bunchTypeName;
	}

	public Integer getAddBunchTypeId() {
		return addBunchTypeId;
	}
	public void setAddBunchTypeId(Integer addBunchTypeId) {
		this.addBunchTypeId = addBunchTypeId;
	}

	public String getAddBunchTypeName() {
		return addBunchTypeName;
	}
	public void setAddBunchTypeName(String addBunchTypeName) {
		this.addBunchTypeName = addBunchTypeName;
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
	public Object clone(){
		try {
			return super.clone();
		} catch (CloneNotSupportedException ex) {
			return null;
		}
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("eventType", this.getEventType());
		result.put("balanceType", this.getBalanceType());
		result.put("bunchTypeId", this.getBunchTypeId());
		result.put("instId", this.getInstId());
		
		return result;
	}
}

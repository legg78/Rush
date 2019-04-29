package ru.bpc.sv2.operations;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class ParticipantType implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private String operType;
	private String participantType;
	
	public Object getModelId() {
		return getId();
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	public String getOperType(){
		return this.operType;
	}
	
	public void setOperType(String operType){
		this.operType = operType;
	}
	
	public String getParticipantType(){
		return this.participantType;
	}
	
	public void setParticipantType(String participantType){
		this.participantType = participantType;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("operType", getOperType());
		result.put("participantType", getParticipantType());
		return result;
	}
}
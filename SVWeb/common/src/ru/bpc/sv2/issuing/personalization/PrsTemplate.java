package ru.bpc.sv2.issuing.personalization;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class PrsTemplate implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer methodId;
	private String methodName;
	private String entityType;	
	private Integer formatId;
	private String formatName;
	private String modId;
	
	public String getModId() {
		return modId;
	}

	public void setModId(String modId) {
		this.modId = modId;
	}
	public Object getModelId() {
		return getId();
	}
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
	public Integer getMethodId() {
		return methodId;
	}
	public void setMethodId(Integer methodId) {
		this.methodId = methodId;
	}
	public String getMethodName() {
		return methodName;
	}
	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}
	public String getEntityType() {
		return entityType;
	}
	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}
	public Integer getFormatId() {
		return formatId;
	}
	public void setFormatId(Integer formatId) {
		this.formatId = formatId;
	}
	public String getFormatName() {
		return formatName;
	}
	public void setFormatName(String formatName) {
		this.formatName = formatName;
	}
	@Override
	public PrsTemplate clone() throws CloneNotSupportedException {
		return (PrsTemplate) super.clone();
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("methodId", getMethodId());
		result.put("entityType", getEntityType());
		result.put("formatId", getFormatId());
		return result;
	}
}

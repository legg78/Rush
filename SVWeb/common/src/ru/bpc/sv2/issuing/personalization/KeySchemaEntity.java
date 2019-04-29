package ru.bpc.sv2.issuing.personalization;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class KeySchemaEntity implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private String keyType;
	private String entityType;
	private Integer keySchemaId;
	
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
	public String getKeyType() {
		return keyType;
	}

	public void setKeyType(String keyType) {
		this.keyType = keyType;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Integer getKeySchemaId() {
		return keySchemaId;
	}

	public void setKeySchemaId(Integer keySchemaId) {
		this.keySchemaId = keySchemaId;
	}

	@Override
	public KeySchemaEntity clone() throws CloneNotSupportedException {
		return (KeySchemaEntity) super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("keySchemaId", getKeySchemaId());
		result.put("keyType", getKeyType());
		result.put("entityType", getEntityType());
		return result;
	}
}

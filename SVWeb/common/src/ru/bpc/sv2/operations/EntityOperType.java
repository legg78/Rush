package ru.bpc.sv2.operations;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class EntityOperType implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer seqNum;
	private Integer instId;
	private String entityType;
	private String operType;
	private String invokeMethod;
	private Integer reasonLovId;
	private String instName;
	private String reasonLovName;
	private Long wizardId;
	private String wizardName;
	private String name;
	private String lang;
	private String objectType;
	private String entityObjectType;

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

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getOperType() {
		return operType;
	}

	public void setOperType(String operType) {
		this.operType = operType;
	}

	public String getInvokeMethod() {
		return invokeMethod;
	}

	public void setInvokeMethod(String invokeMethod) {
		this.invokeMethod = invokeMethod;
	}

	public Integer getReasonLovId() {
		return reasonLovId;
	}

	public void setReasonLovId(Integer reasonLovId) {
		this.reasonLovId = reasonLovId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getReasonLovName() {
		return reasonLovName;
	}

	public void setReasonLovName(String reasonLovName) {
		this.reasonLovName = reasonLovName;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("instId", getInstId());
		result.put("entityType", getEntityType());
		result.put("operType", getOperType());
		result.put("invokeMethod", getInvokeMethod());
		result.put("reasonLovId", getReasonLovId());
		return result;
	}

	public Long getWizardId() {
		return wizardId;
	}

	public void setWizardId(Long wizardId) {
		this.wizardId = wizardId;
	}
	
	public String getWizardName() {
		return wizardName;
	}
	
	public void setWizardName(String wizardName) {
		this.wizardName = wizardName;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public String getEntityObjectType() {
		return entityObjectType;
	}

	public void setEntityObjectType(String entityObjectType) {
		this.entityObjectType = entityObjectType;
	}
}

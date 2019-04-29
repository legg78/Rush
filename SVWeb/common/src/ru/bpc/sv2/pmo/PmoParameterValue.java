package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for List PMO purpose parameters tab.
 */
public class PmoParameterValue extends Parameter implements IAuditableObject, ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 9160260928538889903L;
	
	private Long id;
	private Integer purposeId;
	private Integer purpParamId;
	private String entityType;
	private String object;
	private Long objectId;
	private String paramValue;
	
	public PmoParameterValue()
	{
	}
	
	public PmoParameterValue(String name, String dataType, Object value) {
		setDataType(dataType);
		if (isChar()) {
			setValueV((String)value);
		} else if (isNumber()) {
			setValueN((BigDecimal)value);
		} else if (isDate()) {
			setValueD((Date)value);
		}
	}

	public Object getModelId() {
		return getId(); 
	}
	
	@Override
	public PmoParameterValue clone() throws CloneNotSupportedException {
		return (PmoParameterValue)super.clone();
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getObject() {
		return object;
	}

	public void setObject(String object) {
		this.object = object;
	}

	public String getParamValue() {
		return paramValue;
	}

	public void setParamValue(String paramValue) {
		this.paramValue = paramValue;
	}

	@Override
	public void setLovId(Integer lovId) {
		super.setLovId(lovId);
	}

	public Integer getPurpParamId() {
		return purpParamId;
	}

	public void setPurpParamId(Integer purpParamId) {
		this.purpParamId = purpParamId;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Integer getPurposeId() {
		return purposeId;
	}

	public void setPurposeId(Integer purposeId) {
		this.purposeId = purposeId;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("purpParamId", getPurpParamId());
		result.put("purposeId", getPurposeId());
		result.put("entityType", getEntityType());
		result.put("objectId", getObjectId());
		result.put("dataType", getDataType());
		result.put("valueV", getValueV());
		result.put("valueN", getValueN());
		result.put("valueD", getValueD());
		
		return result;
	}
	
}
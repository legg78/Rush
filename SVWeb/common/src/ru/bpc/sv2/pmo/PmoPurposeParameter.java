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
public class PmoPurposeParameter extends Parameter implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject
{
	/**
	 * 
	 */
	private static final long serialVersionUID = 9160260928538889903L;
	
	private Integer id;
	private Integer purposeId;
	private Integer paramId;
	private String orderStage;
	private Boolean fixed;
	private Boolean editable;
	private String defaultValue;
	private String paramFunction;
	
	public PmoPurposeParameter()
	{
	}
	
	public PmoPurposeParameter(String name, String dataType, Object value) {
		setDataType(dataType);
		if (isChar()) {
			setValueV((String) value);
		} else if (isNumber()) {
			setValueN((BigDecimal) value);
		} else if (isDate()) {
			setValueD((Date) value);
		}
	}

	public Object getModelId() {
		return getId(); 
	}
	
	@Override
	public PmoPurposeParameter clone() throws CloneNotSupportedException {
		return (PmoPurposeParameter)super.clone();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getOrderStage() {
		return orderStage;
	}

	public void setOrderStage(String orderStage) {
		this.orderStage = orderStage;
	}

	public Boolean getFixed() {
		return fixed;
	}

	public void setFixed(Boolean fixed) {
		this.fixed = fixed;
	}

	public Boolean getEditable() {
		return editable;
	}

	public void setEditable(Boolean editable) {
		this.editable = editable;
	}

	public Integer getPurposeId() {
		return purposeId;
	}

	public void setPurposeId(Integer purposeId) {
		this.purposeId = purposeId;
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public String getParamFunction() {
		return paramFunction;
	}

	public void setParamFunction(String paramFunction) {
		this.paramFunction = paramFunction;
	}

	@Override
	public void setLovId(Integer lovId) {
		super.setLovId(lovId);
		if (lovId == null) {
			setValue(null);
			setValueV(null);
			setValueN((BigDecimal)null);
			setValueD(null);
			setLovValue(null);
		}
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("paramId", getParamId());
		result.put("purposeId", getPurposeId());
		result.put("orderStage", getOrderStage());
		result.put("displayOrder", getDisplayOrder());
		result.put("mandatory", getMandatory());
		result.put("fixed", getFixed());
		result.put("editable", getEditable());
		result.put("dataType", getDataType());
		result.put("valueV", getValueV());
		result.put("valueN", getValueN());
		result.put("valueD", getValueD());
		result.put("paramFunction", getParamFunction());
		return result;
	}

}
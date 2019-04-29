package ru.bpc.sv2.acm;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class AcmActionValue implements Serializable, ModelIdentifiable, IAuditableObject, Cloneable {

	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer actionId;
	private Integer paramId;
	private String systemName;
	private String dataType;
	private String label;
	private Integer lovId;
	private String paramFunction;
	private Object paramValue;
	private String lang;
	private String valueV;	// varchar value
	private BigDecimal valueN;	// number value
	private Date valueD;	// date value
	private String paramName;
	private String paramSystemName;
	private String lovName;
	
	public Object getModelId() {
		return actionId + "_" + paramId; 
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getActionId() {
		return actionId;
	}

	public void setActionId(Integer actionId) {
		this.actionId = actionId;
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public String getSystemName() {
		return systemName;
	}

	public void setSystemName(String systemName) {
		this.systemName = systemName;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public Integer getLovId() {
		return lovId;
	}

	public void setLovId(Integer lovId) {
		this.lovId = lovId;
	}

	public String getParamFunction() {
		return paramFunction;
	}

	public void setParamFunction(String paramFunction) {
		this.paramFunction = paramFunction;
	}

	public Object getParamValue() {
		return paramValue;
	}

	public void setParamValue(Object paramValue) {
		this.paramValue = paramValue;
	}

	public String getValueV() {
		return valueV;
	}

	public void setValueV(String valueV) {
		this.valueV = valueV;
	}

	public BigDecimal getValueN() {
		return valueN;
	}

	public void setValueN(BigDecimal valueN) {
		this.valueN = valueN;
	}

	public Date getValueD() {
		return valueD;
	}

	public void setValueD(Date valueD) {
		this.valueD = valueD;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public String getParamName() {
		return paramName;
	}

	public void setParamName(String paramName) {
		this.paramName = paramName;
	}

	public String getLovName() {
		return lovName;
	}

	public void setLovName(String lovName) {
		this.lovName = lovName;
	}

	public String getParamSystemName() {
		return paramSystemName;
	}

	public void setParamSystemName(String paramSystemName) {
		this.paramSystemName = paramSystemName;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		AcmActionValue value = (AcmActionValue) super.clone();
		if (valueD != null) {
			value.setValueD(new Date(valueD.getTime()));
		}
		
		return value;
	}

	public boolean isDateValue() {
		if (dataType != null) {
			return DataTypes.DATE.equals(dataType);
		}
		return false;
	}

	public boolean isCharValue() {
		if (dataType != null) {
			return DataTypes.CHAR.equals(dataType);
		}
		return true;
	}

	public boolean isNumberValue() {
		if (dataType != null) {
			return DataTypes.NUMBER.equals(dataType);
		}
		return false;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("valueV", this.getValueV());
		result.put("valueN", this.getValueN());
		result.put("valueD", this.getValueD());
		result.put("paramFunction", this.getParamFunction());

		return result;
	}
}

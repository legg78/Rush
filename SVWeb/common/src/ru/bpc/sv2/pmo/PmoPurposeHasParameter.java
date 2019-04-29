package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;

/**
 * Model Bean for PMO Purpose param.
 */
public class PmoPurposeHasParameter extends Parameter implements ModelIdentifiable, Serializable, Cloneable
{
	/**
	 * 
	 */
	private static final long	serialVersionUID	= 549943522920261631L;
	
	private Integer id;
	private Integer paramId;
	private String purposeName;
	private String defaultValue;
	private Long objectId;
	
	public PmoPurposeHasParameter()
	{
	}

	public PmoPurposeHasParameter(String name, String dataType, Object value) {
		setDataType(dataType);
		if (isChar()) {
			setValueV((String) value);
		} else if (isNumber()) {
			setValueN((BigDecimal) value);
		} else if (isDate()) {
			setValueD((Date) value);
		}
	}
	
	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Object getModelId() {
		return getId();
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}
	
	public String getPurposeName() {
		return purposeName;
	}

	public void setPurposeName(String purposeName) {
		this.purposeName = purposeName;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public Integer getParamId() {
		return paramId;
	}

	public void setParamId(Integer paramId) {
		this.paramId = paramId;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}
	
}
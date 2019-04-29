package ru.bpc.sv2.cmn;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CmnParameter extends Parameter implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Long standardId;
	private String entityType;
	private String defaultValue;
	private BigDecimal defaultValueN;		// numeric value
	private String defaultValueV;		// varchar value
	private Date defaultValueD;		// date value
	private String defaultLovValue;
	private Integer scaleId;
	private String scaleName;
	private String pattern;
	private String patternDescription;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public Long getStandardId() {
		return standardId;
	}

	public void setStandardId(Long standardId) {
		this.standardId = standardId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getDefaultValue() {
		return defaultValue;
	}

	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		CmnParameter clone = (CmnParameter) super.clone();
		if (defaultValueD != null) {
			clone.setDefaultValueD(new Date(defaultValueD.getTime()));
		}
		return clone;
	}

	public BigDecimal getDefaultValueN() {
		return defaultValueN;
	}

	public void setDefaultValueN(BigDecimal defaultValueN) {
		this.defaultValueN = defaultValueN;
	}

	public String getDefaultValueV() {
		return defaultValueV;
	}

	public void setDefaultValueV(String defaultValueV) {
		this.defaultValueV = defaultValueV;
	}

	public Date getDefaultValueD() {
		return defaultValueD;
	}

	public void setDefaultValueD(Date defaultValueD) {
		this.defaultValueD = defaultValueD;
	}

	public String getDefaultLovValue() {
		return defaultLovValue;
	}

	public void setDefaultLovValue(String defaultLovValue) {
		this.defaultLovValue = defaultLovValue;
	}

	public Integer getScaleId() {
		return scaleId;
	}

	public void setScaleId(Integer scaleId) {
		this.scaleId = scaleId;
	}

	public String getScaleName() {
		return scaleName;
	}

	public void setScaleName(String scaleName) {
		this.scaleName = scaleName;
	}
	
	public String getPattern() {
		return pattern;
	}

	public void setPattern(String pattern) {
		this.pattern = pattern;
	}

	public String getPatternDescription() {
		return patternDescription;
	}

	public void setPatternDescription(String patternDescription) {
		this.patternDescription = patternDescription;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("systemName", this.getSystemName());
		result.put("entityType", this.getEntityType());
		result.put("dataType", this.getDataType());
		result.put("lovId", this.getLovId());
		result.put("defaultValueV", this.getDefaultValueV());
		result.put("defaultValueN", this.getDefaultValueN());
		result.put("defaultValueD", this.getDefaultValueD());
		result.put("scaleId", this.getScaleId());
		result.put("lang", this.getLang());
		result.put("name", this.getName());
		result.put("description", this.getDescription());
		
		return result;
	}
}

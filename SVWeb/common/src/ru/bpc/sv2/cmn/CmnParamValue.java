package ru.bpc.sv2.cmn;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class CmnParamValue extends CmnParameter implements Serializable, ModelIdentifiable, Cloneable{
	private static final long serialVersionUID = 1L;

	private Integer paramId;
	private Long objectId;
	private Integer instId;
	private Object paramValue;
	private BigDecimal paramValueN;		// numeric value
	private String paramValueV;		// varchar value
	private Date paramValueD;		// date value
	private String lovValue;		// lov value got from DB
	private Integer versionId;
	private String paramValueXml;
	private Integer modId;
	private String modName;
	private String defaultXmlValue;
	
	public Object getModelId() {
		return getId() + "_" + paramId + "_" + getStandardId(); // id is not always presented
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

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Object getParamValue() {
		return paramValue;
	}

	public void setParamValue(Object paramValue) {
		this.paramValue = paramValue;
	}

	public BigDecimal getParamValueN() {
		return paramValueN;
	}

	public void setParamValueN(BigDecimal paramValueN) {
		this.paramValueN = paramValueN;
	}

	public String getParamValueV() {
		return paramValueV;
	}

	public void setParamValueV(String paramValueV) {
		this.paramValueV = paramValueV;
	}

	public Date getParamValueD() {
		return paramValueD;
	}

	public void setParamValueD(Date paramValueD) {
		this.paramValueD = paramValueD;
	}

	public String getParamValueXml() {
		return paramValueXml;
	}

	public void setParamValueXml(String paramValueXml) {
		this.paramValueXml = paramValueXml;
	}

	public String getLovValue() {
		return lovValue;
	}

	public void setLovValue(String lovValue) {
		this.lovValue = lovValue;
	}

	public Integer getVersionId() {
		return versionId;
	}

	public void setVersionId(Integer versionId) {
		this.versionId = versionId;
	}

	public Integer getModId() {
		return modId;
	}

	public void setModId(Integer modId) {
		this.modId = modId;
	}

	public String getModName() {
		return modName;
	}

	public void setModName(String modName) {
		this.modName = modName;
	}

	@Override
	public CmnParamValue clone() throws CloneNotSupportedException {
		
		CmnParamValue value = (CmnParamValue) super.clone();
		if (this.getParamValueD() != null) {
			value.setParamValueD(new Date(this.getParamValueD().getTime()));
		}
		
		return value;
	}

	public String getDefaultXmlValue() {
		return defaultXmlValue;
	}

	public void setDefaultXmlValue(String defaultXmlValue) {
		this.defaultXmlValue = defaultXmlValue;
	}
}

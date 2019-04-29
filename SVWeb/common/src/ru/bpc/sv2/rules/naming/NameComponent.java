package ru.bpc.sv2.rules.naming;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.rules.naming.constants.NamingRulesConstants;

public class NameComponent implements Serializable, ModelIdentifiable, Cloneable {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer formatId;
	private Integer componentOrder;
	private String baseValueType;
	private String baseValue;
	private String transformationType;
	private String transformationMask;
	private Integer componentLength;
	private String padType;
	private String padString;
	private String propertiesValues;
	private Boolean check;
	
	public Object getModelId() {
		return getId();
	}

	public Integer getId() {
		return id;
	}
	
	public void setId(Integer id) {
		this.id = id;
	}
	
	public Integer getFormatId() {
		return formatId;
	}
	
	public void setFormatId(Integer formatId) {
		this.formatId = formatId;
	}
	
	public Integer getComponentOrder() {
		return componentOrder;
	}
	
	public void setComponentOrder(Integer componentOrder) {
		this.componentOrder = componentOrder;
	}
	
	public String getBaseValueType() {
		return baseValueType;
	}
	
	public void setBaseValueType(String baseValueType) {
		this.baseValueType = baseValueType;
	}
	
	public String getBaseValue() {
		return baseValue;
	}
	
	public void setBaseValue(String baseValue) {
		this.baseValue = baseValue;
	}
	
	public String getTransformationType() {
		return transformationType;
	}
	
	public void setTransformationType(String transformationType) {
		this.transformationType = transformationType;
	}
	
	public String getTransformationMask() {
		return transformationMask;
	}
	
	public void setTransformationMask(String transformationMask) {
		this.transformationMask = transformationMask;
	}
	
	public Integer getComponentLength() {
		return componentLength;
	}
	
	public void setComponentLength(Integer componentLength) {
		this.componentLength = componentLength;
	}
	
	public String getPadType() {
		return padType;
	}
	
	public void setPadType(String padType) {
		this.padType = padType;
	}
	
	public String getPadString() {
		return padString;
	}
	
	public void setPadString(String padString) {
		this.padString = padString;
	}	
	
	public String getPropertiesValues() {
		return propertiesValues;
	}

	public void setPropertiesValues(String propertiesValues) {
		this.propertiesValues = propertiesValues;
	}
	
	public Boolean getCheck() {
		return check;
	}

	public void setCheck(Boolean check) {
		this.check = check;
	}

	public boolean isConstant() {
		return NamingRulesConstants.BASE_VALUE_TYPE_CONSTANT.equals(baseValueType);
	}
	
	@Override
	public NameComponent clone() throws CloneNotSupportedException{
		return (NameComponent)super.clone();		
	}
}

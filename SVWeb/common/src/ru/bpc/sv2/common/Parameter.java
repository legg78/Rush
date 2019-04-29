package ru.bpc.sv2.common;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.utils.KeyLabelItem;

public class Parameter implements Serializable, ModelIdentifiable, Cloneable {
	private String dataType;
	private String dataFormat;
	private Integer lovId;
	private String lovName;
	private KeyLabelItem[] lov;
	protected String valueV;
	protected BigDecimal valueN;
	protected Date valueD;
	private Object value;
	private String lovValue;
	private String systemName;
	private String name;
	private String description;
	private String lang;
	private Integer displayOrder;
	private Boolean mandatory;
	private Integer seqNum;
	private Boolean editable;
	private Integer dataLength;
	private Boolean editableLov;

	public boolean isDateEnd() {
		return "I_END_DATE".equals(systemName);
	}
	public boolean isLovType() {
		return (getLovId() != null);
	}

	public KeyLabelItem[] getLov() {
		return lov;
	}
	public void setLov(KeyLabelItem[] lov) {
		this.lov = lov;
	}

	public String getDataType() {
		return dataType;
	}
	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getDataFormat() {
		return dataFormat;
	}
	public void setDataFormat(String dataFormat) {
		this.dataFormat = dataFormat;
	}

	public Integer getLovId() {
		return lovId;
	}
	public void setLovId(Integer lovId) {		
		this.lovId = lovId;
	}

	public String getLovName() {
		return lovName;
	}
	public void setLovName(String lovName) {
		this.lovName = lovName;
	}

	public boolean isUnknownType(){
		return dataType == null || !(isChar() || isNumber() || isDate() || isClob());
	}
	public boolean isChar(){
		return DataTypes.CHAR.equals(dataType);
	}
	public boolean isNumber(){
		return DataTypes.NUMBER.equals(dataType);
	}
	public boolean isDate(){
		return DataTypes.DATE.equals(dataType);
	}
	public boolean isClob() {
		return DataTypes.CLOB.equals(dataType);
	}
	public boolean isRaw(){
		return DataTypes.RAW.equals(dataType);
	}

	public Object getValue() {
		return value;
	}
	public void setValue(Object value) {
		this.value = value;
	}

	public String getValueV() {
		return valueV;
	}
	public void setValueV(String valueV) {
		this.valueV = valueV;
		if (isChar()){
			this.value = valueV;
		}
	}

	public BigDecimal getValueN() {
		return valueN;
	}
	public void setValueN(BigDecimal valueN) {
		this.valueN = valueN;
		if (isNumber()){
			this.value = valueN;
		}
	}
	public void setValueN(Integer valueN){
		setValueN(valueN != null ? new BigDecimal(valueN) : null);
	}
	public void setValueN(Long valueN){
		setValueN(valueN != null ? new BigDecimal(valueN) : null);
	}

	public Date getValueD() {
		return valueD;
	}
	public void setValueD(Date valueD) {
		this.valueD = valueD;
		if (isDate()){
			this.value = valueD;
		}
	}

	public String getLovValue() {
		return lovValue;
	}
	public void setLovValue(String lovValue) {
		this.lovValue = lovValue;
	}

	public String getSystemName() {
		return systemName;
	}
	public void setSystemName(String systemName) {
		this.systemName = systemName;
	}

	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}
	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}

	public Integer getDisplayOrder() {
		return displayOrder;
	}
	public void setDisplayOrder(Integer displayOrder) {
		this.displayOrder = displayOrder;
	}

	public Boolean getMandatory() {
		return mandatory;
	}
	public void setMandatory(Boolean mandatory) {
		this.mandatory = mandatory;
	}

	public Integer getSeqNum() {
		return seqNum;
	}
	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Boolean getEditable() {
		return editable;
	}
	public void setEditable(Boolean editable) {
		this.editable = editable;
	}

	public Boolean getEditableLov() {
		return editableLov;
	}
	public void setEditableLov(Boolean editableLov) {
		this.editableLov = editableLov;
	}

	public Integer getDataLength() {
		return dataLength;
	}
	public void setDataLength(Integer dataLength) {
		this.dataLength = dataLength;
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		Parameter clone = (Parameter) super.clone();
		if (lov != null) {
			clone.setLov(new KeyLabelItem[lov.length]);
			for (int i = 0; i < lov.length; i++) {
				clone.getLov()[i] = new KeyLabelItem();
				clone.getLov()[i].setLabel(lov[i].getLabel());
				clone.getLov()[i].setValue(lov[i].getValue());
			}
		}
		if (valueD != null) { 
			clone.setValueD(new Date(valueD.getTime()));
			// suppose that if valueD is set then value should be Date too
			if (value != null) {
				try {
					clone.setValue(new Date(((Date) value).getTime()));
				} catch (ClassCastException ignore) {
				}
			}
		}
		return clone;
	}
	@Override
	public Object getModelId() {
		return getSystemName();
	}
}

package ru.bpc.sv2.conditions;

import java.util.Date;

import ru.bpc.sv2.constants.DataTypes;

public class SqlConditionFormatter {

	private String paramName;
	private String paramDataType;
	private Object value;
	private Double valueN;
	private String valueV;
	private Date valueD;
	private String operation;
	private String condition;
	private boolean prependCondition;
	private String prepend;
	private String parameterPrefix = "";
	private Integer depth;
	
	public String getParamName() {
		return paramName;
	}

	public void setParamName(String paramName) {
		this.paramName = paramName;
	}

	public String getParamDataType() {
		return paramDataType;
	}

	public void setParamDataType(String paramDataType) {
		this.paramDataType = paramDataType;
	}

	public Object getValue() {
		return value;
	}

	public void setValue(Object value) {
		this.value = value;
	}

	public Double getValueN() {
		return valueN;
	}

	public void setValueN(Double valueN) {
		this.valueN = valueN;
		value = valueN;
	}

	public String getValueV() {
		return valueV;
	}

	public void setValueV(String valueV) {
		this.valueV = valueV;
		value = valueV;
	}

	public Date getValueD() {
		return valueD;
	}

	public void setValueD(Date valueD) {
		this.valueD = valueD;
		value = valueD;
	}

	public String getOperation() {
		return operation;
	}

	public void setOperation(String operation) {
		this.operation = operation;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	public boolean isPrependCondition() {
		return prependCondition;
	}

	public void setPrependCondition(boolean prependCondition) {
		this.prependCondition = prependCondition;
	}

	public String getPrepend() {
		return prepend;
	}

	public void setPrepend(String prepend) {
		this.prepend = prepend;
	}

	public String getParameterPrefix() {
		return parameterPrefix;
	}

	public void setParameterPrefix(String parameterPrefix) {
		this.parameterPrefix = parameterPrefix;
	}

	public Integer getDepth() {
		return depth;
	}

	public void setDepth(Integer depth) {
		this.depth = depth;
	}

	public String formCondition(){
		String cond;
//		if (valueParam != null) {
//			value = ":"+valueParam.getName();			
//		} else {		
//			if (paramDataType.equals(DataTypes.CHAR)) {
//				
//			}
//			if (paramDataType.equals(DataTypes.NUMBER)) {
//				value = valueN.toString();
//			}
//			if (paramDataType.equals(DataTypes.DATE)) {
//				String dbDateFormat = "dd.MM.yyyy";
//				SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
//				value = "TO_DATE('"+df.format(valueD)+"', '"+dbDateFormat+"')";
//			}
//		}
		
		// if entered value is empty and value type is not CHAR 
		// then this value is invalid and no condition is added
//		if (!DataTypes.CHAR.equals(paramDataType) && 
		if (value == null || value.toString().trim().length() == 0) {
			return "";
		}

		// add quotes for string values 
		if (DataTypes.CHAR.equals(paramDataType) && 
				!value.toString().startsWith("'")) {
			value = "'" + value.toString();
		}
		if (DataTypes.CHAR.equals(paramDataType) && 
				!value.toString().endsWith("'")) {
			value = value.toString() + "'";
		}

		if (condition.equals("IN")) {
			value = "(" + value + ")";
		}
		if (depth == null) {
			cond = parameterPrefix + paramName + " " + condition + " " + value;
		} else {
			cond = parameterPrefix + paramName + "(" + depth + ")" + " " + condition + " " + value;
		}
		
		if (prependCondition == true) {
			cond = " " + operation + " " + cond;
		}
		
		return cond;
	}
	
	public boolean isVarchar() {
		return DataTypes.CHAR.equals(paramDataType);
	}
	
	public boolean isNumber() {
		return DataTypes.NUMBER.equals(paramDataType);
	}
	
	public boolean isDate() {
		return DataTypes.DATE.equals(paramDataType);
	}
}

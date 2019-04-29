package ru.bpc.sv2.conditions;

public class SqlOrderingFormatter {

	private String paramName;
	private String condition;
	private boolean prependCondition;
	private String prepend;
	private String parameterPrefix;

	public String getParamName() {
		return paramName;
	}

	public void setParamName(String paramName) {
		this.paramName = paramName;
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

	public String formCondition() {
		String cond = "";
		if (parameterPrefix != null) {
			cond = parameterPrefix;
		}
		cond = cond + paramName + " " + condition;
		if (prependCondition == true) {
			cond = ", " + cond;
		}
		return cond;
	}

}

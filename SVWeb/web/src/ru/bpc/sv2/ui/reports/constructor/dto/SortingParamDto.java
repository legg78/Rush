package ru.bpc.sv2.ui.reports.constructor.dto;

import java.io.Serializable;

public final class SortingParamDto implements Serializable {
	private static final long serialVersionUID = -6942930435041473077L;

	private ParameterDto param;
	private boolean ascending;
	private boolean nullsFirst;
	private boolean nullsLast;

	public ParameterDto getParam() {
		return param;
	}

	public void setParam(ParameterDto param) {
		this.param = param;
	}

	public boolean isAscending() {
		return ascending;
	}

	public void setAscending(boolean ascending) {
		this.ascending = ascending;
	}

	public boolean isNullsFirst() {
		return nullsFirst;
	}

	public void setNullsFirst(boolean nullsFirst) {
		this.nullsFirst = nullsFirst;
	}

	public boolean isNullsLast() {
		return nullsLast;
	}

	public void setNullsLast(boolean nullsLast) {
		this.nullsLast = nullsLast;
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + (ascending ? 1231 : 1237);
		result = prime * result + (nullsFirst ? 1231 : 1237);
		result = prime * result + (nullsLast ? 1231 : 1237);
		result = prime * result + ((param == null) ? 0 : param.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		SortingParamDto other = (SortingParamDto) obj;
		if (ascending != other.ascending)
			return false;
		if (nullsFirst != other.nullsFirst)
			return false;
		if (nullsLast != other.nullsLast)
			return false;
		if (param == null) {
			if (other.param != null)
				return false;
		} else if (!param.equals(other.param))
			return false;
		return true;
	}

	@Override
	public String toString() {
		StringBuilder builder = new StringBuilder().append(param).append(' ')
				.append(ascending ? "ASC" : "DESC");
		if (nullsFirst) {
			builder.append(" NULLS FIRST");
		} else if (nullsLast) {
			builder.append(" NULLS LAST");
		}
		return builder.toString();
	}
}

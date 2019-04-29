package ru.bpc.sv2.invocation;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Filter implements Serializable {
	private static final long serialVersionUID = 1L;

	private String element;
	private Object value;
	private List<String> valueList;
	private Operator op;
	private String condition;

	public enum Operator {
		eq, ne, lt, gt, like
	}

	public Filter(String element, Object value) {
		this.element = element;
		this.value = value;
	}
	public Filter(String element, Object value, String condition) {
		this.element = element;
		this.value = value;
		this.condition = condition;
	}
	public Filter(String element, Object value, List<String> valueList) {
		this.element = element;
		this.value = value;
		this.valueList = valueList;
	}
	public Filter() {}

	public String getElement() {
		return element;
	}
	public void setElement(String element) {
		this.element = element;
	}

	public Object getValue() {
		return value;
	}
	public void setValue(Object value) {
		this.value = value;
	}

	public Operator getOp() {
		return op;
	}
	public void setOp(Operator op) {
		this.op = op;
	}

	public List<String> getValueList() {
		return valueList;
	}
	public void setValueList(List<String> valueList) {
		this.valueList = valueList;
	}

	public String getConditionRealValue() {
		return condition;
	}
	public String getCondition() {
		if (condition == null) {
			return "=";
		}
		return condition;
	}
	public void setCondition(String condition) {
		this.condition = condition;
	}

	@Override
	public String toString() {
		return String.format("%s=%s", element, (value != null ? value.toString() : "null") );
	}
	@SuppressWarnings("RedundantIfStatement")
	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;

		Filter filter = (Filter) o;

		if (!element.equals(filter.element)) return false;
		if (op != filter.op) return false;
		if (value != null ? !value.equals(filter.value) : filter.value != null) return false;
		if (valueList != null ? !valueList.equals(filter.valueList) : filter.valueList != null) return false;
		if (condition != null ? !condition.equals(filter.condition) : filter.condition != null) return false;
		return true;
	}
	@Override
	public int hashCode() {
		int result = element.hashCode();
		result = 31 * result + (value != null ? value.hashCode() : 0);
		result = 31 * result + (valueList != null ? valueList.hashCode() : 0);
		result = 31 * result + (op != null ? op.hashCode() : 0);
		result = 31 * result + (condition != null ? condition.hashCode() : 0);
		return result;
	}

	public static Filter create(String name, Object value) {
		return create(name, Operator.eq, value);
	}
	public static Filter create(String name, Operator operator, Object value) {
		return create(name, operator, null, value);
	}
	public static Filter create(String name, String condition, Object value) {
		return create(name, Operator.eq, condition, value);
	}
	public static Filter create(String name, Operator operator, String condition, Object value) {
		Filter filter = new Filter();
		if (name != null && !name.isEmpty()) {
			filter.setElement(name);
			if (operator != null) {
				filter.setOp(operator);
			}
			if (condition != null && !condition.isEmpty()) {
				filter.setCondition(condition);
			}
			if (value instanceof List) {
				filter.setValueList((List<String>)value);
			} else {
				filter.setValue(value);
			}
		}
		return filter;
	}

	public static Filter[] asArray(List<Filter> list) {
		if(list != null) {
			return list.toArray(new Filter[list.size()]);
		}
		return null;
	}
	public static List<Filter> asList(Filter[] array) {
		if(array != null) {
			List<Filter> out = new ArrayList<Filter>(array.length);
			out.addAll(Arrays.asList(array));
			return out;
		}
		return null;
	}

	public static String mask(String raw) {
		return mask(raw, false);
	}
	public static String mask(String raw, boolean caseSensitive) {
		String out = raw;
		if (raw != null) {
			out = raw.trim().replaceAll("[*]", "%").replaceAll("[?]", "_");
			if (!caseSensitive) {
				out = out.toUpperCase();
			}
		}
		return out;
	}
}

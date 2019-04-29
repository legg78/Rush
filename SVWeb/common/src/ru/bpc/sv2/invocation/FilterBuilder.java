package ru.bpc.sv2.invocation;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.constants.DatePatterns;

import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.*;

public final class FilterBuilder {
	public enum FilterMode {
		AS_IS, DATE_TO_STRING, ALL_TO_STRING
	};

	private static ThreadLocal<SimpleDateFormat> filterDateFormat = new ThreadLocal<SimpleDateFormat>() {
		@Override
		protected SimpleDateFormat initialValue() {
			return new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		}
	};
	private static ThreadLocal<SimpleDateFormat> filterTimeFormat = new ThreadLocal<SimpleDateFormat>() {
		@Override
		protected SimpleDateFormat initialValue() {
			return new SimpleDateFormat(DatePatterns.TIME_SECONDS_PATTERN);
		}
	};
	private static ThreadLocal<SimpleDateFormat> filterDateTimeFormat = new ThreadLocal<SimpleDateFormat>() {
		@Override
		protected SimpleDateFormat initialValue() {
			return new SimpleDateFormat(DatePatterns.DATETIME_PATTERN);
		}
	};

	private FilterBuilder() {
	}

	public static Map<String, Object> createMapFromBean(Object bean) {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			PropertyDescriptor[] descriptors = Introspector.getBeanInfo(bean.getClass()).getPropertyDescriptors();
			for (PropertyDescriptor descriptor : descriptors) {
				if (descriptor.getReadMethod() != null) {
					Object value = descriptor.getReadMethod().invoke(bean);
					if (value != null) {
						if (value instanceof String && StringUtils.isNotBlank((String) value)) {
							map.put(descriptor.getName(), Filter.mask((String) value, true));
						} else {
							map.put(descriptor.getName(), value);
						}
					}
				}
			}
			return map;
		} catch (Exception e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	private static Object formatDateTime(Object value) {
		if (value instanceof Timestamp) {
			return filterDateTimeFormat.get().format((Timestamp) value);
		} else if (value instanceof Date) {
			String time = filterTimeFormat.get().format((Date) value);
			if (DatePatterns.DEFAULT_TIME.equals(time) || DatePatterns.DEFAULT_SHORT_TIME.equals(time)) {
				return filterDateFormat.get().format((Date) value);
			} else {
				return filterDateTimeFormat.get().format((Date) value);
			}
		} else {
			return value;
		}
	}

	public static List<Filter> createFiltersFromMap(Map<String, Object> map, FilterMode mode) {
		List<Filter> filters = new ArrayList<Filter>();
		for(Map.Entry<String, Object> entry: map.entrySet()) {
			Object value = entry.getValue();
			Object filterValue;
			if (FilterMode.ALL_TO_STRING.equals(mode)) {
				filterValue = formatDateTime(value).toString();
			} else if (FilterMode.DATE_TO_STRING.equals(mode)) {
				filterValue = formatDateTime(value);
			} else {
				filterValue = value;
			}
			filters.add(Filter.create(entry.getKey(), filterValue));
		}
		return filters;
	}

	public static List<Filter> createFilters(Object bean, FilterMode mode) {
		Map<String, Object> map = createMapFromBean(bean);
		return createFiltersFromMap(map, mode);
	}
	public static List<Filter> createFilters(Object bean) {
		Map<String, Object> map = createMapFromBean(bean);
		return createFiltersFromMap(map, FilterMode.AS_IS);
	}
	public static List<Filter> createFiltersDatesAsString(Object bean) {
		Map<String, Object> map = createMapFromBean(bean);
		return createFiltersFromMap(map, FilterMode.DATE_TO_STRING);
	}
	public static List<Filter> createFiltersAsString(Object bean) {
		Map<String, Object> map = createMapFromBean(bean);
		return createFiltersFromMap(map, FilterMode.ALL_TO_STRING);
	}
}

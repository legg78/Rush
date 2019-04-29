package ru.bpc.sv2.mastercom.api;

import com.mastercard.api.core.model.RequestMap;
import org.apache.log4j.Logger;
import ru.bpc.sv2.mastercom.api.format.MasterComDateFormat;
import ru.bpc.sv2.mastercom.api.format.MasterComFormatter;
import ru.bpc.sv2.mastercom.api.format.MasterComPropertyName;
import ru.bpc.sv2.mastercom.api.format.MasterComValueFormatter;
import ru.bpc.sv2.mastercom.api.types.MasterComRequest;
import ru.bpc.sv2.mastercom.api.types.MasterComResponse;

import java.beans.BeanInfo;
import java.beans.IntrospectionException;
import java.beans.Introspector;
import java.beans.PropertyDescriptor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.ParameterizedType;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

public class MasterComMapper {
	private static final Logger logger = Logger.getLogger("MASTERCOM");

	public static final String DATE_DEFAULT_FORMAT = "yyyy-MM-dd";
	public static final String DATE_NUMBER_FORMAT = "number";


	@SuppressWarnings({"unchecked", "WeakerAccess"})
	public <T extends MasterComRequest> RequestMap formatRequest(T source) {
		try {
			RequestMap result = new RequestMap();
			BeanInfo info = Introspector.getBeanInfo(source.getClass(), Object.class);
			for (PropertyDescriptor pd: info.getPropertyDescriptors()) {
				Method getter = pd.getReadMethod();
				if (!getter.isAccessible()) {
					getter.setAccessible(true);
				}

				Object value = getter.invoke(source);

				Field field = source.getClass().getDeclaredField(pd.getName());
				MasterComFormatter formatterAnnotation = field.getAnnotation(MasterComFormatter.class);
				if (formatterAnnotation != null) {
					MasterComValueFormatter formatter = formatterAnnotation.using().newInstance();
					value = formatter.format(value);
				} else {
					value = formatValue(field, value);
				}

				if (value != null) {
					String propertyName;
					MasterComPropertyName propertyNameAnnotation = field.getAnnotation(MasterComPropertyName.class);
					if (propertyNameAnnotation != null) {
						propertyName = propertyNameAnnotation.value();
					} else {
						propertyName = pd.getName();
					}
					result.put(propertyName, value);
				}
			}
			return result;
		} catch (IntrospectionException | InvocationTargetException | IllegalAccessException | NoSuchFieldException | InstantiationException e) {
			throw new RuntimeException("Error mapping properties for class " + source.getClass().getName(), e);
		}
	}

	@SuppressWarnings("WeakerAccess")
	public <T extends MasterComResponse> T parseResponse(Map<String, Object> response, Class<T> targetClass) {
		try {
			BeanInfo info = Introspector.getBeanInfo(targetClass, Object.class);

			T target = targetClass.newInstance();

			Map<String, PropertyDescriptor> descriptorMap = new HashMap<>();
			for (final PropertyDescriptor pd : info.getPropertyDescriptors()) {
				try {
					Field field = targetClass.getDeclaredField(pd.getName());
					MasterComPropertyName propertyName = field.getAnnotation(MasterComPropertyName.class);
					if (propertyName != null) {
						descriptorMap.put(propertyName.value(), pd);
					} else {
						descriptorMap.put(pd.getName(), pd);
					}
				} catch (NoSuchFieldException e) {
					throw new RuntimeException("Error getting field: " + pd.getName() + " in class " + targetClass.getName(), e);
				}

			}
			for (Map.Entry<String, Object> entry: response.entrySet()) {
				try {
					if (descriptorMap.containsKey(entry.getKey())) {
						PropertyDescriptor pd = descriptorMap.get(entry.getKey());

						Object value = parseProperty(pd, targetClass, pd.getName(), entry.getValue());
						if (value != null) {
							Method setter = pd.getWriteMethod();
							if (!setter.isAccessible()) {
								setter.setAccessible(true);
							}
							setter.invoke(target, value);
						}
					} else {
						logger.info(String.format("Can't find property %s [value = %s] in class %s (response: %s)", entry.getKey(), entry.getValue(), target.getClass().getName(), response.toString()));
					}
				} catch (InvocationTargetException | NoSuchFieldException | ParseException e) {
					throw new RuntimeException("Error parse MasterCom response key: " + entry.getKey() + "[value: " + entry.getValue() + "] in class " + targetClass.getName(), e);
				}
			}
			return target;
		} catch (IntrospectionException | IllegalAccessException | InstantiationException e) {
			throw new RuntimeException("Error parse MasterCom response for class " + targetClass.getName() + " (response: " + response + ")", e);
		}
	}

	private Object parseProperty(PropertyDescriptor pd, Class targetClass, String fieldName, Object value) throws NoSuchFieldException, ParseException, IllegalAccessException, InstantiationException {
		Class propertyType = pd.getPropertyType();
		Field field = targetClass.getDeclaredField(fieldName);
		MasterComFormatter formatAnnotation = field.getAnnotation(MasterComFormatter.class);
		if (formatAnnotation != null) {
			MasterComValueFormatter<?> formatter = formatAnnotation.using().newInstance();
			return formatter.parse(value);
		} else if (List.class.isAssignableFrom(propertyType)) {
			return parseList(field, (List) value);
		} else if (Map.class.isAssignableFrom(propertyType)) {
			return parseMap(field, (Map) value);
		} else {
			return parseValue(field, propertyType, value);
		}
	}


	@SuppressWarnings("unchecked")
	private Object formatValue(Field field, Object value) {
		if (value == null) {
			return null;
		}

		if (value instanceof String) {
			return value;
		} else if (value instanceof Date) {
			MasterComDateFormat annotation = field.getAnnotation(MasterComDateFormat.class);
			String format = annotation == null ? DATE_DEFAULT_FORMAT : annotation.value();
			if (DATE_NUMBER_FORMAT.equals(format)) {
				return ((Date) value).getTime();
			}
			SimpleDateFormat dateFormat = new SimpleDateFormat(format);
			return dateFormat.format(value);
		} else if (value instanceof Boolean) {
			return value;
		} else if (value instanceof Number) {
			return value.toString();
		} else if (value instanceof Enum) {
			return ((Enum) value).name();
		} else if (value instanceof List) {
			List source = (List) value;
			List<Object> result = new ArrayList<>(source.size());
			for (Object o : source) {
				result.add(formatValue(field, o));
			}
			return result;
		} else if(value instanceof Map) {
			Map<?, ?> source = (Map) value;
			Map result = new LinkedHashMap(source.size());
			for (Map.Entry o : source.entrySet()) {
				result.put(o.getKey(), formatValue(field, o.getValue()));
			}
			return result;
		} else if (value instanceof MasterComRequest) {
			return formatRequest((MasterComRequest) value);
		} else {
			throw new RuntimeException("Value " + value.getClass().getName() + " is not supported (" + value.toString() + ")");
		}
	}

	/**
	 *
	 * List and Map don't supported
	 */
	@SuppressWarnings("unchecked")
	private Object parseValue(Field field, Class clazz, Object value) throws ParseException {
		if (clazz == null || value == null) {
			return null;
		}
		if (String.class.isAssignableFrom(clazz)) {
			return value.toString();
		} else if (Date.class.isAssignableFrom(clazz)) {
			MasterComDateFormat annotation = field.getAnnotation(MasterComDateFormat.class);
			return parseDate(value, annotation == null ? null : annotation.value());
		} else if (Boolean.class.isAssignableFrom(clazz)) {
			return parseBoolean(value);
		} else if (BigDecimal.class.isAssignableFrom(clazz)) {
			return parseDecimal(value);
		} else if (Long.class.isAssignableFrom(clazz)) {
			return Long.valueOf(value.toString());
		} else if (Double.class.isAssignableFrom(clazz)) {
			return Double.valueOf(value.toString());
		} else if (Integer.class.isAssignableFrom(clazz)) {
			return Integer.valueOf(value.toString());
		} else if(Enum.class.isAssignableFrom(clazz)) {
			return Enum.valueOf(clazz, value.toString());
		} else if (MasterComResponse.class.isAssignableFrom(clazz)) {
			return parseResponse((Map<String, Object>) value, clazz);
		} else {
			throw new RuntimeException("Type " + clazz.getName() + " is not supported");
		}
	}

	@SuppressWarnings("unchecked")
	private List parseList(Field listField, List list) throws ParseException {
		if (list == null) {
			return null;
		}
		ParameterizedType listType = (ParameterizedType) listField.getGenericType();
		Class<?> listClass = (Class<?>) listType.getActualTypeArguments()[0];

		List result = new ArrayList<>();

		for (Object listValue: list) {
			result.add(parseValue(listField, listClass, listValue));
		}

		return result;
	}

	@SuppressWarnings("unchecked")
	private Map parseMap(Field mapField, Map<?, ?> map) throws ParseException {
		if (map == null) {
			return null;
		}
		ParameterizedType mapType = (ParameterizedType) mapField.getGenericType();
		Class<?> mapClass = (Class<?>) mapType.getActualTypeArguments()[1];

		Map result = new LinkedHashMap();

		for (Map.Entry entry: map.entrySet()) {
			result.put(entry.getKey(), parseValue(mapField, mapClass, entry.getValue()));
		}

		return result;
	}

	private BigDecimal parseDecimal(Object value) {
		if (value == null) {
			return null;
		}

		if (value instanceof BigDecimal) {
			return (BigDecimal) value;
		}

		return new BigDecimal(value.toString());
	}


	private Date parseDate(Object value, String format) throws ParseException {
		if (value == null) {
			return null;
		}
		if (value instanceof Date) {
			return (Date) value;
		}

		if (DATE_NUMBER_FORMAT.equals(format)) {
			return new Date(Long.valueOf(value.toString()));
		}

		SimpleDateFormat dateFormat = new SimpleDateFormat(format == null ? DATE_DEFAULT_FORMAT : format);
		return dateFormat.parse(value.toString());
	}

	private Boolean parseBoolean(Object value) {
		if (value == null) {
			return null;
		}
		if (value instanceof Boolean) {
			return (Boolean) value;
		}

		return Boolean.parseBoolean(value.toString());
	}
}

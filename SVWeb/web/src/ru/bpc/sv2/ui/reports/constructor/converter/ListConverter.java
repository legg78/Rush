package ru.bpc.sv2.ui.reports.constructor.converter;

import java.util.List;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.ConverterException;
import javax.faces.convert.FacesConverter;

@FacesConverter("dynamicReportListConverter")
public class ListConverter implements Converter {
	protected static Object getAttribute(UIComponent component, String attrName, Class<?> expectedType) {
		Object value = component.getAttributes().get(attrName);
		if(null == value) {
			throw new ConverterException("Attribute '"+attrName+"' is null for ["+component+']');
		}
		if(!(expectedType.isInstance(value))) {
			throw new ConverterException("Attribute '"+attrName+"' for ["+component+"] references to object ["+value+"] that is not instance of ["+expectedType+']');
		}
		return value;
	}
	
	protected List<?> getList(UIComponent component) {
		return (List<?>) getAttribute(component, "value", List.class);
	}

	@Override
	public Object getAsObject(FacesContext context,
			UIComponent component, String value) {
		int index = Integer.parseInt(value);
		return getList(component).get(index);	
	}

	@Override
	public String getAsString(FacesContext context,
			UIComponent component, Object value) {
		String result;
		if(null == value) {
			result = null;
		} else {
			result = Integer.toString(getList(component).indexOf(value));
		}
		return result;
	}
}

package ru.bpc.jsf.conversion;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;

@FacesConverter("bpc.ShortStringConverter")
public class ShortStringConverter implements Converter{
	public Object getAsObject(FacesContext context, UIComponent component, String value) {
		Integer maxLength = null;
		try {
			maxLength = Integer.parseInt((String)component.getAttributes().get("stringLength"));
		} catch (NumberFormatException e) {			
		}
		if (maxLength == null || maxLength < 0) {
			maxLength = 30;
		}
		if (value != null) {
			int length = value.length();
			if (length > maxLength) {
				value = value.substring(0, maxLength) + "...";
			}
		}
		return value;
	}
	
	public String getAsString(FacesContext context, UIComponent component, Object value) {
		String val = value.toString();
		Integer maxLength = null;
		try {
			maxLength = Integer.parseInt((String)component.getAttributes().get("stringLength"));
		} catch (NumberFormatException e) {			
		}
		if (maxLength == null || maxLength < 0){
			maxLength = 30;
		}
		if (val != null) {
			int length = val.length();
			if (length > maxLength) {
				val = val.substring(0, maxLength) + "...";
			}
		}
		return val;
	}

}

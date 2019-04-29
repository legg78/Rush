package ru.bpc.jsf.conversion;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;

@FacesConverter("HexadecimalConverter")
public class HexadecimalConverter implements Converter {

	@Override
	public Object getAsObject(FacesContext arg0, UIComponent arg1, String arg2) {
		Integer result = null;
		try {
			result = Integer.parseInt(arg2, 16);
		} catch (NumberFormatException e){
			
		}
		return result;
	}

	@Override
	public String getAsString(FacesContext arg0, UIComponent arg1, Object arg2) {
		String result = null;
		Integer arg = (Integer)arg2;
		result = Integer.toString(arg, 16);
		result = result.toUpperCase();
		return result;		
	}

}

package ru.bpc.jsf.conversion;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;

import ru.bpc.sv2.cmn.CmnStandard;
@FacesConverter("bpc.CmnStandardConverter")
public class CmnStandardConverter implements Converter {

	/*
	 * (non-Javadoc)
	 * 
	 * @see javax.faces.convert.Converter#getAsObject(javax.faces.context.FacesContext,
	 * javax.faces.component.UIComponent, java.lang.String)
	 */
	public Object getAsObject(FacesContext context, UIComponent component, String value) {

		int index = value.indexOf(':');
		CmnStandard std = new CmnStandard();
		std.setLabel(value.substring(index + 1));
		std.setId(Long.valueOf(value.substring(0, index)));
		return std;
	}

	/*
	 * (non-Javadoc)
	 * 
	 * @see javax.faces.convert.Converter#getAsString(javax.faces.context.FacesContext,
	 * javax.faces.component.UIComponent, java.lang.Object)
	 */
	public String getAsString(FacesContext context, UIComponent component, Object value) {

		CmnStandard optionItem = (CmnStandard) value;
		return optionItem.getId() + ":" + optionItem.getLabel();
	}

}

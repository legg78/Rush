package ru.bpc.sv2.ui.products;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;

import ru.bpc.sv2.ui.utils.FacesUtils;

@FacesConverter("UnlimitedConv")
public class UnlimitedConv implements Converter{
	String unlimited = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
			"unlimited");
	@Override
	public Object getAsObject(FacesContext context, UIComponent component,
			String value) {
		if(value.trim().equalsIgnoreCase(unlimited)){
			value = "9999";
		}
		return Integer.valueOf(value);
	}

	@Override
	public String getAsString(FacesContext context, UIComponent component,
			Object value) {
		if(value.toString().equals("9999")){
			return unlimited;
		}
		return value.toString();
	}
	
}

package ru.bpc.jsf.conversion;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.ConverterException;
import javax.faces.convert.FacesConverter;

import ru.bpc.sv2.ui.utils.FacesUtils;

/**
 * documentation has been lost
 *  
 * @author Alexeev
 *
 */
@FacesConverter("bpc.NotEmptyConverter")
public class NotEmptyConverter implements Converter {
	public Object getAsObject(FacesContext context, UIComponent component, String value) 
			throws ConverterException {
		String skipValidation = FacesUtils.getRequestParameter("skipValidation");
		if (skipValidation != null && Boolean.parseBoolean(skipValidation)) {
			return value;
		}
		if (value == null || value.trim().length() < 1) {
			String label = ((HtmlInputText) component).getLabel();
			if (label == null || label.trim().length() == 0) {
				label = component.getClientId(context);
			}
			// TODO: see what will be if use: ((UIInput) component).getRequiredMessage()
			String msgText = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"javax.faces.component.UIInput.REQUIRED",
					label);
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msgText, msgText);
			context.addMessage(component.getClientId(context), message);
			((UIInput)component).setValid(false);
			
		}
		
		return value;
	}
	
	public String getAsString(FacesContext context, UIComponent component, Object value)
			throws ConverterException {
		if (value == null) value = "";
		return value.toString();
	}


}

package ru.bpc.jsf.misc.form;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import java.io.IOException;

/**
 * Adds hidden input with CSRF token to the form on render
 */
public class FormRenderer extends com.sun.faces.renderkit.html_basic.FormRenderer {
	@Override
	public void encodeEnd(FacesContext context, UIComponent component) throws IOException {
		CsrfFormDecorator.encodeFormEnd(context, component);
		super.encodeEnd(context, component);
	}
}

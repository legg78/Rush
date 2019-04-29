package ru.bpc.jsf.misc.form;

import org.apache.log4j.Logger;
import org.owasp.csrfguard.CsrfGuard;
import ru.bpc.sv2.ui.utils.RequestContextHolder;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;
import javax.servlet.http.HttpServletRequest;

class CsrfFormDecorator {
	private static final Logger logger = Logger.getLogger(CsrfFormDecorator.class);

	static void encodeFormEnd(FacesContext context, UIComponent component) {
		// Writing hidden input with CSRF token
		try {
			String tokenName = CsrfGuard.getInstance().getTokenName();
			String tokenValue = CsrfGuard.getInstance().getTokenValue(RequestContextHolder.getRequest());
			ResponseWriter writer = context.getResponseWriter();
			writer.startElement("input", null);
			writer.writeAttribute("name", tokenName, null);
			writer.writeAttribute("type", "hidden", null);
			writer.writeAttribute("value", tokenValue, null);
			writer.endElement("input");
		} catch (Exception e) {
			// In the case of error hidden fields with tokens will be created by javascript Owasp.CsrfGuard.js
			logger.error(e.getMessage(), e);
		}
	}
}

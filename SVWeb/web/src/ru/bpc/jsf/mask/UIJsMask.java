package ru.bpc.jsf.mask;

import ru.bpc.sv2.ui.session.UserSession;
import util.auxil.ManagedBeanWrapper;

import java.io.IOException;

import javax.faces.component.UIComponent;
import javax.faces.component.UIComponentBase;
import javax.faces.context.FacesContext;
import javax.faces.context.ResponseWriter;

public class UIJsMask extends UIComponentBase{

	private static final String FAMILY = "jsSupport";
	private static final String MASK = "mask";	
	private static final String FOR = "for";
	private static final String DEC_DIGITS = "decDigits";
	private static final String PROMT_TEXT = "promtText";
	private static final String FILL_DIGITS = "fillDigits";
	private UserSession us;
	
	public UIJsMask(){
		setRendererType(null);
		us = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
	}
	
	@Override
	public String getFamily() {
		return FAMILY;
	}

	@Override
	public void encodeEnd (FacesContext context) throws IOException {
		ResponseWriter rw = context.getResponseWriter();
		Object bfr = null;
		String inputId = null;
		String mask = null;
		String decDigs = null;
		String promted = null;
		String promtText = null;
		bfr = getAttributes().get(FOR);
		if (bfr != null) inputId = bfr.toString();
		bfr = getAttributes().get(MASK);
		if (bfr != null) mask = bfr.toString();
		bfr = getAttributes().get(DEC_DIGITS);		
		if (bfr != null) decDigs = bfr.toString();
		bfr = getAttributes().get(PROMT_TEXT);
		if (bfr != null){
			promtText = bfr.toString();
			promted = "true";
		} else {
			promted = "false";
		}
		String fillDigits = getAttributes().get(FILL_DIGITS) == null ? "false" : getAttributes().get(FILL_DIGITS).toString();

		UIComponent input = this.getParent().findComponent(inputId);
		if (input != null){
			inputId = input.getClientId(context);
		}
		
		String type = mask != null ? "fixed" : "number";
		if (decDigs == null) {decDigs = "2";}
		String template = 				
				"<script>" +
				"var options = {type:\'%s\',mask:\'%s\',decDigits:%s,promted:%s,promtText:\'%s\',fillDigits:%s,groupSymbol:\'%s\'};" +
				"new MaskType(document.getElementById(\'%s\'),options);" +
				"</script>";
		String response = String.format(template, type, mask, decDigs, promted, promtText, fillDigits, us.getGroupSeparator(), inputId);
		rw.write(response);		
	}
}

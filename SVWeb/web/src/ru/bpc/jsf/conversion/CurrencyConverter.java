package ru.bpc.jsf.conversion;

import java.math.BigDecimal;

import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;

import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

@FacesConverter("bpc.CurrencyConverter")
public class CurrencyConverter implements Converter{
	
	private String groupSymbol = ",";
	private UserSession us;

	public CurrencyConverter() {
		us = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
	}
	
	static final String[] FRACTION_TABLE = {
	    (String)""
	    ,(String)".0"
	    ,(String)".00"
	    ,(String)".000"
	    ,(String)".0000"
	    ,(String)".00000"
	    }; 
	
	public Object getAsObject(FacesContext context, UIComponent component, String value) {
		Integer exponent = null;
		BigDecimal val = null;
		
//		try {
//			val = Double.parseDouble(value);
//		} catch (NumberFormatException e1) {
//			return null;
//		}
		if (value == null || value.trim().length() == 0) {
			return null;
		}
		
		try {
			value = value.replaceAll(us.getGroupSeparator(), "");
			val = new BigDecimal(value);
		} catch (NumberFormatException e) {
			((HtmlInputText) component).setValid(false);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "must_be_number");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(component.getClientId(context), message);
			return val;
		}
		
		try {
			exponent = (Integer)component.getAttributes().get("exponent");
		} catch (NumberFormatException e) {
		}
		if (exponent == null || exponent < 0) {
			exponent = 2;
		}

//		NumberConverter numberConverter = new NumberConverter();
//		String fractionPart = FRACTION_TABLE[exponent];
//		numberConverter.setPattern("##0" + fractionPart);
//		try {
//			val = Double.parseDouble(numberConverter.getAsObject(context, component, value).toString());
//		} catch (Exception e) {
//			return null;
//		}
		try {
			// if provided value has too big fraction part - show error
			val.setScale(exponent);
		} catch (ArithmeticException e) {
			((HtmlInputText) component).setValid(false);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"max_fract_digits_exceed", exponent);
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(component.getClientId(context), message);
			return val;
		}

		val = val.multiply(BigDecimal.valueOf(Math.pow(10, exponent)));
		return val;
	}
	
	public String getAsString(FacesContext context, UIComponent component, Object value) {
		BigDecimal val;
		Integer exponent = null;
		
		try {
			String valueStr = value.toString().trim();
			val = new BigDecimal(valueStr);
		} catch (NumberFormatException e) {
			return "";
		}
		
		try {
			exponent = (Integer)component.getAttributes().get("exponent");
		} catch (NumberFormatException e) {
		}
		if (exponent == null || exponent < 0) {
			exponent = 2;
		}
		val = val.divide(BigDecimal.valueOf(Math.pow(10, exponent)));
		
		// TODO: correct rounding mode?
		String result = val.setScale(exponent, BigDecimal.ROUND_HALF_UP).toString();
		
//		try {
//			NumberConverter numberConverter = new NumberConverter();
//			String fractionPart = FRACTION_TABLE[exponent];
//			numberConverter.setPattern("##0" + fractionPart);
//			result = numberConverter.getAsString(context, component, val);
//		} catch (Exception e) {
//			result = val.toString();
//		}

		String intPart = result.substring(0, result.contains(".") ? result.indexOf('.') : result
				.length());
		if (intPart.length() > 3) {
			String fractPart = result.contains(".") ? result.substring(result.indexOf(".")) : "";
			result = "";
			int k = 0;
			// split by 3 symbols
			for (int i = intPart.length() - 1; i >= 0; i --) {
				if (++k == 4) {
					result = us.getGroupSeparator() + result;
					k = 1;
				}
				result = intPart.charAt(i) + result;
			}
			result += fractPart;
		}
		
		return result;
	}

}

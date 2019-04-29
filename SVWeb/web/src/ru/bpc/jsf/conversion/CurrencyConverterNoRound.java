package ru.bpc.jsf.conversion;

import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.component.html.HtmlInputText;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;
import java.math.BigDecimal;

@FacesConverter("bpc.CurrencyConverterNoRound")
public class CurrencyConverterNoRound implements Converter{

    private String groupSymbol = ",";

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

        if (value == null || value.trim().length() == 0) {
            return null;
        }

        try {
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

        try {
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


        String result = val.toString();


        String intPart = result.substring(0, result.contains(".") ? result.indexOf('.') : result
                .length());
        if (intPart.length() > 3) {
            String fractPart = result.contains(".") ? result.substring(result.indexOf(".")) : "";
            result = "";
            int k = 0;
            for (int i = intPart.length() - 1; i >= 0; i --) {
                if (++k == 4) {
                    result = "," + result;
                    k = 1;
                }
                result = intPart.charAt(i) + result;
            }
            result += fractPart;
        }

        return result;
    }
}

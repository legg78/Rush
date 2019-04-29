package ru.bpc.jsf.conversion;

import ru.bpc.sv2.ui.utils.FacesUtils;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;
import javax.faces.component.html.HtmlInputText;
import java.math.BigDecimal;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */

@FacesConverter("bpc.PercentConverter")
public class PercentConverter implements Converter {

    @Override
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
            exponent = Integer.parseInt((String)component.getAttributes().get("exponent"));
        } catch (NumberFormatException e) {
        }
        if (exponent == null || exponent < 0) {
            exponent = 2;
        }
        try {
            val.setScale(exponent);
        } catch (ArithmeticException e) {
            ((HtmlInputText) component).setValid(false);
            String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "max_fract_digits_exceed", exponent);
            FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
            context.addMessage(component.getClientId(context), message);
            return val;
        }
        val = val.multiply(BigDecimal.valueOf(Math.pow(10, exponent)));
        return val;
    }

    @Override
    public String getAsString(FacesContext context, UIComponent component, Object value) {
        BigDecimal itemValue  = (BigDecimal) value;
        BigDecimal result = BigDecimal.ZERO;
        itemValue  = itemValue.multiply(new BigDecimal(100));
        result = result.add(itemValue);
        return result.toString();
    }
}

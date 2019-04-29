package ru.bpc.jsf.conversion;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;
import java.math.BigDecimal;
import java.util.UUID;

@FacesConverter (value = "BooleanConverter")
public class BooleanConverter implements Converter {
    private static final String TRUE_STRING = "true";
    private static final String TRUE_DIGIT = "1";
    private static final String FALSE_STRING = "false";
    private static final String FALSE_DIGIT = "0";

    @Override
    public Object getAsObject(FacesContext facesContext, UIComponent uiComponent, String value) {
        if (value == null || value.trim().length() == 0) {
            return null;
        }
        value = value.trim();
        if (TRUE_STRING.equalsIgnoreCase(value) || TRUE_DIGIT.equalsIgnoreCase(value)) {
            return Boolean.TRUE;
        }
        return Boolean.FALSE;
    }

    @Override
    public String getAsString(FacesContext facesContext, UIComponent uiComponent, Object value) {
        if (value != null) {
            if (value instanceof Boolean) {
                return value.toString();
            } else if (value instanceof String) {
                return (String) value;
            } else if (value instanceof Integer) {
                return (((Integer) value).intValue() != 0) ? TRUE_STRING : FALSE_STRING;
            } else if (value instanceof Long) {
                return (((Long) value).longValue() != 0) ? TRUE_STRING : FALSE_STRING;
            } else if (value instanceof Double) {
                if (!((Double) value).isNaN()) {
                    return (((Double) value).longValue() != 0) ? TRUE_STRING : FALSE_STRING;
                }
            }
        }
        return "";
    }
}

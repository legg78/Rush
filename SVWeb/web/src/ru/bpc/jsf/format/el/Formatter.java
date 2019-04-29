package ru.bpc.jsf.format.el;

import java.math.BigDecimal;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.text.NumberFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;
import java.util.TimeZone;

import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.LocaleContextHolder;
import util.auxil.ManagedBeanWrapper;

public class Formatter {
	public static int DOUBLE_FRACTION_DIGITS = 340;
	public static int DEFAULT_EXPONENT = 2;

    private Formatter() {
        // Hide constructor.
    }

    public static String formatDate(Date date, String pattern, String timeZoneId) {
    	if (date == null) {
    		return "";
    	}
    	if (pattern == null) {
    		return date.toString();
    	}
    	SimpleDateFormat sdf = new SimpleDateFormat(pattern); 
    	if (timeZoneId != null && timeZoneId.trim().length() > 0) {
    		sdf.setTimeZone(TimeZone.getTimeZone(timeZoneId));
    	}
        return sdf.format(date);
    }
    
    // kinda strange method but should work
    public static String formatDateRange(Date dateFrom, Date dateTo, String pattern, String timeZoneId) {
    	if (dateFrom == null && dateTo == null) {
    		return "";
    	}

    	String dateFromStr = "";
    	String dateToStr = "";
    	
		if (pattern == null) {
			dateFromStr = dateFrom == null ? "" : dateFrom.toString();
			dateToStr = dateTo == null ? "" : dateTo.toString();
		} else {
	    	SimpleDateFormat sdf = new SimpleDateFormat(pattern); 
	    	if (timeZoneId != null && timeZoneId.trim().length() > 0) {
	    		sdf.setTimeZone(TimeZone.getTimeZone(timeZoneId));
	    	}
			dateFromStr = dateFrom == null ? "" : sdf.format(dateFrom);
			dateToStr = dateTo == null ? "" : sdf.format(dateTo);
		}
		
    	if (dateFrom != null && dateTo == null) {
        	return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "from") + " " + dateFromStr;
        } else if (dateFrom == null && dateTo != null) {
        	return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "till") + " " + dateToStr;
        } else {
        	return dateFromStr + " - " + dateToStr;
        }
    }

	public static String formatMoney(BigDecimal value, Number exp) {
		if (value != null) {
			Integer exponent;
			if (exp == null) {
				exponent = DEFAULT_EXPONENT;
			} else {
				exponent = exp.intValue();
			}
			UserSession us = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
			value = value.divide(BigDecimal.valueOf(Math.pow(10, exponent)));
			value = value.setScale(exponent, BigDecimal.ROUND_HALF_UP);
			DecimalFormat formatter = (DecimalFormat) NumberFormat.getInstance(LocaleContextHolder.getLocale());
			DecimalFormatSymbols symbols = formatter.getDecimalFormatSymbols();
			symbols.setGroupingSeparator(us.getGroupSeparator().charAt(0));
			formatter.setDecimalFormatSymbols(symbols);
			formatter.setMaximumFractionDigits(exponent);
			formatter.setMinimumFractionDigits(exponent);
			return formatter.format(value);
		}
		return "";
	}

	public static String formatNumber(Double value, String pattern){
		DecimalFormatSymbols symbols = new DecimalFormatSymbols(LocaleContextHolder.getLocale());
		DecimalFormat df = new DecimalFormat(pattern, symbols);
		df.setMaximumFractionDigits(DOUBLE_FRACTION_DIGITS);
		df.setGroupingUsed(false);
		return df.format(value);
	}
}

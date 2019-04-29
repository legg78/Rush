package ru.bpc.jsf.mask;

import org.apache.commons.lang3.StringUtils;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import java.io.Serializable;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Map;

//This intended for masked numeric INPUT and EDITING. E.g. for input/edit amount in create or edit dialog.
public class NumericMaskConverter implements Converter, Serializable{

	private static final long serialVersionUID = 1L;
	
	private static final String INT = "int";
	private static final String DOUBLE = "double";
	private static final String LONG = "long";
	private static final String BIG_DEC = "bigdecimal";
	
	private String numericType = INT;
	private Integer decDigits = 2;
	private int groupDigits = 3;
	private String groupSymbol = ",";
	private String decSymbol = ".";
	private String validSimbols = "1234567890";

	public Object getAsObject(FacesContext arg0, UIComponent arg1, String arg2) {
		if (StringUtils.isEmpty(arg2)) {
			return null;
		}

		char[] resultSrc = new char[arg2.length()];
		char[] srcSrc = arg2.toCharArray();
		int i = 0;
		for (char simbol : srcSrc) {
			if (validSimbols.indexOf(simbol) >= 0 ) {
				resultSrc[i++] = simbol;
			} else if (decSymbol.charAt(0) == simbol){
				resultSrc[i++] = '.';
			}
		}

		Integer extDecDigits = obtainDecDigs(arg1); 
		if (extDecDigits != null){
			this.decDigits = extDecDigits;
		}
		
		String resultStr = new String(resultSrc, 0, i);
		if (resultStr.isEmpty()) return null;
		if (INT.equals(numericType)) {
			int dotPosition = resultStr.length() - getDecDigits();
			if (getDecDigits() > 0){
				dotPosition--;
			}
			resultStr = resultStr.substring(0, dotPosition);
			return Integer.parseInt(resultStr);
		} else if (DOUBLE.equals(numericType)) {
			return new Double(resultStr) * Math.pow(10, decDigits);
		} else if (LONG.equals(numericType)){
			int dotPosition = resultStr.length() - getDecDigits();
			if (getDecDigits() > 0){
				dotPosition--;
			}
			resultStr = resultStr.substring(0,dotPosition);		
			return Long.parseLong(resultStr);
		} else if (BIG_DEC.equals(numericType)){
			BigDecimal result = null;
			result = new BigDecimal(resultStr);
			result = result.scaleByPowerOfTen(decDigits);
			result = result.divideToIntegralValue(new BigDecimal(1));
			result = result.setScale(1);
			return result;
		} else {
			return 0;
		}
	}

	public String getAsString(FacesContext arg0, UIComponent arg1, Object arg2) {		
		if (arg2 == null) {
			return "";
		}

		Number number = (Number)arg2;
		String result = "";
		Integer decDigits = obtainDecDigs(arg1);
		if (decDigits != null){
			this.decDigits = decDigits;
		}
		
		if (INT.equals(numericType)) {	
			result = Integer.toString(number.intValue());
			for (int i=0;i<getDecDigits();i++){
				result += "0";
			}		
		} else if (LONG.equals(numericType)){
			result = Long.toString(number.longValue());
			for (int i=0;i<getDecDigits();i++){
				result += "0";
			}		                                   
		} else if (DOUBLE.equals(numericType)) {
			Double dNumber = number.doubleValue();
			dNumber = dNumber / Math.pow(10, getDecDigits());
			
			DecimalFormat format = (DecimalFormat) DecimalFormat.getInstance();
			format.setGroupingUsed(false);
			DecimalFormatSymbols dfs = new DecimalFormatSymbols();
			dfs.setDecimalSeparator('.');
			format.setDecimalFormatSymbols(dfs);
			format.setMaximumFractionDigits(getDecDigits());
			format.setMinimumFractionDigits(getDecDigits());
			format.setRoundingMode(RoundingMode.HALF_UP);
			
			String numberStr = format.format(dNumber);
			if (numberStr.indexOf('.') >= 0){
				String[] parts = numberStr.split("\\.");
				if (getDecDigits() > parts[1].length()) {
					result = parts[0] + parts[1];
				} else {
					result = parts[0] + parts[1].substring(0,getDecDigits());
				}
				
			} else {
				result = numberStr;
			}
		} else if (BIG_DEC.equals(numericType)) {
			
			BigDecimal bigNumber = (BigDecimal) number;
			bigNumber = bigNumber.divide(BigDecimal.valueOf((Math.pow(10, getDecDigits()))));
			
			DecimalFormat format = (DecimalFormat) DecimalFormat.getInstance();
			format.setGroupingUsed(false);
			DecimalFormatSymbols dfs = new DecimalFormatSymbols();
			dfs.setDecimalSeparator('.');
			format.setDecimalFormatSymbols(dfs);
			format.setMaximumFractionDigits(getDecDigits());
			format.setMinimumFractionDigits(getDecDigits());
			format.setRoundingMode(RoundingMode.HALF_UP);
			
			String numberStr = format.format(bigNumber);
			if (numberStr.indexOf('.') >= 0) {
				String[] parts = numberStr.split("\\.");
				if (getDecDigits() > parts[1].length()) {
					result = parts[0] + parts[1];
				} else {
					result = parts[0] + parts[1].substring(0,getDecDigits());
				}
				
			} else {
				result = numberStr;
			}
		}
		
		return result;
	}
	
	private Integer obtainDecDigs(UIComponent component){
		Object attribute = component.getAttributes().get("decDigits");
		if (attribute instanceof String){
			return new Integer((String)attribute);
		} else {
			return (Integer)attribute;
		}

	}
	
	public String getNumericType() {
		return numericType;
	}

	public void setNumericType(String numericType) {
		this.numericType = numericType;
	}

	public Integer getDecDigits() {
		return decDigits;
	}

	public void setDecDigits(Integer decDigits) {
		this.decDigits = decDigits;
	}
	
}

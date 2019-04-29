package ru.bpc.jsf.mask;

import java.io.Serializable;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;

//This intended for masked INPUT and EDITING. E.g. for input/edit phone number in create or edit dialog.
public class FixedMaskConverter implements Converter, Serializable{

	private static final long serialVersionUID = 1L;
	
	private String mask;
	private String emptyChar = "_";		
	
	public Object getAsObject(FacesContext arg0, UIComponent arg1, String arg2) {
		String result = "";
		if (mask != null && mask != "") {			
			for (int i = 0, len = mask.length(); i < len; i++) {
				if ("ax9".indexOf(mask.codePointAt(i)) >= 0){
					if (arg2.length() > i && emptyChar.codePointAt(0) != arg2.codePointAt(i)){
						result += arg2.substring(i,i+1);
					} 
				} 
			}
		}
		return result;
	}

	
	public String getAsString(FacesContext arg0, UIComponent arg1, Object arg2) {
		return arg2.toString();
	}

	public String getMask() {
		return mask;
	}

	public void setMask(String mask) {
		this.mask = mask;
	}

	public String getEmptyChar() {
		return emptyChar;
	}

	public void setEmptyChar(String emptyChar) {
		this.emptyChar = emptyChar;
	}

}

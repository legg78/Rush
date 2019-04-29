package ru.bpc.jsf.mask;

import java.io.Serializable;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;

// This intended for masked OUTPUT. E.g. for dispaly phone number in table or view dialog.
public class OutputMaskConverter implements Converter, Serializable{

	private static final long serialVersionUID = 1L;
	
	private String mask;
	private String emptyChar = "_";
	
	@Override
	public Object getAsObject(FacesContext arg0, UIComponent arg1, String arg2) {
		return null;
	}

	@Override
	public String getAsString(FacesContext arg0, UIComponent arg1, Object arg2) {
		String source = arg2.toString();
		if (source == null || "".equals(source)){
			return null;
		}
		String mask = this.getMask().toLowerCase();
		char[] srcSource = source.toCharArray();
		char[] srcMask = mask.toCharArray();
		char[] srcResult = new char[mask.length()];
		int u = 0;
		for (int i = 0, len = mask.length(); i < len; i++) {
			switch (srcMask[i]){
				case 'a':
				case 'x':
				case '9':
					if (source != "" && source.length() > u){
						srcResult[i] = srcSource[u++];
					} else {
						srcResult[i] = getEmptyChar().charAt(0);
						u++;
					}
					break;
				default:
					srcResult[i] = srcMask[i];
					break;
			}			
		}
		String result = new String(srcResult);		
		return result;
	}

	public String getEmptyChar() {
		return emptyChar;
	}

	public void setEmptyChar(String emptyChar) {
		this.emptyChar = emptyChar;
	}

	public String getMask() {
		return mask;
	}

	public void setMask(String mask) {
		this.mask = mask;
	}



}

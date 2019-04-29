package ru.bpc.jsf.conversion;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.convert.Converter;
import javax.faces.convert.FacesConverter;

@FacesConverter ("SecondToHoursConverter")
public class SecondToHoursConverter implements Converter{

	@Override
	public Object getAsObject(FacesContext arg0, UIComponent arg1, String arg2) {		
		String[] pieces = arg2.split(":");
		int hours = Integer.parseInt(pieces[0]);
		int minutes = Integer.parseInt(pieces[1]);
		int seconds = Integer.parseInt(pieces[2]);
		Long timeInSeconds = (long) (seconds + minutes * 60 + hours * 3600);
		return timeInSeconds;
	}

	@Override
	public String getAsString(FacesContext arg0, UIComponent arg1, Object arg2) {
		Long timeInSeconds = (Long)arg2;
		int hours = (int) (timeInSeconds / 3600);
		int remainder = (int) (timeInSeconds - hours * 3600);
		int minutes = remainder / 60;
		remainder = remainder - minutes * 60;
		int seconds = remainder;

		String result = String.format("%d:%02d:%02d", hours, minutes, seconds);
		return result;
	}

}

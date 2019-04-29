package ru.bpc.jsf.validation;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.faces.application.FacesMessage;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.validator.FacesValidator;
import javax.faces.validator.Validator;
import javax.faces.validator.ValidatorException;

import ru.bpc.sv2.ui.utils.FacesUtils;

@FacesValidator("bpc.RegExValidator")
public class RegExValidator implements Validator{

	private static String ERROR_BUNDLE = "ru.bpc.sv2.ui.bundles.Error";
	private static String NOT_MATCH_THE_PATTERN_KEY = "no_match_the_pattern";
	
	private String regexp;
	private String textPattern;		// contains "user-friendly" pattern
    private String fieldName;
	
	public void validate(FacesContext context, UIComponent component, Object value) throws ValidatorException {
		// if component was invalidated by some previous validator then we don't
		// need to validate it again
		if (!((UIInput) component).isValid()) {
			return;
		}
		Pattern mask =  null;		 
	    initProps(component);

	    if (regexp != null && !regexp.equals("")) {
	    	try {
				mask = Pattern.compile(regexp);
			} catch (Exception e) {
				FacesMessage message = new FacesMessage();
			    message.setDetail("Pattern " + regexp + " is not valid");
			    message.setSeverity(FacesMessage.SEVERITY_ERROR);
			    throw new ValidatorException(message);
			}
	    }

	    String field = (String)value; 
			 	
	    Matcher matcher = mask.matcher(field);
		     
	    if (!matcher.matches()){		     	
	       FacesMessage message = new FacesMessage();
	       if (textPattern == null) {
               textPattern = regexp;
	       }
           if (fieldName == null){
               fieldName = "";
           }
	       String msg = FacesUtils.getMessage(ERROR_BUNDLE,NOT_MATCH_THE_PATTERN_KEY, fieldName, textPattern);
	       
	       //String str = "Field does not match the pattern ";

	       message.setDetail(msg);
	       message.setSummary(msg);
	       message.setSeverity(FacesMessage.SEVERITY_ERROR);
	       throw new ValidatorException(message);
	    }
	}
	
	private void initProps(UIComponent component) {
		regexp = (String)component.getAttributes().get("pattern");
		textPattern = (String) component.getAttributes().get("textPattern");
        fieldName = (String) component.getAttributes().get("fieldName");
	}

	public void setPattern(String pattern){
		regexp = pattern;
	}
	
	public String getPattern(){
		return regexp;
	}
}

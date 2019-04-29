package ru.bpc.sv2.ui.application.blocks.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.Contact;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbContactEdit")
public class MbContactEdit extends SimpleAppBlock{

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String COMMAND = "COMMAND";
	private static final String CONTACT_TYPE = "CONTACT_TYPE";
	private static final String PREFERRED_LANG = "PREFERRED_LANG";
	private static final String JOB_TITLE = "JOB_TITLE";
	private static final String PHONE_NUMBER = "PHONE_NUMBER";
	private static final String MOBILE_NUMBER = "MOBILE_NUMBER";
	private static final String FAX = "FAX";
	private static final String EMAIL = "EMAIL";
	private static final String IM_TYPE = "IM_TYPE";
	private static final String IM_NUMBER = "IM_NUMBER";

	private Contact activeItem;
	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Contact());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();

		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null) {
			setCommand(childElement.getValueV());
			getObjectAttrs().put(COMMAND, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(CONTACT_TYPE, 1);
		if (childElement != null) {
			activeItem.setContactType(childElement.getValueV());
			getObjectAttrs().put(CONTACT_TYPE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(PREFERRED_LANG, 1);
		if (childElement != null) {
			activeItem.setPreferredLang(childElement.getValueV());
			getObjectAttrs().put(PREFERRED_LANG, childElement);
		}

		childElement = getLocalRootEl().getChildByName(JOB_TITLE, 1);
		if (childElement != null) {
			activeItem.setJobTitle(childElement.getValueV());
			getObjectAttrs().put(JOB_TITLE, childElement);
		}				
	}
	
	@Override
	public void formatObject(ApplicationElement element) {
		if (getActiveItem() == null || getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;

		childElement = element.getChildByName(COMMAND, 1);
		if (childElement != null) {
			childElement.setValueV(getCommand());
		}		
		
		childElement = element.getChildByName(CONTACT_TYPE, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getContactType());
		}	
		
		childElement = element.getChildByName(PREFERRED_LANG, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getPreferredLang());
		}	
		
		childElement = element.getChildByName(JOB_TITLE, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getJobTitle());
		}			
	}
	
	public Object getActiveItem() {
		return activeItem;
	}

	protected void setActiveItem(Object object) {
		this.activeItem = (Contact) object;
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}
	
	public List<SelectItem> getCommands(){
		List<SelectItem> result = getLov(objectAttrs.get(COMMAND));
		return result;
	}
	
	public List<SelectItem> getContactTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(CONTACT_TYPE));
		return result;
	}
	
	public List<SelectItem> getPreferredLangs(){
		List<SelectItem> result = getLov(objectAttrs.get(PREFERRED_LANG));
		return result;
	}	
	
	public List<SelectItem> getImTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(IM_TYPE));
		return result;
	}	
	
	@Override
	protected void clear() {
		super.clear();
		setActiveItem(null);
		setCommand(null);
	}
}

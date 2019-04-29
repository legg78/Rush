package ru.bpc.sv2.ui.application.blocks.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbPersonEdit")
public class MbPersonEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private static final String PERSON_TITLE = "PERSON_TITLE";
	private static final String SUFFIX = "SUFFIX";
	private static final String BIRTHDAY = "BIRTHDAY";
	private static final String GENDER = "GENDER";
	private static final String COMMAND = "COMMAND";

	private Person activeItem;
	private Map<String, ApplicationElement> objectAttrs;	
	
	private String command;
	
	@Override
	public void formatObject(ApplicationElement element) {
		if (getActiveItem() == null || getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;

		childElement = element.getChildByName(PERSON_TITLE, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getTitle());
		}

		childElement = element.getChildByName(SUFFIX, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getSuffix());
		}

		childElement = element.getChildByName(BIRTHDAY, 1);
		if (childElement != null) {
			childElement.setValueD(activeItem.getBirthday());
		}

		childElement = element.getChildByName(GENDER, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getGender());
		}
		
		childElement = element.getChildByName(COMMAND, 1);
		if (childElement != null) {
			childElement.setValueV(getCommand());
		}
	}

	@Override
	public void parseAppBlock() {
		setActiveItem(new Person());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();

		childElement = getLocalRootEl().getChildByName(PERSON_TITLE, 1);
		if (childElement != null) {
			activeItem.setTitle(childElement.getValueV());
			getObjectAttrs().put(PERSON_TITLE, childElement);
		}

		childElement = getLocalRootEl().getChildByName(SUFFIX, 1);
		if (childElement != null) {
			activeItem.setSuffix(childElement.getValueV());
			getObjectAttrs().put(SUFFIX, childElement);
		}

		childElement = getLocalRootEl().getChildByName(BIRTHDAY, 1);
		if (childElement != null) {
			activeItem.setBirthday(childElement.getValueD());
			getObjectAttrs().put(BIRTHDAY, childElement);
		}

		childElement = getLocalRootEl().getChildByName(GENDER, 1);
		if (childElement != null) {
			activeItem.setGender(childElement.getValueV());
			getObjectAttrs().put(GENDER, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null) {
			setCommand(childElement.getValueV());
			getObjectAttrs().put(COMMAND, childElement);
		}
	}
	
	public Object getActiveItem() {
		return activeItem;
	}

	protected void setActiveItem(Object object) {
		this.activeItem = (Person) object;		
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public List<SelectItem> getTitles(){
		List<SelectItem> result = getLov(objectAttrs.get(PERSON_TITLE));
		return result;
	}
	
	public List<SelectItem> getSuffixes(){
		List<SelectItem> result = getLov(objectAttrs.get(SUFFIX));
		return result;
	}

	public List<SelectItem> getGenderes(){
		List<SelectItem> result = getLov(objectAttrs.get(GENDER));
		return result;
	}
	
	public List<SelectItem> getCommands(){
		List<SelectItem> result = getLov(objectAttrs.get(COMMAND));
		return result;
	}	

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}
	
	@Override
	protected void clear() {
		super.clear();
		setActiveItem(null);
		setCommand(null);
	}
}

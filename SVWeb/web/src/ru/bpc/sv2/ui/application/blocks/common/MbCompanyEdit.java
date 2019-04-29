package ru.bpc.sv2.ui.application.blocks.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.Company;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbCompanyEdit")
public class MbCompanyEdit extends SimpleAppBlock{

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String COMMAND = "COMMAND";
	private static final String EMBOSSED_NAME = "EMBOSSED_NAME";
	
	private Company activeItem;
	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Company());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();

		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null) {
			setCommand(childElement.getValueV());
			getObjectAttrs().put(COMMAND, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(EMBOSSED_NAME, 1);
		if (childElement != null) {
			activeItem.setEmbossedName(childElement.getValueV());
			getObjectAttrs().put(EMBOSSED_NAME, childElement);
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
		
		childElement = element.getChildByName(EMBOSSED_NAME, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getEmbossedName());
		}		
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	
	@Override
	protected void clear() {
		super.clear();
		setActiveItem(null);
		setCommand(null);
	}

	public Company getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Company activeItem) {
		this.activeItem = activeItem;
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
}

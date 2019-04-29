package ru.bpc.sv2.ui.application.blocks.common;

import java.util.HashMap;

import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbAccountEdit")
public class MbAccountEdit extends SimpleAppBlock {
	private static final Logger logger = Logger.getLogger("APPLICATION");

	private static final String COMMAND = "COMMAND";
	
	private Account activeItem;
	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	public void parseAppBlock() {
		//implement hardcode here
		activeItem = new Account();
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();

		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null) {
			setCommand(childElement.getValueV());
			getObjectAttrs().put(COMMAND, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName("ACCOUNT_NUMBER", 1);
		if (childElement != null) {
			activeItem.setAccountNumber(childElement.getValueV());
			getObjectAttrs().put("ACCOUNT_NUMBER", childElement);
		}

		childElement = getLocalRootEl().getChildByName("ACCOUNT_STATUS", 1);
		if (childElement != null) {
			activeItem.setStatus(childElement.getValueV());
			getObjectAttrs().put("ACCOUNT_STATUS", childElement);
		}

		childElement = getLocalRootEl().getChildByName("CURRENCY", 1);
		if (childElement != null) {
			activeItem.setCurrency(childElement.getValueV());
			getObjectAttrs().put("CURRENCY", childElement);
		}

		childElement = getLocalRootEl().getChildByName("ACCOUNT_TYPE", 1);
		if (childElement != null) {
			activeItem.setAccountType(childElement.getValueV());
			getObjectAttrs().put("ACCOUNT_TYPE", childElement);
		}
	}
	
	@Override
	public void formatObject(ApplicationElement element) {
		//implement hardcode here
		if (getActiveItem() == null || getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;

		childElement = element.getChildByName(COMMAND, 1);
		if (childElement != null) {
			childElement.setValueV(getCommand());
		}		
		
		childElement = element.getChildByName("ACCOUNT_NUMBER", 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getAccountNumber());
		}	

		childElement = element.getChildByName("ACCOUNT_STATUS", 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getStatus());
		}	
		
		childElement = element.getChildByName("CURRENCY", 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getCurrency());
		}	
		
		childElement = element.getChildByName("ACCOUNT_TYPE", 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getAccountType());
		}	
	}

	public Object getActiveItem() {
		return activeItem;
	}

	protected void setActiveItem(Object object) {
		this.activeItem = (Account) object;
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public List<SelectItem> getAccountStatuses() {
		return getLov(objectAttrs.get("ACCOUNT_STATUS"));
	}
	
	public List<SelectItem> getAccountTypes() {
		return getLov(objectAttrs.get("ACCOUNT_TYPE"));
	}
	
	public List<SelectItem> getCurrencies() {
		return getLov(objectAttrs.get("CURRENCY"));
	}
	
	public List<SelectItem> getCommandsList() {
		return getLov(objectAttrs.get("COMMAND"));
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}
}

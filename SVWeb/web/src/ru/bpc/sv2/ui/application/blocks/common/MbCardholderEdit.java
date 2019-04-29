package ru.bpc.sv2.ui.application.blocks.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbCardholderEdit")
public class MbCardholderEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String COMMAND = "COMMAND";
	private static final String CARDHOLDER_NUMBER = "CARDHOLDER_NUMBER";
	private static final String CARDHOLDER_NAME = "CARDHOLDER_NAME";
	
	private String command;
	private String cardholderNumber;
	private String cardholderName;
	
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null) {
			setCommand(childElement.getValueV());
			getObjectAttrs().put(COMMAND, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARDHOLDER_NUMBER, 1);
		if (childElement != null) {
			setCardholderNumber(childElement.getValueV());
			getObjectAttrs().put(CARDHOLDER_NUMBER, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARDHOLDER_NAME, 1);
		if (childElement != null) {
			setCardholderName(childElement.getValueV());
			getObjectAttrs().put(CARDHOLDER_NAME, childElement);
		}
			
	}
	
	@Override
	public void formatObject(ApplicationElement element) {
		if (getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;
		
		childElement = element.getChildByName(COMMAND, 1);
		if (childElement != null) {
			childElement.setValueV(getCommand());
		}	
		
		childElement = element.getChildByName(CARDHOLDER_NUMBER, 1);
		if (childElement != null) {
			childElement.setValueV(getCardholderNumber());
		}	
		childElement = element.getChildByName(CARDHOLDER_NAME, 1);
		if (childElement != null) {
			childElement.setValueV(getCardholderName());
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
		command = null;
		cardholderNumber = null;
		cardholderName = null;
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public String getCardholderNumber() {
		return cardholderNumber;
	}

	public void setCardholderNumber(String cardholderNumber) {
		this.cardholderNumber = cardholderNumber;
	}

	public String getCardholderName() {
		return cardholderName;
	}

	public void setCardholderName(String cardholderName) {
		this.cardholderName = cardholderName;
	}

	public List<SelectItem> getCommands() {
		return getLov(getObjectAttrs().get("COMMAND"));
	}
}

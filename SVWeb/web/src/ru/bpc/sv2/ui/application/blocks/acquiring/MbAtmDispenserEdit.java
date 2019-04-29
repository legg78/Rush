package ru.bpc.sv2.ui.application.blocks.acquiring;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.atm.AtmDispenser;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbAtmDispenserEdit")
public class MbAtmDispenserEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String DISP_NUMBER = "DISP_NUMBER";
	private static final String FACE_VALUE = "FACE_VALUE";
	private static final String CURRENCY = "CURRENCY";
	private static final String DENOMINATION_ID = "DENOMINATION_ID";
	private static final String DISPENSER_TYPE = "DISPENSER_TYPE";
	private static final String COMMAND = "COMMAND";
	
	private AtmDispenser activeItem;
	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new AtmDispenser());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(DISP_NUMBER, 1);
		if (childElement != null){
			getActiveItem().setDispNumber(childElement.getValueN() != null 
					? childElement.getValueN().shortValue() : null);
			objectAttrs.put(DISP_NUMBER, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(FACE_VALUE, 1);
		if (childElement != null){
			getActiveItem().setFaceValue(childElement.getValueN() != null 
					? childElement.getValueN() : null);
			objectAttrs.put(FACE_VALUE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CURRENCY, 1);
		if (childElement != null){
			getActiveItem().setCurrency(childElement.getValueV());
			objectAttrs.put(CURRENCY, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(DENOMINATION_ID, 1);
		if (childElement != null){
			getActiveItem().setDenominationId(childElement.getValueV());
			objectAttrs.put(DENOMINATION_ID, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(DISPENSER_TYPE, 1);
		if (childElement != null){
			getActiveItem().setDispenserType(childElement.getValueV());
			objectAttrs.put(DISPENSER_TYPE, childElement);
		}	
		
		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null){
			setCommand(childElement.getValueV());
			objectAttrs.put(COMMAND, childElement);
		}
	}

	protected void clear(){
		super.clear();
		command = null;
	}
	
	public void formatObject(ApplicationElement element) {
		if (getActiveItem() == null || getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;
		
		childElement = element.getChildByName(COMMAND, 1);
		if (childElement != null){
			childElement.setValueV(getCommand());
		}
		
		childElement = element.getChildByName(DISP_NUMBER, 1);
		if (childElement != null){
			childElement.setValueN(activeItem.getDispNumber() != null 
					? new BigDecimal(activeItem.getDispNumber()) : null);
		}
		
		childElement = element.getChildByName(FACE_VALUE, 1);
		if (childElement != null){
			childElement.setValueN(activeItem.getFaceValue() != null 
					? activeItem.getFaceValue() : null);
		}
		
		childElement = element.getChildByName(CURRENCY, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getCurrency());
		}
		
		childElement = element.getChildByName(DENOMINATION_ID, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getDenominationId());
		}		
		
		childElement = element.getChildByName(DISPENSER_TYPE, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getDispenserType());
		}	
	}	
	
	protected Logger getLogger(){
		return logger;
	}	

	public AtmDispenser getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(AtmDispenser activeItem) {
		this.activeItem = activeItem;
	}

	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public List<SelectItem> getDispenserTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(DISPENSER_TYPE));
		return result;
	}
	
	public List<SelectItem> getCurrencies(){
		List<SelectItem> result = getLov(objectAttrs.get(CURRENCY));
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

}

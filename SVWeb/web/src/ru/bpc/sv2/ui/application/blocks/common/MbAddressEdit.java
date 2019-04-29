package ru.bpc.sv2.ui.application.blocks.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.Address;
import ru.bpc.sv2.ui.application.ApplicationUtils;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbAddressEdit")
public class MbAddressEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String ADDRESS_TYPE = "ADDRESS_TYPE";
	private static final String COUNTRY = "COUNTRY";
	private static final String HOUSE = "HOUSE";
	private static final String APARTMENT = "APARTMENT";
	private static final String POSTAL_CODE = "POSTAL_CODE";
	private static final String REGION_CODE = "REGION_CODE";
	private static final String ADDRESS_NAME = "ADDRESS_NAME";
	private static final String COMMAND = "COMMAND";
	private static final String REGION = "REGION";
	private static final String CITY = "CITY";
	private static final String STREET = "STREET";
	
	private Address activeItem;
	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Address());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(ADDRESS_TYPE, 1);
		if (childElement != null){
			getActiveItem().setAddressType(childElement.getValueV());
			objectAttrs.put(ADDRESS_TYPE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(COUNTRY, 1);
		if (childElement != null){
			getActiveItem().setCountry(childElement.getValueV());
			objectAttrs.put(COUNTRY, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(HOUSE, 1);
		if (childElement != null){
			getActiveItem().setHouse(childElement.getValueV());
			objectAttrs.put(HOUSE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(APARTMENT, 1);
		if (childElement != null){
			getActiveItem().setApartment(childElement.getValueV());
			objectAttrs.put(APARTMENT, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(POSTAL_CODE, 1);
		if (childElement != null){
			getActiveItem().setPostalCode(childElement.getValueV());
			objectAttrs.put(POSTAL_CODE, childElement);
		}	
		
		childElement = getLocalRootEl().getChildByName(REGION_CODE, 1);
		if (childElement != null){
			getActiveItem().setRegionCode(childElement.getValueV());
			objectAttrs.put(REGION_CODE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null){
			setCommand(childElement.getValueV());
			objectAttrs.put(COMMAND, childElement);
		}
		
		ApplicationElement addrName = getLocalRootEl().getChildByName(ADDRESS_NAME, 1);
		if (addrName != null) {
			objectAttrs.put(ADDRESS_NAME, addrName);
			childElement = addrName.getChildByName(REGION, 1);
			if (childElement != null) {
				getActiveItem().setRegion(childElement.getValueV());
			}
			childElement = addrName.getChildByName(CITY, 1);
			if (childElement != null) {
				getActiveItem().setCity(childElement.getValueV());
			}
			childElement = addrName.getChildByName(STREET, 1);
			if (childElement != null) {
				getActiveItem().setStreet(childElement.getValueV());
			}
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
		
		ApplicationUtils.formatAddressElement(element, activeItem);
	}	
	
	protected Logger getLogger(){
		return logger;
	}	

	public Address getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Object activeItem) {
		this.activeItem = (Address)activeItem;
	}
	
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public List<SelectItem> getAddressTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(ADDRESS_TYPE));
		return result;
	}
	
	public List<SelectItem> getCountries(){
		List<SelectItem> result = getLov(objectAttrs.get(COUNTRY));
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

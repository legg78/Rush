package ru.bpc.sv2.ui.application.blocks.acquiring;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean(name = "mbMerchantEdit")
public class MbMerchantEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String MERCHANT_NUMBER = "MERCHANT_NUMBER";
	private static final String MERCHANT_NAME = "MERCHANT_NAME";
	private static final String MERCHANT_LABEL = "MERCHANT_LABEL";
	private static final String MERCHANT_TYPE = "MERCHANT_TYPE";
	private static final String MCC = "MCC";
	private static final String MERCHANT_STATUS = "MERCHANT_STATUS";
	private static final String MERCHANT_DESC = "MERCHANT_DESC";
	private static final String PARTNER_ID_CODE = "PARTNER_ID_CODE";
	private static final String COMMAND = "COMMAND";
	
	private Merchant activeItem;
	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Merchant());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(MERCHANT_NUMBER, 1);
		if (childElement != null){
			getActiveItem().setMerchantNumber(childElement.getValueV());
			objectAttrs.put(MERCHANT_NUMBER, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(MERCHANT_NAME, 1);
		if (childElement != null){
			getActiveItem().setMerchantName(childElement.getValueV());
			objectAttrs.put(MERCHANT_NAME, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(MERCHANT_LABEL, 1);
		if (childElement != null){
			getActiveItem().setLabel(childElement.getValueV());
			objectAttrs.put(MERCHANT_LABEL, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(MERCHANT_TYPE, 1);
		if (childElement != null){
			getActiveItem().setMerchantType(childElement.getValueV());
			objectAttrs.put(MERCHANT_TYPE, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(MCC, 1);
		if (childElement != null){
			getActiveItem().setMcc(childElement.getValueV());
			objectAttrs.put(MCC, childElement);
		}	
		
		childElement = getLocalRootEl().getChildByName(MERCHANT_STATUS, 1);
		if (childElement != null){
			getActiveItem().setStatus(childElement.getValueV());
			objectAttrs.put(MERCHANT_STATUS, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(MERCHANT_DESC, 1);
		if (childElement != null){
			getActiveItem().setDescription(childElement.getValueV());
			objectAttrs.put(MERCHANT_DESC, childElement);
		}

		childElement = getLocalRootEl().getChildByName(PARTNER_ID_CODE, 1);
		if (childElement != null){
			getActiveItem().setPartnerIdCode(childElement.getValueV());
			objectAttrs.put(PARTNER_ID_CODE, childElement);
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
		
		childElement = element.getChildByName(MERCHANT_NUMBER, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getMerchantNumber());
		}
		
		childElement = element.getChildByName(MERCHANT_NAME, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getMerchantName());
		}
		
		childElement = element.getChildByName(MERCHANT_LABEL, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getLabel());
		}
		
		childElement = element.getChildByName(MERCHANT_TYPE, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getMerchantType());
		}		
		
		childElement = element.getChildByName(MCC, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getMcc());
		}	
		
		childElement = element.getChildByName(MERCHANT_STATUS, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getStatus());
		}
		
		childElement = element.getChildByName(MERCHANT_DESC, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getDescription());
		}

		childElement = element.getChildByName(PARTNER_ID_CODE, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getPartnerIdCode());
		}
	}	
	
	protected Logger getLogger(){
		return logger;
	}	

	public Merchant getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Merchant activeItem) {
		this.activeItem = activeItem;
	}

	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public List<SelectItem> getMccs(){
		List<SelectItem> result = getLov(objectAttrs.get(MCC));
		return result;
	}
	
	public List<SelectItem> getMerchantTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(MERCHANT_TYPE));
		return result;
	}
	
	public List<SelectItem> getMerchantStatuses(){
		List<SelectItem> result = getLov(objectAttrs.get(MERCHANT_STATUS));
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

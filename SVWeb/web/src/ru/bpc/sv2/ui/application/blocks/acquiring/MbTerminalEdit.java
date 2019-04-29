package ru.bpc.sv2.ui.application.blocks.acquiring;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbTerminalEdit")
public class MbTerminalEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String TERMINAL_NUMBER = "TERMINAL_NUMBER";
	private static final String TERMINAL_TYPE = "TERMINAL_TYPE";
	private static final String STANDARD_ID = "STANDARD_ID";
	private static final String VERSION_ID = "VERSION_ID";
	private static final String MCC = "MCC";
	private static final String TERMINAL_TEMPLATE = "TERMINAL_TEMPLATE";
	private static final String PLASTIC_NUMBER = "PLASTIC_NUMBER";
	private static final String CARD_DATA_INPUT_CAP = "CARD_DATA_INPUT_CAP";
	private static final String CRDH_AUTH_CAP = "CRDH_AUTH_CAP";
	private static final String CARD_CAPTURE_CAP = "CARD_CAPTURE_CAP";
	private static final String TERM_OPERATING_ENV = "TERM_OPERATING_ENV";
	private static final String CARD_DATA_PRESENT = "CARD_DATA_PRESENT";
	private static final String CARD_DATA_INPUT_MODE = "CARD_DATA_INPUT_MODE";
	private static final String CRDH_AUTH_METHOD = "CRDH_AUTH_METHOD";
	private static final String CRDH_AUTH_ENTITY = "CRDH_AUTH_ENTITY";
	private static final String CARD_DATA_OUTPUT_CAP = "CARD_DATA_OUTPUT_CAP";
	private static final String TERM_DATA_OUTPUT_CAP = "TERM_DATA_OUTPUT_CAP";
	private static final String PIN_CAPTURE_CAP = "PIN_CAPTURE_CAP";
	private static final String CAT_LEVEL = "CAT_LEVEL";
	private static final String TERMINAL_STATUS = "TERMINAL_STATUS";
	private static final String DEVICE_ID = "DEVICE_ID";
	private static final String GMT_OFFSET = "GMT_OFFSET";
	private static final String IS_MAC = "IS_MAC";
	private static final String TERMINAL_QUANTITY = "TERMINAL_QUANTITY";
	private static final String COMMAND = "COMMAND";
	
	private Terminal activeItem;
	private String command;
	private Integer terminalQuantity;
	private Integer terminalTemplate;
	private Integer versionId;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Terminal());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(TERMINAL_NUMBER, 1);
		if (childElement != null){
			getActiveItem().setTerminalNumber(childElement.getValueV());
			objectAttrs.put(TERMINAL_NUMBER, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(TERMINAL_TYPE, 1);
		if (childElement != null){
			getActiveItem().setTerminalType(childElement.getValueV());
			objectAttrs.put(TERMINAL_TYPE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(STANDARD_ID, 1);
		if (childElement != null){
			getActiveItem().setStandardId(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(STANDARD_ID, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(VERSION_ID, 1);
		if (childElement != null){
			setVersionId(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(VERSION_ID, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(MCC, 1);
		if (childElement != null){
			getActiveItem().setMcc(childElement.getValueV());
			objectAttrs.put(MCC, childElement);
		}	
		
		childElement = getLocalRootEl().getChildByName(TERMINAL_TEMPLATE, 1);
		if (childElement != null){
			setTerminalTemplate(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(TERMINAL_TEMPLATE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(PLASTIC_NUMBER, 1);
		if (childElement != null){
			getActiveItem().setPlasticNumber(childElement.getValueV());
			objectAttrs.put(PLASTIC_NUMBER, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARD_DATA_INPUT_CAP, 1);
		if (childElement != null){
			getActiveItem().setCardDataInputCap(childElement.getValueV());
			objectAttrs.put(CARD_DATA_INPUT_CAP, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CRDH_AUTH_CAP, 1);
		if (childElement != null){
			getActiveItem().setCrdhAuthCap(childElement.getValueV());
			objectAttrs.put(CRDH_AUTH_CAP, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARD_CAPTURE_CAP, 1);
		if (childElement != null){
			getActiveItem().setCardCaptureCap(childElement.getValueV());
			objectAttrs.put(CARD_CAPTURE_CAP, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(TERM_OPERATING_ENV, 1);
		if (childElement != null){
			getActiveItem().setTermOperatingEnv(childElement.getValueV());
			objectAttrs.put(TERM_OPERATING_ENV, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARD_DATA_PRESENT, 1);
		if (childElement != null){
			getActiveItem().setCardDataPresent(childElement.getValueV());
			objectAttrs.put(CARD_DATA_PRESENT, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARD_DATA_INPUT_MODE, 1);
		if (childElement != null){
			getActiveItem().setCardDataInputMode(childElement.getValueV());
			objectAttrs.put(CARD_DATA_INPUT_MODE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CRDH_AUTH_METHOD, 1);
		if (childElement != null){
			getActiveItem().setCrdhAuthMethod(childElement.getValueV());
			objectAttrs.put(CRDH_AUTH_METHOD, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CRDH_AUTH_ENTITY, 1);
		if (childElement != null){
			getActiveItem().setCrdhAuthEntity(childElement.getValueV());
			objectAttrs.put(CRDH_AUTH_ENTITY, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARD_DATA_OUTPUT_CAP, 1);
		if (childElement != null){
			getActiveItem().setCardDataOutputCap(childElement.getValueV());
			objectAttrs.put(CARD_DATA_OUTPUT_CAP, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(TERM_DATA_OUTPUT_CAP, 1);
		if (childElement != null){
			getActiveItem().setTermDataOutputCap(childElement.getValueV());
			objectAttrs.put(TERM_DATA_OUTPUT_CAP, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(PIN_CAPTURE_CAP, 1);
		if (childElement != null){
			getActiveItem().setPinCaptureCap(childElement.getValueV());
			objectAttrs.put(PIN_CAPTURE_CAP, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CAT_LEVEL, 1);
		if (childElement != null){
			getActiveItem().setCatLevel(childElement.getValueV());
			objectAttrs.put(CAT_LEVEL, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(TERMINAL_STATUS, 1);
		if (childElement != null){
			getActiveItem().setStatus(childElement.getValueV());
			objectAttrs.put(TERMINAL_STATUS, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(DEVICE_ID, 1);
		if (childElement != null){
			getActiveItem().setDeviceId(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(DEVICE_ID, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(GMT_OFFSET, 1);
		if (childElement != null){
			getActiveItem().setGmtOffset(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(GMT_OFFSET, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(IS_MAC, 1);
		if (childElement != null){
			getActiveItem().setIsMac(childElement.getValueN() != null && childElement.getValueN().intValue() == 1 ? true : false);
			objectAttrs.put(IS_MAC, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(TERMINAL_QUANTITY, 1);
		if (childElement != null){
			setTerminalQuantity(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			objectAttrs.put(TERMINAL_QUANTITY, childElement);
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
		
		childElement = element.getChildByName(TERMINAL_NUMBER, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getTerminalNumber());
		}
		
		childElement = element.getChildByName(TERMINAL_TYPE, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getTerminalType());
		}
		
		childElement = element.getChildByName(STANDARD_ID, 1);
		if (childElement != null){
			childElement.setValueN(activeItem.getStandardId() != null ? new BigDecimal(activeItem
					.getStandardId()) : null);
		}
		
		childElement = element.getChildByName(VERSION_ID, 1);
		if (childElement != null){
			childElement.setValueN(getVersionId() != null ? new BigDecimal(getVersionId()) : null);
		}		
		
		childElement = element.getChildByName(MCC, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getMcc());
		}	
		
		childElement = element.getChildByName(TERMINAL_TEMPLATE, 1);
		if (childElement != null){
			childElement.setValueN(getTerminalTemplate() != null ? new BigDecimal(getTerminalTemplate()) : null);
		}
		
		childElement = element.getChildByName(PLASTIC_NUMBER, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getPlasticNumber());
		}
		
		childElement = element.getChildByName(CARD_DATA_INPUT_CAP, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCardDataInputCap());
		}
		
		childElement = element.getChildByName(CRDH_AUTH_CAP, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCrdhAuthCap());
		}
		
		childElement = element.getChildByName(CARD_CAPTURE_CAP, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCardCaptureCap());
		}
		
		childElement = element.getChildByName(TERM_OPERATING_ENV, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getTermOperatingEnv());
		}
		
		childElement = element.getChildByName(CARD_DATA_PRESENT, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCardDataPresent());
		}
		
		childElement = element.getChildByName(CARD_DATA_INPUT_MODE, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCardDataInputMode());
		}
		
		childElement = element.getChildByName(CRDH_AUTH_METHOD, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCrdhAuthMethod());
		}
		
		childElement = element.getChildByName(CRDH_AUTH_ENTITY, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCrdhAuthEntity());
		}
		
		childElement = element.getChildByName(CARD_DATA_OUTPUT_CAP, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCardDataOutputCap());
		}
		
		childElement = element.getChildByName(TERM_DATA_OUTPUT_CAP, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getTermDataOutputCap());
		}
		
		childElement = element.getChildByName(PIN_CAPTURE_CAP, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getPinCaptureCap());
		}
		
		childElement = element.getChildByName(CAT_LEVEL, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getCatLevel());
		}
		
		childElement = element.getChildByName(TERMINAL_STATUS, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getStatus());
		}
		
		childElement = element.getChildByName(DEVICE_ID, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getDeviceId() != null ? new BigDecimal(
					getActiveItem().getDeviceId()) : null);
		}

		childElement = element.getChildByName(GMT_OFFSET, 1);
		if (childElement != null) {
			childElement.setValueN(getActiveItem().getGmtOffset() != null ? new BigDecimal(
					getActiveItem().getGmtOffset()) : null);
		}
		
		childElement = element.getChildByName(IS_MAC, 1);
		if (childElement != null){
			childElement.setValueN(BigDecimal.valueOf(getActiveItem().getIsMac() == true ? 1 : 0));
		}
		
		childElement = element.getChildByName(TERMINAL_QUANTITY, 1);
		if (childElement != null){
			childElement.setValueN(getTerminalQuantity() != null ? new BigDecimal(getTerminalQuantity()) : null);
		}
	}	
	
	protected Logger getLogger(){
		return logger;
	}	

	public Terminal getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Terminal activeItem) {
		this.activeItem = activeItem;
	}

	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}
	
	public List<SelectItem> getVersions(){
		List<SelectItem> result = getLov(objectAttrs.get(VERSION_ID));
		return result;
	}

	public List<SelectItem> getTerminalTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(TERMINAL_TYPE));
		return result;
	}
	
	public List<SelectItem> getStandards(){
		List<SelectItem> result = getLov(objectAttrs.get(STANDARD_ID));
		return result;
	}
	
	public List<SelectItem> getMccs(){
		List<SelectItem> result = getLov(objectAttrs.get(MCC));
		return result;
	}
	
	public List<SelectItem> getTerminalTemplates(){
		List<SelectItem> result = getLov(objectAttrs.get(TERMINAL_TEMPLATE));
		return result;
	}
	
	public List<SelectItem> getCardDataInputCaps(){
		List<SelectItem> result = getLov(objectAttrs.get(CARD_DATA_INPUT_CAP));
		return result;
	}
	
	public List<SelectItem> getCrdhAuthCaps(){
		List<SelectItem> result = getLov(objectAttrs.get(CRDH_AUTH_CAP));
		return result;
	}
	
	public List<SelectItem> getCardCaptureCaps(){
		List<SelectItem> result = getLov(objectAttrs.get(CARD_CAPTURE_CAP));
		return result;
	}
	
	public List<SelectItem> getTermOperatingEnvs(){
		List<SelectItem> result = getLov(objectAttrs.get(TERM_OPERATING_ENV));
		return result;
	}
	
	public List<SelectItem> getCardDataPresents(){
		List<SelectItem> result = getLov(objectAttrs.get(CARD_DATA_PRESENT));
		return result;
	}
	
	public List<SelectItem> getCardDataInputModes(){
		List<SelectItem> result = getLov(objectAttrs.get(CARD_DATA_INPUT_MODE));
		return result;
	}
	
	public List<SelectItem> getCrdhAuthMethods(){
		List<SelectItem> result = getLov(objectAttrs.get(CRDH_AUTH_METHOD));
		return result;
	}
	
	public List<SelectItem> getCrdhAuthEntities(){
		List<SelectItem> result = getLov(objectAttrs.get(CRDH_AUTH_ENTITY));
		return result;
	}
	
	public List<SelectItem> getCardDataOutputCaps(){
		List<SelectItem> result = getLov(objectAttrs.get(CARD_DATA_OUTPUT_CAP));
		return result;
	}
	
	public List<SelectItem> getTermDataOutputCaps(){
		List<SelectItem> result = getLov(objectAttrs.get(TERM_DATA_OUTPUT_CAP));
		return result;
	}
	
	public List<SelectItem> getPinCaptureCaps(){
		List<SelectItem> result = getLov(objectAttrs.get(PIN_CAPTURE_CAP));
		return result;
	}

	public List<SelectItem> getCatLevels(){
		List<SelectItem> result = getLov(objectAttrs.get(CAT_LEVEL));
		return result;
	}
	
	public List<SelectItem> getStatuses(){
		List<SelectItem> result = getLov(objectAttrs.get(TERMINAL_STATUS));
		return result;
	}
	
	public List<SelectItem> getDevices(){
		List<SelectItem> result = getLov(objectAttrs.get(DEVICE_ID));
		return result;
	}
	
	public List<SelectItem> getGmtOffsets(){
		List<SelectItem> result = getLov(objectAttrs.get(GMT_OFFSET));
		return result;
	}
	
	public List<SelectItem> getIsMacs(){
		List<SelectItem> result = getLov(objectAttrs.get(IS_MAC));
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

	public Integer getTerminalQuantity() {
		return terminalQuantity;
	}

	public void setTerminalQuantity(Integer terminalQuantity) {
		this.terminalQuantity = terminalQuantity;
	}

	public Integer getTerminalTemplate() {
		return terminalTemplate;
	}

	public void setTerminalTemplate(Integer terminalTemplate) {
		this.terminalTemplate = terminalTemplate;
	}

	public Integer getVersionId() {
		return versionId;
	}

	public void setVersionId(Integer versionId) {
		this.versionId = versionId;
	}

}

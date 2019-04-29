package ru.bpc.sv2.ui.application.blocks.issuing;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "mbCardEdit")
public class MbCardEdit extends SimpleAppBlock {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private static final String COMMAND = "COMMAND";
	private static final String CARD_NUMBER = "CARD_NUMBER";
	private static final String CARD_TYPE = "CARD_TYPE";
	private static final String CARD_COUNT = "CARD_COUNT";
	private static final String BATCH_CARD_COUNT = "BATCH_CARD_COUNT";
	private static final String CARDHOLDER_NAME = "CARDHOLDER_NAME";
	private static final String CATEGORY = "CATEGORY";
	private static final String START_DATE = "START_DATE";
	private static final String START_DATE_RULE = "START_DATE_RULE";
	private static final String EXPIRATION_DATE = "EXPIRATION_DATE";
	private static final String EXPIRATION_DATE_RULE = "EXPIRATION_DATE_RULE";
	private static final String PERSO_PRIORITY = "PERSO_PRIORITY";
	private static final String PIN_REQUEST = "PIN_REQUEST";
	private static final String PIN_MAILER_REQUEST = "PIN_MAILER_REQUEST";
	private static final String EMBOSSING_REQUEST = "EMBOSSING_REQUEST";
	
	private Card activeItem;
	private String command;
	private Integer cardCount;
	private Integer batchCardCount;
	private Date startDate;
	private String startDateRule;
	private Date expirationDate;
	private String expirationDateRule;
	private String persoPriority;
	private String pinRequest;
	private String pinMailerRequest;
	private String embossingRequest;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Card());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();

		childElement = getLocalRootEl().getChildByName(COMMAND, 1);
		if (childElement != null) {
			setCommand(childElement.getValueV());
			getObjectAttrs().put(COMMAND, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CARD_NUMBER, 1);
		if (childElement != null) {
			activeItem.setCardNumber(childElement.getValueV());
			getObjectAttrs().put(CARD_NUMBER, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(CARD_TYPE, 1);
		if (childElement != null) {
			activeItem.setCardTypeId(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			getObjectAttrs().put(CARD_TYPE, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(CARD_COUNT, 1);
		if (childElement != null) {
			setCardCount(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			getObjectAttrs().put(CARD_COUNT, childElement);
		}

		childElement = getLocalRootEl().getChildByName(BATCH_CARD_COUNT, 1);
		if (childElement != null) {
			setBatchCardCount(childElement.getValueN() != null ? childElement.getValueN().intValue() : null);
			getObjectAttrs().put(BATCH_CARD_COUNT, childElement);
		}

		childElement = getLocalRootEl().getChildByName(CARDHOLDER_NAME, 1);
		if (childElement != null) {
			activeItem.setCardholderName(childElement.getValueV());
			getObjectAttrs().put(CARDHOLDER_NAME, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(CATEGORY, 1);
		if (childElement != null) {
			activeItem.setCategory(childElement.getValueV());
			getObjectAttrs().put(CATEGORY, childElement);
		}	
		
		childElement = getLocalRootEl().getChildByName(START_DATE, 1);
		if (childElement != null) {
			setStartDate(childElement.getValueD());
			getObjectAttrs().put(START_DATE, childElement);
		}	
		
		childElement = getLocalRootEl().getChildByName(START_DATE_RULE, 1);
		if (childElement != null) {
			setStartDateRule(childElement.getValueV());
			getObjectAttrs().put(START_DATE_RULE, childElement);
		}	
		
		childElement = getLocalRootEl().getChildByName(EXPIRATION_DATE, 1);
		if (childElement != null) {
			setExpirationDate(childElement.getValueD());
			getObjectAttrs().put(EXPIRATION_DATE, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(EXPIRATION_DATE_RULE, 1);
		if (childElement != null) {
			setExpirationDateRule(childElement.getValueV());
			getObjectAttrs().put(EXPIRATION_DATE_RULE, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(PERSO_PRIORITY, 1);
		if (childElement != null) {
			setPersoPriority(childElement.getValueV());
			getObjectAttrs().put(PERSO_PRIORITY, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(PIN_REQUEST, 1);
		if (childElement != null) {
			setPinRequest(childElement.getValueV());
			getObjectAttrs().put(PIN_REQUEST, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(PIN_MAILER_REQUEST, 1);
		if (childElement != null) {
			setPinMailerRequest(childElement.getValueV());
			getObjectAttrs().put(PIN_MAILER_REQUEST, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(EMBOSSING_REQUEST, 1);
		if (childElement != null) {
			setEmbossingRequest(childElement.getValueV());
			getObjectAttrs().put(EMBOSSING_REQUEST, childElement);
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
		
		childElement = element.getChildByName(CARD_NUMBER, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getCardNumber());
		}		
		
		childElement = element.getChildByName(CARD_TYPE, 1);
		if (childElement != null) {
			childElement.setValueN(activeItem.getCardTypeId() != null ? new BigDecimal(activeItem
					.getCardTypeId()) : null);
		}
		
		childElement = element.getChildByName(CARD_COUNT, 1);
		if (childElement != null) {
			childElement.setValueN(getCardCount() != null ? new BigDecimal(getCardCount()) : null);
		}

		childElement = element.getChildByName(BATCH_CARD_COUNT, 1);
		if (childElement != null) {
			childElement.setValueN(getBatchCardCount() != null ? new BigDecimal(getBatchCardCount()) : null);
		}
		
		childElement = element.getChildByName(CARDHOLDER_NAME, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getCardholderName());
		}
		
		childElement = element.getChildByName(CATEGORY, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getCategory());
		}
		
		childElement = element.getChildByName(START_DATE, 1);
		if (childElement != null) {
			childElement.setValueD(getStartDate());
		}
		
		childElement = element.getChildByName(START_DATE_RULE, 1);
		if (childElement != null) {
			childElement.setValueV(getStartDateRule());
		}
		
		childElement = element.getChildByName(EXPIRATION_DATE, 1);
		if (childElement != null) {
			childElement.setValueD(getExpirationDate());
		}
		
		childElement = element.getChildByName(EXPIRATION_DATE_RULE, 1);
		if (childElement != null) {
			childElement.setValueV(getExpirationDateRule());
		}
		
		childElement = element.getChildByName(PERSO_PRIORITY, 1);
		if (childElement != null) {
			childElement.setValueV(getPersoPriority());
		}
		
		childElement = element.getChildByName(PIN_REQUEST, 1);
		if (childElement != null) {
			childElement.setValueV(getPinRequest());
		}
		
		childElement = element.getChildByName(PIN_MAILER_REQUEST, 1);
		if (childElement != null) {
			childElement.setValueV(getPinMailerRequest());
		}
		
		childElement = element.getChildByName(EMBOSSING_REQUEST, 1);
		if (childElement != null) {
			childElement.setValueV(getEmbossingRequest());
		}		
	}
	
	@Override
	protected void clear() {
		super.clear();
		setActiveItem(null);
		setCommand(null);
		setCardCount(null);
		setStartDate(null);
		setStartDateRule(null);
		setExpirationDate(null);
		setExpirationDateRule(null);
		setPersoPriority(null);
		setPinRequest(null);
		setPinMailerRequest(null);
		setEmbossingRequest(null);
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}

	public List<SelectItem> getCommands(){
		List<SelectItem> result = getLov(objectAttrs.get(COMMAND));
		return result;
	}
	
	public List<SelectItem> getCardTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(CARD_TYPE));
		return result;
	}	

	public List<SelectItem> getCategories(){
		List<SelectItem> result = getLov(objectAttrs.get(CATEGORY));
		return result;
	}
	
	public List<SelectItem> getStartDateRules(){
		List<SelectItem> result = getLov(objectAttrs.get(START_DATE_RULE));
		return result;
	}
	
	public List<SelectItem> getExpirationDateRules(){
		List<SelectItem> result = getLov(objectAttrs.get(EXPIRATION_DATE_RULE));
		return result;
	}
	
	public List<SelectItem> getPersoPriorities(){
		List<SelectItem> result = getLov(objectAttrs.get(PERSO_PRIORITY));
		return result;
	}
	
	public List<SelectItem> getPinRequests(){
		List<SelectItem> result = getLov(objectAttrs.get(PIN_REQUEST));
		return result;
	}
	
	public List<SelectItem> getPinMailerRequests(){
		List<SelectItem> result = getLov(objectAttrs.get(PIN_MAILER_REQUEST));
		return result;
	}
	
	public List<SelectItem> getEmbossingRequests(){
		List<SelectItem> result = getLov(objectAttrs.get(EMBOSSING_REQUEST));
		return result;
	}	

	public Card getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Card activeItem) {
		this.activeItem = activeItem;
	}

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public Integer getCardCount() {
		return cardCount;
	}

	public void setCardCount(Integer cardCount) {
		this.cardCount = cardCount;
	}

	public Integer getBatchCardCount() {
		return batchCardCount;
	}
	public void setBatchCardCount(Integer batchCardCount) {
		this.batchCardCount = batchCardCount;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getExpirationDate() {
		return expirationDate;
	}

	public void setExpirationDate(Date expirationDate) {
		this.expirationDate = expirationDate;
	}

	public String getStartDateRule() {
		return startDateRule;
	}

	public void setStartDateRule(String startDateRule) {
		this.startDateRule = startDateRule;
	}

	public String getExpirationDateRule() {
		return expirationDateRule;
	}

	public void setExpirationDateRule(String expirationDateRule) {
		this.expirationDateRule = expirationDateRule;
	}

	public String getPersoPriority() {
		return persoPriority;
	}

	public void setPersoPriority(String persoPriority) {
		this.persoPriority = persoPriority;
	}

	public String getPinRequest() {
		return pinRequest;
	}

	public void setPinRequest(String pinRequest) {
		this.pinRequest = pinRequest;
	}

	public String getPinMailerRequest() {
		return pinMailerRequest;
	}

	public void setPinMailerRequest(String pinMailerRequest) {
		this.pinMailerRequest = pinMailerRequest;
	}

	public String getEmbossingRequest() {
		return embossingRequest;
	}

	public void setEmbossingRequest(String embossingRequest) {
		this.embossingRequest = embossingRequest;
	}
	
}

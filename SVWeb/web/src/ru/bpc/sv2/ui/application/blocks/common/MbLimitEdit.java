package ru.bpc.sv2.ui.application.blocks.common;

import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbLimitEdit")
public class MbLimitEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String LIMIT_COUNT_VALUE = "LIMIT_COUNT_VALUE";
	private static final String LIMIT_SUM_VALUE = "LIMIT_SUM_VALUE";
	private static final String CURRENCY = "CURRENCY";
	private static final String START_DATE = "START_DATE";
	private static final String END_DATE = "END_DATE";
	
	private Limit activeItem;
//	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	private Date startDate;
	private Date endDate;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Limit());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(LIMIT_COUNT_VALUE, 1);
		if (childElement != null){
			getActiveItem().setCountLimit(childElement.getValueN() != null 
					? childElement.getValueN().longValue() : null);
			objectAttrs.put(LIMIT_COUNT_VALUE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(LIMIT_SUM_VALUE, 1);
		if (childElement != null){
			getActiveItem().setSumLimit(childElement.getValueN() != null 
					? childElement.getValueN() : null);
			objectAttrs.put(LIMIT_SUM_VALUE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CURRENCY, 1);
		if (childElement != null){
			getActiveItem().setCurrency(childElement.getValueV());
			objectAttrs.put(CURRENCY, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(START_DATE, 1);
		if (childElement != null){
			setStartDate(childElement.getValueD());
			objectAttrs.put(START_DATE, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(END_DATE, 1);
		if (childElement != null){
			setEndDate(childElement.getValueD());
			objectAttrs.put(END_DATE, childElement);
		}	
		
	}

	protected void clear(){
		super.clear();
//		command = null;
	}
	
	public void formatObject(ApplicationElement element) {
		if (getActiveItem() == null || getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;
		
		childElement = element.getChildByName(LIMIT_COUNT_VALUE, 1);
		if (childElement != null){
			childElement.setValueN(getActiveItem().getCountLimit() != null 
					? BigDecimal.valueOf(getActiveItem().getCountLimit()) : null);
		}
		
		childElement = element.getChildByName(LIMIT_SUM_VALUE, 1);
		if (childElement != null){
			childElement.setValueN(getActiveItem().getSumLimit() != null 
					? getActiveItem().getSumLimit() : null);
		}
		
		childElement = element.getChildByName(CURRENCY, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getCurrency());
		}
		
		childElement = element.getChildByName(START_DATE, 1);
		if (childElement != null){
			childElement.setValueD(getStartDate());
		}		
		
		childElement = element.getChildByName(END_DATE, 1);
		if (childElement != null){
			childElement.setValueD(getEndDate());
		}	
	}	
	
	protected Logger getLogger(){
		return logger;
	}	

	public Limit getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Limit activeItem) {
		this.activeItem = activeItem;
	}

	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}
	
	public List<SelectItem> getCurrencies(){
		List<SelectItem> result = getLov(objectAttrs.get(CURRENCY));
		return result;
	}
	
	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

}

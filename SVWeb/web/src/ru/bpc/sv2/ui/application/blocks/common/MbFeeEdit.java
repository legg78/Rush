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
import ru.bpc.sv2.fcl.fees.Fee;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbFeeEdit")
public class MbFeeEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String FEE_RATE_CALC = "FEE_RATE_CALC";
	private static final String FEE_FIXED_VALUE = "FEE_FIXED_VALUE";
	private static final String CURRENCY = "CURRENCY";
	private static final String FEE_PERCENT_VALUE = "FEE_PERCENT_VALUE";
	private static final String START_DATE = "START_DATE";
	private static final String END_DATE = "END_DATE";
	
	private Fee activeItem;
//	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	
	private Integer feeFixedValue;
	private Integer feePercentValue;
	private Date startDate;
	private Date endDate;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Fee());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(FEE_RATE_CALC, 1);
		if (childElement != null){
			getActiveItem().setFeeRateCalc(childElement.getValueV());
			objectAttrs.put(FEE_RATE_CALC, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(FEE_FIXED_VALUE, 1);
		if (childElement != null){
			setFeeFixedValue(childElement.getValueN() != null 
					? childElement.getValueN().intValue() : null);
			objectAttrs.put(FEE_FIXED_VALUE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(FEE_PERCENT_VALUE, 1);
		if (childElement != null){
			setFeePercentValue(childElement.getValueN() != null 
					? childElement.getValueN().intValue() : null);
			objectAttrs.put(FEE_PERCENT_VALUE, childElement);
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
		
		childElement = element.getChildByName(FEE_RATE_CALC, 1);
		if (childElement != null){
			childElement.setValueV(activeItem.getFeeRateCalc());
		}
		
		childElement = element.getChildByName(FEE_FIXED_VALUE, 1);
		if (childElement != null){
			childElement.setValueN(getFeeFixedValue() != null 
					? new BigDecimal(getFeeFixedValue()) : null);
		}
		
		childElement = element.getChildByName(FEE_PERCENT_VALUE, 1);
		if (childElement != null){
			childElement.setValueN(getFeePercentValue() != null 
					? new BigDecimal(getFeePercentValue()) : null);
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

	public Fee getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Fee activeItem) {
		this.activeItem = activeItem;
	}

	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}
	
	public List<SelectItem> getCurrencies(){
		List<SelectItem> result = getLov(objectAttrs.get(CURRENCY));
		return result;
	}
	
	public List<SelectItem> getFeeRateCalcs(){
		List<SelectItem> result = getLov(objectAttrs.get(FEE_RATE_CALC));
		return result;
	}
	
	public Integer getFeeFixedValue() {
		return feeFixedValue;
	}

	public void setFeeFixedValue(Integer feeFixedValue) {
		this.feeFixedValue = feeFixedValue;
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

	public Integer getFeePercentValue() {
		return feePercentValue;
	}

	public void setFeePercentValue(Integer feePercentValue) {
		this.feePercentValue = feePercentValue;
	}

}

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
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbCycleEdit")
public class MbCycleEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String CYCLE_START_DATE = "CYCLE_START_DATE";
	private static final String CYCLE_LENGTH_TYPE = "CYCLE_LENGTH_TYPE";
	private static final String CYCLE_LENGTH = "CYCLE_LENGTH";
	private static final String START_DATE = "START_DATE";
	private static final String END_DATE = "END_DATE";
	
	private Cycle activeItem;
//	private String command;
	private Map<String, ApplicationElement> objectAttrs;
	private Date cycleStartDate;
	private Date startDate;
	private Date endDate;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new Cycle());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(CYCLE_START_DATE, 1);
		if (childElement != null){
			setCycleStartDate(childElement.getValueD());
			objectAttrs.put(CYCLE_START_DATE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CYCLE_LENGTH_TYPE, 1);
		if (childElement != null){
			getActiveItem().setLengthType(childElement.getValueV());
			objectAttrs.put(CYCLE_LENGTH_TYPE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(CYCLE_LENGTH, 1);
		if (childElement != null){
			getActiveItem().setCycleLength(childElement.getValueN() != null 
					? childElement.getValueN().intValue() : null);
			objectAttrs.put(CYCLE_LENGTH, childElement);
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
		
		childElement = element.getChildByName(CYCLE_START_DATE, 1);
		if (childElement != null){
			childElement.setValueD(getCycleStartDate());
		}
		
		childElement = element.getChildByName(CYCLE_LENGTH_TYPE, 1);
		if (childElement != null){
			childElement.setValueV(getActiveItem().getLengthType());
		}
		
		childElement = element.getChildByName(CYCLE_LENGTH, 1);
		if (childElement != null){
			childElement.setValueN(getActiveItem().getCycleLength() != null 
					? new BigDecimal(getActiveItem().getCycleLength()) : null);
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

	public Cycle getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(Cycle activeItem) {
		this.activeItem = activeItem;
	}

	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}
	
	public List<SelectItem> getCycleLengthTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(CYCLE_LENGTH_TYPE));
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

	public Date getCycleStartDate() {
		return cycleStartDate;
	}

	public void setCycleStartDate(Date cycleStartDate) {
		this.cycleStartDate = cycleStartDate;
	}
	
}

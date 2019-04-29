package ru.bpc.sv2.ui.application.blocks.common;

import java.util.Date;
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
@ManagedBean (name = "mbContractEdit")
public class MbContractEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String COMMAND = "COMMAND";
	private static final String CONTRACT_NUMBER = "CONTRACT_NUMBER";
	private static final String START_DATE = "START_DATE";
	private static final String END_DATE = "END_DATE";
	
	private Date startDate;
	private Date endDate;
	private String command;
	private String contractNumber;
	
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
		
		childElement = getLocalRootEl().getChildByName(CONTRACT_NUMBER, 1);
		if (childElement != null) {
			setContractNumber(childElement.getValueV());
			getObjectAttrs().put(CONTRACT_NUMBER, childElement);
		}

		childElement = getLocalRootEl().getChildByName(START_DATE, 1);
		if (childElement != null) {
			setStartDate(childElement.getValueD());
			getObjectAttrs().put(START_DATE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(END_DATE, 1);
		if (childElement != null) {
			setEndDate(childElement.getValueD());
			getObjectAttrs().put(END_DATE, childElement);
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
		
		childElement = element.getChildByName(CONTRACT_NUMBER, 1);
		if (childElement != null) {
			childElement.setValueV(getContractNumber());
		}	
		
		childElement = element.getChildByName(START_DATE, 1);
		if (childElement != null) {
			childElement.setValueD(getStartDate());
		}	
		
		childElement = element.getChildByName(END_DATE, 1);
		if (childElement != null) {
			childElement.setValueD(getEndDate());
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
		startDate = null;
		endDate = null;
		contractNumber = null;
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

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public String getContractNumber() {
		return contractNumber;
	}

	public void setContractNumber(String contractNumber) {
		this.contractNumber = contractNumber;
	}

	public List<SelectItem> getCommands() {
		return getLov(getObjectAttrs().get("COMMAND"));
	}
}

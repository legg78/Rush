package ru.bpc.sv2.ui.application.blocks.common;

import java.math.BigDecimal;
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
@ManagedBean (name = "mbDepartmentEdit")
public class MbDepartmentEdit extends SimpleAppBlock{

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String COMMAND = "COMMAND";
	private static final String NEW_DEPT = "NEW_DEPT";
	private static final String DEPARTMENT_NAME = "DEPARTMENT_NAME";
		
	private String command;
	private Integer newDept;
	private String departmentName;
	
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
		
		childElement = getLocalRootEl().getChildByName(NEW_DEPT, 1);
		if (childElement != null) {
			setNewDept(childElement.getValueN().intValue());
			getObjectAttrs().put(NEW_DEPT, childElement);
		}		
		
		childElement = getLocalRootEl().getChildByName(DEPARTMENT_NAME, 1);
		if (childElement != null) {
			setDepartmentName(childElement.getValueV());
			getObjectAttrs().put(DEPARTMENT_NAME, childElement);
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
		
		childElement = element.getChildByName(NEW_DEPT, 1);
		if (childElement != null) {
			childElement.setValueN(new BigDecimal(getNewDept()));
		}	
		
		childElement = element.getChildByName(DEPARTMENT_NAME, 1);
		if (childElement != null) {
			childElement.setValueV(getDepartmentName());
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

	public String getCommand() {
		return command;
	}

	public void setCommand(String command) {
		this.command = command;
	}

	public Integer getNewDept() {
		return newDept;
	}

	public void setNewDept(Integer newDept) {
		this.newDept = newDept;
	}

	public String getDepartmentName() {
		return departmentName;
	}

	public void setDepartmentName(String departmentName) {
		this.departmentName = departmentName;
	}

	@Override
	protected void clear() {
		super.clear();
		command = null;
		newDept = null;
		departmentName = null;
	}
	
	public List<SelectItem> getCommands(){
		List<SelectItem> result = getLov(objectAttrs.get(COMMAND));
		return result;
	}
	
}

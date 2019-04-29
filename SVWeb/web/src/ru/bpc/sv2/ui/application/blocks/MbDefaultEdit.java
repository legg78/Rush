package ru.bpc.sv2.ui.application.blocks;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean (name = "mbDefaultEdit")
public class MbDefaultEdit extends SimpleAppBlock {
	private static final Logger logger = Logger.getLogger("COMMON");

	private Map<String, ApplicationElement> objectAttrs = new HashMap<String, ApplicationElement>();
	private List<ApplicationElement> objectAttrsList;
	private Map<String,List<SelectItem>> lovMap;

	@Override
	public void parseAppBlock() {
		List<ApplicationElement> elements = getLocalRootEl().getChildren();
		lovMap = new HashMap<String, List<SelectItem>>();
		objectAttrsList = new ArrayList<ApplicationElement>();
		for (ApplicationElement element: elements) {
			if (element.getInnerId() == 0 && element.getContent()) {
				continue;
			}
			objectAttrsList.add(element);
			objectAttrs.put(element.getName(), element);
			List<SelectItem> lovList = getLov(element);
			lovMap.put(element.getName(), lovList);
		}
	}
	@Override
	public void formatObject(ApplicationElement element) {}
	@Override
	protected Logger getLogger() {
		return logger;
	}
	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return  objectAttrs;
	}

	public List<ApplicationElement> getObjectAttrsList(){
		return objectAttrsList;
	}

	public Map<String,List<SelectItem>> getLovMap(){
		return lovMap;
	}

	public boolean isRendered(ApplicationElement element) {
		if (element != null) {
			return (element.getVisible() && element.isSimple());
		}
		return false;
	}
	public boolean isNumeric(ApplicationElement element) {
		if (element != null) {
			return (element.isNumber() && !element.isLovType());
		}
		return false;
	}
	public boolean isNumericList(ApplicationElement element) {
		if (element != null) {
			return (element.isNumber() && element.isLovType());
		}
		return false;
	}
	public boolean isString(ApplicationElement element) {
		if (element != null) {
			return (element.isChar() && !element.isLovType());
		}
		return false;
	}
	public boolean isStringList(ApplicationElement element) {
		if (element != null) {
			return (element.isChar() && element.isLovType());
		}
		return false;
	}
	public boolean isDate(ApplicationElement element) {
		if (element != null) {
			return element.isDate();
		}
		return false;
	}
}

package ru.bpc.sv2.ui.application.blocks.common;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.PersonId;
import ru.bpc.sv2.ui.utils.SimpleAppBlock;

@ViewScoped
@ManagedBean(name = "mbPersonIdEdit")
public class MbPersonIdEdit extends SimpleAppBlock {

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private static final String ID_TYPE = "ID_TYPE";
	private static final String ID_SERIES = "ID_SERIES";
	private static final String ID_NUMBER = "ID_NUMBER";
	private static final String ID_ISSUER = "ID_ISSUER";
	private static final String ID_ISSUE_DATE = "ID_ISSUE_DATE";
	private static final String ID_EXPIRE_DATE = "ID_EXPIRE_DATE";
	
	private PersonId activeItem;
	private Map<String, ApplicationElement> objectAttrs;
	
	@Override
	public void parseAppBlock() {
		setActiveItem(new PersonId());
		ApplicationElement childElement;
		objectAttrs = new HashMap<String, ApplicationElement>();
		
		childElement = getLocalRootEl().getChildByName(ID_TYPE, 1);
		if (childElement != null) {
			activeItem.setIdType(childElement.getValueV());
			getObjectAttrs().put(ID_TYPE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(ID_SERIES, 1);
		if (childElement != null) {
			activeItem.setIdSeries(childElement.getValueV());
			getObjectAttrs().put(ID_SERIES, childElement);
		}

		childElement = getLocalRootEl().getChildByName(ID_NUMBER, 1);
		if (childElement != null) {
			activeItem.setIdNumber(childElement.getValueV());
			getObjectAttrs().put(ID_NUMBER, childElement);
		}

		childElement = getLocalRootEl().getChildByName(ID_ISSUER, 1);
		if (childElement != null) {
			activeItem.setIdIssuer(childElement.getValueV());
			getObjectAttrs().put(ID_ISSUER, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(ID_ISSUE_DATE, 1);
		if (childElement != null) {
			activeItem.setIssueDate(childElement.getValueD());
			getObjectAttrs().put(ID_ISSUE_DATE, childElement);
		}
		
		childElement = getLocalRootEl().getChildByName(ID_EXPIRE_DATE, 1);
		if (childElement != null) {
			activeItem.setExpireDate(childElement.getValueD());
			getObjectAttrs().put(ID_EXPIRE_DATE, childElement);
		}			
	}
	
	@Override
	public void formatObject(ApplicationElement element) {
		if (getActiveItem() == null || getSourceRootEl() == null) {
			return;
		}
		ApplicationElement childElement;
		
		childElement = element.getChildByName(ID_TYPE, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getIdType());
		}	
		
		childElement = element.getChildByName(ID_SERIES, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getIdSeries());
		}	
		
		childElement = element.getChildByName(ID_NUMBER, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getIdNumber());
		}	
		
		childElement = element.getChildByName(ID_ISSUER, 1);
		if (childElement != null) {
			childElement.setValueV(activeItem.getIdIssuer());
		}		
		
		childElement = element.getChildByName(ID_ISSUE_DATE, 1);
		if (childElement != null) {
			childElement.setValueD(activeItem.getIssueDate());
		}	
		
		childElement = element.getChildByName(ID_EXPIRE_DATE, 1);
		if (childElement != null) {
			childElement.setValueD(activeItem.getExpireDate());
		}		
	}

	public Object getActiveItem() {
		return activeItem;
	}

	protected void setActiveItem(Object object) {
		this.activeItem = (PersonId) object;
	}

	@Override
	protected Logger getLogger() {
		return logger;
	}

	@Override
	public Map<String, ApplicationElement> getObjectAttrs() {
		return objectAttrs;
	}
	
	public List<SelectItem> getIdTypes(){
		List<SelectItem> result = getLov(objectAttrs.get(ID_TYPE));
		return result;
	}

	@Override
	protected void clear() {
		super.clear();
		setActiveItem(null);
	}
}

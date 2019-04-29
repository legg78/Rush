package ru.bpc.sv2.ui.utils;

import java.util.ArrayList;
import java.util.List;

import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.utils.KeyLabelItem;

import util.auxil.SessionWrapper;

public abstract class ApplicationBlockBean {
	private static Logger commonlogger = Logger.getLogger("COMMON");
	
	protected String beanEntityType;
	
	protected String curLang;
	protected String userLang;
	protected Long userSessionId = null;
	protected final Integer userInstId;
	
	public ApplicationBlockBean() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = userLang = SessionWrapper.getField("language");
		userInstId = (Integer) SessionWrapper.getObjectField("defaultInst");	
	}
	
    protected String getCurLang() {
		return curLang;
	}

    protected void setCurLang(String curLang) {
		this.curLang = curLang;
	}
	
    abstract public void parseAppBlock();
    
    abstract public void formatObject();
    
    abstract public void init();
    
    protected List<SelectItem> getLov(ApplicationElement el) {
		if (el == null || el.getLovId() == null) {
        	return new ArrayList<SelectItem>(0);
        }
		List<SelectItem> siList = null;
		try {
			siList = new ArrayList<SelectItem>(el.getLov().length);
			for (int i=0; i<el.getLov().length;i++)
			{
				KeyLabelItem item = el.getLov()[i];
				SelectItem si = new SelectItem(item.getValue(),item.getLabel());
				siList.add(si);
			}
		} catch (Exception e) {
			commonlogger.error("", e);
		} finally {
			if (siList == null) {
				siList = new ArrayList<SelectItem>(0);
			}
		}
        return siList;
    } 
}

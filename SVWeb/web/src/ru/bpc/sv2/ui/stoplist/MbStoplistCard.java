package ru.bpc.sv2.ui.stoplist;

import java.io.Serializable;

import ru.bpc.sv2.stoplist.StoplistCardEntry;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbStoplistCard")
public class MbStoplistCard implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private StoplistCardEntry stoplistCardEntry;
	private String tabName;
	
	private String backLink;
	private boolean _modalMode = false;
	private boolean managingNew;
	private boolean searching;

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void save() {
    	try {
    		//TODO invoke appropriate dao methods
    		if (!managingNew) {
//    			_processDao.updateProcess( userSessionId, stoplistCardEntry);
    		} else {
//    			_processDao.createProcess( userSessionId, stoplistCardEntry);
    		}
    		MbStoplistCardSearch stoplistSearchBean = (MbStoplistCardSearch)ManagedBeanWrapper.getManagedBean("MbStoplistCardSearch");
    		stoplistSearchBean.getStoplistEntries().flushCache();    		
    	} catch (Exception e) {
    		FacesUtils.addMessageError(e);
    	}
    }

	public void cancel()
	{
		MbStoplistCardSearch stoplistSearchBean = (MbStoplistCardSearch)ManagedBeanWrapper.getManagedBean("MbStoplistCardSearch");
		stoplistSearchBean.setActiveEntry(null);
		stoplistCardEntry = null;
	}
	
	public boolean isModalMode() {
		return _modalMode;
	}

	public void setModalMode(boolean modalMode) {
		_modalMode = modalMode;
	}
	
	public StoplistCardEntry getStoplistCardEntry() {
		if (stoplistCardEntry == null)
			stoplistCardEntry = new StoplistCardEntry();
		return stoplistCardEntry;
	}

	public void setStoplistCardEntry(StoplistCardEntry stoplistCardEntry) {
		this.stoplistCardEntry = stoplistCardEntry;
	}

	public boolean isManagingNew() {
		return managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		this.managingNew = managingNew;
	}
	

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	
	public void create() {
		managingNew = true;
		stoplistCardEntry = new StoplistCardEntry();
	}
	
	public void edit() {
		managingNew = false;
	}	
}

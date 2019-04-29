package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationHistory;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.ui.application.MbApplicationErrorsSearch;
import ru.bpc.sv2.ui.application.MbApplicationHistory;
import ru.bpc.sv2.ui.application.MbApplicationLinkedObjects;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.process.monitoring.MbProcessTrace;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbApplicationsContextSearch")
public class MbApplicationsContextSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	
	private Long id;
	protected String tabName;
	private Application app;
	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	
	private ApplicationDao _applicationDao = new ApplicationDao();
	
	public MbApplicationsContextSearch(){
		
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Application getActiveApp() {
		return getApplication();
	}
	
	public Application getApplication(){
		try {
			if (app == null && id != null) {
				List<Filter> filters = new ArrayList<Filter>(2);
				filters.add(Filter.create("id", id));
				filters.add(Filter.create("lang", curLang));
				SelectionParams params = new SelectionParams();
				params.setFilters(filters);
				List<Application> apps = _applicationDao.getApplications(userSessionId, params);
				if (apps != null && apps.size() > 0) {
					app = apps.get(0);
				}
				loadedTabs.clear();
			}
			return app;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbInstitutionDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils
					.getSessionMapValue(CTX_MENU_PARAMS);
			FacesUtils.setSessionMapValue(CTX_MENU_PARAMS, null);
			if (ctxMenuParams.containsKey(OBJECT_ID)){
				id = (Long) ctxMenuParams.get(OBJECT_ID);
			} 
		} else {
			if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
				id = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
//				FacesUtils.setSessionMapValue(OBJECT_ID, null);
			}	
		}
		if (id == null){
			objectIdIsNotSet();
		}
		getActiveApp();
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	

	public void reset(){
		app = null;
		id = null;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public String getTabName() {
		return tabName;
	}
	
	public void loadCurrentTab() {
		
		Boolean isLoadedCurrentTab = loadedTabs.get(getTabName());

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}
		loadTab(getTabName());
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (app == null || app.getId() == null) {
			return;
		}
		if (tab.equalsIgnoreCase("errorsContextTab")) {
			MbApplicationErrorsSearch errorsBean = (MbApplicationErrorsSearch) ManagedBeanWrapper
					.getManagedBean("MbApplicationErrorsContextSearch");
			ApplicationElement filter = new ApplicationElement();
			filter.setAppId(app.getId());
			errorsBean.setFilter(filter);
			errorsBean.search();
		} else if (tab.equalsIgnoreCase("notesContextTab")){
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.APPLICATION);
			filterNote.setObjectId(app.getId());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("historyContextTab")){
			MbApplicationHistory mbApplicationHistory = (MbApplicationHistory) ManagedBeanWrapper
					.getManagedBean("MbApplicationHistoryContext");
			ApplicationHistory applicationHistory = new ApplicationHistory();
			applicationHistory.setApplId(app.getId());
			mbApplicationHistory.setFilter(applicationHistory);
			mbApplicationHistory.search();
		} else if (tab.equalsIgnoreCase("traceContextTab")){
			MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper.getManagedBean("MbProcessTraceContext");
			traceBean.clearBean();
			ProcessTrace filterTrace = new ProcessTrace();
			filterTrace.setEntityType(EntityNames.APPLICATION);
			filterTrace.setObjectId(app.getId());
			traceBean.setFilter(filterTrace);
			traceBean.search();
		} else if(tab.equalsIgnoreCase("linkedObjectsContextTab")){
			MbApplicationLinkedObjects mbApplicationLinkedObjects = ManagedBeanWrapper.getManagedBean(MbApplicationLinkedObjects.class);
			mbApplicationLinkedObjects.getFilter().setApplId(app.getId());
			mbApplicationLinkedObjects.search();
		}
		loadedTabs.put(tab, Boolean.TRUE);
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}

package ru.bpc.sv2.ui.utils;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.component.ExtendedDataTableState;
import org.richfaces.component.UIColumn;
import org.richfaces.component.UIExtendedDataTable;
import org.richfaces.model.Ordering;
import ru.bpc.jsf.ComponentReference;
import ru.bpc.sv2.acm.ComponentState;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.filters.SectionFilter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.session.StoreFilter;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;
import java.io.IOException;
import java.io.Serializable;
import java.lang.annotation.Annotation;
import java.security.Principal;
import java.util.*;

public abstract class AbstractBean implements Serializable {
	private static final long serialVersionUID = 1L;
	private static Logger commonLogger = Logger.getLogger("COM");

	protected SettingsDao settingsDao = new SettingsDao();

	private AccessManagementDao _acmDao = new AccessManagementDao();

	// <navigation-case> from "<!-- MENU NAVIGATION -->" section of faces-config.xml
	protected String thisBackLink = "";

	protected boolean directAccess = true;	// was page accessed directly (from menu, URL or favorites)
	protected String pageName;
	protected String previousPageName;

	protected Boolean restoreBean = false;	// bean's restore flag; indicates whether bean should 
											// restore its state from session bean (if it has one) or not 

	public static final int UNKNOWN_MODE = 0;
	public static final int VIEW_MODE = 1;
	public static final int EDIT_MODE = 2;
	public static final int REMOVE_MODE = 3;
	public static final int NEW_MODE = 4;
	public static final int PROCESS_MODE = 5;
	public static final int APPROVE_MODE = 6;
	public static final int TRANSL_MODE = 8;
	public static final int CREATE_ADD_MODE = 16;
	public static final long BYTES_IN_MB = 1048576;

	protected String beanEntityType;

	protected int curMode;
	protected String curLang;
	protected String userLang;
	protected List<Filter> filters;
	protected boolean searching;
	protected Integer forceSearch = 0;
	protected boolean forceDelete = false;
	protected Long userSessionId = null;
	protected final Integer userInstId;
	protected final Integer userAgentId;
	protected int rowsNum = 20;
	protected int pageNumber = 1;
	protected boolean renderTabs = false;
	//section filters objects
	protected Integer selectedSectionFilter;
	protected boolean searchAutomatically;
	protected SectionFilter sectionFilter;
	protected boolean sectionFilterModeEdit;
	protected String tableState;
	protected String tabsState;
	protected boolean tableStateLookedDB;
	protected boolean tabsStateLookedDB;
	protected Boolean showAllTabs;
	protected List<SelectItem> languages = null;
	private transient DictUtils dictUtils;
	protected String pageLink = "";
	private String queue;
	private StoreFilter storeFilter;
	protected ComponentReference<UIExtendedDataTable> tableReference;
	protected String newTableState;

	protected Map<String, Object> params;
	protected Set<String> excludedIds;

	public AbstractBean() {
		String idStr = SessionWrapper.getUserSessionIdStr();
		userSessionId = idStr != null ? Long.parseLong(idStr) : null;
		curLang = userLang = SessionWrapper.getField("language");
		userInstId = (Integer) SessionWrapper.getObjectField("defaultInst");
		userAgentId = (Integer) SessionWrapper.getObjectField("defaultAgent");
		curMode = VIEW_MODE;
		searchAutomatically = true;
	}

    @SuppressWarnings("UnusedDeclaration")
    private boolean isRequestScopedBean() {
        for (Annotation annotation : this.getClass().getAnnotations()) {
            if (annotation.annotationType().equals(RequestScoped.class)) {
                return true;
            }
        }
        return false;
    }

	@SuppressWarnings("UnusedDeclaration")
    private String getBeanName() {
        for (Annotation annotation : this.getClass().getAnnotations()) {
            if (annotation.annotationType().equals(ManagedBean.class)) {
                ManagedBean a = (ManagedBean) annotation;
                return a.name();
            }
        }
        return null;
    }


    /**
	 * @return <code>true</code> - if page was accessed directly (e.g. from menu
	 *         or url), <code>false</code> - if it was accessed from other page
	 *         for that page's needs (e.g. select some object and return).
	 */
	public boolean isDirectAccess() {
		return directAccess;
	}

	/**
	 * <p>
	 * Set <code>directAccess</code> to <code>false</code> to prevent selection
	 * of menu section for loading page and add current page to bread crumbs.
	 * </p>
	 * 
	 * @param directAccess flag
	 */
	public void setDirectAccess(boolean directAccess) {
		this.directAccess = directAccess;
	}

	public boolean isMenuNode() {
		if (restoreBean) return false;
		
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (directAccess) {
			pageName = menu.selectNode(thisBackLink);
		} else {
			menu.addPageToRoute(previousPageName);
		}
		return pageName != null;
	}
	
	public String getPageName() {
		return pageName;
	}

	public void setPageName(String pageName) {
		this.pageName = pageName;
	}

	@SuppressWarnings("UnusedDeclaration")
	public String getPreviousPageName() {
		return previousPageName;
	}

	public void setPreviousPageName(String previousPageName) {
		this.previousPageName = previousPageName;
	}

	protected int removeLastPageFromRoute() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		return menu.removeLastPageFromRoute();
	}

    protected void log(Object object) {
        String methodName = Thread.currentThread().getStackTrace()[2].getMethodName();
        System.out.println(this.getClass() + " " + methodName + ": " + object);
    }

	public List<Filter> getFilters() {
		return filters;
	}

	public void setFilters(List<Filter> filters) {
		this.filters = filters;
	}

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public Integer getForceSearch() {
		return forceSearch;
	}

	public void setForceSearch(Integer forceSearch) {
		this.forceSearch = forceSearch;
	}

	public boolean isForceDelete() {
		return forceDelete;
	}

	public void setForceDelete(boolean forceDelete) {
		this.forceDelete = forceDelete;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void setCurMode(int mode) {
		curMode = mode;
	}

	public boolean isViewMode() {
		return (curMode == VIEW_MODE);
	}

	public boolean isEditMode() {
		return (curMode == EDIT_MODE);
	}

	public boolean isRemoveMode() {
		return (curMode == REMOVE_MODE);
	}

	public boolean isNewMode() {
		return (curMode == NEW_MODE);
	}

	public boolean isTranslMode() {
		return (curMode == TRANSL_MODE);
	}

	public boolean isCreateAddMode() {
		return (curMode == CREATE_ADD_MODE);
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

	@SuppressWarnings("UnusedDeclaration")
	public void setSectionFilter() {
		try {
			if (selectedSectionFilter != null) {
				applySectionFilter(selectedSectionFilter);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);			
		} 
	}
	
	public Integer getSelectedSectionFilter() {
		return selectedSectionFilter;
	}

	public void setSelectedSectionFilter(Integer selectedSectionFilter) {
		this.selectedSectionFilter = selectedSectionFilter;
	}

	public boolean isSearchAutomatically() {
		return searchAutomatically;
	}

	public void setSearchAutomatically(boolean searchAutomatically) {
		this.searchAutomatically = searchAutomatically;
	}

	public SectionFilter getSectionFilter() {
		if (sectionFilter == null) {
			sectionFilter = new SectionFilter();
		}
		return sectionFilter;
	}

	public void setSectionFilter(SectionFilter sectionFilter) {
		this.sectionFilter = sectionFilter;
	}
	
	public boolean isSectionFilterModeEdit() {
		return sectionFilterModeEdit;
	}
	
	public void setSectionFilterModeEdit(boolean sectionFilterModeEdit) {
		this.sectionFilterModeEdit = sectionFilterModeEdit;
	}
	
	protected void applySectionFilter(Integer filterId){
		
	}
	
	public void saveSectionFilter(){
		
	}
	
	public void clearSectionFilter() {
		selectedSectionFilter = null;
		searchAutomatically = false;
		sectionFilter = null;
		sectionFilterModeEdit = false;
	}
	
	public void setTableState(String tableState) {
		this.newTableState = tableState;
	}

	
	public String getSateFromDB(String componentId) {
		String state = null;
		
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("componentId");
		filters[0].setValue(componentId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ComponentState[] items = _acmDao.getComponentStates(userSessionId, params);
			if (items != null && items.length > 0) {
				state = items[0].getState();				
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			Logger logger = getLogger();
			logger.error("", e);
		}
		return state;
	}
	
	public void saveStateDB(String componentId, String state) {
		ComponentState componentState = new ComponentState();
		componentState.setComponentId(componentId);
		componentState.setState(state);
		try {
			_acmDao.addComponentState(userSessionId, componentState);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			Logger logger = getLogger();
			logger.error("", e);
		}
	}
	
	public void deleteStateDB(String componentId) {
		ComponentState componentState = new ComponentState();
		componentState.setComponentId(componentId);
		try {
			_acmDao.removeComponentState(userSessionId, componentState);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			Logger logger = getLogger();
			logger.error("", e);
		}
	}
	
	public String getTableState() {
		if (tableState == null && !tableStateLookedDB) {			
			tableState = getSateFromDB(getComponentId());
			tableStateLookedDB = true;
			if(tableState == null){
				resetTableState();
			}
		}
		return tableState;
	}
	
	public UIExtendedDataTable getTable() {  
		return tableReference != null ? tableReference.getComponent() : null;
	}  
	  
	 /** 
	 * @param table the table to set 
	 */  
	
	public void setTable( UIExtendedDataTable table ) {  
		this.tableReference = ComponentReference.newUIComponentReference(table);
	}
	 
	public void resetTableState() {
		UIExtendedDataTable table = getTable();
		if (table == null)
			return;
		for (Iterator<UIColumn> iter = table.getChildColumns(); iter.hasNext(); ) {
		  UIColumn col = iter.next();
		  col.setVisible(true);
		 }
		tableState = null;
		tableState = ExtendedDataTableState.getExtendedDataTableState(table).toString();
		table.resetState();
	}

	public void saveTableStateDB() {
		saveStateDB(getComponentId(), newTableState);
		tableState = newTableState;
	}
	
	public void deleteTableStateDB() {
		deleteStateDB(getComponentId());
		resetTableState();
	}

	public void setTabsState(String tabsState) {
		this.tabsState = tabsState;
	}

	public String getTabsState() {
		if (tabsState == null && !tabsStateLookedDB) {
			tabsState = getSateFromDB(getTabComponentId());
			tabsStateLookedDB = true;					
		}
		return tabsState;
	}
	
	public void saveTabsStateDB() {
		saveStateDB(getTabComponentId(), tabsState);
	}

	public void deleteTabsStateDB() {
		deleteStateDB(getTabComponentId());
	}

	protected String getComponentId() {
		return null;
	}
	
	protected String getTabComponentId() {
		return null;
	}

	protected Logger getLogger() {
		commonLogger.error(
				"AbstractBean.getLogger is called, but it's not overriden in descendant class. " +
				"Using common logger as a fallback");
		return commonLogger;
	}

	/**
	 * Prepare WS endpoint like "10.7.1.127:3361"
	 *
	 * @param wsPortEntryName Name of entry is saved in DB settings. List of avaliable names is contained in SettingsConstants. For example it may be SettingsConstants.UPDATE_CACHE_WS_PORT.
	 */
	protected String prepareFeLocation(String wsPortEntryName) throws IOException{
		String feLocation = settingsDao.getParameterValueV(userSessionId,
				SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM, null);
		if (feLocation == null || feLocation.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
			throw new IOException(msg);
		}
		Double wsPort = settingsDao.getParameterValueN(userSessionId,
				wsPortEntryName, LevelNames.SYSTEM, null);
		if (wsPort == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					wsPortEntryName);
			throw new IOException(msg);
		}
		feLocation = feLocation + ":" + wsPort.intValue();
		return feLocation;
	}

	public boolean isRenderTabs() {
		return renderTabs;
	}

	public void setRenderTabs(boolean renderTabs) {
		this.renderTabs = renderTabs;
	}

	public boolean isShowAllTabs() {
		if (showAllTabs == null) {
			showAllTabs = getTabsState() == null;
		}
		return showAllTabs;
	}

	public void setShowAllTabs(boolean showAllTabs) {
		this.showAllTabs = showAllTabs;
	}
	
	public List<Object> getEmptyTable() {
		List<Object> arr = new ArrayList<Object>(1);
		arr.add(new Object());
		return arr;
	}

	/**
	 * Resets all filters to their default values, clears search results for
	 * current bean and all dependent beans
	 */
	abstract public void clearFilter();

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
	
	public List<SelectItem> getLanguages() {
		if (languages == null) {
			languages = getDictUtils().getLov(LovConstants.LANGUAGES);
		}
		return sortLanguages(languages);
	}

    public ArrayList<SelectItem> sortLanguages(List<SelectItem> languages){
        ArrayList<SelectItem> newlistLangs = new ArrayList<SelectItem>();
        String userLang = getUserLang();
        for(SelectItem lang : languages){
            if (lang.getValue().equals(userLang)){
                newlistLangs.add(0, lang);
            } else {
                newlistLangs.add(lang);
            }
        }
        return newlistLangs;
    }

	public void activate(){

	}
	
	public StoreFilter getStoreFilter(){
		if(storeFilter == null){
			storeFilter = (StoreFilter) ManagedBeanWrapper.getManagedBean("StoreFilter");
		}
		return storeFilter;
	}

	public String getQueue(String bean) {
		if (queue == null || queue.equals("")) {
			StoreFilter storeFilter = getStoreFilter();
			queue = storeFilter.getKeyQueue(bean);
		}
		return queue;
	}

	public void setQueue(String queue) {
		this.queue = queue;
	}
	
	public HashMap<String,Object> getQueueFilter(String bean){
		StoreFilter storeFilter = getStoreFilter();
		String queue = getQueue(bean);
		return storeFilter.getFilter(queue, bean);
		
	}
	
	public void addFilterToQueue(String bean, HashMap<String,Object> queueFilter){
		getStoreFilter().addFilter(getQueue(bean), bean, queueFilter);
	}
	
	 public void setFilterMap(Map<String, Object> params) {
			this.params = params;
	}

    public String getUserLang(){
        if (userLang == null){
            userLang = SessionWrapper.getField("language");
        }
        return  userLang;
    }

    public void setUserLang(String userLang){
        this.userLang = userLang;
    }

	public String getUserName() {
		Principal userPrincipal = FacesContext.getCurrentInstance().getExternalContext().getUserPrincipal();
		return userPrincipal != null ? userPrincipal.getName() : null;
	}

	public void onSortablePreRenderTable(DaoDataModel dataModel) {
		if (dataModel == null) return;
		int maxRowCount = DaoDataModel.getSortableMaxRowCount();
		if (dataModel.getRowCount() <= maxRowCount || isExcludedColumns()) return;

		boolean needMessage = false;
		UIExtendedDataTable table = getTable();

		if (table == null) return;
		for (Iterator<UIColumn> iterator = table.getChildColumns(); iterator.hasNext(); ) {
			UIColumn column = iterator.next();
			if (column.getSortOrder() != Ordering.UNSORTED) {
				column.setSortOrder(Ordering.UNSORTED);
				needMessage = true;
			}
		}
		if (needMessage) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
											   "max_search_message", maxRowCount, dataModel.getRowCount());
			FacesUtils.addMessageError(msg);
		}
	}

	public String getAcceptedFileTypes(String customListString) {
		List<String> customList = new ArrayList<String>();
		if (StringUtils.isNotBlank(customListString)) {
			customList = new ArrayList<String>(Arrays.asList(customListString.split(",")));
			for (int i = 0; i < customList.size(); i++) {
				customList.set(i, customList.get(i).trim().toLowerCase());
			}
		}

		String systemListString = null;
		try {
			if (settingsDao != null) {
				systemListString = settingsDao.getParameterValueV(userSessionId,
																  SettingsConstants.ALLOWED_UPLOAD_FILE_TYPES,
																  LevelNames.SYSTEM,
																  null);
			}
		} catch (Exception e) {
			getLogger().warn("Failed to get '" + SettingsConstants.ALLOWED_UPLOAD_FILE_TYPES + "' parameter");
		}

		if (StringUtils.isNotBlank(systemListString)) {
			List<String> systemList = new ArrayList<String>(Arrays.asList(systemListString.split(",")));
			for (int i = 0; i < systemList.size(); i++) {
				systemList.set(i, systemList.get(i).trim().toLowerCase());
			}
			systemList.retainAll(customList);

			if (!systemList.isEmpty()) {
				StringBuilder out = new StringBuilder();
				for (String ext : systemList) {
					out.append(ext);
					out.append(", ");
				}
				return out.toString().substring(0, out.lastIndexOf(", "));
			} else {
				return "";
			}
		} else {
			return customListString;
		}
	}

	public boolean checkMaximumFileSize(long input) {
		try {
			if (settingsDao != null && input > 0) {
				Double size = settingsDao.getParameterValueN(userSessionId,
															 SettingsConstants.MAX_UPLOAD_FILE_SIZE,
															 LevelNames.SYSTEM,
															 null);
				if (size != null && size.longValue() > 0) {
					return (size.longValue() * BYTES_IN_MB) >= input;
				}
			}
		} catch (Exception e) {
			getLogger().warn("Failed to check maximum file length parameter");
		}
		return true;
	}

	public boolean isExcludedColumns() {
    	if (excludedIds == null) return false;
    	UIExtendedDataTable table = getTable();
    	if (table == null) return false;
		for (Iterator<UIColumn> iterator = table.getChildColumns(); iterator.hasNext(); ) {
			UIColumn column = iterator.next();
			if (column.getSortOrder() != Ordering.UNSORTED && !excludedIds.contains(column.getId())) {
				return false;
			}
		}
		return true;
	}
}

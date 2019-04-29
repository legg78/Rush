package ru.bpc.sv2.ui.acquiring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acquiring.AccountScheme;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbAccountSchemes")
public class MbAccountSchemes extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private static String COMPONENT_ID = "1699:accountSchemesTable";

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private AccountScheme filter;
	private AccountScheme newAccountScheme;
	private AccountScheme detailAccountScheme;

	private final DaoDataModel<AccountScheme> _accountSchemesSource;
	private final TableRowSelection<AccountScheme> _itemSelection;
	private AccountScheme _activeAccountScheme;

	private String tabName;
	private ArrayList<SelectItem> institutions;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	public MbAccountSchemes() {
		pageLink = "acquiring|accSchemes";
		tabName = "detailsTab";

		_accountSchemesSource = new DaoDataModel<AccountScheme>() {
			@Override
			protected AccountScheme[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AccountScheme[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getAccountSchemes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new AccountScheme[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getAccountSchemesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<AccountScheme>(null, _accountSchemesSource);
	}

	public DaoDataModel<AccountScheme> getAccountSchemes() {
		return _accountSchemesSource;
	}

	public AccountScheme getActiveAccountScheme() {
		return _activeAccountScheme;
	}

	public void setActiveAccountScheme(AccountScheme activeAccountScheme) {
		_activeAccountScheme = activeAccountScheme;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAccountScheme == null && _accountSchemesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAccountScheme != null && _accountSchemesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAccountScheme.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAccountScheme = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeAccountScheme.getId())) {
				changeSelect = true;
			}
			_activeAccountScheme = _itemSelection.getSingleSelection();
	
			if (_activeAccountScheme != null) {
				setBeans();
				if (changeSelect) {
					detailAccountScheme = (AccountScheme) _activeAccountScheme.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_accountSchemesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAccountScheme = (AccountScheme) _accountSchemesSource.getRowData();
		selection.addKey(_activeAccountScheme.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
		detailAccountScheme = (AccountScheme) _activeAccountScheme.clone();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
		curLang = _activeAccountScheme.getLang();
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
	}

	public AccountScheme getFilter() {
		if (filter == null) {
			filter = new AccountScheme();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(AccountScheme filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newAccountScheme = new AccountScheme();
		if (getFilter().getInstId() != null) {
			newAccountScheme.setInstId(filter.getInstId());
		}
		newAccountScheme.setLang(userLang);
		curLang = newAccountScheme.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newAccountScheme = (AccountScheme) detailAccountScheme.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_acquiringDao.removeAccountScheme(userSessionId, _activeAccountScheme);

			_activeAccountScheme = _itemSelection.removeObjectFromList(_activeAccountScheme);
			if (_activeAccountScheme == null) {
				clearBean();
			} else {
				setBeans();
				detailAccountScheme = (AccountScheme) _activeAccountScheme.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newAccountScheme = _acquiringDao.addAccountScheme(userSessionId, newAccountScheme);
				detailAccountScheme = (AccountScheme) newAccountScheme.clone();
				_itemSelection.addNewObjectToList(newAccountScheme);
			} else {
				newAccountScheme = _acquiringDao.modifyAccountScheme(userSessionId,
						newAccountScheme);
				detailAccountScheme = (AccountScheme) newAccountScheme.clone();
				if (!userLang.equals(newAccountScheme.getLang())) {
					newAccountScheme = getNodeByLang(_activeAccountScheme.getId(), userLang);
				}
				_accountSchemesSource.replaceObject(_activeAccountScheme, newAccountScheme);
			}
			_activeAccountScheme = newAccountScheme;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public AccountScheme getNewAccountScheme() {
		if (newAccountScheme == null) {
			newAccountScheme = new AccountScheme();
		}
		return newAccountScheme;
	}

	public void setNewAccountScheme(AccountScheme newAccountScheme) {
		this.newAccountScheme = newAccountScheme;
	}

	public void clearBean() {
		curLang = userLang;
		_accountSchemesSource.flushCache();
		_itemSelection.clearSelection();
		_activeAccountScheme = null;
		detailAccountScheme = null;
		loadedTabs.clear();
		
		clearBeans();
	}

	private void clearBeans() {
		MbAccountPatterns patterns = (MbAccountPatterns) ManagedBeanWrapper
				.getManagedBean("MbAccountPatterns");
		patterns.setFilter(null);
		patterns.clearBean();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
		
		if (tabName.equalsIgnoreCase("patternsTab")) {
			MbAccountPatterns bean = (MbAccountPatterns) ManagedBeanWrapper
					.getManagedBean("MbAccountPatterns");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_CONFIG_SCHEME;
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeAccountScheme == null || _activeAccountScheme.getId() == null) {
			needRerender = tab;
			loadedTabs.put(tab, Boolean.TRUE);

			return;
		}

		if (tab.equalsIgnoreCase("patternsTab")) {
			MbAccountPatterns patterns = (MbAccountPatterns) ManagedBeanWrapper
					.getManagedBean("MbAccountPatterns");
			patterns.setFilter(null);
			patterns.getFilter().setSchemeId(_activeAccountScheme.getId());
			patterns.getFilter().setSchemeName(_activeAccountScheme.getLabel());
			patterns.search();
		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailAccountScheme = getNodeByLang(detailAccountScheme.getId(), curLang);
	}
	
	public AccountScheme getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(String.valueOf(id));
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			AccountScheme[] types = _acquiringDao.getAccountSchemes(userSessionId, params);
			if (types != null && types.length > 0) {
				return types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void confirmEditLanguage() {
		curLang = newAccountScheme.getLang();
		AccountScheme tmp = getNodeByLang(newAccountScheme.getId(), newAccountScheme.getLang());
		if (tmp != null) {
			newAccountScheme.setLabel(tmp.getLabel());
			newAccountScheme.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public AccountScheme getDetailAccountScheme() {
		return detailAccountScheme;
	}

	public void setDetailAccountScheme(AccountScheme detailAccountScheme) {
		this.detailAccountScheme = detailAccountScheme;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new AccountScheme();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("id") != null) {
					filter.setId(Integer.parseInt(filterRec.get("id")));
				}
				if (filterRec.get("label") != null) {
					filter.setLabel(filterRec.get("label"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getInstId() != null) {
				filterRec.put("instId", filter.getInstId().toString());
			}
			if (filter.getId() != null) {
				filterRec.put("id", filter.getId().toString());
			}
			if (filter.getLabel() != null) {
				filterRec.put("label", filter.getLabel());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}

package ru.bpc.sv2.ui.acquiring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.acquiring.RevenueSharing;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbRevenueSharingBottom")
public class MbRevenueSharingBottom extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACQUIRING");
//TODO define sectionID
	private static String COMPONENT_ID = "revenueSharing";

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private RevenueSharing filter;
	private RevenueSharing newRevenueSharing;
	

	private final DaoDataModel<RevenueSharing> _accountSchemesSource;
	private final TableRowSelection<RevenueSharing> _itemSelection;
	private RevenueSharing _activeRevenueSharing;

	private String tabName;
	private ArrayList<SelectItem> institutions;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	
	private String parentSectionId;

	public MbRevenueSharingBottom() {
		
		tabName = "detailsTab";

		_accountSchemesSource = new DaoDataModel<RevenueSharing>() {
			@Override
			protected RevenueSharing[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new RevenueSharing[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setPrivilege(AccountPrivConstants.VIEW_TAB_ACCOUNT_SELECTION_PRIORITY);
					return _acquiringDao.getRevenueSharings(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new RevenueSharing[0];
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
					params.setPrivilege(AccountPrivConstants.VIEW_TAB_ACCOUNT_SELECTION_PRIORITY);
					return _acquiringDao.getRevenueSharingsCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<RevenueSharing>(null, _accountSchemesSource);
	}

	public DaoDataModel<RevenueSharing> getRevenueSharings() {
		return _accountSchemesSource;
	}

	public RevenueSharing getActiveRevenueSharing() {
		return _activeRevenueSharing;
	}

	public void setActiveRevenueSharing(RevenueSharing activeRevenueSharing) {
		_activeRevenueSharing = activeRevenueSharing;
	}

	public SimpleSelection getItemSelection() {
		if (_activeRevenueSharing == null && _accountSchemesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeRevenueSharing != null && _accountSchemesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeRevenueSharing.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeRevenueSharing = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRevenueSharing = _itemSelection.getSingleSelection();

		if (_activeRevenueSharing != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_accountSchemesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRevenueSharing = (RevenueSharing) _accountSchemesSource.getRowData();
		selection.addKey(_activeRevenueSharing.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		
		if (getFilter().getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("customerId");
			paramFilter.setValue(filter.getCustomerId());
			filters.add(paramFilter);
		} else {
			if (getFilter().getCustomerNumber() != null &&
					getFilter().getCustomerNumber().trim().length() > 0) {
				paramFilter = new Filter();
				paramFilter.setElement("customerNumber");
				paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll(
						"[*]", "%").replaceAll("[?]", "_"));
				filters.add(paramFilter);
			}
		}

		if (getFilter().getTerminalId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setValue(filter.getTerminalId());
			filters.add(paramFilter);
		} else {
			if (getFilter().getTerminalNumber() != null &&
					getFilter().getTerminalNumber().trim().length() > 0) {
				paramFilter = new Filter();
				paramFilter.setElement("terminalNumber");
				paramFilter.setValue(filter.getTerminalNumber().trim().toUpperCase().replaceAll(
						"[*]", "%").replaceAll("[?]", "_"));
				filters.add(paramFilter);
			}
		}
		
		if (getFilter().getAccountNumber() != null
				&& getFilter().getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setValue(filter.getAccountNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		
	}

	public RevenueSharing getFilter() {
		if (filter == null) {
			filter = new RevenueSharing();			
		}
		return filter;
	}

	public void setFilter(RevenueSharing filter) {
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
		newRevenueSharing = new RevenueSharing();
		newRevenueSharing.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newRevenueSharing = (RevenueSharing) _activeRevenueSharing.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newRevenueSharing = _activeRevenueSharing;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_acquiringDao.removeRevenueSharing(userSessionId, _activeRevenueSharing);

			_activeRevenueSharing = _itemSelection.removeObjectFromList(_activeRevenueSharing);
			if (_activeRevenueSharing == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newRevenueSharing = _acquiringDao.addRevenueSharing(userSessionId,
						newRevenueSharing);
				_itemSelection.addNewObjectToList(newRevenueSharing);
			} else {
				newRevenueSharing = _acquiringDao.modifyRevenueSharing(userSessionId,
						newRevenueSharing);
				_accountSchemesSource.replaceObject(_activeRevenueSharing, newRevenueSharing);
			}
			_activeRevenueSharing = newRevenueSharing;
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

	public RevenueSharing getNewRevenueSharing() {
		if (newRevenueSharing == null) {
			newRevenueSharing = new RevenueSharing();
		}
		return newRevenueSharing;
	}

	public void setNewRevenueSharing(RevenueSharing newRevenueSharing) {
		this.newRevenueSharing = newRevenueSharing;
	}

	public void clearBean() {
		curLang = userLang;
		_accountSchemesSource.flushCache();
		_itemSelection.clearSelection();
		_activeRevenueSharing = null;
		loadedTabs.clear();

		clearBeans();
	}

	private void clearBeans() {		
	}

	public String getTabName() {
		return tabName;
	}
	
	public void keepTabName(String tabName) {
		this.tabName = tabName;
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
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeRevenueSharing == null || _activeRevenueSharing.getId() == null) {
			needRerender = tab;
			loadedTabs.put(tab, Boolean.TRUE);

			return;
		}

		if (tab.equalsIgnoreCase("patternsTab")) {

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

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeRevenueSharing.getId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			RevenueSharing[] types = _acquiringDao.getRevenueSharings(userSessionId, params);
			if (types != null && types.length > 0) {
				_activeRevenueSharing = types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}

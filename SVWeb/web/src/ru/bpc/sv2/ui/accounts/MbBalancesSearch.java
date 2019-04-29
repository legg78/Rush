package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;

import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbBalancesSearch")
public class MbBalancesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private AccountsDao _accountsDao = new AccountsDao();

	

	private Balance filter;
	private Balance _activeBalance;
	private Balance newBalance;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> balanceStatuses;
	private ArrayList<SelectItem> balanceTypes;

	private String tabName;

	private final DaoDataModel<Balance> _balancesSource;
	private final TableRowSelection<Balance> _itemSelection;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	
	private static String COMPONENT_ID = "mainTable";
	private String parentSectionId;

	public MbBalancesSearch() {
		
		filter = new Balance();
		tabName = "detailsTab";
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");

		_balancesSource = new DaoDataModel<Balance>() {
			@Override
			protected Balance[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Balance[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getBalances(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
					logger.error("", e);
				}
				return new Balance[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getBalancesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Balance>(null, _balancesSource);

		if (!menu.isKeepState()) {
			// if user came here from menu, we don't need to select previously selected tab
			clearFilter();
			clearBeansStates();
		}
	}

	public DaoDataModel<Balance> getBalances() {
		return _balancesSource;
	}

	public Balance getActiveBalance() {
		return _activeBalance;
	}

	public void setActiveBalance(Balance activeBalance) {
		_activeBalance = activeBalance;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeBalance == null && _balancesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeBalance != null && _balancesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeBalance.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeBalance = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_balancesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBalance = (Balance) _balancesSource.getRowData();
		selection.addKey(_activeBalance.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBalance != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBalance = _itemSelection.getSingleSelection();
		if (_activeBalance != null) {
			setInfo();
		}
	}

	public void setInfo() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = new Balance();
		clearState();
		searching = false;
	}

	public Balance getFilter() {
		if (filter == null)
			filter = new Balance();
		return filter;
	}

	public void setFilter(Balance filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		if (filter.getAccountId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAccountId().toString());
			filters.add(paramFilter);
		}

		if (filter.getBalanceNumber() != null && filter.getBalanceNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("balanceNumber");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getBalanceNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getBalanceType() != null && filter.getBalanceType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("type");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getBalanceType());
			filters.add(paramFilter);
		}

		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStatus());
			filters.add(paramFilter);
		}

		if (filter.getCurrency() != null && filter.getCurrency().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCurrency());
			filters.add(paramFilter);
		}

		if (filter.getOpenDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("openDateFrom");
			paramFilter.setValue(filter.getOpenDate());
			filters.add(paramFilter);
		}
		if (filter.getCloseDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("closeDateTo");
			paramFilter.setValue(filter.getCloseDate());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newBalance = new Balance();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newBalance = (Balance) _activeBalance.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newBalance = _activeBalance;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public Balance getNewBalance() {
		if (newBalance == null) {
			newBalance = new Balance();
		}
		return newBalance;
	}

	public void setNewBalance(Balance newBalance) {
		this.newBalance = newBalance;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeBalance = null;
		_balancesSource.flushCache();
		curLang = userLang;
		loadedTabs.clear();
	}

	public void clearBeansStates() {

	}

	public ArrayList<SelectItem> getBalanceTypes() {
		if (balanceTypes == null) {
			balanceTypes = getDictUtils().getArticles(DictNames.BALANCE_TYPE, false, false);
		}
		return balanceTypes;
	}

	public ArrayList<SelectItem> getBalanceStatuses() {
		if (balanceStatuses == null) {
			balanceStatuses = getDictUtils().getArticles(DictNames.BALANCE_STATUS, false, false);
		}
		return balanceStatuses;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
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
	}
	
	public void keepTabName(String tabName) {
		this.tabName = tabName;
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeBalance == null)
			return;

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

	public void filterByDate(ValueChangeEvent event) {
		_balancesSource.flushCache();
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}

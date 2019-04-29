package ru.bpc.sv2.ui.accounts;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.AccountGL;
import ru.bpc.sv2.accounts.AccountType;
import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.operations.MbOperationsBottom;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbGLAccountsSearch")
public class MbGLAccountsSearch extends AbstractBean {
	private static final long serialVersionUID = 1186626182906899105L;

	private static String COMPONENT_ID = "mainTable";

	private AccountsDao _accountsDao = new AccountsDao();

	private OrgStructDao _orgStructDao = new OrgStructDao();

	private AccountGL filter;
	private String backLink;

	private AccountGL _activeAccount;
	private AccountGL newAccount;

	private final DaoDataModel<AccountGL> _accountsSource;

	private final TableRowSelection<AccountGL> _itemSelection;
	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	private String tabName;

	private ArrayList<SelectItem> institutions;
	
	private String parentSectionId;
	private String privilege;

	public MbGLAccountsSearch() {
		pageLink = "accounts|gl";
		tabName = "detailsTab";
		
		_accountsSource = new DaoDataModel<AccountGL>() {
			private static final long serialVersionUID = 7173326369425505772L;

			@Override
			protected AccountGL[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new AccountGL[0];
				setFilters();
				params.setPrivilege(privilege);
				params.setFilters(filters.toArray(new Filter[filters.size()]));
				try {
					return _accountsDao.getGLAccounts(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AccountGL[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				setFilters();
				params.setPrivilege(privilege);
				params.setFilters(filters.toArray(new Filter[filters.size()]));
				try {
					return _accountsDao.getGLAccountsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AccountGL>(null, _accountsSource);
	}

	public DaoDataModel<AccountGL> getAccounts() {
		return _accountsSource;
	}

	public AccountGL getActiveAccount() {
		return _activeAccount;
	}

	public void setActiveAccount(AccountGL activeAccount) {
		_activeAccount = activeAccount;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAccount == null && _accountsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAccount != null && _accountsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAccount.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAccount = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_accountsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAccount = (AccountGL) _accountsSource.getRowData();
		selection.addKey(_activeAccount.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAccount != null) {
			setBeans();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAccount = _itemSelection.getSingleSelection();
		
		if (_activeAccount != null) {
			setBeans();
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getAccountNumber() != null
				&& getFilter().getAccountNumber().trim().length() != 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setCondition("=");
			paramFilter.setValue(getFilter().getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || getFilter().getAccountNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filtersList.add(paramFilter);
		}
		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getEntityType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getEntityId() != null && !getFilter().getEntityId().trim().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("entityId");
			paramFilter.setValue(filter.getEntityId().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getFilter().getInstId() != null && !getFilter().getInstId().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId());
			filtersList.add(paramFilter);
		}
		if (getFilter().getAccountType() != null && getFilter().getAccountType().length() > 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("accountType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getAccountType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getStatus() != null && getFilter().getStatus().length() > 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getStatus());
			filtersList.add(paramFilter);
		}
		if (getFilter().getCurrency() != null && getFilter().getCurrency().length() > 0) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCurrency());
			filtersList.add(paramFilter);
		}

		filters = filtersList;
	}

	public AccountGL getFilter() {
		if (filter == null)
			filter = new AccountGL();
		return filter;
	}

	public void setFilter(AccountGL filter) {
		this.filter = filter;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void generateGLaccounts() {
		try {
			_accountsDao.generateGLAccounts(userSessionId, getFilter());
//			filter.setCurrency(null); // clear currency in filter after
			// generating
			_accountsSource.flushCache();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			filter.setCurrency(null);
		}
	}

	public void generateGL() {
	}

	public void createGLaccounts() {
		try {
			newAccount = _accountsDao.createGLAccount(userSessionId, newAccount);
			_itemSelection.addNewObjectToList(newAccount);
			_activeAccount = newAccount;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}		
		search();
	}

	public void createGL() {
		newAccount = new AccountGL();
		getNewAccount().setEntityType(getFilter().getEntityType());
		getNewAccount().setEntityId(getFilter().getEntityId());
		getNewAccount().setCurrency(getFilter().getCurrency());
	}

	public void cancelCreateGLaccount() {

	}

	public void delete() {
		try {
			_accountsDao.deleteGLAccount(userSessionId, _activeAccount);

			_activeAccount = _itemSelection.removeObjectFromList(_activeAccount);
			if (_activeAccount == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void clearBean() {
		_accountsSource.flushCache();
		_itemSelection.clearSelection();
		_activeAccount = null;
	}

	public void clearFilter() {
		clearBean();
		filter = null;
		searching = false;
	}

	public void cancelGenerateGLaccounts() {

	}

	public ArrayList<SelectItem> getAccountStatuses() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_STATUS, true, false);
	}

	public ArrayList<SelectItem> getAccountTypesArticles() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true, false);
	}

	public ArrayList<SelectItem> getAccountTypes() {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("productType");
		paramFilter.setValue(ProductConstants.INSTITUTION_PRODUCT);
		filtersList.add(paramFilter);

		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(getFilter().getEntityType());
			filtersList.add(paramFilter);
		}

		if (getFilter().getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(getFilter().getInstId().toString());
			filtersList.add(paramFilter);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		try {
			AccountType[] types = _accountsDao.getAccountTypes(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(types.length);
			for (AccountType type: types) {
				String desc = getDictUtils().getAllArticlesDesc().get(
						type.getAccountType());
				if (desc == null) {
					desc = "";
				}
				items.add(new SelectItem(type.getAccountType(), type.getAccountType() + " - " + desc, desc));
			}
			Collections.sort(items, new Comparator<SelectItem>() {
				@Override
				public int compare(SelectItem o1, SelectItem o2) {
					return o1.getDescription().toLowerCase().compareTo(o2.getDescription().toLowerCase());
				}
			});
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage() != null && e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return new ArrayList<SelectItem>(0);
	}

	public AccountGL getNewAccount() {
		if (newAccount == null)
			newAccount = new AccountGL();
		return newAccount;
	}

	public void setNewAccount(AccountGL newAccount) {
		this.newAccount = newAccount;
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
		
		if (tabName.equalsIgnoreCase("balancesTab")) {
			MbBalancesSearch bean = (MbBalancesSearch) ManagedBeanWrapper
					.getManagedBean("MbBalancesSearch");
			bean.keepTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("transactionsTab")) {
			MbEntriesForAccount bean = (MbEntriesForAccount) ManagedBeanWrapper
					.getManagedBean("MbEntriesForAccount");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("operationsTab")) {
			MbOperationsBottom bean = (MbOperationsBottom) ManagedBeanWrapper
					.getManagedBean("MbOperationsBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("attributesTab")) {
			MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.STRUCT_ORG_ACC;
	}
	
	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeAccount == null)
			return;

		if (tab.equalsIgnoreCase("OPERATIONSTAB")) {
			MbOperationsBottom operationsBean = (MbOperationsBottom) ManagedBeanWrapper
					.getManagedBean("MbOperationsBottom");

			operationsBean.getParticipantFilter().setAccountId(_activeAccount.getId());

			operationsBean.getAdjustmentFilter().setAccountNumber(_activeAccount.getAccountNumber());
			operationsBean.getAdjustmentFilter().setSplitHash(_activeAccount.getSplitHash());
			operationsBean.getAdjustmentFilter().setAcqInstId(_activeAccount.getInstId());
			operationsBean.getAdjustmentFilter().setIssInstId(_activeAccount.getInstId());
			operationsBean.getAdjustmentFilter().setOperationCurrency(_activeAccount.getCurrency());
			operationsBean.setSearchTabName("ACCOUNT");
			operationsBean.searchByParticipant();
		}
		if (tab.equalsIgnoreCase("BALANCESTAB")) {
			MbBalancesSearch balancesSearch = (MbBalancesSearch) ManagedBeanWrapper
					.getManagedBean("MbBalancesSearch");
			Balance balanceFilter = new Balance();
			balanceFilter.setAccountId(_activeAccount.getId());
			balancesSearch.setFilter(balanceFilter);
			balancesSearch.search();
		}
		if (tab.equalsIgnoreCase("TRANSACTIONSTAB")) {
			MbEntriesForAccount entriesSearch = (MbEntriesForAccount) ManagedBeanWrapper
					.getManagedBean("MbEntriesForAccount");
			Balance balanceFilter = new Balance();
			balanceFilter.setAccountId(_activeAccount.getId());
			entriesSearch.setFilter(balanceFilter);
			entriesSearch.search();
		}
		if (tab.equalsIgnoreCase("attributesTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(_activeAccount.getId());
			attrs.setProductId(_activeAccount.getProductId());
			attrs.setEntityType(EntityNames.ACCOUNT);
			attrs.setInstId(_activeAccount.getInstId());
		}
//		if (tab.equalsIgnoreCase("CUSTOMERSTAB")) {
//			MbCustomers customersBean = (MbCustomers) ManagedBeanWrapper
//					.getManagedBean("MbCustomers");
////			customersBean.clearFilter();
//			customersBean.getCustomer(_activeAccount.getCustomerId());
//		}
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

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getEntityTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>(2);
		items.add(new SelectItem(EntityNames.AGENT, getDictUtils().getAllArticlesDesc().get(
				EntityNames.AGENT)));
		items.add(new SelectItem(EntityNames.INSTITUTION, getDictUtils().getAllArticlesDesc().get(
				EntityNames.INSTITUTION)));

		return items;
	}

	public List<SelectItem> getEntities() {
		if (EntityNames.AGENT.equals(getFilter().getEntityType())) {
			return getAgents();
		} else if (EntityNames.INSTITUTION.equals(getFilter().getEntityType())) {
			return getInstitutions();
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getAgents() {
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter filter = new Filter();
		filter.setElement("lang");
		filter.setValue(userLang);
		filters.add(filter);
		if (getFilter().getInstId() != null) {
			filter = new Filter();
			filter.setElement("instId");
			filter.setValue(getFilter().getInstId());
			filters.add(filter);
		}

		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			Agent[] agents = _orgStructDao.getAgentsTree(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(agents.length);
			for (Agent agent: agents) {
				String name = agent.getName();
				for (int i = 1; i < agent.getLevel(); i++) {
					name = "--" + name;
				}
				items.add(new SelectItem(agent.getId(), " " + name, agent.getDescription()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeAccount.getId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			AccountGL[] accounts = _accountsDao.getGLAccounts(userSessionId, params);
			if (accounts != null && accounts.length > 0) {
				_activeAccount = accounts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			// for tab table
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			//for main table
			return "2162:accountsTable";
		}
	}

	public Logger getLogger() {
		return logger;
	}
	
	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new AccountGL();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("accountNumber") != null) {
					filter.setAccountNumber(filterRec.get("accountNumber"));
				}
				if (filterRec.get("status") != null) {
					filter.setStatus(filterRec.get("status"));
				}
				if (filterRec.get("accountType") != null) {
					filter.setAccountType(filterRec.get("accountType"));
				}
				if (filterRec.get("entityType") != null) {
					filter.setEntityType(filterRec.get("entityType"));
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
			if (filter.getAccountNumber() != null) {
				filterRec.put("accountNumber", filter.getAccountNumber());
			}
			if (filter.getStatus() != null) {
				filterRec.put("status", filter.getStatus());
			}
			if (filter.getAccountType() != null) {
				filterRec.put("accountType", filter.getAccountType());
			}
			if (filter.getEntityType() != null) {
				filterRec.put("entityType", filter.getEntityType());
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

package ru.bpc.sv2.ui.accounts;

import org.apache.log4j.Logger;
import org.apache.poi.hssf.usermodel.HSSFRichTextString;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.reports.QueryResult;
import ru.bpc.sv2.ui.accounts.details.MbCreditAccountDetails;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.acquiring.MbMerchantsBottom;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.fcl.cycles.MbAccountCycleCounters;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.fraud.MbFraudObjects;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.loyalty.MbLoyaltyBonusesSearch;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.operations.MbOperationsBottom;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.reports.MbEntityObjectInfoBottom;
import ru.bpc.sv2.ui.reports.MbReportsBottom;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.ByteArrayOutputStream;
import java.io.OutputStream;
import java.net.URLEncoder;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean (name = "MbAccountsAllSearch")
public class MbAccountsAllSearch extends AbstractBean {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	private static String COMPONENT_ID = "accountsTable";

	private AccountsDao _accountsDao = new AccountsDao();
	private ProductsDao _productsDao = new ProductsDao();

	public static final String CREDIT_ACCOUNT_TYPE = "ACTP0130";

	private Account filter;
	private Account _activeAccount;
	private Account newAccount;

	private ArrayList<SelectItem> institutions;

	protected String tabName;

	private String module;
	private ArrayList<SelectItem> accountStatuses;
	
	private String pageName;
	private String backLink;
	private String appType;

	private boolean searchByCard;

	private final DaoDataModel<Account> _accountsSource;
	private final TableRowSelection<Account> _itemSelection;

	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private HashMap<String, Object> paramMap;
	protected String needRerender;
	private List<String> rerenderList;

	private final String ACQUIRING_BACKLINK = "acquiring|accounts";
	private final String ISSUING_BACKLINK = "issuing|accounts";
	public static final String ACQUIRING = "acquiring";
	public static final String ISSUING = "issuing";

	protected MbAccounts sessionBean;
	
	private String ctxItemEntityType;
	private ContextType ctxType;
	private String isspageLink;
	private String acqpageLink;
	
	public MbAccountsAllSearch() {
		isspageLink = "issuing|accounts";
		acqpageLink = "acquiring|accounts";
		sessionBean = (MbAccounts) ManagedBeanWrapper.getManagedBean("MbAccounts");

		tabName = "detailsTab";
		_accountsSource = new DaoDataModel<Account>(true) {
			private static final long serialVersionUID = 1L;

			@Override
			protected Account[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Account[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getAccountsCur(userSessionId, params, paramMap);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
					logger.error("", e);
				}
				return new Account[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				int count = 0;
				int threshold = 300;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setThreshold(threshold);
					count = _accountsDao.getAccountsCountCur(userSessionId, paramMap);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				
				return count;
			}
		};

		_itemSelection = new TableRowSelection<Account>(null, _accountsSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	@PostConstruct
	public void init() {
		setModule(getModuleFromRequest());
		setDefaultValues();
		// 2-nd restore: to get shown information back in bean
		// FIXME: the stupidest way of doing things but it works, at least it seems so
		// (see also restoreBean()) perhaps it can be used without time check as bean is
		// destroyed everytime we return on the page so the situation when flag is set
		// but bean isn't destroyed seems to be impossible
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink + "RESTORE_AGAIN");
		Long restoreTime = (Long) FacesUtils.getSessionMapValue("RESTORE_TIME");
		if (restoreBean != null && restoreBean && restoreTime != null) {
			if (System.currentTimeMillis() - restoreTime < 10000) {
				restoreBean();
			}
			FacesUtils.setSessionMapValue(thisBackLink + "RESTORE_AGAIN", null);
		}

		// 1-st restore: to show saved information
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean != null && restoreBean) {
			restoreBean();
		}
	}
	
	public DaoDataModel<Account> getAccounts() {
		return _accountsSource;
	}

	public Account getActiveAccount() {
		return _activeAccount;
	}
	
	public String toApplications() {
		try {
			HashMap<String,Object> queueFilter = new HashMap<String,Object>();
			queueFilter.put("accountNumber", _activeAccount.getAccountNumber());
			queueFilter.put("instId", _activeAccount.getInstId());
			queueFilter.put("objectId", _activeAccount.getId().longValue());
			queueFilter.put("entityType", EntityNames.ACCOUNT);
			queueFilter.put("backLink", thisBackLink);

			addFilterToQueue("MbApplicationsSearch", queueFilter);

			Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			if (isAcquiringType()) {
				mbMenu.externalSelect("applications|list_acq_apps");
			} else if(isIssuingType()){
				mbMenu.externalSelect("applications|list_iss_apps");
			}

			return "acquiring|applications|list_apps";
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return "";
	}

	public void setActiveAccount(Account activeAccount) {
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
		_activeAccount = (Account) _accountsSource.getRowData();
		selection.addKey(_activeAccount.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeAccount != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAccount = _itemSelection.getSingleSelection();
		if (_activeAccount != null) {
			setInfo();			
		}
	}

	private void setInfo() {
		setInfo(false);
	}
	
	public void setInfo(boolean restoreBean) {
		setRenderTabs(true);
		loadedTabs.clear();
		
		if (_activeAccount != null) {
			sessionBean.setActiveAccount(_activeAccount);
			sessionBean.setBackLink(backLink);
			sessionBean.setFilter(filter);
			sessionBean.setModule(module);
			sessionBean.setPageNumber(pageNumber);
			sessionBean.setRowsNum(rowsNum);
			sessionBean.setTabName(tabName);
		}
		
		loadTab(getTabName(), restoreBean);
	}

	public void search() {
		clearState();
		paramMap = new HashMap<String, Object>();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearSectionFilter();
		setDefaultValues();
		searching = false;
	}

	public Account getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}
		if (filter == null) {
			filter = new Account();
		}
		return filter;
	}

	public void setFilter(Account filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getAccountNumber() != null && filter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setValue(filter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (getFilter().getEntityType() != null && !getFilter().getEntityType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("ENTITY_TYPE");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getEntityType());
			filters.add(paramFilter);
		}
		if (getFilter().getObjectId() != null && !getFilter().getObjectId().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("OBJECT_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getObjectId().toString());
			filters.add(paramFilter);
		}
		if (getFilter().getInstId() != null && !getFilter().getInstId().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId());
			filters.add(paramFilter);
		}
		if (getFilter().getAccountType() != null && !getFilter().getAccountType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_TYPE");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getAccountType());
			filters.add(paramFilter);
		}
		if (getFilter().getStatus() != null && !getFilter().getStatus().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getStatus());
			filters.add(paramFilter);
		}
		if (getFilter().getCurrency() != null && !getFilter().getCurrency().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("CURRENCY");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCurrency());
			filters.add(paramFilter);
		}
		if (getFilter().getCustomerNumber() != null &&
				getFilter().getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (getFilter().getContractNumber() != null 
				&& !getFilter().getContractNumber().trim().isEmpty()){
			String contractNumber = getFilter().getContractNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_");
			filters.add(new Filter("CONTRACT_NUMBER", contractNumber));
		}
		filters.add(new Filter("PARTICIPANT_MODE", isAcquiringType()?"ACQ":"ISS"));
		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMap().put("tab_name", "ACCOUNT");
		
	}

	public void add() {
		newAccount = new Account();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newAccount = (Account) _activeAccount.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newAccount = _activeAccount;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public Account getNewAccount() {
		if (newAccount == null) {
			newAccount = new Account();
		}
		return newAccount;
	}

	public void setNewAccount(Account newAccount) {
		this.newAccount = newAccount;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeAccount = null;
		_accountsSource.flushCache();
		curLang = userLang;
		loadedTabs.clear();
		clearBeansStates();
	}

	public void clearBeansStates() {

		if (!searchByCard) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			cardsSearch.clearState();
			cardsSearch.setFilter(null);
			cardsSearch.setSearching(false);
		}
		MbOperationsBottom operationsBean = (MbOperationsBottom) ManagedBeanWrapper
				.getManagedBean("MbOperationsBottom");
		operationsBean.clearState();
		operationsBean.setFilter(null);
		operationsBean.setSearching(false);

		MbBalancesSearch balancesSearch = (MbBalancesSearch) ManagedBeanWrapper
				.getManagedBean("MbBalancesSearch");
		balancesSearch.clearState();
		balancesSearch.setFilter(null);
		balancesSearch.setSearching(false);

		MbEntriesForAccount entriesSearch = (MbEntriesForAccount) ManagedBeanWrapper
				.getManagedBean("MbEntriesForAccount");
		entriesSearch.clearState();
		entriesSearch.setFilter(null);
		entriesSearch.setSearching(false);

		MbLoyaltyBonusesSearch loaltyBonueseBean = (MbLoyaltyBonusesSearch) ManagedBeanWrapper
				.getManagedBean("MbLoyaltyBonusesSearch");
		loaltyBonueseBean.clearState();
		loaltyBonueseBean.setSearching(false);

		MbMerchantsBottom merchantBean = (MbMerchantsBottom) ManagedBeanWrapper
				.getManagedBean("MbMerchantsBottom");
		merchantBean.clearState();
		merchantBean.setSearching(false);

		MbTerminalsBottom terminalBean = (MbTerminalsBottom) ManagedBeanWrapper
				.getManagedBean("MbTerminalsBottom");
		terminalBean.clearState();
		terminalBean.setSearching(false);

		MbObjectAttributes objAttrBean = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		objAttrBean.clearFilter();
		objAttrBean.fullCleanBean();

		MbLimitCounters limitCountersBean = (MbLimitCounters) ManagedBeanWrapper
				.getManagedBean("MbLimitCounters");
		limitCountersBean.clearFilter();

		MbCycleCounters cycleCountersBean = (MbCycleCounters) ManagedBeanWrapper
				.getManagedBean("MbCycleCounters");
		cycleCountersBean.clearFilter();

		MbCustomersDependent customerBean = (MbCustomersDependent) ManagedBeanWrapper
				.getManagedBean("MbCustomersDependent");
		customerBean.setActiveCustomer(null);
		
//		MbAccountContacts mbAccountContacts = (MbAccountContacts) ManagedBeanWrapper
//				.getManagedBean("MbAccountContacts");
//		mbAccountContacts.fullCleanBean();
		
		MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
				.getManagedBean("MbObjectDocuments");
		mbObjectDocuments.clearFilter();
		
		MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
				.getManagedBean(MbObjectApplicationsSearch.class);
		mbAppObjects.clearFilter();
		
		MbFraudObjects suiteObjectBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
		suiteObjectBean.fullCleanBean();
		
		MbReportsBottom reportsBean = (MbReportsBottom) ManagedBeanWrapper.getManagedBean("MbReportsBottom");
		reportsBean.clearFilter();
				
		MbEntityObjectInfoBottom info = (MbEntityObjectInfoBottom) ManagedBeanWrapper.getManagedBean("MbEntityObjectInfoBottom");
		info.clearFilter();
		
	}

	public String getPageName() {
		if (isIssuingType()) {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Iss", "issuing_accounts");
		} else {
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acq", "acquiring_accounts");
		}
		return pageName;
	}

	public boolean isIssuingType() {
		return ModuleNames.ISSUING.equals(module);
	}

	public boolean isAcquiringType() {
		return ModuleNames.ACQUIRING.equals(module);
	}

	public List<SelectItem> getAccountTypes() {
		if (isIssuingType()) {
			return getDictUtils().getLov(LovConstants.ISSUING_ACCOUNT_TYPES_USER);
		} else if (isAcquiringType()) {
			return getDictUtils().getLov(LovConstants.ACQUIRING_ACCOUNT_TYPES_USER);
		} else {
			return new ArrayList<SelectItem>(0);
		}
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;

		if (_activeAccount != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeAccount.getId().toString());
			filtersList.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Account[] accounts = _accountsDao.getAccounts(userSessionId, params);
			if (accounts != null && accounts.length > 0) {
				_activeAccount = accounts[0];
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

	public ArrayList<SelectItem> getAccountStatuses() {
		if (accountStatuses == null) {
			accountStatuses = getDictUtils().getArticles(DictNames.ACCOUNT_STATUS, false, false);
		}
		return accountStatuses;
	}

	public boolean isSearchByCard() {
		return searchByCard;
	}

	public void setSearchByCard(boolean searchByCard) {
		this.searchByCard = searchByCard;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		sessionBean.setTabName(tabName);
		/*
		 * Boolean isLoadedCurrentTab = loadedTabs.get(tabName);
		 * 
		 * if (isLoadedCurrentTab == null) { isLoadedCurrentTab = Boolean.FALSE; }
		 * 
		 * if (isLoadedCurrentTab.equals(Boolean.TRUE)) { return; }
		 * 
		 * loadTab(tabName);
		 */
		
		if (tabName.equalsIgnoreCase("FLEXIBLEFIELDSTAB")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			flexible.setTabName(tabName);
			flexible.setParentSectionId(getSectionId());
			flexible.setTableState(getSateFromDB(flexible.getComponentId()));
		} else if (tabName.equalsIgnoreCase("BALANCESTAB")) {
			MbBalancesSearch balancesSearch = (MbBalancesSearch) ManagedBeanWrapper
					.getManagedBean("MbBalancesSearch");
			
			balancesSearch.keepTabName(tabName);
			balancesSearch.setParentSectionId(getSectionId());
			balancesSearch.setTableState(getSateFromDB(balancesSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("transactionsTab")) {
			MbEntriesForAccount entriesSearch = (MbEntriesForAccount) ManagedBeanWrapper
					.getManagedBean("MbEntriesForAccount");
			entriesSearch.setTabName(tabName);
			entriesSearch.setParentSectionId(getSectionId());
			entriesSearch.setTableState(getSateFromDB(entriesSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("operationsTab")) {
			MbOperationsBottom search = (MbOperationsBottom) ManagedBeanWrapper
					.getManagedBean("MbOperationsBottom");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
			
		} else if (tabName.equalsIgnoreCase("attributesTab")) {
			MbAttributeValues attrSearch = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			attrSearch.setTabName(tabName);
			attrSearch.setParentSectionId(getSectionId());
			attrSearch.setTableState(getSateFromDB(attrSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cardsTab")) {
			MbCardsBottomSearch cardSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			cardSearch.setTabName(tabName);
			cardSearch.setParentSectionId(getSectionId());
			cardSearch.setTableState(getSateFromDB(cardSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("merchantsTab")) {
			MbMerchantsBottom merchantSearch = (MbMerchantsBottom) ManagedBeanWrapper
					.getManagedBean("MbMerchantsBottom");
			merchantSearch.setTabName(tabName);
			merchantSearch.setParentSectionId(getSectionId());
			merchantSearch.setTableState(getSateFromDB(merchantSearch.getComponentId()));
		}  else if (tabName.equalsIgnoreCase("terminalsTab")) {
			MbTerminalsBottom search = (MbTerminalsBottom) ManagedBeanWrapper
					.getManagedBean("MbTerminalsBottom");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		} else if (tabName.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters search = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters search = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCounters");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		} else if (tabName.equalsIgnoreCase("loyaltyBonusesTab")) {
			MbLoyaltyBonusesSearch search = (MbLoyaltyBonusesSearch) ManagedBeanWrapper
					.getManagedBean("MbLoyaltyBonusesSearch");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		} else if (tabName.equalsIgnoreCase("notesTab")) {
			MbNotesSearch search = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		} else if (tabName.equalsIgnoreCase("documentsTab")) {
			MbObjectDocuments search = (MbObjectDocuments) ManagedBeanWrapper
					.getManagedBean("MbObjectDocuments");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		}  else if (tabName.equalsIgnoreCase("statusLogsTab")) {
			MbStatusLogs search = (MbStatusLogs) ManagedBeanWrapper
					.getManagedBean("MbStatusLogs");
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		} else if (tabName.equalsIgnoreCase("applicationsTab")) {
			MbObjectApplicationsSearch search = (MbObjectApplicationsSearch) ManagedBeanWrapper
					.getManagedBean(MbObjectApplicationsSearch.class);
			search.setTabName(tabName);
			search.setParentSectionId(getSectionId());
			search.setTableState(getSateFromDB(search.getComponentId()));
		} else if (tabName.equalsIgnoreCase("suitesTab")) {
			MbFraudObjects bean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("creditTab")){
			MbCreditAccountDetails bean = (MbCreditAccountDetails) ManagedBeanWrapper
					.getManagedBean(MbCreditAccountDetails.class);
			bean.setTabNameParam(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName, false);
	}

	private void loadTab(String tab, boolean restoreBean) {
		if (tab == null)
			return;
		if (_activeAccount == null)
			return;

		if (tab.equalsIgnoreCase("CARDSTAB")) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			Card cardFilter = new Card();
			cardFilter.setAccountId(_activeAccount.getId());
			cardsSearch.setFilter(cardFilter);
			cardsSearch.setSearchTabName("ACCOUNT");
			cardsSearch.search();
		} else if (tab.equalsIgnoreCase("OPERATIONSTAB")) {
			MbOperationsBottom operationsBean = (MbOperationsBottom) ManagedBeanWrapper
					.getManagedBean("MbOperationsBottom");
			operationsBean.clearFilter();
			operationsBean.setSearchTabName("ACCOUNT");
			operationsBean.getParticipantFilter().setAccountId(_activeAccount.getId());
			if (isIssuingType()) {
				operationsBean.getParticipantFilter().setParticipantType("PRTYISS");
				operationsBean.getParticipantFilter().setInstId(_activeAccount.getInstId());
			} else if (isAcquiringType()) {
				operationsBean.getParticipantFilter().setParticipantType("PRTYACQ");
				operationsBean.getParticipantFilter().setInstId(_activeAccount.getInstId());
			}

			ru.bpc.sv2.operations.incoming.Operation filterAdjusment = new ru.bpc.sv2.operations.incoming.Operation();
			filterAdjusment.setAccountNumber(_activeAccount.getAccountNumber());
			filterAdjusment.setAccountId(_activeAccount.getId());
			filterAdjusment.setSplitHash(_activeAccount.getSplitHash());
			filterAdjusment.setAcqInstId(_activeAccount.getInstId());
			filterAdjusment.setIssInstId(_activeAccount.getInstId());
			filterAdjusment.setOperationCurrency(_activeAccount.getCurrency());

			operationsBean.setAdjustmentFilter(filterAdjusment);
			operationsBean.setBackLink(thisBackLink);
			operationsBean.searchByParticipant();
			if(isIssuingType()){
				operationsBean.setObjectType("PRTYISS");
			}
			else if (isAcquiringType()){
				operationsBean.setObjectType("PRTYACQ");
			}
		} else if (tab.equalsIgnoreCase("BALANCESTAB")) {
			MbBalancesSearch balancesSearch = (MbBalancesSearch) ManagedBeanWrapper
					.getManagedBean("MbBalancesSearch");
			Balance balanceFilter = new Balance();
			balanceFilter.setAccountId(_activeAccount.getId());
			balancesSearch.setFilter(balanceFilter);
			balancesSearch.search();
		} else if (tab.equalsIgnoreCase("TRANSACTIONSTAB")) {
			MbEntriesForAccount entriesSearch = (MbEntriesForAccount) ManagedBeanWrapper
					.getManagedBean("MbEntriesForAccount");
			Balance balanceFilter = new Balance();
			balanceFilter.setAccountId(_activeAccount.getId());
			entriesSearch.setFilter(balanceFilter);
			entriesSearch.search();
		} else if (tab.equalsIgnoreCase("attributesTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(_activeAccount.getId());
			attrs.setProductId(_activeAccount.getProductId());
			attrs.setEntityType(EntityNames.ACCOUNT);
			attrs.setInstId(_activeAccount.getInstId());
			attrs.setProductType(_activeAccount.getProductType());
		} else if (tab.equalsIgnoreCase("merchantsTab")) {
			MbMerchantsBottom merchantsBean = (MbMerchantsBottom) ManagedBeanWrapper
					.getManagedBean("MbMerchantsBottom");
			Merchant merchantFilter = new Merchant();
			merchantFilter.setAccountId(_activeAccount.getId());
			merchantsBean.setFilter(merchantFilter);
			merchantsBean.setSearchTabName("ACCOUNT");
			merchantsBean.search();
		} else if (tab.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(_activeAccount.getId());
			limitCounters.getFilter().setInstId(_activeAccount.getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.ACCOUNT);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersTab")) {
			MbAccountCycleCounters cycleCounters = (MbAccountCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbAccountCycleCounters");
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(_activeAccount.getId());
			cycleCounters.getFilter().setInstId(_activeAccount.getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.ACCOUNT);
			cycleCounters.search();
		} else if (tab.equalsIgnoreCase("CUSTOMERSTAB")) {
			MbCustomersDependent customersBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependent");
			// customersBean.clearFilter();
			customersBean.getCustomer(_activeAccount.getCustomerId(), _activeAccount.getCustomerType());
		} else if (tab.equalsIgnoreCase("loyaltyBonusesTab")) {
			MbLoyaltyBonusesSearch loaltyBonueseBean = (MbLoyaltyBonusesSearch) ManagedBeanWrapper
					.getManagedBean("MbLoyaltyBonusesSearch");
			loaltyBonueseBean.setAccountId(_activeAccount.getId());
			loaltyBonueseBean.search();
		} else if (tab.equalsIgnoreCase("TERMINALSTAB")) {

			MbTerminalsBottom terminalsBean = (MbTerminalsBottom) ManagedBeanWrapper
					.getManagedBean("MbTerminalsBottom");
            terminalsBean.setFilterTerm(null);
			terminalsBean.setAccountId(_activeAccount.getId());
			terminalsBean.setSearchTabName("ACCOUNT");
			terminalsBean.searchTerminal();

		} else if (tab.equalsIgnoreCase("FLEXIBLEFIELDSTAB")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(_activeAccount.getInstId());
			filterFlex.setEntityType(EntityNames.ACCOUNT);
			filterFlex.setObjectId(_activeAccount.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("NOTESTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.ACCOUNT);
			filterNote.setObjectId(_activeAccount.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("CONTACTSTAB")){
//			MbAccountContacts mbAccountContacts = (MbAccountContacts) ManagedBeanWrapper
//					.getManagedBean("MbAccountContacts");
//			mbAccountContacts.setAccountId(_activeAccount.getId().longValue());
//			mbAccountContacts.search();
		} else if (tab.equalsIgnoreCase("documentsTab")){
			MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
					.getManagedBean("MbObjectDocuments");
			mbObjectDocuments.getFilter().setObjectId(_activeAccount.getId().longValue());
			mbObjectDocuments.getFilter().setEntityType(EntityNames.ACCOUNT);
			mbObjectDocuments.setBackLink(thisBackLink);
			if (restoreBean) {
				mbObjectDocuments.restoreState();
			}
			mbObjectDocuments.search();
		} else if (tab.equalsIgnoreCase("statusLogsTab")) {
			MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper
					.getManagedBean("MbStatusLogs");
			statusLogs.clearFilter();
			statusLogs.getFilter().setObjectId(_activeAccount.getId());
			statusLogs.getFilter().setEntityType(EntityNames.ACCOUNT);
			statusLogs.search();
		} else if (tab.equalsIgnoreCase("applicationsTab")){
			MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
					.getManagedBean(MbObjectApplicationsSearch.class);
			mbAppObjects.setObjectId(_activeAccount.getId().longValue());
			mbAppObjects.setEntityType(EntityNames.ACCOUNT);
//			mbObjectDocuments.setBackLink(thisBackLink);
			mbAppObjects.search();
		} else if (tab.equalsIgnoreCase("suitesTab")) {
			MbFraudObjects fraudObjectsBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
			fraudObjectsBean.setObjectId(_activeAccount.getId().longValue());
			fraudObjectsBean.setEntityType(EntityNames.ACCOUNT);
			fraudObjectsBean.search();
		} else if (tab.equalsIgnoreCase("reportTab")){
			MbReportsBottom reportsBean = (MbReportsBottom) ManagedBeanWrapper
					.getManagedBean("MbReportsBottom");
			reportsBean.setEntityType(EntityNames.ACCOUNT);
			reportsBean.setObjectType(_activeAccount.getAccountType());
			reportsBean.setObjectId(_activeAccount.getId());
			reportsBean.search();
		} else if (tab.equalsIgnoreCase("info")){
			MbEntityObjectInfoBottom infoBean = (MbEntityObjectInfoBottom) ManagedBeanWrapper
					.getManagedBean("MbEntityObjectInfoBottom");
			infoBean.setEntityType(EntityNames.ACCOUNT);
			infoBean.setObjectType(_activeAccount.getAccountType());
			infoBean.setObjectId(_activeAccount.getId());
			infoBean.search();
		} else if (tab.equalsIgnoreCase("creditTab") && isCreditAccount()){
			MbCreditAccountDetails creditAccount = (MbCreditAccountDetails)ManagedBeanWrapper
					.getManagedBean(MbCreditAccountDetails.class);
			creditAccount.getFilter().setAccountId(_activeAccount.getId());
			creditAccount.search();
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

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
		sessionBean.setModule(module);
		if (ModuleNames.ACQUIRING.equals(module)) {
			thisBackLink = ACQUIRING_BACKLINK;
		} else {
			thisBackLink = ISSUING_BACKLINK;
		}

	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Account();
				setFilterForm(filterRec);
				if (searchAutomatically)
					search();
			}

			sectionFilterModeEdit = true;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("accNum") != null) {
			filter.setAccountNumber(filterRec.get("accNum"));
		}
		if (filterRec.get("entityType") != null) {
			filter.setEntityType(filterRec.get("entityType"));
		}
		if (filterRec.get("objectId") != null) {
			filter.setObjectId(Long.valueOf(filterRec.get("objectId")));
		}
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("accType") != null) {
			filter.setAccountType(filterRec.get("accType"));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		if (filterRec.get("currency") != null) {
			filter.setCurrency(filterRec.get("currency"));
		}

		if (filterRec.get("customerNumber") != null) {
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}

		if (filterRec.get("custInfo") != null) {
			filter.setCustInfo(filterRec.get("custInfo"));
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

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

	private void setFilterRec(Map<String, String> filterRec) {

		if (filter.getAccountNumber() != null && filter.getAccountNumber().trim().length() > 0) {
			filterRec.put("accNum", filter.getAccountNumber());
		}
		if (filter.getEntityType() != null && filter.getEntityType().trim().length() > 0) {
			filterRec.put("entityType", filter.getEntityType());
		}
		if (filter.getObjectId() != null) {
			filterRec.put("objectId", filter.getObjectId().toString());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getAccountType() != null && filter.getAccountType().trim().length() > 0) {
			filterRec.put("accType", filter.getAccountType());
		}

		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			filterRec.put("status", filter.getStatus());
		}

		if (filter.getCurrency() != null && filter.getCurrency().trim().length() > 0) {
			filterRec.put("currency", filter.getCurrency());
		}

		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}

		if (filter.getCustInfo() != null && filter.getCustInfo().trim().length() > 0) {
			filterRec.put("custInfo", filter.getCustInfo());
		}
	}

	public String getSectionId() {
		if (isIssuingType()) {
			return SectionIdConstants.ISSUING_ACCOUNT;
		} else {
			return SectionIdConstants.ACQUIRING_ACCOUNT;
		}
	}

	public String getComponentId() {
		return getSectionId() + ":" + COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		if (getFilter().getInstId() != null) {
			custBean.setBlockInstId(true);
			custBean.setDefaultInstId(getFilter().getInstId());
		} else {
			custBean.setBlockInstId(false);
		}
	}

	public void selectCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			getFilter().setCustomerNumber(selected.getCustomerNumber());
			getFilter().setCustomerId(selected.getId());
			getFilter().setCustInfo(selected.getName());
			getFilter().setInstId(custBean.getFilter().getInstId());
		}
	}

	/**
	 * Initializes bean's filter if bean has been accessed by context menu.
	 */
	private void initFilterFromContext() {
		filter = new Account();
		if (FacesUtils.getSessionMapValue("customerNumber") != null) {
			filter.setCustomerNumber((String) FacesUtils.getSessionMapValue("customerNumber"));
			filter.setCustInfo((String) FacesUtils.getSessionMapValue("customerNumber"));
			FacesUtils.setSessionMapValue("customerNumber", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("accountNumber") != null){
			filter.setAccountNumber((String)FacesUtils.getSessionMapValue("accountNumber"));
			FacesUtils.setSessionMapValue("accountNumber", null);
		}
	}

	public String back() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public boolean isShowBackBtn() {
		return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
	}

	public void displayCustInfo() {
		
		if (getFilter().getCustInfo() == null || "".equals(getFilter().getCustInfo())) {
			getFilter().setCustomerNumber(null);
			getFilter().setCustomerId(null);
			return;
		}
		
		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getFilter().getCustInfo());
		if (m.find() || getFilter().getInstId() == null) {
			getFilter().setCustomerNumber(getFilter().getCustInfo());
			return;
		}
		
		// search and redisplay		
		Filter[] filters  = new Filter[3];
		filters[0] = new Filter("LANG", curLang);
		filters[1] = new Filter("INST_ID", getFilter().getInstId());
		filters[2] = new Filter("CUSTOMER_NUMBER", getFilter().getCustInfo());
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] cust = _productsDao.getCombinedCustomersProc(userSessionId, params, "CUSTOMER");
			if (cust != null && cust.length > 0) {
				getFilter().setCustInfo(cust[0].getName());
				getFilter().setCustomerNumber(cust[0].getCustomerNumber());
				getFilter().setCustomerId(cust[0].getId());
			} else {
				getFilter().setCustomerNumber(getFilter().getCustInfo());
				getFilter().setCustomerId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	/**
	 * <p>
	 * Gets and sets (if needed) actual account type if user moved from one account form to another
	 * because there are possible situations when user changed form (e.g. moved from acquiring
	 * accounts to issuing) but the bean wasn't destroyed and account type remained the same. One
	 * needs to read this parameter from form by placing hidden input on its top.
	 * </p>
	 * 
	 * @return
	 */
	public String getModuleHidden() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (this.module == null || menu.isClicked()) {
			String module = getModuleFromRequest();
			if (!module.equals(this.module)) {
				// if it's another account form then we need to clear all form's data
				clearFilter();
			}
			this.module = module;
		}
		return module;
	}

	private String getModuleFromRequest() {
		String module = FacesUtils.getRequestParameter("module");
		if (module != null) {
			module = module.toUpperCase();
		} else {
			module = (String) FacesUtils.getSessionMapValue("module");
			FacesUtils.setSessionMapValue("module", null);
		}
		if (ModuleNames.ISSUING.equalsIgnoreCase(module)) {
			module = ModuleNames.ISSUING;
		} else if (ModuleNames.ACQUIRING.equalsIgnoreCase(module)) {
			// it doesn't mean that acquiring accounts don't need module
			// it means that if module isn't set then we show acquiring
			// accounts
			module = ModuleNames.ACQUIRING;
		} else {
			module = sessionBean.getModule() == null ? ModuleNames.ISSUING : sessionBean.getModule();
		}

		return module;
	}

	public String getFilename(String extension) {
		GregorianCalendar gc = new GregorianCalendar();

		return "" + gc.get(Calendar.YEAR) + (gc.get(Calendar.MONTH) + 1)
				+ gc.get(Calendar.DAY_OF_MONTH) + "." + extension;
	}
	
	public String exportData() {
		SelectionParams params = null;
		OutputStream outStream = null;
		try {
			params = new SelectionParams();
			setFilters();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(Integer.MAX_VALUE);
			if (isIssuingType()) {
				QueryResult qr = _accountsDao.getIssAccountsRs(userSessionId, params);
				outStream = new ByteArrayOutputStream();
				executeSimpleReport(qr, outStream);
				String filename = "export_data";
				filename = getFilename("xls");
				HttpServletResponse res = RequestContextHolder.getResponse();
				res.setContentType("application/x-download");
				String URLEncodedFileName = URLEncoder.encode(filename, "UTF-8");
				res.setHeader("Content-Disposition", "attachment; filename*=\"utf8''" +
						URLEncodedFileName + "\"");

				res.getOutputStream().write(((ByteArrayOutputStream) outStream).toByteArray());				
				FacesContext.getCurrentInstance().responseComplete();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return "ok";
	}

	private void executeSimpleReport(QueryResult data, OutputStream out) throws Exception {
		HSSFWorkbook wb = new HSSFWorkbook();
		HSSFSheet sheet = wb.createSheet("Data");
		int i = 0, j = 0;
		HSSFRow row = sheet.createRow(i++);
		for (String columnName : data.getFieldNames()) {
			row.createCell(j++).setCellValue(new HSSFRichTextString(columnName));
		}
		j = 0;
		for (HashMap<String, String> map : data.getFields()) {
			row = sheet.createRow(i++);
			for (String columnName : data.getFieldNames()) {
				row.createCell(j++).setCellValue(new HSSFRichTextString(map.get(columnName)));
			}
			j = 0;
		}
		wb.write(out);
	}
	
	public void restoreBean() {
		filter = sessionBean.getFilter();
		_activeAccount = sessionBean.getActiveAccount();
		backLink = sessionBean.getBackLink();
		tabName = sessionBean.getTabName();
		rowsNum = sessionBean.getRowsNum();
		pageNumber = sessionBean.getPageNumber();
		setModule(sessionBean.getModule());
		
		if (_activeAccount != null) {
			searching = true;
			setInfo(true);
		}
		
		FacesUtils.setSessionMapValue(ACQUIRING_BACKLINK, Boolean.FALSE);
		FacesUtils.setSessionMapValue(ISSUING_BACKLINK, Boolean.FALSE);
		
		FacesUtils.setSessionMapValue(thisBackLink + "RESTORE_AGAIN", Boolean.TRUE);
		FacesUtils.setSessionMapValue("RESTORE_TIME", System.currentTimeMillis());	
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		Integer defaultInstId = null;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		} else {
			defaultInstId = userInstId;
		}
		filter = new Account();
		filter.setInstId(defaultInstId);
	}
	
	/**
	 * Wizard engine call this method after a wizard is finished
	 */
	public void updateAccounts(){
		Account updatedAccount = null;
		Map<String, Object> params = new HashMap<String, Object>();
		SelectionParams sp = SelectionParams.build("ACCOUNT_ID", _activeAccount.getId(), "LANG", curLang, "PARTICIPANT_MODE", isAcquiringType()?"ACQ":"ISS");
		
		params.put("param_tab", sp.getFilters());
        params.put("tab_name", "ACCOUNT");
		Account[] accs;
		
		accs = _accountsDao.getAccountsCur(userSessionId, sp, params);
		if (accs.length != 0){
			updatedAccount = accs[0];
		}
		try {
			_accountsSource.replaceObject(_activeAccount, updatedAccount);
			_activeAccount = updatedAccount;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		loadCurrentTab();
	}
	
	public void setupOperTypeSelection(){
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr","select_oper_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);
		context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.ACCOUNT);
		context.put(MbOperTypeSelectionStep.OBJECT_ID, _activeAccount.getId());
		context.put(MbOperTypeSelectionStep.ENTITY_OBJECT_TYPE, _activeAccount.getAccountType());

		context.put("INST_ID", _activeAccount.getInstId());
		if (isIssuingType()){
			context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
		}else if (isAcquiringType()){
			context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ACQ_PARTICIPANT);
		}
		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);		
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		
		if (_activeAccount != null){
			if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
				map.put("id", _activeAccount.getInstId());
				map.put("instId", _activeAccount.getInstId());
			}
			if (EntityNames.ACCOUNT.equals(ctxItemEntityType)) {
				map.put("id", _activeAccount.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.CARD);
	}

	public String getAppType() {
		if (isAcquiringType()){
			return ACQUIRING;
		}else{
			return ISSUING;
		}
		
	}

	public void setAppType(String appType) {
		this.appType = appType;
	}
	
	public HashMap<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(HashMap<String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	public boolean isCreditAccount() {
		if (_activeAccount != null && _activeAccount.getAccountType() != null && _activeAccount.getAccountType().equals(CREDIT_ACCOUNT_TYPE))
			return true;
		return false;
	}

    public void onSortablePreRenderTable() {
        onSortablePreRenderTable(_accountsSource);
    }

    public Account loadAccount() {
        _activeAccount = null;

        setFilters();
        SelectionParams params = new SelectionParams();
        params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));

        try {
            setFilters();
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            Account[] accounts =  _accountsDao.getAccountsCur(userSessionId, params, paramMap);
            if (accounts.length > 0) {
                _activeAccount = accounts[0];
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return _activeAccount;
    }
}

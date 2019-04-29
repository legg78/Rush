package ru.bpc.sv2.ui.fraud;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fraud.MonitoredFraudAlert;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.operations.incoming.Operation;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.operations.MbOperations;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbFraudAlertMonitoring")
public class MbFraudAlertMonitoring extends AbstractBean {
	private static final long serialVersionUID = -993076043131591045L;
	
	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");
	private static String COMPONENT_ID = "2277:alertsTable";

	private static final String SEARCH_TAB_AUTH = "authTab";
	private static final String SEARCH_TAB_CARD = "cardTab";
	private static final String SEARCH_TAB_ACCOUNT = "accountTab";
	private static final String SEARCH_TAB_TERMINAL = "terminalTab";
	
	private FraudDao _fraudDao = new FraudDao();

	private MonitoredFraudAlert filter;

	private final DaoDataModel<MonitoredFraudAlert> _alertsSource;
	private final TableRowSelection<MonitoredFraudAlert> _itemSelection;
	private MonitoredFraudAlert _activeFraudAlert;

	private String tabName;
	private final String defaultTabName = "detailsTab";
	private String searchTabName;

	private ArrayList<SelectItem> institutions;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	private ArrayList<SelectItem> resolutions;

	private AcmAction selectedCtxItem;
	private String ctxItemEntityType;

	// filters
	private Card filterCard;
	private Account filterAccount;
	private Terminal filterTerminal;
	private Operation filterAuth;
	
	private Date authDateFrom;
	private Date authDateTo;
	private Date cardDateFrom;
	private Date cardDateTo;
	private Date accDateFrom;
	private Date accDateTo;
	private Date termDateFrom;
	private Date termDateTo;

	private BigDecimal authAmountFrom;
	private BigDecimal authAmountTo;
	
	public MonitoredFraudAlert newFraud;
	// end filters
	
	public MbFraudAlertMonitoring() {
		pageLink = "fraud|alerts";
		tabName = defaultTabName;
		thisBackLink = "fraud|alerts";
		
		_alertsSource = new DaoDataModel<MonitoredFraudAlert>() {
			private static final long serialVersionUID = 5168175217200438246L;

			@Override
			protected MonitoredFraudAlert[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new MonitoredFraudAlert[0];
				}
				try {
					String tabNameParam = setFilters();
					if (tabNameParam != null) {
						return _fraudDao.getMonitoredFraudAlerts(userSessionId, params,
								tabNameParam);
					}
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new MonitoredFraudAlert[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (tabNameParam != null) {
						return _fraudDao.getMonitoredFraudAlertsCount(userSessionId, params,
								tabNameParam);
					}
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<MonitoredFraudAlert>(null, _alertsSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");
		setSearchTabName(SEARCH_TAB_AUTH);

		if (sectionId != null && filterId != null && sectionId.equals("1677")) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public DaoDataModel<MonitoredFraudAlert> getFraudAlerts() {
		return _alertsSource;
	}

	public MonitoredFraudAlert getActiveFraudAlert() {
		return _activeFraudAlert;
	}

	public void setActiveFraudAlert(MonitoredFraudAlert activeFraudAlert) {
		_activeFraudAlert = activeFraudAlert;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeFraudAlert == null && _alertsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeFraudAlert != null && _alertsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeFraudAlert.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeFraudAlert = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFraudAlert = _itemSelection.getSingleSelection();
		/*
		if (_activeFraudAlert != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(_activeFraudAlert.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			try {
				FraudAlert[] custArr = _fraudDao.getFraudAlerts(userSessionId, params,
						curLang);

				if (custArr != null && custArr.length > 0) {
					_activeFraudAlert = custArr[0];
				} else {
					_activeFraudAlert = null;
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
			*/
			if (_activeFraudAlert != null) {
				setBeans();
			}
	//	}
	}

	public void setFirstRowActive() {
		_alertsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFraudAlert = (MonitoredFraudAlert) _alertsSource.getRowData();
		selection.addKey(_activeFraudAlert.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName(), false);	
	}

	public String setFilters() {
		if (isSearchFraudAlertByAuthorization()) {
			setFiltersAuth();
			return "AUTHORIZATION";
		} else if (isSearchFraudAlertByCard()) {
			setFiltersCard();
			return "CARD";
		} else if (isSearchFraudAlertByAccount()) {
			setFiltersAccount();
			return "ACCOUNT";
		} else if (isSearchFraudAlertByTerminal()) {
			setFiltersTerminal();
			return "TERMINAL";
		} else {
			return null;
		}
	}

	public void setFiltersAuth() {
		getFilterAuth();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (authDateFrom != null) {
			paramFilter = new Filter("OPER_DATE", authDateFrom);
			paramFilter.setCondition(">=");
			filters.add(paramFilter);
		}
		if (authDateTo != null) {
			paramFilter = new Filter("OPER_DATE", authDateTo);
			paramFilter.setCondition("<=");
			filters.add(paramFilter);
		}
		if (authAmountFrom != null) {
			paramFilter = new Filter("OPER_AMOUNT", authAmountFrom);
			paramFilter.setCondition(">=");
			filters.add(paramFilter);
		}
		if (authAmountTo != null) {
			paramFilter = new Filter("OPER_AMOUNT", authAmountTo);
			paramFilter.setCondition("<=");
			filters.add(paramFilter);
		}
		if (filterAuth.getMccCode() != null) {
			filters.add(new Filter("MCC", filterAuth.getMccCode()));
		}
		if (filterAuth.getOperType() != null) {
			filters.add(new Filter("OPER_TYPE", filterAuth.getOperType()));
		}
		if (filterAuth.getOperationCurrency() != null) {
			filters.add(new Filter("OPER_CURRENCY", filterAuth.getOperationCurrency()));
		}
	}
	
	public void setFiltersCard() {
		getFilterCard();
		filters = new ArrayList<Filter>();

		Filter paramFilter;

		if (filterCard.getCardNumber() != null && filterCard.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_NUMBER");
			paramFilter.setValue(filterCard.getCardNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (cardDateFrom != null) {
			paramFilter = new Filter("OPER_DATE", cardDateFrom);
			paramFilter.setCondition(">=");
			filters.add(paramFilter);
		}
		if (cardDateTo != null) {
			paramFilter = new Filter("OPER_DATE", cardDateTo);
			paramFilter.setCondition("<=");
			filters.add(paramFilter);
		}
	}

	public void setFiltersAccount() {
		getFilterAccount();
		filters = new ArrayList<Filter>();

		Filter paramFilter;

		if (filterAccount.getInstId() != null) {
			filters.add(new Filter("INST_ID", filterAccount.getInstId()));
		}
		if (filterAccount.getAccountNumber() != null &&
				filterAccount.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setValue(filterAccount.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (accDateFrom != null) {
			paramFilter = new Filter("OPER_DATE", accDateFrom);
			paramFilter.setCondition(">=");
			filters.add(paramFilter);
		}
		if (accDateTo != null) {
			paramFilter = new Filter("OPER_DATE", accDateTo);
			paramFilter.setCondition("<=");
			filters.add(paramFilter);
		}
	}

	public void setFiltersTerminal() {
		getFilterTerminal();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filterTerminal.getInstId() != null) {
			filters.add(new Filter("INST_ID", filterTerminal.getInstId()));
		}
		if (filterTerminal.getTerminalNumber() != null &&
				filterTerminal.getTerminalNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("TERMINAL_NUMBER");
			paramFilter.setValue(filterTerminal.getTerminalNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (termDateFrom != null) {
			paramFilter = new Filter("OPER_DATE", termDateFrom);
			paramFilter.setCondition(">=");
			filters.add(paramFilter);
		}
		if (termDateTo != null) {
			paramFilter = new Filter("OPER_DATE", termDateTo);
			paramFilter.setCondition("<=");
			filters.add(paramFilter);
		}
	}

	public MonitoredFraudAlert getFilter() {
		if (filter == null) {
			filter = new MonitoredFraudAlert();
		}
		return filter;
	}

	public void setFilter(MonitoredFraudAlert filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		filterAuth = null;
		filterTerminal = null;
		filterAccount = null;
		filterCard = null;
		
		authAmountFrom = null;
		authAmountTo = null;
		authDateFrom = null;
		authDateTo = null;
		cardDateFrom = null;
		cardDateTo = null;
		accDateFrom = null;
		accDateTo = null;
		termDateFrom = null;
		termDateTo = null;
		
		clearBean();
		clearSectionFilter();
		// tabName = defaultTabName;
		searching = false;
	}

	public void searchByAuthorization() {
		getFilter().setEntityType(EntityNames.AUTHORIZATION);
		search();
	}
	
	public void searchByCard() {
		getFilter().setEntityType(EntityNames.CARD);
		search();
	}

	public void searchByAccount() {
		getFilter().setEntityType(EntityNames.ACCOUNT);
		search();
	}

	public void searchByTerminal() {
		getFilter().setEntityType(EntityNames.TERMINAL);
		search();
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void clearBean() {
		curLang = userLang;
		_alertsSource.flushCache();
		_itemSelection.clearSelection();
		loadedTabs.clear();
		_activeFraudAlert = null;
		clearBeansStates();
	}

	private void clearBeansStates() {
		MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
				.getManagedBean("MbCardsBottomSearch");
		cardsSearch.clearFilter();
		
		MbTerminalsBottom terminalsSearch = (MbTerminalsBottom) ManagedBeanWrapper
				.getManagedBean("MbTerminalsBottom");
		terminalsSearch.clearFilter();
		
		MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
				.getManagedBean("MbAccountsSearch");
		accsSearch.clearFilter();
		
		MbOperations operSearch = (MbOperations) ManagedBeanWrapper
				.getManagedBean("MbOperations");
		operSearch.clearFilter();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
	}

	public void loadCurrentTab() {
		loadTab(tabName, false);
	}

	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (_activeFraudAlert == null || _activeFraudAlert.getId() == null) {
			return;
		}
		try {
			if (tab.equalsIgnoreCase("cardsTab")) {
				MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
						.getManagedBean("MbCardsBottomSearch");
				cardsSearch.clearFilter();
				cardsSearch.getFilter().setAuthId(_activeFraudAlert.getAuthId());
				prepareCardFilter();
				cardsSearch.loadCard();
			} else if (tab.equalsIgnoreCase("terminalsTab")) {
				MbTerminalsBottom terminalsSearch = (MbTerminalsBottom) ManagedBeanWrapper
						.getManagedBean("MbTerminalsBottom");
				terminalsSearch.clearFilter();
				terminalsSearch.getFilterTerm().setAuthId(_activeFraudAlert.getAuthId());
				terminalsSearch.loadTerminal();
			} else if (tab.equalsIgnoreCase("accountsTab")) {
				MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
						.getManagedBean("MbAccountsSearch");
				accsSearch.clearFilter();
				accsSearch.getFilter().setAuthId(_activeFraudAlert.getAuthId());
				accsSearch.loadAccount();
			} else if (tab.equalsIgnoreCase("authDetailsTab")) {
				MbOperations operSearch = (MbOperations) ManagedBeanWrapper
						.getManagedBean("MbOperations");
				operSearch.clearFilter();
				operSearch.getFilter().setAuthId(_activeFraudAlert.getAuthId());
				operSearch.loadOperation();
			}
			needRerender = tab;
			loadedTabs.put(tab, Boolean.TRUE);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
	private void prepareCardFilter(){
		HashMap<String, Object> queueFilter = new HashMap<String, Object>();
		queueFilter.put("entityType", getFilter().getEntityType());
		queueFilter.put("accountFilter", filterAccount);
		queueFilter.put("operationFilter", filterAuth);
		queueFilter.put("cardFilter", filterCard);
		queueFilter.put("terminalFilter", filterTerminal);
		queueFilter.put("backLink", pageLink);
		addFilterToQueue("MbCardsBottomSearch", queueFilter);
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
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getFraudAlertTypes() {
		return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES);
	}

	public List<SelectItem> getIdTypes() {
		return getDictUtils().getLov(LovConstants.DOCUMENT_TYPES);
	}

	/**
	 * <p>
	 * Loads alert by <code>ID</code> into bean as <code>activeFraudAlert</code> and
	 * returns it.
	 * </p>
	 * 
	 * @return found alert or empty alert if no alert was found.
	 */
	/*
	public FraudAlert getFraudAlert(Long customerId) {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(customerId);

			params.setFilters(filters);
			FraudAlert[] customers = _fraudDao.getFraudAlerts(userSessionId, params, curLang);
			if (customers != null && customers.length > 0) {
				_activeFraudAlert = customers[0];
			} else {
				_activeFraudAlert = null;
			}
			return _activeFraudAlert;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
		return new FraudAlert();
	}
	 */
	public ArrayList<SelectItem> getGenders() {
		return getDictUtils().getArticles(DictNames.PERSON_GENDER, false, false);
	}

	public Card getFilterCard() {
		if (filterCard == null) {
			filterCard = new Card();
		}
		return filterCard;
	}

	public void setFilterCard(Card filterCard) {
		this.filterCard = filterCard;
	}

	public Account getFilterAccount() {
		if (filterAccount == null) {
			filterAccount = new Account();
			filterAccount.setInstId(userInstId);
		}
		return filterAccount;
	}

	public void setFilterAccount(Account filterAccount) {
		this.filterAccount = filterAccount;
	}

	public Terminal getFilterTerminal() {
		if (filterTerminal == null) {
			filterTerminal = new Terminal();
			filterTerminal.setInstId(userInstId);
		}
		return filterTerminal;
	}

	public void setFilterTerminal(Terminal filterTerminal) {
		this.filterTerminal = filterTerminal;
	}

	public List<SelectItem> getCardTypes() {
		return getDictUtils().getLov(LovConstants.CARD_TYPES);
	}

	public List<SelectItem> getAccountStatuses() {
		return getDictUtils().getLov(LovConstants.ACCOUNT_STATUSES);
	}

	public List<SelectItem> getTerminalTypes() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, true, true);
	}

	public List<SelectItem> getTerminalStatuses() {
		return getDictUtils().getArticles(DictNames.TERMINAL_STATUS, true, true);
	}

	public List<SelectItem> getMccs() {
		return getDictUtils().getLov(LovConstants.MCC);
	}

	private boolean isSearchFraudAlertByAuthorization() {
		return EntityNames.AUTHORIZATION.equals(filter.getEntityType());
	}

	private boolean isSearchFraudAlertByCard() {
		return EntityNames.CARD.equals(filter.getEntityType());
	}

	private boolean isSearchFraudAlertByAccount() {
		return EntityNames.ACCOUNT.equals(filter.getEntityType());
	}

	private boolean isSearchFraudAlertByTerminal() {
		return EntityNames.TERMINAL.equals(filter.getEntityType());
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
		// sessBean.setSearchTabName(searchTabName);
	}

	public void switchTab() {
		// initialize again when switch tab
		if (SEARCH_TAB_AUTH.equals(searchTabName)) {
			filter = new MonitoredFraudAlert();			
		} else if (SEARCH_TAB_CARD.equals(searchTabName)) {
			filterCard = new Card();
			filterCard.setInstId(userInstId);
		} else if (SEARCH_TAB_ACCOUNT.equals(searchTabName)) {
			filterAccount = new Account();
			filterAccount.setInstId(userInstId);
		} else if (SEARCH_TAB_TERMINAL.equals(searchTabName)) {
			filterTerminal = new Terminal();
			filterTerminal.setInstId(userInstId);
		}
		sectionFilterModeEdit = false;
		selectedSectionFilter = null;
		sectionFilter = null;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new MonitoredFraudAlert();
				if (filterRec.get("searchTabName") != null) {
					searchTabName = filterRec.get("searchTabName");
				}
				if (SEARCH_TAB_AUTH.equals(searchTabName)) {
					setFilterFormFraudAlert(filterRec);
					if (searchAutomatically)
						searchByAuthorization();
				} else if (SEARCH_TAB_CARD.equals(searchTabName)) {
					setFilterFormCard(filterRec);
					if (searchAutomatically)
						searchByCard();
				} else if (SEARCH_TAB_ACCOUNT.equals(searchTabName)) {
					setFilterFormAccount(filterRec);
					if (searchAutomatically)
						searchByAccount();
				} else if (SEARCH_TAB_TERMINAL.equals(searchTabName)) {
					setFilterFormTerminal(filterRec);
					if (searchAutomatically)
						searchByTerminal();
				}
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
			if (SEARCH_TAB_AUTH.equals(searchTabName)) {
				setFilterRecFraudAlert(filterRec);
			} else if (SEARCH_TAB_CARD.equals(searchTabName)) {
				setFilterRecCards(filterRec);
			} else if (SEARCH_TAB_ACCOUNT.equals(searchTabName)) {
				setFilterRecAccount(filterRec);
			} else if (SEARCH_TAB_TERMINAL.equals(searchTabName)) {
				setFilterRecTerminal(filterRec);
			}
			filterRec.put("searchTabName", searchTabName);

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

	private void setFilterFormFraudAlert(Map<String, String> filterRec) throws ParseException {
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("operationCurrency") != null){
			filterAuth.setOperationCurrency(filterRec.get("operationCurrency"));
		}
		if (filterRec.get("authAmountFrom") != null){
			setAuthAmountFrom(new BigDecimal(filterRec.get("authAmountFrom")));
		}
		if (filterRec.get("authAmountTo") != null){
			setAuthAmountTo(new BigDecimal(filterRec.get("authAmountTo")));
		}
		if (filterRec.get("authDateFrom") != null){
			setAuthDateFrom(df.parse(filterRec.get("authDateFrom")));
		}
		if (filterRec.get("authDateTo") != null){
			setAuthDateTo(df.parse(filterRec.get("authDateTo")));
		}
		if (filterRec.get("operType") != null){
			filterAuth.setOperType(filterRec.get("operType"));
		}
		if (filterRec.get("mccCode") != null){
			filterAuth.setMccCode(filterRec.get("mccCode"));
		}
	}

	private void setFilterFormCard(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("instId") != null) {
			filterCard.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filterCard.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("cardTypeId") != null) {
			filterCard.setCardTypeId(Integer.valueOf(filterRec.get("cardTypeId")));
		}
		if (filterRec.get("cardNumber") != null) {
			filterCard.setCardNumber(filterRec.get("cardNumber"));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("cardExpDate") != null) {
			filterCard.setExpDate(df.parse(filterRec.get("cardExpDate")));
		}
	}

	private void setFilterFormAccount(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filterAccount.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filterAccount.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("accountNumber") != null) {
			filterAccount.setAccountNumber(filterRec.get("accountNumber"));
		}
	}

	private void setFilterFormTerminal(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filterTerminal.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filterTerminal.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("terminalNumber") != null) {
			filterTerminal.setTerminalNumber(filterRec.get("terminalNumber"));
		}
	}

	private void setFilterRecFraudAlert(Map<String, String> filterRec) {
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);

		if (filterAuth.getOperationCurrency() != null) {
			filterRec.put("operationCurrency", filterAuth.getOperationCurrency());
		}
		if (getAuthAmountFrom() != null) {
			filterRec.put("authAmountFrom", getAuthAmountFrom().toString());
		}
		if (getAuthAmountTo() != null) {
			filterRec.put("authAmountTo", getAuthAmountTo().toString());
		}
		if (getAuthDateFrom() != null ) {
			filterRec.put("authDateFrom", df.format(getAuthDateFrom()));
		}
		if (getAuthDateTo() != null ) {
			filterRec.put("authDateTo", df.format(getAuthDateTo()));
		}
		if (filterAuth.getOperType() != null && filterAuth.getOperType().length() > 0) {
			filterRec.put("operType", filterAuth.getOperType());
		}
		if (filterAuth.getMccCode() != null && filterAuth.getMccCode().length() > 0){
			filterRec.put("mccCode", filterAuth.getMccCode());
		}

	}
	
	private void setFilterRecCards(Map<String, String> filterRec) {
		if (filterCard.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filterCard.getInstId()));
		}
		if (filterCard.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filterCard.getAgentId()));
		}
		if (filterCard.getCardTypeId() != null) {
			filterRec.put("cardTypeId", String.valueOf(filterCard.getCardTypeId()));
		}
		if (filterCard.getCardNumber() != null && filterCard.getCardNumber().trim().length() > 0) {
			filterRec.put("cardNumber", filterCard.getCardNumber());
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterCard.getExpDate() != null) {
			filterRec.put("cardExpDate", df.format(filterCard.getExpDate()));
		}
	}

	private void setFilterRecAccount(Map<String, String> filterRec) {
		if (filterAccount.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filterAccount.getInstId()));
		}
		if (filterAccount.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filterAccount.getAgentId()));
		}
		if (filterAccount.getAccountNumber() != null &&
				filterAccount.getAccountNumber().trim().length() > 0) {
			filterRec.put("accountNumber", filterAccount.getAccountNumber());
		}
	}

	private void setFilterRecTerminal(Map<String, String> filterRec) {
		if (filterTerminal.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filterTerminal.getInstId()));
		}
		if (filterTerminal.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filterTerminal.getAgentId()));
		}
		if (filterTerminal.getTerminalNumber() != null &&
				filterTerminal.getTerminalNumber().trim().length() > 0) {
			filterRec.put("terminalNumber", String.valueOf(filterTerminal.getTerminalNumber()));
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);
		ctxBean.initCtxParams(EntityNames.CUSTOMER, _activeFraudAlert.getId());

		if (EntityNames.PERSON.equals(ctxItemEntityType)) {
			FacesUtils.setSessionMapValue("module", "iss");
		} else if (EntityNames.COMPANY.equals(ctxItemEntityType)) {
			FacesUtils.setSessionMapValue("module", "acq");
		}
		FacesUtils.setSessionMapValue("entityType", EntityNames.CUSTOMER);
		FacesUtils.setSessionMapValue("id", _activeFraudAlert.getId());
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", thisBackLink);
		// sessBean.setActiveFraudAlert(_activeFraudAlert);
		// sessBean.setFilter(filter);
		// sessBean.setPageNumber(pageNumber);
		// sessBean.setRowsNum(rowsNum);
		// sessBean.setTabName(tabName);
		// sessBean.setSearchTabName(searchTabName);

		return selectedCtxItem.getAction();
	}

	public AcmAction getSelectedCtxItem() {
		return selectedCtxItem;
	}

	public void setSelectedCtxItem(AcmAction selectedCtxItem) {
		this.selectedCtxItem = selectedCtxItem;
	}

	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType(String ctxItemEntityType) {
		this.ctxItemEntityType = ctxItemEntityType;
	}

	public String doDefaultAction() {
		MbContextMenu ctx = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		AcmAction action = ctx.getDefaultAction(_activeFraudAlert.getId().intValue());

		if (action != null) {
			selectedCtxItem = action;
			return ctxPageForward();
		}
		return "";
	}

	public Date getAuthDateFrom() {
		return authDateFrom;
	}

	public void setAuthDateFrom(Date authDateFrom) {
		this.authDateFrom = authDateFrom;
	}

	public Date getAuthDateTo() {
		return authDateTo;
	}

	public void setAuthDateTo(Date authDateTo) {
		this.authDateTo = authDateTo;
	}

	public Date getCardDateFrom() {
		return cardDateFrom;
	}

	public void setCardDateFrom(Date cardDateFrom) {
		this.cardDateFrom = cardDateFrom;
	}

	public Date getCardDateTo() {
		return cardDateTo;
	}

	public void setCardDateTo(Date cardDateTo) {
		this.cardDateTo = cardDateTo;
	}

	public Date getAccDateFrom() {
		return accDateFrom;
	}

	public void setAccDateFrom(Date accDateFrom) {
		this.accDateFrom = accDateFrom;
	}

	public Date getAccDateTo() {
		return accDateTo;
	}

	public void setAccDateTo(Date accDateTo) {
		this.accDateTo = accDateTo;
	}

	public Date getTermDateFrom() {
		return termDateFrom;
	}

	public void setTermDateFrom(Date termDateFrom) {
		this.termDateFrom = termDateFrom;
	}

	public Date getTermDateTo() {
		return termDateTo;
	}

	public void setTermDateTo(Date termDateTo) {
		this.termDateTo = termDateTo;
	}

	public BigDecimal getAuthAmountFrom() {
		return authAmountFrom;
	}

	public void setAuthAmountFrom(BigDecimal authAmountFrom) {
		this.authAmountFrom = authAmountFrom;
	}

	public BigDecimal getAuthAmountTo() {
		return authAmountTo;
	}

	public void setAuthAmountTo(BigDecimal authAmountTo) {
		this.authAmountTo = authAmountTo;
	}

	public Operation getFilterAuth() {
		if (filterAuth == null) {
			filterAuth = new Operation();
		}
		return filterAuth;
	}

	public void setFilterAuth(Operation filterAuth) {
		this.filterAuth = filterAuth;
	}
	
	public List<SelectItem> getOperTypes() {
		return getDictUtils().getArticles(DictNames.OPER_TYPE, false);
	}
	
	public void edit(){
		newFraud = (MonitoredFraudAlert) _activeFraudAlert.clone();
		curMode = EDIT_MODE;
		if (newFraud.getResolution()==null || newFraud.getResolution().equals("RSLTNVRF")){
			newFraud.setResolution("RSLTWORK");
			save();
		}
	}
	
	public void save(){
		try {
			newFraud = _fraudDao.modifyFraud(userSessionId, newFraud);
			_alertsSource.replaceObject(_activeFraudAlert, newFraud);
			curMode = VIEW_MODE;
			_activeFraudAlert = newFraud;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public ArrayList<SelectItem> getResolutions(){
		if (resolutions==null){
			resolutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.RESOLUTIONS);
		}
		return resolutions; 
	}

	public MonitoredFraudAlert getNewFraud() {
		return newFraud;
	}
	
	public boolean isDisabled(){
		UserSession usession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		if(_activeFraudAlert==null){
			return true; 
		}
		if(_activeFraudAlert.getResolutionUserId()!=null && !usession.getUser().getId().equals(_activeFraudAlert.getResolutionUserId())){
			return true;
		}
		if(_activeFraudAlert.getResolution()!=null && !_activeFraudAlert.getResolution().equals("RSLTWORK") && !_activeFraudAlert.getResolution().equals("RSLTNVRF")){
			return true;
		}
		return false;
	}
}

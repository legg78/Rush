package ru.bpc.sv2.ui.products;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.pmo.PaymentOrderPrivConstants;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoTemplate;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.accounts.MbObjectDocuments;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.acquiring.MbAcquiringHierarchyBottom;
import ru.bpc.sv2.ui.acquiring.MbMerchantsBottom;
import ru.bpc.sv2.ui.acquiring.MbRevenueSharingBottom;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactDataSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.MbObjectIdsSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.issuing.MbIssuingHierarchyBottom;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.notifications.MbNtfEventBottom;
import ru.bpc.sv2.ui.pmo.MbPmoPaymentOrders;
import ru.bpc.sv2.ui.pmo.MbPmoTemplates;
import ru.bpc.sv2.ui.scoring.MbScoringCalculation;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbCustomersNew")
public class MbCustomersNew extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private static String COMPONENT_ID = "1677:customersTable";
	private static String COMPONENT_TAB_ID = "1677:customersTabs";

	private static final String SEARCH_TAB_CUSTOMER = "customerTab";
	private static final String SEARCH_TAB_PERSON = "personTab";
	private static final String SEARCH_TAB_COMPANY = "companyTab";
	private static final String SEARCH_TAB_CONTRACT = "contractTab";
	private static final String SEARCH_TAB_CARD = "cardTab";
	private static final String SEARCH_TAB_ACCOUNT = "accountTab";
	private static final String SEARCH_TAB_MERCHANT = "merchantTab";
	private static final String SEARCH_TAB_TERMINAL = "terminalTab";
	private static final String SEARCH_TAB_DOCUMENT = "documentTab";
	private static final String SEARCH_TAB_CONTACT = "contactTab";
	private static final String SEARCH_TAB_ADDRESS = "addressTab";
//	private static final HashMap<String, String> tabsMap;
//	
//	static {
//		tabsMap = new HashMap<String, String>();
//		tabsMap.put(SEARCH_TAB_CUSTOMER, "detailsTab");
//		tabsMap.put(SEARCH_TAB_PERSON, "detailsTab");
//		tabsMap.put(SEARCH_TAB_COMPANY, "detailsTab");
//		tabsMap.put(SEARCH_TAB_CONTRACT, "contractsTab");
//		tabsMap.put(SEARCH_TAB_CARD, "cardsTab");
//		tabsMap.put(SEARCH_TAB_ACCOUNT, "accountsTab");
//		tabsMap.put(SEARCH_TAB_MERCHANT, "merchantsTab");
//		tabsMap.put(SEARCH_TAB_TERMINAL, "terminalsTab");
//		tabsMap.put(SEARCH_TAB_DOCUMENT, "personIdsTab");
//		tabsMap.put(SEARCH_TAB_CONTACT, "contactsTab");
//		tabsMap.put(SEARCH_TAB_ADDRESS, "addressesTab");
//	}
	
	private ProductsDao _productsDao = new ProductsDao();
	private EventsDao _eventsDao = new EventsDao();
	private NetworkDao _networkDao = new NetworkDao();

	private Customer filter;
	private Card filterCard;
	private Contract filterContract;
	private Account filterAccount;
	private Merchant filterMerchant;
	private Terminal filterTerminal;

	private Customer newCustomer;

	private final DaoDataModel<Customer> _customersSource;
	private final TableRowSelection<Customer> _itemSelection;
	private Customer _activeCustomer;

	protected String tabName;
	private final String defaultTabName = "detailsTab";
	private String searchTabName;

	private ArrayList<SelectItem> institutions;
	private List<SelectItem> idTypes;
	private List<SelectItem> mccs;
	private List<SelectItem> customerTypes;
	private ArrayList<SelectItem> merchantTypes;
	private List<SelectItem> accountStatuses;
	private ArrayList<SelectItem> terminalStatuses;
	private ArrayList<SelectItem> terminalTypes;
	private List<SelectItem> cardTypes;
	private ArrayList<SelectItem> imTypes;
	private ArrayList<SelectItem> genders;
	private List<SelectItem> extEntityTypes;
	
	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	protected String needRerender;
	private List<String> rerenderList;

	private boolean fromCard;

	protected MbCustomersSess sessBean;

	private AcmAction selectedCtxItem;
	private boolean beanRestored;
	private SortElement[] sort = null;

	private Map<String, Object> customerMap;
	private Map<String, Boolean> renderTabsMap;
	private List<String> backupSelectedTabs;

	private UserSession userSession;
	
	private ContextType ctxType;
	private String ctxItemEntityType;
	
	private boolean initedFromCtx;
	
	public MbCustomersNew() {
		pageLink = "products|customers";
		searchTabName = "customerTab";
		tabName = defaultTabName;
//		thisBackLink = "products|customers";
		userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
			
		sessBean = (MbCustomersSess) ManagedBeanWrapper.getManagedBean("MbCustomersSess");

		setDefaultValues();
		
		// 2-nd restore: to get shown information back in bean
		// FIXME: the stupidest way of doing things but it works, at least it seems so
		// (see also restoreBean()) perhaps it can be used without time check as bean is
		// destroyed everytime we return on the page so the situation when flag is set
		// but bean isn't destroyed seems to be impossible
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(pageLink + "RESTORE_AGAIN");
		Long restoreTime = (Long) FacesUtils.getSessionMapValue("RESTORE_TIME");
		if (restoreBean != null && restoreBean && restoreTime != null) {
			if (System.currentTimeMillis() - restoreTime < 20000) { // 10 secs not enough :(
				restoreBean();
			}
			FacesUtils.setSessionMapValue(pageLink + "RESTORE_AGAIN", null);
		}

		// 1-st restore: to show saved information
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(pageLink);
		if (restoreBean == null) {
			restoreBean = false;
		}
		if (restoreBean) {
			restoreBean();
		}

		_customersSource = new DaoDataModel<Customer>(true) {
			private static final long serialVersionUID = 1L;

			@Override
			protected Customer[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Customer[0];
				}
				try {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if ((getBeanRestored()) && (sort != null)){
						params.setSortElement(sort);
						sort = null;
					} else {
						sort = params.getSortElement();
					}
					if (tabNameParam != null) {
						return _productsDao.getCombinedCustomersProc(userSessionId,
								params, tabNameParam);
//						Customer[] customers = _productsDao.getCombinedCustomersProc(userSessionId,
//								params, tabNameParam);
//						if (customers.length > 0 && tabsMap.get(searchTabName) != null) {
//							tabName = tabsMap.get(searchTabName);
//						}
//						return customers;
					}
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new Customer[0];
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
						return _productsDao.getCombinedCustomersCountProc(userSessionId, params,
								tabNameParam);
					}
					return 0;
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					searching = false;
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<Customer>(null, _customersSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals("1677")) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	private void restoreBean() {
		tabName = sessBean.getTabName();
		searchTabName = sessBean.getSearchTabName();
		_activeCustomer = sessBean.getActiveCustomer();
		rowsNum = sessBean.getRowsNum();
		pageNumber = sessBean.getPageNumber();

		filter = sessBean.getFilter();
		filterCard = sessBean.getFilterCard();
		filterContract = sessBean.getFilterContract();
		filterAccount = sessBean.getFilterAccount();
		filterMerchant = sessBean.getFilterMerchant();
		filterTerminal = sessBean.getFilterTerminal();
		Boolean renderTabs = (Boolean) FacesUtils.getSessionMapValue("renderTabs");
		this.renderTabs = renderTabs == null ? false : renderTabs.booleanValue();

		sort = sessBean.getSort();
		searching = true;
		loadTab(tabName, true);
		
		

		FacesUtils.setSessionMapValue(pageLink, Boolean.FALSE);
		beanRestored = true;
		FacesUtils.setSessionMapValue(pageLink + "RESTORE_AGAIN", Boolean.TRUE);
		FacesUtils.setSessionMapValue("RESTORE_TIME", System.currentTimeMillis());
	}

	public DaoDataModel<Customer> getCustomers() {
		return _customersSource;
	}

	public Customer getActiveCustomer() {
		return _activeCustomer;
	}

	public void setActiveCustomer(Customer activeCustomer) {
		_activeCustomer = activeCustomer;
	}

	boolean setItemSelectionInternCall = false;
	
	public SimpleSelection getItemSelection() {
		try {
			setItemSelectionInternCall = true;
			if (_activeCustomer == null && _customersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCustomer != null && _customersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCustomer.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCustomer = _itemSelection.getSingleSelection();
				sessBean.setActiveCustomer(_activeCustomer);
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		} finally {
			setItemSelectionInternCall = false;
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCustomer = _itemSelection.getSingleSelection();
		sessBean.setActiveCustomer(_activeCustomer);
		tabName = sessBean.getTabName();
		loadCurrentTab();
	}
	
	public void prepareCustomer(){
		if (_activeCustomer != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(_activeCustomer.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			Customer[] custArr = new Customer[0];
			try {
				if (_activeCustomer.isCompanyCustomer()) {
					custArr = _productsDao.getCompanyCustomers(userSessionId, params, curLang);
				} else if (_activeCustomer.isPersonCustomer()) {
					custArr = _productsDao.getPersonCustomers(userSessionId, params, curLang);
				} else {
					custArr = _productsDao.getUndefinedCustomers(userSessionId, params, curLang);
				}	
				String agentName = null;
				String agentNumber = null;
				if (_activeCustomer.getAgentName() != null){
					agentName = _activeCustomer.getAgentName();
				}
				if (_activeCustomer.getAgentNumber() != null){
					agentNumber = _activeCustomer.getAgentNumber(); 
				}
				Integer maxAgingPeriod = _activeCustomer.getMaxAgingPeriod();
				if (custArr != null && custArr.length > 0) {
					_activeCustomer = custArr[0];
					_activeCustomer.setAgentName(agentName);
					_activeCustomer.setAgentNumber(agentNumber);
					_activeCustomer.setMaxAgingPeriod(maxAgingPeriod);
				} else {
					_activeCustomer = null;
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
			setRenderTabs(true);
			FacesUtils.setSessionMapValue("renderTabs", true);
		}
	}

	public void setFirstRowActive() {
		_customersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomer = (Customer) _customersSource.getRowData();
		selection.addKey(_activeCustomer.getModelId());
		setItemSelection(selection);
		
		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		// FacesContext context = FacesContext.getCurrentInstance();
		// boolean renderResponse = context.getRenderResponse();
		// if (renderResponse) {
		loadedTabs.clear();
		loadTab(getTabName(), false);
		// }
		sessBean.setActiveCustomer(_activeCustomer);
		sessBean.setCustomerSelection(_itemSelection.getWrappedSelection());
		sessBean.setFilter(filter);
		sessBean.setFilterContract(filterContract);
		sessBean.setFilterCard(filterCard);
		sessBean.setFilterAccount(filterAccount);
		sessBean.setFilterMerchant(filterMerchant);
		sessBean.setFilterTerminal(filterTerminal);
		sessBean.setPageNumber(pageNumber);
		sessBean.setRowsNum(rowsNum);
		sessBean.setTabName(tabName);
		sessBean.setSearchTabName(searchTabName);
		sessBean.setSort(sort);
	}

	public String setFilters() {
		if (isSearchCustomerByCustomer()) {
			setFiltersCustomer();
			return "CUSTOMER";
		} else if (isSearchCustomerByCompany()) {
			setFiltersCompany();
			return "COMPANY";
		} else if (isSearchCustomerByPerson()) {
			setFiltersPerson();
			return "PERSON";
		} else if (isSearchCustomerByContract()) {
			setFiltersContract();
			return "CUSTOMER";
		} else if (isSearchCustomerByCard()) {
			setFiltersCard();
			return "CARD";
		} else if (isSearchCustomerByAccount()) {
			setFiltersAccount();
			return "ACCOUNT";
		} else if (isSearchCustomerByMerchant()) {
			setFiltersMerchant();
			return "MERCHANT";
		} else if (isSearchCustomerByTerminal()) {
			setFiltersTerminal();
			return "TERMINAL";
		} else if (isSearchCustomerByAddress()) {
			setFiltersAddress();
			return "ADDRESS";
		} else if (isSearchCustomerByContact()) {
			setFiltersContact();
			return "CONTACT";
		} else if (isSearchCustomerByDocument()) {
			setFiltersDocument();
			return "ID_CARD";
		} else {
			filters = new ArrayList<Filter>();
			return null;
		}
	}

	public void setFiltersDocument() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}
		if (filter.getDocument().getEntityType() != null &&
				filter.getDocument().getEntityType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ENTITY_TYPE");
			paramFilter.setValue(filter.getDocument().getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdType() != null &&
				filter.getDocument().getIdType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ID_TYPE");
			paramFilter.setValue(filter.getDocument().getIdType());
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdNumber() != null &&
				filter.getDocument().getIdNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ID_NUMBER");
			paramFilter.setValue(filter.getDocument().getIdNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void setFiltersPerson() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filter.getPerson().getFirstName() != null &&
				filter.getPerson().getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("FIRST_NAME");
			paramFilter.setValue(filter.getPerson().getFirstName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getSurname() != null &&
				filter.getPerson().getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("SURNAME");
			paramFilter.setValue(filter.getPerson().getSurname().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getSecondName() != null &&
				filter.getPerson().getSecondName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("SECOND_NAME");
			paramFilter.setValue(filter.getPerson().getSecondName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getGender() != null &&
				filter.getPerson().getGender().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("GENDER");
			paramFilter.setValue(filter.getPerson().getGender().trim().toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPerson().getBirthday() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("BIRTHDAY");
			paramFilter.setValue(filter.getPerson().getBirthday());
			filters.add(paramFilter);
		}
	}

	public void setFiltersCustomer() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_NUMBER");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getExtEntityType() != null) {
			paramFilter = new Filter("EXT_ENTITY_TYPE", filter.getExtEntityType());
			filters.add(paramFilter);
		}
	}

	public void setFiltersCompany() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filter.getCompany().getLabel() != null &&
				filter.getCompany().getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("COMPANY_NAME");
			paramFilter.setValue(filter.getCompany().getLabel().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void setFiltersContract() {
		getFilterContract();
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filterContract.getStartDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_START_DATE_FROM");
			paramFilter.setValue(filterContract.getStartDate());
			filters.add(paramFilter);
		}
		if (filterContract.getEndDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_START_DATE_TILL");
			paramFilter.setValue(filterContract.getEndDate());
			filters.add(paramFilter);
		}
		if (filterContract.getContractNumber() != null &&
				filterContract.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_NUMBER");
			paramFilter.setValue(filterContract.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersCard() {
		getFilterCard();
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filterCard.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_TYPE_ID");
			paramFilter.setValue(filterCard.getCardTypeId());
			filters.add(paramFilter);
		}

		if (filterCard.getCardNumber() != null && filterCard.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_NUMBER");
			paramFilter.setValue(filterCard.getCardNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterCard.getExpDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("EXPIR_DATE");
			paramFilter.setValue(filterCard.getExpDate());
			filters.add(paramFilter);
		}
	}

	public void setFiltersAccount() {
		getFilterAccount();
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filterAccount.getAccountNumber() != null &&
				filterAccount.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setValue(filterAccount.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersMerchant() {
		getFilterMerchant();
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filterMerchant.getMerchantNumber() != null &&
				filterMerchant.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NUMBER");
			paramFilter.setValue(filterMerchant.getMerchantNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterMerchant.getMerchantName() != null &&
				filterMerchant.getMerchantName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NAME");
			paramFilter.setValue(filterMerchant.getMerchantName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterMerchant.getMerchantType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_TYPE");
			paramFilter.setValue(filterMerchant.getMerchantType());
			filters.add(paramFilter);
		}
	}

	public void setFiltersTerminal() {
		getFilterTerminal();
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filterTerminal.getTerminalNumber() != null &&
				filterTerminal.getTerminalNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("TERMINAL_NUMBER");
			paramFilter.setValue(filterTerminal.getTerminalNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersAddress() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filter.getAddress().getCountry() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("COUNTRY");
			paramFilter.setValue(filter.getAddress().getCountry());
			filters.add(paramFilter);
		}
		if (filter.getAddress().getCity() != null &&
				filter.getAddress().getCity().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CITY");
			paramFilter.setValue(filter.getAddress().getCity().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getStreet() != null &&
				filter.getAddress().getStreet().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("STREET");
			paramFilter.setValue(filter.getAddress().getStreet().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getHouse() != null &&
				filter.getAddress().getHouse().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("HOUSE");
			paramFilter.setValue(filter.getAddress().getHouse().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getPostalCode() != null &&
				filter.getAddress().getPostalCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("POSTAL_CODE");
			paramFilter.setValue(filter.getAddress().getPostalCode().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getApartment() != null &&
				filter.getAddress().getApartment().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("APARTMENT");
			paramFilter.setValue(filter.getAddress().getApartment().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void setFiltersContact() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filter.getAgentId());
			filters.add(paramFilter);
		}

		if (filter.getContact().getPhone() != null &&
				filter.getContact().getPhone().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("PHONE_NUMBER");
			paramFilter.setValue(filter.getContact().getPhone().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getContact().getEmail() != null &&
				filter.getContact().getEmail().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("EMAIL");
			paramFilter.setValue(filter.getContact().getEmail().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getContact().getImNumber() != null &&
				filter.getContact().getImNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("IM_NUMBER");
			paramFilter.setValue(filter.getContact().getImNumber().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public Customer getFilter() {
		// restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		// if (restoreBean != null && restoreBean) {
		// restoreBean();
		// }
		if (filter == null) {
			filter = new Customer();
		}
		return filter;
	}

	private void initFilterFromContext() {
		filter = new Customer();
		
		Integer instId = null;
		Integer agentId = null;
		String customerNumber = null;
		String contractNumber = null;
		
		if (FacesUtils.getSessionMapValue("customerNumber") != null) {
			customerNumber = (String) FacesUtils.getSessionMapValue("customerNumber");
			FacesUtils.setSessionMapValue("customerNumber", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			instId = (Integer) FacesUtils.getSessionMapValue("instId");
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("agentId") != null) {
			agentId = (Integer) FacesUtils.getSessionMapValue("agentId");
			FacesUtils.setSessionMapValue("agentId", null);
		}
		if (FacesUtils.getSessionMapValue("contractNumber") != null) {
			contractNumber = (String) FacesUtils.getSessionMapValue("contractNumber");
			FacesUtils.setSessionMapValue("contractNumber", null);
		}
		
		// to show all tabs
		setRenderTabs(true);
		FacesUtils.setSessionMapValue("renderTabs", true);
		initedFromCtx = true;
		
		getFilter().setInstId(instId);
		getFilter().setAgentId(agentId);
		getFilterContract().setInstId(instId);
		getFilterContract().setAgentId(agentId);
		getFilterCard().setInstId(instId);
		getFilterCard().setAgentId(agentId);
		getFilterAccount().setInstId(instId);
		getFilterAccount().setAgentId(agentId);
		getFilterMerchant().setInstId(instId);
		getFilterMerchant().setAgentId(agentId);
		getFilterTerminal().setInstId(instId);
		getFilterTerminal().setAgentId(agentId);
		if (userSession.getInRole().get(SystemConstants.VIEW_ALL_CUSTOMERS_PRIVILEGE)) {
			filter.setCustomerNumber((customerNumber != null)?customerNumber:"*");
			filter.setContractNumber((contractNumber != null)?contractNumber:"*");
			filter.getPerson().setSurname("*");
			filter.getPerson().setFirstName("*");
			filter.getCompany().setLabel("*");
			filter.getDocument().setIdNumber("*");
			filter.getContact().setPhone("*");
			filter.getContact().setEmail("*");
			filter.getAddress().setCity("*");
			filter.getAddress().setStreet("*");
			filter.getAddress().setHouse("*");
			filterContract.setContractNumber("*");
			filterCard.setCardNumber("*");
			filterAccount.setAccountNumber("*");
			filterMerchant.setMerchantNumber("*");
			filterTerminal.setTerminalNumber("*");
		}
		
	}

	public void setFilter(Customer filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = new Customer();
		filterTerminal = new Terminal();
		filterAccount = new Account();
		filterMerchant = new Merchant();
		filterCard = new Card();
		filterContract = new Contract();
		clearBean();
		clearSectionFilter();
		tabName = defaultTabName;
		setDefaultValues();
		searching = false;
	}

	private void setDefaultValues() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			FacesUtils.setSessionMapValue("initFromContext", null);
			initFilterFromContext();
//			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			curMode = VIEW_MODE;
			searching = true;
			getFilter().setEntityType(EntityNames.CUSTOMER);
		} else {
			Integer defaultInstId = userInstId;
			Integer defaultAgentId = userAgentId;
			List<SelectItem> instList = getInstitutions();
			if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
				// instId from LOV is for some reason String 
				defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
				defaultAgentId = null;
			}
			getFilter().setInstId(defaultInstId);
			getFilter().setAgentId(defaultAgentId);
			getFilterContract().setInstId(defaultInstId);
			getFilterContract().setAgentId(defaultAgentId);
			getFilterCard().setInstId(defaultInstId);
			getFilterCard().setAgentId(defaultAgentId);
			getFilterAccount().setInstId(defaultInstId);
			getFilterAccount().setAgentId(defaultAgentId);
			getFilterMerchant().setInstId(defaultInstId);
			getFilterMerchant().setAgentId(defaultAgentId);
			getFilterTerminal().setInstId(defaultInstId);
			getFilterTerminal().setAgentId(defaultAgentId);
			if (userSession.getInRole().get(SystemConstants.VIEW_ALL_CUSTOMERS_PRIVILEGE)) {
				filter.setCustomerNumber("*");
				filter.getPerson().setSurname("*");
				filter.getPerson().setFirstName("*");
				filter.getCompany().setLabel("*");
				filter.getDocument().setIdNumber("*");
				filter.getContact().setPhone("*");
				filter.getContact().setEmail("*");
				filter.getAddress().setCity("*");
				filter.getAddress().setStreet("*");
				filter.getAddress().setHouse("*");
				filterContract.setContractNumber("*");
				filterCard.setCardNumber("*");
				filterAccount.setAccountNumber("*");
				filterMerchant.setMerchantNumber("*");
				filterTerminal.setTerminalNumber("*");
			}
		}
	}
	
	public void searchByDocument() {
		getFilter().setEntityType(EntityNames.IDENTIFICATOR);
		search();
	}

	public void searchByCustomer() {
		getFilter().setEntityType(EntityNames.CUSTOMER);
		search();
	}

	public void searchByPerson() {
		getFilter().setEntityType(EntityNames.PERSON);
		search();
	}

	public void searchByCompany() {
		getFilter().setEntityType(EntityNames.COMPANY);
		search();
	}

	public void searchByContract() {
		getFilter().setEntityType(EntityNames.CONTRACT);
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

	public void searchByMerchant() {
		getFilter().setEntityType(EntityNames.MERCHANT);
		search();
	}

	public void searchByTerminal() {
		getFilter().setEntityType(EntityNames.TERMINAL);
		search();
	}

	public void searchByContact() {
		getFilter().setEntityType(EntityNames.CONTACT);
		search();
	}

	public void searchByAddress() {
		getFilter().setEntityType(EntityNames.ADDRESS);
		search();
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newCustomer = new Customer();
		if (getFilter().getInstId() != null) {
			newCustomer.setInstId(filter.getInstId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCustomer = (Customer) _activeCustomer.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCustomer = _activeCustomer;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_productsDao.removeCustomer(userSessionId, _activeCustomer);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "customer_deleted",
					"(id = " + _activeCustomer.getId() + ")");

			_activeCustomer = _itemSelection.removeObjectFromList(_activeCustomer);
			if (_activeCustomer == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newCustomer = _productsDao.addCustomer(userSessionId, newCustomer, curLang);
				_itemSelection.addNewObjectToList(newCustomer);
			} else {
				newCustomer = _productsDao.editCustomer(userSessionId, newCustomer, curLang);
				_customersSource.replaceObject(_activeCustomer, newCustomer);
			}
			_activeCustomer = newCustomer;
			curMode = VIEW_MODE;
			setBeans();

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd",
					"customer_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Customer getNewCustomer() {
		if (newCustomer == null) {
			newCustomer = new Customer();
		}
		return newCustomer;
	}

	public void setNewCustomer(Customer newCustomer) {
		this.newCustomer = newCustomer;
	}

	public void clearBean() {
		curLang = userLang;
		_customersSource.flushCache();
		_itemSelection.clearSelection();
		loadedTabs.clear();
		_activeCustomer = null;
		clearBeansStates();
	}

	private void clearBeansStates() {
		MbContractsBottom contracts = (MbContractsBottom) ManagedBeanWrapper.getManagedBean("MbContractsBottom");
		contracts.clearFilter();

		if (!fromCard) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			cardsSearch.clearFilter();
		}

		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();

		MbLimitCounters limitCountersBean = (MbLimitCounters) ManagedBeanWrapper
				.getManagedBean("MbLimitCounters");
		limitCountersBean.clearFilter();

		MbCycleCounters cycleCountersBean = (MbCycleCounters) ManagedBeanWrapper
				.getManagedBean("MbCycleCounters");
		cycleCountersBean.clearFilter();

		MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
				.getManagedBean("MbAccountsSearch");
		accsSearch.clearFilter();
		accsSearch.setSearching(false);

		MbObjectIdsSearch docsSearch = (MbObjectIdsSearch) ManagedBeanWrapper
				.getManagedBean("MbObjectIdsSearch");
		docsSearch.clearFilter();
		docsSearch.setSearching(false);

		MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
				.getManagedBean("MbNotesSearch");
		notesSearch.clearFilter();

		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
		flexible.setSearching(false);
		flexible.setFilter(null);

		MbAddressesSearch addrSearch = (MbAddressesSearch) ManagedBeanWrapper
				.getManagedBean("MbAddressesSearch");
		addrSearch.fullCleanBean();

		MbContactSearch contSearch = (MbContactSearch) ManagedBeanWrapper
				.getManagedBean("MbContactSearch");
		contSearch.fullCleanBean();

		MbAcquiringHierarchyBottom acqHier = (MbAcquiringHierarchyBottom) ManagedBeanWrapper
				.getManagedBean("MbAcquiringHierarchyBottom");
		acqHier.clearFilter();

		MbIssuingHierarchyBottom issHier = (MbIssuingHierarchyBottom) ManagedBeanWrapper
				.getManagedBean("MbIssuingHierarchyBottom");
		issHier.clearFilter();

		MbPmoPaymentOrders paymentOrderBean = (MbPmoPaymentOrders) ManagedBeanWrapper
				.getManagedBean("MbPmoPaymentOrders");
		paymentOrderBean.clearFilter();
		paymentOrderBean.search();

		MbPmoTemplates templatesBean = (MbPmoTemplates) ManagedBeanWrapper
				.getManagedBean("MbPmoTemplates");
		templatesBean.clearFilter();

		MbTerminalsBottom terminalsBean = (MbTerminalsBottom) ManagedBeanWrapper
				.getManagedBean("MbTerminalsBottom");
		terminalsBean.clearFilter();

		MbMerchantsBottom merchantsBean = (MbMerchantsBottom) ManagedBeanWrapper
				.getManagedBean("MbMerchantsBottom");
		merchantsBean.clearFilter();

		MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
				.getManagedBean("MbRevenueSharingBottom");
		revenueSharingBean.clearFilter();
		
		MbObjectDocuments documentsBean = (MbObjectDocuments) ManagedBeanWrapper
				.getManagedBean("MbObjectDocuments");
		documentsBean.clearFilter();
		
		MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
				.getManagedBean(MbObjectApplicationsSearch.class);
		mbAppObjects.clearFilter();
		
		MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper
				.getManagedBean("MbNtfEventBottom");
		ntf.clearFilter();
		
	}

	public ArrayList<SelectItem> getMerchantTypes() {
		if (merchantTypes == null) {
			merchantTypes = getDictUtils().getArticles(DictNames.MERCHANT_TYPE, true);
		}
		return merchantTypes;
	}

	public String getTabName() {
		if (_customersSource.getDataSize()<=0 && _activeCustomer == null)
			tabName = defaultTabName;
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		sessBean.setTabName(tabName);

		// Boolean isLoadedCurrentTab = loadedTabs.get(tabName);
		//
		// if (isLoadedCurrentTab == null) {
		// isLoadedCurrentTab = Boolean.FALSE;
		// }
		//
		// if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
		// return;
		// }

		loadTab(tabName, false);
		
		if (tabName.equalsIgnoreCase("additionalTab")) {
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			flexible.setTabName(tabName);
			flexible.setParentSectionId(getSectionId());
			flexible.setTableState(getSateFromDB(flexible.getComponentId()));
		} else if (tabName.equalsIgnoreCase("contractsTab")) {
			MbContractsBottom contracts = (MbContractsBottom) ManagedBeanWrapper
					.getManagedBean("MbContractsBottom");
			contracts.keepTabName(tabName);
			contracts.setParentSectionId(getSectionId());
			contracts.setTableState(getSateFromDB(contracts.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cardsTab")) {
			MbCardsBottomSearch bean = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomSearch");
			bean.setTabNameParam(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("merchantsTab")) {
			MbMerchantsBottom bean = (MbMerchantsBottom) ManagedBeanWrapper
					.getManagedBean("MbMerchantsBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("terminalsTab")) {
			MbTerminalsBottom bean = (MbTerminalsBottom) ManagedBeanWrapper
					.getManagedBean("MbTerminalsBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("accountsTab")) {
			MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsSearch");
			accsSearch.setTabName(tabName);
			accsSearch.setParentSectionId(getSectionId());
			accsSearch.setTableState(getSateFromDB(accsSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("attributesTab")) {
			MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			limitCounters.setTabName(tabName);
			limitCounters.setParentSectionId(getSectionId());
			limitCounters.setTableState(getSateFromDB(limitCounters.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCounters");
			cycleCounters.setTabName(tabName);
			cycleCounters.setParentSectionId(getSectionId());
			cycleCounters.setTableState(getSateFromDB(cycleCounters.getComponentId()));
		} else if (tabName.equalsIgnoreCase("PERSONIDSTAB")) {
			MbObjectIdsSearch docsSearch = (MbObjectIdsSearch) ManagedBeanWrapper
					.getManagedBean("MbObjectIdsSearch");
			docsSearch.setTabName(tabName);
			docsSearch.setParentSectionId(getSectionId());
			docsSearch.setTableState(getSateFromDB(docsSearch.getComponentId()));
			
		} else if (tabName.equalsIgnoreCase("documentsTab")){
			MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
					.getManagedBean("MbObjectDocuments");
			mbObjectDocuments.setTabName(tabName);
			mbObjectDocuments.setParentSectionId(getSectionId());
			mbObjectDocuments.setTableState(getSateFromDB(mbObjectDocuments.getComponentId()));
		} else if (tabName.equalsIgnoreCase("CONTACTSTAB")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearch");
			cont.setTabName(tabName);
			cont.setParentSectionId(getSectionId());
			cont.setTableState(getSateFromDB(cont.getComponentId()));
			
			MbContactDataSearch contData = (MbContactDataSearch) ManagedBeanWrapper
					.getManagedBean("MbContactDataSearch");
			contData.setTabName(tabName);
			contData.setParentSectionId(getSectionId());
			contData.setTableState(getSateFromDB(contData.getComponentId()));
		} else if (tabName.equalsIgnoreCase("ADDRESSESTAB")) {
			// get addresses for this institution
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
			addr.setTabName(tabName);
			addr.setParentSectionId(getSectionId());
			addr.setTableState(getSateFromDB(addr.getComponentId()));
		} else if (tabName.equalsIgnoreCase("notesTab")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			notesSearch.setTabName(tabName);
			notesSearch.setParentSectionId(getSectionId());
			notesSearch.setTableState(getSateFromDB(notesSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("revenueSharingTab")) {
			MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
					.getManagedBean("MbRevenueSharingBottom");
			revenueSharingBean.keepTabName(tabName);
			revenueSharingBean.setParentSectionId(getSectionId());
			revenueSharingBean.setTableState(getSateFromDB(revenueSharingBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("paymentOrdersTab")) {
			MbPmoPaymentOrders paymentOrderBean = (MbPmoPaymentOrders) ManagedBeanWrapper
					.getManagedBean("MbPmoPaymentOrders");
			paymentOrderBean.setTabName(tabName);
			paymentOrderBean.setParentSectionId(getSectionId());
			paymentOrderBean.setTableState(getSateFromDB(paymentOrderBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("templatesTab")) {
			MbPmoTemplates templatesBean = (MbPmoTemplates) ManagedBeanWrapper
					.getManagedBean("MbPmoTemplates");
			templatesBean.setTabName(tabName);
			templatesBean.setParentSectionId(getSectionId());
			templatesBean.setTableState(getSateFromDB(templatesBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("applicationsTab")){
			MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
					.getManagedBean(MbObjectApplicationsSearch.class);
			mbAppObjects.setTabName(tabName);
			mbAppObjects.setParentSectionId(getSectionId());
			mbAppObjects.setTableState(getSateFromDB(mbAppObjects.getComponentId()));
		} else if (tabName.equalsIgnoreCase("ntfEventTab")){
			MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper
					.getManagedBean("MbNtfEventBottom");
			ntf.setTabName(tabName);
			ntf.setParentSectionId(getSectionId());
			ntf.setTableState(getSateFromDB(ntf.getComponentId()));
		}

	}

	public String getSectionId() {
		return SectionIdConstants.CUSTOMER_CUSTOMER;
	}

	public void loadCurrentTab() {
		loadTab(tabName, false);
	}

	private void loadTab(String tab, boolean restoreState) {
		if (tab == null) {
			return;
		}
		if (_activeCustomer == null || _activeCustomer.getId() == null) {
			MbContractsBottom contracts = (MbContractsBottom) ManagedBeanWrapper.getManagedBean("MbContractsBottom");
			contracts.clearFilter();
			return;
		}
		try {
			if (tab.equalsIgnoreCase("detailsTab")) {
				String reason = _eventsDao.getStatusReason(userSessionId, _activeCustomer.getId(), EntityNames.CUSTOMER);
				_activeCustomer.setStatusReason(reason);
			} else if (tab.equalsIgnoreCase("contractsTab")) {
				MbContractsBottom contracts = (MbContractsBottom) ManagedBeanWrapper
						.getManagedBean("MbContractsBottom");
				contracts.setFilter(null);
				contracts.getFilter().setCustomerId(_activeCustomer.getId());
				contracts.getFilter().setCustomerName(_activeCustomer.getId().toString()); // TODO:
				// fix
				// it
				contracts.getFilter().setInstId(_activeCustomer.getInstId());
				contracts.setBackLink(pageLink);
				contracts.setSearchByCustomer(true);
				contracts.search();
			} else if (tab.equalsIgnoreCase("objectsTabs")) {
				// MbProductCustomers pCustomers =
				// (MbProductCustomers) ManagedBeanWrapper.getManagedBean("MbProductCustomers");
				// pCustomers.clearFilter();
				// pCustomers.getFilter().setCustomerId(_activeCustomer.getId());
				// pCustomers.getFilter().setCustomerName(_activeCustomer.getLabel());
				// pCustomers.search();
			} else if (tab.equalsIgnoreCase("cardsTab")) {
				MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
						.getManagedBean("MbCardsBottomSearch");
				cardsSearch.clearFilter();
				cardsSearch.getFilter().setCustomerId(_activeCustomer.getId());
				cardsSearch.setSearchTabName("CUSTOMER");
				cardsSearch.setBackLink(pageLink);
				cardsSearch.search();
			} else if (tab.equalsIgnoreCase("merchantsTab")) {
				MbMerchantsBottom merchantsSearch = (MbMerchantsBottom) ManagedBeanWrapper
						.getManagedBean("MbMerchantsBottom");
				merchantsSearch.clearFilter();
				merchantsSearch.getFilter().setCustomerId(_activeCustomer.getId());
				merchantsSearch.setSearchTabName("CUSTOMER");
				merchantsSearch.search();
			} else if (tab.equalsIgnoreCase("terminalsTab")) {
				MbTerminalsBottom terminalsSearch = (MbTerminalsBottom) ManagedBeanWrapper
						.getManagedBean("MbTerminalsBottom");
				terminalsSearch.clearFilter();
				terminalsSearch.getFilterTerm().setCustomerId(_activeCustomer.getId());
				terminalsSearch.searchTerminal();
				terminalsSearch.setSearchTabName("TERMINAL");
			} else if (tab.equalsIgnoreCase("accountsTab")) {
				MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
						.getManagedBean("MbAccountsSearch");
				accsSearch.clearFilter();
				accsSearch.getFilter().setCustomerId(_activeCustomer.getId());
				//accsSearch.getFilter().setEntityType(_activeCustomer.getEntityType());
				accsSearch.getFilter().setInstId(_activeCustomer.getInstId());
				accsSearch.setBackLink(pageLink);
				accsSearch.setTabsName("CUSTOMER");
				accsSearch.setSearchByObject(false);
				accsSearch.search();

			} else if (tab.equalsIgnoreCase("PERSONIDSTAB")) {
				MbObjectIdsSearch docsSearch = (MbObjectIdsSearch) ManagedBeanWrapper
						.getManagedBean("MbObjectIdsSearch");
				docsSearch.clearFilter();
				docsSearch.getFilter().setObjectId(_activeCustomer.getObjectId());
				docsSearch.getFilter().setEntityType(_activeCustomer.getEntityType());
				docsSearch.search();
			} else if (tab.equalsIgnoreCase("attributesTab")) {
				MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
						.getManagedBean("MbObjectAttributes");
				MbContractsBottom contracts = (MbContractsBottom) ManagedBeanWrapper
						.getManagedBean("MbContractsBottom");
				attrs.fullCleanBean();
				attrs.setObjectId(_activeCustomer.getId());
				if(contracts.getActiveContract() != null) {
					_activeCustomer.setProductId(contracts.getActiveContract().getProductId());
					_activeCustomer.setProductType(contracts.getActiveContract().getProductType());
				}
				attrs.setProductId(_activeCustomer.getProductId());
				attrs.setProductType(_activeCustomer.getProductType());
				attrs.setEntityType(EntityNames.CUSTOMER);
				attrs.setInstId(_activeCustomer.getInstId());
			} else if (tab.equalsIgnoreCase("limitCountersTab")) {
				MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
						.getManagedBean("MbLimitCounters");
				limitCounters.setFilter(null);
				limitCounters.getFilter().setObjectId(_activeCustomer.getId());
				limitCounters.getFilter().setInstId(_activeCustomer.getInstId());
				limitCounters.getFilter().setEntityType(EntityNames.CUSTOMER);
				limitCounters.search();
			} else if (tab.equalsIgnoreCase("cycleCountersTab")) {
				MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
						.getManagedBean("MbCycleCounters");
				cycleCounters.setFilter(null);
				cycleCounters.getFilter().setObjectId(_activeCustomer.getId());
				cycleCounters.getFilter().setInstId(_activeCustomer.getInstId());
				cycleCounters.getFilter().setEntityType(EntityNames.CUSTOMER);
				cycleCounters.search();
			} else if (tab.equalsIgnoreCase("additionalTab")) {
				// get flexible data for this institution
				MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
						.getManagedBean("MbFlexFieldsDataSearch");
				FlexFieldData filterFlex = new FlexFieldData();
				filterFlex.setInstId(_activeCustomer.getInstId());
				filterFlex.setEntityType(EntityNames.CUSTOMER);
				filterFlex.setObjectId(_activeCustomer.getId());
				//set a filter for a child object
				FlexFieldData childFilterFlex = new FlexFieldData();
				childFilterFlex.setInstId(_activeCustomer.getInstId());
				childFilterFlex.setEntityType(_activeCustomer.getEntityType());
				childFilterFlex.setObjectId(_activeCustomer.getObjectId());
				filterFlex.setChildEntityFilter(childFilterFlex);
				
				flexible.setFilter(filterFlex);
				flexible.search();
			} else if (tab.equalsIgnoreCase("notesTab")) {
				MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
						.getManagedBean("MbNotesSearch");
				ObjectNoteFilter filterNote = new ObjectNoteFilter();
				filterNote.setEntityType(EntityNames.CUSTOMER);
				filterNote.setObjectId(_activeCustomer.getId());
				notesSearch.setFilter(filterNote);
				notesSearch.search();
			} else if (tab.equalsIgnoreCase("ADDRESSESTAB")) {
				// get addresses for this institution
				MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
						.getManagedBean("MbAddressesSearch");
                addr.fullCleanBean();
                addr.getFilter().setEntityType(EntityNames.CUSTOMER);
                addr.getFilter().setObjectId(_activeCustomer.getId());
				addr.setCurLang(userLang);
				addr.search();
			} else if (tab.equalsIgnoreCase("CONTACTSTAB")) {
				// get contacts for this institution
				MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
						.getManagedBean("MbContactSearch");
				if (restoreState) {
					cont.restoreBean();
				} else {
					cont.fullCleanBean();
					cont.setBackLink(pageLink);
					cont.setObjectId(_activeCustomer.getId());
					cont.setEntityType(EntityNames.CUSTOMER);
				}
			} else if (tab.equalsIgnoreCase("acqHierarchyTab")) {
				MbAcquiringHierarchyBottom hierBean = (MbAcquiringHierarchyBottom) ManagedBeanWrapper
						.getManagedBean("MbAcquiringHierarchyBottom");
				hierBean.setObjectId(_activeCustomer.getId());
				hierBean.setObjectType(EntityNames.CUSTOMER);
				hierBean.search();
			} else if (tab.equalsIgnoreCase("issHierarchyTab")) {
				MbIssuingHierarchyBottom hierBean = (MbIssuingHierarchyBottom) ManagedBeanWrapper
						.getManagedBean("MbIssuingHierarchyBottom");
				hierBean.setObjectId(_activeCustomer.getId());
				hierBean.setObjectType(EntityNames.CUSTOMER);
				hierBean.search();
			} else if (tab.equalsIgnoreCase("paymentOrdersTab")) {
				MbPmoPaymentOrders paymentOrderBean = (MbPmoPaymentOrders) ManagedBeanWrapper
						.getManagedBean("MbPmoPaymentOrders");
				PmoPaymentOrder paymentOrderFilter = new PmoPaymentOrder();
				paymentOrderFilter.setCustomerId(_activeCustomer.getId());
				paymentOrderBean.setPaymentOrderFilter(paymentOrderFilter);
				paymentOrderBean.search();
			} else if (tab.equalsIgnoreCase("templatesTab")) {
				MbPmoTemplates templatesBean = (MbPmoTemplates) ManagedBeanWrapper
						.getManagedBean("MbPmoTemplates");
				PmoTemplate templateFilter = new PmoTemplate();
				templateFilter.setCustomerId(_activeCustomer.getId());
				templateFilter.setInstId(_activeCustomer.getInstId());
				templateFilter.setInstName(_activeCustomer.getInstName());
				templateFilter.setCustomerNumber(_activeCustomer.getCustomerNumber());
				templatesBean.setTemplateFilter(templateFilter);
				templatesBean.setPrivilege(PaymentOrderPrivConstants.VIEW_TAB_PMO_TEMPLATE);
				templatesBean.search();
			} else if (tab.equalsIgnoreCase("revenueSharingTab")) {
				MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
						.getManagedBean("MbRevenueSharingBottom");
				revenueSharingBean.clearFilter();
				revenueSharingBean.getFilter().setCustomerId(_activeCustomer.getId());
				revenueSharingBean.search();
			} else if (tab.equalsIgnoreCase("documentsTab")){
				MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
						.getManagedBean("MbObjectDocuments");
				mbObjectDocuments.getFilter().setObjectId(_activeCustomer.getId().longValue());
				mbObjectDocuments.getFilter().setEntityType(EntityNames.CUSTOMER);
				mbObjectDocuments.setBackLink(pageLink);
				if (restoreBean) {
					mbObjectDocuments.restoreState();
				}
				mbObjectDocuments.search();
			} else if (tab.equalsIgnoreCase("applicationsTab")){
				MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
						.getManagedBean(MbObjectApplicationsSearch.class);
				mbAppObjects.setObjectId(_activeCustomer.getId().longValue());
				mbAppObjects.setEntityType(EntityNames.CUSTOMER);
//				mbObjectDocuments.setBackLink(thisBackLink);
				mbAppObjects.search();
			} else if(tab.equalsIgnoreCase("ntfEventTab")){
				MbNtfEventBottom ntf = (MbNtfEventBottom) ManagedBeanWrapper
						.getManagedBean("MbNtfEventBottom");
				ntf.setEntityType(EntityNames.CUSTOMER);
				ntf.setObjectId(_activeCustomer.getId());
				ntf.search();
			}
			needRerender = tab;
			loadedTabs.put(tab, Boolean.TRUE);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
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
		filters[0] = new Filter("id", _activeCustomer.getId());
		filters[1] = new Filter("lang", curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] custArr = new Customer[0];
			if (_activeCustomer.isCompanyCustomer()) {
				custArr = _productsDao.getCompanyCustomers(userSessionId, params, curLang);
			} else if (_activeCustomer.isPersonCustomer()) {
				custArr = _productsDao.getPersonCustomers(userSessionId, params, curLang);
			} else {
				custArr = _productsDao.getUndefinedCustomers(userSessionId, params, curLang);
			}

			if (custArr != null && custArr.length > 0) {
				_activeCustomer = custArr[0];
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

	public List<SelectItem> getCustomerTypes() {
		if (customerTypes == null) {
			customerTypes = getDictUtils().getLov(LovConstants.CUSTOMER_TYPES);
		}
		return customerTypes;
	}

	public List<SelectItem> getIdTypes() {
		if (idTypes == null) {
			idTypes = getDictUtils().getLov(LovConstants.ID_TYPES_WITHOUT_CUSTOMER);
		}
		return idTypes;
	}

	/**
	 * <p>
	 * Loads customer by <code>customerId</code> into bean as <code>activeCustomer</code> and
	 * returns it.
	 * </p>
	 * 
	 * @return found customer or empty customer if no customer was found.
	 */
	public Customer getCustomer(Long customerId) {
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
			List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
			if (customers != null && !customers.isEmpty()) {
				_activeCustomer = customers.get(0);
			} else {
				_activeCustomer = null;
			}
			return _activeCustomer;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
		return new Customer();
	}

	/**
	 * <p>
	 * Gets customer by <code>customerNumber</code> and sets it as <code>activeCustomer</code>.
	 * </p>
	 * 
	 * @return found customer.
	 */
	public Customer getCustomer(String customerNumber) {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("customerNumber");
			filters[1].setValue(customerNumber);

			params.setFilters(filters);
			List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
			if (customers != null && !customers.isEmpty()) {
				_activeCustomer = customers.get(0);
			}
			return _activeCustomer;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
		return new Customer();
	}

	public boolean isFromCard() {
		return fromCard;
	}

	public void setFromCard(boolean fromCard) {
		this.fromCard = fromCard;
	}

	public ArrayList<SelectItem> getGenders() {
		if (genders == null) {
			genders = getDictUtils().getArticles(DictNames.PERSON_GENDER, false, false);
		}
		return genders;
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

	public Contract getFilterContract() {
		if (filterContract == null) {
			filterContract = new Contract();
		}
		return filterContract;
	}

	public void setFilterContract(Contract filterContract) {
		this.filterContract = filterContract;
	}

	public Account getFilterAccount() {
		if (filterAccount == null) {
			filterAccount = new Account();
		}
		return filterAccount;
	}

	public void setFilterAccount(Account filterAccount) {
		this.filterAccount = filterAccount;
	}

	public Merchant getFilterMerchant() {
		if (filterMerchant == null) {
			filterMerchant = new Merchant();
		}
		return filterMerchant;
	}

	public void setFilterMerchant(Merchant filterMerchant) {
		this.filterMerchant = filterMerchant;
	}

	public Terminal getFilterTerminal() {
		if (filterTerminal == null) {
			filterTerminal = new Terminal();
		}
		return filterTerminal;
	}

	public void setFilterTerminal(Terminal filterTerminal) {
		this.filterTerminal = filterTerminal;
	}

	public List<SelectItem> getAgents() {
		if (getFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public List<SelectItem> getCardTypes() {
		if (cardTypes == null) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				CardType[] types = _networkDao.getCardTypes(userSessionId, params);
				for (CardType type : types) {
					String name = type.getName();
					for (int i = 1; i < type.getLevel(); i++) {
						name = " -- " + name;
					}
					SelectItem item = new SelectItem(type.getId(), String.format("%s - %s", type.getId(), name));
					if (!type.isLeaf()){
						item.setDisabled(true);
					}
					items.add(item);
				}
				cardTypes = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (cardTypes == null)
					cardTypes = new ArrayList<SelectItem>();
			}
		}
		return cardTypes;
	}

	public List<SelectItem> getAccountStatuses() {
		if (accountStatuses == null) {
			accountStatuses = getDictUtils().getLov(LovConstants.ACCOUNT_STATUSES);
		}
		return accountStatuses;
	}

	public List<SelectItem> getTerminalTypes() {
		if (terminalTypes == null) {
			terminalTypes = getDictUtils().getArticles(DictNames.TERMINAL_TYPE, true, true);
		}
		return terminalTypes;
	}

	public List<SelectItem> getTerminalStatuses() {
		if (terminalStatuses == null) {
			terminalStatuses = getDictUtils().getArticles(DictNames.TERMINAL_STATUS, true, true);
		}
		return terminalStatuses;
	}

	public List<SelectItem> getMccs() {
		if (mccs == null) {
			mccs = getDictUtils().getLov(LovConstants.MCC);
		}
		return mccs;
	}

	public ArrayList<SelectItem> getImTypes() {
		if (imTypes == null) {
			imTypes = getDictUtils().getArticles(DictNames.IM_TYPE, false, true);
		}
		return imTypes;
	}

	private boolean isSearchCustomerByDocument() {
		return EntityNames.IDENTIFICATOR.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByCustomer() {
		return EntityNames.CUSTOMER.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByPerson() {
		return EntityNames.PERSON.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByCompany() {
		return EntityNames.COMPANY.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByContract() {
		return EntityNames.CONTRACT.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByCard() {
		return EntityNames.CARD.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByAccount() {
		return EntityNames.ACCOUNT.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByTerminal() {
		return EntityNames.TERMINAL.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByMerchant() {
		return EntityNames.MERCHANT.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByAddress() {
		return EntityNames.ADDRESS.equals(getFilter().getEntityType());
	}

	private boolean isSearchCustomerByContact() {
		return EntityNames.CONTACT.equals(getFilter().getEntityType());
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
		sessBean.setRowsNum(rowsNum);
	}

	public void setPageNumber(int pageNumber) {
		sessBean.setPageNumber(pageNumber);
		this.pageNumber = pageNumber;
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
		if (SEARCH_TAB_CUSTOMER.equals(searchTabName) || SEARCH_TAB_PERSON.equals(searchTabName) ||
				SEARCH_TAB_COMPANY.equals(searchTabName) ||
				SEARCH_TAB_DOCUMENT.equals(searchTabName) ||
				SEARCH_TAB_CONTACT.equals(searchTabName) ||
				SEARCH_TAB_ADDRESS.equals(searchTabName)) {
			filter = new Customer();
			filter.setInstId(userInstId);
		} else if (SEARCH_TAB_CONTRACT.equals(searchTabName)) {
			filterContract = new Contract();
			filterContract.setInstId(userInstId);
		} else if (SEARCH_TAB_CARD.equals(searchTabName)) {
			filterCard = new Card();
			filterCard.setInstId(userInstId);
		} else if (SEARCH_TAB_ACCOUNT.equals(searchTabName)) {
			filterAccount = new Account();
			filterAccount.setInstId(userInstId);
		} else if (SEARCH_TAB_MERCHANT.equals(searchTabName)) {
			filterMerchant = new Merchant();
			filterMerchant.setInstId(userInstId);
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
				filter = new Customer();
				if (filterRec.get("searchTabName") != null) {
					searchTabName = filterRec.get("searchTabName");
				}
				if (SEARCH_TAB_CUSTOMER.equals(searchTabName)) {
					setFilterFormCustomer(filterRec);
					if (searchAutomatically)
						searchByCustomer();
				} else if (SEARCH_TAB_PERSON.equals(searchTabName)) {
					setFilterFormPerson(filterRec);
					if (searchAutomatically)
						searchByPerson();
				} else if (SEARCH_TAB_COMPANY.equals(searchTabName)) {
					setFilterFormCompany(filterRec);
					if (searchAutomatically)
						searchByCompany();
				} else if (SEARCH_TAB_CONTRACT.equals(searchTabName)) {
					setFilterFormContract(filterRec);
					if (searchAutomatically)
						searchByContract();
				} else if (SEARCH_TAB_CARD.equals(searchTabName)) {
					setFilterFormCard(filterRec);
					if (searchAutomatically)
						searchByCard();
				} else if (SEARCH_TAB_ACCOUNT.equals(searchTabName)) {
					setFilterFormAccount(filterRec);
					if (searchAutomatically)
						searchByAccount();
				} else if (SEARCH_TAB_MERCHANT.equals(searchTabName)) {
					setFilterFormMerchant(filterRec);
					if (searchAutomatically)
						searchByMerchant();
				} else if (SEARCH_TAB_TERMINAL.equals(searchTabName)) {
					setFilterFormTerminal(filterRec);
					if (searchAutomatically)
						searchByTerminal();
				} else if (SEARCH_TAB_DOCUMENT.equals(searchTabName)) {
					setFilterFormDocument(filterRec);
					if (searchAutomatically)
						searchByDocument();
				} else if (SEARCH_TAB_CONTACT.equals(searchTabName)) {
					setFilterFormContact(filterRec);
					if (searchAutomatically)
						searchByContact();
				} else if (SEARCH_TAB_ADDRESS.equals(searchTabName)) {
					setFilterFormAddress(filterRec);
					if (searchAutomatically)
						searchByAddress();
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
			if (SEARCH_TAB_CUSTOMER.equals(searchTabName)) {
				setFilterRecCustomer(filterRec);
			} else if (SEARCH_TAB_PERSON.equals(searchTabName)) {
				setFilterRecPerson(filterRec);
			} else if (SEARCH_TAB_COMPANY.equals(searchTabName)) {
				setFilterRecCompany(filterRec);
			} else if (SEARCH_TAB_CONTRACT.equals(searchTabName)) {
				setFilterRecContract(filterRec);
			} else if (SEARCH_TAB_CARD.equals(searchTabName)) {
				setFilterRecCards(filterRec);
			} else if (SEARCH_TAB_ACCOUNT.equals(searchTabName)) {
				setFilterRecAccount(filterRec);
			} else if (SEARCH_TAB_MERCHANT.equals(searchTabName)) {
				setFilterRecMerchant(filterRec);
			} else if (SEARCH_TAB_TERMINAL.equals(searchTabName)) {
				setFilterRecTerminal(filterRec);
			} else if (SEARCH_TAB_DOCUMENT.equals(searchTabName)) {
				setFilterRecDocument(filterRec);
			} else if (SEARCH_TAB_CONTACT.equals(searchTabName)) {
				setFilterRecContact(filterRec);
			} else if (SEARCH_TAB_ADDRESS.equals(searchTabName)) {
				setFilterRecAddress(filterRec);
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

	private void setFilterFormCustomer(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("customerNumber") != null) {
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}
		if (filterRec.get("contractNumber") != null) {
			filter.setContractNumber(filterRec.get("contractNumber"));
		}
		if (filterRec.get("extEntityType") != null) {
			filter.setExtEntityType(filterRec.get("extEntityType"));
		}
	}

	private void setFilterFormPerson(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("firstName") != null) {
			filter.getPerson().setFirstName(filterRec.get("firstName"));
		}
		if (filterRec.get("surName") != null) {
			filter.getPerson().setSurname(filterRec.get("surName"));
		}
		if (filterRec.get("secondName") != null) {
			filter.getPerson().setSecondName(filterRec.get("secondName"));
		}
		if (filterRec.get("personGender") != null) {
			filter.getPerson().setGender(filterRec.get("personGender"));
		}
		if (filterRec.get("personBirthday") != null) {
			SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
			filter.getPerson().setBirthday(df.parse(filterRec.get("personBirthday")));
		}
	}

	private void setFilterFormCompany(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("companyName") != null) {
			filter.getCompany().setLabel(filterRec.get("companyName"));
		}

	}

	private void setFilterFormContract(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("startDate") != null) {
			filterContract.setStartDate(df.parse(filterRec.get("startDate")));
		}
		if (filterRec.get("endDate") != null) {
			filterContract.setEndDate(df.parse(filterRec.get("endDate")));
		}
		if (filterRec.get("contractNumber") != null) {
			filterContract.setContractNumber(filterRec.get("contractNumber"));
		}
	}

	private void setFilterFormCard(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
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
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("accountNumber") != null) {
			filterAccount.setAccountNumber(filterRec.get("accountNumber"));
		}
	}

	private void setFilterFormMerchant(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("merchantNumber") != null) {
			filterMerchant.setMerchantNumber(filterRec.get("merchantNumber"));
		}
		if (filterRec.get("merchantName") != null) {
			filterMerchant.setMerchantName(filterRec.get("merchantName"));
		}
		if (filterRec.get("merchantType") != null) {
			filterMerchant.setMerchantType(filterRec.get("merchantType"));
		}
	}

	private void setFilterFormTerminal(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("terminalNumber") != null) {
			filterTerminal.setTerminalNumber(filterRec.get("terminalNumber"));
		}
	}

	private void setFilterFormDocument(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("entityType") != null) {
			filter.getDocument().setEntityType(filterRec.get("entityType"));
		}
		if (filterRec.get("idNumber") != null) {
			filter.getDocument().setIdNumber(filterRec.get("idNumber"));
		}
		if (filterRec.get("idType") != null) {
			filter.getDocument().setIdType(filterRec.get("idType"));
		}
	}

	private void setFilterFormContact(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("phone") != null) {
			filter.getContact().setPhone(filterRec.get("phone"));
		}
		if (filterRec.get("email") != null) {
			filter.getContact().setEmail(filterRec.get("email"));
		}
		if (filterRec.get("imNumber") != null) {
			filter.getContact().setImNumber(filterRec.get("imNumber"));
		}
	}

	private void setFilterFormAddress(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filter.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("country") != null) {
			filter.getAddress().setCountry(filterRec.get("country"));
		}
		if (filterRec.get("city") != null) {
			filter.getAddress().setCity(filterRec.get("city"));
		}
		if (filterRec.get("street") != null) {
			filter.getAddress().setStreet(filterRec.get("street"));
		}
		if (filterRec.get("house") != null) {
			filter.getAddress().setHouse(filterRec.get("house"));
		}
		if (filterRec.get("postalCode") != null) {
			filter.getAddress().setPostalCode(filterRec.get("postalCode"));
		}
		if (filterRec.get("apartment") != null) {
			filter.getAddress().setApartment(filterRec.get("apartment"));
		}
	}

	private void setFilterRecCustomer(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", filter.getAgentId().toString());
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			filterRec.put("contractNumber", filter.getContractNumber());
		}
		if (filter.getExtEntityType() != null && filter.getExtEntityType().trim().length() > 0) {
			filterRec.put("extEntityType", filter.getExtEntityType());
		}
	}

	private void setFilterRecPerson(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", filter.getAgentId().toString());
		}
		if (filter.getPerson().getFirstName() != null &&
				filter.getPerson().getFirstName().trim().length() > 0) {
			filterRec.put("firstName", filter.getPerson().getFirstName());
		}

		if (filter.getPerson().getSurname() != null &&
				filter.getPerson().getSurname().trim().length() > 0) {
			filterRec.put("surName", filter.getPerson().getSurname());
		}

		if (filter.getPerson().getSecondName() != null &&
				filter.getPerson().getSecondName().trim().length() > 0) {
			filterRec.put("secondName", filter.getPerson().getSecondName());
		}

		if (filter.getPerson().getGender() != null &&
				filter.getPerson().getGender().trim().length() > 0) {
			filterRec.put("personGender", filter.getPerson().getGender());
		}

		if (filter.getPerson().getBirthday() != null) {
			SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
			filterRec.put("personBirthday", df.format(filter.getPerson().getBirthday()));
		}
	}

	private void setFilterRecCompany(Map<String, String> filterRec) {

		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", filter.getAgentId().toString());
		}
		if (filter.getCompany().getLabel() != null &&
				filter.getCompany().getLabel().trim().length() > 0) {
			filterRec.put("companyName", filter.getCompany().getLabel());
		}
	}

	private void setFilterRecContract(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filter.getAgentId()));
		}
		if (filterContract.getProductId() != null) {
			filterRec.put("productId", String.valueOf(filterContract.getProductId()));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterContract.getStartDate() != null) {
			filterRec.put("startDate", df.format(filterContract.getStartDate()));
		}
		if (filterContract.getEndDate() != null) {
			filterRec.put("endDate", df.format(filterContract.getEndDate()));
		}
		if (filterContract.getContractNumber() != null &&
				filterContract.getContractNumber().trim().length() > 0) {
			filterRec.put("contractNumber", filterContract.getContractNumber());
		}
	}

	private void setFilterRecCards(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
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
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filterAccount.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filterAccount.getAgentId()));
		}
		if (filterAccount.getAccountNumber() != null &&
				filterAccount.getAccountNumber().trim().length() > 0) {
			filterRec.put("accountNumber", filterAccount.getAccountNumber());
		}
	}

	private void setFilterRecMerchant(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filter.getAgentId()));
		}
		if (filterMerchant.getMerchantNumber() != null &&
				filterMerchant.getMerchantNumber().trim().length() > 0) {
			filterRec.put("merchantNumber", filterMerchant.getMerchantNumber());
		}
		if (filterMerchant.getMerchantName() != null &&
				filterMerchant.getMerchantName().trim().length() > 0) {
			filterRec.put("merchantName", filterMerchant.getMerchantName());
		}
		if (filterMerchant.getMerchantType() != null) {
			filterRec.put("merchantType", filterMerchant.getMerchantType());
		}
	}

	private void setFilterRecTerminal(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filter.getAgentId()));
		}
		if (filterTerminal.getTerminalNumber() != null &&
				filterTerminal.getTerminalNumber().trim().length() > 0) {
			filterRec.put("terminalNumber", String.valueOf(filterTerminal.getTerminalNumber()));
		}
	}

	private void setFilterRecDocument(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filter.getAgentId()));
		}
		if (filter.getDocument().getEntityType() != null) {
			filterRec.put("entityType", filter.getDocument().getEntityType());
		}
		if (filter.getDocument().getIdNumber() != null) {
			filterRec.put("idNumber", filter.getDocument().getIdNumber());
		}
		if (filter.getDocument().getIdType() != null) {
			filterRec.put("idType", filter.getDocument().getIdType());
		}
	}

	private void setFilterRecContact(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filter.getAgentId()));
		}
		if (filter.getContact().getPhone() != null &&
				filter.getContact().getPhone().trim().length() > 0) {
			filterRec.put("phone", filter.getContact().getPhone());
		}
		if (filter.getContact().getEmail() != null &&
				filter.getContact().getEmail().trim().length() > 0) {
			filterRec.put("email", filter.getContact().getEmail());
		}
		if (filter.getContact().getImNumber() != null &&
				filter.getContact().getImNumber().trim().length() > 0) {
			filterRec.put("imNumber", filter.getContact().getImNumber());
		}
	}

	private void setFilterRecAddress(Map<String, String> filterRec) {
		if (filter.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filter.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filter.getAgentId()));
		}
		if (filter.getAddress().getCountry() != null) {
			filterRec.put("country", filter.getAddress().getCountry());
		}
		if (filter.getAddress().getCity() != null &&
				filter.getAddress().getCity().trim().length() > 0) {
			filterRec.put("city", filter.getAddress().getCity());
		}
		if (filter.getAddress().getStreet() != null &&
				filter.getAddress().getStreet().trim().length() > 0) {
			filterRec.put("street", filter.getAddress().getStreet());
		}
		if (filter.getAddress().getHouse() != null &&
				filter.getAddress().getHouse().trim().length() > 0) {
			filterRec.put("house", filter.getAddress().getHouse());
		}
		if (filter.getAddress().getPostalCode() != null &&
				filter.getAddress().getPostalCode().trim().length() > 0) {
			filterRec.put("postalCode", filter.getAddress().getPostalCode());
		}
		if (filter.getAddress().getApartment() != null &&
				filter.getAddress().getApartment().trim().length() > 0) {
			filterRec.put("apartment", filter.getAddress().getApartment());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public String getTabComponentId() {
		return COMPONENT_TAB_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setSelectedCtxItem(selectedCtxItem);
		ctxBean.initCtxParams(EntityNames.CUSTOMER, _activeCustomer.getId());

//		if (EntityNames.PERSON.equals(ctxItemEntityType)) {
//			FacesUtils.setSessionMapValue("module", "iss");
//		} else if (EntityNames.COMPANY.equals(ctxItemEntityType)) {
//			FacesUtils.setSessionMapValue("module", "acq");
//		}
		FacesUtils.setSessionMapValue("entityType", EntityNames.CUSTOMER);
		FacesUtils.setSessionMapValue("customerNumber", _activeCustomer.getCustomerNumber());
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", pageLink);
		// sessBean.setActiveCustomer(_activeCustomer);
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


	public String doDefaultAction() {
		MbContextMenu ctx = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		AcmAction action = ctx.getDefaultAction(_activeCustomer.getInstId());

		if (action != null) {
			selectedCtxItem = action;
			return ctxPageForward();
		}
		return "";
	}

	public boolean isBeanRestored() {
		if (beanRestored) { // just to use it only once
			beanRestored = false;
			return true;
		}
		return false;
	}
	
	private boolean getBeanRestored(){
		return beanRestored;
	}

	public void setBeanRestored(boolean beanRestored) {
		this.beanRestored = beanRestored;
	}

	public Map<String, Object> getCustomerMap() {
		return customerMap;
	}

	public void setCustomerMap(Map<String, Object> customerMap) {
		this.customerMap = customerMap;
	}

	public Map<String, Boolean> getRenderTabsMap() {
		if (renderTabsMap == null) {
			renderTabsMap = createTabsMap();
		}
		return renderTabsMap;
	}

	private HashMap<String, Boolean> createTabsMap() {
		HashMap<String, Boolean> map = new HashMap<String, Boolean>();
		for (String str : getSelectedTabs()) {
			map.put(str, true);
		}
		return map;
	}

	public void saveTabsMap() {
		backupSelectedTabs = null;
		getRenderTabsMap().clear();
		String state = null;
		if (selectedTabs != null) {
			for (String tab : selectedTabs) {
				renderTabsMap.put(tab, true);
				if (state == null) {
					state = tab;
				} else {
					state += ";" + tab;
				}
			}
		}
		setShowAllTabs(false);
		setTabsState(state);
		saveTabsStateDB();
	}

	public void clearTabsMap() {
		getBackupSelectedTabs().addAll(selectedTabs);
		deleteTabsStateDB();
		setShowAllTabs(true);
		selectedTabs = null;
		renderTabsMap = null;
	}
	
	public void cancelTabsMap(){
		if (backupSelectedTabs != null){
			selectedTabs = backupSelectedTabs;
			getRenderTabsMap().clear();
			String state = null;
			if (selectedTabs != null) {
				for (String tab : selectedTabs) {
					renderTabsMap.put(tab, true);
					if (state == null) {
						state = tab;
					} else {
						state += ";" + tab;
					}
				}
			}
			setShowAllTabs(false);
			setTabsState(state);
			saveTabsStateDB();
		}
	}
	
	private List<String> getBackupSelectedTabs(){
		if (backupSelectedTabs == null){
			backupSelectedTabs = new ArrayList<String>();
		}
		return backupSelectedTabs;
	}

	private List<String> selectedTabs;

	private void setTabsList() {
		selectedTabs = new ArrayList<String>();
		if (isShowAllTabs()) {
			selectedTabs.add("additionalTab");
			selectedTabs.add("contractsTab");
			selectedTabs.add("cardsTab");
			selectedTabs.add("merchantsTab");
			selectedTabs.add("terminalsTab");
			selectedTabs.add("accountsTab");
			selectedTabs.add("attributesTab");
			selectedTabs.add("limitCountersTab");
			selectedTabs.add("cycleCountersTab");
			selectedTabs.add("personIdsTab");
			selectedTabs.add("documentsTab");
			selectedTabs.add("contactsTab");
			selectedTabs.add("addressesTab");
			selectedTabs.add("notesTab");
			selectedTabs.add("acqHierarchyTab");
			selectedTabs.add("issHierarchyTab");
			selectedTabs.add("revenueSharingTab");
			selectedTabs.add("paymentOrdersTab");
			selectedTabs.add("templatesTab");
			selectedTabs.add("applicationsTab");
		} else {
			String state = getTabsState();
			if (state != null) {
				for (String str : state.split(";")) {
					selectedTabs.add(str);
				}
			}
		}
	}

	public List<String> getSelectedTabs() {
		if (selectedTabs == null) {
			setTabsList();
		}
		return selectedTabs;
	}

	public void setSelectedTabs(List<String> selectedItems) {
		this.selectedTabs = selectedItems;
	}

	public List<SelectItem> getExtEntityTypes() {
		if (extEntityTypes == null) {
			extEntityTypes = getDictUtils().getLov(LovConstants.EXT_ENTITY_TYPES);
		}
		return extEntityTypes;
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
		map.put("selfUrl", "products|customers");
		if (_activeCustomer != null) {
			if (EntityNames.CUSTOMER.equals(ctxItemEntityType)) {
					 map.put("id", _activeCustomer.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}

	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.CUSTOMER);
	}
	
	public boolean isInitedFromCtx() {
		return initedFromCtx;
	}

	public void setInitedFromCtx(boolean initedFromCtx) {
		this.initedFromCtx = initedFromCtx;
	}

	public void scoring() {
		MbScoringCalculation bean = ManagedBeanWrapper.getManagedBean(MbScoringCalculation.class);
		if (bean != null) {
			bean.clearFilter();
			bean.setUserLang(userLang);
			bean.loadEvaluations();
		}
	}


    public void onSortablePreRenderTable() {
        onSortablePreRenderTable(_customersSource);
    }
}

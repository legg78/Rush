package ru.bpc.sv2.ui.products;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;

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
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoTemplate;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.acquiring.MbAcquiringHierarchy;
import ru.bpc.sv2.ui.acquiring.MbMerchantsBottom;
import ru.bpc.sv2.ui.acquiring.MbRevenueSharingBottom;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.MbObjectIdsSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.issuing.MbIssuingHierarchy;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.pmo.MbPmoPaymentOrders;
import ru.bpc.sv2.ui.pmo.MbPmoTemplates;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@ManagedBean (name = "MbCustomers")
public class MbCustomers extends AbstractBean {
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
	private static final String SEARCH_TAB_CONTACT = "contactTab";
	private static final String SEARCH_TAB_ADDRESS = "addressTab";

	private ProductsDao _productsDao = new ProductsDao();

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

	private String tabName;
	private final String defaultTabName = "detailsTab";
	private String searchTabName;

	private ArrayList<SelectItem> institutions;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	private boolean fromCard;

	private MbCustomersSess sessBean;

	private AcmAction selectedCtxItem;
	private String ctxItemEntityType;
	private boolean beanRestored;

	private Map<String, Boolean> renderTabsMap;
	
	public MbCustomers() {
		tabName = defaultTabName;
		thisBackLink = "products|customers";
		

		sessBean = (MbCustomersSess) ManagedBeanWrapper.getManagedBean("MbCustomersSess");

		// 2-nd restore: to get shown information back in bean
		// FIXME: the stupidest way of doing things but it works, at least it seems so
		// (see also restoreBean()) perhaps it can be used without time check as bean is
		// destroyed everytime we return on the page so the situation when flag is set
		// but bean isn't destroyed seems to be impossible
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink + "RESTORE_AGAIN");
		Long restoreTime = (Long) FacesUtils.getSessionMapValue("RESTORE_TIME");
		if (restoreBean != null && restoreBean && restoreTime != null) {
			if (System.currentTimeMillis() - restoreTime < 20000) { // 10 secs not enough :(
				restoreBean();
			}
			FacesUtils.setSessionMapValue(thisBackLink + "RESTORE_AGAIN", null);
		}

		// 1-st restore: to show saved information
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean != null && restoreBean) {
			restoreBean();
		}

		_customersSource = new DaoDataModel<Customer>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Customer[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Customer[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (isSearchCustomerByCustomer()) {
						return _productsDao.getCombinedCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByPerson()) {
						return _productsDao.getCombinedCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByCompany()) {
						return _productsDao.getCombinedCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByContract()) {
						return _productsDao.getContractCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByCard()) {
						return _productsDao.getCardCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByAccount()) {
						return _productsDao.getAccountCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByMerchant()) {
						return _productsDao.getMerchantCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByTerminal()) {
						return _productsDao.getTerminalCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByAddress()) {
						return _productsDao.getAddressCustomers(userSessionId, params, curLang);
					} else if (isSearchCustomerByContact()) {
						return _productsDao.getContactCustomers(userSessionId, params, curLang);
					} else {
						// return _productsDao.getCustomers(userSessionId, params, curLang);
						return new Customer[0];
					}
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new Customer[0];
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
					if (isSearchCustomerByCustomer()) {
						return _productsDao.getCombinedCustomersCount(userSessionId, params,
								curLang);
					} else if (isSearchCustomerByPerson()) {
						return _productsDao.getCombinedCustomersCount(userSessionId, params,
								curLang);
					} else if (isSearchCustomerByCompany()) {
						return _productsDao.getCombinedCustomersCount(userSessionId, params,
								curLang);
					} else if (isSearchCustomerByContract()) {
						return _productsDao.getContractCustomersCount(userSessionId, params,
								curLang);
					} else if (isSearchCustomerByCard()) {
						return _productsDao.getCardCustomersCount(userSessionId, params, curLang);
					} else if (isSearchCustomerByAccount()) {
						return _productsDao
								.getAccountCustomersCount(userSessionId, params, curLang);
					} else if (isSearchCustomerByMerchant()) {
						return _productsDao.getMerchantCustomersCount(userSessionId, params,
								curLang);
					} else if (isSearchCustomerByTerminal()) {
						return _productsDao.getTerminalCustomersCount(userSessionId, params,
								curLang);
					} else if (isSearchCustomerByAddress()) {
						return _productsDao
								.getAddressCustomersCount(userSessionId, params, curLang);
					} else if (isSearchCustomerByContact()) {
						return _productsDao
								.getContactCustomersCount(userSessionId, params, curLang);
					} else {
						// return _productsDao.getCustomersCount(userSessionId, params, curLang);
						return 0;
					}
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<Customer>(null, _customersSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");
		setSearchTabName(SEARCH_TAB_CUSTOMER);

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
		searching = true;

		loadTab(tabName, true);

		FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		beanRestored = true;
		FacesUtils.setSessionMapValue(thisBackLink + "RESTORE_AGAIN", Boolean.TRUE);
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

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCustomer == null && _customersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCustomer != null && _customersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCustomer.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCustomer = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCustomer = _itemSelection.getSingleSelection();

		if (_activeCustomer != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_customersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomer = (Customer) _customersSource.getRowData();
		selection.addKey(_activeCustomer.getModelId());
		_itemSelection.setWrappedSelection(selection);

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
	}

	public void setFilters() {
		if (isSearchCustomerByCustomer()) {
			setFiltersCustomer();
		} else if (isSearchCustomerByCompany()) {
			setFiltersCompany();
		} else if (isSearchCustomerByPerson()) {
			setFiltersPerson();
		} else if (isSearchCustomerByContract()) {
			setFiltersContract();
		} else if (isSearchCustomerByCard()) {
			setFiltersCard();
		} else if (isSearchCustomerByAccount()) {
			setFiltersAccount();
		} else if (isSearchCustomerByMerchant()) {
			setFiltersMerchant();
		} else if (isSearchCustomerByTerminal()) {
			setFiltersTerminal();
		} else if (isSearchCustomerByAddress()) {
			setFiltersAddress();
		} else if (isSearchCustomerByContact()) {
			setFiltersContact();
		}
	}

	public void setFiltersPerson() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(EntityNames.PERSON);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPerson().getFirstName() != null &&
				filter.getPerson().getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personFirstName");
			paramFilter.setValue(filter.getPerson().getFirstName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getSurname() != null &&
				filter.getPerson().getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personSurname");
			paramFilter.setValue(filter.getPerson().getSurname().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getSecondName() != null &&
				filter.getPerson().getSecondName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personSecondName");
			paramFilter.setValue(filter.getPerson().getSecondName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getPerson().getGender() != null &&
				filter.getPerson().getGender().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("personGender");
			paramFilter.setValue(filter.getPerson().getGender().trim().toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPerson().getBirthday() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("personBirthday");
			paramFilter.setValue(filter.getPerson().getBirthday());
			filters.add(paramFilter);
		}

		if (filter.getDocument().getIdType() != null &&
				filter.getDocument().getIdType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idType");
			paramFilter.setValue(filter.getDocument().getIdType());
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdSeries() != null &&
				filter.getDocument().getIdSeries().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idSeries");
			paramFilter.setValue(filter.getDocument().getIdSeries().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdNumber() != null &&
				filter.getDocument().getIdNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idNumber");
			paramFilter.setValue(filter.getDocument().getIdNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void setFiltersCustomer() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersCompany() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(EntityNames.COMPANY);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getCompany().getLabel() != null &&
				filter.getCompany().getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("companyName");
			paramFilter.setValue(filter.getCompany().getLabel().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getCompany().getEmbossedName() != null &&
				filter.getCompany().getEmbossedName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("embossedName");
			paramFilter.setValue(filter.getCompany().getEmbossedName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdType() != null &&
				filter.getDocument().getIdType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idType");
			paramFilter.setValue(filter.getDocument().getIdType());
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdSeries() != null &&
				filter.getDocument().getIdSeries().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idSeries");
			paramFilter.setValue(filter.getDocument().getIdSeries().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDocument().getIdNumber() != null &&
				filter.getDocument().getIdNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("idNumber");
			paramFilter.setValue(filter.getDocument().getIdNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void setFiltersContract() {
		getFilterContract();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filterContract.getAgentId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("agentId");
			paramFilter.setValue(filterContract.getAgentId());
			filters.add(paramFilter);
		}
		if (filterContract.getProductId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setValue(filterContract.getProductId());
			filters.add(paramFilter);
		}
		if (filterContract.getContractType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("contractType");
			paramFilter.setValue(filterContract.getContractType());
			filters.add(paramFilter);
		}

		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (filterContract.getStartDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("startDate");
			paramFilter.setValue(df.format(filterContract.getStartDate()));
			filters.add(paramFilter);
		}
		if (filterContract.getEndDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("endDate");
			paramFilter.setValue(df.format(filterContract.getEndDate()));
			filters.add(paramFilter);
		}
		if (filterContract.getContractNumber() != null &&
				filterContract.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filterContract.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersCard() {
		getFilterCard();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filterCard.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardTypeId");
			paramFilter.setValue(filterCard.getCardTypeId());
			filters.add(paramFilter);
		}
		if (filterCard.getProductId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setValue(filterCard.getProductId());
			filters.add(paramFilter);
		}

		if (filterCard.getCardNumber() != null && filterCard.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardNumber");
			paramFilter.setValue(filterCard.getCardNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterCard.getCardholderName() != null &&
				filterCard.getCardholderName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardholderName");
			paramFilter.setValue(filterCard.getCardholderName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

	}

	public void setFiltersAccount() {
		getFilterAccount();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filterAccount.getAccountType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountType");
			paramFilter.setValue(filterAccount.getAccountType());
			filters.add(paramFilter);
		}
		if (filterAccount.getAccountNumber() != null &&
				filterAccount.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setValue(filterAccount.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterAccount.getStatus() != null && filterAccount.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setValue(filterAccount.getStatus());
			filters.add(paramFilter);
		}

		if (filterAccount.getCurrency() != null && filterAccount.getCurrency().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setValue(filterAccount.getCurrency());
			filters.add(paramFilter);
		}
	}

	public void setFiltersMerchant() {
		getFilterMerchant();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filterMerchant.getMerchantNumber() != null &&
				filterMerchant.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantNumber");
			paramFilter.setValue(filterMerchant.getMerchantNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterMerchant.getMerchantName() != null &&
				filterMerchant.getMerchantName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantName");
			paramFilter.setValue(filterMerchant.getMerchantName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterMerchant.getMcc() != null && filterMerchant.getMcc().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("mcc");
			paramFilter.setValue(filterMerchant.getMcc());
			filters.add(paramFilter);
		}
	}

	public void setFiltersTerminal() {
		getFilterTerminal();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filterTerminal.getTerminalType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalType");
			paramFilter.setValue(filterTerminal.getTerminalType());
			filters.add(paramFilter);
		}
		if (filterTerminal.getTerminalNumber() != null &&
				filterTerminal.getTerminalNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalNumber");
			paramFilter.setValue(filterTerminal.getTerminalNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filterTerminal.getStatus() != null && filterTerminal.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setValue(filterTerminal.getStatus());
			filters.add(paramFilter);
		}

	}

	public void setFiltersAddress() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAddress().getCountry() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("country");
			paramFilter.setValue(filter.getAddress().getCountry());
			filters.add(paramFilter);
		}
		if (filter.getAddress().getCity() != null &&
				filter.getAddress().getCity().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("city");
			paramFilter.setValue(filter.getAddress().getCity().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getStreet() != null &&
				filter.getAddress().getStreet().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("street");
			paramFilter.setValue(filter.getAddress().getStreet().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getHouse() != null &&
				filter.getAddress().getHouse().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("house");
			paramFilter.setValue(filter.getAddress().getHouse().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddress().getPostalCode() != null &&
				filter.getAddress().getPostalCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("postalCode");
			paramFilter.setValue(filter.getAddress().getPostalCode());
			filters.add(paramFilter);
		}
	}

	public void setFiltersContact() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getContact().getPhone() != null &&
				filter.getContact().getPhone().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("phone");
			paramFilter.setValue(filter.getContact().getPhone().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getContact().getMobile() != null &&
				filter.getContact().getMobile().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("mobile");
			paramFilter.setValue(filter.getContact().getMobile().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getContact().getFax() != null &&
				filter.getContact().getFax().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("fax");
			paramFilter.setValue(filter.getContact().getFax().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getContact().getEmail() != null &&
				filter.getContact().getEmail().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("email");
			paramFilter.setValue(filter.getContact().getEmail().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getContact().getImType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("imType");
			paramFilter.setValue(filter.getContact().getImType());
			filters.add(paramFilter);
		}
		if (filter.getContact().getImNumber() != null &&
				filter.getContact().getImNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("imNumber");
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
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Customer filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = new Customer();
		filter.setInstId(userInstId);
		filterTerminal = new Terminal();
		filterTerminal.setInstId(userInstId);
		filterAccount = new Account();
		filterAccount.setInstId(userInstId);
		filterMerchant = new Merchant();
		filterMerchant.setInstId(userInstId);
		filterCard = new Card();
		filterCard.setInstId(userInstId);
		filterContract = new Contract();
		filterContract.setInstId(userInstId);
		clearBean();
		clearSectionFilter();
		// tabName = defaultTabName;
		searching = false;
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
		MbContracts contracts = (MbContracts) ManagedBeanWrapper.getManagedBean("MbContracts");
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

		MbAcquiringHierarchy acqHier = (MbAcquiringHierarchy) ManagedBeanWrapper
				.getManagedBean("MbAcquiringHierarchy");
		acqHier.setFromCustomer(true);
		acqHier.clearFilter();

		MbIssuingHierarchy issHier = (MbIssuingHierarchy) ManagedBeanWrapper
				.getManagedBean("MbIssuingHierarchy");
		issHier.setFromCustomer(true);
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

	}

	public String getTabName() {
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

		// loadTab(tabName);
	}

	public void loadCurrentTab() {
		loadTab(tabName, false);
	}

	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (_activeCustomer == null || _activeCustomer.getId() == null) {
			MbContracts contracts = (MbContracts) ManagedBeanWrapper.getManagedBean("MbContracts");
			contracts.clearFilter();

			return;
		}
		try {
			if (tab.equalsIgnoreCase("contractsTab")) {
				MbContracts contracts = (MbContracts) ManagedBeanWrapper
						.getManagedBean("MbContracts");
				contracts.setFilter(null);
				contracts.getFilter().setCustomerId(_activeCustomer.getId());
				contracts.getFilter().setCustomerName(_activeCustomer.getId().toString()); // TODO:
				// fix
				// it
				contracts.getFilter().setInstId(_activeCustomer.getInstId());
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
				cardsSearch.search();
			} else if (tab.equalsIgnoreCase("merchantsTab")) {
				MbMerchantsBottom merchantsSearch = (MbMerchantsBottom) ManagedBeanWrapper
						.getManagedBean("MbMerchantsBottom");
				merchantsSearch.clearFilter();
				merchantsSearch.getFilter().setCustomerId(_activeCustomer.getId());
				merchantsSearch.search();
			} else if (tab.equalsIgnoreCase("terminalsTab")) {
				MbTerminalsBottom terminalsSearch = (MbTerminalsBottom) ManagedBeanWrapper
						.getManagedBean("MbTerminalsBottom");
				terminalsSearch.clearFilter();
				terminalsSearch.getFilterTerm().setCustomerId(_activeCustomer.getId());
				terminalsSearch.searchTerminal();
			} else if (tab.equalsIgnoreCase("accountsTab")) {
				MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
						.getManagedBean("MbAccountsSearch");
				accsSearch.clearFilter();
				accsSearch.getFilter().setCustomerId(_activeCustomer.getId());
				accsSearch.getFilter().setEntityType(_activeCustomer.getEntityType());
				accsSearch.setBackLink(thisBackLink);
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
				attrs.fullCleanBean();
				attrs.setObjectId(_activeCustomer.getId());
				attrs.setProductId(_activeCustomer.getProductId());
				attrs.setEntityType(EntityNames.CUSTOMER);
				attrs.setInstId(_activeCustomer.getInstId());
				attrs.setProductType(_activeCustomer.getProductType());
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
					cont.setBackLink(thisBackLink);
					cont.setObjectId(_activeCustomer.getId());
					cont.setEntityType(EntityNames.CUSTOMER);
				}
			} else if (tab.equalsIgnoreCase("acqHierarchyTab")) {
				MbAcquiringHierarchy hierBean = (MbAcquiringHierarchy) ManagedBeanWrapper
						.getManagedBean("MbAcquiringHierarchy");
				hierBean.setObjectId(_activeCustomer.getId());
				hierBean.setObjectType(EntityNames.CUSTOMER);
				hierBean.setFromCustomer(true);
				hierBean.search();
			} else if (tab.equalsIgnoreCase("issHierarchyTab")) {
				MbIssuingHierarchy hierBean = (MbIssuingHierarchy) ManagedBeanWrapper
						.getManagedBean("MbIssuingHierarchy");
				hierBean.setObjectId(_activeCustomer.getId());
				hierBean.setObjectType(EntityNames.CUSTOMER);
				hierBean.setFromCustomer(true);
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
				templatesBean.setTemplateFilter(templateFilter);
				templatesBean.search();
			} else if (tab.equalsIgnoreCase("revenueSharingTab")) {
				MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
						.getManagedBean("MbRevenueSharingBottom");
				revenueSharingBean.clearFilter();
				revenueSharingBean.getFilter().setCustomerId(_activeCustomer.getId());
				revenueSharingBean.search();
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
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeCustomer.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
			if (customers != null && !customers.isEmpty()) {
				_activeCustomer = customers.get(0);
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
		return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES);
	}

	public List<SelectItem> getPersonIdTypes() {
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("CUSTOMER_TYPE", EntityNames.PERSON);
			if (getFilter().getInstId() != null) {
				paramMap.put("INSTITUTION_ID", getFilter().getInstId());
			}
			return getDictUtils().getLov(LovConstants.DOCUMENT_TYPES, paramMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}

	public List<SelectItem> getCompanyIdTypes() {
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			paramMap.put("CUSTOMER_TYPE", EntityNames.COMPANY);
			if (getFilter().getInstId() != null) {
				paramMap.put("INSTITUTION_ID", getFilter().getInstId());
			}
			return getDictUtils().getLov(LovConstants.DOCUMENT_TYPES, paramMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
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
		return getDictUtils().getArticles(DictNames.PERSON_GENDER, false, false);
	}

	public Card getFilterCard() {
		if (filterCard == null) {
			filterCard = new Card();
			filterCard.setInstId(userInstId);
		}
		return filterCard;
	}

	public void setFilterCard(Card filterCard) {
		this.filterCard = filterCard;
	}

	public Contract getFilterContract() {
		if (filterContract == null) {
			filterContract = new Contract();
			if (userInstId.intValue() != ApplicationConstants.DEFAULT_INSTITUTION) {
				filterContract.setInstId(userInstId);
			}
		}
		return filterContract;
	}

	public void setFilterContract(Contract filterContract) {
		this.filterContract = filterContract;
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

	public Merchant getFilterMerchant() {
		if (filterMerchant == null) {
			filterMerchant = new Merchant();
			filterMerchant.setInstId(userInstId);
		}
		return filterMerchant;
	}

	public void setFilterMerchant(Merchant filterMerchant) {
		this.filterMerchant = filterMerchant;
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

	public List<SelectItem> getAgents() {
		if (getFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public List<SelectItem> getCardTypes() {
		return getDictUtils().getLov(LovConstants.CARD_TYPES);
	}

	public List<SelectItem> getAccountTypes() {
		if (getFilterAccount().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		return getDictUtils().getLov(LovConstants.ACCOUNT_TYPES, paramMap);
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

	public ArrayList<SelectItem> getImTypes() {
		return getDictUtils().getArticles(DictNames.IM_TYPE, false, true);
	}

	public ArrayList<SelectItem> getProducts() {
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter filter = new Filter();
		filter.setElement("lang");
		filter.setValue(curLang);
		filters.add(filter);

		if (getFilterContract().getInstId() != null) {
			filter = new Filter();
			filter.setElement("instId");
			filter.setValue(getFilter().getInstId());
			filters.add(filter);
		}
		if (getFilterContract().getContractType() != null) {
			filter = new Filter();
			filter.setElement("contractType");
			filter.setValue(getFilterContract().getContractType());
			filters.add(filter);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			Product[] products = _productsDao.getProducts(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(products.length);
			for (Product product : products) {
				String name = product.getName();
				for (int i = 1; i < product.getLevel(); i++) {
					name = " -- " + name;
				}
				items.add(new SelectItem(product.getId(), product.getId() + " - " + name));
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

	private boolean isSearchCustomerByCustomer() {
		return EntityNames.CUSTOMER.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByPerson() {
		return EntityNames.PERSON.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByCompany() {
		return EntityNames.COMPANY.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByContract() {
		return EntityNames.CONTRACT.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByCard() {
		return EntityNames.CARD.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByAccount() {
		return EntityNames.ACCOUNT.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByTerminal() {
		return EntityNames.TERMINAL.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByMerchant() {
		return EntityNames.MERCHANT.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByAddress() {
		return EntityNames.ADDRESS.equals(filter.getEntityType());
	}

	private boolean isSearchCustomerByContact() {
		return EntityNames.CONTACT.equals(filter.getEntityType());
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

	public List<SelectItem> getContractTypes() {
		if (getFilter().getInstId() != null) {
			return getDictUtils().getArticles(DictNames.CONTRACT_TYPE, false, false, getFilter()
					.getInstId());
		} else {
			return getDictUtils().getArticles(DictNames.CONTRACT_TYPE, false);
		}
	}

	public void switchTab() {
		// initialize again when switch tab
		if (SEARCH_TAB_PERSON.equals(searchTabName) || SEARCH_TAB_COMPANY.equals(searchTabName) ||
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
				if (SEARCH_TAB_PERSON.equals(searchTabName)) {
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

	private void setFilterFormPerson(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("id") != null) {
			filter.setId(Long.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("customerNumber") != null) {
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}
		if (filterRec.get("contractNumber") != null) {
			filter.setContractNumber(filterRec.get("contractNumber"));
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
		if (filterRec.get("idType") != null) {
			filter.getDocument().setIdType(filterRec.get("idType"));
		}
		if (filterRec.get("idSeries") != null) {
			filter.getDocument().setIdSeries(filterRec.get("idSeries"));
		}
		if (filterRec.get("idNumber") != null) {
			filter.getDocument().setIdNumber(filterRec.get("idNumber"));
		}

	}

	private void setFilterFormCompany(Map<String, String> filterRec) {
		if (filterRec.get("id") != null) {
			filter.setId(Long.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("customerNumber") != null) {
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}
		if (filterRec.get("contractNumber") != null) {
			filter.setContractNumber(filterRec.get("contractNumber"));
		}
		if (filterRec.get("companyName") != null) {
			filter.getCompany().setLabel(filterRec.get("companyName"));
		}
		if (filterRec.get("idType") != null) {
			filter.getDocument().setIdType(filterRec.get("idType"));
		}
		if (filterRec.get("idSeries") != null) {
			filter.getDocument().setIdSeries(filterRec.get("idSeries"));
		}
		if (filterRec.get("idNumber") != null) {
			filter.getDocument().setIdNumber(filterRec.get("idNumber"));
		}

	}

	private void setFilterFormContract(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("agentId") != null) {
			filterContract.setAgentId(Integer.valueOf(filterRec.get("agentId")));
		}
		if (filterRec.get("productId") != null) {
			filterContract.setProductId(Integer.valueOf(filterRec.get("productId")));
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

	private void setFilterFormCard(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("cardTypeId") != null) {
			filterCard.setCardTypeId(Integer.valueOf(filterRec.get("cardTypeId")));
		}
		if (filterRec.get("productId") != null) {
			filterCard.setProductId(Integer.valueOf(filterRec.get("productId")));
		}
		if (filterRec.get("cardNumber") != null) {
			filterCard.setCardNumber(filterRec.get("cardNumber"));
		}
		if (filterRec.get("cardholderName") != null) {
			filterCard.setCardholderNumber(filterRec.get("cardholderName"));
		}
	}

	private void setFilterFormAccount(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("accountType") != null) {
			filterAccount.setAccountType(filterRec.get("accountType"));
		}
		if (filterRec.get("status") != null) {
			filterAccount.setStatus(filterRec.get("status"));
		}
		if (filterRec.get("currency") != null) {
			filterAccount.setCurrency(filterRec.get("currency"));
		}
	}

	private void setFilterFormMerchant(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("merchantNumber") != null) {
			filterMerchant.setMerchantNumber(filterRec.get("merchantNumber"));
		}
		if (filterRec.get("merchantName") != null) {
			filterMerchant.setMerchantName(filterRec.get("merchantName"));
		}
		if (filterRec.get("mcc") != null) {
			filterMerchant.setMcc(filterRec.get("mcc"));
		}
	}

	private void setFilterFormTerminal(Map<String, String> filterRec) {
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("terminalType") != null) {
			filterTerminal.setTerminalType(filterRec.get("terminalType"));
		}
		if (filterRec.get("terminalNumber") != null) {
			filterTerminal.setTerminalNumber(filterRec.get("terminalNumber"));
		}
		if (filterRec.get("status") != null) {
			filterTerminal.setStatus(filterRec.get("status"));
		}
	}

	private void setFilterFormContact(Map<String, String> filterRec) {
		if (filterRec.get("phone") != null) {
			filter.getContact().setPhone(filterRec.get("phone"));
		}
		if (filterRec.get("mobile") != null) {
			filter.getContact().setMobile(filterRec.get("mobile"));
		}
		if (filterRec.get("fax") != null) {
			filter.getContact().setFax(filterRec.get("fax"));
		}
		if (filterRec.get("email") != null) {
			filter.getContact().setEmail(filterRec.get("email"));
		}
		if (filterRec.get("imType") != null) {
			filter.getContact().setImType(filterRec.get("imType"));
		}
		if (filterRec.get("imNumber") != null) {
			filter.getContact().setImNumber(filterRec.get("imNumber"));
		}
	}

	private void setFilterFormAddress(Map<String, String> filterRec) {
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
	}

	private void setFilterRecPerson(Map<String, String> filterRec) {

		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			filterRec.put("contractNumber", filter.getContractNumber());
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

		if (filter.getDocument().getIdType() != null &&
				filter.getDocument().getIdType().trim().length() > 0) {
			filterRec.put("idType", filter.getDocument().getIdType());
		}
		if (filter.getDocument().getIdSeries() != null &&
				filter.getDocument().getIdSeries().trim().length() > 0) {
			filterRec.put("idSeries", filter.getDocument().getIdSeries());
		}
		if (filter.getDocument().getIdNumber() != null &&
				filter.getDocument().getIdNumber().trim().length() > 0) {
			filterRec.put("idNumber", filter.getDocument().getIdNumber());
		}
	}

	private void setFilterRecCustomer(Map<String, String> filterRec) {

		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			filterRec.put("contractNumber", filter.getContractNumber());
		}
	}

	private void setFilterRecCompany(Map<String, String> filterRec) {

		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			filterRec.put("contractNumber", filter.getContractNumber());
		}
		if (filter.getCompany().getLabel() != null &&
				filter.getCompany().getLabel().trim().length() > 0) {
			filterRec.put("companyName", filter.getCompany().getLabel());
		}
		if (filter.getDocument().getIdType() != null &&
				filter.getDocument().getIdType().trim().length() > 0) {
			filterRec.put("idType", filter.getDocument().getIdType());
		}
		if (filter.getDocument().getIdSeries() != null &&
				filter.getDocument().getIdSeries().trim().length() > 0) {
			filterRec.put("idSeries", filter.getDocument().getIdSeries());
		}
		if (filter.getDocument().getIdNumber() != null &&
				filter.getDocument().getIdNumber().trim().length() > 0) {
			filterRec.put("idNumber", filter.getDocument().getIdNumber());
		}
	}

	private void setFilterRecContract(Map<String, String> filterRec) {
		if (filterContract.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filterContract.getAgentId() != null) {
			filterRec.put("agentId", String.valueOf(filterContract.getAgentId()));
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
		if (filterCard.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filterCard.getCardTypeId() != null) {
			filterRec.put("cardTypeId", String.valueOf(filterCard.getCardTypeId()));
		}
		if (filterCard.getProductId() != null) {
			filterRec.put("productId", String.valueOf(filterCard.getProductId()));
		}
		if (filterCard.getCardNumber() != null && filterCard.getCardNumber().trim().length() > 0) {
			filterRec.put("cardNumber", filterCard.getCardNumber());
		}
		if (filterCard.getCardholderName() != null &&
				filterCard.getCardholderName().trim().length() > 0) {
			filterRec.put("cardholderName", filterCard.getCardholderName());
		}
	}

	private void setFilterRecAccount(Map<String, String> filterRec) {
		if (filterAccount.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filterAccount.getAccountType() != null &&
				filterAccount.getAccountType().trim().length() > 0) {
			filterRec.put("accountType", filterAccount.getAccountType());
		}
		if (filterAccount.getAccountNumber() != null &&
				filterAccount.getAccountNumber().trim().length() > 0) {
			filterRec.put("accountNumber", filterAccount.getAccountNumber());
		}
		if (filterAccount.getStatus() != null && filterAccount.getStatus().trim().length() > 0) {
			filterRec.put("status", filterAccount.getStatus());
		}
		if (filterAccount.getCurrency() != null && filterAccount.getCurrency().trim().length() > 0) {
			filterRec.put("currency", filterAccount.getCurrency());
		}
	}

	private void setFilterRecMerchant(Map<String, String> filterRec) {
		if (filterMerchant.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filterMerchant.getMerchantNumber() != null &&
				filterMerchant.getMerchantNumber().trim().length() > 0) {
			filterRec.put("merchantNumber", filterMerchant.getMerchantNumber());
		}
		if (filterMerchant.getMerchantName() != null &&
				filterMerchant.getMerchantName().trim().length() > 0) {
			filterRec.put("merchantName", filterMerchant.getMerchantName());
		}
		if (filterMerchant.getMcc() != null && filterMerchant.getMcc().trim().length() > 0) {
			filterRec.put("mcc", filterMerchant.getMcc());
		}
	}

	private void setFilterRecTerminal(Map<String, String> filterRec) {
		if (filterTerminal.getInstId() != null) {
			filterRec.put("instId", String.valueOf(filter.getInstId()));
		}
		if (filterTerminal.getTerminalType() != null &&
				filterTerminal.getTerminalType().trim().length() > 0) {
			filterRec.put("terminalType", String.valueOf(filterTerminal.getTerminalType()));
		}
		if (filterTerminal.getTerminalNumber() != null &&
				filterTerminal.getTerminalNumber().trim().length() > 0) {
			filterRec.put("terminalNumber", String.valueOf(filterTerminal.getTerminalNumber()));
		}
		if (filterTerminal.getStatus() != null && filterTerminal.getStatus().trim().length() > 0) {
			filterRec.put("status", String.valueOf(filterTerminal.getStatus()));
		}
	}

	private void setFilterRecContact(Map<String, String> filterRec) {
		if (filter.getContact().getPhone() != null &&
				filter.getContact().getPhone().trim().length() > 0) {
			filterRec.put("phone", filter.getContact().getPhone());
		}
		if (filter.getContact().getMobile() != null &&
				filter.getContact().getPhone().trim().length() > 0) {
			filterRec.put("mobile", filter.getContact().getMobile());
		}
		if (filter.getContact().getFax() != null &&
				filter.getContact().getFax().trim().length() > 0) {
			filterRec.put("fax", filter.getContact().getFax());
		}
		if (filter.getContact().getEmail() != null &&
				filter.getContact().getEmail().trim().length() > 0) {
			filterRec.put("email", filter.getContact().getEmail());
		}
		if (filter.getContact().getImType() != null &&
				filter.getContact().getImType().trim().length() > 0) {
			filterRec.put("imType", filter.getContact().getImType());
		}
		if (filter.getContact().getImNumber() != null &&
				filter.getContact().getImNumber().trim().length() > 0) {
			filterRec.put("imNumber", filter.getContact().getImNumber());
		}
	}

	private void setFilterRecAddress(Map<String, String> filterRec) {
		if (filter.getAddress().getCountry() != null &&
				filter.getAddress().getCountry().trim().length() > 0) {
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

		if (EntityNames.PERSON.equals(ctxItemEntityType)) {
			FacesUtils.setSessionMapValue("module", "iss");
		} else if (EntityNames.COMPANY.equals(ctxItemEntityType)) {
			FacesUtils.setSessionMapValue("module", "acq");
		}
		FacesUtils.setSessionMapValue("entityType", EntityNames.CUSTOMER);
		FacesUtils.setSessionMapValue("customerNumber", _activeCustomer.getCustomerNumber());
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", thisBackLink);
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

	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType(String ctxItemEntityType) {
		this.ctxItemEntityType = ctxItemEntityType;
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

	public void setBeanRestored(boolean beanRestored) {
		this.beanRestored = beanRestored;
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
		deleteTabsStateDB();
		setShowAllTabs(true);
		selectedTabs = null;
		renderTabsMap = null;
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
			selectedTabs.add("contactsTab");
			selectedTabs.add("addressesTab");
			selectedTabs.add("notesTab");			
			selectedTabs.add("acqHierarchyTab");
			selectedTabs.add("issHierarchyTab");
			selectedTabs.add("revenueSharingTab");
			selectedTabs.add("paymentOrdersTab");
			selectedTabs.add("templatesTab");
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
}

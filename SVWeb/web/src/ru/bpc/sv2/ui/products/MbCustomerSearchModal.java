package ru.bpc.sv2.ui.products;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv.ws.cbs.WsClient;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataListModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.ui.utils.model.LoadableDetachableModel;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbCustomerSearchModal")
public class MbCustomerSearchModal extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

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

	private boolean blockInstId;
	private Integer defaultInstId;
	private boolean blockAgentId;
	private Integer defaultAgentId;

	private ProductsDao _productsDao = new ProductsDao();

	private SettingsDao _settingsDao = new SettingsDao();

	private Customer filter;
	private Card filterCard;
	private Contract filterContract;
	private Account filterAccount;
	private Merchant filterMerchant;
	private Terminal filterTerminal;


	private final DaoDataListModel<Customer> _customersSource;
	private final TableRowSelection<Customer> _itemSelection;
	private Customer _activeCustomer;

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

	private String beanName;
	private String methodName;
	private String rerenderList;
	private String module;

	private UserSession userSession;

	private boolean notPersonTab;

	private LoadableDetachableModel<List<SelectItem>> agentsModel;

	private boolean searchingCBS;
	private boolean loadAccountInfo;
	private boolean searchingEWallet;
	private ru.bpc.svap.Customer cbsCustomer;
	private ru.bpc.svap.Customer eWalletCustomer;

	public MbCustomerSearchModal() {
		rowsNum = Integer.MAX_VALUE; // we don't have pages on modal panel so we need to show all entries
		loadAccountInfo = false;
		userSession = ManagedBeanWrapper.getManagedBean("usession");

		_customersSource = new DaoDataListModel<Customer>(logger) {
			private static final long serialVersionUID = 1L;

			@Override
			protected List<Customer> loadDaoListData(SelectionParams params) {
				if (searching) {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setModule(getModule());
					if (tabNameParam != null) {
						return Arrays.asList(_productsDao.getCombinedCustomersProc(userSessionId, params, tabNameParam));
					}
				} else if (searchingCBS) {
					// Check if this customer already exists in SVBO
					final Customer customer = getSvboCustomer(params);
					return new ArrayList<Customer>(1) {{
						if (customer == null) {
							// Customer does not exist, create new entry from CBS
							add(createCbsCustomer(cbsCustomer));
						}
						else {
							// Customer already exists, update SVBO entry from CBS
							add(updateCbsCustomer(cbsCustomer, customer));
						}
					}};
				} else if (searchingEWallet) {
					final Customer customer = getSvboCustomer(params);
					return new ArrayList<Customer>(1) {{
						if (customer == null) {
							add(createEWalletCustomer(eWalletCustomer));
						}
						else {
							add(updateEWalletCustomer(eWalletCustomer, customer));
						}
					}};
				}
				return new ArrayList<Customer>();
			}

			private Customer getSvboCustomer(SelectionParams params) {
				String tabNameParam = setFilters();
				params.setFilters(filters.toArray(new Filter[filters.size()]));
				params.setModule(getModule());
				Customer[] customers = null;
				if (tabNameParam != null) {
					customers = _productsDao.getCombinedCustomersProc(userSessionId, params, tabNameParam);
				}
				if (customers != null && customers.length == 1) {
					return customers[0];
				}
				else {
				    return null;
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setModule(getModule());
					if (tabNameParam != null) {
						return _productsDao.getCombinedCustomersCountProc(userSessionId, params, tabNameParam);
					}
				} else if (searchingCBS) {
					try {
						cbsCustomer = queryCbs(filter.getCustomerNumber(), true);
						if (cbsCustomer != null) {
							return (1);
						}
					} catch (Exception e) {
						logger.error("", e);
						FacesUtils.addMessageError(e);
					}
				} else if (searchingEWallet) {
					try {
						eWalletCustomer = queryEWallet(filter.getCustomerNumber(), true);
						if (eWalletCustomer != null) {
							return (1);
						}
					} catch (Exception e) {
						logger.error("", e);
						FacesUtils.addMessageError(e);
					}

				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Customer>(null, _customersSource);

		setSearchTabName(SEARCH_TAB_CUSTOMER);
		setDefaultValues();
		agentsModel = new LoadableDetachableModel<List<SelectItem>>() {
			@Override
			protected List<SelectItem> load() {
				Map<String, Object> paramMap = new HashMap<String, Object>();
				paramMap.put("INSTITUTION_ID", getFilter().getInstId());
				return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
			}
		};
	}

	public DaoDataListModel<Customer> getCustomers() {
		return _customersSource;
	}

	public Customer getActiveCustomer() {
		if (_activeCustomer != null) {
			if (_activeCustomer.getInstId() == null) {
				if (getFilter().getInstId() != null) {
					_activeCustomer.setInstId(getFilter().getInstId());
					for (SelectItem inst : institutions) {
						if (inst.getValue().toString().equals(_activeCustomer.getInstId().toString())) {
							_activeCustomer.setInstName(inst.getLabel());
						}
					}
				}
			}
			if (_activeCustomer.getEntityType() == null) {
				_activeCustomer.setEntityType(getFilter().getEntityType());
			}
		}
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
	}

	public void setFirstRowActive() {
		_customersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomer = (Customer) _customersSource.getRowData();
		selection.addKey(_activeCustomer.getModelId());
		_itemSelection.setWrappedSelection(selection);

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

		if (filterContract.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filterContract.getAgentId());
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

		if (filterCard.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filterCard.getAgentId());
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

		if (filterAccount.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filterAccount.getAgentId());
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

		if (filterMerchant.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filterMerchant.getAgentId());
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

		if (filterTerminal.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", filterTerminal.getAgentId());
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
			paramFilter.setValue(filter.getAddress().getPostalCode());
			filters.add(paramFilter);
		}
		if (filter.getAddress().getApartment() != null &&
				filter.getAddress().getApartment().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("APARTMENT");
			paramFilter.setValue(filter.getAddress().getApartment());
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
		if (filter == null) {
			filter = new Customer();
		}
		return filter;
	}

	public void setFilter(Customer filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		setDefaultValues();
		searching = false;
		searchingCBS = false;
		searchingEWallet = false;
		loadAccountInfo = false;
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
		searchingCBS = true;
		searchingEWallet = true;
	}

	public void searchCBS() {
		getFilter().setEntityType(EntityNames.CUSTOMER);
	    curMode = VIEW_MODE;
	    clearBean();
	    searching = false;
	    searchingCBS = true;
		searchingEWallet = false;
	}

	public void searchEWallet() {
		getFilter().setEntityType(EntityNames.CUSTOMER);
		curMode = VIEW_MODE;
		clearBean();
		searching = false;
		searchingCBS = false;
		searchingEWallet = true;
	}

	public void clearBean() {
		curLang = userLang;
		_customersSource.flushCache();
		_itemSelection.clearSelection();
		_activeCustomer = null;
		eWalletCustomer = null;
		cbsCustomer = null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
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
		return agentsModel.getObject();
	}

	public List<SelectItem> getCardTypes() {
		if (cardTypes == null) {
			cardTypes = getDictUtils().getLov(LovConstants.CARD_TYPES);
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
		return EntityNames.IDENTIFICATOR.equals(filter.getEntityType());
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
	}

	public void setPageNumber(int pageNumber) {
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

	public List<SelectItem> getContractTypes() {
		if (getFilterContract().getInstId() != null) {
			return getDictUtils().getArticles(DictNames.CONTRACT_TYPE, false, false, getFilter()
					.getInstId());
		} else {
			return getDictUtils().getArticles(DictNames.CONTRACT_TYPE, false);
		}
	}

	public Logger getLogger() {
		return logger;
	}

	public String getBeanName() {
		return beanName;
	}

	public void setBeanName(String beanName) {
		this.beanName = beanName;
	}

	public String getRerenderList() {
		return rerenderList;
	}

	public void setRerenderList(String rerenderList) {
		this.rerenderList = rerenderList;
	}

	public String getMethodName() {
		if (methodName == null || "".equals(methodName)) {
			return "selectCustomer";
		}
		return methodName;
	}

	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}

	public ArrayList<SelectItem> getMerchantTypes() {
		if (merchantTypes == null) {
			merchantTypes = getDictUtils().getArticles(DictNames.MERCHANT_TYPE, true);
		}
		return merchantTypes;
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

	public String getModule() {
		return module;
	}
	public void setModule(String module) {
		this.module = module;
	}

	public boolean isBlockInstId() {
		return blockInstId;
	}

	public void setBlockInstId(boolean blockInstId) {
		this.blockInstId = blockInstId;
	}

	private void setDefaultValues() {
		// this search is done from other beans that set some instId in preinitialization
		// we should use this instId as default 
		Integer defaultInstId = this.defaultInstId == null ? userInstId : this.defaultInstId;
		Integer defaultAgentId = this.defaultAgentId == null ? userAgentId : this.defaultAgentId;

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

	public Integer getDefaultInstId() {
		return defaultInstId;
	}

	public void setDefaultInstId(Integer defaultInstId) {
		this.defaultInstId = defaultInstId;
		setDefaultValues();
	}

	public Integer getDefaultAgentId() {
		return defaultAgentId;
	}

	public void setDefaultAgentId(Integer defaultAgentId) {
		this.defaultAgentId = defaultAgentId;
		setDefaultValues();
	}

	public boolean isBlockAgentId() {
		return blockAgentId;
	}

	public void setBlockAgentId(boolean blockAgentId) {
		this.blockAgentId = blockAgentId;
	}

	public boolean isNotPersonTab() {
		return notPersonTab;
	}

	public void setNotPersonTab(boolean notPersonTab) {
		this.notPersonTab = notPersonTab;
	}

	public void clearDefaultAgent() {
		if (SEARCH_TAB_CUSTOMER.equals(searchTabName) || SEARCH_TAB_PERSON.equals(searchTabName) ||
				SEARCH_TAB_COMPANY.equals(searchTabName) ||
				SEARCH_TAB_DOCUMENT.equals(searchTabName) ||
				SEARCH_TAB_CONTACT.equals(searchTabName) ||
				SEARCH_TAB_ADDRESS.equals(searchTabName)) {
			getFilter().setAgentId(null);
		} else if (SEARCH_TAB_CONTRACT.equals(searchTabName)) {
			getFilterContract().setAgentId(null);
		} else if (SEARCH_TAB_CARD.equals(searchTabName)) {
			getFilterCard().setAgentId(null);
		} else if (SEARCH_TAB_ACCOUNT.equals(searchTabName)) {
			getFilterAccount().setAgentId(null);
		} else if (SEARCH_TAB_MERCHANT.equals(searchTabName)) {
			getFilterMerchant().setAgentId(null);
		} else if (SEARCH_TAB_TERMINAL.equals(searchTabName)) {
			getFilterTerminal().setAgentId(null);
		}
	}

	public ru.bpc.svap.Customer getCbsCustomer() {
		return cbsCustomer;
	}

	public void setCbsCustomer(ru.bpc.svap.Customer cbsCustomer) {
		this.cbsCustomer = cbsCustomer;
	}

	public ru.bpc.svap.Customer geteWalletCustomer() {
		return eWalletCustomer;
	}

	public void seteWalletCustomer(ru.bpc.svap.Customer eWalletCustomer) {
		this.eWalletCustomer = eWalletCustomer;
	}

	private String getCbsWsUrl() {
		return (_settingsDao.getParameterValueV(null, SettingsConstants.CBS_SVAPINT_WS_URL, LevelNames.INSTITUTION, null));
	}

	private String getEWalletWsUrl() {
		return (_settingsDao.getParameterValueV(null, SettingsConstants.EWALLET_SVAPINT_WS_URL, LevelNames.INSTITUTION, null));
	}

	private Customer createCbsCustomer(final ru.bpc.svap.Customer cbsCustomer) {
		return (updateCbsCustomer(cbsCustomer, new Customer() {{
			setId(-1L);
			setNewCustomer(true);
		}}));
	}

	private Customer updateCbsCustomer(final ru.bpc.svap.Customer cbsCustomer, Customer customer) {
		customer.setCustomerNumber(cbsCustomer.getId());
		if (cbsCustomer.getCategory() != null && StringUtils.isNotBlank(cbsCustomer.getCategory())) {
			customer.setCategory(cbsCustomer.getCategory());
		}
		if (StringUtils.isNotBlank(cbsCustomer.getNationality())) {
			customer.setNationality(cbsCustomer.getNationality());
		}
		if (cbsCustomer.isIsResidence() != null) {
			customer.setResident(cbsCustomer.isIsResidence());
		}
		if (cbsCustomer.getPerson() != null) {
			if (!cbsCustomer.getPerson().getPersonName().isEmpty()) {
				if (StringUtils.isNotEmpty(cbsCustomer.getPerson().getPersonName().get(0).getSecondName())) {
					customer.setCustomerName(cbsCustomer.getPerson().getPersonName().get(0).getFirstName() + " " +
											 cbsCustomer.getPerson().getPersonName().get(0).getSecondName() + " " +
											 cbsCustomer.getPerson().getPersonName().get(0).getSurname());
				} else {
					customer.setCustomerName(cbsCustomer.getPerson().getPersonName().get(0).getFirstName() + " " +
											 cbsCustomer.getPerson().getPersonName().get(0).getSurname());
				}
				customer.getPerson().setFirstName(cbsCustomer.getPerson().getPersonName().get(0).getFirstName());
				customer.getPerson().setSecondName(cbsCustomer.getPerson().getPersonName().get(0).getSecondName());
				customer.getPerson().setSurname(cbsCustomer.getPerson().getPersonName().get(0).getSurname());
			}
			if (!cbsCustomer.getPerson().getIdentityCard().isEmpty()) {
				customer.setDocumentString(cbsCustomer.getPerson().getIdentityCard().get(0).getIdType() + " " +
										   cbsCustomer.getPerson().getIdentityCard().get(0).getIdSeries() + " " +
										   cbsCustomer.getPerson().getIdentityCard().get(0).getIdNumber());
			}
			if (cbsCustomer.getPerson().getBirthday() != null) {
				if (cbsCustomer.getPerson().getBirthday().isValid()) {
					customer.getPerson().setBirthday(cbsCustomer.getPerson().getBirthday().toGregorianCalendar().getTime());
				}
			}
			if (cbsCustomer.getPerson().getGender() != null && StringUtils.isNotEmpty(cbsCustomer.getPerson().getGender().value())) {
				customer.getPerson().setGender(cbsCustomer.getPerson().getGender().value());
			}
			customer.setEntityType(EntityNames.PERSON);
		} else if (cbsCustomer.getCompany() != null) {
			if (!cbsCustomer.getCompany().getCompanyName().isEmpty()) {
				customer.setCustomerName(cbsCustomer.getCompany().getCompanyName().get(0).getCompanyShortName());
			}
			if (!cbsCustomer.getCompany().getIdentityCard().isEmpty()) {
				customer.setDocumentString(cbsCustomer.getCompany().getIdentityCard().get(0).getIdType() + " " +
										   cbsCustomer.getCompany().getIdentityCard().get(0).getIdSeries() + " " +
										   cbsCustomer.getCompany().getIdentityCard().get(0).getIdNumber());
			}
			customer.setEntityType(EntityNames.COMPANY);
		}
		return (customer);
	}

	private Customer createEWalletCustomer(final ru.bpc.svap.Customer eWalletCustomer) {
		return (updateEWalletCustomer(eWalletCustomer, new Customer() {{
			setId(-1L);
			setNewCustomer(true);
		}}));
	}

	private Customer updateEWalletCustomer(final ru.bpc.svap.Customer eWalletCustomer, Customer customer) {
		customer.setCustomerNumber(eWalletCustomer.getId());
		if (eWalletCustomer.getPerson() != null) {
			if (!eWalletCustomer.getPerson().getPersonName().isEmpty()) {
				if (StringUtils.isNotEmpty(eWalletCustomer.getPerson().getPersonName().get(0).getSecondName())) {
					customer.setCustomerName(eWalletCustomer.getPerson().getPersonName().get(0).getFirstName() + " " +
											 eWalletCustomer.getPerson().getPersonName().get(0).getSecondName() + " " +
											 eWalletCustomer.getPerson().getPersonName().get(0).getSurname());
				} else {
					customer.setCustomerName(eWalletCustomer.getPerson().getPersonName().get(0).getFirstName() + " " +
											 eWalletCustomer.getPerson().getPersonName().get(0).getSurname());
				}
				customer.getPerson().setFirstName(eWalletCustomer.getPerson().getPersonName().get(0).getFirstName());
				customer.getPerson().setSecondName(eWalletCustomer.getPerson().getPersonName().get(0).getSecondName());
				customer.getPerson().setSurname(eWalletCustomer.getPerson().getPersonName().get(0).getSurname());
			}
			if (!eWalletCustomer.getPerson().getIdentityCard().isEmpty()) {
				customer.setDocumentString(eWalletCustomer.getPerson().getIdentityCard().get(0).getIdType() + " " +
										   eWalletCustomer.getPerson().getIdentityCard().get(0).getIdSeries() + " " +
										   eWalletCustomer.getPerson().getIdentityCard().get(0).getIdNumber());
			}
			if (eWalletCustomer.getPerson().getBirthday() != null) {
				if (eWalletCustomer.getPerson().getBirthday().isValid()) {
					customer.getPerson().setBirthday(eWalletCustomer.getPerson().getBirthday().toGregorianCalendar().getTime());
				}
			}
			if (eWalletCustomer.getPerson().getGender() != null && StringUtils.isNotEmpty(eWalletCustomer.getPerson().getGender().value())) {
				customer.getPerson().setGender(eWalletCustomer.getPerson().getGender().value());
			}
			customer.setEntityType(EntityNames.PERSON);
		} else if (eWalletCustomer.getCompany() != null) {
			if (!eWalletCustomer.getCompany().getCompanyName().isEmpty()) {
				customer.setCustomerName(eWalletCustomer.getCompany().getCompanyName().get(0).getCompanyShortName());
			}
			if (!eWalletCustomer.getCompany().getIdentityCard().isEmpty()) {
				customer.setDocumentString(eWalletCustomer.getCompany().getIdentityCard().get(0).getIdType() + " " +
										   eWalletCustomer.getCompany().getIdentityCard().get(0).getIdSeries() + " " +
										   eWalletCustomer.getCompany().getIdentityCard().get(0).getIdNumber());
			}
			customer.setEntityType(EntityNames.COMPANY);
		}
		return (customer);
	}

	public ru.bpc.svap.Customer queryCbs(String customerNumber, boolean displayError) {
		try {
			ru.bpc.svap.Customer cbsCustomer = loadAccountInfo ? new WsClient(getCbsWsUrl()).getCustomerInfoWithoutAccounts(customerNumber)
															   : new WsClient(getCbsWsUrl()).getCustomerInfo(customerNumber);;
			if (cbsCustomer != null && StringUtils.isNotEmpty(cbsCustomer.getId())) {
				return (cbsCustomer);
			}
		}
		catch (Exception e) {
			logger.error("", e);
			if (displayError) {
				FacesUtils.addMessageError(e);
			}
		}
		return (null);
	}

	public ru.bpc.svap.Customer queryEWallet(String customerNumber, boolean displayError) {
		try {
			ru.bpc.svap.Customer eWalletCustomer = new WsClient(getEWalletWsUrl()).getCustomerInfo(customerNumber);
			if (eWalletCustomer != null && StringUtils.isNotEmpty(eWalletCustomer.getId())) {
				return (eWalletCustomer);
			}
		} catch (Exception e) {
			logger.error("", e);
			if (displayError) {
				FacesUtils.addMessageError(e);
			}
		}
		return (null);
	}

	public boolean isLoadAccountInfo() {
		return loadAccountInfo;
	}
	public void setLoadAccountInfo(boolean loadAccountInfo) {
		this.loadAccountInfo = loadAccountInfo;
	}
}

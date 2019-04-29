package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.AccountType;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.CommonHierarchyObject;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAcquiringHierarchySearch")
public class MbAcquiringHierarchySearch extends AbstractBean {

	private static final long serialVersionUID = 1L;

	private static String COMPONENT_ID = "acqObjsTable";

	// Filters
	private Account accountFilter;
	private Terminal terminalFilter;
	private Merchant merchantFilter;
	private Customer customerFilter;
	private Contract contractFilter;

	private String selectedFilter;
	private String searchTabName;
	
	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private AccountsDao _accountsDao = new AccountsDao();

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private ProductsDao _productsDao = new ProductsDao();

	
	private CurrencyUtils currencyUtils;

	private List<SelectItem> institutions;
	private List<SelectItem> genders;
	private List<SelectItem> extEntityTypes;

	private final DaoDataModel<CommonHierarchyObject> _acqObjsSource;
	private final TableRowSelection<CommonHierarchyObject> _itemSelection;
	private CommonHierarchyObject _activeAcqObj;

	private UserSession userSession;
	
	public MbAcquiringHierarchySearch() {
		searchTabName = "customerTab";
		
		currencyUtils = (CurrencyUtils) ManagedBeanWrapper.getManagedBean("CurrencyUtils");
		userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		
		setDefaultValues();

		_acqObjsSource = new DaoDataModel<CommonHierarchyObject>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected CommonHierarchyObject[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CommonHierarchyObject[0];
				}

				CommonHierarchyObject[] acqObjs = null;

				try {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					if (EntityNames.TERMINAL.equals(selectedFilter)) {
						acqObjs = getTerminals(params);
					} else if (EntityNames.MERCHANT.equals(selectedFilter)) {
						acqObjs = getMerchants(params);
					} else if (EntityNames.ACCOUNT.equals(selectedFilter)) {
						acqObjs = getAccounts(params);
					} else if (EntityNames.CONTRACT.equals(selectedFilter)) {
						acqObjs = getContracts(params);
					} else if (isCustomersSearch()) {
						acqObjs = getCustomers(params, tabNameParam);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}

				if (acqObjs == null) {
					acqObjs = new CommonHierarchyObject[0];
				}
				return acqObjs;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					Map<String, Object> paramsMap = new HashMap<String, Object>();
					
					if (EntityNames.TERMINAL.equals(selectedFilter)) {
						paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
						paramsMap.put("tab_name", "TERMINAL");
						return _acquiringDao.getTerminalsCountCur(userSessionId,
								((HashMap<String, Object>)paramsMap));
					} else if (EntityNames.MERCHANT.equals(selectedFilter)) {
						paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
						paramsMap.put("tab_name", "MERCHANT");
						return _acquiringDao.getMerchantsCurCount(userSessionId, paramsMap);
					} else if (EntityNames.ACCOUNT.equals(selectedFilter)) {
						paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
						paramsMap.put("tab_name", "ACCOUNT");
						return _accountsDao.getAccountsCountCur(userSessionId, paramsMap);
					} else if (EntityNames.CONTRACT.equals(selectedFilter)) {
						paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
						paramsMap.put("tab_name", "CONTRACT");
						return _productsDao.getContractsCurCount(userSessionId, params, paramsMap);
					} else if (isCustomersSearch()) {
						return _productsDao.getCombinedCustomersCountProc(userSessionId, params,
								tabNameParam);
					}
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}

				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CommonHierarchyObject>(null, _acqObjsSource);
	}

	public DaoDataModel<CommonHierarchyObject> getAcqObjs() {
		return _acqObjsSource;
	}

	public CommonHierarchyObject getActiveAcqObj() {
		return _activeAcqObj;
	}

	public void setActiveAcqObj(CommonHierarchyObject activeAcqObj) {
		_activeAcqObj = activeAcqObj;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAcqObj = _itemSelection.getSingleSelection();
	}

	private CommonHierarchyObject[] getTerminals(SelectionParams params) throws Exception {
		CommonHierarchyObject[] issObjs;
		HashMap<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
		paramsMap.put("tab_name", "TERMINAL");
		Terminal[] terminals = _acquiringDao.getTerminalsCur(userSessionId, params, paramsMap);
		issObjs = new CommonHierarchyObject[terminals.length];
		int i = 0;
		for (Terminal terminal : terminals) {
			issObjs[i] = new CommonHierarchyObject();
			issObjs[i].setId(terminal.getId().longValue());
			issObjs[i].setName(terminal.getTerminalName());
			issObjs[i].setEntityType(EntityNames.TERMINAL);
			i++;
		}
		return issObjs;
	}

	private CommonHierarchyObject[] getMerchants(SelectionParams params) throws Exception {
		CommonHierarchyObject[] issObjs;
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
		paramsMap.put("tab_name", "MERCHANT");
		Merchant[] merchants = _acquiringDao.getMerchantsCur(userSessionId, params, paramsMap);
		issObjs = new CommonHierarchyObject[merchants.length];
		int i = 0;
		for (Merchant merchant : merchants) {
			issObjs[i] = new CommonHierarchyObject();
			issObjs[i].setId(merchant.getId().longValue());
			issObjs[i].setName(merchant.getLabel());
			issObjs[i].setEntityType(EntityNames.MERCHANT);
			i++;
		}
		return issObjs;
	}

	private CommonHierarchyObject[] getAccounts(SelectionParams params) throws Exception {
		CommonHierarchyObject[] issObjs;

		// This can be used only when acq_ui_account_vw is corrected
		// Account[] accounts = _accountsDao.getAcqAccounts(userSessionId, params);

		// This can be used any time as long as there is "productType" filter
		// (set to acquiring products code) among filters
		HashMap<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
		paramsMap.put("tab_name", "ACCOUNT");
		Account[] accounts = _accountsDao.getAccountsCur(userSessionId, params, paramsMap);

		issObjs = new CommonHierarchyObject[accounts.length];
		int i = 0;
		for (Account account : accounts) {
			issObjs[i] = new CommonHierarchyObject();
			issObjs[i].setId(account.getId());
			issObjs[i].setName(currencyUtils.getCurrencyShortNamesMap().get(account.getCurrency()) +
					" " + account.getAccountNumber() + " " +
					getDictUtils().getAllArticlesDesc().get(account.getStatus()));
			issObjs[i].setEntityType(EntityNames.ACCOUNT);
			i++;
		}
		return issObjs;
	}

	private CommonHierarchyObject[] getContracts(SelectionParams params) throws Exception {
		CommonHierarchyObject[] issObjs;
		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", params.getFilters());
		paramsMap.put("tab_name", "CONTRACT");
		Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);
		issObjs = new CommonHierarchyObject[contracts.length];
		int i = 0;
		for (Contract contract : contracts) {
			issObjs[i] = new CommonHierarchyObject();
			issObjs[i].setId(contract.getId().longValue());
			issObjs[i].setName(contract.getContractNumber());
			issObjs[i].setEntityType(EntityNames.CONTRACT);
			i++;
		}
		return issObjs;
	}

	public CommonHierarchyObject[] getCustomers(SelectionParams params, String tabNameParam) throws Exception {
		CommonHierarchyObject[] issObjs;
		Customer[] customers;

		customers = _productsDao.getCombinedCustomersProc(userSessionId, params, tabNameParam);

		issObjs = new CommonHierarchyObject[customers.length];
		int i = 0;
		for (Customer customer : customers) {
			issObjs[i] = new CommonHierarchyObject();
			issObjs[i].setId(customer.getId());
//			String customerName = "";
//			if (EntityNames.PERSON.equals(customer.getEntityType()) && customer.getPerson() != null) {
//				customerName = customer.getPerson().getFirstName() +
//						" " +
//						(customer.getPerson().getSecondName() == null ? "" : (customer.getPerson()
//								.getSecondName() + " ")) +
//						(customer.getPerson().getSurname() == null ? "" : customer.getPerson()
//								.getSurname());
//			} else if (EntityNames.COMPANY.equals(customer.getEntityType()) &&
//					customer.getCompany() != null) {
//				customerName = customer.getCompany().getLabel();
//			}
			issObjs[i].setName(customer.getCustomerNumber() + ", " + customer.getCustomerName());
			issObjs[i].setEntityType(EntityNames.CUSTOMER);
			i++;
		}
		return issObjs;
	}

	public void searchByCustomer() {
		selectedFilter = EntityNames.CUSTOMER;
		search();
	}
	
	public void syncInst(ActionEvent actionEvent) {
		Integer syncInstId;
		String clientId = actionEvent.getComponent().getClientId(FacesContext.getCurrentInstance());
		if (clientId.contains("contract")) {
			syncInstId = contractFilter.getInstId();
		} else if (clientId.contains("merchant")) {
			syncInstId = merchantFilter.getInstId();
		} else if (clientId.contains("terminal")) {
			syncInstId = terminalFilter.getInstId();
		} else if (clientId.contains("account")) {
			syncInstId = accountFilter.getInstId();
		} else {
			syncInstId = customerFilter.getInstId();
		}
		if (syncInstId != null) {
			getContractFilter().setInstId(syncInstId);
			getAccountFilter().setInstId(syncInstId);
			getTerminalFilter().setInstId(syncInstId);
			getMerchantFilter().setInstId(syncInstId);
			getCustomerFilter().setInstId(syncInstId);
		}
	}

	public void searchByCompany() {
		selectedFilter = EntityNames.COMPANY;
		search();
	}

	public void searchByContract() {
		selectedFilter = EntityNames.CONTRACT;
		search();
	}
	
	public void searchByAccount() {
		selectedFilter = EntityNames.ACCOUNT;
		search();
	}

	public void searchByMerchant() {
		selectedFilter = EntityNames.MERCHANT;
		search();
	}

	public void searchByTerminal() {
		selectedFilter = EntityNames.TERMINAL;
		search();
	}

	public void search() {
		searching = true;

		// search using new criteria
		_acqObjsSource.flushCache();

		// reset selection
		if (_activeAcqObj != null) {
			_itemSelection.unselect(_activeAcqObj);
			_activeAcqObj = null;
		}

		// reset dependent bean
	}

	public void clearFilter() {
		curLang = userLang;
		accountFilter = new Account();
		terminalFilter = new Terminal();
		merchantFilter = new Merchant();
		customerFilter = new Customer();
		contractFilter = new Contract();

		selectedFilter = "";
		searching = false;

		setDefaultValues();
		
		MbAcquiringHierarchy acqHier = (MbAcquiringHierarchy) ManagedBeanWrapper
				.getManagedBean("MbAcquiringHierarchy");
		acqHier.clearFilter();
	}

	private void setDefaultValues() {
		Integer defaultInstId = userInstId;
		Integer defaultAgentId = userAgentId;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
			defaultAgentId = null;
		}
		getCustomerFilter().setInstId(defaultInstId);
		getCustomerFilter().setAgentId(defaultAgentId);
		getContractFilter().setInstId(defaultInstId);
		getContractFilter().setAgentId(defaultAgentId);
		getAccountFilter().setInstId(defaultInstId);
		getAccountFilter().setAgentId(defaultAgentId);
		getMerchantFilter().setInstId(defaultInstId);
		getTerminalFilter().setInstId(defaultInstId);
		if (userSession.getInRole().get(SystemConstants.VIEW_ALL_CUSTOMERS_PRIVILEGE)) {
			getCustomerFilter().setCustomerNumber("*");
			getCustomerFilter().getPerson().setSurname("*");
			getCustomerFilter().getPerson().setFirstName("*");
			getCustomerFilter().getCompany().setLabel("*");
			getContractFilter().setContractNumber("*");
			getAccountFilter().setAccountNumber("*");
		}
	}

	private String setFilters() {
		filters = new ArrayList<Filter>();

		if (EntityNames.TERMINAL.equals(selectedFilter)) {
			setTerminalFilters();
			return "TERMINAL";
		} else if (EntityNames.MERCHANT.equals(selectedFilter)) {
			setMerchantFilters();
			return "MERCHANT";
		} else if (EntityNames.ACCOUNT.equals(selectedFilter)) {
			setAccountFilters();
			return "ACCOUNT";
		} else if (EntityNames.CONTRACT.equals(selectedFilter)) {
			setContractFilters();
			return "CONTRACT";
		} else if (EntityNames.CUSTOMER.equals(selectedFilter)) {
			setCustomerFilters();
			return "CUSTOMER";
		} else if (EntityNames.COMPANY.equals(selectedFilter)) {
			setCompanyFilters();
			return "COMPANY";
		} else {
			return null;
		}
	}

	private boolean isCustomersSearch() {
		return EntityNames.CUSTOMER.equals(selectedFilter) 
				|| EntityNames.COMPANY.equals(selectedFilter);
	}

	private void setTerminalFilters() {
		getTerminalFilter();
		
		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (getCustomerFilter().getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(terminalFilter.getInstId());
			filters.add(paramFilter);
		}

		if (terminalFilter.getTerminalNumber() != null &&
				!terminalFilter.getTerminalNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("TERMINAL_NUMBER");
			paramFilter.setValue(terminalFilter.getTerminalNumber().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (terminalFilter.getTerminalType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("TERMINAL_TYPE");
			paramFilter.setValue(terminalFilter.getTerminalType());
			filters.add(paramFilter);
		}

		if (terminalFilter.getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setValue(terminalFilter.getStatus());
			filters.add(paramFilter);
		}
	}

	private void setMerchantFilters() {
		getMerchantFilter();
		
		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		if (merchantFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(merchantFilter.getInstId());
			filters.add(paramFilter);
		}

		if (merchantFilter.getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setValue(merchantFilter.getStatus());
			filters.add(paramFilter);
		}

		if (merchantFilter.getMerchantName() != null &&
				merchantFilter.getMerchantName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NAME");
			paramFilter.setValue(merchantFilter.getMerchantName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (merchantFilter.getLabel() != null && merchantFilter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(merchantFilter.getLabel().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (merchantFilter.getMerchantType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_TYPE");
			paramFilter.setValue(merchantFilter.getMerchantType());
			filters.add(paramFilter);
		}

		if (merchantFilter.getMerchantNumber() != null &&
				merchantFilter.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NUMBER");
			paramFilter.setValue(merchantFilter.getMerchantNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	private void setAccountFilters() {
		getAccountFilter();
		
		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		// to get only those accounts that refer to acquiring entities
		filters.add(new Filter("PARTICIPANT_MODE", "ACQ"));

		if (accountFilter.getAccountNumber() != null &&
				accountFilter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setCondition("LIKE");
			paramFilter.setValue(accountFilter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (accountFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(accountFilter.getInstId());
			filters.add(paramFilter);
		}
		if (accountFilter.getAgentId() != null) {
			filters.add(new Filter("AGENT_ID", accountFilter.getAgentId()));
		}
		if (accountFilter.getAccountType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_TYPE");
			paramFilter.setValue(accountFilter.getAccountType());
			filters.add(paramFilter);
		}
		if (accountFilter.getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setValue(accountFilter.getStatus());
			filters.add(paramFilter);
		}
	}

	private void setContractFilters() {
		getContractFilter();
		
		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		// to get only those contracts that refer to acquiring entities
		paramFilter = new Filter();
		paramFilter.setElement("PRODUCT_TYPE");
		paramFilter.setValue(ProductConstants.ACQUIRING_PRODUCT);
		filters.add(paramFilter);

		if (contractFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_ID");
			paramFilter.setValue(contractFilter.getId());
			filters.add(paramFilter);
		}
		if (contractFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(contractFilter.getInstId());
			filters.add(paramFilter);
		}
		if (contractFilter.getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setValue(contractFilter.getCustomerId());
			filters.add(paramFilter);
		}
		if (contractFilter.getContractNumber() != null &&
				contractFilter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_NUMBER");
			paramFilter.setValue(contractFilter.getContractNumber().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	private void setCustomerFilters() {
		getCustomerFilter();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		paramFilter = new Filter("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		filters.add(paramFilter);
		
		if (customerFilter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", customerFilter.getInstId());
			filters.add(paramFilter);
		}
		if (customerFilter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", customerFilter.getAgentId());
			filters.add(paramFilter);
		}
		if (customerFilter.getCustomerNumber() != null && customerFilter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setValue(customerFilter.getCustomerNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (customerFilter.getContractNumber() != null && customerFilter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_NUMBER");
			paramFilter.setValue(customerFilter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (customerFilter.getContractNumber() != null) {
			paramFilter = new Filter("EXT_ENTITY_TYPE", customerFilter.getExtEntityType());
			filters.add(paramFilter);
		}
	}

	private void setCompanyFilters() {
		getCustomerFilter();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		paramFilter = new Filter("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		filters.add(paramFilter);

		if (customerFilter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", customerFilter.getInstId());
			filters.add(paramFilter);
		}

		if (customerFilter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", customerFilter.getAgentId());
			filters.add(paramFilter);
		}

		if (customerFilter.getCompany().getLabel() != null &&
				customerFilter.getCompany().getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("COMPANY_NAME");
			paramFilter.setValue(customerFilter.getCompany().getLabel().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public Account getAccountFilter() {
		if (accountFilter == null) {
			accountFilter = new Account();
		}
		return accountFilter;
	}

	public void setAccountFilter(Account accountFilter) {
		this.accountFilter = accountFilter;
	}

	public Terminal getTerminalFilter() {
		if (terminalFilter == null) {
			terminalFilter = new Terminal();
		}
		return terminalFilter;
	}

	public void setTerminalFilter(Terminal terminalFilter) {
		this.terminalFilter = terminalFilter;
	}

	public Merchant getMerchantFilter() {
		if (merchantFilter == null) {
			merchantFilter = new Merchant();
		}
		return merchantFilter;
	}

	public void setMerchantFilter(Merchant merchantFilter) {
		this.merchantFilter = merchantFilter;
	}

	public Contract getContractFilter() {
		if (contractFilter == null) {
			contractFilter = new Contract();
		}
		return contractFilter;
	}

	public void setContractFilter(Contract contractFilter) {
		this.contractFilter = contractFilter;
	}

	public Customer getCustomerFilter() {
		if (customerFilter == null) {
			customerFilter = new Customer();
		}
		return customerFilter;
	}

	public void setCustomerFilter(Customer customerFilter) {
		this.customerFilter = customerFilter;
	}

	public void resetBean() {
	}

	public void cancel() {

	}

	public void changeFilter(ValueChangeEvent event) {
		selectedFilter = (String) event.getNewValue();
	}

	public void select() {
		MbAcquiringHierarchy acqHier = (MbAcquiringHierarchy) ManagedBeanWrapper
				.getManagedBean("MbAcquiringHierarchy");
		acqHier.setObjectId(_activeAcqObj.getId());
		acqHier.setObjectType(_activeAcqObj.getEntityType());
		acqHier.setObjectName(_activeAcqObj.getName());
		acqHier.search();
	}

	public boolean isSearchByTerminal() {
		return EntityNames.TERMINAL.equals(selectedFilter);
	}

	public boolean isSearchByMerchant() {
		return EntityNames.MERCHANT.equals(selectedFilter);
	}

	public boolean isSearchByAccount() {
		return EntityNames.ACCOUNT.equals(selectedFilter);
	}

	public boolean isSearchByContract() {
		return EntityNames.CONTRACT.equals(selectedFilter);
	}

	public boolean isSearchByCustomer() {
		return EntityNames.CUSTOMER.equals(selectedFilter);
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null || institutions.isEmpty()) {
			institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		return institutions;
	}

	public List<SelectItem> getCustomerAgents() {
		if (getCustomerFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getCustomerFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public List<SelectItem> getAccountAgents() {
		if (getAccountFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getAccountFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public List<SelectItem> getContractAgents() {
		if (getContractFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getContractFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public ArrayList<SelectItem> getAccountStatuses() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_STATUS, false, false);
	}

	public ArrayList<SelectItem> getAccountTypes() {

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

			if (getAccountFilter().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getAccountFilter().getInstId().toString());
				filtersList.add(paramFilter);
			}
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			AccountType[] types = _accountsDao.getAccountTypes(userSessionId, params);
			for (AccountType type : types) {
				items.add(new SelectItem(type.getAccountType(), getDictUtils().getAllArticlesDesc().get(
						type.getAccountType())));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}

		return items;
	}

	public String getSelectedFilter() {
		return selectedFilter;
	}

	public void setSelectedFilter(String selectedFilter) {
		this.selectedFilter = selectedFilter;
	}

	public ArrayList<SelectItem> getTerminalTypes() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, true);
	}

	public ArrayList<SelectItem> getTerminalStatuses() {
		return getDictUtils().getArticles(DictNames.TERMINAL_STATUS, true);
	}

	public ArrayList<SelectItem> getMerchantTypes() {
		return getDictUtils().getArticles(DictNames.MERCHANT_TYPE, true);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}

	public List<SelectItem> getGenders() {
		if (genders == null) {
			genders = getDictUtils().getArticles(DictNames.PERSON_GENDER, false, false);
		}
		return genders;
	}

	public List<SelectItem> getExtEntityTypes() {
		if (extEntityTypes == null) {
			extEntityTypes = getDictUtils().getLov(LovConstants.EXT_ENTITY_TYPES);
		}
		return extEntityTypes;
	}
}

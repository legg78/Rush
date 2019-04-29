package ru.bpc.sv2.ui.issuing;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.AccountType;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CommonHierarchyObject;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.faces.model.SelectItem;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbIssuingHierarchySearch")
public class MbIssuingHierarchySearch extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	// Filters
	private Account accountFilter;
	private Card cardFilter;
	private Customer customerFilter;
	private Contract contractFilter;

	private String selectedFilter;
	private String searchTabName;
	private Map <String, Object> paramMap;

	private static final Logger logger = Logger.getLogger("ISSUING");

	private AccountsDao _accountsDao = new AccountsDao();

	private IssuingDao _issuingDao = new IssuingDao();

	private NetworkDao _networkDao = new NetworkDao();

	private ProductsDao _productsDao = new ProductsDao();

	private CurrencyUtils currencyUtils;

	private List<SelectItem> institutions;
	private ArrayList<SelectItem> cardTypes;
	private List<SelectItem> genders;
	private List<SelectItem> extEntityTypes;
	
	private final DaoDataModel<CommonHierarchyObject> _issObjsSource;
	private final TableRowSelection<CommonHierarchyObject> _itemSelection;
	private CommonHierarchyObject _activeIssObj;

	private UserSession userSession;
	
	public MbIssuingHierarchySearch() {
		pageLink = "issuing|hierarchy";
		searchTabName = "customerTab";
		
		currencyUtils = (CurrencyUtils) ManagedBeanWrapper.getManagedBean("CurrencyUtils");
		userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		
		setDefaultValues();
		
		_issObjsSource = new DaoDataModel<CommonHierarchyObject>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected CommonHierarchyObject[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CommonHierarchyObject[0];
				}

				CommonHierarchyObject[] issObjs = null;

				try {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					if (EntityNames.ACCOUNT.equals(selectedFilter)) {
						issObjs = getAccounts(params);
					} else if (EntityNames.CARD.equals(selectedFilter)) {
						issObjs = getCards(params);
					} else if (EntityNames.CONTRACT.equals(selectedFilter)) {
						issObjs = getContracts(params);
					} else if (isCustomersSearch()) {
						issObjs = getCustomers(params, tabNameParam);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}

				if (issObjs == null) {
					issObjs = new CommonHierarchyObject[0];
				}
				return issObjs;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					String tabNameParam = setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					if (EntityNames.ACCOUNT.equals(selectedFilter)) {
						return _accountsDao.getAccountsCountCur(userSessionId, paramMap);
					} else if (EntityNames.CARD.equals(selectedFilter)) {
						return _issuingDao.getCardsCurCount(userSessionId, params, paramMap);
					} else if (EntityNames.CONTRACT.equals(selectedFilter)) {
						return _productsDao.getContractsCurCount(userSessionId, params, paramMap);
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

		_itemSelection = new TableRowSelection<CommonHierarchyObject>(null, _issObjsSource);
	}

	public DaoDataModel<CommonHierarchyObject> getIssObjs() {
		return _issObjsSource;
	}

	public CommonHierarchyObject getActiveIssObj() {
		return _activeIssObj;
	}

	public void setActiveIssObj(CommonHierarchyObject activeIssObj) {
		_activeIssObj = activeIssObj;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeIssObj = _itemSelection.getSingleSelection();
	}

	private CommonHierarchyObject[] getCards(SelectionParams params) throws Exception {
		CommonHierarchyObject[] issObjs;
		Card[] cards = _issuingDao.getCardsCur(userSessionId, params, paramMap);
		issObjs = new CommonHierarchyObject[cards.length];
		int i = 0;
		for (Card card : cards) {
			issObjs[i] = new CommonHierarchyObject();
			issObjs[i].setId(card.getId());
			issObjs[i].setName(card.getCardholderName() + " " + card.getMask());
			issObjs[i].setEntityType(EntityNames.CARD);
			i++;
		}
		return issObjs;
	}

	private CommonHierarchyObject[] getAccounts(SelectionParams params) throws Exception {
		CommonHierarchyObject[] issObjs;

		// This can be used only when acq_ui_account_vw is corrected
		// Account[] accounts = _accountsDao.getIssAccounts(userSessionId, params);

		// This can be used any time as long as there is "productType" filter
		// (set to issuing products code) among filters
		Account[] accounts = _accountsDao.getAccountsCur(userSessionId, params, paramMap);

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

		params.setRowIndexEnd(Integer.MAX_VALUE);

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
//			if ("".equals(customerName)) {
//				customerName = "UNKNOWN CUSTOMER";
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
		} else if (clientId.contains("card")) {
			syncInstId = cardFilter.getInstId();
		} else if (clientId.contains("account")) {
			syncInstId = accountFilter.getInstId();
		} else{
			syncInstId = customerFilter.getInstId();
		}
		if (syncInstId != null) {
			getContractFilter().setInstId(syncInstId);
			getAccountFilter().setInstId(syncInstId);
			getCardFilter().setInstId(syncInstId);
			getCustomerFilter().setInstId(syncInstId);
		}
	}
	
	public void searchByPerson() {
		selectedFilter = EntityNames.PERSON;
		search();
	}

	public void searchByCompany() {
		selectedFilter = EntityNames.COMPANY;
		search();
	}

	public void searchByCard() {
		selectedFilter = EntityNames.CARD;
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

	public void search() {
		// setFilters();
		searching = true;

		// search using new criteria
		_issObjsSource.flushCache();

		// reset selection
		if (_activeIssObj != null) {
			_itemSelection.unselect(_activeIssObj);
			_activeIssObj = null;
		}
	}

	public void clearFilter() {
		curLang = userLang;
		
		accountFilter = null;
		cardFilter = null;
		customerFilter = null;
		contractFilter = null;
		
		selectedFilter = "";
		searching = false;

		setDefaultValues();
		
		MbIssuingHierarchy issHier = (MbIssuingHierarchy) ManagedBeanWrapper
				.getManagedBean("MbIssuingHierarchy");
		issHier.clearFilter();
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
		getCardFilter().setInstId(defaultInstId);
		getCardFilter().setAgentId(defaultAgentId);
		getAccountFilter().setInstId(defaultInstId);
		getAccountFilter().setAgentId(defaultAgentId);
		if (userSession.getInRole().get(SystemConstants.VIEW_ALL_CUSTOMERS_PRIVILEGE)) {
			getCustomerFilter().setCustomerNumber("*");
			getCustomerFilter().getPerson().setSurname("*");
			getCustomerFilter().getPerson().setFirstName("*");
			getCustomerFilter().getCompany().setLabel("*");
			getContractFilter().setContractNumber("*");
			getCardFilter().setCardNumber("*");
			getCardFilter().setCardUid("");
			getAccountFilter().setAccountNumber("*");
		}
	}

	private String setFilters() {
		filters = new ArrayList<Filter>();

		if (EntityNames.ACCOUNT.equals(selectedFilter)) {
			setAccountFilters();
			return "ACCOUNT";
		} else if (EntityNames.CARD.equals(selectedFilter)) {
			setCardFilters();
			return "CARD";
		} else if (EntityNames.CONTRACT.equals(selectedFilter)) {
			setContractFilters();
			return "CONTRACT";
		} else if (EntityNames.CUSTOMER.equals(selectedFilter)) {
			setCustomerFilters();
			return "CUSTOMER";
		} else if (EntityNames.PERSON.equals(selectedFilter)) {
			setPersonFilters();
			return "PERSON";
		} else if (EntityNames.COMPANY.equals(selectedFilter)) {
			setCompanyFilters();
			return "COMPANY";
		} else {
			return null;
		}
	}

	private boolean isCustomersSearch() {
		return EntityNames.CUSTOMER.equals(selectedFilter) || EntityNames.PERSON.equals(selectedFilter)
				|| EntityNames.COMPANY.equals(selectedFilter);
	}
	
	private void setAccountFilters() {
		getAccountFilter();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		// to get only those accounts that refer to issuing entities
		filters.add(new Filter("PARTICIPANT_MODE", "ISS"));

		if (accountFilter.getAccountNumber() != null && accountFilter.getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setValue(accountFilter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (accountFilter.getInstId() != null && !accountFilter.getInstId().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(accountFilter.getInstId());
			filters.add(paramFilter);
		}
		if (accountFilter.getAgentId() != null) {
			filters.add(new Filter("AGENT_ID", accountFilter.getAgentId()));
		}
		if (accountFilter.getAccountType() != null && !accountFilter.getAccountType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_TYPE");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(accountFilter.getAccountType());
			filters.add(paramFilter);
		}
		if (accountFilter.getStatus() != null && !accountFilter.getStatus().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(accountFilter.getStatus());
			filters.add(paramFilter);
		}
		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMap().put("tab_name", "ACCOUNT");
	}

	private void setCardFilters() {
		getCardFilter();
		paramMap = new HashMap<String, Object>();
		Filter paramFilter = new Filter();
		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (cardFilter.getCardNumber() != null && cardFilter.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_NUMBER");
			paramFilter.setCondition("=");
			paramFilter.setValue(cardFilter.getCardNumber().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || cardFilter.getCardNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}

		if (cardFilter.getCardUid() != null && cardFilter.getCardUid().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_UID");
			paramFilter.setCondition("=");
			paramFilter.setValue(cardFilter.getCardUid().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || cardFilter.getCardUid().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}

		if (cardFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(cardFilter.getInstId());
			filters.add(paramFilter);
		}

		if (cardFilter.getAgentId() != null) {
			filters.add(new Filter("AGENT_ID", cardFilter.getAgentId()));
		}

		if (cardFilter.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_TYPE_ID");
			paramFilter.setValue(cardFilter.getCardTypeId());
			filters.add(paramFilter);
		}

		if (cardFilter.getCardholderName() != null && cardFilter.getCardholderName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARDHOLDER_NAME");
			paramFilter.setValue(cardFilter.getCardholderName());
			filters.add(paramFilter);
		}
		
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (cardFilter.getExpDate() != null){
			paramFilter = new Filter();
			paramFilter.setElement("EXPIR_DATE");
			paramFilter.setValue(cardFilter.getExpDate());
			filters.add(paramFilter);
		}
		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
		paramMap.put("tab_name", "CARD");
	}

	private void setContractFilters() {
		getContractFilter();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		// to get only those contracts that refer to issuing entities
		paramFilter = new Filter();
		paramFilter.setElement("PRODUCT_TYPE");
		paramFilter.setValue(ProductConstants.ISSUING_PRODUCT);
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
		if (contractFilter.getAgentId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("AGENT_ID");
			paramFilter.setValue(contractFilter.getAgentId());
			filters.add(paramFilter);
		}
		if (contractFilter.getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setValue(contractFilter.getCustomerId().toString());
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
		if (contractFilter.getStartDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("START_DATE_FROM");
			paramFilter.setValue(contractFilter.getStartDate());
			filters.add(paramFilter);
		}
		if (contractFilter.getEndDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("START_DATE_TO");
			paramFilter.setValue(contractFilter.getEndDate());
			filters.add(paramFilter);
		}

		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
		getParamMap().put("tab_name", "CONTRACT");
	}

	private void setCustomerFilters() {
		getCustomerFilter();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		paramFilter = new Filter("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
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

	public void setPersonFilters() {
		getCustomerFilter();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		paramFilter = new Filter("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		filters.add(paramFilter);

		if (customerFilter.getInstId() != null) {
			paramFilter = new Filter("INST_ID", customerFilter.getInstId());
			filters.add(paramFilter);
		}
		if (customerFilter.getAgentId() != null) {
			paramFilter = new Filter("AGENT_ID", customerFilter.getAgentId());
			filters.add(paramFilter);
		}

		if (customerFilter.getPerson().getFirstName() != null &&
				customerFilter.getPerson().getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("FIRST_NAME");
			paramFilter.setValue(customerFilter.getPerson().getFirstName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (customerFilter.getPerson().getSurname() != null &&
				customerFilter.getPerson().getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("SURNAME");
			paramFilter.setValue(customerFilter.getPerson().getSurname().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (customerFilter.getPerson().getSecondName() != null &&
				customerFilter.getPerson().getSecondName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("SECOND_NAME");
			paramFilter.setValue(customerFilter.getPerson().getSecondName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (customerFilter.getPerson().getGender() != null &&
				customerFilter.getPerson().getGender().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("GENDER");
			paramFilter.setValue(customerFilter.getPerson().getGender().trim().toUpperCase());
			filters.add(paramFilter);
		}

		if (customerFilter.getPerson().getBirthday() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("BIRTHDAY");
			paramFilter.setValue(customerFilter.getPerson().getBirthday());
			filters.add(paramFilter);
		}
	}
	
	private void setCompanyFilters() {
		getCustomerFilter();

		Filter paramFilter = new Filter("LANG", userLang);
		filters.add(paramFilter);

		paramFilter = new Filter("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
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

	public Card getCardFilter() {
		if (cardFilter == null) {
			cardFilter = new Card();
		}
		return cardFilter;
	}

	public void setCardFilter(Card cardFilter) {
		this.cardFilter = cardFilter;
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

	public Contract getContractFilter() {
		if (contractFilter == null) {
			contractFilter = new Contract();
		}
		return contractFilter;
	}

	public void setContractFilter(Contract contractFilter) {
		this.contractFilter = contractFilter;
	}

	public void resetBean() {
	}

	public void cancel() {

	}

	public void select() {
		MbIssuingHierarchy issHier = (MbIssuingHierarchy) ManagedBeanWrapper
				.getManagedBean("MbIssuingHierarchy");
		issHier.setObjectId(_activeIssObj.getId());
		issHier.setObjectType(_activeIssObj.getEntityType());
		issHier.setObjectName(_activeIssObj.getName());
		issHier.search();
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

	public List<SelectItem> getCardAgents() {
		if (getCardFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getCardFilter().getInstId());
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

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}

	public ArrayList<SelectItem> getCardTypes() {
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

	public Map <String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map <String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	public String getHeaderText() {
	    String key = null;

        if (EntityNames.CUSTOMER.equals(selectedFilter)) {
            key = "select_customer";
        } else if (EntityNames.PERSON.equals(selectedFilter)) {
            key = "select_person";
        } else if (EntityNames.COMPANY.equals(selectedFilter)) {
            key = "select_company";
        } else if (EntityNames.CONTRACT.equals(selectedFilter)) {
            key = "select_contract";
        } else if (EntityNames.CARD.equals(selectedFilter)) {
            key = "select_card";
        } else if (EntityNames.ACCOUNT.equals(selectedFilter)) {
            key = "select_account";
        } else {
            key = "select_object";
        }

        return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Form", key);
    }
}

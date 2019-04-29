package ru.bpc.sv2.ui.acquiring;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.common.Company;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.CommonHierarchyObject;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.accounts.MbAccountsAllSearch;
import ru.bpc.sv2.ui.orgstruct.MbAgent;
import ru.bpc.sv2.ui.orgstruct.MbInstitution;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbContracts;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.CurrencyUtils;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbAcquiringHierarchy")
public class MbAcquiringHierarchy extends AbstractBean implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private final String ERROR_PREFIX = "An error occurred while building hierarchy: ";

	private AccountsDao _accountsDao = new AccountsDao();

	private CommonDao _commonDao = new CommonDao();

	private OrgStructDao _orgStructDao = new OrgStructDao();

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private ProductsDao _productsDao = new ProductsDao();

	private CommonHierarchyObject currentNode;

	private ArrayList<CommonHierarchyObject> coreObjects;
	private boolean treeLoaded;
	private TreePath nodePath;
	private Long objectId;
	private String objectType;
	private String objectName;

	private String curLang;
	private String userLang;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> commonIssuingObjectTypes;
	private ArrayList<SelectItem> commonIssuingObjectGroups;
	private ArrayList<SelectItem> lovs;
	private boolean searching;
	private boolean showAttributes;
	private transient DictUtils dictUtils; 
	
	private CurrencyUtils currencyUtils;

	private Long userSessionId = null;

	private boolean fromCustomer;

	private List<String> errorMessages;
	
	private String tabName;
	private ArrayList<SelectItem> dataTypes;

	public MbAcquiringHierarchy() {
		pageLink = "acquiring|hierarchy";
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = userLang = SessionWrapper.getField("language");
		currencyUtils = (CurrencyUtils) ManagedBeanWrapper.getManagedBean("CurrencyUtils");
		showAttributes = false;
	}

	public CommonHierarchyObject getNode() {
		if (currentNode == null) {
			currentNode = new CommonHierarchyObject();
		}
		return currentNode;
	}

	public void setNode(CommonHierarchyObject node) {
		if (node == null)
			return;

		this.currentNode = node;
		if (!fromCustomer) {
			setBeans();
			storeParams();
		}
	}

	/**
	 * Saves parameters in session to restore it when needed
	 */
	public void storeParams() {

	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private CommonHierarchyObject getCommonIssObj() {
		return (CommonHierarchyObject) Faces.var("acqObject");
	}

	private void loadTree() {
		if (searching) {
			coreObjects = new ArrayList<CommonHierarchyObject>();
			errorMessages = new ArrayList<String>();

			if (EntityNames.TERMINAL.equals(objectType)) {
				buildTreeByTerminal();
			} else if (EntityNames.MERCHANT.equals(objectType)) {
				buildTreeByMerchant();
			} else if (EntityNames.ACCOUNT.equals(objectType)) {
				buildTreeByAccount();
			} else if (EntityNames.CONTRACT.equals(objectType)) {
				buildTreeByContract();
			} else if (EntityNames.CUSTOMER.equals(objectType)) {
				buildTreeByCustomer();
			}

			treeLoaded = true;
		}
	}

	private void buildTreeByTerminal() {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("TERMINAL_ID");
			filters[0].setValue(objectId);
			filters[1] = new Filter();
			filters[1].setElement("LANG");
			filters[1].setValue(curLang);
			params.setFilters(filters);

			Map<String, Object> paramsMap = new HashMap<String, Object>();
			paramsMap.put("param_tab", filters);
			paramsMap.put("tab_name", "CONTRACT");

			Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);

			if (contracts != null && contracts.length > 0) {
				// change filters to get customer
				filters[0].setElement("id");
				filters[0].setValue(contracts[0].getCustomerId());

				// Customer is the third level of hierarchy 
				List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
				if (customers != null && !customers.isEmpty()) {
					buildTree(customers.get(0), contracts[0]);
				}
			} else {
				throw new Exception(ERROR_PREFIX + "no contracts were found for terminal \""
						+ objectName + "\"");
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void buildTreeByMerchant() {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("MERCHANT_ID");
			filters[0].setValue(objectId);
			filters[1] = new Filter();
			filters[1].setElement("LANG");
			filters[1].setValue(curLang);
			params.setFilters(filters);

			Map<String, Object> paramsMap = new HashMap<String, Object>();
			paramsMap.put("param_tab", filters);
			paramsMap.put("tab_name", "CONTRACT");

			Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);

			if (contracts != null && contracts.length > 0) {
				// change filters to get customer
				filters[0].setElement("id");
				filters[0].setValue(contracts[0].getCustomerId());

				// Customer is the third level of hierarchy 
				List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
				if (customers != null && !customers.isEmpty()) {
					buildTree(customers.get(0), contracts[0]);
				}
			} else {
				throw new Exception(ERROR_PREFIX + "no contracts were found for merchant \""
						+ objectName + "\"");
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void buildTreeByAccount() {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("ACCOUNT_ID");
			filters[0].setValue(objectId);
			filters[1] = new Filter();
			filters[1].setElement("LANG");
			filters[1].setValue(curLang);
			params.setFilters(filters);

			Map<String, Object> paramsMap = new HashMap<String, Object>();
			paramsMap.put("param_tab", filters);
			paramsMap.put("tab_name", "CONTRACT");

			Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);

			if (contracts != null && contracts.length > 0) {
				// change filters to get customer
				filters[0].setElement("id");
				filters[0].setValue(contracts[0].getCustomerId());

				// Customer is the third level of hierarchy 
				List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
				if (customers != null && !customers.isEmpty()) {
					buildTree(customers.get(0), contracts[0]);
				}
			} else {
				throw new Exception(ERROR_PREFIX + "no contracts were found for account \""
						+ objectName + "\"");
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void buildTreeByContract() {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("CONTRACT_ID");
			filters[0].setValue(objectId);
			filters[1] = new Filter();
			filters[1].setElement("LANG");
			filters[1].setValue(curLang);
			params.setFilters(filters);

			Map<String, Object> paramsMap = new HashMap<String, Object>();
			paramsMap.put("param_tab", filters);
			paramsMap.put("tab_name", "CONTRACT");

			Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);

			if (contracts != null && contracts.length > 0) {
				// change filters to get customer
				filters[0].setElement("id");
				filters[0].setValue(contracts[0].getCustomerId());

				// Customer is the third level of hierarchy 
				List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
				if (customers != null && !customers.isEmpty()) {
					buildTree(customers.get(0), contracts[0]);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void buildTreeByCustomer() {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(objectId);
			params.setFilters(filters);

			List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
			if (customers != null && !customers.isEmpty()) {
				buildTree(customers.get(0), null);
			} else {
				throw new Exception(ERROR_PREFIX + "no contracts were found for customer \"" + objectName + "\"");
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	// TODO: to be implemented... if needed
	@SuppressWarnings("unused")
	private void buildReverseTree(Customer customer, Contract contract) throws Exception {
		// Agents are the 2-nd level
		List<Agent> agents;
		if (contract != null) {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(contract.getAgentId());
			params.setFilters(filters);

			Agent[] agentsArray = _orgStructDao.getAgentsList(userSessionId, params);
			agents = new ArrayList<Agent>(agentsArray.length);
			for (Agent agent : agentsArray) {
				agents.add(agent);
			}
		} else {
			agents = getAgentsByCustomer(customer.getId());
		}

		if (agents.size() == 0) {
			throw new Exception(ERROR_PREFIX + "no agents were found for customer \""
					+ customer.getName() + "\"."); // TODO: i18n
		}
		// Get institution which is the 1-st level of final hierarchy.
		Institution inst = getInstitution(agents);

		// Contracts are the 4-th level
		List<Contract> contracts;
		if (contract == null) {
			// if tree is built by customer (the only case when contract is null)
			// find all contracts for this customer
			contracts = getContractsByCustomer(customer.getId());
		} else {
			contracts = new ArrayList<Contract>(1);
			contracts.add(contract);
		}

		// Accounts are the 5-th level of hierarchy 
		List<Account> contractAccounts = getAccountsByObject(EntityNames.CONTRACT, contracts.get(0)
				.getId());

		// Merchants are the 5-th (along with accounts) and the 6-th level of hierarchy
		Merchant[] merchants = getMerchantsByContract(contract.getId());

		// Tie terminals to merchants 
		ArrayList<CommonHierarchyObject> merchantObjects = new ArrayList<CommonHierarchyObject>();
		for (Merchant merchant : merchants) {
			CommonHierarchyObject merchantObj = new CommonHierarchyObject();
			merchantObj.setId(merchant.getId().longValue());
			merchantObj.setName(merchant.getLabel());
			merchantObj.setEntityType(EntityNames.MERCHANT);
			merchantObj.setObject(merchant);

			// Terminals are descendants of merchants (6-th (7-th) level of hierarchy)
			Terminal[] terminals = getTerminals(merchant.getId().intValue());
			merchantObj.setChildren(new ArrayList<CommonHierarchyObject>(terminals.length));
			for (Terminal terminal : terminals) {
				CommonHierarchyObject terminalObj = new CommonHierarchyObject();
				terminalObj.setId(terminal.getId().longValue());
				terminalObj.setParentId(terminal.getMerchantId().longValue());
				terminalObj.setName(terminal.getDescription());
				terminalObj.setEntityType(EntityNames.TERMINAL);
				terminalObj.setObject(terminal);

				merchantObj.getChildren().add(terminalObj);
			}
			merchantObjects.add(merchantObj);
		}

	}

	private String getCustomerName(Customer customer) {
		String customerName = "";

		if (EntityNames.PERSON.equals(customer.getEntityType())) {
			if (customer.getPerson().getPersonId() == null) {
				Person person = _commonDao.getPersonById(userSessionId, customer.getObjectId(),
						curLang);
				customer.setPerson(person);
			}
			customerName = customer.getPerson().getFirstName()
					+ " "
					+ (customer.getPerson().getSecondName() == null ? "" : (customer.getPerson()
							.getSecondName() + " "))
					+ (customer.getPerson().getSurname() == null ? "" : customer.getPerson()
							.getSurname());
		} else if (EntityNames.COMPANY.equals(customer.getEntityType())) {
			if (customer.getCompany() == null) {
				SelectionParams params = new SelectionParams();
				Filter[] filters = new Filter[1];
				filters[0].setElement("id");
				filters[0].setValue(customer.getId());
				params.setFilters(filters);

				Company[] companies = _commonDao.getCompanies(userSessionId, params);
				if (companies.length > 0) {
					customer.setCompany(companies[0]);
				}
			}
			customerName = customer.getCompany().getLabel();
		}
		if ("".equals(customerName)) {
			customerName = "UNKNOWN CUSTOMER";
		}

		return customerName;
	}

	private List<Account> getAccountsByObject(String objectType, Long objectId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("LANG");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("OBJECT_ID");
		filters[1].setValue(objectId);
		filters[2] = new Filter();
		filters[2].setElement("ENTITY_TYPE");
		filters[2].setValue(objectType);

		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		Map<String, Object>paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "ACCOUNT");

		Account[] objectAccounts = _accountsDao.getAccountsCur(userSessionId, params, paramsMap);
		List<Account> result = new ArrayList<Account>(objectAccounts.length);
		for (Account acc : objectAccounts) {
			result.add(acc);
		}
		return result;
	}

	private List<Contract> getContractsByCustomer(Long customerId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("LANG");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("CUSTOMER_ID");
		filters[1].setValue(customerId);
		filters[2] = new Filter();
		filters[2].setElement("PRODUCT_TYPE");
		filters[2].setValue(ProductConstants.ACQUIRING_PRODUCT);

		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);

		Map<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "CONTRACT");

		Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);

		List<Contract> result = new ArrayList<Contract>(contracts.length);
		for (Contract contract : contracts) {
			result.add(contract);
		}

		return result;
	}

	private List<Agent> getAgentsByCustomer(Long customerId) throws Exception {
		List<Agent> agents = _orgStructDao.getAgentsByCustomer(userSessionId, customerId);
		return agents;
	}

	private Merchant[] getMerchantsByContract(Long contractId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("LANG");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("CONTRACT_ID");
		filters[1].setValue(contractId);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		Map <String, Object> paramsMap = new HashMap<String, Object>(); 
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "CONTRACT");
		
		return _acquiringDao.getMerchantsCur(userSessionId, params, paramsMap);
	}

	private Account[] getAccountsByContract(Long contractId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("LANG");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("CONTRACT_ID");
		filters[1].setValue(contractId);

		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		Map<String, Object>paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "ACCOUNT");

		return _accountsDao.getAccountsCur(userSessionId, params, paramsMap);
	}

	private Terminal[] getTerminals(Integer merchantId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("LANG");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("MERCHANT_ID");
		filters[1].setValue(merchantId);
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		HashMap<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "MERCHANT");

		return _acquiringDao.getTerminalsCur(userSessionId, params, paramsMap);
	}

	private Terminal[] getTerminalsByAccount(Long accountId) {
		List<Filter> filters = new ArrayList<Filter>(2);
		filters.add(Filter.create("LANG", curLang));
		filters.add(Filter.create("ACCOUNT_ID", accountId));
		SelectionParams params = new SelectionParams(filters);
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		HashMap<String, Object> paramsMap = new HashMap<String, Object>();
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "ACCOUNT");

		return _acquiringDao.getTerminalsCur(userSessionId, params, paramsMap);
	}

	private Institution getInstitution(List<Agent> agents) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("ids");
		String ids = "";
		for (Agent agent : agents) {
			// instId is always 4 digit number, so there can't be any accidental coincidences 
			if (!ids.contains(String.valueOf(agent.getInstId()))) {
				ids += agent.getInstId() + ", ";
			}
		}
		filters[1].setValue(ids.substring(0, ids.lastIndexOf(',')));
		params.setFilters(filters);

		return _orgStructDao.getInstitutions(userSessionId, params, curLang, false)[0];
	}

	public ArrayList<CommonHierarchyObject> getNodeChildren() {
		if (!searching) {
			return new ArrayList<CommonHierarchyObject>(0);
		}
		CommonHierarchyObject prod = getCommonIssObj();
		if (prod == null) {
			if (!treeLoaded || coreObjects == null) {
				loadTree();
			}
			return coreObjects;
		} else {
			return prod.getChildren();
		}
	}

	private void setBeans() {
		showAttributes = false;
		if (EntityNames.INSTITUTION.equals(currentNode.getEntityType())) {
			MbInstitution instBean = (MbInstitution) ManagedBeanWrapper
					.getManagedBean("MbInstitution");
			instBean.setCurLang(curLang);
			instBean.setNode((Institution) currentNode.getObject());
		} else if (EntityNames.AGENT.equals(currentNode.getEntityType())) {
			MbAgent agentsBean = (MbAgent) ManagedBeanWrapper.getManagedBean("MbAgent");
			agentsBean.setCurLang(curLang);
			agentsBean.setNode((Agent) currentNode.getObject());
		} else if (EntityNames.CUSTOMER.equals(currentNode.getEntityType()) && !fromCustomer) {
			MbCustomersDependent custBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependent");
			custBean.setCurLang(curLang);
			custBean.setActiveCustomer((Customer) currentNode.getObject());

			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			Customer object = (Customer) currentNode.getObject();
			attrs.setObjectId(object.getId());
			attrs.setProductId(object.getProductId());
			attrs.setEntityType(EntityNames.CUSTOMER);
			attrs.setInstId(object.getInstId());
			attrs.setProductType(object.getProductType());
			showAttributes = true;
		} else if (EntityNames.CONTRACT.equals(currentNode.getEntityType())) {
			MbContracts contractsBean = (MbContracts) ManagedBeanWrapper
					.getManagedBean("MbContracts");
			contractsBean.setCurLang(curLang);
			contractsBean.setActiveContract((Contract) currentNode.getObject());

			// for contract show product's attributes (see SVTWO-5683)
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			Contract object = (Contract) currentNode.getObject();
			attrs.setProductId(object.getProductId());
			attrs.setEntityType(EntityNames.PRODUCT);
			attrs.setProductType(ProductConstants.ACQUIRING_PRODUCT);
			attrs.setInstId(object.getInstId());
			attrs.setProductType(object.getProductType());
			showAttributes = true;
		} else if (EntityNames.ACCOUNT.equals(currentNode.getEntityType())) {
			MbAccountsAllSearch accBean = (MbAccountsAllSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsAllSearch");
			accBean.setCurLang(curLang);
			accBean.setActiveAccount((Account) currentNode.getObject());

			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			Account object = (Account) currentNode.getObject();
			attrs.setObjectId(object.getId());
			attrs.setProductId(object.getProductId());
			attrs.setEntityType(EntityNames.ACCOUNT);
			attrs.setInstId(object.getInstId());
			attrs.setProductType(object.getProductType());
			showAttributes = true;
		} else if (EntityNames.MERCHANT.equals(currentNode.getEntityType())) {
			MbMerchant merchantsBean = (MbMerchant) ManagedBeanWrapper.getManagedBean("MbMerchant");
			merchantsBean.setCurLang(curLang);
			merchantsBean.setNode((Merchant) currentNode.getObject());

			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			Merchant object = (Merchant) currentNode.getObject();
			attrs.setObjectId(object.getId().longValue());
			attrs.setProductId(object.getProductId());
			attrs.setEntityType(EntityNames.MERCHANT);
			attrs.setInstId(object.getInstId());
			attrs.setProductType(object.getProductType());
			showAttributes = true;
		} else if (EntityNames.TERMINAL.equals(currentNode.getEntityType())) {
			MbTerminal terminalsBean = (MbTerminal) ManagedBeanWrapper.getManagedBean("MbTerminal");
			terminalsBean.setCurLang(curLang);
			terminalsBean.setActiveTerminal((Terminal) currentNode.getObject());

			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			Terminal object = (Terminal) currentNode.getObject();
			attrs.setObjectId(object.getId().longValue());
			attrs.setProductId(object.getProductId());
			attrs.setEntityType(EntityNames.TERMINAL);
			attrs.setInstId(object.getInstId());
			attrs.setProductType(object.getProductType());
			showAttributes = true;
		}
	}

	public boolean getNodeHasChildren() {
		return (getCommonIssObj() != null) && getCommonIssObj().hasChildren();
	}

	public void search() {
		clearBean();

		searching = true;
		loadTree();
	}

	public void clearFilter() {
		clearBean();
		searching = false;
	}

	private void clearBeansStates() {
		MbInstitution instBean = (MbInstitution) ManagedBeanWrapper.getManagedBean("MbInstitution");
		instBean.setNode(null);
		MbAgent agentsBean = (MbAgent) ManagedBeanWrapper.getManagedBean("MbAgent");
		agentsBean.setNode(null);
		if (!fromCustomer) {
			MbCustomersDependent custBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependent");
			custBean.setActiveCustomer(null);
		}
		MbContracts contractsBean = (MbContracts) ManagedBeanWrapper.getManagedBean("MbContracts");
		contractsBean.setActiveContract(null);
		MbMerchant merchantBean = (MbMerchant) ManagedBeanWrapper.getManagedBean("MbMerchant");
		merchantBean.setNode(null);
		MbTerminal terminalsBean = (MbTerminal) ManagedBeanWrapper.getManagedBean("MbTerminal");
		terminalsBean.setActiveTerminal(null);
		MbAccountsAllSearch accBean = (MbAccountsAllSearch) ManagedBeanWrapper
				.getManagedBean("MbAccountsAllSearch");
		accBean.setActiveAccount(null);
	}

	public void cancel() {

	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreObjects = null;
		treeLoaded = false;
		curLang = userLang;
		if (!fromCustomer) {
			clearBeansStates();
		}
	}

	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public List<SelectItem> getLovs() {
		if(lovs ==null){
			lovs = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.LOVS_LOV);
		}
		if(lovs ==null){
			lovs = new ArrayList<SelectItem>();
		}
		return lovs;
	}

	public List<SelectItem> getCommonIssuingObjectTypes() {
		if(commonIssuingObjectTypes == null){
			commonIssuingObjectTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ATTRIBUTE_TYPES);
		}
		if(commonIssuingObjectTypes == null){
			commonIssuingObjectTypes = new ArrayList<SelectItem>();
		}
		return commonIssuingObjectTypes;
	}

	public List<SelectItem> getCommonIssuingObjectGroups() {
		if(commonIssuingObjectGroups == null){
			commonIssuingObjectGroups = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.ATTRIBUTE_GROUPS);
		}
		if(commonIssuingObjectGroups == null){
			commonIssuingObjectGroups = new ArrayList<SelectItem>();
		}
		return commonIssuingObjectGroups;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getObjectType() {
		return objectType;
	}

	public void setObjectType(String objectType) {
		this.objectType = objectType;
	}

	public String getObjectName() {
		return objectName;
	}

	public void setObjectName(String objectName) {
		this.objectName = objectName;
	}

	public boolean isInstNode() {
		return currentNode == null ? false : EntityNames.INSTITUTION.equals(currentNode
				.getEntityType());
	}

	public boolean isAgentNode() {
		return currentNode == null ? false : EntityNames.AGENT.equals(currentNode.getEntityType());
	}

	public boolean isCustomerNode() {
		return currentNode == null ? false : EntityNames.CUSTOMER.equals(currentNode
				.getEntityType());
	}

	public boolean isContractNode() {
		return currentNode == null ? false : EntityNames.CONTRACT.equals(currentNode
				.getEntityType());
	}

	public boolean isAccountNode() {
		return currentNode == null ? false : EntityNames.ACCOUNT
				.equals(currentNode.getEntityType());
	}

	public boolean isMerchantNode() {
		return currentNode == null ? false : EntityNames.MERCHANT.equals(currentNode
				.getEntityType());
	}

	public boolean isTerminalNode() {
		return currentNode == null ? false : EntityNames.TERMINAL.equals(currentNode
				.getEntityType());
	}

	public boolean isShowAttributes() {
		return showAttributes;
	}

	private static Boolean buildMerchantTree(CommonHierarchyObject merchant,
											 ArrayList<CommonHierarchyObject> objects,
											 Boolean onlyCheck) {
		if (objects != null) {
			for (CommonHierarchyObject obj : objects) {
				if (onlyCheck == Boolean.TRUE) {
					if (obj.getId().equals(merchant.getId()) == Boolean.TRUE) {
						return Boolean.TRUE;
					}
				} else {
					if (obj.getId().equals(merchant.getParentId()) == Boolean.TRUE) {
						if (obj.getChildren() == null) {
							obj.setChildren(new ArrayList<CommonHierarchyObject>());
						}
						obj.getChildren().add(merchant);
						return Boolean.TRUE;
					}
				}
				if (buildMerchantTree(merchant, obj.getChildren(), onlyCheck) == Boolean.TRUE) {
					return Boolean.TRUE;
				}
			}
		}
		return Boolean.FALSE;
	}

	private void buildTree(Customer customer, Contract contract) throws Exception {
		// Find agents. Agents are the 2-nd level
		List<Agent> agents;
		if (contract != null) {
			// if contract is defined we can find agent by its ID
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(contract.getAgentId());
			params.setFilters(filters);

			// actually it's only one agent as it can be seen from upper conditions
			Agent[] agentsArray = _orgStructDao.getAgentsList(userSessionId, params);
			agents = new ArrayList<Agent>(agentsArray.length);
			for (Agent agent : agentsArray) {
				agents.add(agent);
			}
		} else {
			// if contract is not defined find all possible agents by customer id. 
			agents = getAgentsByCustomer(customer.getId());
		}

		if (agents.size() == 0) {
			throw new Exception(ERROR_PREFIX + "no agents were found for customer \""
					+ customer.getName() + "\"."); // TODO: i18n
		}

		// Get institution which is the first level of final hierarchy.
		Institution inst = getInstitution(agents);

		int uniqueIndex = 1;
		ArrayList<CommonHierarchyObject> agentObjects = new ArrayList<CommonHierarchyObject>();

		// Create first level of hierarchy (institution). 
		CommonHierarchyObject instObj = new CommonHierarchyObject();
		instObj.setId(inst.getId().longValue());
		instObj.setName(inst.getName());
		instObj.setEntityType(EntityNames.INSTITUTION);
		instObj.setObject(inst);
		instObj.setUniqueIndex(uniqueIndex++);
		instObj.setChildren(new ArrayList<CommonHierarchyObject>());
		coreObjects.add(instObj);

		// Contracts are the 4-th level. They're common for both ways of building tree.
		List<Contract> contracts;
		List<CommonHierarchyObject> contractObjects;

		// Contracts may belong to one customer but to different agents.
		if (contract == null) {
			// if tree is built by customer (the only case when contract is null)
			// find all contracts for this customer
			contracts = getContractsByCustomer(customer.getId());
		} else {
			// contract is defined, so we don't have to do anything but adding it to list
			contracts = new ArrayList<Contract>(1);
			contracts.add(contract);
		}

		// When hierarchy is called from "Customers" form it's better to show customer
		// directly after institution, so that if this customer belongs to several agents
		// we don't have to show 2, 3 or more same customers when only one is needed. 
		if (fromCustomer) {
			CommonHierarchyObject customerObj = addCustomerToInst(customer, instObj, uniqueIndex);
			agentObjects = addAgentsToCustomer(agents, customerObj, uniqueIndex);

			contractObjects = addContractsToAgents(contracts, agentObjects, uniqueIndex);
		} else {
			agentObjects = addAgentsToInst(agents, instObj, uniqueIndex);
			addCustomerToAgents(customer, agentObjects, uniqueIndex);

			contractObjects = addContractsToCustomer(contracts, agentObjects, uniqueIndex);
		}

		// Accounts are the 5-th level of hierarchy
		ArrayList<CommonHierarchyObject> accountObjects = new ArrayList<CommonHierarchyObject>();

		// These merchants are the 5-th (along with accounts) level of hierarchy.
		// They are tied directly to contracts. 
		ArrayList<CommonHierarchyObject> contractMerchantObjects = new ArrayList<CommonHierarchyObject>();

		// Tie accounts and merchants to contracts.
		for (CommonHierarchyObject contractObj : contractObjects) {
			contractObj.setChildren(new ArrayList<CommonHierarchyObject>());

			Account[] contractAccounts = getAccountsByContract(contractObj.getId());
			for (Account account : contractAccounts) {
				CommonHierarchyObject accountObj = new CommonHierarchyObject();
				accountObj.setId(account.getId());
				accountObj.setParentId(contractObj.getId());
				accountObj.setName(currencyUtils.getCurrencyShortNamesMap().get(
						account.getCurrency())
						+ " "
						+ account.getAccountNumber()
						+ " "
						+ getDictUtils().getAllArticlesDesc().get(account.getStatus()));
				accountObj.setUniqueIndex(uniqueIndex++);
				//accountObj.setAgentId(account.getAgentId().longValue());
				accountObj.setEntityType(EntityNames.ACCOUNT);
				accountObj.setObject(account);

				contractObj.getChildren().add(accountObj);
				accountObjects.add(accountObj);

				// select node if we searched by this object
				if (EntityNames.ACCOUNT.equals(objectType) && objectId.equals(account.getId())) {
					currentNode = accountObj;
					setBeans();
				}
			}

			Merchant[] merchants = getMerchantsByContract(contractObj.getId());
			Integer merchantTotalIndex = merchants.length + uniqueIndex;
			Integer terminalUniqueIndex = merchantTotalIndex;
			while (uniqueIndex < merchantTotalIndex) {
				for( Merchant merchant : merchants ){
					CommonHierarchyObject obj = new CommonHierarchyObject();
					obj.setId(merchant.getId().longValue());
					obj.setName(merchant.getLabel());
					obj.setUniqueIndex(uniqueIndex);
					obj.setEntityType(EntityNames.MERCHANT);
					obj.setObject(merchant);
					if (buildMerchantTree(obj, contractMerchantObjects, Boolean.TRUE) == Boolean.FALSE){
						// Terminals are descendants of merchants (6th or 7th level of hierarchy)
						Terminal[] terminals = getTerminals(obj.getId().intValue());
						for (Terminal terminal : terminals) {
							CommonHierarchyObject term = new CommonHierarchyObject();
							term.setId(terminal.getId().longValue());
							term.setParentId(terminal.getMerchantId().longValue());
							term.setName(terminal.getTerminalName());
							term.setUniqueIndex(terminalUniqueIndex++);
							term.setEntityType(EntityNames.TERMINAL);
							term.setObject(terminal);
							if (obj.getChildren() == null) {
								obj.setChildren(new ArrayList<CommonHierarchyObject>());
							}
							obj.getChildren().add(term);
							if (EntityNames.TERMINAL.equals(objectType) && objectId.equals(terminal.getId().longValue())) {
								currentNode = term;
								setBeans();
							}
						}
						// Setup merchant hierarchy object
						if (merchant.getParentId() == null) {
							obj.setParentId(contractObj.getId());
							contractMerchantObjects.add(obj);
							uniqueIndex++;
						} else {
							obj.setParentId(merchant.getParentId());
							if (buildMerchantTree(obj, contractMerchantObjects, Boolean.FALSE) == Boolean.TRUE) {
								uniqueIndex++;
							}
						}
						if (EntityNames.MERCHANT.equals(objectType) && objectId.equals(merchant.getId().longValue())) {
							currentNode = obj;
							setBeans();
						}
					}
				}
			}
			for (CommonHierarchyObject objects: contractMerchantObjects) {
				contractObj.getChildren().add(objects);
			}
			uniqueIndex += (terminalUniqueIndex - merchantTotalIndex);
		}

		// These merchants are 6-th level of hierarchy. They are tied 
		// to contract accounts. 
		ArrayList<CommonHierarchyObject> accountMerchantObjects = new ArrayList<CommonHierarchyObject>();

		// connect merchants and account terminals to accounts
		for (CommonHierarchyObject accountObj : accountObjects) {
			accountObj.setChildren(new ArrayList<CommonHierarchyObject>());

			// connect merchants to accounts
			Merchant[] merchants = getMerchantsByAccount(accountObj.getId());
			for (Merchant merchant : merchants) {
				CommonHierarchyObject merchantObj = new CommonHierarchyObject();
				merchantObj.setId(merchant.getId().longValue());
				merchantObj.setParentId(accountObj.getId());
				merchantObj.setName(merchant.getLabel());
				merchantObj.setUniqueIndex(uniqueIndex++);
				merchantObj.setEntityType(EntityNames.MERCHANT);
				merchantObj.setObject(merchant);

				accountObj.getChildren().add(merchantObj);
				accountMerchantObjects.add(merchantObj);

				// Here no merchants is selected to not to select two nodes
				// because if tree is built by merchant node is selected above.

				// Tie terminals to merchants
				merchantObj.setChildren(new ArrayList<CommonHierarchyObject>());
				Terminal[] terminals = getTerminals(merchantObj.getId().intValue());
				for (Terminal terminal : terminals) {
					CommonHierarchyObject terminalObj = new CommonHierarchyObject();
					terminalObj.setId(terminal.getId().longValue());
					terminalObj.setParentId(terminal.getMerchantId().longValue());
					terminalObj.setName(terminal.getTerminalName());
					terminalObj.setUniqueIndex(uniqueIndex++);
					terminalObj.setEntityType(EntityNames.TERMINAL);
					terminalObj.setObject(terminal);

					merchantObj.getChildren().add(terminalObj);

					// Here no terminals is selected to not to select two nodes
					// because if tree is built by terminal node then it is selected below.
				}
			}
			// Tie terminals to accounts
			Terminal[] accountTerminals = getTerminalsByAccount(accountObj.getId());
			for (Terminal terminal : accountTerminals) {
				CommonHierarchyObject terminalObj = new CommonHierarchyObject();
				terminalObj.setId(terminal.getId().longValue());
				terminalObj.setParentId(accountObj.getId());
				terminalObj.setName(terminal.getTerminalName());
				terminalObj.setUniqueIndex(uniqueIndex++);
				terminalObj.setEntityType(EntityNames.TERMINAL);
				terminalObj.setObject(terminal);

				accountObj.getChildren().add(terminalObj);

				// Here no terminals is selected to not to select two nodes
				// because if tree is built by terminal node then it is selected below.
			}
		}
	}

	/**
	 * <p>
	 * Constructs <code>CommonIssuingObject</code> for <code>customer</code>,
	 * adds it to children of <code>inst</code> and returns it.
	 * </p>
	 */
	private CommonHierarchyObject addCustomerToInst(Customer customer, CommonHierarchyObject inst,
			int uniqueIndex) {
		CommonHierarchyObject customerObj = new CommonHierarchyObject();
		customerObj.setId(customer.getId());
		customerObj.setParentId(inst.getId());
		customerObj.setName(getCustomerName(customer));
		customerObj.setUniqueIndex(uniqueIndex++);
		customerObj.setEntityType(EntityNames.CUSTOMER);
		customerObj.setObject(customer);

		inst.getChildren().add(customerObj);

		// Select node if we searched by customer.
		if (EntityNames.CUSTOMER.equals(objectType)) {
			currentNode = customerObj;
			setBeans();
		}

		return customerObj;
	}

	private ArrayList<CommonHierarchyObject> addAgentsToCustomer(List<Agent> agents,
			CommonHierarchyObject customer, int uniqueIndex) {
		customer.setChildren(new ArrayList<CommonHierarchyObject>(agents.size()));

		for (Agent agent : agents) {
			CommonHierarchyObject agentObj = new CommonHierarchyObject();
			agentObj.setId(agent.getId().longValue());
			agentObj.setParentId(customer.getId());
			agentObj.setName(agent.getName());
			agentObj.setEntityType(EntityNames.AGENT);
			agentObj.setObject(agent);
			agentObj.setUniqueIndex(uniqueIndex++);

			customer.getChildren().add(agentObj);
		}

		return customer.getChildren();
	}

	private ArrayList<CommonHierarchyObject> addContractsToAgents(List<Contract> contracts,
			ArrayList<CommonHierarchyObject> agents, int uniqueIndex) {
		ArrayList<CommonHierarchyObject> contractObjects = new ArrayList<CommonHierarchyObject>(
				contracts.size());

		for (CommonHierarchyObject agent : agents) {
			agent.setChildren(new ArrayList<CommonHierarchyObject>());
			// add contracts to agent
			for (Contract contract : contracts) {
				if (contract.getAgentId().equals(agent.getId().intValue())) {
					CommonHierarchyObject contractObj = new CommonHierarchyObject();
					contractObj.setId(contract.getId());
					contractObj.setParentId(agent.getId());
					contractObj.setName(contract.getContractNumber());
					contractObj.setUniqueIndex(uniqueIndex++);
					contractObj.setAgentId(agent.getId());
					contractObj.setEntityType(EntityNames.CONTRACT);
					contractObj.setObject(contract);

					agent.getChildren().add(contractObj);
					contractObjects.add(contractObj);

					// select node if we searched by this object
					if (EntityNames.CONTRACT.equals(objectType)
							&& objectId.equals(contract.getId())) {
						currentNode = contractObj;
						setBeans();
					}
				}
			}
		}

		return contractObjects;
	}

	private ArrayList<CommonHierarchyObject> addAgentsToInst(List<Agent> agents,
			CommonHierarchyObject inst, int uniqueIndex) {
		inst.setChildren(new ArrayList<CommonHierarchyObject>(agents.size()));
		for (Agent agent : agents) {
			if (agent.getInstId().equals(inst.getId().intValue())) {
				CommonHierarchyObject agentObj = new CommonHierarchyObject();
				agentObj.setId(agent.getId().longValue());
				agentObj.setParentId(inst.getId());
				agentObj.setName(agent.getName() + " - " + agent.getExternalNumber());
				agentObj.setEntityType(EntityNames.AGENT);
				agentObj.setObject(agent);
				agentObj.setUniqueIndex(uniqueIndex++);

				inst.getChildren().add(agentObj);
			}
		}

		return inst.getChildren();
	}

	private void addCustomerToAgents(Customer customer, ArrayList<CommonHierarchyObject> agents,
			int uniqueIndex) {
		boolean customerSelected = false;
		for (CommonHierarchyObject agent : agents) {
			agent.setChildren(new ArrayList<CommonHierarchyObject>(1));

			CommonHierarchyObject customerObj = new CommonHierarchyObject();
			customerObj.setId(customer.getId());
			customerObj.setParentId(agent.getId());
			customerObj.setName(getCustomerName(customer));
			customerObj.setUniqueIndex(uniqueIndex++);
			customerObj.setAgentId(agent.getId());

			customerObj.setEntityType(EntityNames.CUSTOMER);

            customer.setAgentId(agent.getId().intValue());
            Agent agentObj = (Agent)agent.getObject();
            customer.setAgentName(agentObj != null ? agentObj.getName() : null);
            customer.setAgentNumber(agentObj != null ? agentObj.getExternalNumber() : null);

            customerObj.setObject(customer);

			agent.getChildren().add(customerObj);
			// Select node if we searched by customer.
			// Only customer in first agent is selected (customer is 
			// always only one but it can belong to different agents) 
			if (EntityNames.CUSTOMER.equals(objectType) && !customerSelected) {
				currentNode = customerObj;
				setBeans();
				customerSelected = true;
			}
		}
	}

	private ArrayList<CommonHierarchyObject> addContractsToCustomer(List<Contract> contracts,
			ArrayList<CommonHierarchyObject> agents, int uniqueIndex) {
		ArrayList<CommonHierarchyObject> contractObjects = new ArrayList<CommonHierarchyObject>(
				contracts.size());

		for (CommonHierarchyObject agent : agents) {
			CommonHierarchyObject customerObj = agent.getChildren().get(0);
			customerObj.setChildren(new ArrayList<CommonHierarchyObject>());
			// add contracts to Customer
			for (Contract contract : contracts) {
				if (contract.getAgentId().equals(agent.getId().intValue())) {
					CommonHierarchyObject contractObj = new CommonHierarchyObject();
					contractObj.setId(contract.getId());
					contractObj.setParentId(customerObj.getId());
					contractObj.setName(contract.getContractNumber());
					contractObj.setUniqueIndex(uniqueIndex++);
					contractObj.setAgentId(agent.getId());
					contractObj.setEntityType(EntityNames.CONTRACT);
					contractObj.setObject(contract);

					customerObj.getChildren().add(contractObj);
					contractObjects.add(contractObj);

					// select node if we searched by this object
					if (EntityNames.CONTRACT.equals(objectType)
							&& objectId.equals(contract.getId())) {
						currentNode = contractObj;
						setBeans();
					}
				}
			}
		}

		return contractObjects;
	}

	private Merchant[] getMerchantsByAccount(Long accountId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("LANG");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("ACCOUNT_ID");
		filters[1].setValue(accountId);
		params.setRowIndexEnd(Integer.MAX_VALUE);

		params.setFilters(filters);
		Map <String, Object> paramsMap = new HashMap<String, Object>(); 
		paramsMap.put("param_tab", filters);
		paramsMap.put("tab_name", "ACCOUNT");
		
		return _acquiringDao.getMerchantsCur(userSessionId, params, paramsMap);
	}

	public boolean isFromCustomer() {
		return fromCustomer;
	}

	public void setFromCustomer(boolean fromCustomer) {
		this.fromCustomer = fromCustomer;
	}

	public List<String> getErrorMessages() {
		return errorMessages;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("attrTab")) {
			MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_HIERACHY;
	}
}

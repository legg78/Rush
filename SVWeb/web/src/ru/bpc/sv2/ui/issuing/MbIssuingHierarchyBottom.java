package ru.bpc.sv2.ui.issuing;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.common.Company;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.Cardholder;
import ru.bpc.sv2.issuing.CommonHierarchyObject;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbIssuingHierarchyBottom")
public class MbIssuingHierarchyBottom implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ISSUING");

	private final String ERROR_PREFIX = "An error occurred while building hierarchy: ";

	private AccountsDao _accountsDao = new AccountsDao();

	private CommonDao _commonDao = new CommonDao();

	private OrgStructDao _orgStructDao = new OrgStructDao();

	private IssuingDao _issuingDao = new IssuingDao();

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
	private boolean searching;
	
	private transient CurrencyCache curCache;
	private transient DictUtils dictUtils;
	
	private Long userSessionId = null;

	private List<String> errorMessages;
	
	SelectionParams params;

	public MbIssuingHierarchyBottom() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = userLang = SessionWrapper.getField("language");
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
		return (CommonHierarchyObject) Faces.var("issObject");
	}

	private void loadTree() {
		if (searching) {
			coreObjects = new ArrayList<CommonHierarchyObject>();
			errorMessages = new ArrayList<String>();

			if (EntityNames.ACCOUNT.equals(objectType)) {
				buildTreeByAccount();
			} else if (EntityNames.CARD.equals(objectType)) {
				buildTreeByCard();
			} else if (EntityNames.CONTRACT.equals(objectType)) {
				buildTreeByContract();
			} else if (EntityNames.CUSTOMER.equals(objectType)) {
				buildTreeByCustomer();
			}

			treeLoaded = true;
		}
	}

//    private void buildTreeByAccount() {
//    	try {
//    		// Customer is the third level of hierarchy 
//    		Customer customer = _issuingDao.getCustomerByAccount(userSessionId, objectId);
//    		
//    		if (customer != null) {
//    			buildTree(customer);
//    		}
//    	} catch (Exception e) {
//    		FacesUtils.addMessageError(e);
//    		logger.error("", e);
//    	}
//    }

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

	private void buildTreeByCard() {
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("LANG");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("CARD_ID");
			filters[1].setValue(objectId);
			params.setFilters(filters);

			Map<String, Object> paramsMap = new HashMap<String, Object>();
			paramsMap.put("param_tab", filters);
			paramsMap.put("tab_name", "CONTRACT");

			Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, paramsMap);
			if (contracts != null && contracts.length > 0) {
				filters[1].setElement("id");
				filters[1].setValue(contracts[0].getCustomerId());
				params.setFilters(filters);
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
			params.setPrivilege(getParams().getPrivilege());

			List<Customer> customers = _productsDao.getCustomers(userSessionId, params, curLang);
			if (customers != null && !customers.isEmpty()) {
				buildTree(customers.get(0), null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
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

		CommonHierarchyObject errorObj = new CommonHierarchyObject(true);

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
		if (EntityNames.CUSTOMER.equals(objectType)) {
			CommonHierarchyObject customerObj = addCustomerToInst(customer, instObj, uniqueIndex);
			agentObjects = addAgentsToCustomer(agents, customerObj, uniqueIndex);

			contractObjects = addContractsToAgents(contracts, agentObjects, uniqueIndex);
		} else {
			agentObjects = addAgentsToInst(agents, instObj, uniqueIndex);
			addCustomerToAgents(customer, agentObjects, uniqueIndex);

			contractObjects = addContractsToCustomer(contracts, agentObjects, uniqueIndex);
		}

		// Tie accounts and cardholders (both are the 5-th level of hierarchy) to contracts.
		for (CommonHierarchyObject contractObj : contractObjects) {
			contractObj.setChildren(new ArrayList<CommonHierarchyObject>());

			// first - accounts
			Account[] contractAccounts = getAccountsByContract(contractObj.getId());
			for (Account account : contractAccounts) {
				CommonHierarchyObject accountObj = new CommonHierarchyObject();
				accountObj.setId(account.getId());
				accountObj.setParentId(contractObj.getId());
				accountObj.setName(getCurrencyCache().getCurrencyShortNamesMap().get(
						account.getCurrency())
						+ " "
						+ account.getAccountNumber()
						+ " "
						+ getDictUtils().getAllArticlesDesc().get(account.getStatus()));
				accountObj.setUniqueIndex(uniqueIndex++);
				//accountObj.setAgentId(account.getAgentId().longValue());
				accountObj.setEntityType(EntityNames.ACCOUNT);
				accountObj.setObject(account);

				Card[] cards = getCardsByAccount(account.getId());
				accountObj.setChildren(new ArrayList<CommonHierarchyObject>(cards.length));

				for (Card card : cards) {
					Cardholder holder = getCardholder(card.getCardholderId());
					if (holder == null) {
						holder = new Cardholder();
						if (!coreObjects.get(0).isErrorNode()) {
							coreObjects.add(0, errorObj);
						}
						errorMessages.add(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Iss",
								"cardholder_not_found", card.getMask()));
					}
					card.setHolder(holder);

					CommonHierarchyObject cardObj = new CommonHierarchyObject();
					cardObj.setId(card.getId());
					cardObj.setParentId(account.getId());
					cardObj.setName(card.getMask() + " - " + card.getCardholderName());
					cardObj.setEntityType(EntityNames.CARD);
					cardObj.setUniqueIndex(uniqueIndex++);
					cardObj.setObject(card);

					accountObj.getChildren().add(cardObj);

					// select node if we searched by this object
					if (EntityNames.CARD.equals(objectType) && objectId.equals(card.getId())) {
						currentNode = cardObj;
					}
				}

				contractObj.getChildren().add(accountObj);

				// select node if we searched by this object
				if (EntityNames.ACCOUNT.equals(objectType) && objectId.equals(account.getId())) {
					currentNode = accountObj;
				}
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
			agentObj.setName(agent.getName() + " - " + agent.getExternalNumber());
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
				agentObj.setName(agent.getName());
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
			customerObj.setObject(customer);

			agent.getChildren().add(customerObj);

			// Select node if we searched by customer.
			// Only customer in first agent is selected (customer is 
			// always only one but it can belong to different agents) 
			if (EntityNames.CUSTOMER.equals(objectType) && !customerSelected) {
				currentNode = customerObj;
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
					}
				}
			}
		}

		return contractObjects;
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
		filters[2].setValue(ProductConstants.ISSUING_PRODUCT);

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

	private Card[] getCardsByAccount(Long accountId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("accountId");
		filters[1].setValue(accountId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);

		return _issuingDao.getCards(userSessionId, params);
	}

	private Cardholder getCardholder(Long cardholderId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("id");
		filters[1].setValue(cardholderId);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);

		try {
			Cardholder[] holders = _issuingDao.getCardholders(userSessionId, params, curLang);
			if (holders != null && holders.length > 0) {
				return holders[0];
			}
		} catch (Exception e) {
			logger.error("", e);
		}
		return null;
	}

	private List<Agent> getAgentsByCustomer(Long customerId) {
		List<Agent> agents = _orgStructDao.getAgentsByCustomer(userSessionId, customerId);
		return agents;
	}

	private Account[] getAccountsByContract(Long contractId) {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("contractId");
		filters[1].setValue(contractId);

		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);

		return _accountsDao.getAccounts(userSessionId, params);
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

	public void cancel() {

	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreObjects = null;
		treeLoaded = false;
		curLang = userLang;		
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

	public List<String> getErrorMessages() {
		return errorMessages;
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}

	public CurrencyCache getCurrencyCache() {
		if (curCache == null) {
			curCache = CurrencyCache.getInstance();
		}
		return curCache;
	}
	
	public SelectionParams getParams() {
		if (params == null) params = new SelectionParams();
		return params;
	}
}

package ru.bpc.sv2.ui.application;

import org.ajax4jsf.context.AjaxContext;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.component.UIDragSupport;
import org.richfaces.component.UITree;
import org.richfaces.component.UITreeNode;
import org.richfaces.component.html.HtmlTree;
import org.richfaces.event.DropEvent;
import org.richfaces.event.NodeSelectedEvent;
import org.richfaces.model.TreeNode;
import org.richfaces.model.TreeNodeImpl;
import org.richfaces.model.TreeRowKey;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.application.ApplicationPrivConstants;
import ru.bpc.sv2.application.ContractObject;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.issuing.ProductCardType;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.products.*;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.issuing.MbProductSearchModal;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.ArrayMap;
import ru.bpc.sv2.utils.TreeUtils;
import ru.bpc.svap.Account;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbApplicationCreate")
public class MbApplicationCreate extends AbstractBean {
	private static final long serialVersionUID = -5167108016168606669L;
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private ApplicationDao _applicationDao = new ApplicationDao();
	private ProductsDao _productsDao = new ProductsDao();
	private OrgStructDao orgStructDao = new OrgStructDao();
	private SettingsDao _settingsDao = new SettingsDao();
	private IssuingDao _issuingDao = new IssuingDao();

	private String appType;
	private String module;
	private Application newApplication;

	public static final String COMPANY = "ENTTCOMP";
	public static final String SRVP = "ENTTSRVP";
	public static final Integer INST_APP_DEFAULT_FLOW_ID = 2301;
	public static final Integer INST_APP_CREATE_FLOW_ID = 2302;
	public static final Integer QUESTIONARY_APP_CREATE_FLOW_ID = 2401;
	public static final Integer CAMPAIGN_APP_CREATE_FLOW_ID = 2501;

	private final DaoDataListModel<Contract> _contractsSource;
	private final TableRowSelection<Contract> _contractsSelection;
	private boolean searchingContract;
	private boolean searchingAccountsWithoutContract;
	private boolean searchingCardsWithoutContract;
	private Contract _activeContract;
	private Contract filterContract;
	private List<Filter> filtersContract;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> extCustomerTypes;

	private boolean newCustomer;
	private boolean newContract;
	private boolean newProduct = false;

	private UserSession userSession;

	private List<ContractObject> services;
	private ContractObject[] cards;
	private ContractObject[] linkCards;
	private List<ContractObject> selectedCards;
	private ContractObject[] accounts;
	private ContractObject[] linkAccounts;
	private ContractObject[] cbsAccounts;
	private List<Account> cbsAccountsAll;
	private ContractObject[] eWalletAccounts;
	private List<ContractObject> selectedAccounts;
	private ContractObject[] merchants;
	private ContractObject[] linkMerchants;
	private List<ContractObject> selectedMerchants;
	private ContractObject[] terminals;
	private ContractObject[] linkTerminals;
	private List<ContractObject> selectedTerminals;
	private List<ContractObject> selectedObjects;

	private ProductService[] productServices;
	private List<ProductService> selectedProductServices;
	private ProductCardType[] cardTypes;
	private List<ProductCardType> selectedCardTypes;
	private ProductAccountType[] accountTypes;
	private List<ProductAccountType> selectedAccountTypes;

	private String branchEntity;
	private String initialServiceId;
	private String parentMerchantId;
	private String branchObjectId;
	private String objectNumberMask;
	private boolean isNew;

	private Map<String, List<ProductService>> initialServices;

	private Map<String, Map<String, List<ContractObject>>> customerObjects;
	private Map<String, Map<String, List<ContractObject>>> accountObjects;
	private Map<String, Map<String, List<ContractObject>>> cardObjects;
	private Map<String, Map<String, List<ContractObject>>> merchantObjects;
	private Map<String, Map<String, List<ContractObject>>> terminalObjects;
	private Map<String, Map<String, List<ContractObject>>> contractObjects;
	private List<ContractObject> finalObjects;

	private String customerMainContract;

	private boolean disableInst;
	private boolean disableAgent;
	private boolean disableCustomer;
	private boolean disableContract;
	private boolean disableAppFlow;
	private boolean disableCustomerType;
	private boolean disableContractType;
	private boolean disableProduct;

	private List<SelectItem> customerTypes;
	private List<SelectItem> serviceProviders;
	private String customerTypeDescription;
	private List<SelectItem> contractTypes;
	private String contractTypeDescription;

	private boolean showAppType;
	private boolean closeWizard = false;
    private boolean displayWizardPage = true;
	private boolean displayFinishButton = false;
	private Map<String, Object> parentMerchants = new LinkedHashMap<String, Object>(0);

	private ArrayMap<List<SelectItem>> flowCache = new ArrayMap<List<SelectItem>>();

	private Map<String, Object> contractParamMaps;

	public MbApplicationCreate() {
		userSession = ManagedBeanWrapper.getManagedBean("usession");

		_contractsSource = new DaoDataListModel<Contract>(logger) {
			private static final long serialVersionUID = 6326935688695442986L;

			@Override
			protected List<Contract> loadDaoListData(SelectionParams params) {
				if (isSearchingContract()) {
					setFiltersContract();
					params.setFilters(filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("param_tab", filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("tab_name", "CONTRACT");
					return Arrays.asList(_productsDao.getContractsCur(userSessionId, params, getContractParamMaps()));
				}
				return new ArrayList<Contract>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!isSearchingContract()) {
						return 0;
					}
					setFiltersContract();
					params.setFilters(filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("param_tab", filtersContract.toArray(new Filter[filtersContract.size()]));
					getContractParamMaps().put("tab_name", "CONTRACT");
					return _productsDao.getContractsCurCount(userSessionId, params, getContractParamMaps());
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return 0;
			}
		};
		_contractsSelection = new TableRowSelection<Contract>(null, _contractsSource);
	}

	public DaoDataListModel<Contract> getContracts() {
		return _contractsSource;
	}

	public Contract getActiveContract() {
		return _activeContract;
	}
	public void setActiveContract(Contract activeContract) {
		_activeContract = activeContract;
	}

	public SimpleSelection getContractsSelection() {
		return _contractsSelection.getWrappedSelection();
	}
	public void setContractsSelection(SimpleSelection selection) {
		_contractsSelection.setWrappedSelection(selection);
		_activeContract = _contractsSelection.getSingleSelection();
	}

	public boolean isSearchingContract() {
		return searchingContract;
	}
	public void setSearchingContract(boolean searchingContract) {
		this.searchingContract = searchingContract;
	}

	public boolean isSearchingAccountsWithoutContract() {
		return searchingAccountsWithoutContract;
	}
	public void setSearchingAccountsWithoutContract(boolean searchingAccountsWithoutContract) {
		this.searchingAccountsWithoutContract = searchingAccountsWithoutContract;
	}
	public void searchAccountsWithoutContract() {
		setSearchingAccountsWithoutContract(isSearchingAccountsWithoutContract());
	}

	public boolean isSearchingCardsWithoutContract() {
		return searchingCardsWithoutContract;
	}
	public void setSearchingCardsWithoutContract(boolean searchingCardsWithoutContract) {
		this.searchingCardsWithoutContract = searchingCardsWithoutContract;
	}
	public void searchCardsWithoutContract() {
		setSearchingCardsWithoutContract(isSearchingCardsWithoutContract());
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

	public void searchContracts() {
		setSearchingContract(true);
		_contractsSelection.clearSelection();
		_activeContract = null;
		_contractsSource.flushCache();
		updateContractTypes();
	}

	public void showContracts() {
		searchingContract = false;
		_contractsSelection.clearSelection();
		_activeContract = null;
		_contractsSource.flushCache();
		filterContract = new Contract();
		filterContract.setInstId(getNewApplication().getInstId());
		filterContract.setAgentId(getNewApplication().getAgentId());
		if (isNewCustomer() && getNewApplication().getCustomerType() != null) {
			filterContract.setCustomerType(getNewApplication().getCustomerType());
		}
	}

	public void selectContract() {
		Contract selected = _contractsSelection.getSingleSelection();
		getNewApplication().setContractId(selected.getId());
		getNewApplication().setContractNumber(selected.getContractNumber());

		getNewApplication().setCustomerId(selected.getCustomerId());
		getNewApplication().setCustomerNumber(selected.getCustomerNumber());
		getNewApplication().setCustomerType(selected.getCustomerType());
		customerMainContract = selected.getCustomerContractNumber();

		getNewApplication().setProductId(selected.getProductId());
		getNewApplication().setContractType(selected.getContractType());
		newCustomer = false;
		newContract = false;
		getNewApplication().setContractType(selected.getContractType());
		updateContractTypes();
	}


	public void showProducts() {
		MbProductSearchModal bean = (MbProductSearchModal) ManagedBeanWrapper.getManagedBean("MbProductSearchModal");
		bean.clearFilter();
		bean.getFilter().setInstId(getNewApplication().getInstId());
	}

	public void selectProduct() {
		MbProductSearchModal bean = (MbProductSearchModal) ManagedBeanWrapper.getManagedBean("MbProductSearchModal");
		Product selected = bean.getDetailNode();
		if (selected != null) {
			getNewApplication().setProductId(selected.getId().intValue());
			getNewApplication().setProductName(selected.getName());
		}
	}

	public void setFiltersContract() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Contract filter = getFilterContract();

		if (StringUtils.isNotEmpty(filter.getAccountNumber())) {
			filtersList.add(Filter.create("ACCOUNT_NUMBER", Operator.like, Filter.mask(filter.getAccountNumber())));
		}
		if (StringUtils.isNotEmpty(filter.getCardNumber())) {
			filtersList.add(Filter.create("CARD_NUMBER", Operator.like, "like", Filter.mask(filter.getCardNumber())));
		}
		if (StringUtils.isNotEmpty(filter.getCustomerNumber())) {
			filtersList.add(Filter.create("CUSTOMER_NUMBER", Operator.like, Filter.mask(filter.getCustomerNumber())));
		}
		if (filter.getCustomerId() != null) {
			filtersList.add(Filter.create("CUSTOMER_ID", filter.getCustomerId().toString()));
		}
		if (StringUtils.isNotEmpty(filter.getContractNumber())) {
			filtersList.add(Filter.create("CONTRACT_NUMBER", Operator.like, Filter.mask(filter.getContractNumber())));
		}
		if (StringUtils.isNotEmpty(filter.getTerminalNumber())) {
			filtersList.add(Filter.create("TERMINAL_NUMBER", Operator.like, Filter.mask(filter.getTerminalNumber())));
		}
		if (StringUtils.isNotEmpty(filter.getMerchantNumber())) {
			filtersList.add(Filter.create("MERCHANT_NUMBER", Operator.like, Filter.mask(filter.getMerchantNumber())));
		}
		if (filter.getInstId() != null) {
			filtersList.add(Filter.create("INST_ID", filter.getInstId().toString()));
		}
		if (getNewApplication().getAgentId() != null) {
			filtersList.add(Filter.create("AGENT_ID", filter.getAgentId().toString()));
		}
		if (StringUtils.isNotEmpty(filter.getContractType())) {
			filtersList.add(Filter.create("CONTRACT_TYPE", filter.getContractType()));
		}
		if (StringUtils.isNotEmpty(filter.getCustomerType())) {
			filtersList.add(Filter.create("CUSTOMER_TYPE", filter.getCustomerType()));
		}
		filtersList.add(Filter.create("LANG", curLang));
		filtersList.add(Filter.create("PRODUCT_TYPE", isProductType() ? determineProductType()
		                                                                     : (isAcquiringType() ? ProductConstants.ACQUIRING_PRODUCT
		                                                                                          : ProductConstants.ISSUING_PRODUCT)));

		filtersContract = filtersList;
	}

	private String determineProductType() {
		if ("acquiring|products".equals(thisBackLink)) {
			return ProductConstants.ACQUIRING_PRODUCT;
		} else if ("orgStruct|products".equals(thisBackLink)) {
			return ProductConstants.INSTITUTION_PRODUCT;
		} else {
			return ProductConstants.ISSUING_PRODUCT;
		}
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		custBean.setDefaultInstId(newApplication.getInstId());
		custBean.setDefaultAgentId(newApplication.getAgentId());
		custBean.setNotPersonTab(isAcquiringType());
	}

	public void selectCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
		Customer selectedCustomer = custBean.getActiveCustomer();
		if (!newApplication.getInstId().equals(custBean.getFilter().getInstId())) {
			String message = String.format("You cannot select a client from the institution %s. Select a client from the institution %s", selectedCustomer.getInstId(), newApplication.getInstId());
			FacesUtils.addErrorExceptionMessage(message);
			return;
		}
		if (selectedCustomer != null) {
			// If this customer is a new customer queried from CBS
			if (selectedCustomer.isNewCustomer()) {
				this.newCustomer = true;
				getNewApplication().setCustomerNumber(null);
				getNewApplication().setCustomerType(null);
				getNewApplication().setCustomerId(null);
				clearContractNumber();
				setNewContract(true);
			} else {
				setNewCustomer(false);
				setNewContract(false);
				getNewApplication().setCustomerId(selectedCustomer.getId());
				customerMainContract = selectedCustomer.getContractNumber();
				if (isIssuingType() && isCbsSyncEnabled()) {
					// If this is an existing customer, query CBS for possible new accounts
					if (custBean.getCbsCustomer() == null) {
						custBean.setCbsCustomer(custBean.queryCbs(selectedCustomer.getCustomerNumber(), false));
					}
				}
				if (isIssuingType() && iseWalletSyncEnabled()) {
					// If this is an existing customer, query eWallet for possible new accounts
					if (custBean.geteWalletCustomer() == null) {
						custBean.seteWalletCustomer(custBean.queryEWallet(selectedCustomer.getCustomerNumber(), false));
					}
				}
			}
			getNewApplication().setCustomerNumber(selectedCustomer.getCustomerNumber());
			getNewApplication().setCustomerType(selectedCustomer.getEntityType());
			clearContractNumber();
			updateContractTypes();
			if (isIssuingType() && isCbsSyncEnabled()) {
				processCbsAccounts();
			}
			if (isIssuingType() && iseWalletSyncEnabled()) {
				processEWalletAccounts();
			}
		}
	}

	private void updateCustomerTypes() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		customerTypes = null;
		if (isAcquiringType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (isIssuingType() || isQuestionaryType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		} else {
			return;
		}
		customerTypes = getDictUtils().getLov(LovConstants.CUSTOMER_TYPE_NO_AGNT, paramMap, null);

	}

	public List<SelectItem> getCustomerTypes() {
		if (customerTypes == null) {
			customerTypes = new ArrayList<SelectItem>(0);
		}
		return customerTypes;
	}

	@SuppressWarnings("unchecked")
	public void updateContractTypes() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		Set contractTypesRemovedDuplicates = null;
		contractTypes = null;
		if (isAcquiringType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (isIssuingType() || isQuestionaryType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		} else if (isInstitutionType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.INSTITUTION_PRODUCT);
		} else if (isProductType()) {
			if (getNewApplication().getProductType() == null) {
				getNewApplication().setProductType(determineProductType());
			}
			paramMap.put("PRODUCT_TYPE", getNewApplication().getProductType());
		} else {
			return;
		}
		if (getNewApplication().getCustomerType() != null && !getNewApplication().getCustomerType().trim().equals("")) {
			paramMap.put("CUSTOMER_ENTITY_TYPE", getNewApplication().getCustomerType());
		} else if (!isProductType()) {
			return;
		} else {
			contractTypesRemovedDuplicates = new TreeSet(new Comparator<SelectItem>() {
				@Override
				public int compare(SelectItem o1, SelectItem o2) {
					if(o1.getValue().equals(o2.getValue())){
						return 0;
					}
					return 1;
				}
			});
		}
		getNewApplication().setExtCustomerType(null);
		contractTypes = getDictUtils().getLov(LovConstants.CONTRACT_TYPES, paramMap);
		if(contractTypesRemovedDuplicates != null) {
			contractTypesRemovedDuplicates.addAll(contractTypes);
			contractTypes = new ArrayList<SelectItem>(contractTypesRemovedDuplicates);
		}
	}

	public List<SelectItem> getContractTypes() {
		if (contractTypes == null) {
			contractTypes = new ArrayList<SelectItem>(0);
		}
		return contractTypes;
	}

	public Application getNewApplication() {
		if (newApplication == null)
			newApplication = new Application();
		return newApplication;
	}

	public void setNewApplication(Application newApplication) {
		this.newApplication = newApplication;
	}

	public boolean isIssuingType() {
		return (ApplicationConstants.TYPE_ISSUING).equals(appType);
	}

	public boolean isQuestionaryType() {
		return (ApplicationConstants.TYPE_QUESTIONARY).equals(appType);
	}

	public boolean isCampaignType() {
		return (ApplicationConstants.TYPE_CAMPAIGNS).equals(appType);
	}

	public boolean isAcquiringType() {
		return (ApplicationConstants.TYPE_ACQUIRING).equals(appType);
	}

	public boolean isInstitutionType() {
		return (ApplicationConstants.TYPE_INSTITUTION).equals(appType);
	}

	public boolean isProductType() {
		if (ApplicationConstants.TYPE_PRODUCT.equals(appType) ||
			ApplicationConstants.TYPE_ISS_PRODUCT.equals(appType) ||
			ApplicationConstants.TYPE_ACQ_PRODUCT.equals(appType)) {
			return true;
		}
		return false;
	}
	public boolean isAcqProductType() {
		return ApplicationConstants.TYPE_ACQ_PRODUCT.equals(appType);
	}
	public boolean isIssProductType() {
		return ApplicationConstants.TYPE_ISS_PRODUCT.equals(appType);
	}
	public boolean isInstProductType() {
		return ApplicationConstants.TYPE_PRODUCT.equals(appType);
	}

	public String getAppType() {
		return appType;
	}

	public void setAppType(String appType) {
		this.appType = appType;
		if (newApplication != null) {
			newApplication.setAppType(appType);
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

	public List<SelectItem> getAgents() {
		if (getNewApplication().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getNewApplication().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public List<SelectItem> getProducts() {
		if (getNewApplication().getInstId() == null || getNewApplication().getContractType() == null) {
			return new ArrayList<SelectItem>();
		} else if (!isProductType() && getNewApplication().getCustomerType() == null) {
			return new ArrayList<SelectItem>();
		}
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getNewApplication().getInstId());
		paramMap.put("STATUS", ProductConstants.STATUS_ACTIVE_PRODUCT);
		paramMap.put("CONTRACT_TYPE", getNewApplication().getContractType());
		try {
			if (isAcquiringType()) {
				return getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCTS, paramMap);
			} else if (isIssuingType() || isQuestionaryType()) {
				return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
			} else if (isProductType()) {
				getNewApplication().setProductType(determineProductType());
				if (ProductConstants.ISSUING_PRODUCT.equals(getNewApplication().getProductType())) {
					return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
				} else if (ProductConstants.ACQUIRING_PRODUCT.equals(getNewApplication().getProductType())) {
					return getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCTS, paramMap);
				} else if (ProductConstants.INSTITUTION_PRODUCT.equals(getNewApplication().getProductType())) {
					return getDictUtils().getLov(LovConstants.INSTITUTION_PRODUCTS, paramMap);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}

	public List<SelectItem> getApplicationFlows() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);
			ArrayList<Filter> filtersFlow = new ArrayList<Filter>();

			if (getNewApplication().getInstId() != null) {
				filtersFlow.add(new Filter("instId", getNewApplication().getInstId().toString()));
				filtersFlow.add(new Filter("lang", curLang));
				filtersFlow.add(new Filter("type", getNewApplication().getAppType()));

				if (newApplication.getContractNumber() != null && !newApplication.getContractNumber().trim().equals("")) {
					filtersFlow.add(new Filter("contractExist", 1));
				} else {
					filtersFlow.add(new Filter("contractExist", 0));
				}

				if (newApplication.getCustomerNumber() != null && !newApplication.getCustomerNumber().trim().equals("")) {
					filtersFlow.add(new Filter("customerExist", 1));
					filtersFlow.add(new Filter("customerTypeNvl", getNewApplication().getCustomerType()));
				} else {
					filtersFlow.add(new Filter("customerExist", 0));
				}

				if(getNewApplication().getContractType() != null && !getNewApplication().getContractType().trim().equals("")) {
					filtersFlow.add(new Filter("contractTypeNvl", getNewApplication().getContractType()));
				}
				if(getNewApplication().getCustomerType() != null && !getNewApplication().getCustomerType().trim().equals("")) {
					filtersFlow.add(new Filter("customerTypeNvl", getNewApplication().getCustomerType()));
				}

				params.setFilters(filtersFlow);
				params.setSortElement(new SortElement("name", Direction.ASC));

				if(isIssuingType()){
					params.setPrivilege(ApplicationPrivConstants.ADD_ISSUING_APPLICATION);
				} else if(isAcquiringType()){
					params.setPrivilege(ApplicationPrivConstants.ADD_ACQUIRING_APPLICATION);
				} else if(isInstitutionType()){
					params.setPrivilege(ApplicationPrivConstants.ADD_INSTITUTION_APPLICATION);
				} else if(isQuestionaryType()) {
					params.setPrivilege(ApplicationPrivConstants.ADD_QUESTIONARY_APPLICATION);
				} else if(isCampaignType()) {
					params.setPrivilege(ApplicationPrivConstants.ADD_CAMPAIGN_APPLICATION);
				}

				Object[] key = {userSessionId, params};
				if (flowCache.containsKey(key)) {
					return flowCache.get(key);
				} else {
					ApplicationFlow[] flows = _applicationDao.getApplicationFlowsWithRoles(userSessionId, params);

					for (ApplicationFlow flow : flows) {
						//XXX: CORE-10196 Very evil hardcode - please do not try this at home
						if (flow.getId() == 1009) {
							if ("CNTPINIC".equals(getNewApplication().getContractType()) ||
									("CNTPPRPD".equals(getNewApplication().getContractType()))) {
								items.add(new SelectItem(flow.getId(), flow.getId() + " - " + flow.getName(), flow.getDescription()));
							}
						}
						else {
							items.add(new SelectItem(flow.getId(), flow.getId() + " - " + flow.getName(), flow.getDescription()));
						}
					}
					flowCache.put(key, items);
				}
			}
		} catch (DataAccessException e) {
			logger.error("", e);
			if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
				FacesUtils.addMessageError(e);
			}
		}
		return items;
	}

	private List<SelectItem> branchTypes = null;

	public List<SelectItem> getBranchTypes() {
		if (branchTypes == null && newApplication != null) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (newApplication.getAppType() != null && !newApplication.getAppType().equals("")) {
				paramMap.put("APPL_TYPE", newApplication.getAppType());
			}
			if (newApplication.getStatus() != null && !newApplication.getStatus().equals("")) {
				paramMap.put("APPL_STATUS", newApplication.getStatus());
			} else {
				paramMap.put("APPL_STATUS", ApplicationStatuses.JUST_CREATED);
			}
			if (newApplication.getFlowId() != null) {
				paramMap.put("FLOW_ID", newApplication.getFlowId().toString());
			}
			try {
				branchTypes = getDictUtils().getLov(LovConstants.APP_BRANCH_TYPES, paramMap);
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
				branchTypes = new ArrayList<SelectItem>();
			}
		}
		return branchTypes;
	}

	private void loadInitialServices(String entityType) {
		try {
			if (initialServices != null) {
				initialServices.clear();
			} else {
				initialServices = new HashMap<String, List<ProductService>>();
			}

			if (getNewApplication().getProductId() == null && !isNewProduct()) {
				return;
			}
			for (SelectItem si : getBranchTypes()) {
				String entity = (String) si.getValue();
				if (entity == null || entity.trim().equals("")) {
					continue;
				}
				try {
					SelectionParams params = new SelectionParams();
					params.setRowIndexEnd(-1);
					ArrayList<Filter> servicesFlow = new ArrayList<Filter>();

					if (getNewApplication().getContractNumber() != null &&
							getNewApplication().getContractNumber().trim().length() > 0) {
						Filter paramFilter = new Filter();
						paramFilter.setElement("contractNumber");
						paramFilter.setValue(getNewApplication().getContractNumber());
						servicesFlow.add(paramFilter);

						paramFilter = new Filter();
						paramFilter.setElement("entityType");
						paramFilter.setValue(entity);
						servicesFlow.add(paramFilter);

						paramFilter = new Filter();
						paramFilter.setElement("isInitial");
						paramFilter.setValue(1);
						servicesFlow.add(paramFilter);

						paramFilter = new Filter();
						paramFilter.setElement("lang");
						paramFilter.setValue(userLang);
						servicesFlow.add(paramFilter);

						params.setFilters(servicesFlow.toArray(new Filter[servicesFlow.size()]));
						ProductService[] services = _productsDao.getContractServices(userSessionId, params);
						initialServices.put(entity, Arrays.asList(services));
					} else {
						Filter paramFilter = new Filter();
						paramFilter.setElement("entityType");
						paramFilter.setValue(entity);
						servicesFlow.add(paramFilter);

						paramFilter = new Filter();
						paramFilter.setElement("isInitial");
						paramFilter.setValue(1);
						servicesFlow.add(paramFilter);

						paramFilter = new Filter();
						paramFilter.setElement("lang");
						paramFilter.setValue(userLang);
						servicesFlow.add(paramFilter);

						paramFilter = new Filter();
						paramFilter.setElement("productId");
						paramFilter.setValue(getNewApplication().getProductId());
						servicesFlow.add(paramFilter);

						paramFilter = new Filter();
						paramFilter.setElement("maxCount");
						paramFilter.setCondition(">");
						paramFilter.setValue(0);
						servicesFlow.add(paramFilter);

						params.setFilters(servicesFlow.toArray(new Filter[servicesFlow.size()]));
						ProductService[] services = _productsDao.getProductServices(userSessionId, params);
						initialServices.put(entity, Arrays.asList(services));
					}
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
			if (isProductType()) {
				List<ProductService> serv1 = new ArrayList<ProductService>(1);
				serv1.add(new ProductService());
				serv1.get(0).setMinCount(0);
				serv1.get(0).setCurrentCount(0);
				serv1.get(0).setAvalCount(30);
				serv1.get(0).setMaxCount(30);
				serv1.get(0).setServiceName("Count of adding services");
				initialServices.put(EntityNames.SERVICE, serv1);

				List<ProductService> serv2 = new ArrayList<ProductService>(1);
				serv2.add(new ProductService());
				serv2.get(0).setMinCount(0);
				serv2.get(0).setCurrentCount(0);
				serv2.get(0).setAvalCount(30);
				serv2.get(0).setMaxCount(30);
				serv2.get(0).setServiceName("Count of adding card types");
				initialServices.put(EntityNames.CARD_TYPE, serv2);

				List<ProductService> serv3 = new ArrayList<ProductService>(1);
				serv3.add(new ProductService());
				serv3.get(0).setMinCount(0);
				serv3.get(0).setCurrentCount(0);
				serv3.get(0).setAvalCount(30);
				serv3.get(0).setMaxCount(30);
				serv3.get(0).setServiceName("Count of adding account types");
				initialServices.put(EntityNames.ACCOUNT_TYPE, serv3);
			}
		} catch (Exception e) {
			logger.error("", e);
		} finally {
			if (initialServices == null) {
				initialServices = new HashMap<String, List<ProductService>>();
			}
		}
	}

	private List<ProductService> getInitialServices(String entityType) {
		if (initialServices == null) {
			loadInitialServices(entityType);
		}
		List<ProductService> lst = null;
		try {
			lst = initialServices.get(entityType);
		} catch (Exception e) {
			logger.error("", e);
		} finally {
			if (lst == null) {
				lst = new ArrayList<ProductService>();
			}
		}
		return lst;
	}

	public List<ProductService> getAccountInitialServices() {
		return getInitialServices(EntityNames.ACCOUNT);
	}

	public List<ProductService> getAccountTypeInitialServices() {
		return getInitialServices(EntityNames.ACCOUNT_TYPE);
	}

	public List<ProductService> getCardInitialServices() {
		return getInitialServices(EntityNames.CARD);
	}

	public List<ProductService> getCardTypeInitialServices() {
		return getInitialServices(EntityNames.CARD_TYPE);
	}

	public List<ProductService> getMerchantInitialServices() {
		return getInitialServices(EntityNames.MERCHANT);
	}

	public List<ProductService> getTerminalInitialServices() {
		return getInitialServices(EntityNames.TERMINAL);
	}

	public List<ProductService> getServiceInitialServices() {
		return getInitialServices(EntityNames.SERVICE);
	}

	public boolean isHasEntityInBranch(String entityName) {
		boolean find = false;
		if(chkExclude(entityName)){
			return false;
		}
		try {
			for (SelectItem si : getBranchTypes()) {
				if (entityName != null && entityName.equals(si.getValue())) {
					find = true;
					break;
				}
			}
		} catch (Exception ignored) {}
		if (isProductType()) {
			if (EntityNames.SERVICE.equals(entityName) ||
				EntityNames.ACCOUNT_TYPE.equals(entityName)) {
				find = true;
			} else if (EntityNames.CARD_TYPE.equals(entityName)) {
				find = !isAcqProductType();
			}
		}
		return find;
	}

	public boolean isHasAccounts() {
		return isHasEntityInBranch(EntityNames.ACCOUNT);
	}

	public boolean isHasCards() {
		return isHasEntityInBranch(EntityNames.CARD);
	}

	public boolean isHasServices() {
		return isHasEntityInBranch(EntityNames.SERVICE);
	}

	public boolean isHasAccountTypes() {
		return isHasEntityInBranch(EntityNames.ACCOUNT_TYPE);
	}

	public boolean isHasCardTypes() {
		return isHasEntityInBranch(EntityNames.CARD_TYPE);
	}

	public boolean isHasMerchants() {
		return isHasEntityInBranch(EntityNames.MERCHANT);
	}

	public boolean isHasTerminals() {
		return isHasEntityInBranch(EntityNames.TERMINAL);
	}

	private boolean chkExclude(String entityName){
		if (newApplication.getFlowId() == 1009 &&
			EntityNames.ACCOUNT.equals(entityName) &&
			"CNTPINIC".equals(newApplication.getContractType())) {
			return (true);
		} else {
			return (false);
		}
	}

	public List<SelectItem> formServiceCountList(Integer minCount, Integer maxCount) {
		List<SelectItem> lst = new ArrayList<SelectItem>();
		for (Integer i = minCount; i <= maxCount; i++) {
			SelectItem si = new SelectItem(i.toString(), i.toString());
			lst.add(si);
		}
		if (getNewApplication().getContractNumber() != null &&
				getNewApplication().getContractNumber().trim().length() > 0) {
			if (minCount > 0) {
				lst.add(0, new SelectItem("0", "0"));
			}
		}
		return lst;
	}

	// Card branch is selected
	private void mapContractAccountsWithObjects(String objectEntityType, String objectId) throws Exception {
		if (objectId == null || objectEntityType == null) {
			// Cannot find object
			return;
		}
		// Iterate through contract accounts to change flag
		for (ContractObject accObj : linkAccounts) {
			Map<String, List<ContractObject>> linkedObjectsMap = accountObjects.get(accObj
					.getNumber());
			if (linkedObjectsMap == null) {
				accObj.setChecked(false);
				continue;
			}
			List<ContractObject> linkedObjects = linkedObjectsMap.get(objectEntityType);
			if (linkedObjects == null || linkedObjects.size() == 0) {
				accObj.setChecked(false);
				continue;
			}
			for (ContractObject obj : linkedObjects) {
				if (objectId.equals(obj.getNumber())) {
					boolean isChecked = obj.isChecked();
					accObj.setChecked(isChecked);
					break;
				}
			}
		}
	}

	// Account branch is selected
	private void mapContractObjectsWithAccounts(String entityType, ContractObject[] objects,
	                                            String accountNumber) throws Exception {
		// Find account block for selected account in branch (accountId)

		if (accountNumber == null) {
			return;
		}
		Map<String, List<ContractObject>> accountLinksMap = accountObjects.get(accountNumber);
		if (accountLinksMap == null) {
			return;
		}

		// Block is found. Get its links with cards
		List<ContractObject> accountLinks = accountLinksMap.get(entityType);
		if (accountLinks == null) {
			return;
			// No links are found for a particular entity
		}
		if (accountLinks.size() == 0) {
			for (ContractObject obj : objects) {
				obj.setChecked(false);
			}
		}
		for (ContractObject accObjLink : accountLinks) {
			String objectLinkNumber = accObjLink.getNumber();
			if (objectLinkNumber == null) {
				continue;
			}
			for (ContractObject cardObj : objects) {
				if (objectLinkNumber.equals(cardObj.getNumber())) {
					boolean isChecked = accObjLink.isChecked();
					cardObj.setChecked(isChecked);
					// cardObj.setCheckedOld(isChecked);
					break;
				}
			}
		}
	}

	private ContractObject getAccountsFilter() {
		ContractObject filter = new ContractObject();
		if (newApplication.getProductId() != null) {
			filter.setProductId(newApplication.getProductId());
		}
		if (branchEntity == null) {
			filter.setEntityType(EntityNames.ACCOUNT);
		}
		else if (EntityNames.CARD.equals(branchEntity)) {
			if (branchObjectId == null) {
				return null;
			}
			if (!isNew) {
				filter.setEntityType(EntityNames.CARD);
				filter.setObjectId(branchObjectId);
			}
			else {
				filter.setEntityType(EntityNames.ACCOUNT);
			}
		}
		else if (EntityNames.MERCHANT.equals(branchEntity)) {
			if (branchObjectId == null) {
				return null;
			}
			if (!isNew) {
				filter.setEntityType(EntityNames.MERCHANT);
				filter.setObjectId(branchObjectId);
			}
			else {
				filter.setEntityType(EntityNames.ACCOUNT);
			}
		}
		else if (EntityNames.TERMINAL.equals(branchEntity)) {
			if (branchObjectId == null) {
				return null;
			}
			if (!isNew) {
				filter.setEntityType(EntityNames.TERMINAL);
				filter.setObjectId(branchObjectId);
			}
			else {
				filter.setEntityType(EntityNames.ACCOUNT);
			}
		}
		return (filter);
	}

	public ContractObject[] getContractAccounts() {
		try {
			ContractObject filter = getAccountsFilter();
			if (filter == null) {
				return new ContractObject[0];
			}
			if (isSearchingAccountsWithoutContract()) {
				filter.setCustomerNumber(newApplication.getCustomerNumber());
				accounts = _applicationDao.getCustomerAccounts(userSessionId, filter);
			} else {
				filter.setContractNumber(newApplication.getContractNumber());
				accounts = _applicationDao.getContractAccounts(userSessionId, filter);
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			accounts = new ContractObject[0];
		}
		return accounts;
	}

	public ContractObject[] getToLinkAccounts() {
		try {
			ContractObject filter = getAccountsFilter();
			if (filter == null) {
				return new ContractObject[0];
			}
			if (isSearchingAccountsWithoutContract()) {
				filter.setCustomerNumber(newApplication.getCustomerNumber());
				linkAccounts = _applicationDao.getCustomerAccounts(userSessionId, filter);
			} else {
				filter.setContractNumber(newApplication.getContractNumber());
				linkAccounts = _applicationDao.getContractAccounts(userSessionId, filter);
			}
			if (branchEntity != null && !EntityNames.ACCOUNT.equals(branchEntity)) {
				List<ContractObject> appCards = getNewObjects(EntityNames.ACCOUNT);
				List<ContractObject> temp = new ArrayList<ContractObject>(linkAccounts.length +
						appCards.size());
				temp.addAll(appCards);
				temp.addAll(Arrays.asList(linkAccounts));
				linkAccounts = temp.toArray(new ContractObject[temp.size()]);
			}
			mapContractAccountsWithObjects(branchEntity, branchObjectId);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			linkAccounts = new ContractObject[0];
		}
		return linkAccounts;
	}

	private void filterCbsAccounts() {
		List<String> currencies;
		if (getNewApplication().getProductId() != null && cbsAccountsAll != null && !cbsAccountsAll.isEmpty()) {
			currencies = _productsDao.getAccountProductCurrencies(userSessionId, getNewApplication().getProductId());
			if (currencies == null || currencies.isEmpty()) {
				cbsAccounts = new ContractObject[0];
			} else {
				CurrencyUtils curUtils = (CurrencyUtils) ManagedBeanWrapper.getManagedBean("CurrencyUtils");
				List<ContractObject> list = new ArrayList<ContractObject>(cbsAccountsAll.size());
				for (Account cbsAccount : cbsAccountsAll) {
					if (currencies.contains(curUtils.getCodeMap().get(cbsAccount.getCurrency()))) {
						list.add(new ContractObject(EntityNames.ACCOUNT, cbsAccount.getAccountNumber()));
					}
				}
				cbsAccounts = list.toArray(new ContractObject[0]);
			}
		}

	}

	public ContractObject[] getCbsAccounts() {
		filterCbsAccounts();
		return cbsAccounts;
	}

	public ContractObject[] geteWalletAccounts() {
		return (eWalletAccounts);
	}

	private void processCbsAccounts() {
		cbsAccounts = null;
		cbsAccountsAll = Collections.EMPTY_LIST;
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
		ru.bpc.svap.Customer cbsCustomer = bean.getCbsCustomer();
		// If customer data has been queried from CBS
		if (cbsCustomer != null && !cbsCustomer.getAccount().isEmpty()) {
			// Get accounts already registered in SVBO for this customer (if any)
			ContractObject filter = getAccountsFilter();
			if (filter != null) {
				filter.setCustomerNumber(cbsCustomer.getId());
				ContractObject[] customerAccounts = _applicationDao.getCustomerAccounts(userSessionId, filter);
				cbsAccountsAll = new ArrayList<Account>(cbsCustomer.getAccount().size());
				List<ContractObject> list = new ArrayList<ContractObject>(cbsCustomer.getAccount().size());
				// Iterate CBS accounts to determine which are already registered in SVBO and which are not
				for (Account cbsAccount : cbsCustomer.getAccount()) {
					boolean found = false;
					for (ContractObject svboAccount : customerAccounts) {
						if (cbsAccount.getAccountNumber().equals(svboAccount.getNumber())) {
							found = true;
							break;
						}
					}
					if (!found) {
						// This CBS account is not registered in SVBO, add it to the list of available CBS accounts
						list.add(new ContractObject(EntityNames.ACCOUNT, cbsAccount.getAccountNumber()));
						cbsAccountsAll.add(cbsAccount);
					}
				}
				cbsAccounts = list.toArray(new ContractObject[0]);
			}
		}
	}

	private void processEWalletAccounts() {
		eWalletAccounts = null;
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
		ru.bpc.svap.Customer eWalletCustomer = bean.geteWalletCustomer();

		if (eWalletCustomer != null && !eWalletCustomer.getAccount().isEmpty()) {
			ContractObject filter = getAccountsFilter();
			if (filter != null) {
				filter.setCustomerNumber(eWalletCustomer.getId());
				ContractObject[] customerAccounts = _applicationDao.getCustomerAccounts(userSessionId, filter);
				List<ContractObject> list = new ArrayList<ContractObject>(eWalletCustomer.getAccount().size());
				// Iterate eWallet accounts to determine which are already registered in SVBO and which are not
				for (Account eWalletAcc : eWalletCustomer.getAccount()) {
					boolean found = false;
					for (ContractObject svboAccount : customerAccounts) {
						if (eWalletAcc.getAccountNumber().equals(svboAccount.getNumber())) {
							found = true;
							break;
						}
					}
					if (!found) {
						// This eWallet account is not registered in SVBO, add it to the list of available eWallet accounts
						list.add(new ContractObject(EntityNames.ACCOUNT, eWalletAcc.getAccountNumber()));
					}
				}
				eWalletAccounts = list.toArray(new ContractObject[0]);
			}
		}
	}
	
	public ContractObject[] getContractCards() {
		try {
			ContractObject filter = new ContractObject();
			if (newApplication.getProductId() != null) {
				filter.setProductId(newApplication.getProductId());
			}
			if (branchEntity == null) {
				// In this case we get all cards for the contract
				filter.setEntityType(EntityNames.CARD);
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (branchObjectId == null) {
					return new ContractObject[0];
				}

				if (!isNew) {
					// Account is new - created from initial service
					// In this case we get all cards for the contract, but with links for current
					// account.
					filter.setEntityType(EntityNames.ACCOUNT);
					filter.setObjectId(branchObjectId);
				} else {
					// Account is new - created from initial service
					// In this case we get all cards for the contract.
					filter.setEntityType(EntityNames.CARD);
				}
			}
			if (isSearchingCardsWithoutContract()) {
				filter.setCustomerNumber(newApplication.getCustomerNumber());
				cards = _applicationDao.getCustomerCards(userSessionId, filter);
			} else {
				filter.setContractNumber(newApplication.getContractNumber());
				cards = _applicationDao.getContractCards(userSessionId, filter);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			cards = new ContractObject[0];
		}
		return cards;
	}

	public ContractObject[] getToLinkCards() {
		try {
			ContractObject filter = new ContractObject();
			if (newApplication.getProductId() != null) {
				filter.setProductId(newApplication.getProductId());
			}
			if (branchEntity == null) {
				// In this case we get all cards for the contract
				filter.setEntityType(EntityNames.CARD);
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (branchObjectId == null) {
					return new ContractObject[0];
				}

				if (!isNew) {
					// Account is new - created from initial service
					// In this case we get all cards for the contract, but with links for current
					// account.
					filter.setEntityType(EntityNames.ACCOUNT);
					filter.setObjectId(branchObjectId);
				} else {
					// Account is new - created from initial service
					// In this case we get all cards for the contract.
					filter.setEntityType(EntityNames.CARD);
				}
			}
			if (isSearchingCardsWithoutContract()) {
				filter.setCustomerNumber(newApplication.getCustomerNumber());
				linkCards = _applicationDao.getCustomerCards(userSessionId, filter);
			} else {
				filter.setContractNumber(newApplication.getContractNumber());
				linkCards = _applicationDao.getContractCards(userSessionId, filter);
			}
			if (EntityNames.ACCOUNT.equals(branchEntity)) {
				List<ContractObject> appCards = getNewObjects(EntityNames.CARD);
				List<ContractObject> temp = new ArrayList<ContractObject>(linkCards.length +
						appCards.size());
				temp.addAll(appCards);
				temp.addAll(Arrays.asList(linkCards));
				linkCards = temp.toArray(new ContractObject[temp.size()]);
				mapContractObjectsWithAccounts(EntityNames.CARD, linkCards, branchObjectId);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			linkCards = new ContractObject[0];
		}
		return linkCards;
	}

	public ContractObject[] getContractMerchants() {
		try {
			ContractObject filter = new ContractObject();
			filter.setContractNumber(newApplication.getContractNumber());
			if (newApplication.getProductId() != null) {
				filter.setProductId(newApplication.getProductId());
			}
			if (branchEntity == null) {
				filter.setEntityType(EntityNames.MERCHANT);
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (branchObjectId == null) {
					return new ContractObject[0];
				}
				if (!isNew) {
					// Account is new - created from initial service
					// In this case we get all merchants for the contract, but with links for
					// current account.
					filter.setEntityType(EntityNames.ACCOUNT);
					filter.setObjectId(branchObjectId);
				} else {
					// Account is new - created from initial service
					// In this case we get all merchants for the contract.
					filter.setEntityType(EntityNames.MERCHANT);
				}
			}
			merchants = _applicationDao.getContractMerchants(userSessionId, filter);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			merchants = new ContractObject[0];
		}
		return merchants;
	}

	public ContractObject[] getToLinkMerchants() {
		try {
			ContractObject filter = new ContractObject();
			filter.setContractNumber(newApplication.getContractNumber());
			if (newApplication.getProductId() != null) {
				filter.setProductId(newApplication.getProductId());
			}
			if (branchEntity == null) {
				filter.setEntityType(EntityNames.MERCHANT);
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (branchObjectId == null) {
					return new ContractObject[0];
				}
				if (!isNew) {
					// Account is new - created from initial service
					// In this case we get all merchants for the contract, but with links for
					// current account.
					filter.setEntityType(EntityNames.ACCOUNT);
					filter.setObjectId(branchObjectId);
				} else {
					// Account is new - created from initial service
					// In this case we get all merchants for the contract.
					filter.setEntityType(EntityNames.MERCHANT);
				}
			}
			linkMerchants = _applicationDao.getContractMerchants(userSessionId, filter);
			if (EntityNames.ACCOUNT.equals(branchEntity)) {
				List<ContractObject> appMerch = getNewObjects(EntityNames.MERCHANT);
				List<ContractObject> temp = new ArrayList<ContractObject>(linkMerchants.length +
						appMerch.size());
				temp.addAll(appMerch);
				temp.addAll(Arrays.asList(merchants));
				linkMerchants = temp.toArray(new ContractObject[temp.size()]);
				mapContractObjectsWithAccounts(EntityNames.MERCHANT, linkMerchants, branchObjectId);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			linkMerchants = new ContractObject[0];
		}
		return linkMerchants;
	}

	public ContractObject[] getContractTerminals() {
		try {
			ContractObject filter = new ContractObject();
			filter.setContractNumber(newApplication.getContractNumber());
			if (newApplication.getProductId() != null) {
				filter.setProductId(newApplication.getProductId());
			}
			if (branchEntity == null) {
				filter.setEntityType(EntityNames.TERMINAL);
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (branchObjectId == null) {
					return new ContractObject[0];
				}
				if (!isNew) {
					// Account is new - created from initial service
					// In this case we get all terminals for the contract, but with links for
					// current account.
					filter.setEntityType(EntityNames.ACCOUNT);
					filter.setObjectId(branchObjectId);
				} else {
					// Account is new - created from initial service
					// In this case we get all terminals for the contract.
					filter.setEntityType(EntityNames.TERMINAL);
				}
			}
			terminals = _applicationDao.getContractTerminals(userSessionId, filter);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			terminals = new ContractObject[0];
		}
		return terminals;
	}

	public ContractObject[] getToLinkTerminals() {
		try {
			ContractObject filter = new ContractObject();
			filter.setContractNumber(newApplication.getContractNumber());
			if (newApplication.getProductId() != null) {
				filter.setProductId(newApplication.getProductId());
			}
			if (branchEntity == null) {
				filter.setEntityType(EntityNames.TERMINAL);
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (branchObjectId == null) {
					return new ContractObject[0];
				}
				if (!isNew) {
					// Account is new - created from initial service
					// In this case we get all terminals for the contract, but with links for
					// current account.
					filter.setEntityType(EntityNames.ACCOUNT);
					filter.setObjectId(branchObjectId);
				} else {
					// Account is new - created from initial service
					// In this case we get all terminals for the contract.
					filter.setEntityType(EntityNames.TERMINAL);
				}
			}
			linkTerminals = _applicationDao.getContractTerminals(userSessionId, filter);
			if (EntityNames.ACCOUNT.equals(branchEntity)) {
				List<ContractObject> appMerch = getNewObjects(EntityNames.TERMINAL);
				List<ContractObject> temp = new ArrayList<ContractObject>(linkTerminals.length +
						appMerch.size());
				temp.addAll(appMerch);
				temp.addAll(Arrays.asList(linkTerminals));
				linkTerminals = temp.toArray(new ContractObject[temp.size()]);
				mapContractObjectsWithAccounts(EntityNames.TERMINAL, linkTerminals, branchObjectId);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			linkTerminals = new ContractObject[0];
		}
		return linkTerminals;
	}

	public List<Filter> getProductsFilter() {
		List<Filter> filters = new ArrayList<Filter>();

		Filter filter = new Filter();
		filter.setElement("lang");
		filter.setValue(curLang);
		filters.add(filter);

		if (getNewApplication().getProductId() != null) {
			filter = new Filter();
			filter.setElement("productId");
			filter.setValue(getNewApplication().getProductId().toString());
			filters.add(filter);
		}

		return filters;
	}

	public ProductService[] getProductServices() {
		try {
			List<Filter> filters = getProductsFilter();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			productServices = _productsDao.getProductServicesHier(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			productServices = new ProductService[0];
		}
		return productServices;
	}

	public ProductCardType[] getCardTypes() {
		try {
			List<Filter> filters = getProductsFilter();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			cardTypes = _issuingDao.getProductCardTypes(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			cardTypes = new ProductCardType[0];
		}
		return cardTypes;
	}

	public ProductAccountType[] getAccountTypes() {
		try {
			List<Filter> filters = getProductsFilter();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			accountTypes = _productsDao.getProductAccountTypes(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			accountTypes = new ProductAccountType[0];
		}
		return accountTypes;
	}

	private void loadContractServices() {
		List<ContractObject> selectedServices = null;
		boolean replace = false;
		try {
			loadServicesFromObjects();
			if (services != null) {
				selectedServices = services;
				replace = true;
			}

			ContractObject filter = new ContractObject();
			filter.setInitial(false);
			filter.setContractNumber(newApplication.getContractNumber());
			if (newApplication.getProductId() != null) {
				filter.setProductId(newApplication.getProductId());
			}

			if (EntityNames.CUSTOMER.equals(branchEntity)) {
				if (!isNew) {
					filter.setObjectId(branchObjectId);
				}
			} else {
				if (!isNew) {
					filter.setObjectId(branchObjectId);
				} else {
					if (initialServiceId != null && !"".equals(initialServiceId)) {
						filter.setId(Long.parseLong(initialServiceId));
					}
				}
			}
			if (newApplication != null && newApplication.getFlowId().equals(1006)) {
				filter.setServiceExist(1);
			}

			filter.setEntityType(branchEntity);

			ContractObject[] servicesArr = _applicationDao.getContractServices(userSessionId, filter);
			services = Arrays.asList(servicesArr);
			for (ContractObject service : services) {
				configureActivity(service);
			}
			if (replace) {
				replaceServices(selectedServices);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			services = new ArrayList<ContractObject>(0);
		}
	}

	private void replaceServices(List<ContractObject> selectedServices) {
		for (ContractObject selected : selectedServices) {
			for (ContractObject service : services) {
				if (service.getNumber().equalsIgnoreCase(selected.getNumber()) && (
						(service.getContractNumber() == null && selected.getContractNumber() == null) ||
								(service.getContractNumber() != null && service.getContractNumber().equalsIgnoreCase(selected.getContractNumber())))) {
					service.setChecked(selected.isChecked());
					service.setCheckedOld(selected.isCheckedOld());
					service.setEdit(selected.isEdit());
				}
			}
		}
	}

	public void loadServicesFromObjects() {
		Map<String, List<ContractObject>> objectLinks = null;
		if (EntityNames.CUSTOMER.equals(branchEntity)) {
			objectLinks = merchantObjects.get(branchObjectId);
		} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
			objectLinks = accountObjects.get(branchObjectId);
		} else if (EntityNames.CARD.equals(branchEntity)) {
			objectLinks = cardObjects.get(branchObjectId);
		} else if (EntityNames.MERCHANT.equals(branchEntity)) {
			objectLinks = merchantObjects.get(branchObjectId);
		} else if (EntityNames.TERMINAL.equals(branchEntity)) {
			objectLinks = terminalObjects.get(branchObjectId);
		}
		if (objectLinks != null) {
			List<ContractObject> linkedServices = objectLinks.get(EntityNames.SERVICE);
			if (linkedServices != null && !linkedServices.isEmpty()) {
				services = TreeUtils.fillTree(linkedServices);
			}
		}
	}

	public List<ContractObject> getServiceNodeChildren() {
		ContractObject node = getServiceNodeVar();
		if (node == null) {
			if (services == null) {
				loadContractServices();
			}

			return services;
		} else {
			return node.getChildren();
		}
	}

	public boolean getServiceNodeHasChildren() {
		ContractObject node = getServiceNodeVar();
		return node.getChildren() != null && !node.getChildren().isEmpty();
	}

	private ContractObject getServiceNodeVar() {
		return (ContractObject) Faces.var("serviceNode");
	}

	public void changeServiceActivity() {
		ContractObject setlectedService = getServiceNodeVar();
		configureActivity(setlectedService);
	}

	public void configureChildrenActivity(ContractObject root) {
		boolean active = root.isChecked();
		List<ContractObject> children = root.getChildren();
		for (ContractObject child : children) {
			if (!active) {
				child.setChecked(false);
				child.setEdit(false);
			}
			child.setDisabled(!active);
			if (child.getChildren().size() != 0) {
				configureChildrenActivity(child);
			}
		}
	}

	public void configureActivity(ContractObject root) {
		boolean active = root.isChecked();
		if (!root.isCheckedOld()) {
			root.setEdit(active);
		}
		configureChildrenActivity(root);
	}

	public List<SelectItem> getServiceCountList() {
		ProductService currentService = (ProductService) Faces.var("service");
		int minCount = 0;
		int maxCount = 0;
		int avalCount = 0;
		if (currentService.getMinCount() != null) {
			minCount = currentService.getMinCount();
		}
		if (currentService.getMaxCount() != null) {
			maxCount = currentService.getMaxCount();
		}
		if (currentService.getAvalCount() != null) {
			avalCount = currentService.getAvalCount();
		}
		return formServiceCountList(Math.max(0, minCount - maxCount + avalCount), avalCount);
	}

	private ContractObject makeContractObjectFromService(ProductService service) {
		ContractObject obj = new ContractObject();
		obj.setEntityType(service.getEntityType());
		obj.setInitial(service.getId() == null ? true : false);
		obj.setObjectId(service.getServiceId() == null ? null : service.getServiceId().toString());
		obj.setProductId(service.getProductId());
		obj.setProduct(service.getProductNumber());
		obj.setMinCount(service.getMinCount().shortValue());
		obj.setMaxCount(service.getMaxCount().shortValue());
		obj.setChecked(service.isChecked());
		obj.setCheckedOld(service.isCheckedOld());
		obj.setNumber(service.getServiceNumber());
		obj.setContractType(getNewApplication().getContractType());
		return obj;
	}

	public List<ContractObject> getNewObjects(String entityType) throws Exception {
		List<ProductService> initServsLst = initialServices.get(entityType);
		List<ContractObject> newObjects = new ArrayList<ContractObject>();
		if (initServsLst == null) {
			return newObjects;
		}
		int j = 0;
		int k = 0;
		for (ProductService service : initServsLst) {
			int val = ((service.getCurrentCount() == null) ? 0 : service.getCurrentCount());
			for (int i = 0; i < val; i++) {
				j++;
				ContractObject obj = new ContractObject();
				obj.setEntityType(entityType);
				obj.setNumber(getDictUtils().getAllArticlesDesc().get(entityType) + " " + j);
				//XXX: If a new account from CBS has been selected, use its number
				if (cbsAccounts != null && EntityNames.ACCOUNT.equals(entityType) && k < cbsAccounts.length) {
					//XXX: Look for the next selected CBS account
					for (int i1 = k; i1 < cbsAccounts.length; i1++) {
					    if (cbsAccounts[i1].isChecked()) {
						    obj.setNumber(cbsAccounts[i1].getNumber());
						    k = i1 + 1;
						    break;
					    }
					}
				}
				//XXX: If a new account from eWallet has been selected, use its number
				if (eWalletAccounts != null && EntityNames.ACCOUNT.equals(entityType) && k < eWalletAccounts.length) {
					//XXX: Look for the next selected eWallet account
					for (int i1 = k; i1 < eWalletAccounts.length; i1++) {
						if (eWalletAccounts[i1].isChecked()) {
							obj.setNumber(eWalletAccounts[i1].getNumber());
							k = i1 + 1;
							break;
						}
					}
				}

				obj.setInitial(true);
				if (service.getServiceId() != null) {
					obj.setObjectId(service.getServiceId().toString());
				}
				newObjects.add(obj);
				// TODO fill object and link with initial services
			}
		}

		return newObjects;
	}

	public List<ContractObject> getObjects(String entityType) throws Exception {
		if (EntityNames.ACCOUNT.equals(entityType)) {
			return (accounts != null) ? Arrays.asList(accounts) : new ArrayList<ContractObject>();
		} else if (EntityNames.CARD.equals(entityType)) {
			return (cards != null) ? Arrays.asList(cards) : new ArrayList<ContractObject>();
		} else if (EntityNames.MERCHANT.equals(entityType)) {
			return (merchants != null) ? Arrays.asList(merchants) : new ArrayList<ContractObject>();
		} else if (EntityNames.TERMINAL.equals(entityType)) {
			return (terminals != null) ? Arrays.asList(terminals) : new ArrayList<ContractObject>();
		}
		return new ArrayList<ContractObject>();
	}

	public List<ContractObject> getSelectedObjects(String entityType) throws Exception {
		if (EntityNames.ACCOUNT.equals(entityType)) {
			if(selectedAccounts == null)
				selectedAccounts = new ArrayList<ContractObject>();
			return selectedAccounts;
		} else if (EntityNames.CARD.equals(entityType)) {
			if(selectedCards == null)
				selectedCards = new ArrayList<ContractObject>();
			return selectedCards;
		} else if (EntityNames.MERCHANT.equals(entityType)) {
			if (selectedMerchants == null)
				selectedMerchants = new ArrayList<ContractObject>();
			return selectedMerchants;
		} else if (EntityNames.TERMINAL.equals(entityType)) {
			if (selectedTerminals == null)
				selectedTerminals = new ArrayList<ContractObject>();
			return selectedTerminals;
		}
		return null;
	}

	private void setSelectedObjects(String entityType) throws Exception {
		List<ContractObject> selectedObjects = getSelectedObjects(entityType);
		List<ContractObject> objects = getObjects(entityType);
		List<ContractObject> newObjects = getNewObjects(entityType);

		for (ContractObject obj : newObjects) {
			obj.setEntityType(entityType);
			selectedObjects.add(obj);
		}
		for (ContractObject obj : objects) {
			if (obj.isChecked()) {
				obj.setEntityType(entityType);
				selectedObjects.add(obj);
			}
		}
	}

	private void setSelectedAccounts() throws Exception {
		setSelectedObjects(EntityNames.ACCOUNT);
	}

	private void setSelectedCards() throws Exception {
		setSelectedObjects(EntityNames.CARD);
	}

	private void setSelectedMerchants() throws Exception {
		setSelectedObjects(EntityNames.MERCHANT);
	}

	private void setSelectedTerminals() throws Exception {
		setSelectedObjects(EntityNames.TERMINAL);
	}

	private void setSelectedServices() throws Exception {
		selectedProductServices = new ArrayList<ProductService>();
		List<ContractObject> newServices = getNewObjects(EntityNames.SERVICE);
		for (ContractObject serv : newServices) {
			ProductService ins = new ProductService();
			ins.setEntityType(EntityNames.SERVICE);
			selectedProductServices.add(ins);
		}
		if (productServices != null) {
			for (ProductService serv : productServices) {
				if (serv.isChecked()) {
					selectedProductServices.add(serv);
				}
			}
		}
	}

	private void setSelectedCardTypes() throws Exception {
		selectedCardTypes = new ArrayList<ProductCardType>();
		List<ContractObject> newCardTypes = getNewObjects(EntityNames.CARD_TYPE);
		for (ContractObject newCrdt : newCardTypes) {
			ProductCardType ins = new ProductCardType();
			ins.setEntityType(EntityNames.CARD_TYPE);
			selectedCardTypes.add(ins);
		}
		if (cardTypes != null) {
			for (ProductCardType crdt : cardTypes) {
				if (crdt.isChecked()) {
					selectedCardTypes.add(crdt);
				}
			}
		}
	}

	private void setSelectedAccountTypes() throws Exception {
		selectedAccountTypes = new ArrayList<ProductAccountType>();
		List<ContractObject> newAccountTypes = getNewObjects(EntityNames.ACCOUNT_TYPE);
		for (ContractObject newAcct : newAccountTypes) {
			ProductAccountType ins = new ProductAccountType();
			ins.setEntityType(EntityNames.ACCOUNT_TYPE);
			selectedAccountTypes.add(ins);
		}
		if (accountTypes != null) {
			for (ProductAccountType acct : accountTypes) {
				if (acct.isChecked()) {
					selectedAccountTypes.add(acct);
				}
			}
		}
	}

	private void setSelectedProductData() throws Exception {
		if (getNewApplication().getProductId() != null) {
			Product product = _productsDao.getProductById(userSessionId, getNewApplication().getProductId(), getUserLang());
			getNewApplication().setProductName(product.getName());
			getNewApplication().setProductType(product.getProductType());
			getNewApplication().setProductStatus(product.getStatus());
			getNewApplication().setProductNumber(product.getProductNumber());
			if (product.getParentId() != null) {
				getNewApplication().setProductParentId(product.getParentId().intValue());
			}
		}
	}

	private ContractObject[] updateLinks(ContractObject[] links, List<ContractObject> source) {
		if(source == null || source.isEmpty()) {
			return new ContractObject[0];
		}
		List<ContractObject> newLinks = new ArrayList<ContractObject>();
		List<ContractObject> oldLinks = links != null ? Arrays.asList(links) : Collections.EMPTY_LIST;
		for (ContractObject object : source) {
			int i = oldLinks.indexOf(object);
			if(i >= 0) {
				newLinks.add(oldLinks.get(i));
			} else {
				newLinks.add(object);
			}
		}
		return newLinks.toArray(new ContractObject[newLinks.size()]);
	}

	private void updateObjects(Map<String, Map<String, List<ContractObject>>> objects, ContractObject[] links) {
		if(links == null || links.length == 0) {
			objects.clear();
			return;
		}
		for (Iterator<Map.Entry<String, Map<String, List<ContractObject>>>> it = objects.entrySet().iterator(); it.hasNext();) {
			Map.Entry<String, Map<String, List<ContractObject>>> entry = it.next();
			boolean found = false;
			for(int i = 0; i < links.length; ++i) {
				if(entry.getKey().equals(links[i].getNumber())) {
					found = true;
				}
			}
			if (!found) {
				it.remove();
			}
		}
	}

	int i = 0;
	ContractObject currentObject;

	public void next() {
		if (!checkServices(services)) {
			return;
		}
		parentMerchants.clear();
		int current = 0;
		try {
			saveCurrent();
			displayWizardPage = false; // we need to find an object that has services
			displayFinishButton = false;
			while (true) {
				services = null;
				parentMerchantId = null;
				i++;
				selectObject(i);
				loadContractServices();
				boolean linksPresented = ((isHasCards() || isHasMerchants() || isHasTerminals()) && EntityNames.ACCOUNT.equals(branchEntity))
									   || (isHasAccounts() && (EntityNames.CARD.equals(branchEntity) || EntityNames.MERCHANT.equals(branchEntity) || EntityNames.TERMINAL.equals(branchEntity)));
				if (services != null && services.size() > 0 || linksPresented) {
					if (!displayWizardPage) {
						displayWizardPage = true;
						current = i;
					} else {
						break;
					}
				}
				if (i == selectedObjects.size() - 1) {
					if (!displayWizardPage) {
						closeWizard = true;
					}
					displayFinishButton = true;
					break;
				}
			}
			if(displayWizardPage) {
				selectObject(current);
				loadContractServices();
				i = current;
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String finish() {
		if (!checkServices(services)) {
			return "";
		}
		try {
			if (selectedObjects != null && selectedObjects.size() > 0) {
				saveCurrent();
			}
			if (isAcquiringType()) {
				setMerchantsLevels(0, getTreeNode());
			}
			Collections.sort(finalObjects);
			finishWizard();
			return "applications|edit";
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return "";
	}

	public void back() {
		parentMerchants.clear();
		try {
			saveCurrent();
			displayWizardPage = false;
			while (!displayWizardPage) {
				services = null;
				parentMerchantId = null;
				i--;
				if (i >= 0) {
					selectObject(i);
					loadContractServices();
					boolean linksPresented = ((isHasCards() || isHasMerchants() || isHasTerminals()) && EntityNames.ACCOUNT.equals(branchEntity)) ||
							(isHasAccounts() && (EntityNames.CARD.equals(branchEntity) || EntityNames.MERCHANT.equals(branchEntity) || EntityNames.TERMINAL.equals(branchEntity)));
					if (services != null && services.size() > 0) {
						displayWizardPage = true;
					} else if (linksPresented) {
						displayWizardPage = true;
					} else if (i == selectedObjects.size() - 1) {
						closeWizard = true;
						return;
					}
				} else{
					branchEntity = null;
					branchObjectId = null;
					displayWizardPage = true;
				}
			}
			services = null;
			parentMerchantId = null;
			displayFinishButton = false;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isHasNextInWizard() {
		return selectedObjects != null && (i < selectedObjects.size() - 1);
	}

	public boolean isHasSelectedObjects() {
		return selectedObjects != null && (selectedObjects.size() > 0);
	}

	public boolean isHasBackInWizard() {
		return (i >= 0);
	}

	private void selectObject(int i) {
		currentObject = selectedObjects.get(i);
		branchEntity = currentObject.getEntityType();
		branchObjectId = currentObject.getNumber();
		objectNumberMask = currentObject.getMask();
		isNew = currentObject.isInitial();
		if (isNew) {
			initialServiceId = currentObject.getObjectId();
		} else {
			initialServiceId = null;
		}
	}

	public void applySelectObjects() {
		if (newContract) {
			getNewApplication().setContractNumber("");
			if (newCustomer) {
				getNewApplication().setCustomerNumber("");
			}
		}
		try {
			if (selectedObjects == null) {
				selectedObjects = new ArrayList<ContractObject>();
			} else {
				selectedObjects.clear();
			}
			if(selectedAccounts != null) {
				selectedAccounts.clear();
			}
			if(selectedCards != null) {
				selectedCards.clear();
			}
			if(selectedMerchants != null) {
				selectedMerchants.clear();
			}
			if(selectedTerminals != null) {
				selectedTerminals.clear();
			}
			if (getNewApplication().getCustomerNumber() == null || getNewApplication().getCustomerNumber().equals("")) {
				// if this is a new customer
				ContractObject customerObject = new ContractObject(EntityNames.CUSTOMER, getNewApplication().getCustomerNumber(), true);
				selectedObjects.add(customerObject);
			} else {
				// customer main contract is selected in contract field
				ContractObject customerObject = new ContractObject(EntityNames.CUSTOMER, getNewApplication().getCustomerNumber());
				selectedObjects.add(customerObject);
			}

			ContractObject contractObject = new ContractObject(EntityNames.CONTRACT, getNewApplication().getContractNumber());
			selectedObjects.add(contractObject);

			if (isHasAccounts()) {
				setSelectedAccounts();
				if (selectedAccounts != null) {
					selectedObjects.addAll(selectedAccounts);
				}
			}
			linkAccounts = updateLinks(linkAccounts, selectedAccounts);
			updateObjects(accountObjects, linkAccounts);
			if (isHasCards()) {
				setSelectedCards();
				if (selectedCards != null) {
					selectedObjects.addAll(selectedCards);
				}
			}
			linkCards = updateLinks(linkCards, selectedCards);
			updateObjects(cardObjects, linkCards);
			if (isHasMerchants()) {
				setSelectedMerchants();
				if (selectedMerchants != null) {
					selectedObjects.addAll(selectedMerchants);
				}
			}
			linkMerchants = updateLinks(linkMerchants, selectedMerchants);
			updateObjects(merchantObjects, linkMerchants);
			if (isHasTerminals()) {
				setSelectedTerminals();
				if (selectedTerminals != null) {
					selectedObjects.addAll(selectedTerminals);
				}
			}
			linkTerminals = updateLinks(linkTerminals, selectedTerminals);
			updateObjects(terminalObjects, linkTerminals);
			finalObjects.clear();
			if (isHasServices()) {
				setSelectedServices();
			}
			if (isHasCardTypes()) {
				setSelectedCardTypes();
			}
			if (isHasAccountTypes()) {
				setSelectedAccountTypes();
			}
			if (isProductType()) {
				setSelectedProductData();
			}
			if (!isNewCustomer() || !isCustomerCompany()) {
				newApplication.setExtCustomerType(null);
				newApplication.setExtObjectId(null);
			}
			if (isNewProduct()) {
				closeWizard = true;
			}

			i = -1;
			next();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cleanSelectObjects() {
		if (selectedObjects != null) {
			selectedObjects.clear();
			selectedObjects = null;
		}
		if (services != null) {
			services.clear();
			services = null;
		}
		branchEntity = null;
	}

	public ContractObject getCurrentObject() {
		return currentObject;
	}

	public List<ContractObject> getSelectedObjects() {
		return selectedObjects;
	}

	public boolean checkServices(List<ContractObject> services) {
		boolean result = true;
		if (services != null && branchEntity != null) {
			for (ContractObject object : services) {
				if (object.isHasChildren()) {
					int count = 0;
					for (ContractObject child : object.getChildren()) {
						if (child.isChecked()) {
							count++;
						}
					}
					try {
						result = _productsDao.checkConditionalService(userSessionId, newApplication.getProductId(), object.getId(), count);
					} catch (Exception e) {
						FacesUtils.addMessageError(e.getMessage());
					}
					if (result) {
						result = checkServices(object.getChildren());
					} else {
						String group = null;
						try {
							group = _productsDao.getConditionalGroup(userSessionId, newApplication.getProductId(), object.getId());
						} catch (Exception e) {}
						if (ProductConstants.CONDITIONAL_GROUP_MANY.equals(group)) {
							FacesUtils.addMessageError("Service '" + object.getLabel() + "' should contain at least one service from group");
						} else if (ProductConstants.CONDITIONAL_GROUP_ONE.equals(group)) {
							FacesUtils.addMessageError("Service '" + object.getLabel() + "' should contain strictly one service from group");
						} else if (ProductConstants.CONDITIONAL_GROUP_NOMO.equals(group)) {
							FacesUtils.addMessageError("Service '" + object.getLabel() + "' should contain not more than one service from group");
						} else {
							FacesUtils.addMessageError("Services group condition is violated in service '" + object.getLabel() + "'");
						}
					}
				}
			}
		}
		return result;
	}

	private void saveCurrent() throws Exception {
		if (branchObjectId == null || branchEntity == null) {
			return;
		}
		Map<String, List<ContractObject>> objectLinks = null;

		if (EntityNames.ACCOUNT.equals(branchEntity)) {
			objectLinks = accountObjects.get(branchObjectId);
			if (objectLinks == null) {
				objectLinks = new HashMap<String, List<ContractObject>>();
				accountObjects.put(branchObjectId, objectLinks);
			}
		} else if (EntityNames.CARD.equals(branchEntity)) {
			objectLinks = cardObjects.get(branchObjectId);
			if (objectLinks == null) {
				objectLinks = new HashMap<String, List<ContractObject>>();
				cardObjects.put(branchObjectId, objectLinks);
			}
		} else if (EntityNames.TERMINAL.equals(branchEntity)) {
			objectLinks = terminalObjects.get(branchObjectId);
			if (objectLinks == null) {
				objectLinks = new HashMap<String, List<ContractObject>>();
				terminalObjects.put(branchObjectId, objectLinks);
			}
		} else if (EntityNames.MERCHANT.equals(branchEntity)) {
			objectLinks = merchantObjects.get(branchObjectId);
			if (objectLinks == null) {
				objectLinks = new HashMap<String, List<ContractObject>>();
				merchantObjects.put(branchObjectId, objectLinks);
			}
		} else if (EntityNames.CUSTOMER.equals(branchEntity)) {
			objectLinks = customerObjects.get(branchObjectId);
			if (objectLinks == null) {
				objectLinks = new HashMap<String, List<ContractObject>>();
				customerObjects.put(branchObjectId, objectLinks);
			}
		} else if (EntityNames.CONTRACT.equals(branchEntity)) {
			objectLinks = contractObjects.get(branchObjectId);
			if (objectLinks == null) {
				objectLinks = new HashMap<String, List<ContractObject>>();
				contractObjects.put(branchObjectId, objectLinks);
			}
		}
		ContractObject obj = new ContractObject(branchEntity, branchObjectId, objectNumberMask, isNew);
		int index = finalObjects.indexOf(obj);
		if (index < 0) {
			finalObjects.add(obj);
		} else {
			obj = finalObjects.get(index);

		}

		if (isNew) {
			if (EntityNames.MERCHANT.equals(branchEntity) ||
					EntityNames.TERMINAL.equals(branchEntity)) {
				obj.setParentNumber(parentMerchantId);
			}
		}
		List<ContractObject> servicesList = new ArrayList<ContractObject>();
		flatTree(services, servicesList);
		setLinkedObjects(branchObjectId, branchEntity, objectLinks, EntityNames.SERVICE,
				servicesList.toArray(new ContractObject[servicesList.size()]));
		setLinkedObjects(branchObjectId, branchEntity, objectLinks, EntityNames.ACCOUNT, linkAccounts);
		setLinkedObjects(branchObjectId, branchEntity, objectLinks, EntityNames.CARD, linkCards);
		setLinkedObjects(branchObjectId, branchEntity, objectLinks, EntityNames.MERCHANT, linkMerchants);
		setLinkedObjects(branchObjectId, branchEntity, objectLinks, EntityNames.TERMINAL, linkTerminals);
	}

	private void flatTree(List<ContractObject> roots, List<ContractObject> flat) {
		for (ContractObject node : roots) {
			flat.add(node);
			if (node.isHasChildren()) {
				List<ContractObject> children = node.getChildren();
				flatTree(children, flat);
			}
		}
	}

	private void setLinkedObjects(String objectId, String objectEntity,
	                              Map<String, List<ContractObject>> objectLinks, String entityType,
	                              ContractObject[] objects) throws Exception {

		if (objects == null) {
			return;
		}
		List<ContractObject> linkedObjects = objectLinks.get(entityType);
		if (linkedObjects == null) {
			linkedObjects = new ArrayList<ContractObject>();
		} else {
			linkedObjects.clear();
		}

		for (ContractObject obj : objects) {
			if (obj.isChecked()) {
				obj.setEntityType(entityType);
				if (obj.isChecked() == obj.isCheckedOld() && !obj.isEdit()) {
					if (EntityNames.ACCOUNT.equals(entityType)) {
						Map<String, List<ContractObject>> accountLinksMap = accountObjects.get(obj
								.getNumber());
						if (accountLinksMap == null) {
							accountLinksMap = new HashMap<String, List<ContractObject>>();
							accountObjects.put(obj.getNumber(), accountLinksMap);
						}
						List<ContractObject> accountLinks = accountLinksMap.get(objectEntity);
						if (accountLinks == null) {
							accountLinks = new ArrayList<ContractObject>();
							accountLinksMap.put(objectEntity, accountLinks);
						}
						int i = 0;
						for (ContractObject accLinkObj : accountLinks) {
							if (objectId.equals(accLinkObj.getNumber())) {
								accountLinks.remove(i);
								break;
							}
							i++;
						}
					} else if (EntityNames.CARD.equals(entityType)) {
						if (obj.isChecked() == false && obj.isCheckedOld() == false) {
							continue;
						}
					} else {
						continue;
					}
				}
				linkedObjects.add(obj);
				if (!finalObjects.contains(obj)) {
					finalObjects.add(obj);
				}
			}
			if (EntityNames.ACCOUNT.equals(entityType)) {
				Map<String, List<ContractObject>> accountLinksMap = accountObjects.get(obj
						.getNumber());
				if (accountLinksMap == null) {
					accountLinksMap = new HashMap<String, List<ContractObject>>();
					accountObjects.put(obj.getNumber(), accountLinksMap);
				}
				List<ContractObject> accountLinks = accountLinksMap.get(objectEntity);
				if (accountLinks == null) {
					accountLinks = new ArrayList<ContractObject>();
					accountLinksMap.put(objectEntity, accountLinks);
				}
				boolean found = false;
				for (ContractObject accLinkObj : accountLinks) {
					if (objectId.equals(accLinkObj.getNumber())) {
						accLinkObj.setChecked(obj.isChecked());
						found = true;
						break;
					}
				}
				if (!found) {
					ContractObject objTmp = new ContractObject();
					objTmp.setObjectId(obj.getNumber());
					objTmp.setNumber(objectId);
					objTmp.setChecked(obj.isChecked());
					objTmp.setCheckedOld(obj.isCheckedOld());
					objTmp.setEntityType(objectEntity);
					accountLinks.add(objTmp);
				}
			}
		}
		objectLinks.put(entityType, linkedObjects);
	}

	public void flush() {
		i = 0;
		if (getNewApplication().getCustomerNumber() == null ||
				getNewApplication().getCustomerNumber().equals("")) {
			customerMainContract = null;
		}
		contractTypeDescription = null;
		customerTypeDescription = null;
		branchEntity = null;
		branchObjectId = null;
		initialServiceId = null;
		customerObjects = null;
		contractObjects = null;
		accountObjects = null;
		cardObjects = null;
		merchantObjects = null;
		terminalObjects = null;
		selectedCards = null;
		selectedAccounts = null;
		selectedMerchants = null;
		selectedTerminals = null;
		branchTypes = null;
		initialServices = null;
		finalObjects = null;
		rootNode = null;
		customerObjects = new HashMap<String, Map<String, List<ContractObject>>>();
		contractObjects = new HashMap<String, Map<String, List<ContractObject>>>();
		accountObjects = new HashMap<String, Map<String, List<ContractObject>>>();
		cardObjects = new HashMap<String, Map<String, List<ContractObject>>>();
		merchantObjects = new HashMap<String, Map<String, List<ContractObject>>>();
		terminalObjects = new HashMap<String, Map<String, List<ContractObject>>>();
		finalObjects = new ArrayList<ContractObject>();

		disableInst = false;
		disableAgent = false;
		disableCustomer = false;
		disableContract = false;
		disableAppFlow = false;
	}

	public String getBranchEntity() {
		return branchEntity;
	}

	public void setBranchEntity(String branchEntity) {
		this.branchEntity = branchEntity;
	}

	public String getBranchObjectId() {
		return branchObjectId;
	}

	public void setBranchObjectId(String branchObjectId) {
		this.branchObjectId = branchObjectId;
	}

	public void finishWizard() throws Exception {
		for (ContractObject obj : selectedObjects) {
			Map<String, List<ContractObject>> objectLinks = null;
			String objEntity = obj.getEntityType();
			logger.trace(objEntity + " " + obj.getMaskedNumber());
			if (EntityNames.ACCOUNT.equals(objEntity)) {
				objectLinks = accountObjects.get(obj.getNumber());
				if (objectLinks == null) {
					objectLinks = new HashMap<String, List<ContractObject>>();
				}

			} else if (EntityNames.CARD.equals(objEntity)) {
				objectLinks = cardObjects.get(obj.getNumber());
				if (objectLinks == null) {
					objectLinks = new HashMap<String, List<ContractObject>>();
				}

			} else if (EntityNames.TERMINAL.equals(objEntity)) {
				objectLinks = terminalObjects.get(obj.getNumber());
				if (objectLinks == null) {
					objectLinks = new HashMap<String, List<ContractObject>>();
				}

			} else if (EntityNames.MERCHANT.equals(objEntity)) {
				objectLinks = merchantObjects.get(obj.getNumber());
				if (objectLinks == null) {
					objectLinks = new HashMap<String, List<ContractObject>>();
				}
			} else if (EntityNames.CUSTOMER.equals(objEntity)) {
				objectLinks = customerObjects.get(obj.getNumber());
				if (objectLinks == null) {
					objectLinks = new HashMap<String, List<ContractObject>>();
				}
			} else if (EntityNames.CONTRACT.equals(objEntity)) {
				objectLinks = contractObjects.get(obj.getNumber());
				if (objectLinks == null) {
					objectLinks = new HashMap<String, List<ContractObject>>();
				}
			}

			for (String entity : objectLinks.keySet()) {
				List<ContractObject> linkedObjects = objectLinks.get(entity);
				if (linkedObjects == null) {
					continue;
				}
				for (ContractObject linked : linkedObjects) {
					String msg = "Linked with " + entity + " " + linked.getMaskedNumber() +
							"; checked = " + linked.isChecked();
					logger.trace(objEntity + " " + obj.getMaskedNumber() + ": " + msg);
				}
			}
			logger.trace("----------------");
		}
		MbApplication appBean = (MbApplication) ManagedBeanWrapper.getManagedBean("MbApplication");

		newApplication.setId(null);

		appBean.setActiveApp(newApplication);
		appBean.setModule(module);
		appBean.setCurMode(MbApplication.NEW_MODE);
		appBean.setBackLink(thisBackLink);
		appBean.saveProductObjects(selectedProductServices,
								   selectedCardTypes,
								   selectedAccountTypes);
		appBean.getApplicationForEdit();
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
		appBean.saveObjects(finalObjects,
							accountObjects,
							cardObjects,
							merchantObjects,
							terminalObjects,
							customerObjects,
							contractObjects);
		appBean.fillTree();

		if (isIssuingType() && isCbsSyncEnabled()) {
			MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
			ru.bpc.svap.Customer cbsCustomer = bean.getCbsCustomer();
			if (cbsCustomer != null) {
				appBean.fillCbsData(cbsCustomer);
			}
		}
		if (isIssuingType() && iseWalletSyncEnabled()) {
			MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
			ru.bpc.svap.Customer eWalletCustomer = bean.geteWalletCustomer();
			if (eWalletCustomer != null) {
				appBean.fillEWalletData(eWalletCustomer);
			}
		}
	}

	public void setThisBackLink(String backLink) {
		thisBackLink = backLink;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public boolean isRenderParentMerchant() {
		if (newApplication == null) {
			return false;
		}
		if (EntityNames.MERCHANT.equals(branchEntity) || EntityNames.TERMINAL.equals(branchEntity)) {
			if (branchObjectId != null) {
				if (isNew && !getMerchant().isEmpty()) {
					return true;
				}
			}
		}
		return false;
	}

	public boolean isParentMerchantRequired() {
		if (newApplication == null) {
			return false;
		}
		if (EntityNames.TERMINAL.equals(branchEntity)) {
			if (branchObjectId != null) {
				if (isNew) {
					return true;
				}
			}
		}
		return false;
	}

	private boolean possibleToContain(String childNumber, String parentNumber, List<ContractObject> binds) {
		for (ContractObject co : binds) {
			if (parentNumber.equals(co.getNumber())) {
				if (co.getParentNumber() != null) {
					return !co.getParentNumber().equals(childNumber) && possibleToContain(childNumber, co.getParentNumber(), binds);
				}
			}
		}
		return true;
	}

	public List<SelectItem> getBranchMerchants() {
		List<ContractObject> appMerchants;
		List<SelectItem> appMerchantsItems = null;
		if (newApplication == null || newApplication.isIssuing() || finalObjects == null) {
			return new ArrayList<SelectItem>(0);
		}
		try {
			appMerchantsItems = new ArrayList<SelectItem>();
			appMerchants = getNewMerchants();

			List<ContractObject> savedMerchants = new ArrayList<ContractObject>();
			for (ContractObject co : finalObjects) {
				if (EntityNames.MERCHANT.equals(co.getEntityType())) {
					savedMerchants.add(co);
				}
			}

			for (ContractObject merchant : appMerchants) {
				// We have to separate new merchants (that are without number) from existing
				// merchants in contract
				// so, we add dataId in key value
				boolean possibleToAdd;
				possibleToAdd = possibleToContain(currentObject.getNumber(), merchant.getNumber(), savedMerchants);
				if (currentObject.getNumber().equals(merchant.getNumber())) {
					possibleToAdd = false;
				}


				if (possibleToAdd) {
					appMerchantsItems
							.add(new SelectItem(merchant.getNumber(), merchant.getNumber()));
				}
			}

			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (newApplication.getContractNumber() != null &&
					!newApplication.getContractNumber().equals("")) {
				paramMap.put("CONTRACT_NUMBER", newApplication.getContractNumber());
				List<SelectItem> items = getDictUtils().getLov(LovConstants.APP_BRANCH_MERCHANTS,
						paramMap);
				if (items != null && items.size() > 0) {
					appMerchantsItems.addAll(0, items);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (appMerchantsItems == null) {
				appMerchantsItems = new ArrayList<SelectItem>();
			}
		}

		return appMerchantsItems;
	}

	public String getParentMerchantId() {
		return parentMerchantId;
	}

	public void setParentMerchantId(String parentMerchantId) {
		this.parentMerchantId = parentMerchantId;
	}

	private List<ContractObject> getNewMerchants() {
		List<ContractObject> newMerchants = new ArrayList<ContractObject>();
		if (selectedMerchants != null) {
			for (ContractObject obj : selectedMerchants) {
				if (obj.isInitial()) {
					newMerchants.add(obj);
				}
			}
		}
		return newMerchants;
	}

	private TreeNodeImpl<TreeItemImpl> rootNode = null;

	public class TreeItemImpl {
		private String type;
		private String data;
		public static final String ROOT_TYPE = "root";

		public String getType() {
			return type;
		}

		public void setType(String type) {
			this.type = type;
		}

		public String getData() {
			return data;
		}

		public void setData(String data) {
			this.data = data;
		}

	}

	private void loadTree() {
		try {
			int counter = 1;
			rootNode = new TreeNodeImpl<TreeItemImpl>();
			TreeNodeImpl<TreeItemImpl> customerNode = new TreeNodeImpl<TreeItemImpl>();
			TreeItemImpl dataCustomer = new TreeItemImpl();
			dataCustomer.setData("CUSTOMER");
			dataCustomer.setType(TreeItemImpl.ROOT_TYPE);
			customerNode.setData(dataCustomer);
			rootNode.addChild(counter, customerNode);

			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (newApplication.getContractNumber() != null &&
					!newApplication.getContractNumber().equals("")) {
				paramMap.put("CONTRACT_NUMBER", newApplication.getContractNumber());
				List<SelectItem> items = getDictUtils().getLov(LovConstants.APP_BRANCH_MERCHANTS,
						paramMap);
				for (SelectItem item : items) {
					if (item.getValue() == null) {
						continue;
					}
					TreeNodeImpl<TreeItemImpl> merchNode = new TreeNodeImpl<TreeItemImpl>();
					TreeItemImpl data = new TreeItemImpl();
					data.setData((String) item.getValue());
					data.setType("existing");
					merchNode.setParent(customerNode);
					merchNode.setData(data);
					counter++;
					customerNode.addChild(counter, merchNode);
				}
			}
			List<ContractObject> newMerchants = getNewMerchants();
			for (ContractObject merch : newMerchants) {
				TreeNodeImpl<TreeItemImpl> merchNode = new TreeNodeImpl<TreeItemImpl>();
				TreeItemImpl data = new TreeItemImpl();
				data.setData(merch.getNumber());
				data.setType("new");
				merchNode.setParent(customerNode);
				merchNode.setData(data);
				counter++;
				customerNode.addChild(counter, merchNode);
			}

		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public void processSelection(NodeSelectedEvent event) {
		HtmlTree tree = (HtmlTree) event.getComponent();
	}

	private Object getNewId(TreeNode<String> parentNode) {
		Map<Object, TreeNode<String>> childs = new HashMap<Object, TreeNode<String>>();
		Iterator<Map.Entry<Object, TreeNode<String>>> iter = parentNode.getChildren();
		while (iter != null && iter.hasNext()) {
			Map.Entry<Object, TreeNode<String>> entry = iter.next();
			childs.put(entry.getKey(), entry.getValue());
		}

		Integer index = 1;
		while (childs.containsKey(index)) {
			index++;
		}
		return index;
	}

	public void dropListener(DropEvent dropEvent) {

		// resolve drag destination attributes
		UITreeNode destNode = (dropEvent.getSource() instanceof UITreeNode) ? (UITreeNode) dropEvent
				.getSource()
				: null;
		UITree destTree = destNode != null ? destNode.getUITree() : null;
		TreeRowKey<String> dropNodeKey = (dropEvent.getDropValue() instanceof TreeRowKey) ? (TreeRowKey) dropEvent
				.getDropValue()
				: null;
		TreeNode<TreeItemImpl> droppedInNode = dropNodeKey != null ? destTree
				.getTreeNode(dropNodeKey) : null;

		// resolve drag source attributes
		UITreeNode srcNode = (dropEvent.getDraggableSource() instanceof UITreeNode) ? (UITreeNode) dropEvent
				.getDraggableSource()
				: null;
		UITree srcTree = srcNode != null ? srcNode.getUITree() : null;
		TreeRowKey<String> dragNodeKey = (dropEvent.getDragValue() instanceof TreeRowKey) ? (TreeRowKey) dropEvent
				.getDragValue()
				: null;
		TreeNode<TreeItemImpl> draggedNode = dragNodeKey != null ? srcTree.getTreeNode(dragNodeKey)
				: null;
		if (dropEvent.getDraggableSource() instanceof UIDragSupport && srcTree == null &&
				draggedNode == null && dropEvent.getDragValue() instanceof TreeNode) {
			srcTree = destTree;
			draggedNode = (TreeNode) dropEvent.getDragValue();
			dragNodeKey = srcTree.getTreeNodeRowKey(draggedNode) instanceof TreeRowKey ? (TreeRowKey) srcTree
					.getTreeNodeRowKey(draggedNode)
					: null;
		}

		// Note: check if we dropped node on to itself or to item instead of
		// folder here
		if (droppedInNode != null && droppedInNode.equals(draggedNode)) {
			return;
		}

		if (dropNodeKey != null) {
			// add destination node for rerender
			destTree.addRequestKey(dropNodeKey);

			Object state = null;
			if (dragNodeKey != null) { // Drag from this or other tree
				TreeNode<TreeItemImpl> parentNode = draggedNode.getParent();
				// 1. remove node from tree
				state = srcTree.removeNode(dragNodeKey);
				// 2. add parent for rerender
				Object rowKey = srcTree.getTreeNodeRowKey(parentNode);
				srcTree.addRequestKey(rowKey);
				if (dropEvent.getDraggableSource() instanceof UIDragSupport) {
					// if node was gragged in it's parent place dragged node to
					// the end of selected nodes in grid
					if (droppedInNode.equals(parentNode)) {
					}
				}
			} else if (dropEvent.getDragValue() != null) { // Drag from some
				// drag source
				draggedNode = new TreeNodeImpl<TreeItemImpl>();
				draggedNode.setData((TreeItemImpl) dropEvent.getDragValue());
			}

			// generate new node id
			Object id = getNewId(destTree.getTreeNode(dropNodeKey));
			destTree.addNode(dropNodeKey, draggedNode, id, state);
		}

		AjaxContext ac = AjaxContext.getCurrentInstance();
		// Add destination tree to reRender
		try {
			ac.addComponentToAjaxRender(destTree);
		} catch (Exception e) {
			System.err.print(e.getMessage());
		}

	}

	public TreeNodeImpl<TreeItemImpl> getTreeNode() {
		if (rootNode == null) {
			loadTree();
		}
		return rootNode;
	}

	public Map<String, Object> getMerchant() {
		if(!parentMerchants.isEmpty()){
			return parentMerchants;
		}
		Map<String, Object> merchants = new LinkedHashMap<String, Object>();
		List<ContractObject> appMerchants;
		List<SelectItem> appMerchantsItems = null;
		if (newApplication == null || newApplication.isIssuing() || finalObjects == null) {
			parentMerchants = new LinkedHashMap<String, Object>(0);
			return parentMerchants;
		}
		try {
			appMerchantsItems = new ArrayList<SelectItem>();
			appMerchants = getNewMerchants();

			List<ContractObject> savedMerchants = new ArrayList<ContractObject>();
			for (ContractObject co : finalObjects) {
				if (EntityNames.MERCHANT.equals(co.getEntityType())) {
					savedMerchants.add(co);
				}
			}

			for (ContractObject merchant : appMerchants) {
				// We have to separate new merchants (that are without number) from existing
				// merchants in contract
				// so, we add dataId in key value
				boolean possibleToAdd;
				possibleToAdd = possibleToContain(currentObject.getNumber(), merchant.getNumber(), savedMerchants);
				if (currentObject.getNumber().equals(merchant.getNumber())) {
					possibleToAdd = false;
				}


				if (possibleToAdd) {
					appMerchantsItems
							.add(new SelectItem(merchant.getNumber(), merchant.getNumber()));
					merchants.put(merchant.getNumber(), merchant.getNumber());
				}
			}

			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (newApplication.getContractNumber() != null &&
					!newApplication.getContractNumber().equals("")) {
				paramMap.put("CONTRACT_NUMBER", newApplication.getContractNumber());
				List<SelectItem> items = getDictUtils().getLov(LovConstants.APP_BRANCH_MERCHANTS,
						paramMap);
				if (items != null && items.size() > 0) {
					appMerchantsItems.addAll(0, items);
					for (SelectItem item : items) {
						merchants.put(item.getLabel(), item.getValue());
					}
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (appMerchantsItems == null) {
				appMerchantsItems = new ArrayList<SelectItem>();
			}
			if (merchants == null) {
				merchants = new LinkedHashMap<String, Object>();
			}
		}

		parentMerchants = merchants;
		return merchants;
	}

	private void setMerchantsLevels(int level, TreeNode<TreeItemImpl> node) {
		Iterator<Map.Entry<Object, TreeNode<TreeItemImpl>>> iter = node.getChildren();
		while (iter != null && iter.hasNext()) {
			Map.Entry<Object, TreeNode<TreeItemImpl>> entry = iter.next();
			TreeNode<TreeItemImpl> child = entry.getValue();
			ContractObject obj = new ContractObject(EntityNames.MERCHANT,
					child.getData().getData(), true);
			int index = finalObjects.indexOf(obj);
			if (index > 0) {
				obj = finalObjects.get(index);
				obj.setLevel(level);
				if (!TreeItemImpl.ROOT_TYPE.equals(node.getData().getType())) {
					obj.setParentNumber(node.getData().getData());
				}
			}
			setMerchantsLevels(level + 1, child);
		}
	}

	public void initializeModalPanel() {
		flush();
		appType = (String) FacesUtils.getSessionMapValue("APP_TYPE");
		newApplication = new Application();
		newApplication.setAppType(appType);
		if (FacesUtils.getSessionMapValue("instId") != null) {
			newApplication.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
			disableInst = true;
		}
		if (FacesUtils.getSessionMapValue("agentId") != null) {
			newApplication.setAgentId((Integer) FacesUtils.getSessionMapValue("agentId"));
			FacesUtils.setSessionMapValue("agentId", null);
			disableAgent = true;
		}
		if (FacesUtils.getSessionMapValue("productId") != null) {
			newApplication.setProductId((Integer) FacesUtils.getSessionMapValue("productId"));
			FacesUtils.setSessionMapValue("productId", null);
			disableProduct = true;
		}
		if (FacesUtils.getSessionMapValue("customerNumber") != null) {
			newApplication.setCustomerNumber((String) FacesUtils
					.getSessionMapValue("customerNumber"));
			FacesUtils.setSessionMapValue("customerNumber", null);
			disableCustomer = true;
		}
		if (FacesUtils.getSessionMapValue("contractNumber") != null) {
			newApplication.setContractNumber((String) FacesUtils
					.getSessionMapValue("contractNumber"));
			FacesUtils.setSessionMapValue("contractNumber", null);
			disableContract = true;
			initContractType(newApplication.getContractNumber(), newApplication.getInstId());
		}
		if (FacesUtils.getSessionMapValue("APP_FLOW") != null) {
			newApplication.setFlowId(((Double) FacesUtils.getSessionMapValue("APP_FLOW"))
					.intValue());
			FacesUtils.setSessionMapValue("APP_FLOW", null);
			disableAppFlow = true;
		}
		if (FacesUtils.getSessionMapValue("APP_CUST_TYPE") != null) {
			newApplication.setCustomerType((String) FacesUtils.getSessionMapValue("APP_CUST_TYPE"));
			FacesUtils.setSessionMapValue("APP_CUST_TYPE", null);
			disableCustomerType = true;
		}
		if (FacesUtils.getSessionMapValue("appl_prioritized") != null) {
			newApplication.setPrioritized((Boolean) FacesUtils.getSessionMapValue("appl_prioritized"));
			FacesUtils.setSessionMapValue("appl_prioritized", null);
		}
		if (FacesUtils.getSessionMapValue("TEST_FUNC_VAL") != null) {
			Object functionValue = FacesUtils.getSessionMapValue("TEST_FUNC_VAL");
			System.out.println(functionValue.toString());
		}
	}

	private void initContractType(String contractNumber, Integer instId) {
		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("CONTRACT_NUMBER");
		filters[0].setValue(contractNumber);
		filters[1] = new Filter();
		filters[1].setElement("INST_ID");
		filters[1].setValue(instId);
		filters[2] = new Filter("LANG", userLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		getContractParamMaps().put("param_tab", filters);
		getContractParamMaps().put("tab_name", "CONTRACT");
		try {
			Contract[] contracts = _productsDao.getContractsCur(userSessionId, params, getContractParamMaps());
			if (contracts != null && contracts.length > 0) {
				newApplication.setContractType(contracts[0].getContractType());
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public boolean isDisableInst() {
		return disableInst;
	}

	public void setDisableInst(boolean disableInst) {
		this.disableInst = disableInst;
	}

	public boolean isDisableAgent() {
		return disableAgent;
	}

	public void setDisableAgent(boolean disableAgent) {
		this.disableAgent = disableAgent;
	}

	public boolean isDisableCustomer() {
		return disableCustomer;
	}

	public void setDisableCustomer(boolean disableCustomer) {
		this.disableCustomer = disableCustomer;
	}

	public boolean isDisableContract() {
		return disableContract;
	}

	public void setDisableContract(boolean disableContract) {
		this.disableContract = disableContract;
	}

	public boolean isDisableAppFlow() {
		return disableAppFlow;
	}

	public void setDisableAppFlow(boolean disableAppFlow) {
		this.disableAppFlow = disableAppFlow;
	}

	public boolean isDisableCustomerType() {
		return disableCustomerType;
	}

	public void setDisableCustomerType(boolean disableCustomerType) {
		this.disableCustomerType = disableCustomerType;
	}

	public boolean isDisableContractType() {
		return disableContractType;
	}

	public void setDisableContractType(boolean disableContractType) {
		this.disableContractType = disableContractType;
	}

	public boolean isDisableProduct() {
		return disableProduct || newApplication.getContractNumber() != null;
	}

	public void setDisableProduct(boolean disableProduct) {
		this.disableProduct = disableProduct;
	}

	public String getCustomerTypeDescription() {
		String result = customerTypeDescription;

		if (getNewApplication().getCustomerType() == null ||
				customerTypes == null) {
			return result;
		}
		String searchingType = getNewApplication().getCustomerType();
		result = searchingType;

		for (SelectItem customerType : customerTypes) {
			if (searchingType.equals(customerType.getValue())) {
				result = customerType.getDescription();
				break;
			}
		}
		customerTypeDescription = result;
		return result;
	}

	public String getContractTypeDescription() {
		String result = contractTypeDescription;

		if (getNewApplication().getContractType() == null ||
				contractTypes == null || contractTypeDescription != null) {
			return result;
		}
		String searchingType = getNewApplication().getContractType();
		result = searchingType;

		for (SelectItem contractType : contractTypes) {
			if (searchingType.equals(contractType.getValue())) {
				result = contractType.getDescription();
				break;
			}
		}
		contractTypeDescription = result;
		return result;
	}

	public void clearCustomerNumber() {
		getNewApplication().setCustomerNumber(null);
		getNewApplication().setCustomerType(null);
		getNewApplication().setCustomerId(null);
		clearContractNumber();
		clearCbsData();
		clearEWalletData();
	}

	public void clearContractNumber() {
		getNewApplication().setContractNumber(null);
		getNewApplication().setContractType(null);
		getNewApplication().setProductId(null);
		getNewApplication().setFlowId(null);
		getNewApplication().setContractId(null);
		customerMainContract = null;
	}

	public void clearCbsData() {
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
		bean.setCbsCustomer(null);
		cbsAccounts = null;
	}

	public void clearEWalletData() {
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
		bean.seteWalletCustomer(null);
		eWalletAccounts = null;
	}

	private UsersDao daoUsers = new UsersDao();

	public void onInstitutionChanged() {
		Integer instId = getNewApplication().getInstId();
		getNewApplication().setAgentId(null);

		UserSession userSessionBean = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		User currentUser = userSessionBean.getUser();
		Integer userId = currentUser.getId();

		SelectionParams sp = new SelectionParams(
				new Filter("userId", userId),
				new Filter("instId", instId),
				new Filter("isDefault", true),
				new Filter("lang", curLang));

		/**
		 * If user have a default agent_id then we use it
		 */
		Integer agentId = daoUsers.getDefaultUserAgent(userSessionId, sp);
		if (agentId != null) {
			getNewApplication().setAgentId(agentId);
		} else {
			Agent[] agents = daoUsers.getAgentsForUserFlat(userSessionId, sp);
			if (agents.length != 0) {
				getNewApplication().setAgentId(agents[0].getId().intValue()); // Agent's ID is actually an integer
			}
		}

		clear();
		updateCustomerTypes();
		if (isProductType()) {
			updateContractTypes();
		}
	}

	public boolean isNewCustomer() {
		return newCustomer;
	}
	public void setNewCustomer(boolean newCustomer) {
		if (this.newCustomer == newCustomer) return;

		this.newCustomer = newCustomer;
		clearCustomerNumber();
	}

	public boolean isNewContract() {
		if (appType != null && isProductType()) {
			setNewContract(true);
		}
		return newContract;
	}
	public void setNewContract(boolean newContract) {
		if (this.newContract == newContract) return;
		this.newContract = newContract;
		if (newContract) {
			newApplication.setContractNumber(null);
			newApplication.setProductId(null);
		}
		newApplication.setContractType(null);
		newApplication.setFlowId(null);
	}

	public boolean isNewProduct() {
		return newProduct;
	}
	public void setNewProduct(boolean newProduct) {
		this.newProduct = newProduct;
	}

	public void clear() {
		flush();
		newCustomer = false;
		newContract = false;
		contractTypes = null;
		customerTypes = null;
		clearCustomerNumber();
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}

	public boolean isShowAppType() {
		return showAppType;
	}

	public void setShowAppType(boolean showAppType) {
		this.showAppType = showAppType;
	}

	public List<SelectItem> getApplicationTypes() {
		List<SelectItem> types = getDictUtils().getArticles(DictNames.AP_TYPES);
		Iterator<SelectItem> it = types.iterator();
		// TODO: it seems that it's easier to manually add them :)
		while (it.hasNext()) {
			SelectItem type = it.next();
			if (((String) type.getValue()).indexOf(DictNames.ACQUIRING_APPLICATION) > 0
					&& !userSession.getInRole().get(ApplicationPrivConstants.VIEW_ACQUIRING_APPLICATION)) {
				it.remove();
			} else if (((String) type.getValue()).indexOf(DictNames.ISSUING_APPLICATION) > 0
					&& !userSession.getInRole().get(ApplicationPrivConstants.VIEW_ISSUING_APPLICATION)) {
				it.remove();
			}
		}
		return types;
	}

	public void onAppTypeChanged() {
		if (getNewApplication().getAppType() == null) {
			getNewApplication().setInstId(null);
			getNewApplication().setAgentId(null);
		}
		clear();
		updateCustomerTypes();
	}

	public boolean isCloseWizard() {
		return closeWizard;
	}

	public void setCloseWizard(boolean closeWizard) {
		this.closeWizard = closeWizard;
	}

	public ArrayList<SelectItem> getExtCustomerTypes() {
		if (extCustomerTypes == null) {
			extCustomerTypes = (ArrayList<SelectItem>)
					getDictUtils().getLov(LovConstants.EXT_ENTITY_TYPES);
		}
		return extCustomerTypes;
	}

	public boolean isCustomerCompany() {
		return COMPANY.equalsIgnoreCase(newApplication.getCustomerType());
	}

	public boolean isSrvp() {
		return SRVP.equalsIgnoreCase(newApplication.getExtCustomerType());
	}

	public List<SelectItem> getServiceProviders() {
		if (serviceProviders == null) {
			serviceProviders = getDictUtils().getLov(LovConstants.PAYMENT_ORDER_PROVIDERS);
		}
		return serviceProviders;
	}

	public boolean isDisabled() {
		return newApplication.getFlowId().equals(1006);
	}

	public boolean isDisabledAccServices() {
		return newApplication.getFlowId().equals(1006) || newApplication.getFlowId().equals(1003);
	}

	public boolean isDisabledCardServices() {
		return newApplication.getFlowId().equals(1006) || newApplication.getFlowId().equals(1002);
	}

	public boolean isCbsSyncEnabled() {
		return (BigDecimal.ONE.equals(SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.ENABLE_CBS_SYNC)));
	}

	public boolean iseWalletSyncEnabled() {
		return (BigDecimal.ONE.equals(SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.ENABLE_EWALLET_SYNC)));
	}

	public boolean isHasCbsAccounts() {
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
		ru.bpc.svap.Customer cbsCustomer = bean.getCbsCustomer();
		return (cbsCustomer != null && !cbsCustomer.getAccount().isEmpty());
	}

	public boolean isHasEWalletAccounts() {
		MbCustomerSearchModal bean = ManagedBeanWrapper.getManagedBean("MbCustomerSearchModal");
		ru.bpc.svap.Customer eWalletCustomer = bean.geteWalletCustomer();
		return (eWalletCustomer != null && !eWalletCustomer.getAccount().isEmpty());
	}

	public boolean isRenderFinishButton() {return displayFinishButton;}

	public Map<String, Object> getContractParamMaps() {
		if (contractParamMaps == null) {
			contractParamMaps = new HashMap<String, Object>();
		}
		return contractParamMaps;
	}
}

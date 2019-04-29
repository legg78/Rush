package ru.bpc.sv2.ui.application;

import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.validator.ValidatorException;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import org.richfaces.component.UITree;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.application.*;
import ru.bpc.sv2.common.Address;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Cardholder;
import ru.bpc.sv2.issuing.ProductCardType;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.products.*;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.svap.*;
import ru.bpc.svap.Customer;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@SuppressWarnings("unused")
@SessionScoped
@ManagedBean (name = "MbApplication")
public class MbApplication extends AbstractBean implements Serializable {
	private static final long serialVersionUID = 1L;
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private ApplicationDao _applicationDao = new ApplicationDao();
	private ProductsDao _productDao = new ProductsDao();
	private AcquiringDao acquiringDao = new AcquiringDao();
	private CommonDao _commonDao = new CommonDao();
	private IssuingDao _issuingDao = new IssuingDao();

	private ApplicationElement appTree = null;
	private ApplicationElement currentNode = null;

	private Application _activeApp;
	private Application filter;

	private HashMap<Integer, SelectItem[]> listValues;
	private ArrayList<SelectItem> disabledElements;
	private ArrayList<SelectItem> applicationStatuses;
	private TreePath nodePath;
	private Map<Integer, ApplicationFlowFilter> filtersMap;
	private List<String> warnAppStatuses = null;
	private Set<ApplicationElement> expandeedList = new HashSet<ApplicationElement>();
	private Map<ApplicationElement, TreePath> exElNodePathLink = new HashMap<ApplicationElement, TreePath>();

	private String blockToAdd;
	private String selectedAppType;
	private String tabName;
	private String backLink;

	private int dependencesCount;
	private int curMode;
	private int pageNumber;
	private int rowsNum;

	private boolean valid = true;
	private boolean renderList = false;
	private boolean searching;
	private boolean fromNewWizard;
	private boolean isAddAttribute;
	private boolean keepState;
	private boolean useBlocksRepresentation = false;

	private String branchEntity;
	private String cardId;
	private String merchantId;
	private String terminalId;
	private String accountId;
	private String parentMerchantId;
	private String module;
	private String userName;

	private Integer attrId;
	private Integer serviceId;
	private Long userSessionId = null;

	private Map<Integer, ContractObject> servicesMap;
	private Map<String, ContractObject> appTerminalsMap;
	private Map<Integer, ProductAttribute> attributesMap;
	private Map<BigDecimal,String> currencyMap;

	private ContractObject[] services;
	private ContractObject[] cards;
	private ContractObject[] accounts;
	private ContractObject[] merchants;
	private ContractObject[] terminals;

	private Map<String, Long> cardNumberDataIdMap;
	private Map<Long, ApplicationElement> cardsMap;

	private Map<String, Long> accountNumberDataIdMap;
	private Map<Long, ApplicationElement> accountsMap;

	private Map<String, Long> merchantNumberDataIdMap;
	private Map<Long, ApplicationElement> merchantsMap;

	private Map<String, Long> terminalNumberDataIdMap;
	private Map<Long, ApplicationElement> terminalsMap;

	private Map<Long, ApplicationElement> contractsMap;

	public static final int VIEW_MODE = 1;
	public static final int EDIT_MODE = 2;
	public static final int NEW_MODE = 4;

	public static final String AGENT = "ENTTAGNT";
	public static final String INST = "ENTTINST";
	public static final String SERVICE_PROVIDER = "ENTTSRVP";

	public static final Integer CARDHOLDER_ID = 10000372;
	public static final Integer CONTACT_ID = 10000602;
	public static final Integer PERSON_ID = 10000601;

	org.openfaces.component.table.DynamicNodeExpansionState tst = new org.openfaces.component.table.DynamicNodeExpansionState();

	public MbApplication() {
		fromNewWizard = false;
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		appTree = new ApplicationElement();
		listValues = new HashMap<Integer, SelectItem[]>();

		UserSession us = ManagedBeanWrapper.getManagedBean("usession");
		userName = us.getUserName();
	}

	public ApplicationElement getNode() {
		if (currentNode == null) {
			currentNode = new ApplicationElement();
		}
		return currentNode;
	}

	public void setNode(ApplicationElement node) {
		if (node != null) {
			this.currentNode = node;
		}
	}

	public void constructAppStructure(Application app) throws DataAccessException {
		appTree = new ApplicationElement();
		filtersMap = new HashMap<Integer, ApplicationFlowFilter>();
		appTree = _applicationDao.getApplicationStructure(userSessionId, app, filtersMap);
		if (appTree == null) {
			throw new DataAccessException("Stage not found");
		}
	}

	public void getApplicationForEdit() throws Exception {
		currentNode = new ApplicationElement();
		try {
			ApplicationElement rootAppEdit = null;
			if (isNewMode()){
				rootAppEdit = _applicationDao.getNewApplicationForEdit(userSessionId, _activeApp);
			}else if (isEditMode() || isViewMode()){
				rootAppEdit = _applicationDao.getApplicationForEdit(userSessionId, _activeApp);
			}
			assert rootAppEdit != null;
			_activeApp.setStatus(rootAppEdit.getChildByName("APPLICATION_STATUS", 1).getValue().toString());
			constructAppStructure(_activeApp);
			_applicationDao.mergeApplication(userSessionId, _activeApp, rootAppEdit, appTree, filtersMap);
			appTree.setAppId(_activeApp.getId());
			coreChilds = new ArrayList<ApplicationElement>();
			coreChilds.add(appTree);
			initApplication();
		} catch (DataAccessException ee) {
			logger.error("", ee);
			throw ee;
		} catch (Exception e) {
			logger.error("", e);
			throw e;
		}
		nodePath = null;
		this.valid = true;
	}

	private void setParamLovs(ApplicationElement rootTree){
		Long instId = rootTree.getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().longValue();
		if (isProductApp() || isFreqApp() || isCampaignApp()) {
			return;
		}

		if (isQuestionaryApp()) {
			String entityType = rootTree.getChildByName(AppElements.QUESTIONARY, 1).
					getChildByName(AppElements.ENTITY_TYPE, 1).getValueV();

			HashMap<String , Object> params = new HashMap<String, Object>();
			params.put("entity_type", entityType);
			params.put("lang", userLang);

			List<ApplicationElement> parameters = rootTree.getChildByName(AppElements.QUESTIONARY, 1)
					.getChildrenByName(AppElements.QUESTIONARY_PARAMETER);

			for (ApplicationElement parameter : parameters){
				ApplicationElement parameterName = parameter.getChildByName(AppElements.PARAMETER_NAME, 1);
				fillParmLov(parameterName, params);
			}

			return;
		}

		Long productId = rootTree.getChildByName(AppElements.CUSTOMER, 1).
								  getChildByName(AppElements.CONTRACT, 1).
								  getChildByName(AppElements.PRODUCT_ID, 1).
								  getValueN().longValue();
		try{
			List<ApplicationElement> accounts = rootTree.getChildByName(AppElements.CUSTOMER, 1)
														.getChildByName(AppElements.CONTRACT, 1)
														.getChildrenByName(AppElements.ACCOUNT);
			for (ApplicationElement account : accounts){
				ApplicationElement accountType = account.getChildByName(AppElements.ACCOUNT_TYPE, 1);
				HashMap<String , Object> params = new HashMap<String, Object>();
				params.put("product_id", productId);
				params.put("institution_id", instId);
				fillParmLov(accountType, params);
			}
		} catch (Exception ignored){}

		try{
			ApplicationElement idType = rootTree.getChildByName(AppElements.CUSTOMER, 1)
												.getChildByName(AppElements.PERSON, 1)
												.getChildByName(AppElements.IDENTITY_CARD, 1)
												.getChildByName(AppElements.ID_TYPE, 1);
			String entityType = rootTree.getChildByName(AppElements.CUSTOMER_TYPE, 1).getValueV();
			HashMap<String , Object> params = new HashMap<String, Object>();
			params.put(AppElements.INSTITUTION_ID, instId);
			params.put(AppElements.CUSTOMER_TYPE, entityType);
			fillParmLov(idType, params);
		} catch (Exception ignored){}

		try{
			List<ApplicationElement> services = rootTree.getChildByName(AppElements.CUSTOMER, 1)
														.getChildByName(AppElements.CONTRACT, 1)
														.getChildrenByName(AppElements.SERVICE);
			for (ApplicationElement service : services){
				ApplicationElement attrFee = service.getChildByName(AppElements.SERVICE_OBJECT, 1)
													.getChildByName(AppElements.ATTRIBUTE_FEE, 1);
				if (attrFee == null) {
					continue;
				}
				ApplicationElement currency = attrFee.getChildByName(AppElements.CURRENCY, 1);
				HashMap<String , Object> params = new HashMap<String, Object>();
				params.put("product_id", productId);
				fillParmLov(currency, params);
			}
		} catch (Exception ignored){}

		try{
			List<ApplicationElement> cards = rootTree.getChildByName(AppElements.CUSTOMER,1)
													 .getChildByName(AppElements.CONTRACT, 1)
													 .getChildrenByName(AppElements.CARD);
			for (ApplicationElement card:cards){
				ApplicationElement iccCardId = card.getChildByName(AppElements.ICC_CARD_ID, 1);
				ApplicationElement cardBlank = card.getChildByName(AppElements.CARD_BLANK_TYPE, 1);
				HashMap<String, Object> params = new HashMap<String, Object>();
				params.put(AppElements.INST_ID, instId);
				params.put(AppElements.PRODUCT_ID, productId);
				fillParmLov(iccCardId, params);
				params.clear();
				params.put(AppElements.INSTITUTION_ID, instId);
				fillParmLov(cardBlank, params);
			}
		} catch (Exception ignored){}
	}

	private void fillParmLov(ApplicationElement element, HashMap<String, Object> params){
		ArrayList<SelectItem>lovs = (ArrayList<SelectItem>) getDictUtils().getLov(element.getLovId(), params);
		KeyLabelItem[] lovItems = new KeyLabelItem[lovs.size()];
		for (int i = 0; i<lovs.size(); i++){
			KeyLabelItem item = new KeyLabelItem();
			item.setLabel(lovs.get(i).getLabel());
			item.setValue(lovs.get(i).getValue());
			lovItems[i] = item;
		}
		element.setLov(lovItems);
	}

	private void initApplication() throws Exception {
		ApplicationElement user = appTree.getChildByName(AppElements.USER, 1);
		if (user != null) {
			return;
		}
		branchEntity = null;
		serviceId = null;
		cardId = null;
		merchantId = null;
		terminalId = null;
		accountId = null;
		disabledElements = null;
		applicationStatuses = null;
		serviceObjects = new ArrayList<ApplicationElement>();
		if (!isInstitutionApp() && !isQuestionaryApp() && !isCampaignApp()) {
			if (!isFreqApp()) {
				if (!isProductApp() && !isFreqApp()) {
					initCustomer();
					initContract();
					if (_activeApp.isIssuing()) {
						initCards();
					} else if (_activeApp.isAcquiring()) {
						initMerchants();
					}
					initAccounts();
					initCustomer();
					initContract();
				}
				initProduct();
			}
			initServices();
			setFakeValues();
			if (!isFreqApp()) {
				storeServicsObjects();
				if(isProductApp()) {
					addServiceObjects();
				}
				updateAddDescForObjects();
			}
		}
	}

	public void initCards() throws Exception {
		if (cardNumberDataIdMap == null) {
			cardNumberDataIdMap = new HashMap<String, Long>();
		} else {
			cardNumberDataIdMap.clear();
		}

		if (cardsMap == null) {
			cardsMap = new HashMap<Long, ApplicationElement>();
		} else {
			cardsMap.clear();
		}
		ApplicationElement contract = findContract();
		List<ApplicationElement> cardElements = contract
				.getChildrenByName(AppElements.CARD);
		for (ApplicationElement el : cardElements) {
			String cardNumber = el.getChildByName(AppElements.CARD_NUMBER, 1)
					.getValueV();
			if (cardNumber != null && !cardNumber.trim().equals("")) {
				cardNumberDataIdMap.put(cardNumber, el.getDataId());
			}
			cardsMap.put(el.getDataId(), el);
		}
	}

	private ApplicationElement findContract() throws Exception {
		ApplicationElement customer = findCustomer();
		ApplicationElement contract = customer.getChildByName(AppElements.CONTRACT, 1);
		if (contract == null) {
			throw new Exception("Contract not found");
		}
		return contract;
	}

	private ApplicationElement findCustomer() throws Exception {
		ApplicationElement customer = appTree.getChildByName(AppElements.CUSTOMER, 1);
		if (customer == null) {
			throw new Exception("Customer not found");
		}
		return customer;
	}

	private ApplicationElement findProduct() throws Exception {
		ApplicationElement product = appTree.getChildByName(AppElements.PRODUCT, 1);
		if (product == null) {
			throw new Exception("Product not found in application structure");
		}
		return product;
	}

	private ApplicationElement findInstitution() throws Exception {
		ApplicationElement institution = appTree.getChildByName(AppElements.INSTITUTION, 1);
		if (institution == null) {
			throw new Exception("Institution not found");
		}
		return institution;
	}

	private ApplicationElement findQuestionary() throws Exception {
		ApplicationElement questionary = appTree.getChildByName(AppElements.QUESTIONARY, 1);
		if (questionary == null) {
			throw new Exception("Questionary not found");
		}
		return questionary;
	}

	private ApplicationElement findCampaign() throws Exception {
		ApplicationElement campaign = appTree.getChildByName(AppElements.CAMPAIGN, 1);
		if (campaign == null) {
			throw new Exception("Campaign not found");
		}
		return campaign;
	}

	public void initMerchants() throws Exception {
		if (merchantNumberDataIdMap == null) {
			merchantNumberDataIdMap = new HashMap<String, Long>();
		} else {
			merchantNumberDataIdMap.clear();
		}

		if (merchantsMap == null) {
			merchantsMap = new HashMap<Long, ApplicationElement>();
		} else {
			merchantsMap.clear();
		}

		if (terminalNumberDataIdMap == null) {
			terminalNumberDataIdMap = new HashMap<String, Long>();
		} else {
			terminalNumberDataIdMap.clear();
		}

		if (terminalsMap == null) {
			terminalsMap = new HashMap<Long, ApplicationElement>();
		} else {
			terminalsMap.clear();
		}

		ApplicationElement contract = findContract();
		initMerchantTree(contract);

		appTerminalsMap = new HashMap<String, ContractObject>();
		try {
			ContractObject filter = new ContractObject();
			if (_activeApp.getProductId() != null) {
				filter.setProductId(_activeApp.getProductId());
			}
			filter.setContractNumber(_activeApp.getContractNumber());
			filter.setEntityType(EntityNames.TERMINAL);
			ContractObject[] terms = _applicationDao.getContractTerminals(
					userSessionId, filter);
			for (ContractObject term : terms) {
				appTerminalsMap.put(term.getNumber(), term);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void initMerchantTree(ApplicationElement root) {
		List<ApplicationElement> merchants = root.getChildrenByName(AppElements.MERCHANT);
		for (ApplicationElement merch : merchants) {
			String merchNumber = merch.getChildByName(AppElements.MERCHANT_NUMBER,
					1).getValueV();
			if (merchNumber != null && !merchNumber.trim().equals("")) {
				merchantNumberDataIdMap.put(merchNumber, merch.getDataId());
			}
			merchantsMap.put(merch.getDataId(), merch);
			initMerchantTree(merch);
		}
		List<ApplicationElement> termElements = root.getChildrenByName(AppElements.TERMINAL);
		for (ApplicationElement terminal : termElements) {
			String termNumber = terminal.getChildByName(
					AppElements.TERMINAL_NUMBER, 1).getValueV();
			if (termNumber != null && !termNumber.trim().equals("")) {
				terminalNumberDataIdMap.put(termNumber, terminal.getDataId());
			}
			terminalsMap.put(terminal.getDataId(), terminal);
		}
	}

	public void initAccounts() throws Exception {
		if (accountNumberDataIdMap == null) {
			accountNumberDataIdMap = new HashMap<String, Long>();
		} else {
			accountNumberDataIdMap.clear();
		}

		if (accountsMap == null) {
			accountsMap = new HashMap<Long, ApplicationElement>();
		} else {
			accountsMap.clear();
		}

		ApplicationElement contract = findContract();
		List<ApplicationElement> accElements = contract.getChildrenByName(AppElements.ACCOUNT);
		for (ApplicationElement el : accElements) {
			String accNumber = el.getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueV();
			if (accNumber != null && !accNumber.trim().equals("")) {
				accountNumberDataIdMap.put(accNumber, el.getDataId());
			}
			accountsMap.put(el.getDataId(), el);
		}
	}

	public void initContract() throws Exception {
		if (contractsMap == null) {
			contractsMap = new HashMap<Long, ApplicationElement>();
		} else {
			contractsMap.clear();
		}

		ApplicationElement customer = findCustomer();
		ApplicationElement cb = customer.getChildByName(AppElements.CONTRACT, 1);

		if (isNewMode()) {
			if (cb == null) {
				cb = addBl(AppElements.CONTRACT, customer);
				if (cb == null) {
					throw new Exception("Cannot create contract block");
				}
			}
			fillContractBlock(cb, _activeApp);
		} else if (isEditMode() || isViewMode()) {

			if (cb == null) {
				_activeApp.setContractNumber(null);
			} else {
				ApplicationElement contractNumber = cb.getChildByName(
						AppElements.CONTRACT_NUMBER, 1);
				if (contractNumber == null) {
					_activeApp.setContractNumber(null);
				} else {
					_activeApp.setContractNumber(contractNumber.getValueV());
				}
			}
		}

		if (cb != null) {
			contractsMap.put(cb.getDataId(), cb);
		}
	}

	public void initCustomer() throws Exception {
		if (isNewMode()) {
			ApplicationElement customerBlock = appTree.getChildByName(AppElements.CUSTOMER, 1);
			if (customerBlock == null) {
				customerBlock = addBl(AppElements.CUSTOMER, appTree, null, false);
				if (customerBlock == null) {
					throw new Exception("Cannot create customer block");
				}
				customerBlock.setDataId(getDataId());
			}
			fillCustomerBlock(customerBlock, _activeApp);
			_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp, customerBlock, filtersMap);
			_applicationDao.setPathForSubtree(customerBlock);
		} else if (isEditMode() || isViewMode()) {
			ApplicationElement customer = appTree.getChildByName(AppElements.CUSTOMER, 1);
			if (customer == null) {
				_activeApp.setCustomerNumber(null);
			} else {
				ApplicationElement customerNumber = customer.getChildByName(AppElements.CUSTOMER_NUMBER, 1);
				if (customerNumber == null) {
					_activeApp.setCustomerNumber(null);
				} else {
					_activeApp.setCustomerNumber(customerNumber.getValueV());
				}
			}
		}
	}

	public void initProduct() throws Exception {
		if (isEditMode() || isViewMode()) {
			ApplicationElement element = isProductApp() ? findProduct() : findContract();
			ApplicationElement product_id = element.getChildByName(AppElements.PRODUCT_ID, 1);
			ApplicationElement parentProductId = element.getChildByName(AppElements.PARENT_PRODUCT_ID, 1);
			ApplicationElement productType = element.getChildByName(AppElements.PRODUCT_TYPE, 1);
			ApplicationElement contractType = element.getChildByName(AppElements.CONTRACT_TYPE, 1);
			ApplicationElement productNumber = element.getChildByName(AppElements.PRODUCT_NUMBER, 1);
			ApplicationElement productStatus = element.getChildByName(AppElements.PRODUCT_STATUS, 1);

			_activeApp.setProductId((product_id != null && product_id.getValueN() != null) ? product_id.getValueN().intValue() : null);
			_activeApp.setProductParentId((parentProductId != null && parentProductId.getValueN() != null) ? parentProductId.getValueN().intValue() : null);
			_activeApp.setProductType((productType != null && productType.getValueV() != null) ? productType.getValueV() : null);
			_activeApp.setContractType((contractType != null && contractType.getValueV() != null) ? contractType.getValueV() : null);
			_activeApp.setProductNumber((productNumber != null && productNumber.getValueV() != null) ? productNumber.getValueV() : null);
			_activeApp.setProductStatus((productStatus != null && productStatus.getValueV() != null) ? productStatus.getValueV() : null);
		}
	}

	public void getApplicationForView() throws Exception {
		curMode = VIEW_MODE;
		switchToTree();
		try {
			SelectionParams params = new SelectionParams();
			ArrayList<Filter> filters = new ArrayList<Filter>();
			filters.add(Filter.create("id", _activeApp.getId()));
			params.setFilters(Filter.asArray(filters));
			List<Application> apps = _applicationDao.getApplications(userSessionId, params);

			if (apps == null || apps.size() == 0) {
				appTree = new ApplicationElement();
				return;
			}

			_activeApp = apps.get(0);
			ApplicationElement rootAppEdit = _applicationDao.getApplicationForEdit(userSessionId, _activeApp);
			constructAppStructure(_activeApp);
			_applicationDao.mergeApplication(userSessionId, _activeApp, rootAppEdit, appTree, filtersMap);
			appTree.setAppId(_activeApp.getId());
			coreChilds = new ArrayList<ApplicationElement>();
			coreChilds.add(appTree);
			initApplication();
		} catch (DataAccessException ee) {
			logger.error("", ee);
			throw ee;
		} catch (Exception e) {
			logger.error("", e);
			throw e;
		}
		currentNode = new ApplicationElement();
		nodePath = null;
	}

	public void showAddBlock() {
		isAddAttribute = AppElements.SERVICE_OBJECT.equalsIgnoreCase(currentNode.getName());
	}

	public boolean isShowAttributes() {
		return isAddAttribute;
	}

	public void add() {
		try {
			if (isAddAttribute) {
				if (attrId == null) {
					return;
				}
				addAttribute(attrId, currentNode);
			} else {
				addBl(blockToAdd, currentNode).setUpdatable(true);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ApplicationElement addBl(String blockName,
									ApplicationElement parent)
			throws Exception {
		return addBl(blockName, parent, null, true);
	}

	public void addBl(String blockName,
	                  ApplicationElement parent,
	                  Boolean applyDependences)
			throws Exception {
		addBl(blockName, parent, null, applyDependences);
	}

	public ApplicationElement addBl(String blockName,
									ApplicationElement parent,
									ApplicationElement template)
			throws Exception {
		return addBl(blockName, parent, template, true);
	}

	/**
	 * Create new application element and add it to parent
	 *
	 * @param blockName Name of the element you want to create.
	 * @param parent Parent for new element. New element will be added to
	 *        its children.
	 * @param templateNode Template for new element.
	 * @param applyDependences Flag that dependencies should be taken
	 *        into consideration.
	 * @throws Exception If any unhandled error occured in this function.
	 */
	public ApplicationElement addBl(String blockName,
									ApplicationElement parent,
									ApplicationElement templateNode,
									Boolean applyDependences)
			throws Exception {
		String errMsg = "Cannot add element " + blockName+". ";
		String errReason;
		if (templateNode == null) {
			List<ApplicationElement> templateBlocks = new ArrayList<ApplicationElement>();
			for (ApplicationElement el : parent.getChildren()) {
				if (el.isPossibleToAdd()) {
					templateBlocks.add(el);
				}
			}

			templateNode = new ApplicationElement();
			templateNode.setInnerId(0);
			templateNode.setName(blockName);
			int index = templateBlocks.indexOf(templateNode);
			if (index < 0) {
				errReason = "This element is deprecated for adding to element " + parent.getShortDesc();
				throw new Exception(errMsg+errReason);
			}
			templateNode = templateBlocks.get(index); // get template for new node from content node
		}

		if (templateNode.getMaxCount() == null || templateNode.getMaxCount() == 0) {
			errMsg = "Cannot add element " + templateNode.getShortDesc()+". ";
			errReason = "Please check possibility of adding element " + templateNode.getShortDesc() + " to " + parent.getShortDesc();
			throw new Exception(errMsg+errReason);
		}

		if (templateNode.getCopyCount().equals(templateNode.getMaxCount())) {
			errMsg = "Cannot add element " + templateNode.getShortDesc()+". ";
			errReason = "Maximum number of children of this type for " + parent.getShortDesc() + " was reached.";
			throw new Exception(errMsg+errReason);
		}

		ApplicationElement newNode = new ApplicationElement();
		templateNode.clone(newNode);
		newNode.setContent(false);
		newNode.setInnerId(templateNode.getMaxCopy() + 1);
		newNode.setContentBlock(templateNode);
		_applicationDao.fillRootChilds(userSessionId, _activeApp.getInstId(), newNode, _activeApp, filtersMap);
		parent.getChildren().add(newNode);

		templateNode.setCopyCount(templateNode.getCopyCount() + 1);
		templateNode.setMaxCopy(templateNode.getMaxCopy() + 1);
		Collections.sort(parent.getChildren());

		if (applyDependences) {
			_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp, newNode, filtersMap);
			_applicationDao.setPathForSubtree(newNode);
		}
		return newNode;
	}

	private void removeBl (String blockName,
						   ApplicationElement parent,
						   Integer delIndex){
		ApplicationElement template = parent.getChildByName(blockName, 0);
		Integer maxCopy = template.getMaxCopy();

		if(maxCopy > 0){
			template.setCopyCount(template.getCopyCount() - 1);

			int index = maxCopy;
			//boolean reindex = false;
			if(delIndex != null && delIndex < maxCopy){
				index = delIndex;
				//reindex = true;
			}else{
				template.setMaxCopy(template.getMaxCopy()-1);
			}
			template = parent.getChildByName(blockName, index);
			parent.getChildren().remove(template);
			/*
			if(reindex){
				for(int i = index+1; i < count; i++){
					template = parent.getChildByName(blockName, i);
					template.setInnerId(template.getInnerId() - 1);
				}
			}
			*/
		}

	}

	private ArrayList<SelectItem> getDisabledElements() {
		if (disabledElements == null) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (_activeApp != null) {
				paramMap.put("APPL_TYPE", _activeApp.getAppType());
			}
			disabledElements = (ArrayList<SelectItem>) getDictUtils().getLov(
					LovConstants.APP_ELEMENTS_CANNOT_ADD, paramMap);
		}
		if (disabledElements == null) {
			disabledElements = new ArrayList<SelectItem>();
		}
		return disabledElements;
	}

	public SelectItem[] getCurNodeBlocksToAdd() {
		List<SelectItem> items;
		try {
			ApplicationElement current = currentNode;
			if (current == null || current.getChildren() == null) {
				return new SelectItem[0];
			}
			boolean found;
			items = new ArrayList<SelectItem>();
			for (ApplicationElement el : currentNode.getChildren()) {
				if (el.isPossibleToInsert()) {
					found = false;
					for (SelectItem item : getDisabledElements()) {
						if (item.getValue() != null
								&& el.getName().equalsIgnoreCase(
										(String) item.getValue())) {
							found = true;
							break;
						}
					}
					if (!found) {
						items.add(new SelectItem(el.getName(), el.getShortDesc()));
					}
				}
			}
			return items.toArray(new SelectItem[items.size()]);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new SelectItem[0];
	}

	public List<SelectItem> getCurrentAttrsToAdd() {
		// This is service_object block
		// To get service id, we must get it's parent
		ApplicationElement current = currentNode;

		if (current == null || current.getParent() == null
				|| current.getParent().getValueN() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Integer serviceId = current.getParent().getValueN().intValue();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("SERVICE", serviceId);
		return getDictUtils().getLov(LovConstants.APP_SERVICE_ATTRIBUTES, paramMap);
	}

	public void fillAppElementChilds(ApplicationElement curElement) {
		try {
			if (curElement.getChildren().size() == 0) {
				List<ApplicationElement> childs = _applicationDao
						.fillAppElementChilds(userSessionId, _activeApp.getInstId(), curElement);
				curElement.setChildren(childs);
			}
			// fillListValues(curElement); //loading listValues
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void deleteBlock() {
		ApplicationElement templateNode = currentNode.getContentBlock();
		if (templateNode.getCopyCount().equals(templateNode.getMinCount())) {
			return; // we can't delete more blocks than is possible
		}

		ApplicationElement blockToDel = currentNode;
		templateNode.setCopyCount(templateNode.getCopyCount() - 1);
		for (ApplicationElement elem : blockToDel.getChildren()) {
			deleteBlockRecursion(elem);
		}
		blockToDel.getChildren().clear();
		blockToDel.setInnerId(blockToDel.getInnerId() * (-1));
		blockToDel.setVisible(false);

		// if we delete block that is marked as "required", then
		// we have to mark another element as required in order to
		// display proper amount of "*"
		if (currentNode.isRequired()) {
			List<ApplicationElement> childrenByName = currentNode.getParent()
					.getChildrenByName(currentNode.getName());
			for (ApplicationElement el : childrenByName) {
				if (!el.isRequired()) {
					el.setRequired(true);
					break;
				}
			}
		}
		currentNode = null;
	}

	public void deleteBlockRecursion(ApplicationElement block) {
		try {
			for (ApplicationElement elem : block.getChildren()) {
				if (elem.getChildren().size() > 0)
					deleteBlockRecursion(elem);
			}
			block.getChildren().clear();
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public void save() {
		List<ApplicationElement> requiredList = new ArrayList<ApplicationElement>();
		try {
			validate(requiredList);
			if (requiredList.size() > 0 && ApplicationStatuses.AWAITING_PROCESSING.equals(_activeApp.getNewStatus())) {
				throw new Exception("Not all required fields are filled!");
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			valid = false;
		}
		if (valid) {
			try {
				_applicationDao.saveApplication(userSessionId, appTree, _activeApp);
				applicationStatuses = null;
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
	}

	public void validate() {
		List<ApplicationElement> requiredList = new ArrayList<ApplicationElement>();
		try {
			validate(requiredList);
		} catch (Exception e) {
			FacesUtils.addSystemError(e);
		}
	}

	public void validate(List<ApplicationElement> requiredList)
			throws Exception {
		try {
			valid = _applicationDao.validateApplication(userSessionId, appTree, requiredList);
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			throw new Exception(ee);
		}
	}

	public void notSave() {
		valid = true;
	}

	public String forceSave() {
		if (_activeApp.getNewStatus() == null) {
			_activeApp.setNewStatus(_activeApp.getStatus());
		}
		try {
			if (_activeApp.getPrioritized() == null) {
				ApplicationElement priorityEl= appTree.getChildByName("APPL_PRIORITIZED", 1);
				if(priorityEl != null && priorityEl.getValueN() != null){
					_activeApp.setPrioritized(priorityEl.getValueN().intValue());
				}
			}
			int isNew = 0;
			if (_activeApp.getId() == null) {
				isNew = 1;
				ApplicationElement instEl= appTree.getChildByName("INSTITUTION_ID", 1);
				if(instEl != null && instEl.getValueN() != null){
					_activeApp.setInstId(instEl.getValueN().intValue());
				}
				ApplicationElement applNumberEl = appTree.getChildByName("APPLICATION_NUMBER");
				if(applNumberEl != null && StringUtils.isNotEmpty(applNumberEl.getValueV())) {
					_activeApp.setApplNumber(applNumberEl.getValueV());
				}
				_activeApp = _applicationDao.createApplication(userSessionId, _activeApp);
				List<ApplicationElement> childrens = _applicationDao.getChildrensForElement(userSessionId, _activeApp);
				ApplicationElement el;
				for (ApplicationElement child : childrens){
						ApplicationElement elem = appTree.getChildByName(child.getName(), 1);
						if (elem != null) {
							elem.setDataId(child.getDataId());
						} else if (child.isComplex()) {
								appTree.setDataId(child.getDataId());
								if (isCampaignApp()) {
									el = appTree.getChildByName(AppElements.CAMPAIGN, 1);
								} else {
									el = appTree.getChildByName(AppElements.CUSTOMER, 1);
									if (el == null) {
										el = appTree.getChildByName(AppElements.USER, 1);
									}
									if (el == null) {
										el = appTree.getChildByName(AppElements.PRODUCT, 1);
									}
									if (el == null) {
										el = appTree.getChildByName(AppElements.INSTITUTION, 1);
									}
									if (el == null) {
										el = appTree.getChildByName(AppElements.QUESTIONARY, 1);
									}
								}
								el.setParentDataId(child.getDataId());
						}
				}
				appTree.getChildByName("APPLICATION_ID", 1).setValueN(new BigDecimal(_activeApp.getId()));
			}
			_applicationDao.saveApplication(userSessionId, appTree, _activeApp, isNew);
			applicationStatuses = null;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			return "";
		}
		Menu menu = ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
		setKeepState(true);

		return backLink;
	}

	public ApplicationElement getAppTree() {
		return appTree;
	}

	public String getSelectedAppType() {
		return selectedAppType;
	}

	public void setSelectedAppType(String selectedAppType) {
		this.selectedAppType = selectedAppType;
	}

	public ApplicationElement getCurrentNode() {
		return currentNode;
	}

	public void setCurrentNode(ApplicationElement currentNode) {
		this.currentNode = currentNode;
	}

	public boolean isShowApp() {
		return currentNode != null;
	}

	public ApplicationElement getApplicationTree() {
		return appTree;
	}

	public void setApplicationTree(ApplicationElement appTree){
		this.appTree = appTree;
		coreChilds = new ArrayList<ApplicationElement>();
		coreChilds.add(appTree);
	}

	public Boolean autoExpand(UITree node) {
		return true;
	}

	public String view() {
		return "view";
	}

	public Application getActiveApp() {
		return _activeApp;
	}

	public void setActiveApp(Application activeApp) {
		_activeApp = activeApp;
	}

	public HashMap<Integer, SelectItem[]> getListValues() {
		return listValues;
	}

	public void setListValues(HashMap<Integer, SelectItem[]> listValues) {
		this.listValues = listValues;
	}

	public Boolean autoSelect(UITree node) {
		if (currentNode.getDataId().equals(((ApplicationElement) node.getRowData()).getDataId())) {
			return true;
		}
		return null;
	}

	public boolean isValid() {
		return valid;
	}

	public void setValid(boolean valid) {
		this.valid = valid;
	}

	public ArrayList<SelectItem> getApplicationStatuses() {
		if (applicationStatuses == null) {
			applicationStatuses = new ArrayList<SelectItem>();
			try {
				if (_activeApp == null || _activeApp.getStatus() == null || _activeApp.getFlowId() == null) {
					return applicationStatuses;
				}
				List<ApplicationFlowTransition> statuses = _applicationDao.getTransitionApplicationStatuses(userSessionId, _activeApp);

				ApplicationFlowTransition activeStatus = _activeApp.createTransition(getDictUtils().getAllArticlesDesc());
				applicationStatuses.add(new SelectItem(activeStatus.getAppStatusRejectCode(), activeStatus.getAppStatusRejectLabel()));

				for (ApplicationFlowTransition status : statuses) {
					if (!status.getAppStatusRejectCode().equals(activeStatus.getAppStatusRejectCode())){
						applicationStatuses.add(new SelectItem(status.getAppStatusRejectCode(), status.getAppStatusRejectLabel()));
					}
				}

			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage() != null && !e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
					FacesUtils.addMessageError(e);
				}
			}
		}

		return applicationStatuses;
	}

	private List<ApplicationElement> coreChilds;

	public List<ApplicationElement> getNodeChildren() {
		ApplicationElement param = getCurrentAppElement();
		if (param == null) {
			return coreChilds;
		} else {
			configureExpandedNodes();

			fillAppElementChilds(param);
			List<ApplicationElement> childs = new ArrayList<ApplicationElement>();
			for (ApplicationElement el : param.getChildren()) {
				if (el.isMultiLang() && el.getValueLang()==null) {
					el.setValueLang(userLang);
				}
				el.setCurMode(curMode);
				boolean goodChild = el.getVisible();
				goodChild = goodChild && !el.getContent();
				updateAdditionalDesc(el);
				if (goodChild) {
					if (el.getLov() != null) {
						if (el.getLovId() != null && el.getLov().length == 0) {
							Map<String, Object> map = null;
							if (AppElements.PRODUCT_ID.equals(el.getName())) {
								map = getProductLovMap(el);
							} else if (AppElements.CARD_PRODUCT_ID.equals(el.getName())) {
								map = getCardProductLovMap(el);
							} else if (AppElements.CARD_TYPE.equals(el.getName())) {
								map = getCardTypeLovMap(el);
							} else if (AppElements.CARD_NUMBER.equals(el.getName())) {
								map = getMerchantCardLovMap(el);
							} else if (AppElements.ID_TYPE.equals(el.getName())) {
								map = getIdTypeLovMap(el);
							} else if (AppElements.CURRENCY.equals(el.getName())) {
								map = getCardTypeLovMap(el);
							} else if (AppElements.ACCOUNT_TYPE.equals(el.getName())) {
								map = getAccountTypeLovMap(el);
							}

							List<SelectItem> selectItemList = null;
							if (map == null && !el.getDependent()) {
								selectItemList = getDictUtils().getLov(el.getLovId());
							} else if (!el.getDependent()){
								selectItemList = getDictUtils().getLov(el.getLovId(), map);
							} else {
								_applicationDao.applyLovDependence(userSessionId, _activeApp, el, map);
							}
							if (selectItemList != null) {
								List<KeyLabelItem> items = new ArrayList<KeyLabelItem>(selectItemList.size());
								for (SelectItem item : selectItemList) {
									items.add(new KeyLabelItem(item.getValue(), item.getLabel()));
								}
								el.setLov(items.toArray(new KeyLabelItem[items.size()]));
							}
						}
						if (el.isRequired() && el.getLov().length == 1) {
							if (el.getLov()[0].getValue() != null) {
								Object val = el.getLov()[0].getValue();
								if (el.isNumber()) {
									el.setValueN((int)Double.parseDouble(val.toString()));
								} else if (el.isChar()) {
									el.setValueV(val.toString());
								}
								el.setValueText(el.getLov()[0].getLabel());
							}
						} else if (el.getLovId() != null && el.getLov().length == 0) {
							Map<String, Object> map = null;
							if (AppElements.PRODUCT_ID.equals(el.getName())) {
								map = getProductLovMap(el);
							} else if (AppElements.CARD_PRODUCT_ID.equals(el.getName())) {
								map = getCardProductLovMap(el);
							} else if (AppElements.CARD_TYPE.equals(el.getName())) {
								map = getCardTypeLovMap(el);
							} else if (AppElements.CARD_NUMBER.equals(el.getName())) {
								map = getMerchantCardLovMap(el);
							} else if (AppElements.ID_TYPE.equals(el.getName())) {
								map = getIdTypeLovMap(el);
							} else if (AppElements.CURRENCY.equals(el.getName())) {
								map = getCardTypeLovMap(el);
							} else if (AppElements.ACCOUNT_TYPE.equals(el.getName())) {
								map = getAccountTypeLovMap(el);
							}

							List<SelectItem> selectItemList = null;
							if (map == null) {
								selectItemList = getDictUtils().getLov(el.getLovId());
							} else {
								selectItemList = getDictUtils().getLov(el.getLovId(), map);
							}

							List<KeyLabelItem> items = new ArrayList<KeyLabelItem>(selectItemList.size());
							for (SelectItem item : selectItemList) {
								items.add(new KeyLabelItem(item.getValue(), item.getLabel()));
							}
							el.setLov(items.toArray(new KeyLabelItem[items.size()]));
						}
					}
					if(!useBlocksRepresentation || el.isComplex())
						childs.add(el);
				}
			}

			return childs;
		}
	}

	/**
	 * When treeTable component asks for children of node, this means that the
	 * node is expanded. Every time when getNodeChildren is called, this method
	 * is called also.
	 *
	 * For the node TreePath is created or getting from a map if it is created
	 * early. Then setNodeExpanded(TreePath, true) is called from the openfaces
	 * util class. It programmatically setup the node in the tree as expended.
	 *
	 */
	private void configureExpandedNodes() {

		ApplicationElement param = getCurrentAppElement();
		TreePath tp = null;

		if (!expandeedList.contains(param)) {
			ApplicationElement child;
			ApplicationElement parent = param;

			ArrayList<ApplicationElement> order = new ArrayList<ApplicationElement>();
			while (parent != null) {
				order.add(parent);
				child = parent;
				parent = child.getParent();
			}

			for (int i = order.size(); i > 0; i--) {
				tp = new TreePath(order.get(i - 1), tp);
			}

			exElNodePathLink.put(param, tp);
			expandeedList.add(param);
		} else {
			tp = exElNodePathLink.get(param);
		}
		tst.setNodeExpanded(tp, true);
	}

	private ApplicationElement getCurrentAppElement() {
		return (ApplicationElement) Faces.var("app");
	}

	public boolean isNodeHasChildren() {
		ApplicationElement curEl = getCurrentAppElement();
		if (useBlocksRepresentation) {
			if (curEl != null && curEl.isComplex() && curEl.isHasComplexChildren()) {
				return true;
			}
		} else {
			if (curEl != null && curEl.isComplex() && !curEl.getContent()) {
				return true;
			}
		}
		return false;
	}

	public String getBlockToAdd() {
		return blockToAdd;
	}

	public void setBlockToAdd(String blockToAdd) {
		this.blockToAdd = blockToAdd;
	}

	public ArrayList<SelectItem> getAvailableRejectCodes() {
		return getDictUtils().getArticles(DictNames.AP_REJECT_CODES, false, false);
	}

	public ArrayList<SelectItem> getAvailableAppStatuses() {
		return getDictUtils().getArticles(DictNames.AP_STATUSES, false, false);
	}

	public ArrayList<SelectItem> getAvailableAppTypes() {
		return getDictUtils().getArticles(DictNames.AP_TYPES, false, false);
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public void nodeValueChanged() {
		dependencesCount = 0;
		if (currentNode != null) {
			if (currentNode.getParent() != null) {
				try {
					fillElementData(currentNode.getParent());
				}
				catch (ParseException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
			if (currentNode.getDependence() != null && currentNode.getDependence().equals(Boolean.TRUE)) {
				ArrayList<Filter> filtersFlow = new ArrayList<Filter>();
				filtersFlow.add(Filter.create("lang", SessionWrapper.getField("language")));
				filtersFlow.add(Filter.create("structId", currentNode.getStId().toString()));

				SelectionParams params = new SelectionParams(filtersFlow);
				params.setRowIndexEnd(-1);
				try {
					dependencesCount = _applicationDao.applyDependences(userSessionId, _activeApp,
																		currentNode, currentNode.getParent(),
																		params, filtersMap);
					dependencesCount = 1;
				}
				catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
			if (currentNode.getLovId() != null && currentNode.getParent() != null) {
				if (AppElements.MERCHANT_CARD.equals(currentNode.getParent().getName())) {
					try {
						if (AppElements.CARD_PRODUCT_ID.equals(currentNode.getName())) {
							currentNode.getParent().getChildByName(AppElements.CARD_TYPE, 1).setValueN((Long) null);
							currentNode.getParent().getChildByName(AppElements.CARD_TYPE, 1).setValueText(null);

							currentNode.getParent().getChildByName(AppElements.CARD_NUMBER, 1).setValueV(null);
							currentNode.getParent().getChildByName(AppElements.CARD_NUMBER, 1).setValueText(null);
						} else if (AppElements.CARD_TYPE.equals(currentNode.getName())) {
							currentNode.getParent().getChildByName(AppElements.CARD_NUMBER, 1).setValueV(null);
							currentNode.getParent().getChildByName(AppElements.CARD_NUMBER, 1).setValueText(null);
						}
					} catch (Exception ignored) {}
				}
			}
		}
	}

	public void applyDependenceWhenChangeValue(ApplicationElement node) {
		dependencesCount = 0;
		if (node != null
				&& node.getDependence() != null
				&& node.getDependence().equals(Boolean.TRUE)) {
			SelectionParams params = new SelectionParams();

			ArrayList<Filter> filtersFlow = new ArrayList<Filter>();

			Filter paramFilter;

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(SessionWrapper.getField("language"));
			filtersFlow.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("structId");
			paramFilter.setValue(node.getStId().toString());
			filtersFlow.add(paramFilter);

			params.setFilters(filtersFlow.toArray(new Filter[filtersFlow
					.size()]));
			params.setRowIndexEnd(-1);
			try {
				dependencesCount = _applicationDao.applyDependences(
						userSessionId, _activeApp, node, node.getParent(),
						params, filtersMap);
				dependencesCount = 1;
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	private String selectId;

	public String getSelectId() {
		if (selectId == null)
			selectId = "selectId";
		return selectId;
	}

	public void setSelectId(String selectId) {
		this.selectId = selectId;
	}

	public String getReRenderElements() {
		if (dependencesCount == 0 &&
			!currentNode.getName().equals(AppElements.COMMAND) &&
			!currentNode.getName().equals(AppElements.CARD_PRODUCT_ID) &&
			!currentNode.getName().equals(AppElements.CARD_TYPE)) {
			return null;
		} else {
			return "appTable";
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public String getSectionId() {
		return SectionIdConstants.ISSUING_APPLICATION;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	private Map<String, Object> getProductLovMap(ApplicationElement element) {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put(AppElements.STATUS, ProductConstants.STATUS_ACTIVE_PRODUCT);

			if (element.getParent().getChildByName(AppElements.CONTRACT_TYPE, 1) != null) {
				String contractType = element.getParent().getChildByName(AppElements.CONTRACT_TYPE, 1).getValueV();
				map.put(AppElements.CONTRACT_TYPE, contractType);
			}
			if (element.getParent().getParent().getParent().getChildByName(AppElements.INSTITUTION_ID, 1) != null) {
				BigDecimal instId = element.getParent().getParent().getParent().getChildByName(AppElements.INSTITUTION_ID, 1).getValueN();
				map.put(AppElements.INSTITUTION_ID, instId.intValue());
			}

			return (map.size() > 0) ? map : null;
		} catch (Exception e) {
			logger.debug("", e);
		}
		return null;
	}

	private ApplicationElement getRootElement(ApplicationElement element) {
		ApplicationElement el = element;
		while (el.getParent() != null) {
			el = el.getParent();
		}
		return el;
	}

	private Map<String, Object> getCardProductLovMap(ApplicationElement element) {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			Long instId = getRootElement(element).getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().longValue();
			if (instId != null) {
				map.put(AppElements.INSTITUTION_ID, instId);
			}
			return (map.size() > 0) ? map : null;
		} catch (Exception ignored) {
			return null;
		}
	}

	private Map<String, Object> getCardTypeLovMap(ApplicationElement element) {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			Long productId = null;
			if (MbApplicationsSearch.CAMPAIGN.equals(getModule())) {
				String productNumber = element.getParent().getParent().getParent().getParent()
											  .getChildByName(AppElements.PRODUCT_NUMBER)
											  .getValueV();
				SelectionParams prdParams = SelectionParams.build("productNumber", productNumber, "lang", userLang);
				Product[] products = _productDao.getProductsList(userSessionId, prdParams);
				productId = products[0].getId();
			} else {
				if (element.getParent() != null && element.getParent().getName().equals(AppElements.MERCHANT_CARD)) {
					ApplicationElement cardProduct = element.getParent().getChildByName(AppElements.CARD_PRODUCT_ID, 1);
					if (cardProduct != null) {
						productId = cardProduct.getValueN() != null ? cardProduct.getValueN().longValue() : null;
					}
				} else {
					productId = getRootElement(element).getChildByName(AppElements.CUSTOMER, 1)
							.getChildByName(AppElements.CONTRACT, 1)
							.getChildByName(AppElements.PRODUCT_ID, 1)
							.getValueN().longValue();
				}
			}
			map.put(AppElements.PRODUCT_ID, productId);
			return (map.size() > 0) ? map : null;
		} catch (Exception ignored) {
			return null;
		}
	}

	private Map<String, Object> getMerchantCardLovMap(ApplicationElement element) {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			Long productId = element.getParent().getChildByName(AppElements.CARD_PRODUCT_ID, 1).getValueN().longValue();
			if (productId != null) {
				map.put(AppElements.PRODUCT_ID, productId);
			}
			Long cardType = element.getParent().getChildByName(AppElements.CARD_TYPE, 1).getValueN().longValue();
			if (cardType != null) {
				map.put(AppElements.CARD_TYPE, cardType);
			}
			return (map.size() > 0) ? map : null;
		} catch (Exception ignored) {
			return null;
		}
	}

	private Map<String, Object> getIdTypeLovMap(ApplicationElement element) {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			String entityType = null;
			if(element != null && element.getParent() != null && element.getParent().getParent() != null) {
				ApplicationElement entity = element.getParent().getParent();
				if(entity.getName().equals(AppElements.PERSON)) {
					entityType = EntityNames.PERSON;
				}
				else if (entity.getName().equals(AppElements.COMPANY)) {
					entityType = EntityNames.COMPANY;
				}
			} else {
				entityType = getRootElement(element).getChildByName(AppElements.CUSTOMER_TYPE, 1).getValueV();
			}
			if (entityType != null && !entityType.equals("")) {
				map.put(AppElements.CUSTOMER_TYPE, entityType);
			}
			Long instId = getRootElement(element).getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().longValue();
			if (instId != null) {
				map.put(AppElements.INSTITUTION_ID, instId);
			}
			return (map.size() > 0) ? map : null;
		} catch (Exception ignored) {
			return null;
		}
	}

	private Map<String, Object> getAccountTypeLovMap(ApplicationElement element) {
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			Long productId = getRootElement(element).getChildByName(AppElements.CUSTOMER, 1)
													.getChildByName(AppElements.CONTRACT, 1)
													.getChildByName(AppElements.PRODUCT_ID, 1)
													.getValueN().longValue();
			if (productId != null) {
				map.put(AppElements.PRODUCT_ID, productId);
			}
			Long instId = getRootElement(element).getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().longValue();
			if (instId != null) {
				map.put(AppElements.INSTITUTION_ID, instId);
			}
			return (map.size() > 0) ? map : null;
		} catch (Exception ignored) {
			return null;
		}
	}

	public SelectItem[] getAutocomplete() {
		try {
			if (currentNode != null && currentNode.getLovId() != null) {
				Map<String, Object> map = null;
				List<SelectItem> out = null;

				if (AppElements.PRODUCT_ID.equals(currentNode.getName())) {
					map = getProductLovMap(currentNode);
				} else if (AppElements.CARD_PRODUCT_ID.equals(currentNode.getName())) {
					map = getCardProductLovMap(currentNode);
				} else if (AppElements.CARD_TYPE.equals(currentNode.getName())) {
					map = getCardTypeLovMap(currentNode);
				} else if (AppElements.CARD_NUMBER.equals(currentNode.getName())) {
					map = getMerchantCardLovMap(currentNode);
				} else if (AppElements.ID_TYPE.equals(currentNode.getName())) {
					map = getIdTypeLovMap(currentNode);
				} else if (AppElements.CURRENCY.equals(currentNode.getName())) {
					map = getCardTypeLovMap(currentNode);
				} else if (AppElements.ACCOUNT_TYPE.equals(currentNode.getName())) {
					map = getAccountTypeLovMap(currentNode);
				}

				if (map == null && !currentNode.getDependent()) {
					out = getDictUtils().getLov(currentNode.getLovId());
				} else if (!currentNode.getDependent()){
					out = getDictUtils().getLov(currentNode.getLovId(), map);
				} else {
					_applicationDao.applyLovDependence(userSessionId, _activeApp, currentNode, map);
				}
				if (out != null) {
					List<KeyLabelItem> items = new ArrayList<KeyLabelItem>(out.size());
					for (SelectItem item : out) {
						items.add(new KeyLabelItem(item.getValue(), item.getLabel()));
					}
					currentNode.setLov(items.toArray(new KeyLabelItem[items.size()]));
				} else if (currentNode.getLov() != null) {
					out = new ArrayList<SelectItem>();
					for (KeyLabelItem item : currentNode.getLov()) {
						out.add(new SelectItem(item.getValue(), item.getLabel(), item.getLabel()));
					}
				}

				return out.toArray(new SelectItem[out.size()]);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new SelectItem[0];
	}

	public SelectItem[] getLov() {
		ApplicationElement el = getCurrentAppElement();
		if (el.getLovId() == null) {
			return new SelectItem[0];
		}
		SelectItem[] siArr = new SelectItem[el.getLov().length];
		for (int i = 0; i < el.getLov().length; i++) {
			KeyLabelItem item = el.getLov()[i];
			SelectItem si = new SelectItem(item.getValue(), item.getLabel());
			siArr[i] = si;
		}

		return siArr;
	}

	public SelectItem[] autocomplete1() {
		ApplicationElement el = currentNode;
		if (el.getLovId() == null) {
			return new SelectItem[0];
		}
		SelectItem[] siArr = new SelectItem[el.getLov().length];
		for (int i = 0; i < el.getLov().length; i++) {
			KeyLabelItem item = el.getLov()[i];
			SelectItem si = new SelectItem(item.getValue(), item.getLabel());
			siArr[i] = si;
		}

		return siArr;
	}

	public String cancel() {
		setKeepState(true);
		try {
			if (isNewMode() || fromNewWizard) {
				logger.trace("Delete application with id [" +
							 ((_activeApp != null) ? _activeApp.getId() : "null") +
							 "] because of cancellation!");
				_activeApp = null;
			}
		} catch (Throwable e) {
			logger.error("", e);
		}
		return backLink;
	}

	public String close() {
		setKeepState(true);
		return backLink;
	}

	public boolean isHasBlocksToAdd() {
		return getCurNodeBlocksToAdd().length != 0;
	}

	public Application getFilter() {
		return filter;
	}

	public void setFilter(Application filter) {
		this.filter = filter;
	}

	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}

	public boolean isRenderList() {
		return renderList;
	}

	public void setRenderList(boolean renderList) {
		this.renderList = renderList;
	}

	public ContractObject[] getContractAccounts() {
		try {
			ContractObject filter = new ContractObject();
			filter.setContractNumber(_activeApp.getContractNumber());
			if (_activeApp.getProductId() != null) {
				filter.setProductId(_activeApp.getProductId());
			}
			if (EntityNames.SERVICE.equals(branchEntity)) {
				if (serviceId == null) {
					return new ContractObject[0];
				}
				ContractObject service = servicesMap.get(serviceId);
				if (service != null && service.isInitial()
						&& EntityNames.CARD.equals(service.getEntityType())) {
					filter.setEntityType(EntityNames.ACCOUNT);
				} else {
					filter.setEntityType(EntityNames.SERVICE);
					filter.setObjectId(serviceId.toString());
				}
			} else if (EntityNames.CARD.equals(branchEntity)) {
				if (cardId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.CARD);
				filter.setObjectId(getCardIdNumber());
			} else if (EntityNames.MERCHANT.equals(branchEntity)) {
				if (merchantId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.MERCHANT);
				filter.setObjectId(getMerchantIdNumber(merchantId));
			} else if (EntityNames.TERMINAL.equals(branchEntity)) {
				if (terminalId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.TERMINAL);
				filter.setObjectId(getTerminalIdNumber());
			}

			accounts = _applicationDao.getContractAccounts(userSessionId,
					filter);

			for (ContractObject acc : accounts) {
				Long dataId = accountNumberDataIdMap.get(acc.getNumber());
				if (dataId != null) {
					acc.setDataId(dataId);
				}
			}

			List<ContractObject> appAccounts = getNewAccountsFromApplication();
			List<ContractObject> temp = new ArrayList<ContractObject>(
					accounts.length + appAccounts.size());
			temp.addAll(appAccounts);
			temp.addAll(Arrays.asList(accounts));
			accounts = temp.toArray(new ContractObject[temp.size()]);

			if (_activeApp.isIssuing() && EntityNames.CARD.equals(branchEntity)) {
				mapContractAccountsWithCards();
			} else if (_activeApp.isAcquiring()
					&& EntityNames.MERCHANT.equals(branchEntity)) {
				mapContractAccountsWithMerchants();
			} else if (_activeApp.isAcquiring()
					&& EntityNames.TERMINAL.equals(branchEntity)) {
				mapContractAccountsWithTerminals();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			accounts = new ContractObject[0];
		}
		return accounts;
	}

	public ContractObject[] getContractCards() {
		try {
			if (_activeApp.isAcquiring()) {
				return new ContractObject[0];
			}
			ContractObject filter = new ContractObject();
			filter.setContractNumber(_activeApp.getContractNumber());
			if (_activeApp.getProductId() != null) {
				filter.setProductId(_activeApp.getProductId());
			}
			if (EntityNames.SERVICE.equals(branchEntity)) {
				if (serviceId == null) {
					return new ContractObject[0];
				}
				ContractObject service = servicesMap.get(serviceId);
				if (service != null && service.isInitial()
						&& EntityNames.ACCOUNT.equals(service.getEntityType())) {
					filter.setEntityType(EntityNames.CARD);
				} else {
					filter.setEntityType(EntityNames.SERVICE);
					filter.setObjectId(serviceId.toString());
				}
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (accountId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.ACCOUNT);
				filter.setObjectId(getAccountIdNumber());
			}
			cards = _applicationDao.getContractCards(userSessionId, filter);

			for (ContractObject card : cards) {
				Long dataId = cardNumberDataIdMap.get(card.getNumber());
				if (dataId != null) {
					card.setDataId(dataId);
				}
			}
			List<ContractObject> appCards = getNewCardsFromApplication();
			List<ContractObject> temp = new ArrayList<ContractObject>(
					cards.length + appCards.size());
			temp.addAll(appCards);
			temp.addAll(Arrays.asList(cards));
			cards = temp.toArray(new ContractObject[temp.size()]);

			if (EntityNames.ACCOUNT.equals(branchEntity)) {
				mapContractObjectsWithAccounts(EntityNames.CARD);
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			cards = new ContractObject[0];
		}
		return cards;
	}

	public ContractObject[] getContractMerchants() {
		try {
			if (_activeApp.isIssuing()) {
				return new ContractObject[0];
			}
			ContractObject filter = new ContractObject();
			filter.setContractNumber(_activeApp.getContractNumber());
			if (_activeApp.getProductId() != null) {
				filter.setProductId(_activeApp.getProductId());
			}
			if (EntityNames.SERVICE.equals(branchEntity)) {
				if (serviceId == null) {
					return new ContractObject[0];
				}
				ContractObject service = servicesMap.get(serviceId);
				if (service != null && service.isInitial()
						&& EntityNames.ACCOUNT.equals(service.getEntityType())) {
					filter.setEntityType(EntityNames.MERCHANT);
				} else {
					filter.setEntityType(EntityNames.SERVICE);
					filter.setObjectId(serviceId.toString());
				}
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (accountId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.ACCOUNT);
				filter.setObjectId(getAccountIdNumber());
			}
			merchants = _applicationDao.getContractMerchants(userSessionId,
					filter);

			for (ContractObject merchant : merchants) {
				Long dataId = merchantNumberDataIdMap.get(merchant.getNumber());
				if (dataId != null) {
					merchant.setDataId(dataId);
				}
			}
			List<ContractObject> appMerchants = getNewMerchantsFromApplication();
			List<ContractObject> temp = new ArrayList<ContractObject>(
					merchants.length + appMerchants.size());
			temp.addAll(appMerchants);
			temp.addAll(Arrays.asList(merchants));
			merchants = temp.toArray(new ContractObject[temp.size()]);

			if (EntityNames.ACCOUNT.equals(branchEntity)) {
				mapContractObjectsWithAccounts(EntityNames.MERCHANT);
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			merchants = new ContractObject[0];
		}
		return merchants;
	}

	public ContractObject[] getContractTerminals() {
		try {
			if (_activeApp.isIssuing()) {
				return new ContractObject[0];
			}
			ContractObject filter = new ContractObject();
			filter.setContractNumber(_activeApp.getContractNumber());
			if (_activeApp.getProductId() != null) {
				filter.setProductId(_activeApp.getProductId());
			}
			if (EntityNames.SERVICE.equals(branchEntity)) {
				if (serviceId == null) {
					return new ContractObject[0];
				}
				ContractObject service = servicesMap.get(serviceId);
				if (service != null && service.isInitial()
						&& EntityNames.ACCOUNT.equals(service.getEntityType())) {
					filter.setEntityType(EntityNames.TERMINAL);
				} else {
					filter.setEntityType(EntityNames.SERVICE);
					filter.setObjectId(serviceId.toString());
				}
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (accountId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.ACCOUNT);
				filter.setObjectId(getAccountIdNumber());
			}
			terminals = _applicationDao.getContractTerminals(userSessionId,
					filter);

			for (ContractObject terminal : terminals) {
				Long dataId = terminalNumberDataIdMap.get(terminal.getNumber());
				if (dataId != null) {
					terminal.setDataId(dataId);
				}
			}
			List<ContractObject> appTerminals = getNewTerminalsFromApplication();
			List<ContractObject> temp = new ArrayList<ContractObject>(
					terminals.length + appTerminals.size());
			temp.addAll(appTerminals);
			temp.addAll(Arrays.asList(terminals));
			terminals = temp.toArray(new ContractObject[temp.size()]);

			if (EntityNames.ACCOUNT.equals(branchEntity)) {
				mapContractObjectsWithAccounts(EntityNames.TERMINAL);
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			terminals = new ContractObject[0];
		}
		return terminals;
	}

	public ContractObject[] getContractServices() {
		try {
			ContractObject filter = new ContractObject();
			filter.setContractNumber(_activeApp.getContractNumber());
			if (_activeApp.getProductId() != null) {
				filter.setProductId(_activeApp.getProductId());
			}
			if (EntityNames.CARD.equals(branchEntity)) {
				if (cardId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.CARD);
				filter.setObjectId(getCardIdNumber());
			} else if (EntityNames.MERCHANT.equals(branchEntity)) {
				if (merchantId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.MERCHANT);
				filter.setObjectId(getMerchantIdNumber(merchantId));
			} else if (EntityNames.TERMINAL.equals(branchEntity)) {
				if (terminalId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.TERMINAL);
				filter.setObjectId(getTerminalIdNumber());
			} else if (EntityNames.ACCOUNT.equals(branchEntity)) {
				if (accountId == null) {
					return new ContractObject[0];
				}
				filter.setEntityType(EntityNames.ACCOUNT);
				filter.setObjectId(getAccountIdNumber());
			} else if (EntityNames.SERVICE.equals(branchEntity)) {
				if (serviceId == null) {
					return new ContractObject[0];
				}
				if (_activeApp.getProductId() != null) {
					filter.setObjectId(_activeApp.getProductId().toString());
				}
				ContractObject service = servicesMap.get(serviceId);
				if (service != null && service.isInitial()) {
					filter.setEntityType(service.getEntityType());
				}
			}
			services = _applicationDao.getContractServices(userSessionId,
					filter);

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			services = new ContractObject[0];
		}
		return services;
	}

	public List<SelectItem> getBranchAccounts() {
		List<ContractObject> appAccounts;
		List<SelectItem> appAccountsItems = null;
		try {
			appAccounts = getNewAccountsFromApplication();
			appAccountsItems = new ArrayList<SelectItem>();
			for (ContractObject acc : appAccounts) {
				appAccountsItems.add(new SelectItem(acc.getNumber() + ";"
						+ acc.getDataId(), acc.getNumber()));
			}
			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (_activeApp != null && _activeApp.getContractNumber() != null
					&& !_activeApp.getContractNumber().equals("")) {
				paramMap.put("CONTRACT_NUMBER", _activeApp.getContractNumber());
				List<SelectItem> items = getDictUtils().getLov(
						LovConstants.APP_BRANCH_ACCOUNTS, paramMap);
				if (items != null && items.size() > 0) {
					appAccountsItems.addAll(0, items);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (appAccountsItems == null) {
				appAccountsItems = new ArrayList<SelectItem>();
			}
		}
		return appAccountsItems;
	}

	public List<SelectItem> getBranchCards() {
		List<ContractObject> appCards;
		List<SelectItem> appCardsItems = null;
		if (_activeApp.isAcquiring()) {
			return new ArrayList<SelectItem>(0);
		}
		try {
			appCards = getNewCardsFromApplication();
			appCardsItems = new ArrayList<SelectItem>();

			for (ContractObject card : appCards) {
				// We have to separate new cards (that are without number) from
				// existing cards in
				// contract
				// so, we add dataId in key value
				appCardsItems.add(new SelectItem(card.getNumber() + ";"
						+ card.getDataId(), card.getNumber()));
			}

			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (_activeApp != null && _activeApp.getContractNumber() != null
					&& !_activeApp.getContractNumber().equals("")) {
				paramMap.put("CONTRACT_NUMBER", _activeApp.getContractNumber());
				List<SelectItem> items = getDictUtils().getLov(
						LovConstants.APP_BRANCH_CARDS, paramMap);
				if (items != null && items.size() > 0) {
					appCardsItems.addAll(0, items);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (appCardsItems == null) {
				appCardsItems = new ArrayList<SelectItem>();
			}
		}
		return appCardsItems;
	}

	public List<SelectItem> getBranchMerchants() {
		List<ContractObject> appMerchants;
		List<SelectItem> appMerchantsItems = null;
		if (_activeApp.isIssuing()) {
			return new ArrayList<SelectItem>(0);
		}
		try {
			appMerchants = getNewMerchantsFromApplication();
			appMerchantsItems = new ArrayList<SelectItem>();

			for (ContractObject merchant : appMerchants) {
				// We have to separate new merchants (that are without number)
				// from existing
				// merchants in contract
				// so, we add dataId in key value
				appMerchantsItems.add(new SelectItem(merchant.getNumber() + ";"
						+ merchant.getDataId(), merchant.getNumber()));
			}

			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (_activeApp != null && _activeApp.getContractNumber() != null
					&& !_activeApp.getContractNumber().equals("")) {
				paramMap.put("CONTRACT_NUMBER", _activeApp.getContractNumber());
				List<SelectItem> items = getDictUtils().getLov(
						LovConstants.APP_BRANCH_MERCHANTS, paramMap);
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

	public List<SelectItem> getBranchTerminals() {
		List<ContractObject> appTerminals;
		List<SelectItem> appTerminalsItems = null;
		if (_activeApp.isIssuing()) {
			return new ArrayList<SelectItem>(0);
		}
		try {
			appTerminals = getNewTerminalsFromApplication();
			appTerminalsItems = new ArrayList<SelectItem>();

			for (ContractObject terminal : appTerminals) {
				// We have to separate new merchants (that are without number)
				// from existing
				// merchants in contract
				// so, we add dataId in key value
				appTerminalsItems.add(new SelectItem(terminal.getNumber() + ";"
						+ terminal.getDataId(), terminal.getNumber()));
			}

			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (_activeApp != null && _activeApp.getContractNumber() != null
					&& !_activeApp.getContractNumber().equals("")) {
				paramMap.put("CONTRACT_NUMBER", _activeApp.getContractNumber());
				List<SelectItem> items = getDictUtils().getLov(
						LovConstants.APP_BRANCH_TERMINALS, paramMap);
				if (items != null && items.size() > 0) {
					appTerminalsItems.addAll(0, items);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (appTerminalsItems == null) {
				appTerminalsItems = new ArrayList<SelectItem>();
			}
		}
		return appTerminalsItems;
	}

	public List<SelectItem> getBranchServices() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (_activeApp != null && _activeApp.getProductId() != null) {
			paramMap.put("PRODUCT_ID", _activeApp.getProductId().toString());
		}
		try {
			return getDictUtils().getLov(LovConstants.APP_BRANCH_SERVICES, paramMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}

	private void initServices() {
		servicesMap = new HashMap<Integer, ContractObject>();
		try {
			ContractObject filter = new ContractObject();
			if (_activeApp.getProductId() != null) {
				filter.setProductId(_activeApp.getProductId());
			}
			if (isProductApp() || isFreqApp()) {
				filter.setInitial(true);
			}
			ContractObject[] servs = _applicationDao.getContractServices(userSessionId, filter);
			for (ContractObject serv : servs) {
				servicesMap.put(serv.getId().intValue(), serv);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<SelectItem> getBranchTypes() {
		if (_activeApp != null) {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (_activeApp.getAppType() != null
					&& !_activeApp.getAppType().equals("")) {
				paramMap.put("APPL_TYPE", _activeApp.getAppType());
			}
			if (_activeApp.getStatus() != null
					&& !_activeApp.getStatus().equals("")) {
				paramMap.put("APPL_STATUS", _activeApp.getStatus());
			}
			if (_activeApp.getFlowId() != null) {
				paramMap.put("FLOW_ID", _activeApp.getFlowId().toString());
			}
			try {
				return getDictUtils().getLov(LovConstants.APP_BRANCH_TYPES, paramMap);
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return new ArrayList<SelectItem>();
	}

	public String getBranchEntity() {
		return branchEntity;
	}

	public void setBranchEntity(String branchEntity) {
		this.branchEntity = branchEntity;
	}

	public Integer getServiceId() {
		return serviceId;
	}

	public void setServiceId(Integer serviceId) {
		this.serviceId = serviceId;
	}

	public Integer getAttrId() {
		return attrId;
	}

	public void setAttrId(Integer attrId) {
		this.attrId = attrId;
	}

	public String getCardId() {
		return cardId;
	}

	public void setCardId(String cardId) {
		this.cardId = cardId;
	}

	private Long getCardIdData() throws Exception {
		if (cardId == null) {
			return null;
		}
		String[] cardDetails = cardId.split(";");
		// 0-card number
		// 1-dataId
		if (cardDetails.length > 1) {
			return Long.parseLong(cardDetails[1]);
		} else {
			return null;
		}
	}

	private String getCardIdNumber() throws Exception {
		if (cardId == null) {
			return null;
		}
		String[] cardDetails = cardId.split(";");
		return cardDetails[0];
	}

	public String getMerchantId() {
		return merchantId;
	}

	public void setMerchantId(String merchantId) {
		this.merchantId = merchantId;
	}

	private Long getMerchantIdData(String merchantId) throws Exception {
		if (merchantId == null) {
			return null;
		}
		String[] merchantDetails = merchantId.split(";");
		// 0-merchant number
		// 1-dataId
		if (merchantDetails.length > 1) {
			return Long.parseLong(merchantDetails[1]);
		} else {
			return null;
		}
	}

	private String getMerchantIdNumber(String merchantId) throws Exception {
		if (merchantId == null) {
			return null;
		}
		String[] merchantDetails = merchantId.split(";");
		return merchantDetails[0];
	}

	private Long getTerminalIdData() throws Exception {
		if (terminalId == null) {
			return null;
		}
		String[] terminalDetails = terminalId.split(";");
		// 0-terminal number
		// 1-dataId
		if (terminalDetails.length > 1) {
			return Long.parseLong(terminalDetails[1]);
		} else {
			return null;
		}
	}

	private String getTerminalIdNumber() throws Exception {
		if (terminalId == null) {
			return null;
		}
		String[] terminalDetails = terminalId.split(";");
		return terminalDetails[0];
	}

	public String getAccountId() {
		return accountId;
	}

	public void setAccountId(String accountId) {
		this.accountId = accountId;
	}

	private Long getAccountIdData() throws Exception {
		if (accountId == null) {
			return null;
		}
		String[] accountDetails = accountId.split(";");
		// 0-card number
		// 1-dataId
		if (accountDetails.length > 1) {
			return Long.parseLong(accountDetails[1]);
		} else {
			return null;
		}
	}

	private String getAccountIdNumber() throws Exception {
		if (accountId == null) {
			return null;
		}
		String[] accountDetails = accountId.split(";");
		return accountDetails[0];
	}

	public boolean isRenderServices() {
		if (branchEntity == null) {
			return false;
		}
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			return service != null && service.isInitial();
		}
		return true;
	}

	public boolean isRenderCardsDivNonInitial() {
		if (_activeApp == null || _activeApp.isAcquiring()) {
			return false;
		}
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			return service != null && !service.isInitial() && EntityNames.CARD.equals(service.getEntityType())
					|| service != null && service.isInitial() && EntityNames.ACCOUNT.equals(service.getEntityType());
		} else if (EntityNames.ACCOUNT.equals(branchEntity)
				&& accountId != null) {
			return true;
		}

		return false;
	}

	public boolean isRenderMerchantsDivNonInitial() {
		if (_activeApp == null || _activeApp.isIssuing()) {
			return false;
		}
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			return service != null && !service.isInitial() && EntityNames.MERCHANT.equals(service.getEntityType())
					|| service != null && service.isInitial() && EntityNames.ACCOUNT.equals(service.getEntityType());
		} else if (EntityNames.ACCOUNT.equals(branchEntity)
				&& accountId != null) {
			return true;
		}

		return false;
	}

	public boolean isRenderTerminalsDivNonInitial() {
		if (_activeApp == null || _activeApp.isIssuing()) {
			return false;
		}
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			return service != null && !service.isInitial() && EntityNames.TERMINAL.equals(service.getEntityType())
					|| service != null && service.isInitial() && EntityNames.ACCOUNT.equals(service.getEntityType());
		} else if (EntityNames.ACCOUNT.equals(branchEntity)
				&& accountId != null) {
			return true;
		}

		return false;
	}

	public boolean isRenderAccountsDivNonInitial() {
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			return service != null && !service.isInitial() && EntityNames.ACCOUNT.equals(service.getEntityType())
					|| service != null && service.isInitial() && (EntityNames.CARD.equals(service.getEntityType())
					|| EntityNames.MERCHANT.equals(service.getEntityType())
					|| EntityNames.TERMINAL.equals(service.getEntityType()));
		} else if ((EntityNames.CARD.equals(branchEntity) && cardId != null)
				|| (EntityNames.MERCHANT.equals(branchEntity) && merchantId != null)
				|| (EntityNames.TERMINAL.equals(branchEntity) && terminalId != null)) {
			return true;
		}

		return false;
	}

	public boolean isRenderParentMerchant() {
		if (_activeApp == null) {
			return false;
		}
		if (_activeApp.isAcquiring()
				&& EntityNames.SERVICE.equals(branchEntity)
				&& serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			if (service != null
					&& service.isInitial()
					&& (EntityNames.MERCHANT.equals(service.getEntityType()) || EntityNames.TERMINAL
							.equals(service.getEntityType()))) {
				return true;
			}
		}
		return false;
	}

	@Deprecated
	public boolean isRenderCardsDivInitial() {
		if (_activeApp == null || _activeApp.isAcquiring()) {
			return false;
		}
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			// Important! For initial service show cards if entity type =
			// ACCOUNT for service type
			if (service != null && service.isInitial()
					&& EntityNames.ACCOUNT.equals(service.getEntityType())) {
				return true;
			}
		}

		return false;
	}

	@Deprecated
	public boolean isRenderMerchantsDivInitial() {
		if (_activeApp == null || _activeApp.isIssuing()) {
			return false;
		}
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			// Important! For initial service show cards if entity type =
			// ACCOUNT for service type
			if (service != null && service.isInitial()
					&& EntityNames.ACCOUNT.equals(service.getEntityType())) {
				return true;
			}
		}

		return false;
	}

	@Deprecated
	public boolean isRenderAccountsDivInitial() {
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			// Important! For initial service show cards if entity type =
			// ACCOUNT for service type
			if (service != null
					&& service.isInitial()
					&& (EntityNames.CARD.equals(service.getEntityType()) || EntityNames.MERCHANT
							.equals(service.getEntityType()))) {
				return true;
			}
		}
		return false;
	}

	public boolean isInitialServiceSelected() {
		if (EntityNames.SERVICE.equals(branchEntity) && serviceId != null) {
			ContractObject service = servicesMap.get(serviceId);
			if (service != null && service.isInitial()) {
				return true;
			}
		}
		return false;
	}

	public Map<Integer, ContractObject> getServicesMap() {
		return servicesMap;
	}

	private ApplicationElement searchMerchantBlock(ApplicationElement whereToAdd, String number, Long dataId) throws Exception {
		boolean found = false;
		ApplicationElement merchantBlock;

		if (dataId == null) {
			if (merchantNumberDataIdMap != null) {
				dataId = merchantNumberDataIdMap.get(number);
			}
		}
		if (dataId == null) {
			merchantBlock = getNewBlock(whereToAdd, AppElements.MERCHANT);
		} else {
			merchantBlock = merchantsMap.get(dataId);
			found = true;
		}
		if (merchantBlock == null) {
			throw new Exception("Cannot add merchant!" + "(" + number + ")");
		}
		if (!found) {
			fillMerchantBlock(number, merchantBlock);
		}

		return merchantBlock;
	}

	private ApplicationElement searchTerminalBlock(ApplicationElement branch,
			String number, Long dataId) throws Exception {
		boolean found = false;
		ApplicationElement terminalBlock;

		if (dataId == null) {
			if (terminalNumberDataIdMap != null) {
				dataId = terminalNumberDataIdMap.get(number);
			}
		}
		if (dataId == null) {
			ApplicationElement whereToAdd = branch;
			if (appTerminalsMap.get(number).getParentNumber() != null) {
				whereToAdd = searchMerchantBlock(branch,
						appTerminalsMap.get(number).getParentNumber(), null);
			}
			terminalBlock = getNewBlock(whereToAdd, AppElements.TERMINAL);
		} else {
			terminalBlock = terminalsMap.get(dataId);
			found = true;
		}
		if (terminalBlock == null) {
			throw new Exception("Cannot add terminal!" + "(" + number + ")");
		}
		if (!found) {
			fillTerminalBlock(number, terminalBlock);
		}

		return terminalBlock;
	}

	@Deprecated
	public void applyTerminalWizard() throws Exception {
		if (appTree == null) {
			return;
		}
		// Getting or adding (if not exists) terminal block for selected
		// terminal
		ApplicationElement contract = findContract();
		ApplicationElement terminalBlock = searchTerminalBlock(contract,
				getTerminalIdNumber(), getTerminalIdData());
		// Getting or adding service and service object
		linkServicesToObject(contract, terminalBlock, services);
		linkAccountsToObject(contract, terminalBlock);
	}

	private void linkServicesToObject(ApplicationElement servicesBranch,
			ApplicationElement linkBlock, ContractObject[] services)
			throws Exception {
		if (servicesBranch == null) {
			return;
		}
		List<ApplicationElement> serviceElements = servicesBranch
				.getChildrenByName(AppElements.SERVICE);
		boolean found;
		boolean foundEmpty;
		for (ContractObject service : services) {
			if (service.isChecked() == service.isCheckedOld()
					&& !service.isEdit()) {
				continue;
			}
			found = false;
			foundEmpty = false;
			ApplicationElement serviceBlock = null;
			for (ApplicationElement servEl : serviceElements) {
				if (servEl.getValueN() != null && servEl.getValueN().longValue() == service.getId()) {
					found = true;
					serviceBlock = servEl;
					break;
				} else if (servEl.getValueN() == null) {
					foundEmpty = true;
					serviceBlock = servEl;
					break;
				}
			}
			if (!found && !foundEmpty) {
				ApplicationFlowFilter serviceFilter = filtersMap.get(10000585);
				if (serviceFilter != null &&
						serviceFilter.getMaxCount() == 0 &&
						serviceFilter.getMinCount() == 0) {
					continue;
				}
				serviceBlock = addBl(AppElements.SERVICE, servicesBranch);
			}
			if (serviceBlock == null) {
				throw new Exception("Cannot add service!");
			}
			if (!found || foundEmpty) {
				fillServiceBlock(service, serviceBlock);
			}
			ApplicationElement serviceObjectEl = addBl(AppElements.SERVICE_OBJECT,
					serviceBlock);
			if (serviceObjectEl == null) {
				throw new Exception("Cannot add service object!");
			}
			fillServiceObjectBlock(service, serviceObjectEl, linkBlock);
		}
	}

	private void linkAccountsToObject(ApplicationElement accountsBranch,
			ApplicationElement linkBlock) throws Exception {
		boolean found;
		for (ContractObject account : accounts) {
			if (account.isChecked() == account.isCheckedOld()) {
				continue;
			}
			found = false;
			ApplicationElement accountBlock = accountsMap.get(account
					.getDataId());

			if (accountBlock == null) {
				accountBlock = addBl(AppElements.ACCOUNT, accountsBranch);
			} else {
				found = true;
			}
			if (accountBlock == null) {
				throw new Exception("Cannot add account!");
			}

			ApplicationElement accountObjectBlock = null;

			if (!found) {
				fillAccountBlock(account, accountBlock);
				accountObjectBlock = addBl(AppElements.ACCOUNT_OBJECT, accountBlock);
			} else {
				found = false;
				List<ApplicationElement> accObjElements = accountBlock
						.getChildrenByName(AppElements.ACCOUNT_OBJECT);
				for (ApplicationElement accObjEl : accObjElements) {
					if (accObjEl.getValueN() != null && accObjEl.getValueN().longValue() == linkBlock.getDataId()) {
						found = true;
						accountObjectBlock = accObjEl;
						break;
					}
				}
				if (!found) {
					accountObjectBlock = addBl(AppElements.ACCOUNT_OBJECT, accountBlock);
				}
			}
			if (accountObjectBlock == null) {
				throw new Exception("Cannot add account object!");
			}

			fillAccountObjectBlock(account, accountObjectBlock, linkBlock);
		}
	}

	@Deprecated
	public void applyAccountWizard() throws Exception {
		if (appTree == null) {
			return;
		}
		// Getting or adding (if not exists) account block for selected account
		ApplicationElement contract = findContract();
		boolean found = false;

		ApplicationElement accountBlock;

		Long dataId = getAccountIdData();
		if (dataId == null) {
			dataId = accountNumberDataIdMap.get(getAccountIdNumber());
		}

		if (dataId == null) {
			// selected account is not presented in application. Moreover it is
			// not a new account
			// and it exists in contract
			accountBlock = addBl(AppElements.ACCOUNT, contract);
		} else {
			accountBlock = accountsMap.get(dataId);
			found = true;
		}

		if (accountBlock == null) {
			throw new Exception("Cannot add account!");
		}
		if (!found) {
			fillAccountBlock(getAccountIdNumber(), accountBlock);
		}
		// Getting or adding service and service object
		linkServicesToObject(contract, accountBlock, services);

		if (_activeApp.isIssuing()) {
			linkCardsToAccount(contract, accountBlock, cards);
		} else if (_activeApp.isAcquiring()) {
			linkMerchantsToAccount(contract, accountBlock, merchants);
			linkTerminalsToAccount(contract, accountBlock, terminals);
		}
	}

	private void linkCardsToAccount(ApplicationElement cardsBranch,
			ApplicationElement accountBlock, ContractObject[] cards)
			throws Exception {
		boolean found;
		for (ContractObject card : cards) {

			if (!card.isChecked() && !card.isCheckedOld()) {
				continue;
			}
			found = false;
			ApplicationElement cardBlock = cardsMap.get(card.getDataId());

			if (cardBlock == null) {
				cardBlock = addBl(AppElements.CARD, cardsBranch);
			} else {
				found = true;
			}
			if (cardBlock == null) {
				throw new Exception("Cannot add card!");
			}
			if (!found) {
				fillCardBlock(card, cardBlock);
			}
			found = false;
			ApplicationElement accountObjectBlock = null;
			List<ApplicationElement> accObjElements = accountBlock
					.getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for (ApplicationElement accObjEl : accObjElements) {
				if (accObjEl.getValueN() != null && accObjEl.getValueN().longValue() == cardBlock.getDataId()) {
					found = true;
					accountObjectBlock = accObjEl;
					break;
				}
			}
			if (!found) {
				accountObjectBlock = addBl(AppElements.ACCOUNT_OBJECT, accountBlock);
			}
			if (accountObjectBlock == null) {
				throw new Exception("Cannot add account object!");
			}
			boolean isChecked = card.isChecked();
			fillAccountObjectBlock(accountObjectBlock, cardBlock, isChecked);
		}
	}

	private void linkMerchantsToAccount(ApplicationElement merchantsBranch,
			ApplicationElement accountBlock, ContractObject[] merchants)
			throws Exception {
		boolean found;
		for (ContractObject merchant : merchants) {

			if (merchant.isChecked() == merchant.isCheckedOld()) {
				continue;
			}
			ApplicationElement merchantBlock = findAndAddMerchant(merchant,
					merchantsBranch);

			found = false;
			ApplicationElement accountObjectBlock = null;
			List<ApplicationElement> accObjElements = accountBlock
					.getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for (ApplicationElement accObjEl : accObjElements) {
				if (accObjEl.getValueN() != null && accObjEl.getValueN().longValue() == merchantBlock.getDataId()) {
					found = true;
					accountObjectBlock = accObjEl;
					break;
				}
			}
			if (!found) {
				accountObjectBlock = addBl(AppElements.ACCOUNT_OBJECT, accountBlock);
			}
			if (accountObjectBlock == null) {
				throw new Exception("Cannot add account object!");
			}
			boolean isChecked = merchant.isChecked();
			fillAccountObjectBlock(accountObjectBlock, merchantBlock, isChecked);
		}
	}

	private void linkTerminalsToAccount(ApplicationElement merchantsBranch,
			ApplicationElement accountBlock, ContractObject[] terminals)
			throws Exception {
		boolean found;
		for (ContractObject terminal : terminals) {

			if (terminal.isChecked() == terminal.isCheckedOld()) {
				continue;
			}
			found = false;
			ApplicationElement terminalBlock = terminalsMap.get(terminal
					.getDataId());
			if (terminalBlock == null) {
				// terminal not found in application. Add terminal's merchant
				// block
				// and then add terminal block to that merchant
				ApplicationElement whereToAdd = merchantsBranch;
				if (terminal.getParentNumber() != null) {
					whereToAdd = searchMerchantBlock(merchantsBranch,
							terminal.getParentNumber(), null);
				}
				terminalBlock = addBl(AppElements.TERMINAL, whereToAdd);
			} else {
				found = true;
			}
			if (terminalBlock == null) {
				throw new Exception("Cannot add terminal!");
			}
			if (!found) {
				fillTerminalBlock(terminal, terminalBlock);
			}
			found = false;
			ApplicationElement accountObjectBlock = null;
			List<ApplicationElement> accObjElements = accountBlock
					.getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for (ApplicationElement accObjEl : accObjElements) {
				if (accObjEl.getValueN() != null && accObjEl.getValueN().longValue() == terminalBlock.getDataId()) {
					found = true;
					accountObjectBlock = accObjEl;
					break;
				}
			}
			if (!found) {
				accountObjectBlock = addBl(AppElements.ACCOUNT_OBJECT, accountBlock);
			}
			if (accountObjectBlock == null) {
				throw new Exception("Cannot add account object!");
			}
			boolean isChecked = terminal.isChecked();
			fillAccountObjectBlock(accountObjectBlock, terminalBlock, isChecked);
		}
	}

	private void linkCardsToService(ApplicationElement cardsBranch,
			ApplicationElement serviceBlock, ContractObject service)
			throws Exception {
		boolean found;
		for (ContractObject card : cards) {
			if (card.isChecked() == card.isCheckedOld()) {
				continue;
			}
			found = false;
			ApplicationElement cardBlock = cardsMap.get(card.getDataId());

			if (cardBlock == null) {
				cardBlock = addBl(AppElements.CARD, cardsBranch);
			} else {
				found = true;
			}
			if (cardBlock == null) {
				throw new Exception("Cannot add card!");
			}
			if (!found) {
				fillCardBlock(card, cardBlock);
			}

			ApplicationElement serviceObjectBlock;
			serviceObjectBlock = addBl(AppElements.SERVICE_OBJECT, serviceBlock);

			if (serviceObjectBlock == null) {
				throw new Exception("Cannot add service object!");
			}
			fillServiceObjectBlock(service, serviceObjectBlock, cardBlock);
		}
	}

	private void linkMerchantsToService(ApplicationElement merchantsBranch,
			ApplicationElement serviceBlock, ContractObject service)
			throws Exception {
		for (ContractObject merchant : merchants) {
			if (merchant.isChecked() == merchant.isCheckedOld()) {
				continue;
			}
			ApplicationElement merchantBlock = findAndAddMerchant(merchant,
					merchantsBranch);
			ApplicationElement serviceObjectBlock;
			serviceObjectBlock = addBl(AppElements.SERVICE_OBJECT, serviceBlock);

			if (serviceObjectBlock == null) {
				throw new Exception("Cannot add service object!");
			}
			fillServiceObjectBlock(service, serviceObjectBlock, merchantBlock);
		}
	}

	private ApplicationElement findAndAddMerchant(ContractObject merch,
			ApplicationElement whereToAdd) throws Exception {
		boolean found = false;
		ApplicationElement merchantBlock = merchantsMap.get(merch.getDataId());

		if (merchantBlock == null) {
			merchantBlock = addBl(AppElements.MERCHANT, whereToAdd);
		} else {
			found = true;
		}
		if (merchantBlock == null) {
			throw new Exception("Cannot add merchant!");
		}
		if (!found) {
			fillMerchantBlock(merch, merchantBlock);
		}
		return merchantBlock;
	}

	private void linkTerminalsToService(ApplicationElement merchantsBranch,
			ApplicationElement serviceBlock, ContractObject service)
			throws Exception {
		boolean found;
		for (ContractObject terminal : terminals) {
			if (terminal.isChecked() == terminal.isCheckedOld()) {
				continue;
			}
			found = false;
			ApplicationElement terminalBlock = terminalsMap.get(terminal
					.getDataId());
			if (terminalBlock == null) {
				// terminal not found in application. Add terminal's merchant
				// block
				// and then add terminal block to that merchant
				ApplicationElement whereToAdd = merchantsBranch;
				if (terminal.getParentNumber() != null) {
					whereToAdd = searchMerchantBlock(merchantsBranch,
							terminal.getParentNumber(), null);
				}
				terminalBlock = addBl(AppElements.TERMINAL, whereToAdd);
			} else {
				found = true;
			}
			if (terminalBlock == null) {
				throw new Exception("Cannot add merchant!");
			}
			if (!found) {
				fillTerminalBlock(terminal, terminalBlock);
			}

			ApplicationElement serviceObjectBlock;
			serviceObjectBlock = addBl(AppElements.SERVICE_OBJECT, serviceBlock);

			if (serviceObjectBlock == null) {
				throw new Exception("Cannot add service object!");
			}
			fillServiceObjectBlock(service, serviceObjectBlock, terminalBlock);
		}
	}

	private void linkAccountsToService(ApplicationElement accountsBranch,
			ApplicationElement serviceBlock, ContractObject service)
			throws Exception {
		boolean found;
		for (ContractObject acc : accounts) {
			if (acc.isChecked() == acc.isCheckedOld()) {
				continue;
			}
			found = false;
			ApplicationElement accountBlock = accountsMap.get(acc.getDataId());

			if (accountBlock == null) {
				accountBlock = addBl(AppElements.ACCOUNT, accountsBranch);
			} else {
				found = true;
			}
			if (accountBlock == null) {
				throw new Exception("Cannot add accounts!");
			}
			if (!found) {
				fillAccountBlock(acc, accountBlock);
			}
			ApplicationElement serviceObjectBlock;
			serviceObjectBlock = addBl(AppElements.SERVICE_OBJECT, serviceBlock);

			if (serviceObjectBlock == null) {
				throw new Exception("Cannot add service object!");
			}
			fillServiceObjectBlock(service, serviceObjectBlock, accountBlock);
		}
	}

	private void resetCount() throws Exception {
		step = ApplicationConstants.DATA_SEQUENCE_STEP;
		//noinspection ConstantConditions
		if (step <= 0) {
			throw new Exception("Invalid data sequence step");
		}
		currVal = _applicationDao.getNextDataId(userSessionId, _activeApp.getId());
		currVal = currVal - step;
		count = 0;
	}

	private long getDataId() throws Exception {
		if (count >= step) {
			// need more dataIds from sequence
			resetCount();
		}
		count++;
		return currVal + count;
	}

	long currVal = 0;
	int step = 0;
	int count = 0;

	private void fillContractBlock(ApplicationElement contractBlock,
			Application app) throws Exception {
		contractBlock.setDataId(getDataId());
		if (app.getContractNumber() == null
				|| app.getContractNumber().equals("")) {
			// this is new contract
			fillCommand(contractBlock,
					ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
		} else {
			// contract exists
			fillCommand(contractBlock,
					ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		}
		ApplicationElement contractType = contractBlock.getChildByName(AppElements.CONTRACT_TYPE, 1);
		contractType.setValueV(app.getContractType());
		ApplicationElement productId = contractBlock.getChildByName(AppElements.PRODUCT_ID, 1);
		productId.setValueN(new BigDecimal(app.getProductId()));
		contractBlock.getChildByName(AppElements.CONTRACT_NUMBER, 1).setValueV(
				app.getContractNumber());

		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				contractBlock, filtersMap);
	}

	private void fillCustomerBlock(ApplicationElement customerBlock,
			Application app) throws Exception {
		customerBlock.setDataId(getDataId());
		if (app.getCustomerNumber() == null
				|| app.getCustomerNumber().equals("")) {
			// this is new contract
			fillCommand(customerBlock,
					ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
		} else {
			// contract exists
			fillCommand(customerBlock,
					ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		}
		customerBlock.getChildByName(AppElements.CUSTOMER_NUMBER, 1).setValueV(
				app.getCustomerNumber());
		if (app.getExtCustomerType() != null){
			customerBlock.getChildByName(AppElements.CUSTOMER_EXT_TYPE, 1)
				.setValueV(app.getExtCustomerType());
			if (SERVICE_PROVIDER.equalsIgnoreCase(app.getExtCustomerType())){
				customerBlock.getChildByName(AppElements.CUSTOMER_EXT_ID, 1)
					.setValueN(app.getExtObjectId().intValue());
			} else if (AGENT.equalsIgnoreCase(app.getExtCustomerType())){
				customerBlock.getChildByName(AppElements.CUSTOMER_EXT_ID, 1)
					.setValueN(app.getAgentId());
			} else if (INST.equalsIgnoreCase(app.getExtCustomerType())){
				customerBlock.getChildByName(AppElements.CUSTOMER_EXT_ID, 1)
					.setValueN(app.getInstId());
			}
		}
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				customerBlock, filtersMap);
		if (customerBlock.getChildByName(
				AppElements.PERSON, 0) != null &&
				customerBlock.getChildByName(
						AppElements.PERSON, 0).isPossibleToAdd()){
			ApplicationElement personBlock = customerBlock.getChildByName(
					AppElements.PERSON, 1);
			if (personBlock == null) {
				personBlock = addBl(AppElements.PERSON, customerBlock, null, false);
				if (personBlock == null) {
					throw new Exception("Cannot create customer person");
				}
				personBlock.setDataId(getDataId());
			}
		}
	}

	private void fillCardBlock(ContractObject card, ApplicationElement cardBlock)
			throws Exception {
		fillCommand(cardBlock, ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		ApplicationElement ae = cardBlock.getChildByName(AppElements.CARD_NUMBER, 1);
		ae.setValueV(card.getNumber());
		ae.setMask(card.getMask());
		cardBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				cardBlock, filtersMap);
		cardsMap.put(cardBlock.getDataId(), cardBlock);
		cardNumberDataIdMap.put(card.getNumber(), cardBlock.getDataId());
	}

	private void fillCardBlock(String cardNumber, String mask, ApplicationElement cardBlock)
			throws Exception {
		fillCommand(cardBlock, ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		ApplicationElement ae = cardBlock.getChildByName(AppElements.CARD_NUMBER, 1);
		ae.setValueV(cardNumber);
		ae.setMask(mask);
		cardBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				cardBlock, filtersMap);
		cardsMap.put(cardBlock.getDataId(), cardBlock);
		cardNumberDataIdMap.put(cardNumber, cardBlock.getDataId());
	}

	private void fillNewCardBlock(ApplicationElement cardBlock)
			throws Exception {
		fillCommand(cardBlock, ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
		// cardBlock.getChildByName(AppElements.CARD_NUMBER,
		// 1).setValueV(cardBlock.getBlockName());
		cardBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				cardBlock, filtersMap);
		cardsMap.put(cardBlock.getDataId(), cardBlock);
	}

	private void initCardHolder(ApplicationElement cardBlock) throws Exception{
		ApplicationFlowFilter filter = filtersMap.get(CARDHOLDER_ID);
		if (filter != null  && !filter.getVisible()){
			return;
		}

		ApplicationElement cardholder =
				addElement(cardBlock, AppElements.CARDHOLDER);

		filter = filtersMap.get(CONTACT_ID);

		if (filter != null && filter.getVisible() && filter.getMinCount() != 0){
			addElement(cardholder, AppElements.CONTACT);
		}

		filter = filtersMap.get(PERSON_ID);
		if (filter != null && filter.getVisible() && filter.getMinCount() != 0){
			addElement(cardholder, AppElements.PERSON);
		}

		if (_activeApp.isIssuing()) {
			ApplicationElement cardNumber = cardBlock.getChildByName(AppElements.CARD_NUMBER, 1);
			if (cardNumber != null && StringUtils.isNotEmpty(cardNumber.getValueV())) {
				Cardholder c = _issuingDao.getCardholder(userSessionId, cardNumber.getValueV());
				if (c != null) {
					ApplicationElement ae = cardholder.getChildByName(AppElements.CARDHOLDER_NUMBER, 1);
					if (ae != null) {
						ae.setValueV(c.getCardholderNumber());
					}
					ae = cardholder.getChildByName(AppElements.CARDHOLDER_NAME, 1);
					if (ae != null) {
						ae.setValueV(c.getCardholderName());
					}
				}
			}
		}
	}

	/*
	 * function to add new element, which can't be added in fillRootChilds because it has
	 * entity_type, which used in flexible field
	 * @param parentElement  element to which be added new element
	 * @param nameNewElement element name
	 * @result new element
	 */
	private ApplicationElement addElement(ApplicationElement parentElement, String nameNewElement)throws Exception{
		ApplicationElement newElementBlock = parentElement.getChildByName(
				nameNewElement, 1);
		if (newElementBlock == null) {
			newElementBlock = addBl(nameNewElement, parentElement, null, false);
			if (newElementBlock == null) {
				throw new Exception("Cannot create " + nameNewElement + " block");
			}
			newElementBlock.setDataId(getDataId());

			_applicationDao.fillAppElementChilds(userSessionId, _activeApp.getInstId(), newElementBlock);
			_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
					newElementBlock, filtersMap);
			_applicationDao.setPathForSubtree(newElementBlock);
		}
		return newElementBlock;
	}

	private void fillMerchantBlock(ContractObject merchant, ApplicationElement merchantBlock) throws Exception {
		fillCommand(merchantBlock, ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		merchantBlock.getChildByName(AppElements.MERCHANT_NUMBER, 1).setValueV(merchant.getNumber());
		merchantBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp, merchantBlock, filtersMap);
		merchantsMap.put(merchantBlock.getDataId(), merchantBlock);
		merchantNumberDataIdMap.put(merchant.getNumber(), merchantBlock.getDataId());
	}

	private void fillMerchantBlock(String merchantNumber, ApplicationElement merchantBlock) throws Exception {
		fillCommand(merchantBlock, ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		merchantBlock.getChildByName(AppElements.MERCHANT_NUMBER, 1).setValueV(merchantNumber);
		merchantBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp, merchantBlock, filtersMap);
		merchantsMap.put(merchantBlock.getDataId(), merchantBlock);
		merchantNumberDataIdMap.put(merchantNumber, merchantBlock.getDataId());
	}

	private void fillNewMerchantBlock(ApplicationElement merchantBlock)
			throws Exception {
		fillCommand(merchantBlock,
				ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
		merchantBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				merchantBlock, filtersMap);
		// After initiate Merchant node, set default status "Active"
		KeyLabelItem[] statusList = merchantBlock.getChildByName(AppElements.MERCHANT_STATUS, 1).getLov();
		if (statusList != null && statusList.length > 0) {
			if (statusList[0].getValue() instanceof String) {
				merchantBlock.getChildByName(AppElements.MERCHANT_STATUS, 1).setValueV((String) statusList[0].getValue());
			}
		}
		merchantsMap.put(merchantBlock.getDataId(), merchantBlock);
	}

	private void fillTerminalBlock(ContractObject terminal,
			ApplicationElement terminalBlock) throws Exception {
		fillCommand(terminalBlock,
				ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		terminalBlock.getChildByName(AppElements.TERMINAL_NUMBER, 1).setValueV(
				terminal.getNumber());
		terminalBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				terminalBlock, filtersMap);
		terminalsMap.put(terminalBlock.getDataId(), terminalBlock);
		terminalNumberDataIdMap.put(terminal.getNumber(),
				terminalBlock.getDataId());
		configureTerminalAp(terminalBlock);
	}

	private void fillTerminalBlock(String terminalNumber,
			ApplicationElement terminalBlock) throws Exception {
		fillCommand(terminalBlock,
				ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		terminalBlock.getChildByName(AppElements.TERMINAL_NUMBER, 1).setValueV(
				terminalNumber);
		terminalBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				terminalBlock, filtersMap);
		terminalsMap.put(terminalBlock.getDataId(), terminalBlock);
		terminalNumberDataIdMap.put(terminalNumber, terminalBlock.getDataId());
		configureTerminalAp(terminalBlock);
	}

	private void configureTerminalAp(ApplicationElement terminalAp) {
		Filter[] filters = new Filter[1];
		Filter filter = new Filter();
		filter.setElement("terminalNumber");
		String terminalNumber = terminalAp.getChildByName(
				AppElements.TERMINAL_NUMBER, 1).getValueV();
		filter.setValue(terminalNumber);
		filters[0] = filter;
		SelectionParams sp = new SelectionParams();
		sp.setFilters(filters);
		Terminal[] terminals = acquiringDao.getTerminals(userSessionId, sp);
		if (terminals.length > 0) {
			ApplicationElement terminalTypeAp = terminalAp.getChildByName(AppElements.TERMINAL_TYPE, 1);
			terminalTypeAp.setValueV(terminals[0].getTerminalType());
			applyDependenceWhenChangeValue(terminalTypeAp);
			fillTerminalAddresses(terminalAp, terminals[0]);
		}
	}

	private void fillTerminalAddresses(ApplicationElement terminalAp, Terminal terminal) {
		assert terminalAp != null && terminal != null;

		SelectionParams asp = SelectionParams.build("currentLang", curLang, "objectId", terminal.getId(), "entityType",
				EntityNames.TERMINAL);
		Address[] addresses = _commonDao.getAddresses(userSessionId, asp, curLang);
		if (addresses.length > 0) {
			// set the main address
			ApplicationElement mainAddr = terminalAp.getChildByName(AppElements.ADDRESS, 1);
			ApplicationUtils.formatAddressElement(mainAddr, addresses[0]);
			applyDependenceWhenChangeValue(mainAddr);

			// if there are more than 1 address, add additional blocks and fill them
			ApplicationElement templateAddr = terminalAp.getChildByName(AppElements.ADDRESS, 0);
			for (int i = 1; i < addresses.length; i++) {
				try {
					ApplicationElement addlAddr = addBl(AppElements.ADDRESS, terminalAp, templateAddr);
					ApplicationUtils.formatAddressElement(addlAddr, addresses[i]);
					applyDependenceWhenChangeValue(addlAddr);
				} catch (Exception e) {
					logger.warn("Unable to add an additional address", e);
				}
			}
		}
	}

	private void fillNewTerminalBlock(ApplicationElement terminalBlock)
			throws Exception {
		fillCommand(terminalBlock,
				ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
		terminalBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				terminalBlock, filtersMap);
		terminalsMap.put(terminalBlock.getDataId(), terminalBlock);
	}

	private void fillAccountBlock(ContractObject account,
			ApplicationElement accountBlock) throws Exception {
		fillCommand(accountBlock,
				ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		accountBlock.getChildByName(AppElements.ACCOUNT_NUMBER, 1).setValueV(
				account.getNumber());
		accountBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				accountBlock, filtersMap);
		// Add new account block to map
		accountsMap.put(accountBlock.getDataId(), accountBlock);
		accountNumberDataIdMap.put(account.getNumber(),
				accountBlock.getDataId());
	}

	private void fillAccountBlock(String accountNumber,
			ApplicationElement accountBlock) throws Exception {
		fillCommand(accountBlock,
				ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		accountBlock.getChildByName(AppElements.ACCOUNT_NUMBER, 1).setValueV(
				accountNumber);
		accountBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				accountBlock, filtersMap);
		// Add new account block to map
		accountsMap.put(accountBlock.getDataId(), accountBlock);
		accountNumberDataIdMap.put(accountNumber, accountBlock.getDataId());
	}

	private void fillNewAccountBlock(ApplicationElement accountBlock)
			throws Exception {
		fillCommand(accountBlock, ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
		// ApplicationElement accNumber =
		// accountBlock.getChildByName(AppElements.ACCOUNT_NUMBER, 1);
		// accNumber.setValueV(accountBlock.getBlockName());
		accountBlock.setDataId(getDataId());
		_applicationDao.applyDependencesWhenAdd(userSessionId, _activeApp,
				accountBlock, filtersMap);
		accountsMap.put(accountBlock.getDataId(), accountBlock);
	}

	private void fillAccountObjectBlock(ApplicationElement accountObjectBlock,
	                                    ApplicationElement linkBlock, boolean isChecked) throws Exception {
		long flag = isChecked ? 1 : 0;
		accountObjectBlock.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).setValueN(
				BigDecimal.valueOf(flag));
		accountObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.getDataId()));
		accountObjectBlock.setValueText(linkBlock.getBlockName());
		accountObjectBlock.setFake(true);
	}

	private void fillAccountObjectBlock(ContractObject account,
			ApplicationElement accountObjectBlock, ApplicationElement linkBlock)
			throws Exception {
		long flag = account.isChecked() ? 1 : 0;
		accountObjectBlock.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).setValueN(
				BigDecimal.valueOf(flag));
		accountObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.getDataId()));
		accountObjectBlock.setValueText(linkBlock.getBlockName());
		accountObjectBlock.setFake(true);
	}

	private void fillServiceBlock(ContractObject service, ApplicationElement serviceBlock) throws Exception {
		KeyLabelItem[] lov = getDictUtils().getLovItems(serviceBlock.getLovId());
		serviceBlock.setLov(lov);
		serviceBlock.setValueN(BigDecimal.valueOf(service.getId()));
	}

	private void fillServiceBlock(Integer serviceId, ApplicationElement serviceBlock) throws Exception {
		if (serviceBlock.getLovId() != null) {
			KeyLabelItem[] lov = getDictUtils().getLovItems(serviceBlock.getLovId());
			serviceBlock.setLov(lov);
		}
		serviceBlock.setValueN(new BigDecimal(serviceId));
	}

	private void fillServiceObjectBlock(ContractObject service, ApplicationElement serviceObjectBlock, ApplicationElement linkBlock)
			throws Exception {
		// this is a link to block
		serviceObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.getDataId()));
		serviceObjectBlock.setFake(true);
		serviceObjectBlock.setValueText(linkBlock.getBlockName());
		if (service.isChecked()) {
			// if one wants to enable service then set start date as now
			serviceObjectBlock.getChildByName(AppElements.START_DATE, 1).setValueD(
					new Date());
			ProductAttribute[] attrs = getServiceAttributes(service.getId()
					.intValue());
			for (ProductAttribute attr : attrs) {
				if (ProductAttribute.DEF_LEVEL_OBJECT
						.equals(attr.getDefLevel())) {
					addAttribute(attr.getId(), serviceObjectBlock, true);
				}
			}
		} else {
			// if one wants to disable service then set end date as now
			serviceObjectBlock.getChildByName(AppElements.END_DATE, 1).setValueD(
					new Date());
		}
	}

	private void fillCommand(ApplicationElement parent, String command)
			throws Exception {
		if (parent.getChildByName(AppElements.COMMAND, 1).getValueV() == null) {
			parent.getChildByName(AppElements.COMMAND, 1).setValueV(command);
		}
	}

	// Account branch is selected
	private void mapContractObjectsWithAccounts(String entityType) throws Exception {
		// Find account block for selected account in branch (accountId)

		Long accDataId = getAccountIdData();
		if (accDataId == null) {
			// this is not a new account
			accDataId = accountNumberDataIdMap.get(getAccountIdNumber());
		}
		if (accDataId == null) {
			// Cannot find account block
			return;
		}
		ApplicationElement accountBlock = accountsMap.get(accDataId);
		if (accountBlock == null) {
			return;
		}
		// Block is found. Get its links with cards
		List<ApplicationElement> accObjElements = accountBlock
				.getChildrenByName(AppElements.ACCOUNT_OBJECT);
		findContract(); // it throws exception if contract or customer not found
		for (ApplicationElement accObjEl : accObjElements) {
			if (accObjEl.getValueN() != null) {
				Long dataId = accObjEl.getValueN().longValue();
				if (accObjEl.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).getValueN() == null) {
					break;
				}
				boolean isChecked = accObjEl.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).getValueN().intValue() == 1;

				if (EntityNames.CARD.equals(entityType)) {
					for (ContractObject cardObj : cards) {
						if (dataId.equals(cardObj.getDataId())) {
							cardObj.setChecked(isChecked);
							cardObj.setCheckedOld(isChecked);
							break;
						}
					}
				} else if (EntityNames.MERCHANT.equals(entityType)) {
					for (ContractObject merchantObj : merchants) {
						if (dataId.equals(merchantObj.getDataId())) {
							merchantObj.setChecked(isChecked);
							merchantObj.setCheckedOld(isChecked);
							break;
						}
					}
				} else if (EntityNames.TERMINAL.equals(entityType)) {
					for (ContractObject terminalObj : terminals) {
						if (dataId.equals(terminalObj.getDataId())) {
							terminalObj.setChecked(isChecked);
							terminalObj.setCheckedOld(isChecked);
							break;
						}
					}
				}
			}
		}
	}

	// Card branch is selected
	private void mapContractAccountsWithCards() throws Exception {
		// Find card block for selected card in branch
		Long dataId = getCardIdData();

		if (dataId == null) {
			// This is not a new card
			dataId = cardNumberDataIdMap.get(getCardIdNumber());
		}

		if (dataId == null) {
			// Cannot find card block
			return;
		}
		ApplicationElement contract = findContract();
		List<ApplicationElement> accountElements = contract
				.getChildrenByName(AppElements.ACCOUNT);
		for (ApplicationElement accountEl : accountElements) {
			Long accDataId = accountEl.getDataId();
			List<ApplicationElement> accObjElements = accountEl
					.getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for (ApplicationElement accObjEl : accObjElements) {
				if (accObjEl.getValueN() != null
						&& dataId.equals(accObjEl.getValueN().longValue())) {

					if (accObjEl.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1)
							.getValueN() == null) {
						break;
					}
					boolean isChecked = accObjEl
							.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).getValueN()
							.intValue() == 1;

					// Iterate through contract accounts to change flag
					for (ContractObject accObj : accounts) {
						if (accDataId.equals(accObj.getDataId())) {
							accObj.setChecked(isChecked);
							accObj.setCheckedOld(isChecked);
							break;
						}
					}
					break;
				}
			}
		}
	}

	// Merchant branch is selected
	private void mapContractAccountsWithMerchants() throws Exception {
		// Find merchant block for selected merchant in branch
		Long dataId = getMerchantIdData(merchantId);

		if (dataId == null) {
			// This is not a new merchant
			dataId = merchantNumberDataIdMap
					.get(getMerchantIdNumber(merchantId));
		}

		if (dataId == null) {
			// Cannot find merchant block
			return;
		}
		ApplicationElement contract = findContract();
		List<ApplicationElement> accountElements = contract
				.getChildrenByName(AppElements.ACCOUNT);
		for (ApplicationElement accountEl : accountElements) {
			Long accDataId = accountEl.getDataId();
			List<ApplicationElement> accObjElements = accountEl
					.getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for (ApplicationElement accObjEl : accObjElements) {
				if (accObjEl.getValueN() != null
						&& dataId.equals(accObjEl.getValueN().longValue())) {

					if (accObjEl.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1)
							.getValueN() == null) {
						break;
					}
					boolean isChecked = accObjEl
							.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).getValueN()
							.intValue() == 1;

					// Iterate through contract accounts to change flag
					for (ContractObject accObj : accounts) {
						if (accDataId.equals(accObj.getDataId())) {
							accObj.setChecked(isChecked);
							accObj.setCheckedOld(isChecked);
							break;
						}
					}
					break;
				}
			}
		}
	}

	// Terminals branch is selected
	private void mapContractAccountsWithTerminals() throws Exception {
		// Find terminal block for selected terminal in branch
		Long dataId = getTerminalIdData();

		if (dataId == null) {
			// This is not a new terminal
			dataId = terminalNumberDataIdMap.get(getTerminalIdNumber());
		}

		if (dataId == null) {
			// Cannot find terminal block
			return;
		}
		ApplicationElement contract = findContract();
		List<ApplicationElement> accountElements = contract
				.getChildrenByName(AppElements.ACCOUNT);
		for (ApplicationElement accountEl : accountElements) {
			Long accDataId = accountEl.getDataId();
			List<ApplicationElement> accObjElements = accountEl
					.getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for (ApplicationElement accObjEl : accObjElements) {
				if (accObjEl.getValueN() != null
						&& dataId.equals(accObjEl.getValueN().longValue())) {

					if (accObjEl.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1)
							.getValueN() == null) {
						break;
					}
					boolean isChecked = accObjEl
							.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).getValueN()
							.intValue() == 1;

					// Iterate through contract accounts to change flag
					for (ContractObject accObj : accounts) {
						if (accDataId.equals(accObj.getDataId())) {
							accObj.setChecked(isChecked);
							accObj.setCheckedOld(isChecked);
							break;
						}
					}
					break;
				}
			}
		}
	}

	private List<ContractObject> getNewCardsFromApplication() throws Exception {
		List<ContractObject> objects;
		ApplicationElement contract = findContract();
		List<ApplicationElement> cardElements = contract
				.getChildrenByName(AppElements.CARD);
		objects = new ArrayList<ContractObject>();
		for (ApplicationElement el : cardElements) {
			if (ApplicationConstants.COMMAND_CREATE_OR_EXCEPT.equals(el
					.getChildByName(AppElements.COMMAND, 1).getValueV())) {
				ContractObject obj = new ContractObject();
				obj.setId(1L);
				obj.setNumber(el.getBlockName());
				obj.setDataId(el.getDataId());
				objects.add(obj);
			}
		}
		return objects;
	}

	private List<ContractObject> getNewMerchantsFromApplication()
			throws Exception {
		List<ContractObject> objects;
		ApplicationElement contract = findContract();
		objects = new ArrayList<ContractObject>();
		collectNewMerchantsFromApplication(contract, objects);
		return objects;
	}

	private void collectNewMerchantsFromApplication(ApplicationElement root,
			List<ContractObject> objects) throws Exception {
		List<ApplicationElement> merchantElements = root
				.getChildrenByName(AppElements.MERCHANT);
		if (merchantElements.size() > 0 && objects == null) {
			objects = new ArrayList<ContractObject>();
		}
		for (ApplicationElement el : merchantElements) {
			if (ApplicationConstants.COMMAND_CREATE_OR_EXCEPT.equals(el
					.getChildByName(AppElements.COMMAND, 1).getValueV())) {
				ContractObject obj = new ContractObject();
				obj.setId(1L);
				obj.setNumber(el.getBlockName());
				obj.setLabel(el.getBlockName());
				obj.setDataId(el.getDataId());
				objects.add(obj);
			}
			collectNewMerchantsFromApplication(el, objects);
		}
	}

	private List<ContractObject> getNewTerminalsFromApplication()
			throws Exception {
		List<ContractObject> objects;
		ApplicationElement contract = findContract();
		objects = new ArrayList<ContractObject>();
		collectNewTerminalsFromApplication(contract, objects);
		return objects;
	}

	private void collectNewTerminalsFromApplication(ApplicationElement root,
			List<ContractObject> objects) throws Exception {
		List<ApplicationElement> merchantElements = root
				.getChildrenByName(AppElements.MERCHANT);
		List<ApplicationElement> terminalElements = root
				.getChildrenByName(AppElements.TERMINAL);
		if (objects == null) {
			objects = new ArrayList<ContractObject>();
		}
		for (ApplicationElement el : terminalElements) {
			if (ApplicationConstants.COMMAND_CREATE_OR_EXCEPT.equals(el
					.getChildByName(AppElements.COMMAND, 1).getValueV())) {
				ContractObject obj = new ContractObject();
				obj.setId(1L);
				obj.setNumber(el.getBlockName());
				obj.setLabel(el.getBlockName());
				obj.setDataId(el.getDataId());
				objects.add(obj);
			}
		}
		for (ApplicationElement el : merchantElements) {
			collectNewTerminalsFromApplication(el, objects);
		}
	}

	private List<ContractObject> getNewAccountsFromApplication()
			throws Exception {
		List<ContractObject> objects;
		ApplicationElement contract = findContract();
		List<ApplicationElement> accountElements = contract
				.getChildrenByName(AppElements.ACCOUNT);
		objects = new ArrayList<ContractObject>();
		for (ApplicationElement el : accountElements) {
			if (ApplicationConstants.COMMAND_CREATE_OR_EXCEPT.equals(el
					.getChildByName(AppElements.COMMAND, 1).getValueV())) {
				ContractObject obj = new ContractObject();
				obj.setId(1L);
				obj.setNumber(el.getBlockName());
				obj.setDataId(el.getDataId());
				objects.add(obj);
			}
		}
		return objects;
	}

	@Deprecated
	public void applyServiceWizard() throws Exception {
		if (appTree == null) {
			return;
		}
		// Getting or adding (if not exists) service block for selected service
		ApplicationElement contract = findContract();
		List<ApplicationElement> serviceElements = contract
				.getChildrenByName(AppElements.SERVICE);
		boolean found = false;
		ApplicationElement serviceBlock = null;

		for (ApplicationElement serviceEl : serviceElements) {
			if (serviceEl.getValueN() != null && serviceEl.getValueN().intValue() == serviceId) {
				found = true;
				serviceBlock = serviceEl;
				break;
			}
		}
		if (!found) {
			serviceBlock = addBl(AppElements.SERVICE, contract);
		}
		if (serviceBlock == null) {
			throw new Exception("Cannot add service!");
		}
		if (!found) {
			fillServiceBlock(serviceId, serviceBlock);
		}
		ContractObject service = servicesMap.get(serviceId);
		if (service == null) {
			throw new Exception("Unknown service!");
		}
		if (!service.isInitial()) {
			// this means that 1 service is selected in branch object. And we
			// can select several
			// existing objects for this service
			if (EntityNames.CARD.equals(service.getEntityType())) {
				linkCardsToService(contract, serviceBlock, service);
			} else if (EntityNames.ACCOUNT.equals(service.getEntityType())) {
				linkAccountsToService(contract, serviceBlock, service);
			} else if (EntityNames.MERCHANT.equals(service.getEntityType())) {
				linkMerchantsToService(contract, serviceBlock, service);
			} else if (EntityNames.TERMINAL.equals(service.getEntityType())) {
				linkTerminalsToService(contract, serviceBlock, service);
			}

		} else {
			for (ContractObject service1 : services) {
				service1.setCheckedOld(false);
			}
			if (EntityNames.CARD.equals(service.getEntityType())) {
				ApplicationElement cardBlock = addBl(AppElements.CARD, contract);

				if (cardBlock == null) {
					throw new Exception("Cannot add card!");
				}
				fillNewCardBlock(cardBlock);
				linkServicesToObject(contract, cardBlock, services);
				linkAccountsToObject(contract, cardBlock);
			} else if (EntityNames.ACCOUNT.equals(service.getEntityType())) {
				ApplicationElement accountBlock = addBl(AppElements.ACCOUNT,
						contract);

				if (accountBlock == null) {
					throw new Exception("Cannot add account!");
				}
				fillNewAccountBlock(accountBlock);

				linkServicesToObject(contract, accountBlock, services);

				if (_activeApp.isIssuing()) {
					linkCardsToAccount(contract, accountBlock, cards);
				} else if (_activeApp.isAcquiring()) {
					linkMerchantsToAccount(contract, accountBlock, merchants);
				}
			} else if (EntityNames.MERCHANT.equals(service.getEntityType())) {
				ApplicationElement whereToAdd;
				if (parentMerchantId != null && !parentMerchantId.equals("")) {
					whereToAdd = searchMerchantBlock(contract,
							getParentMerchantIdNumber(),
							getParentMerchantIdData());
				} else {
					whereToAdd = contract;
				}

				ApplicationElement merchantBlock = addBl(AppElements.MERCHANT,
						whereToAdd);

				if (merchantBlock == null) {
					throw new Exception("Cannot add merchant!");
				}
				fillNewMerchantBlock(merchantBlock);

				linkServicesToObject(contract, merchantBlock, services);

				linkAccountsToObject(contract, merchantBlock);

			} else if (EntityNames.TERMINAL.equals(service.getEntityType())) {
				ApplicationElement whereToAdd;
				if (parentMerchantId != null && !parentMerchantId.equals("")) {
					whereToAdd = searchMerchantBlock(contract,
							getParentMerchantIdNumber(),
							getParentMerchantIdData());
				} else {
					whereToAdd = contract;
				}

				ApplicationElement terminalBlock = addBl(AppElements.TERMINAL,
						whereToAdd);

				if (terminalBlock == null) {
					throw new Exception("Cannot add terminal!");
				}
				fillNewTerminalBlock(terminalBlock);

				linkServicesToObject(contract, terminalBlock, services);

				linkAccountsToObject(contract, terminalBlock);

			}
		}
	}

	private ProductAttribute[] getServiceAttributes(Integer serviceId)
			throws Exception {
		if (attributesMap == null) {
			attributesMap = new HashMap<Integer, ProductAttribute>();
		}
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);

		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(SessionWrapper.getField("language"));
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityTypeNot");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(EntityNames.ATTRIBUTE_GROUP);
		filtersList.add(paramFilter);

		if (serviceId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("serviceId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(serviceId);
			filtersList.add(paramFilter);
		}

		if (_activeApp.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeApp.getInstId().toString());
			filtersList.add(paramFilter);
		}

		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		ProductAttribute[] attrs = _productDao.getServiceAttributesLight(
				userSessionId, params);
		for (ProductAttribute attr : attrs) {
			attributesMap.put(attr.getId(), attr);
		}

		return attrs;
	}

	public void addBranch() {
		branchEntity = null;
		cardId = null;
		merchantId = null;
		terminalId = null;
		accountId = null;
		serviceId = null;
	}

	private void setFakeValues() throws Exception {
		ApplicationElement operator = appTree.getChildByName(AppElements.OPERATOR_ID, 1);
		if (operator != null && (operator.getValueV() == null || "".equals(operator.getValueV()))) {
			operator.setValueV(userName);
		}
		if (isFreqApp()) {
			return;
		}
		ApplicationElement element = isProductApp() ? findProduct() : findContract();
		for (ApplicationElement service : element.getChildrenByName(AppElements.SERVICE)) {
			if (service.getValueN() != null) {
				getServiceAttributes(service.getValueN().intValue());
			}

			for (ApplicationElement serviceObject : service.getChildrenByName(AppElements.SERVICE_OBJECT)) {
				for (ApplicationElement attrBlock : serviceObject.getChildrenByName(AppElements.ATTRIBUTE_CHAR)) {
					if (attrBlock.getValueN() == null) {
						continue;
					}
					ProductAttribute attr = attributesMap.get(attrBlock.getValueN().intValue());
					if (attr == null) {
						throw new Exception("Cannot get attribute parameters. Attr id = " + attrBlock.getValueN().intValue());
					}
					attrBlock.setFake(true);
					attrBlock.setValueText(attr.getLabel());
					configureAeDeletable(attrBlock, attr);
					if (attr.getLovId() != null) {
						setAttributeLov(attr, attrBlock);
					}
				}

				for (ApplicationElement attrBlock : serviceObject.getChildrenByName(AppElements.ATTRIBUTE_NUMBER)) {
					if (attrBlock.getValueN() == null) {
						continue;
					}
					ProductAttribute attr = attributesMap.get(attrBlock.getValueN().intValue());
					if (attr == null) {
						throw new Exception("Cannot get attribute parameters. Attr id = " + attrBlock.getValueN().intValue());
					}
					attrBlock.setFake(true);
					attrBlock.setValueText(attr.getLabel());
					configureAeDeletable(attrBlock, attr);
					if (attr.getLovId() != null) {
						setAttributeLov(attr, attrBlock);
					}
				}

				for (ApplicationElement attrBlock : serviceObject.getChildrenByName(AppElements.ATTRIBUTE_DATE)) {
					if (attrBlock.getValueN() == null) {
						continue;
					}
					ProductAttribute attr = attributesMap.get(attrBlock.getValueN().intValue());
					if (attr == null) {
						throw new Exception("Cannot get attribute parameters. Attr id = " + attrBlock.getValueN().intValue());
					}
					attrBlock.setFake(true);
					attrBlock.setValueText(attr.getLabel());
					configureAeDeletable(attrBlock, attr);
					if (attr.getLovId() != null) {
						setAttributeLov(attr, attrBlock);
					}
				}

				for (ApplicationElement attrBlock : serviceObject.getChildrenByName(AppElements.ATTRIBUTE_FEE)) {
					if (attrBlock.getValueN() == null) {
						continue;
					}
					ProductAttribute attr = attributesMap.get(attrBlock.getValueN().intValue());
					if (attr == null) {
						throw new Exception("Cannot get attribute parameters. Attr id = " + attrBlock.getValueN().intValue());
					}
					attrBlock.setFake(true);
					attrBlock.setValueText(attr.getLabel());
					configureAeDeletable(attrBlock, attr);
				}

				for (ApplicationElement attrBlock : serviceObject.getChildrenByName(AppElements.ATTRIBUTE_CYCLE)) {
					if (attrBlock.getValueN() == null) {
						continue;
					}
					ProductAttribute attr = attributesMap.get(attrBlock.getValueN().intValue());
					if (attr == null) {
						throw new Exception("Cannot get attribute parameters. Attr id = " + attrBlock.getValueN().intValue());
					}
					attrBlock.setFake(true);
					attrBlock.setValueText(attr.getLabel());
					configureAeDeletable(attrBlock, attr);
				}

				for (ApplicationElement attrBlock : serviceObject.getChildrenByName(AppElements.ATTRIBUTE_LIMIT)) {
					if (attrBlock.getValueN() == null) {
						continue;
					}
					ProductAttribute attr = attributesMap.get(attrBlock.getValueN().intValue());
					if (attr == null) {
						throw new Exception("Cannot get attribute parameters. Attr id = " + attrBlock.getValueN().intValue());
					}
					attrBlock.setFake(true);
					attrBlock.setValueText(attr.getLabel());
					configureAeDeletable(attrBlock, attr);
				}
				serviceObject.setFake(true);
				Long dataId = null;

				try {
					dataId = serviceObject.getValueN().longValue();
				} catch (Exception ignored) {}
				if (dataId == null) {
					continue;
				}

				ApplicationElement el = accountsMap.get(dataId);
				if (el != null) {
					serviceObject.setValueText(el.getBlockName());
					continue;
				}
				if (_activeApp.isIssuing()) {
					el = cardsMap.get(dataId);
					if (el != null) {
						serviceObject.setValueText(el.getBlockName());
						continue;
					}
					// Application can contain only one customer
					el = appTree.getChildByName(AppElements.CUSTOMER, 1);
					if (el != null && el.getDataId().equals(dataId)) {
						serviceObject.setValueText(el.getBlockName());
						continue;
					}

				} else if (_activeApp.isAcquiring()) {
					el = merchantsMap.get(dataId);
					if (el != null) {
						serviceObject.setValueText(el.getBlockName());
						continue;
					}
					el = terminalsMap.get(dataId);
					if (el != null) {
						serviceObject.setValueText(el.getShortDesc()
								+ el.getAdditionalDesc());
						continue;
					}
				}

				el = contractsMap.get(dataId);
				if (el != null) {
					serviceObject.setValueText(el.getBlockName());
				}
			}
		}
		for (ApplicationElement account : element.getChildrenByName(AppElements.ACCOUNT)) {
			for (ApplicationElement accountObject : account.getChildrenByName(AppElements.ACCOUNT_OBJECT)) {
				accountObject.setFake(true);
				Long dataId = accountObject.getValueN().longValue();
				if (_activeApp.isIssuing()) {
					ApplicationElement el = cardsMap.get(dataId);
					if (el != null) {
						accountObject.setValueText(el.getBlockName());
					}
				} else if (_activeApp.isAcquiring()) {
					ApplicationElement el = merchantsMap.get(dataId);
					if (el != null) {
						accountObject.setValueText(el.getBlockName());
						continue;
					}
					el = terminalsMap.get(dataId);
					if (el != null) {
						accountObject.setValueText(el.getBlockName());
					}
				}
			}
		}
	}

	public void configureAeDeletable(ApplicationElement ae,
			ProductAttribute attr) {
		if (ProductAttribute.DEF_LEVEL_OBJECT.equals(attr.getDefLevel())) {
			ae.setWizard(true);
		}
	}

	public void addAttribute(Integer attrId, ApplicationElement parent,
			boolean wizard) throws Exception {
		if (attributesMap == null) {
			throw new Exception("Cannot get attribute parameters from DB");
		}
		ProductAttribute attr = attributesMap.get(attrId);
		if (attr == null) {
			throw new Exception("Cannot get attribute parameters from cache");
		}
		ApplicationElement attrBlock = null;

		if (attr.isChar()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_CHAR, parent);
		} else if (attr.isNumber()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_NUMBER, parent);
		} else if (attr.isDate()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_DATE, parent);
		} else if (attr.isCycle()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_CYCLE, parent);
		} else if (attr.isLimit()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_LIMIT, parent);
		} else if (attr.isFee()) {
			attrBlock = addBl(AppElements.ATTRIBUTE_FEE, parent);
		}
		if (attrBlock == null) {
			throw new Exception("Cannot add attribute");
		}
		if (attr.getLovId() != null) {
			setAttributeLov(attr, attrBlock);
		}
		attrBlock.setValueN(new BigDecimal(attrId));
		attrBlock.setValueText(attr.getLabel());
		attrBlock.setFake(true);
		attrBlock.setWizard(wizard);
	}

	public void addAttribute(Integer attrId, ApplicationElement parent)
			throws Exception {
		addAttribute(attrId, parent, false);
	}

	private void setAttributeLov(ProductAttribute attr,
			ApplicationElement attrBlock) {
		KeyLabelItem[] lov = getDictUtils().getLovItems(attr.getLovId().intValue());
		ApplicationElement attributeValueEl = null;
		if (attr.isChar()) {
			attributeValueEl = attrBlock.getChildByName(
					AppElements.ATTRIBUTE_VALUE_CHAR, 1);
		} else if (attr.isNumber()) {
			attributeValueEl = attrBlock.getChildByName(
					AppElements.ATTRIBUTE_VALUE_NUM, 1);
		} else if (attr.isDate()) {
			attributeValueEl = attrBlock.getChildByName(
					AppElements.ATTRIBUTE_VALUE_DATE, 1);
		}

		if (attributeValueEl != null) {
			attributeValueEl.setLovId(attr.getLovId().intValue());
			attributeValueEl.setLov(lov);
		}
	}

	public void addAttribute() {

	}

	public int getCurMode() {
		return curMode;
	}
	public void setCurMode(int curMode) {
		this.curMode = curMode;
	}

	public String getParentMerchantId() {
		return parentMerchantId;
	}
	public void setParentMerchantId(String parentMerchantId) {
		this.parentMerchantId = parentMerchantId;
	}

	private Long getParentMerchantIdData() {
		if (parentMerchantId == null) {
			return null;
		}
		String[] merchantDetails = parentMerchantId.split(";");
		// 0-merchant number
		// 1-dataId
		if (merchantDetails.length > 1) {
			return Long.parseLong(merchantDetails[1]);
		} else {
			return null;
		}
	}
	private String getParentMerchantIdNumber() {
		if (parentMerchantId == null) {
			return null;
		}
		String[] merchantDetails = parentMerchantId.split(";");
		return merchantDetails[0];
	}

	public String getTerminalId() {
		return terminalId;
	}
	public void setTerminalId(String terminalId) {
		this.terminalId = terminalId;
	}

	public String getModule() {
		return module;
	}
	public void setModule(String module) {
		this.module = module;
	}

	public int getMaxInteger() {
		return Integer.MAX_VALUE;
	}
	public int getMinInteger() {
		return Integer.MIN_VALUE;
	}

	public long getMaxLong() {
		return Long.MAX_VALUE;
	}
	public long getMinLong() {
		return Long.MIN_VALUE;
	}

	public double getMaxDouble() {
		return Double.MAX_VALUE;
	}
	public double getMinDouble() {
		return Double.MIN_VALUE;
	}

	public String getMaxNumericByMaxLength(int length) {
		return StringUtils.rightPad("", length, '9');
	}
	public String getMinNumericByMaxLength(int length) {
		if (length < 2) {
			return "0";
		}
		return StringUtils.rightPad("-", length, '9');
	}

	private Map<String, Map<String, List<ContractObject>>> accountObjects;
	private Map<String, Map<String, List<ContractObject>>> cardObjects;
	private Map<String, Map<String, List<ContractObject>>> merchantObjects;
	private Map<String, Map<String, List<ContractObject>>> terminalObjects;
	private Map<String, Map<String, List<ContractObject>>> customerObjects;
	private Map<String, Map<String, List<ContractObject>>> contractObjects;
	private List<ProductService> productServices;
	private List<ProductCardType> productCardTypes;
	private List<ProductAccountType> productAccountTypes;

	private ContractObject[] getObjectLinksByEntity(ContractObject obj,
			String linkEntityType) {
		String number = obj.getNumber();
		Map<String, List<ContractObject>> linksMap = null;
		if (EntityNames.ACCOUNT.equals(obj.getEntityType())) {
			linksMap = accountObjects.get(number);
		} else if (EntityNames.CARD.equals(obj.getEntityType())) {
			linksMap = cardObjects.get(number);
		} else if (EntityNames.MERCHANT.equals(obj.getEntityType())) {
			linksMap = merchantObjects.get(number);
		} else if (EntityNames.TERMINAL.equals(obj.getEntityType())) {
			linksMap = terminalObjects.get(number);
		} else if (EntityNames.CUSTOMER.equals(obj.getEntityType())) {
			linksMap = customerObjects.get(number);
		} else if (EntityNames.CONTRACT.equals(obj.getEntityType())) {
			linksMap = contractObjects.get(number);
		}
		if (linksMap == null) {
			return new ContractObject[0];
		}
		List<ContractObject> lst = linksMap.get(linkEntityType);
		if (lst == null) {
			return new ContractObject[0];
		}
		return lst.toArray(new ContractObject[lst.size()]);
	}

	private Map<String, List<ContractObject>> getObjectLinksMap(
			ContractObject obj) {
		String number = obj.getNumber();
		Map<String, List<ContractObject>> linksMap = null;
		if (EntityNames.ACCOUNT.equals(obj.getEntityType())) {
			linksMap = accountObjects.get(number);
		} else if (EntityNames.CARD.equals(obj.getEntityType())) {
			linksMap = cardObjects.get(number);
		} else if (EntityNames.MERCHANT.equals(obj.getEntityType())) {
			linksMap = merchantObjects.get(number);
		} else if (EntityNames.TERMINAL.equals(obj.getEntityType())) {
			linksMap = terminalObjects.get(number);
		} else if (EntityNames.CUSTOMER.equals(obj.getEntityType())) {
			linksMap = customerObjects.get(number);
		} else if (EntityNames.CONTRACT.equals(obj.getEntityType())) {
			linksMap = contractObjects.get(number);
		}
		return linksMap;
	}

	public void saveProductObjects( List<ProductService> productServices,
									List<ProductCardType> productCardTypes,
									List<ProductAccountType> productAccountTypes){
		this.productServices = productServices;
		this.productCardTypes = productCardTypes;
		this.productAccountTypes = productAccountTypes;
	}

	public void saveObjects(List<ContractObject> objects,
							Map<String, Map<String, List<ContractObject>>> accountObjects,
							Map<String, Map<String, List<ContractObject>>> cardObjects,
							Map<String, Map<String, List<ContractObject>>> merchantObjects,
							Map<String, Map<String, List<ContractObject>>> terminalObjects,
							Map<String, Map<String, List<ContractObject>>> customerObjects,
							Map<String, Map<String, List<ContractObject>>> contractObjects)
			throws Exception {
		this.accountObjects = accountObjects;
		this.cardObjects = cardObjects;
		this.merchantObjects = merchantObjects;
		this.terminalObjects = terminalObjects;
		this.customerObjects = customerObjects;
		this.contractObjects = contractObjects;

		ApplicationElement element = isProductApp() ? findProduct() : findContract();

		Collections.sort(objects);
		Collections.sort(objects, new Comparator<ContractObject>() {
			@Override
			public int compare(ContractObject obj1, ContractObject obj2){
				if (obj1.getEntityType().equals(
						obj2.getEntityType())){
					return obj1.getNumber().compareTo(obj2.getNumber());
				}
				return 0;
			}
		});
		for (ContractObject obj : objects) {
			ApplicationElement objectBlock = null;
			Long dataId;
			String objNumber = "(" + obj.getNumber() + ")";
			if (obj.isInitial()) {
				if (EntityNames.ACCOUNT.equals(obj.getEntityType())) {
					objectBlock = getNewBlock(element, AppElements.ACCOUNT);
					if (objectBlock == null) {
						throw new Exception("Cannot add account!" + objNumber);
					}
					fillNewAccountBlock(objectBlock);
					objectBlock.setValueV(obj.getNumber());
				} else if (EntityNames.CARD.equals(obj.getEntityType())) {
					objectBlock = getNewBlock(element, AppElements.CARD);
					if (objectBlock == null) {
						throw new Exception("Cannot add card!" + objNumber);
					}
					fillNewCardBlock(objectBlock);
					objectBlock.setValueV(obj.getNumber());
					initCardHolder(objectBlock);
				} else if (EntityNames.MERCHANT.equals(obj.getEntityType())) {
					ApplicationElement whereToAdd;
					parentMerchantId = getMerchantIdNumber(obj
							.getParentNumber());
					Long parentDataId = getMerchantIdData(obj.getParentNumber());
					boolean isContractBl;
					if (parentMerchantId != null
							&& !parentMerchantId.equals("")) {
						whereToAdd = searchMerchantBlock(element, parentMerchantId, parentDataId);
						isContractBl = false;
					} else {
						whereToAdd = element;
						isContractBl = true;
					}

					// search the existing merchant
					Long merchDataId = merchantNumberDataIdMap.get(obj
							.getNumber());
					if (merchDataId != null) {
						objectBlock = merchantsMap.get(merchDataId);
						// configure old parent block
						List<ApplicationElement> parentChildren = objectBlock
								.getParent().getChildren();
						ApplicationElement template = new ApplicationElement();
						template.setInnerId(0);
						template.setName(objectBlock.getName());
						int templateIdx = parentChildren.indexOf(template);
						template = parentChildren.get(templateIdx);

						parentChildren.remove(objectBlock);
						template.setCopyCount(template.getCopyCount() - 1);

						// configure new parent block
						parentChildren = whereToAdd.getChildren();
						template = new ApplicationElement();
						template.setInnerId(0);
						template.setName(objectBlock.getName());
						templateIdx = parentChildren.indexOf(template);
						template = parentChildren.get(templateIdx);
						parentChildren.add(objectBlock);

						template.setCopyCount(template.getCopyCount() + 1);
						objectBlock.setInnerId(template.getCopyCount());
						objectBlock.setOrderNum(template.getOrderNum());
						objectBlock.setParent(whereToAdd);
						_applicationDao.setPathForSubtree(objectBlock);
						Collections.sort(parentChildren);
					} else {
						objectBlock = getNewBlock(whereToAdd, AppElements.MERCHANT);
						if(!isContractBl){
							removeMondatoryBlocks(whereToAdd, AppElements.MERCHANT, false);
						}
					}

					if (objectBlock == null) {
						throw new Exception("Cannot add merchant!" + objNumber);
					}
					fillNewMerchantBlock(objectBlock);
					objectBlock.setValueV(obj.getNumber());

					// set dataId for all elements that use this merchant as
					// parent
					for (ContractObject tmp : objects) {
						if (tmp.equals(obj)) {
							continue;
						}
						if (EntityNames.MERCHANT.equals(tmp.getEntityType())
								|| EntityNames.TERMINAL.equals(tmp
								.getEntityType())) {
							if (tmp.getParentNumber() != null
									&& tmp.getParentNumber().equals(
									obj.getNumber())) {
								tmp.setParentNumber(tmp.getParentNumber() + ";"
										+ objectBlock.getDataId());
							}
						}
					}
				} else if (EntityNames.TERMINAL.equals(obj.getEntityType())) {
					ApplicationElement whereToAdd;
					parentMerchantId = getMerchantIdNumber(obj
							.getParentNumber());
					Long parentDataId = getMerchantIdData(obj.getParentNumber());
					boolean isContractBl;
					if (parentMerchantId != null
							&& !parentMerchantId.equals("")) {
						whereToAdd = searchMerchantBlock(element, parentMerchantId, parentDataId);
						isContractBl = false;
					} else {
						whereToAdd = element;
						isContractBl = true;
					}

					objectBlock = getNewBlock(whereToAdd, AppElements.TERMINAL);
					if(!isContractBl){
						removeMondatoryBlocks(whereToAdd, AppElements.TERMINAL, whereToAdd.getParent().getName().equals(AppElements.MERCHANT));
						removeMondatoryBlocks(whereToAdd, AppElements.MERCHANT, false);
					}
					if (objectBlock == null) {
						throw new Exception("Cannot add terminal!" + objNumber);
					}
					fillNewTerminalBlock(objectBlock);
					objectBlock.setBlockName(obj.getNumber());
					objectBlock.setValueV(obj.getNumber());
				} else if (EntityNames.CUSTOMER.equals(obj.getEntityType())) {
					objectBlock = appTree.getChildByName(AppElements.CUSTOMER, 1);
					if (objectBlock == null) {
						throw new Exception("Customer block does not exist in application structure");
					}
				} else if (EntityNames.CONTRACT.equals(obj.getEntityType())) {
					objectBlock = appTree.getChildByName(AppElements.CONTRACT, 1);
					if (objectBlock == null) {
						throw new Exception("Contract block does not exist in application structure");
					}
				}
			} else {
				boolean found = false;
				dataId = obj.getDataId();
				if (EntityNames.ACCOUNT.equals(obj.getEntityType())) {
					if (dataId == null) {
						if (accountNumberDataIdMap != null) {
							dataId = accountNumberDataIdMap.get(obj.getNumber());
						}
					}
					if (dataId == null) {
						// selected account is not presented in application.
						// Moreover it is not a
						// new account and it exists in contract
						objectBlock = getNewBlock(element, AppElements.ACCOUNT);
					} else {
						objectBlock = accountsMap.get(dataId);
						found = true;
					}
					if (objectBlock == null) {
						throw new Exception("Cannot add account!" + objNumber);
					}
					if (!found) {
						fillAccountBlock(obj.getNumber(), objectBlock);
					}
				} else if (EntityNames.CARD.equals(obj.getEntityType())) {
					if (dataId == null) {
						if (cardNumberDataIdMap != null) {
							dataId = cardNumberDataIdMap.get(obj.getNumber());
						}
					}
					if (dataId == null) {
						// selected card is not presented in application.
						// Moreover it is not a new
						// card and it exists in contract
						objectBlock = getNewBlock(element, AppElements.CARD);
					} else {
						objectBlock = cardsMap.get(dataId);
						found = true;
					}
					if (objectBlock == null) {
						throw new Exception("Cannot add card!" + objNumber);
					}
					if (!found) {
						fillCardBlock(obj.getNumber(), obj.getMask(), objectBlock);
					}
					initCardHolder(objectBlock);
				} else if (EntityNames.MERCHANT.equals(obj.getEntityType())) {
					objectBlock = searchMerchantBlock(element,
							obj.getNumber(), dataId);
				} else if (EntityNames.TERMINAL.equals(obj.getEntityType())) {
					objectBlock = searchTerminalBlock(element, obj.getNumber(), dataId);
				} else if (EntityNames.CUSTOMER.equals(obj.getEntityType())) {
					objectBlock = appTree.getChildByName(AppElements.CUSTOMER, 1);
					if (objectBlock == null) {
						throw new Exception("Customer block does not exist in application structure");
					}
				} else if (EntityNames.CONTRACT.equals(obj.getEntityType())){
					objectBlock = element;
				}
			}
			if (objectBlock == null) {
				// TODO Rise error?
				continue;
			}
			obj.setDataId(objectBlock.getDataId());
			linkServicesToObject(element, objectBlock, getObjectLinksByEntity(obj, EntityNames.SERVICE));
		}
		for (ContractObject obj : objects) {
			if (EntityNames.ACCOUNT.equals(obj.getEntityType())) {
				if (accountsMap == null) {
					continue;
					// TODO may be rise error?
				}
				ApplicationElement accountBlock = accountsMap.get(obj
						.getDataId());
				if (accountBlock == null) {
					continue;
					// TODO may be rise error?
				}
				Map<String, List<ContractObject>> linksMap = getObjectLinksMap(obj);
				if (linksMap == null) {
					continue;
				}
				for (String key : linksMap.keySet()) {
					ContractObject[] linkedObjects = getObjectLinksByEntity(
							obj, key);
					for (ContractObject linkedObj : linkedObjects) {
						int index = objects.indexOf(linkedObj);
						if (index >= 0) {
							ContractObject fullLinkedObject = objects.get(index);
							linkedObj.setDataId(fullLinkedObject.getDataId());
						}
					}
					if (EntityNames.CARD.equals(key)) {
						linkCardsToAccount(element, accountBlock, linkedObjects);
					} else if (EntityNames.MERCHANT.equals(key)) {
						linkMerchantsToAccount(element, accountBlock, linkedObjects);
					} else if (EntityNames.TERMINAL.equals(key)) {
						linkTerminalsToAccount(element, accountBlock, linkedObjects);
					}
				}
			}
		}
		storeServicsObjects();
		updFakeValuesForServs();
		setParamLovs(appTree);
	}

	private void removeMondatoryBlocks(ApplicationElement currentBlock, String elName, boolean removeAll){
		if(currentBlock.getName().equals(AppElements.CONTRACT)){
			return;
		}
		Integer maxcopy = currentBlock.getParent().getChildByName(elName, 0).getMaxCopy();
		ApplicationElement objectBlock;
		boolean found = false;
		boolean remove = false;
		int i = 0;
		while (i<maxcopy && !found) {
			i++;
			objectBlock = currentBlock.getParent().getChildByName(elName, i);
			if(objectBlock == null){
				continue;
			}
			if (objectBlock.getDataId().intValue() == 0) {
				remove = true;
			}else {
				if(elName.equals(AppElements.TERMINAL) && !terminalsMap.containsKey(objectBlock.getDataId())){
					remove = true;
				}else if(elName.equals(AppElements.MERCHANT) && !merchantsMap.containsKey(objectBlock.getDataId())){
					remove = true;
				}else if(elName.equals(AppElements.CARD) && !cardsMap.containsKey(objectBlock.getDataId())){
					remove = true;
				}else if(elName.equals(AppElements.ACCOUNT) && !accountsMap.containsKey(objectBlock.getDataId())){
					remove = true;
				}
			}
			if(remove){
				removeBl(elName, currentBlock.getParent(), i);
				i--;
				maxcopy = currentBlock.getParent().getChildByName(elName, 0).getMaxCopy();
				if(!removeAll) {
					found = true;
				}
			}
		}
		removeMondatoryBlocks(currentBlock.getParent(), elName, false);
	}

	private ApplicationElement getNewBlock(ApplicationElement whereToAdd, String elName) throws Exception {
		ApplicationElement objectBlock = null;
		Integer maxcopy = whereToAdd.getChildByName(elName, 0).getMaxCopy();
		if(maxcopy > 0){
			int i = 0;
			boolean found = false;
			while (i<maxcopy && !found) {
				i++;
				objectBlock = whereToAdd.getChildByName(elName, i);
				if(objectBlock == null){
					continue;
				}
				if (objectBlock.getDataId().intValue() == 0) {
					found = true;
				}else{
					if(elName.equals(AppElements.TERMINAL) && !terminalsMap.containsKey(objectBlock.getDataId())){
						found = true;
					}else if(elName.equals(AppElements.MERCHANT) && !merchantsMap.containsKey(objectBlock.getDataId())){
						found = true;
					}else if(elName.equals(AppElements.CARD) && !cardsMap.containsKey(objectBlock.getDataId())){
						found = true;
					}else if(elName.equals(AppElements.ACCOUNT) && !accountsMap.containsKey(objectBlock.getDataId())){
						found = true;
					}
				}
			}
			if(!found){
				objectBlock = addBl(elName, whereToAdd);
			}
		}else{
			objectBlock = addBl(elName, whereToAdd);
		}
		return objectBlock;
	}

	public boolean isDisabledAddBlock() {
		return currentNode == null || !currentNode.isComplex() || !currentNode.getUpdatable() || !isHasBlocksToAdd();
	}

	public boolean isUseBlocksRepresentation() {
		return useBlocksRepresentation;
	}

	public void setUseBlocksRepresentation(boolean useBlocksRepresentation) {
		this.useBlocksRepresentation = useBlocksRepresentation;
	}

	public void switchToBlocks() {
		useBlocksRepresentation = true;
	}

	public void switchToTree() {
		useBlocksRepresentation = false;
	}

	public String getBlockPage() {
		String defaultBlock = "/pages/acquiring/applications/blocks/defaultBlock.jspx";
		String blockPath = null;
		if (currentNode != null) {
			blockPath = currentNode.getEditForm();
			if (blockPath == null || blockPath.equals("0")) {
				blockPath = defaultBlock;
			}
		}
		return blockPath;
	}

	public static void updateAdditionalDesc(ApplicationElement element) {
		if (element != null){
			List<ApplicationElement> children = element.getChildren();
			element.setAdditionalDesc( null );
			for( ApplicationElement child : children ){
				if( child.isEffectsOnDesc() ){
					if( child.getValue() == null )
						continue;
					if( child.isChar() ){
						if( child.getValueV().length() == 0 )
							continue;
					}
					updateAdditionalDesc( element, child );
				}
			}
		}
	}

	private static void updateAdditionalDesc(ApplicationElement parent, ApplicationElement child) {
		if (parent == null){
			return;
		}

		String additionalDesc = parent.getAdditionalDesc();
		if (additionalDesc == null) {
			additionalDesc = " - ";
		} else {
			additionalDesc += ";";
		}

		if (child != null){
			if( child.isNumber() ){
				additionalDesc += String.format( "%s:%f", child.getShortDesc(),
												 child.getValueN() );
			}
			else if( child.isChar() ){
				additionalDesc += String.format( "%s:%s", child.getShortDesc(),
												 child.getValueV() );
			}
			else if( child.isDate() ){
				//noinspection MalformedFormatString
				additionalDesc += String.format( "%s:%t", child.getShortDesc(),
												 child.getValueD() );
			}
		}
		parent.setAdditionalDesc(additionalDesc);
	}

	private List<ApplicationElement> serviceObjects = new ArrayList<ApplicationElement>();

	private void addProductToElement(ApplicationElement element) {
		if (element != null) {
			try {
				if (element.getChildByName(AppElements.PRODUCT_TYPE, 1) != null) {
					element.getChildByName(AppElements.PRODUCT_TYPE, 1).setValueV(_activeApp.getProductType());
				}
				if (element.getChildByName(AppElements.CONTRACT_TYPE, 1) != null) {
					element.getChildByName(AppElements.CONTRACT_TYPE, 1).setValueV(_activeApp.getContractType());
				}
				if (element.getChildByName(AppElements.PRODUCT_STATUS, 1) != null) {
					element.getChildByName(AppElements.PRODUCT_STATUS, 1).setValueV(_activeApp.getProductStatus());
				}
				if (element.getChildByName(AppElements.PRODUCT_NAME, 1) != null) {
					element.getChildByName(AppElements.PRODUCT_NAME, 1).setValueV(_activeApp.getProductName());
				} else if (element.getChildByName(AppElements.PRODUCT_NAME, 0) != null) {
					element.getChildByName(AppElements.PRODUCT_NAME, 0).setValueV(_activeApp.getProductName());
				}
				if (element.getChildByName(AppElements.PRODUCT_NUMBER, 1) != null) {
					element.getChildByName(AppElements.PRODUCT_NUMBER, 1).setValueV(_activeApp.getProductNumber());
				}
				if (element.getChildByName(AppElements.PARENT_PRODUCT_ID, 1) != null) {
					if (_activeApp.getProductParentId() != null) {
						element.getChildByName(AppElements.PARENT_PRODUCT_ID, 1).setValueN(_activeApp.getProductParentId());
					}
				}
			} catch (Exception e) {
				logger.debug("Failed to fill product block", e);
			}
		}
	}

	private void addProductServiceToElement(ProductService data, ApplicationElement element) {
		if (data != null && element != null) {
			try {
				if (element.getChildByName(AppElements.SERVICE_NUMBER, 1) != null) {
					element.getChildByName(AppElements.SERVICE_NUMBER, 1).setValueV(data.getServiceNumber());
				}
				if (element.getChildByName(AppElements.MIN_COUNT, 1) != null) {
					element.getChildByName(AppElements.MIN_COUNT, 1).setValueN(data.getMinCount());
				}
				if (element.getChildByName(AppElements.MAX_COUNT, 1) != null) {
					element.getChildByName(AppElements.MAX_COUNT, 1).setValueN(data.getMaxCount());
				}
			} catch (Exception e) {
				logger.debug("Failed to fill product service block", e);
			}
		}
	}

	private void addProductCardTypeToElement(ProductCardType data, ApplicationElement element) {
		if (data != null && element != null) {
			try {
				if (element.getChildByName(AppElements.CARD_TYPE, 1) != null) {
					element.getChildByName(AppElements.CARD_TYPE, 1).setValueN(data.getCardTypeId());
				}
				if (element.getChildByName(AppElements.SERVICE_NUMBER, 1) != null) {
					if (data.getServiceId() != null) {
						element.getChildByName(AppElements.SERVICE_NUMBER, 1).setValueN(data.getServiceId().intValue());
					}
				}
				if (element.getChildByName(AppElements.SEQ_NUMBER_LOW, 1) != null) {
					element.getChildByName(AppElements.SEQ_NUMBER_LOW, 1).setValueN(data.getSeqNumberLow());
				}
				if (element.getChildByName(AppElements.SEQ_NUMBER_HIGH, 1) != null) {
					element.getChildByName(AppElements.SEQ_NUMBER_HIGH, 1).setValueN(data.getSeqNumberHigh());
				}
				if (element.getChildByName(AppElements.BIN, 1) != null) {
					element.getChildByName(AppElements.BIN, 1).setValueN(Integer.valueOf(data.getBinBin()));
				}
				if (element.getChildByName(AppElements.INDEX_RANGE_ID, 1) != null) {
					element.getChildByName(AppElements.INDEX_RANGE_ID, 1).setValueN(data.getIndexRangeId());
				}
				if (element.getChildByName(AppElements.NUMBER_FORMAT_ID, 1) != null) {
					element.getChildByName(AppElements.NUMBER_FORMAT_ID, 1).setValueN(data.getNumberFormatId());
				}
				if (element.getChildByName(AppElements.EMV_APPL_SCHEME_ID, 1) != null) {
					element.getChildByName(AppElements.EMV_APPL_SCHEME_ID, 1).setValueN(data.getEmvApplicationId());
				}
				if (element.getChildByName(AppElements.PIN_REQUEST, 1) != null) {
					element.getChildByName(AppElements.PIN_REQUEST, 1).setValueV(data.getPinRequest());
				}
				if (element.getChildByName(AppElements.PIN_MAILER_REQUEST, 1) != null) {
					element.getChildByName(AppElements.PIN_MAILER_REQUEST, 1).setValueV(data.getPinMailerRequest());
				}
				if (element.getChildByName(AppElements.EMBOSSING_REQUEST, 1) != null) {
					element.getChildByName(AppElements.EMBOSSING_REQUEST, 1).setValueV(data.getEmbossingRequest());
				}
				if (element.getChildByName(AppElements.CARD_STATUS, 1) != null) {
					element.getChildByName(AppElements.CARD_STATUS, 1).setValueV(data.getOnlineStatus());
				}
				if (element.getChildByName(AppElements.PERSO_PRIORITY, 1) != null) {
					element.getChildByName(AppElements.PERSO_PRIORITY, 1).setValueV(data.getPersoPriority());
				}
				if (element.getChildByName(AppElements.REISSUE_COMMAND, 1) != null) {
					element.getChildByName(AppElements.REISSUE_COMMAND, 1).setValueV(data.getReissCommand());
				}
				if (element.getChildByName(AppElements.START_DATE_RULE, 1) != null) {
					element.getChildByName(AppElements.START_DATE_RULE, 1).setValueV(data.getReissStartDateRule());
				}
				if (element.getChildByName(AppElements.EXPIRATION_DATE_RULE, 1) != null) {
					element.getChildByName(AppElements.EXPIRATION_DATE_RULE, 1).setValueV(data.getReissExpirDateRule());
				}
				if (element.getChildByName(AppElements.REISSUE_CARD_TYPE_ID, 1) != null) {
					element.getChildByName(AppElements.REISSUE_CARD_TYPE_ID, 1).setValueN(data.getReissCardTypeId());
				}
				if (element.getChildByName(AppElements.REISSUE_PRODUCT_ID, 1) != null) {
					if (data.getReissProductId() != null) {
						element.getChildByName(AppElements.REISSUE_PRODUCT_ID, 1).setValueN(data.getReissProductId().intValue());
					}
				}
				if (element.getChildByName(AppElements.REISSUE_BIN_ID, 1) != null) {
					if (data.getReissBinId() != null) {
						element.getChildByName(AppElements.REISSUE_BIN_ID, 1).setValueN(data.getReissBinId().intValue());
					}
				}
				if (element.getChildByName(AppElements.CARD_STATE, 1) != null) {
					element.getChildByName(AppElements.CARD_STATE, 1).setValueV(data.getCardState());
				}
				if (element.getChildByName(AppElements.UID_FORMAT_ID, 1) != null) {
					element.getChildByName(AppElements.UID_FORMAT_ID, 1).setValueN(data.getUidFormatId());
				}
			} catch (Exception e) {
				logger.debug("Failed to fill product card type block", e);
			}
		}
	}

	private void addProductAccountTypeToElement(ProductAccountType data, ApplicationElement element) {
		if (data != null && element != null) {
			try {
				if (element.getChildByName(AppElements.CURRENCY, 1) != null) {
					element.getChildByName(AppElements.CURRENCY, 1).setValueV(data.getCurrency());
				}
				if (element.getChildByName(AppElements.ACCOUNT_TYPE, 1) != null) {
					element.getChildByName(AppElements.ACCOUNT_TYPE, 1).setValueV(data.getAccountType());
				}
				if (element.getChildByName(AppElements.SERVICE_NUMBER, 1) != null) {
					if (data.getServiceId() != null) {
						element.getChildByName(AppElements.SERVICE_NUMBER, 1).setValueV(data.getServiceId().toString());
					}
				}
				if (element.getChildByName(AppElements.AVAL_ALGORITHM, 1) != null) {
					element.getChildByName(AppElements.AVAL_ALGORITHM, 1).setValueV(data.getAvalAlgorithm());
				}
			} catch (Exception e) {
				logger.debug("Failed to fill product account type block", e);
			}
		}
	}

	private void addServiceObjects() {
		try {
			ApplicationElement product = findProduct();
			if (product != null) {
				addProductToElement(product);

				int innerId = 1;
				if (productServices != null) {
					for (ProductService service : productServices) {
						if (!isViewMode() || service.getServiceNumber() != null) {
							addBl(AppElements.PRODUCT_SERVICE, product, true);
							if (service.getServiceNumber() != null) {
								ApplicationElement element = product.getChildByName(AppElements.PRODUCT_SERVICE, innerId++);
								addProductServiceToElement(service, element);
							}
						}
					}
				}

				innerId = 1;
				if (productCardTypes != null) {
					for (ProductCardType crdt : productCardTypes) {
						if (!isViewMode() || crdt.getCardTypeId() != null) {
							addBl(AppElements.PRODUCT_CARD_TYPE, product, true);
							if (crdt.getCardTypeId() != null) {
								ApplicationElement element = product.getChildByName(AppElements.PRODUCT_CARD_TYPE, innerId++);
								addProductCardTypeToElement(crdt, element);
							}
						}
					}
				}

				innerId = 1;
				if (productAccountTypes != null) {
					for (ProductAccountType acct : productAccountTypes) {
						if (!isViewMode() || acct.getAccountType() != null) {
							addBl(AppElements.PRODUCT_ACCOUNT_TYPE, product, true);
							if (acct.getAccountType() != null) {
								ApplicationElement element = product.getChildByName(AppElements.PRODUCT_ACCOUNT_TYPE, innerId++);
								addProductAccountTypeToElement(acct, element);
							}
						}
					}
				}
			}
		} catch (Exception e) {
			logger.error("Failed to add product block");
		}
	}

	private void storeServicsObjects() throws Exception {
		ApplicationElement element = isProductApp() ? findProduct() : findContract();
		serviceObjects.clear();
		for (ApplicationElement service : element.getChildrenByName(isProductApp() ? AppElements.PRODUCT_SERVICE : AppElements.SERVICE)) {
			if (service.getValueN() != null) {
				try {
					getServiceAttributes(service.getValueN().intValue());
				} catch (Exception e) {
					e.printStackTrace();
					return;
				}
			}
			if (isProductApp()) {
				serviceObjects.add(service);
			} else {
				serviceObjects.addAll(service.getChildrenByName(AppElements.SERVICE_OBJECT));
			}
		}
	}

	private void updFakeValuesForServs() {
		for (ApplicationElement ts : serviceObjects) {
			long dataId = ts.getValueN() != null ? ts.getValueN().longValue() : ts.getDataId();
			ApplicationElement linkedObject = null;

			if (terminalsMap != null && terminalsMap.containsKey(dataId)) {
				linkedObject = terminalsMap.get(dataId);
			}
			if (cardsMap != null && cardsMap.containsKey(dataId)) {
				linkedObject = cardsMap.get(dataId);
			}
			if (merchantsMap != null && merchantsMap.containsKey(dataId)) {
				linkedObject = merchantsMap.get(dataId);
			}
			if (accountsMap != null && accountsMap.containsKey(dataId)) {
				linkedObject = accountsMap.get(dataId);
			}
			if (linkedObject != null) {
				String valueText = linkedObject.getBlockName()
						+ (linkedObject.getAdditionalDesc() == null ? ""
								: linkedObject.getAdditionalDesc());
				ts.setValueText(valueText);
			}
		}
	}

	public void updateAddDescForObjects() {
		updAddDescForObjMap(terminalsMap);
		updAddDescForObjMap(cardsMap);
		updAddDescForObjMap(merchantsMap);
		updAddDescForObjMap(accountsMap);
		updFakeValuesForServs();
		nodeValueChanged();
	}

	private void updAddDescForObjMap(Map<Long, ApplicationElement> objMap) {
		if (objMap != null) {
			Collection<ApplicationElement> objects = objMap.values();
			for (ApplicationElement ae : objects) {
				updateAdditionalDesc(ae);
			}
		}
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void setFromNewWizard(boolean fromNewWizard){
		this.fromNewWizard = fromNewWizard;
	}

	public boolean isFromNewWizard(){
		return fromNewWizard;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}

	public Map<BigDecimal,String> getCurrencyMap() {
		if (currencyMap == null){
			currencyMap = new HashMap<BigDecimal, String>();
		}
		return currencyMap;
	}

	public void currencyChangeListener(){
		ApplicationElement parent = currentNode.getParent();
		if (parent != null){
			currencyMap.put(parent.getValueN(), currentNode.getValueV());
		}
	}

	public String getCurrencyValue(){
		String result = null;
		ApplicationElement curElem = getCurrentAppElement();
		if (curElem != null && curElem.isNumber()) {
			ApplicationElement parent = curElem.getParent();
			if (parent != null) {
				result = getCurrencyMap().get(parent.getValueN());
				if (result == null && parent.getChildByName(AppElements.CURRENCY) != null) {
					result = parent.getChildByName(AppElements.CURRENCY).getValueV();
				}
			}
			if (result == null) {
				result = "840";
			}
		}
		return result;
	}

	public void validatorN(javax.faces.component.UIComponent component,
	                       Object value) throws javax.faces.validator.ValidatorException {
		BigDecimal minValue = new BigDecimal(getCompositeAttribute(component,"minValue", "0"));
		BigDecimal maxValue = new BigDecimal(getCompositeAttribute(component,"maxValue", "999999"));
		String label = getCompositeAttribute(component, "label", null);
		BigDecimal val = new BigDecimal(value.toString());
		if(val.compareTo(maxValue)>0 || val.compareTo(minValue)<0){
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "javax.faces.validator.LongRangeValidator.NOT_IN_RANGE", minValue, maxValue, label);
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			throw new javax.faces.validator.ValidatorException(message);
		}
		long minLength = Long.valueOf(getCompositeAttribute(component,"minLength", "0"));
		if(value.toString().length() < minLength){
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "javax.faces.validator.LengthValidator.MINIMUM", minLength, label);
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			throw new javax.faces.validator.ValidatorException(message);
		}
	}

	public void validatorN(FacesContext facesContext, UIComponent component, Object value) throws ValidatorException {
		validatorN(component, value);
	}

	private String getCompositeAttribute(javax.faces.component.UIComponent component, String name, String defaultValue) {
		Object obj = component.getAttributes().get(name);
		if(obj == null){
			return defaultValue;
		}
	    return obj.toString();
	}

	public void setFiltersMap(Map<Integer, ApplicationFlowFilter> filtersMap){
		this.filtersMap = filtersMap;
	}

	public Boolean getShowWarning() {
		if (warnAppStatuses == null) {
			warnAppStatuses = new ArrayList<String>();
			for (SelectItem item : getDictUtils().getArray(ArrayConstants.WARN_APPLICATION_STATUSES)) {
				if (item.getValue() != null) {
					warnAppStatuses.add(item.getValue().toString());
				}
			}
		}
		if (_activeApp != null && _activeApp.getNewStatus() != null) {
			return warnAppStatuses.contains(_activeApp.getNewStatus());
		}
		return false;
	}

	public void cancelStatusChange() {
		_activeApp.setNewStatus(_activeApp.getOldStatus());
		_activeApp.setRejectCode(_activeApp.getOldRejectCode());
	}

	public boolean isProductApp() {
		return ApplicationConstants.TYPE_PRODUCT.equals(_activeApp.getAppType()) ||
				ApplicationConstants.TYPE_ISS_PRODUCT.equals(_activeApp.getAppType()) ||
				ApplicationConstants.TYPE_ACQ_PRODUCT.equals(_activeApp.getAppType());
	}

	public boolean isFreqApp() {
		return ApplicationConstants.TYPE_FIN_REQUEST.equals(_activeApp.getAppType());
	}

	public boolean isQuestionaryApp() {
		return ApplicationConstants.TYPE_QUESTIONARY.equals(_activeApp.getAppType());
	}

	public boolean isInstitutionApp() {
		return ApplicationConstants.TYPE_INSTITUTION.equals(_activeApp.getAppType());
	}

	public boolean isCampaignApp() {
		return ApplicationConstants.TYPE_CAMPAIGNS.equals(_activeApp.getAppType());
	}

	public void fillTree() throws Exception {
		if (isInstitutionApp()) {
			ApplicationElement element = findInstitution();
			fillElementData(element);
		} else if (isQuestionaryApp()) {
			setParamLovs(appTree);
			ApplicationElement element = findQuestionary();
			fillElementData(element);
		} else if (isCampaignApp()) {
			setParamLovs(appTree);
			ApplicationElement element = findCampaign();
			fillElementData(element);
		} else if (!isFreqApp()) {
			ApplicationElement element = isProductApp() ? findProduct() : findCustomer();
			fillElementData(element);
		}
	}

	private ApplicationElement findNode(ApplicationElement root, String ... path) {
		ApplicationElement node = root;
		for (String name : path) {
		    if (node != null) {
				node = node.getChildByName(name,1);
		    }
		    else {
		    	break;
			}
		}
		return (node);
	}

	private void fillNodeValueV(ApplicationElement root, String value, String ... path) {
		ApplicationElement node = findNode(root, path);
		if (node != null) {
			node.setValueV(value);
		}
	}

	private void fillNodeValueD(ApplicationElement root, Date value, String ... path) {
		ApplicationElement node = findNode(root, path);
		if (node != null) {
			node.setValueD(value);
		}
	}

	private void fillNodeValueN(ApplicationElement root, BigDecimal value, String ... path) {
		ApplicationElement node = findNode(root, path);
		if (node != null) {
			node.setValueN(value);
		}
	}

	private void fillCbsAddressBlock(ru.bpc.svap.Address address, ApplicationElement root) {
		if (!address.getAddressName().isEmpty()) {
			fillNodeValueV(root, address.getAddressName().get(0).getCity(), AppElements.ADDRESS_NAME, AppElements.CITY);
			fillNodeValueV(root, address.getAddressName().get(0).getStreet(), AppElements.ADDRESS_NAME, AppElements.STREET);
			fillNodeValueV(root, address.getAddressName().get(0).getRegion(), AppElements.ADDRESS_NAME, AppElements.REGION);
		}
		fillNodeValueV(root, address.getAddressType(), AppElements.ADDRESS_TYPE);
		fillNodeValueV(root, address.getCountry(), AppElements.COUNTRY);
		fillNodeValueV(root, address.getHouse(), AppElements.HOUSE);
		fillNodeValueV(root, address.getApartment(), AppElements.APARTMENT);
		fillNodeValueV(root, address.getPostalCode(), AppElements.POSTAL_CODE);
		fillNodeValueV(root, address.getRegionCode(), AppElements.REGION_CODE);
		if (address.getLatitude() != null) {
			fillNodeValueN(root, new BigDecimal(address.getLatitude()), AppElements.LATITUDE);
		}
		if (address.getLongitude() != null) {
			fillNodeValueN(root, new BigDecimal(address.getLongitude()), AppElements.LONGITUDE);
		}
	}

	private void fillEWalletAddressBlock(ru.bpc.svap.Address address, ApplicationElement root) {
		if (!address.getAddressName().isEmpty()) {
			fillNodeValueV(root, address.getAddressName().get(0).getCity(), AppElements.ADDRESS_NAME, AppElements.CITY);
			fillNodeValueV(root, address.getAddressName().get(0).getStreet(), AppElements.ADDRESS_NAME, AppElements.STREET);
			fillNodeValueV(root, address.getAddressName().get(0).getRegion(), AppElements.ADDRESS_NAME, AppElements.REGION);
		}
		fillNodeValueV(root, address.getAddressType(), AppElements.ADDRESS_TYPE);
		fillNodeValueV(root, address.getCountry(), AppElements.COUNTRY);
		fillNodeValueV(root, address.getHouse(), AppElements.HOUSE);
		fillNodeValueV(root, address.getApartment(), AppElements.APARTMENT);
		fillNodeValueV(root, address.getPostalCode(), AppElements.POSTAL_CODE);
		fillNodeValueV(root, address.getRegionCode(), AppElements.REGION_CODE);
		if (address.getLatitude() != null) {
			fillNodeValueN(root, new BigDecimal(address.getLatitude()), AppElements.LATITUDE);
		}
		if (address.getLongitude() != null) {
			fillNodeValueN(root, new BigDecimal(address.getLongitude()), AppElements.LONGITUDE);
		}
	}

	private void fillCbsIdentityCardBlock(IdentityCard identityCard, ApplicationElement root) {
		if (identityCard.getIdType() != null && StringUtils.isNotBlank(identityCard.getIdType().value())) {
			fillNodeValueV(root, identityCard.getIdType().value(), AppElements.ID_TYPE);
		}
		fillNodeValueV(root, identityCard.getIdSeries(), AppElements.ID_SERIES);
		fillNodeValueV(root, identityCard.getIdNumber(), AppElements.ID_NUMBER);
		fillNodeValueV(root, identityCard.getIdIssuer(), AppElements.ID_ISSUER);
		if (identityCard.getIdIssueDate() != null) {
			fillNodeValueD(root, identityCard.getIdIssueDate().toGregorianCalendar().getTime(), AppElements.ID_ISSUE_DATE);
		}
		if (identityCard.getIdExpireDate() != null) {
			fillNodeValueD(root, identityCard.getIdExpireDate().toGregorianCalendar().getTime(), AppElements.ID_EXPIRE_DATE);
		}
	}

	private void fillEWalletIdentityCardBlock(IdentityCard identityCard, ApplicationElement root) {
		if (identityCard.getIdType() != null && StringUtils.isNotBlank(identityCard.getIdType().value())) {
			fillNodeValueV(root, identityCard.getIdType().value(), AppElements.ID_TYPE);
		}
		fillNodeValueV(root, identityCard.getIdSeries(), AppElements.ID_SERIES);
		fillNodeValueV(root, identityCard.getIdNumber(), AppElements.ID_NUMBER);
		fillNodeValueV(root, identityCard.getIdIssuer(), AppElements.ID_ISSUER);
		if (identityCard.getIdIssueDate() != null) {
			fillNodeValueD(root, identityCard.getIdIssueDate().toGregorianCalendar().getTime(), AppElements.ID_ISSUE_DATE);
		}
		if (identityCard.getIdExpireDate() != null) {
			fillNodeValueD(root, identityCard.getIdExpireDate().toGregorianCalendar().getTime(), AppElements.ID_EXPIRE_DATE);
		}
	}

	private void fillCbsPersonBlock(Person person, ApplicationElement root) {
		if (!person.getPersonName().isEmpty()) {
			fillNodeValueV(root, person.getPersonName().get(0).getFirstName(), AppElements.PERSON_NAME, AppElements.FIRST_NAME);
			fillNodeValueV(root, person.getPersonName().get(0).getSecondName(), AppElements.PERSON_NAME, AppElements.SECOND_NAME);
			fillNodeValueV(root, person.getPersonName().get(0).getSurname(), AppElements.PERSON_NAME, AppElements.SURNAME);
		}
		if (person.getBirthday() != null) {
			fillNodeValueD(root, person.getBirthday().toGregorianCalendar().getTime(), AppElements.BIRTHDAY);
		}
		if (person.getGender() != null && StringUtils.isNotEmpty(person.getGender().value())) {
			fillNodeValueV(root, person.getGender().value(), AppElements.GENDER);
		}
		if (!person.getIdentityCard().isEmpty()) {
			fillCbsIdentityCardBlock(person.getIdentityCard().get(0), findNode(root, AppElements.IDENTITY_CARD));
		}
	}

	private void fillCbsPersonCardholderBlock(Person person) throws Exception {
		if (StringUtils.isNotEmpty(person.getCardholderName())) {
			ApplicationElement cardholder = findNode(findContract(), AppElements.CARD, AppElements.CARDHOLDER);
			if (cardholder != null) {
				fillNodeValueV(cardholder, person.getCardholderName(), AppElements.CARDHOLDER_NAME);
			}
		}
		if (person.getSecureWord() != null) {
			ApplicationElement secureWord = findNode(findCustomer(), AppElements.SECURE_WORD);
			if (secureWord != null) {
				fillNodeValueV(secureWord, person.getSecureWord().getSecureQuestion(), AppElements.SECRET_QUESTION);
				fillNodeValueV(secureWord, person.getSecureWord().getSecureAnswer(), AppElements.SECRET_ANSWER);
			}
		}

		if (person.getNotification() != null) {
			ApplicationElement cardholder = findNode(findContract(), AppElements.CARD, AppElements.CARDHOLDER);

			ApplicationElement notification = findNode(cardholder, AppElements.NOTIFICATION);
			if (notification == null) {
				notification = addElement(cardholder, AppElements.NOTIFICATION);
			}

			fillNodeValueV(notification, person.getNotification().getDeliveryAddress(), AppElements.DELIVERY_ADDRESS);
		}
	}

	private void fillEWalletPersonBlock(Person person, ApplicationElement root) {
		if (!person.getPersonName().isEmpty()) {
			fillNodeValueV(root, person.getPersonName().get(0).getFirstName(), AppElements.PERSON_NAME, AppElements.FIRST_NAME);
			fillNodeValueV(root, person.getPersonName().get(0).getSecondName(), AppElements.PERSON_NAME, AppElements.SECOND_NAME);
			fillNodeValueV(root, person.getPersonName().get(0).getSurname(), AppElements.PERSON_NAME, AppElements.SURNAME);
		}
		if (person.getBirthday() != null) {
			fillNodeValueD(root, person.getBirthday().toGregorianCalendar().getTime(), AppElements.BIRTHDAY);
		}
		if (person.getGender() != null && StringUtils.isNotBlank(person.getGender().value())) {
			fillNodeValueV(root, person.getGender().value(), "GENDER");
		}
		if (!person.getIdentityCard().isEmpty()) {
			fillEWalletIdentityCardBlock(person.getIdentityCard().get(0), findNode(root, AppElements.IDENTITY_CARD));
		}
	}

	private ApplicationElement addBlock(ApplicationElement template) {
		ApplicationElement node = new ApplicationElement();
		Map<Integer, ApplicationFlowFilter> filters = new HashMap<Integer, ApplicationFlowFilter>();
		template.clone(node);
		node.setContent(false);
		template.setMaxCopy(template.getMaxCopy() + 1);
		node.setInnerId(template.getMaxCopy());
		node.setContentBlock(template);
		_applicationDao.fillRootChilds(userSessionId, _activeApp.getInstId(), node, _activeApp, filters);
		return node;
	}

	private boolean fillCbsContactDataBlock(ContactData source, ApplicationElement contact, boolean createNew) {
		ApplicationElement contactData = contact.getChildByName(AppElements.CONTACT_DATA, 1);
		if (createNew || contactData == null) {
			if (contact.getChildByName(AppElements.CONTACT_DATA, 0) != null) {
				contact.addChildren(addBlock(contact.getChildByName(AppElements.CONTACT_DATA, 0)));
				Integer inner = contact.getChildByName(AppElements.CONTACT_DATA, 0).getMaxCopy();
				contactData = contact.getChildByName(AppElements.CONTACT_DATA, inner);
			}
		}

		if (contactData != null) {
			fillNodeValueV(contactData, source.getCommunMethod(), AppElements.COMMUN_METHOD);
			fillNodeValueV(contactData, source.getCommunAddress(), AppElements.COMMUN_ADDRESS);
		}

		return true;
	}

	private boolean fillCbsContactBlock(Contact source, ApplicationElement customer, boolean createNew) {
		ApplicationElement contact = customer.getChildByName(AppElements.CONTACT, 1);
		if (createNew || contact == null) {
			if (customer.getChildByName(AppElements.CONTACT, 0) != null) {
				customer.addChildren(addBlock(customer.getChildByName(AppElements.CONTACT, 0)));
				Integer inner = customer.getChildByName(AppElements.CONTACT, 0).getMaxCopy();
				contact = customer.getChildByName(AppElements.CONTACT, inner);
			}
		}
		if (contact != null) {
			fillNodeValueV(contact, source.getContactType(), AppElements.CONTACT_TYPE);
			if (!source.getContactData().isEmpty()) {
				boolean createNewData = false;
				for (ru.bpc.svap.ContactData data : source.getContactData()) {
					createNewData = fillCbsContactDataBlock(data, contact, createNewData);
				}
			}
		}

		if (source.getPerson() != null) {
			fillCbsPersonBlock(source.getPerson(), findNode(customer, AppElements.IDENTITY_CARD));
		}

		if (source.getAddress() != null) {
			fillCbsAddressBlock(source.getAddress(), findNode(customer, AppElements.ADDRESS));
		}

		return true;
	}

	private void fillEWalletContactBlock(Contact contact, ApplicationElement root) {
		fillNodeValueV(root, contact.getContactType(), AppElements.CONTACT_TYPE);
		if (!contact.getContactData().isEmpty()) {
			fillNodeValueV(root, contact.getContactData().get(0).getCommunMethod(), AppElements.CONTACT_DATA, AppElements.COMMUN_METHOD);
			fillNodeValueV(root, contact.getContactData().get(0).getCommunAddress(), AppElements.CONTACT_DATA, AppElements.COMMUN_ADDRESS);
		}
		if (contact.getPerson() != null) {
			fillEWalletPersonBlock(contact.getPerson(), findNode(root, AppElements.IDENTITY_CARD));
		}
		if (contact.getAddress() != null) {
			fillEWalletAddressBlock(contact.getAddress(), findNode(root, AppElements.ADDRESS));
		}
	}

	private void fillCbsCompanyBlock(Company company, ApplicationElement root) {
		fillNodeValueV(root, company.getIncorpForm(), AppElements.INCORP_FORM);
		if (!company.getCompanyName().isEmpty()) {
			fillNodeValueV(root, company.getCompanyName().get(0).getCompanyShortName(), AppElements.EMBOSSED_NAME);
			fillNodeValueV(root, company.getCompanyName().get(0).getCompanyShortName(), AppElements.COMPANY_NAME, AppElements.COMPANY_SHORT_NAME);
			fillNodeValueV(root, company.getCompanyName().get(0).getCompanyFullName(), AppElements.COMPANY_NAME, AppElements.COMPANY_FULL_NAME);
		}
		if (!company.getIdentityCard().isEmpty()) {
			fillCbsIdentityCardBlock(company.getIdentityCard().get(0), findNode(root, AppElements.IDENTITY_CARD));
		}
	}

	private void fillEWalletCompanyBlock(Company company, ApplicationElement root) {
		fillNodeValueV(root, company.getIncorpForm(), AppElements.INCORP_FORM);
		if (!company.getCompanyName().isEmpty()) {
			fillNodeValueV(root, company.getCompanyName().get(0).getCompanyShortName(), AppElements.EMBOSSED_NAME);
			fillNodeValueV(root, company.getCompanyName().get(0).getCompanyShortName(), AppElements.COMPANY_NAME, AppElements.COMPANY_SHORT_NAME);
			fillNodeValueV(root, company.getCompanyName().get(0).getCompanyFullName(), AppElements.COMPANY_NAME, AppElements.COMPANY_FULL_NAME);
		}
		if (!company.getIdentityCard().isEmpty()) {
			fillEWalletIdentityCardBlock(company.getIdentityCard().get(0), findNode(root, AppElements.IDENTITY_CARD));
		}
	}

	//XXX:
	public void fillCbsData(Customer cbsCustomer) throws Exception {
		// If CBS customer is of type Person
		if (cbsCustomer.getPerson() != null) {
			fillCbsPersonBlock(cbsCustomer.getPerson(), findNode(findCustomer(), AppElements.PERSON));
			fillCbsPersonCardholderBlock(cbsCustomer.getPerson());
		}
		// If CBS customer is of type Company
		else if (cbsCustomer.getCompany() != null) {
			fillCbsCompanyBlock(cbsCustomer.getCompany(), findNode(findCustomer(), AppElements.COMPANY));
		}
		// Fill address
		if (!cbsCustomer.getAddress().isEmpty()) {
			fillCbsAddressBlock(cbsCustomer.getAddress().get(0), findNode(findCustomer(), AppElements.ADDRESS));
		}
		// Fill customer
		if (!cbsCustomer.getContact().isEmpty()) {
			boolean createNew = false;
			for (ru.bpc.svap.Contact contact : cbsCustomer.getContact()) {
				createNew = fillCbsContactBlock(contact, findCustomer(), createNew);
			}
		}
		// Fill account blocks
		if (!cbsCustomer.getAccount().isEmpty()) {
			ApplicationElement contract = findContract();
			if (contract != null) {
				List<ApplicationElement> accounts = contract.getChildrenByName(AppElements.ACCOUNT);
				for (ApplicationElement account : accounts) {
					for (Account cbsAccount : cbsCustomer.getAccount()) {
						if (cbsAccount.getAccountNumber() != null) {
							if (cbsAccount.getAccountNumber().equals(account.getValueV())) {
								fillNodeValueV(account, cbsAccount.getAccountNumber(), AppElements.ACCOUNT_NUMBER);
								fillNodeValueV(account, cbsAccount.getAccountType(), AppElements.ACCOUNT_TYPE);
								fillNodeValueV(account, cbsAccount.getCurrency(), AppElements.CURRENCY);
								fillNodeValueV(account, cbsAccount.getAccountStatus(), AppElements.ACCOUNT_STATUS);
							}
						}
					}
				}
			}
		}
		// Fill customer number
		fillNodeValueV(appTree, cbsCustomer.getId(), AppElements.CUSTOMER, AppElements.CUSTOMER_NUMBER);
		if (StringUtils.isNotBlank(cbsCustomer.getNationality())) {
			fillNodeValueV(appTree, cbsCustomer.getNationality(), AppElements.CUSTOMER, AppElements.NATIONALITY);
		}
		if (cbsCustomer.getCategory() != null && StringUtils.isNotBlank(cbsCustomer.getCategory())) {
			fillNodeValueV(appTree, cbsCustomer.getCategory(), AppElements.CUSTOMER, AppElements.CUSTOMER_CATEGORY);
		}
		if (cbsCustomer.isIsResidence() != null) {
			if (Boolean.TRUE.equals(cbsCustomer.isIsResidence())) {
				fillNodeValueN(appTree, new BigDecimal(1), AppElements.CUSTOMER, AppElements.RESIDENT);
			} else {
				fillNodeValueN(appTree, new BigDecimal(0), AppElements.CUSTOMER, AppElements.RESIDENT);
			}
		}
	}

	public void fillEWalletData(Customer eWalletCustomer) {
		// if eWallet customer is of type Person
		if (eWalletCustomer.getPerson() != null) {
			fillEWalletPersonBlock(eWalletCustomer.getPerson(), findNode(appTree, AppElements.CUSTOMER, AppElements.PERSON));
		}
		// if eWallet customer is of type Company
		else if (eWalletCustomer.getCompany() != null) {
			fillEWalletCompanyBlock(eWalletCustomer.getCompany(), findNode(appTree, AppElements.CUSTOMER, AppElements.COMPANY));
		}
		// fill address
		if (!eWalletCustomer.getAddress().isEmpty()) {
			fillEWalletAddressBlock(eWalletCustomer.getAddress().get(0), findNode(appTree, AppElements.CUSTOMER, AppElements.ADDRESS));
		}
		// fill contact
		if (!eWalletCustomer.getContact().isEmpty()) {
			fillEWalletContactBlock(eWalletCustomer.getContact().get(0), findNode(appTree, AppElements.CUSTOMER, AppElements.CONTACT));
		}
		// fill account blocks
		if (!eWalletCustomer.getAccount().isEmpty()) {
			ApplicationElement contract = findNode(appTree, AppElements.CUSTOMER, AppElements.CONTRACT);
			if (contract != null) {
				List<ApplicationElement> accounts = contract.getChildrenByName(AppElements.ACCOUNT);
				for (ApplicationElement account : accounts) {
					for (Account eWalletAcc : eWalletCustomer.getAccount()) {
						if (eWalletAcc.getAccountNumber() != null) {
							if (eWalletAcc.getAccountNumber().equals(account.getValueV())) {
								fillNodeValueV(account, eWalletAcc.getAccountNumber(), AppElements.ACCOUNT_NUMBER);
								fillNodeValueV(account, eWalletAcc.getAccountType(), AppElements.ACCOUNT_TYPE);
								fillNodeValueV(account, eWalletAcc.getCurrency(), AppElements.CURRENCY);
								fillNodeValueV(account, eWalletAcc.getAccountStatus(), AppElements.ACCOUNT_STATUS);
							}
						}
					}
				}
			}
		}
		// fill customer number
		fillNodeValueV(appTree, eWalletCustomer.getId(), AppElements.CUSTOMER, AppElements.CUSTOMER_NUMBER);
	}

	private void fillElementData(ApplicationElement el) throws ParseException {
		fillEntityData(el);
		if(el.getChildren() != null){
			for(ApplicationElement child : el.getChildren()){
				if (child.getInnerId() != 0) {
					if(child.isComplex()) {
						fillElementData(child);
					}
				}
			}
		}
	}

	private void fillEntityData(ApplicationElement el) throws ParseException {
		List<ApplicationElement> elements = null;
		String number = null;
		Integer innerId = null;
		Long objectId;
		Long parentObjectId;
		String parentObjectNumber;
		String objectType = null;
		String command = (el.getChildByName(AppElements.COMMAND, 1) != null) ? el.getChildByName(AppElements.COMMAND, 1).getValueV() : null;
		if(command == null){
			return;
		}
		int mode = 0;

		String elNumName = null;

		if(el.getName().equals(AppElements.CUSTOMER)){
			number = el.getChildByName(AppElements.CUSTOMER_NUMBER, 1).getValueV();
			elNumName = AppElements.CUSTOMER_NUMBER;
			mode = 1;
		}else if(el.getName().equals(AppElements.CONTRACT)){
			number = el.getChildByName(AppElements.CONTRACT_NUMBER, 1).getValueV();
			elNumName = AppElements.CONTRACT_NUMBER;
			mode = 1;
		}else if(el.getName().equals(AppElements.PRODUCT)){
			mode = 1;
		}else if(el.getName().equals(AppElements.ACCOUNT)){
			number = el.getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueV();
			elNumName = AppElements.ACCOUNT_NUMBER;
			mode = 1;
		}else if(el.getName().equals(AppElements.CARD)){
			number = el.getChildByName(AppElements.CARD_NUMBER, 1).getValueV();
			elNumName = AppElements.CARD_NUMBER;
			mode = 1;
		}else if(el.getName().equals(AppElements.MERCHANT)){
			number = el.getChildByName(AppElements.MERCHANT_NUMBER, 1).getValueV();
			elNumName = AppElements.MERCHANT_NUMBER;
			mode = 1;
		}else if(el.getName().equals(AppElements.TERMINAL)){
			number = el.getChildByName(AppElements.TERMINAL_NUMBER, 1).getValueV();
			elNumName = AppElements.TERMINAL_NUMBER;
			mode = 1;
		}else if(el.getName().equals(AppElements.CONTACT)){
			innerId = el.getInnerId();
			objectType = el.getChildByName(AppElements.CONTACT_TYPE, 1).getValueV();
			mode = 2;
		}else if(el.getName().equals(AppElements.ADDRESS)){
			innerId = el.getInnerId();
			objectType = el.getChildByName(AppElements.ADDRESS_TYPE, 1).getValueV();
			mode = 2;
		}else if(el.getName().equals(AppElements.PERSON)){
			mode = 2;
		}else if(el.getName().equals(AppElements.COMPANY)){
			mode = 2;
		}else if(el.getName().equals(AppElements.DOCUMENT)){
			objectType = el.getChildByName(AppElements.DOCUMENT_TYPE, 1).getValueV();
			mode = 2;
		}else if(el.getName().equals(AppElements.CARDHOLDER)){
			mode = 2;
		}else if(el.getName().equals(AppElements.NOTIFICATION)){
			innerId = el.getInnerId();
			mode = 2;
		}

		if(currentNode != null && currentNode.getName() != null && elNumName != null && currentNode.getName().equals(elNumName)){
			objectId = null;
		}else{
			objectId = getObjectId(el);
		}
		parentObjectId = getObjectId(el.getParent());
		parentObjectNumber = getObjectNumber(el.getParent());

		if((number != null || objectId != null) && mode == 1){
			elements = _applicationDao.getObjectNumberData(userSessionId, el.getEntityType(), objectId, number, _activeApp.getInstId());
		}else{
			if((parentObjectId != null || parentObjectNumber != null) && mode == 2) {
				elements = _applicationDao.getObjectTypeData(userSessionId, el.getEntityType(), objectType, el.getParent().getEntityType(), parentObjectId, parentObjectNumber, _activeApp.getInstId(), innerId);
			}
		}

		fillElements(el, elements, command);
		if(el.getName().equals(AppElements.PERSON)){
			fillElements(el.getChildByName(AppElements.PERSON_NAME, 1), elements, command);
			ApplicationElement identity = el.getChildByName(AppElements.IDENTITY_CARD, 1);
			if(identity != null) {
				ApplicationElement commandEl = el.getChildByName(AppElements.IDENTITY_CARD, 1).getChildByName(AppElements.COMMAND, 1);
				fillElements(identity, elements, (commandEl != null) ?
						commandEl.getValueV() : null);
			}
		}
		if(el.getName().equals(AppElements.ADDRESS)){
			fillElements(el.getChildByName(AppElements.ADDRESS_NAME, 1), elements, command);
		}
		if(el.getName().equals(AppElements.CONTACT)){
			fillElements(el.getChildByName(AppElements.CONTACT_DATA, 1), elements, command);
		}
		if(el.getName().equals(AppElements.CARDHOLDER)){
			fillElements(el.getChildByName(AppElements.SECURE_WORD, 1), elements, command);
		}
	}

	private String getObjectNumber(ApplicationElement el){
		String elNumName = null;
		if(el.getName().equals(AppElements.CUSTOMER)){
			elNumName = AppElements.CUSTOMER_NUMBER;
		}else if(el.getName().equals(AppElements.CONTRACT)){
			elNumName = AppElements.CONTRACT_NUMBER;
		}else if(el.getName().equals(AppElements.ACCOUNT)){
			elNumName = AppElements.ACCOUNT_NUMBER;
		}else if(el.getName().equals(AppElements.CARD)){
			elNumName = AppElements.CARD_NUMBER;
		}else if(el.getName().equals(AppElements.MERCHANT)){
			elNumName = AppElements.MERCHANT_NUMBER;
		}else if(el.getName().equals(AppElements.TERMINAL)){
			elNumName = AppElements.TERMINAL_NUMBER;
		}else if(el.getName().equals(AppElements.CARDHOLDER)){
			elNumName = AppElements.CARDHOLDER_NUMBER;
		}else if(el.getName().equals(AppElements.PRODUCT)){
			elNumName = AppElements.PRODUCT_ID;
		}
		if(elNumName != null && el.getChildByName(elNumName, 1) != null
				&& el.getChildByName(elNumName, 1).getValue() != null
				&& !el.getChildByName(elNumName, 1).getValue().toString().isEmpty()) {
			return el.getChildByName(elNumName, 1).getValue().toString();
		}
		return null;
	}

	private void fillElements(ApplicationElement el, List<ApplicationElement> elements, String command) throws ParseException {
		if(el == null){
			return;
		}
		ApplicationElement node;
		String dbDateFormat = "yyyyMMddHHmmss";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if(elements != null && !elements.isEmpty()){
			for(ApplicationElement element : elements){
				node = el.getChildByName(element.getName(), 1);
				if(node != null && !node.isFilled() && element.getValue() != null && (ApplicationConstants.COMMAND_CREATE_OR_UPDATE.equals(command) || ApplicationConstants.COMMAND_EXCEPT_OR_UPDATE.equals(command))){
					if(node.isDate()){
						node.setValueD(df.parse(element.getValue().toString()));
					}else if(node.isChar()){
						node.setValueV(element.getValue().toString());
					}else if(node.isNumber()){
						node.setValueN(new BigDecimal(element.getValue().toString()));
					}
					node.setFilled(true);
				}
			}
		}
	}

	private Long getObjectId(ApplicationElement el) {
		Long value = null;
		String elValue = null;
		String elName = null;
		if (el.getName().equals(AppElements.CARD)) {
			elName = AppElements.CARD_ID;
		} else if (el.getName().equals(AppElements.CONTRACT)) {
			elName = AppElements.CONTRACT_ID;
		} else if (el.getName().equals(AppElements.CUSTOMER)) {
			elName = AppElements.CUSTOMER_ID;
		} else if (el.getName().equals(AppElements.ACCOUNT)) {
			elName = AppElements.ACCOUNT_ID;
		} else if (el.getName().equals(AppElements.TERMINAL)) {
			elName = AppElements.TERMINAL_ID;
		}
		if (elName != null && el.getChildByName(elName, 1) != null
				&& el.getChildByName(elName, 1).getValue() != null
				&& !el.getChildByName(elName, 1).getValue().toString().isEmpty()) {
			elValue = el.getChildByName(elName, 1).getValue().toString();
		}
		if (elValue != null) {
			if (AppElements.CARD_ID.equals(elName)) {
				value = _issuingDao.getCardIdByUid(userSessionId, elValue);
			} else {
				value = Long.valueOf(elValue);
			}
		}
		return value;
	}
}

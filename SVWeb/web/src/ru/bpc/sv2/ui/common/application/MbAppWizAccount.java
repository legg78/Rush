package ru.bpc.sv2.ui.common.application;

import static ru.bpc.sv2.utils.AppStructureUtils.delete;
import static ru.bpc.sv2.utils.AppStructureUtils.instance;
import static ru.bpc.sv2.utils.AppStructureUtils.retrive;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.KeepAlive;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.products.ServiceType;

import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAppWizAccount")
public class MbAppWizAccount extends AbstractBean implements AppWizStep, Serializable {
	private static final long serialVersionUID = 1L;
	private static final String ADD_ACCOUNT = "ADD_ACCOUNT";
	private static final String DONT_CONNECT = "Don't connect";
	
	private ApplicationElement applicationRoot;
	private DictUtils dictUtils;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private Map<Integer, ProductAttribute> attributesMap;
	private static final String page = "/pages/common/application/appWizAccount.jspx";
	private ApplicationElement customerElement;
	private ApplicationWizardContext appWizCtx;
	private Map<String, ApplicationElement> fieldMap;
	private Map<String, List<SelectItem>> listMap;
	private List<Card> cardsList;
	private String language;
	private String selectedService;
	private List <Service> services;
	private String userLanguage;
	private Long userSessionId;
	private List<ApplicationElement> accountElements;
	private ApplicationElement contractElement;
	private boolean lock;
	private boolean serviceTypeValid;
	private Service initialService;
	private boolean accountValid;
	private Map<String, Service> accToService; 
	private MenuTreeItem node;
	private String prevAccType;
	private TreePath nodePath;
	private Long productId;
	private int instId;
	private List<MenuTreeItem> leftMenu = null;
	private List<ServiceType> serviceTypes;
    private MenuTreeItem newAccountsGroup;
    private List<ApplicationElement> oldServices;
    private Map <ApplicationElement, List<ApplicationElement>> linkedMap;
    private List<SelectItem> bindCard;
    private List<SelectItem> unbindCard;
    private String bind;
	private String unbind;
    private Card activeCard;
    private Map<ApplicationElement, List<SelectItem>> accToCard;
	private Map<ApplicationElement, List<SelectItem>> accToUnbindCard;
	
	ApplicationDao applicationDao = new ApplicationDao();
	ProductsDao productDao = new ProductsDao();
	IssuingDao issDao = new IssuingDao();

	@Override
	public ApplicationWizardContext release() {
		clearObjectAttr();
		releaseServices();
		releaseAccounts();
		customerElement = null;
		node = null;
		nodePath = null;
		dictUtils = null;
		appWizCtx.setLinkedMap(linkedMap);
		appWizCtx.setApplicationRoot(applicationRoot);
		applicationRoot = null;
		return appWizCtx;
	}
	
	private void releaseServices(){
		boolean noService;
		List<ApplicationElement> serviceElements =  
				contractElement.getChildrenByName(AppElements.SERVICE);
		noService = !((serviceElements != null) &&
				(serviceElements.size() > 0));
		if (!noService){
			checkOldServices();
		}
		try {
			createServices();
		} catch (Exception ignored) {
		}
	}
	
	private void checkOldServices(){
		boolean found;
		if ((oldServices == null)){
			return;
		}
		for (ApplicationElement oldService: oldServices){
		found = false;
			for (String key: accToService.keySet()){
				Service serv = accToService.get(key);
				if (oldService.getValueN().compareTo(new BigDecimal(serv.getId()))==0){
					found = true;
					accToService.remove(key);
				}
				if (!found){
					ApplicationElement oldServObject = 
							oldService.getChildByName(AppElements.SERVICE_OBJECT, 1);
					oldServObject.getChildByName(AppElements.END_DATE, 1).setValueD(
							new Date());
				}
			}
		}	
	}
	
	private void createServices() throws Exception{
		accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
		addInitialServiceTypes();
		for (ApplicationElement acc: accountElements){
			for (ServiceType servType: serviceTypes){
				StringBuilder str = new StringBuilder();
				if (acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV() != null){
					str.append(acc.getShortDesc()).append(" - ")
						.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
							.getValueV()).append(servType.getLabel());
				} else{
					str.append(acc.getShortDesc()).append(" - ")
					.append(acc.getInnerId()).append(servType.getLabel());
				}
				String key = str.toString();
				Service service = accToService.get(key);
				if(service != null){
					serviceToAcc(service, acc);
				}
			}
		}
	}
	
	private void addInitialServiceTypes(){
		for (Service initServ : accToService.values()){
			if (initServ.getIsInitiating()){
				ArrayList<Filter> filter = new ArrayList<Filter>();
				filter.add(new Filter("id", initServ.getServiceTypeId()));
				filter.add(new Filter("lang", language));
				SelectionParams params = new SelectionParams();		
				params.setRowIndexEnd(-1);
				params.setFilters(filter.toArray(new Filter[filter.size()]));
				ServiceType newST = Arrays.asList(
						productDao.getServiceTypes(userSessionId, params)).get(0);
				if (!containST(newST)){
					serviceTypes.add(newST);
				}
			}
		}
	}
	
	private boolean containST(ServiceType st){
		for (ServiceType servType : serviceTypes){
			if (servType.getId().equals(st.getId())){
				return true;
			}
		}
		return false;
	}
	
	private void serviceToAcc(Service service, 
			ApplicationElement acc) throws Exception{
		ApplicationElement serviceBlock = null;
		try {
			serviceBlock = addBl(AppElements.SERVICE, contractElement);
		} catch (UserException ignored) {
		}
		
		if (serviceBlock == null){
			throw new Exception("Cannot add service!");
		}
		
		fillServiceBlock(service.getId(), serviceBlock);
		
		ApplicationElement serviceObjectBlock;
		serviceObjectBlock = addBl(AppElements.SERVICE_OBJECT, serviceBlock);
		
		if (serviceObjectBlock == null) {
			throw new Exception("Cannot add service object!");
		}
		fillServiceObjectBlock(service, serviceObjectBlock, acc);
		
	}
	
	private void fillServiceBlock(Integer serviceId,
			ApplicationElement serviceBlock) throws Exception {
		if (serviceBlock.getLovId() != null) {
			KeyLabelItem[] lov = dictUtils.getLovItems(serviceBlock.getLovId());
			serviceBlock.setLov(lov);
		}
		serviceBlock.setValueN(new BigDecimal(serviceId));
	}
	
	private void fillServiceObjectBlock(Service service,
			ApplicationElement serviceObjectBlock, ApplicationElement linkBlock)
			throws Exception {
		serviceObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.hashCode()));
		serviceObjectBlock.setFake(true);
		serviceObjectBlock.setValueText(linkBlock.getBlockName());
		List <ApplicationElement> listObjects = linkedMap.get(linkBlock);
		if (listObjects == null){
			listObjects = new ArrayList<ApplicationElement>();
		}
		listObjects.add(serviceObjectBlock);
		linkedMap.put(linkBlock, listObjects);
			serviceObjectBlock.getChildByName(AppElements.START_DATE, 1).setValueD(new Date());
			ProductAttribute[] attrs = getAttribServise(service.getId());
		if (attrs != null) {
			for (ProductAttribute attr : attrs) {
				if (ProductAttribute.DEF_LEVEL_OBJECT
						.equals(attr.getDefLevel())) {
					addAttribute(attr.getId(), serviceObjectBlock, true);
				}
			}
		}
	}
	
	
	public void addAttribute(Integer attrId, ApplicationElement parent, boolean wizard) throws Exception {
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
	
	private void setAttributeLov(ProductAttribute attr,
			ApplicationElement attrBlock) {
		KeyLabelItem[] lov = dictUtils.getLovItems(attr.getLovId().intValue());
		ApplicationElement attributeValueEl = null;
		if (attr.isChar()) {
			attributeValueEl = attrBlock.getChildByName(AppElements.
					ATTRIBUTE_VALUE_CHAR, 1);
		} else if (attr.isNumber()) {
			attributeValueEl = attrBlock.getChildByName(AppElements.
					ATTRIBUTE_VALUE_NUM, 1);
		} else if (attr.isDate()) {
			attributeValueEl = attrBlock.getChildByName(AppElements.
					ATTRIBUTE_VALUE_DATE, 1);
		}

		if (attributeValueEl != null) {
			attributeValueEl.setLovId(attr.getLovId().intValue());
			attributeValueEl.setLov(lov);
		}
	}
	
	private void releaseAccounts(){
		accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
		List<SelectItem> listCards;
		for (ApplicationElement accountElement : accountElements) {
			listCards = accToCard.get(accountElement);
			if (listCards != null) {
				for (SelectItem listCard : listCards) {
					Card card = getCard((String) listCard.getValue());
					ApplicationElement cardEl = cardExist(card.getCardNumber());
					if (cardEl == null) {
						try {
							createAcc(card, accountElement);
						} catch (UserException e) {
							e.printStackTrace();
						}
					} else {

						try {
							List<ApplicationElement> objectList = accountElement.getChildrenByName(AppElements.ACCOUNT_OBJECT);
							boolean contain = false;
							BigDecimal id = new BigDecimal(cardEl.hashCode());
							for (ApplicationElement object : objectList) {
								if (id.compareTo(object.getValueN()) == 0) {
									contain = true;
									break;
								}
							}
							if (!contain) {
								ApplicationElement accountObj;
								accountObj = addBl(AppElements.ACCOUNT_OBJECT, accountElement);
								fillCardObjectBlock(accountObj, cardEl, true);
							}
						} catch (UserException e) {
							e.printStackTrace();
						}
					}
				}
			}
		}
	}
	
	private Card getCard(String cardNumber){
		for (Card aCardsList : cardsList) {
			if (aCardsList.getCardNumber().equals(cardNumber)) {
				return aCardsList;
			}
		}
		return null;
	}
	
	private ApplicationElement cardExist(String cardNumber){
		List<ApplicationElement>cardElements = contractElement.getChildrenByName(AppElements.CARD);
		for (ApplicationElement cardElement : cardElements) {
			String currenCardMask = cardElement.
					getChildByName("CARD_NUMBER", 1).getValueV();
			if (currenCardMask.equals(cardNumber)) {
				return cardElement;
			}
		}
		return null;
	}	
	private void createAcc(Card card, ApplicationElement acc) throws UserException{
		ApplicationElement cardEl;
				cardEl = addBl(AppElements.CARD, contractElement);
		for (int i = 0; i < cardEl.getChildren().size(); i++){
			if (cardEl.getChildren().get(i).getName().equalsIgnoreCase(AppElements.CARD_NUMBER)){
				cardEl.getChildren().get(i).setValueV(card.getCardNumber());
			}  else if(cardEl.getChildren().get(i).getName().equalsIgnoreCase(AppElements.CARD_TYPE)){
				cardEl.getChildren().get(i).setValueN(card.getCardTypeId());
			} 
		}
		ApplicationElement accountObj = addBl(AppElements.ACCOUNT_OBJECT, acc);
		fillCardObjectBlock(accountObj, cardEl, true);
	}
	
	private void fillCardObjectBlock(ApplicationElement cardObjectBlock,
			ApplicationElement linkBlock, boolean isChecked){
		long flag = isChecked ? 1 : 0;
		cardObjectBlock.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).setValueN(BigDecimal.valueOf(flag));
		cardObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.hashCode()));
		cardObjectBlock.setValueText(linkBlock.getBlockName());
		cardObjectBlock.setFake(true);
		List <ApplicationElement> listObjects = linkedMap.get(linkBlock);
		if (listObjects == null){
			listObjects = new ArrayList<ApplicationElement>();
		}
		listObjects.add(cardObjectBlock);
		linkedMap.put(linkBlock, listObjects);
	}
	

	@Override
	public void init(ApplicationWizardContext ctx) {
		accToCard = new HashMap<ApplicationElement, List<SelectItem>>();
		activeCard = new Card();
		accToUnbindCard = new HashMap<ApplicationElement, List<SelectItem>>();
		setServiceTypeValid(true);
		prevAccType = "";
		setAccountValid(true);
		bindCard = new ArrayList<SelectItem>();
		unbindCard = new ArrayList<SelectItem>();
		appWizCtx = ctx;
		this.applicationRoot = ctx.getApplicationRoot();
		linkedMap = ctx.getLinkedMap();
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		accToService = new HashMap<String, Service>();
		language = userLanguage = SessionWrapper.getField("language");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		ctx.setStepPage(page);
		customerElement = applicationRoot.retrive(AppElements.CUSTOMER);
		instId = ((BigDecimal) applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).getValue()).intValue();
		applicationFilters = ctx.getApplicationFilters();
		contractElement =  customerElement.retrive(AppElements.CONTRACT);
		productId = ((BigDecimal) contractElement.getChildByName(AppElements.PRODUCT_ID, 1).getValue()).longValue();
		fillServiceTypes();
		accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
		if ( accountElements.size() == 0){			 
			try {
				addBl(AppElements.ACCOUNT, contractElement);
			} catch (UserException ignored) {
				}
		} else {
			makeListCreatedServices(accountElements);
		}		
		createMenu();
		prepareDetailsFields();
	}
	
	private void makeListCreatedServices(List<ApplicationElement> accounts){
		oldServices = new ArrayList<ApplicationElement>();
		List<ApplicationElement> serviceElements =  
				contractElement.getChildrenByName(AppElements.SERVICE);
		if (serviceElements.size() > 0){
			for (ApplicationElement serviceEl: serviceElements){
				for (ServiceType type:serviceTypes){
					ArrayList<Filter> filters = getServiceFilter(type.getId());
					try{
						services = getServices(filters);
					}catch (Exception ignored){
					}
					for (Service service:services){
						if (serviceEl.getValueN().compareTo
								(new BigDecimal(service.getId()))==0){
							ApplicationElement acc = 
								isServiceConnectAccount(serviceEl, accounts);
							if (acc != null){
								StringBuilder str = new StringBuilder();
								if (acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
										.getValueV() != null){
									str.append(acc.getShortDesc()).append(" - ")
										.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
											.getValueV()).append(type.getLabel());
								} else{
									str.append(acc.getShortDesc()).append(" - ")
									.append(acc.getInnerId()).append(type.getLabel());
								}
								String key = str.toString();
								accToService.put(key, service);
								oldServices.add(serviceEl);
								break;
							}else {
								acc = isServiceConnectAccountNew(serviceEl, accounts);
								if (acc != null){
									StringBuilder str = new StringBuilder();
									if (acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
											.getValueV() != null){
										str.append(acc.getShortDesc()).append(" - ")
											.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
												.getValueV()).append(type.getLabel());
									} else{
										str.append(acc.getShortDesc()).append(" - ")
										.append(acc.getInnerId()).append(type.getLabel());
									}
									String key = str.toString();
									accToService.put(key, service);
									break;	
								}
							}
						}
					}
				}
			}
		}
	}
	
	private ApplicationElement isServiceConnectAccount(ApplicationElement serviceEl, 
			List<ApplicationElement>accounts){
		for	(ApplicationElement serviceObj:serviceEl.getChildrenByName(AppElements.SERVICE_OBJECT)){
			for(ApplicationElement acc: accounts){
				if (serviceObj.getValueN().compareTo(
						new BigDecimal(acc.getDataId()))==0){
					return acc;
				}
			}
		}
		return null;
	}
	
	private ApplicationElement isServiceConnectAccountNew(ApplicationElement serviceEl, 
			List<ApplicationElement>accounts){
		for	(ApplicationElement serviceObj:serviceEl.getChildrenByName(AppElements.SERVICE_OBJECT)){
			for(ApplicationElement acc: accounts){
				if (serviceObj.getValueN().compareTo(
						new BigDecimal(acc.hashCode()))==0){
					return acc;
				}
			}
		}
		return null;
	}
	
	private void fillServiceTypes(){
		ArrayList<Filter> filter = setFilters();
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filter.toArray(new Filter[filter.size()]));
		int count = productDao.getServiceTypeByProductCount(userSessionId, params);
		if (count > 0){
			serviceTypes = Arrays.asList(productDao.getServiceTypeByProduct(userSessionId, params));
		} else {
			serviceTypes = new ArrayList<ServiceType>();
		}
	}
	public void addNewAccount(){
		clearObjectAttr();
		MenuTreeItem accountsGroup;
		ApplicationElement newAccount = new ApplicationElement();
		try {
			newAccount = addBl(AppElements.ACCOUNT, contractElement);
		} catch (UserException e) {
			e.printStackTrace();
		}
		if (newAccount != null){	
			accountsGroup = new MenuTreeItem(newAccount.getShortDesc() + " - " 
					+ newAccount.getInnerId().toString(), AppElements.ACCOUNT,
					newAccount.getInnerId());
			if (serviceTypes != null){
				for (int b = 0; b < serviceTypes.size(); b++){
					MenuTreeItem serviceTypeItem = new MenuTreeItem
							( serviceTypes.get(b).getLabel(), AppElements.SERVICE_TYPE,
									b);
					accountsGroup.getItems().add(serviceTypeItem);
				}
			}
			leftMenu.add(accountsGroup);
			if (appWizCtx.isOldContract()){
				MenuTreeItem cardItem = new MenuTreeItem
						(AppElements.CARD, AppElements.CARD, 0);
				accountsGroup.getItems().add(cardItem);
				prepareCards();
			}
			leftMenu.remove(leftMenu.indexOf(newAccountsGroup));
			leftMenu.add(newAccountsGroup);
			node = accountsGroup;
			nodePath = new TreePath(accountsGroup, null);
			accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
			prepareDetailsFields();
		}
	}
	
	
	private ApplicationElement addBl(String name,
			ApplicationElement parent)throws UserException {
		ApplicationElement result;
		try {
			result = instance(parent, name);
		} catch (IllegalArgumentException e) {
			throw new UserException(e);
		}
		Integer instId = applicationRoot.retrive(AppElements.INSTITUTION_ID).getValueN()
				.intValue();
		Application appStub = new Application();
		appStub.setInstId(instId);
		applicationDao.fillRootChilds(userSessionId, instId, result, applicationFilters);
		if (name.equalsIgnoreCase(AppElements.CARD)){
			result.retrive(AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		}
		applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result,
				applicationFilters);
		return result;
	}
	
	public void updateAccountLabel(){
		String number = fieldMap.get("ACCOUNT_NUMBER").getValueV();
		if (number != null){
			ApplicationElement acc = accountElements.get(node.getInnerId() -1 );
			StringBuffer label;
			for (ServiceType serv:serviceTypes){
				label = new StringBuffer();
				label.append(node.getLabel())
					.append(serv.getLabel());
				String key = label.toString();
				if (accToService.containsKey(key)){
					Service service = accToService.get(key);
					accToService.remove(key);
					label = new StringBuffer();
					label.append(acc.getShortDesc())
						.append(" - ")
						.append(number)
						.append(serv.getLabel());
					key = label.toString();
					accToService.put(key, service);
				}
			}
			if (initialService != null){
				label = new StringBuffer();
				label.append(node.getLabel())
					.append(initialService.getServiceTypeName());
				String key = label.toString();
				if (accToService.containsKey(key)){
					Service service = accToService.get(key);
					accToService.remove(key);
					label = new StringBuffer();
					label.append(acc.getShortDesc())
						.append(" - ")
						.append(number)
						.append(initialService.getServiceTypeName());
					key = label.toString();
					accToService.put(key, service);
				}
			}
			label = new StringBuffer();
			label.append(acc.getShortDesc())
				.append(" - ")
				.append(number);
			node.setLabel(label.toString());
			
		}
	}
	
	private ArrayList<Filter> setFilters(){
		ArrayList<Filter> result = new ArrayList<Filter>(4);
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		result.add(f);
		f = new Filter("productId", productId);			
		result.add(f);
		f = new Filter("entityType", "ENTTACCT");
		result.add(f);
		f = new Filter();
		f.setElement("isInitial");
		f.setValue(false);
		//f = new Filter("entityType", "ENTTMRCH");
		result.add(f);
		return result;
	}
	
	private void createMenu(){
		MenuTreeItem accountsGroup = new MenuTreeItem();
		leftMenu = new ArrayList<MenuTreeItem>();
		accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
		for (ApplicationElement accountElement : accountElements) {
			StringBuilder nodeLabel = new StringBuilder();
			if (accountElement
					.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
					.getValueV() != null) {
				nodeLabel.append(accountElement.getShortDesc())
						.append(" - ")
						.append(accountElement
								.getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueV());

			} else {
				nodeLabel.append(accountElement.getShortDesc())
						.append(" - ")
						.append(accountElement.getInnerId());
			}
			accountsGroup = new MenuTreeItem(nodeLabel.toString(),
											 AppElements.ACCOUNT,
											 accountElement.getInnerId());
			if (serviceTypes != null) {
				for (int b = 0; b < serviceTypes.size(); b++) {
					MenuTreeItem serviceTypeItem = new MenuTreeItem
							(serviceTypes.get(b).getLabel(), AppElements.SERVICE_TYPE,
									b);
					accountsGroup.getItems().add(serviceTypeItem);
				}
			}
			if (appWizCtx.isOldContract()) {
				MenuTreeItem cardItem = new MenuTreeItem
						(AppElements.CARD, AppElements.CARD, 0);
				accountsGroup.getItems().add(cardItem);
				prepareCards();
			}
			leftMenu.add(accountsGroup);
		}
		node = accountsGroup;
		nodePath = new TreePath(accountsGroup, null);
		newAccountsGroup = new MenuTreeItem("Add new account", ADD_ACCOUNT);
		leftMenu.add(newAccountsGroup);
	}
	
	private void prepareCards(){
		List<Filter>filters = new ArrayList<Filter>();
		String customerNumber = applicationRoot.getChildByName(AppElements.CUSTOMER, 1).
				getChildByName(AppElements.CUSTOMER_NUMBER, 1).getValueV();
		filters.add(new Filter("lang", userLanguage));
		filters.add(new Filter("customerNumber", customerNumber));
		filters.add(new Filter("instId", instId));
		
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		Card[] cards = issDao.getCards(userSessionId, params);
		cardsList = new ArrayList<Card>(Arrays.asList(cards));
		
	}
	
	public void prepareDetailsFields(){
		if (node != null) {
			prepareFieldMap();
			prepareListMap();
		}
	}
	
	private void prepareFieldMap(){
		fieldMap = new HashMap<String, ApplicationElement>();
		if (node.getName().equalsIgnoreCase(AppElements.ACCOUNT)){
			clearObjectAttr();
			prepareInitialService();
			ApplicationElement accounts = accountElements.get(node.getInnerId() - 1);
			for (int i = 0; i < accounts.getChildren().size(); i++){
				ApplicationElement acc = accounts.getChildren().get(i);
				//if ((acc.getInfo() != null) && (acc.getInfo())){
				if((acc.getName().equalsIgnoreCase("ACCOUNT_NUMBER"))||
						(acc.getName().equalsIgnoreCase("ACCOUNT_TYPE"))||
							(acc.getName().equalsIgnoreCase("CURRENCY"))){
					fieldMap.put(acc.getName(), acc);
				}
			}
		} else if (node.getName().equalsIgnoreCase(AppElements.SERVICE_TYPE)){
			ArrayList<Filter>filters = getServiceFilter(
					serviceTypes.get(node.getInnerId()).getId()); 
			try{
				services = getServices(filters);
			}catch(Exception ignored){
			}
			String key = ((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel() 
					+ node.getLabel();
			if (!accToService.containsKey(key)){
				selectedService = null;
				clearObjectAttr();
			}else{
				Service selected = accToService.get(key);
				if (selected == null){
					selectedService = "-1";
				}else{
					selectedService = String.valueOf(selected.getId());
					isInishial(selected);
				}
				if (!selectedService.equalsIgnoreCase("-1") ){
					/*fillAttrTree(getAttribServise(
						Integer.parseInt(selectedService)));*/
					prepareAttr(getService());
				}else{
					clearObjectAttr();
				}
			}
		} else if (AppElements.CARD.equalsIgnoreCase(node.getName())){
			if (appWizCtx.isOldContract()){
				fillCardLists();
			}
		}
		
	}
	
	private void clearObjectAttr(){
		MbObjectAttributes attrs = ManagedBeanWrapper
				.getManagedBean(MbObjectAttributes.class);
		attrs.fullCleanBean();
	}
	
	private void isInishial(Service service){
		setLock(false);
		if (service.getIsInitiating() &&
				(oldServices != null) &&
				(oldServices.size() > 0)){
			for (ApplicationElement serv: oldServices){
				if (serv.getValueN().compareTo
						(new BigDecimal(service.getId()))==0){
					setLock(true);
				}
			}
		}	
	}
	
	private ProductAttribute[] getAttribServise(int serviceId){
		if (serviceId > 0){
			SelectionParams params = new SelectionParams();
			List<Filter> filters = setFilterForAttr();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexStart(0);
			params.setRowIndexEnd(Integer.MAX_VALUE);
	    	ProductAttribute[] attrs;
	    	attrs = productDao.getServiceAttributes(userSessionId, params);
	    	if (attributesMap == null) {
				attributesMap = new HashMap<Integer, ProductAttribute>();
			}
	    	
	    	for (ProductAttribute attr : attrs) {
				attributesMap.put(attr.getId(), attr);
			}
	    	return attrs;
		}
		return null;
	}
		
		
	private List <Filter> setFilterForAttr(){
		List<Filter> filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("instId");
		paramFilter.setValue(instId);
		filters.add(paramFilter);
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(language);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(EntityNames.SERVICE);
		filters.add(paramFilter);
			

		paramFilter = new Filter();
		paramFilter.setElement("serviceId");
		paramFilter.setValue(selectedService);
		filters.add(paramFilter);
		
		paramFilter = new Filter();
		paramFilter.setElement("productId");
		paramFilter.setValue(productId);
		filters.add(paramFilter);
		
		return filters;
	}
	
	private List<Service> getServices(ArrayList<Filter> filters) throws Exception{
		List<Service> result;
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		result =  Arrays.asList(productDao.getServicesByAccountProduct(userSessionId, params));
		if (result.size() != 0){
			int count = 0;
			for (Service service: accToService.values()){
				if (service.getId().equals(result.get(0).getId())){
					count++;
				}
			}
			ProductService productService;
			List<Filter> filt = new ArrayList<Filter>();
			filt.add(new Filter("serviceId", result.get(0).getId()));
			filt.add(new Filter("productId", productId));
			filt.add(new Filter("lang", userLanguage));
			params.setFilters(filt.toArray(new Filter[filt.size()]));
			productService = Arrays.asList(
					productDao.getProductServicesHier(userSessionId, params)).get(0);
			if (count == productService.getMaxCount()){
				//throw new Exception();
				removeAddLabel();
			} else if (count > productService.getMaxCount()){
				StringBuilder str = new StringBuilder();
				ApplicationElement acc = accountElements.get(node.getInnerId() - 1); 
				if ((acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV() != null) && 
					(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV().length() != 0)){
					str.append(acc.getShortDesc()).append(" - ")
						.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
							.getValue())
						.append(initialService.getServiceTypeName());
				} else{
					str.append(acc.getShortDesc()).append(" - ")
					.append(acc.getInnerId())
					.append(initialService.getServiceTypeName());
				}
				String key = str.toString();
				String message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "max_number_service");
				acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).setValueV(null);
				acc.getChildByName(AppElements.CURRENCY, 1).setValueV(null);
				accToService.remove(key);
				throw new Exception(message);
			}
		}
		return result;
		//return Arrays.asList(productDao.getServices(userSessionId, params));
	}
	
	private void removeAddLabel(){
		if (leftMenu.get(leftMenu.size() - 1).
				getName().equalsIgnoreCase(ADD_ACCOUNT)){
			leftMenu.remove(leftMenu.size() - 1);
		}
	}
	
	private ArrayList<Filter> getServiceFilter(int serviceTypeId){
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		filters.add(f);
		f = new Filter("serviceTypeId", serviceTypeId);
		filters.add(f);
		f = new Filter("instId", instId);
		filters.add(f);
		return filters;
	}
	
	private ArrayList<Filter> getInitialServiceFilter(){
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		filters.add(f);
		f = new Filter("isInitial", true);
		filters.add(f);
		f = new Filter("instId", instId);
		filters.add(f);
		f = new Filter("productId", productId);
		filters.add(f);
		String value = accountElements.get(node.getInnerId() - 1)
				.getChildByName(AppElements.CURRENCY, 1).getValueV();
		f = new Filter("currency", value);
		filters.add(f);
		value = accountElements.get(node.getInnerId() - 1)
				.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV();
		f = new Filter("accountType", value);
		filters.add(f);
		return filters;
	}
	
	public  List<SelectItem> getServicesRadio(){
		if (services != null){
			List<SelectItem> servicesRadio;
			if (checkMandatory()){
			servicesRadio = new ArrayList<SelectItem>(services.size());
			} else{
				servicesRadio = new ArrayList<SelectItem>(services.size() + 1);
				servicesRadio.add(new SelectItem("-1", DONT_CONNECT));
			}
			for(Service value : services){
				servicesRadio.add(new SelectItem(value.getId().toString(), value.getLabel()));
			}
		return servicesRadio;
		}else return null;
	}
	
	private boolean checkMandatory(){
		for (Service service: services){
			List<Filter> filters = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("serviceId");
			paramFilter.setValue(service.getId());
			filters.add(paramFilter);
			
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setValue(productId);
			filters.add(paramFilter);
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexStart(0);		
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			
			int count = productDao.getProductServiceMinCount(userSessionId, params);
			if (count > 0){
				return true;
			}
		}
		return false;
	}
	
	public void updateAttr(){
		clearObjectAttr();
		String key = ((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel() 
				+ node.getLabel();
		    	if (accToService.containsKey(key)){
		    		accToService.remove(key);
		    	}
		if ((selectedService != null) &&
				(Integer.parseInt(selectedService) > 0)){
			accToService.put(key, getService(selectedService));
			prepareAttr(getService());
			
		}else {
	    	accToService.put(key, null);
		}
	}
	
	private Service getService(String id){
		for (Service service:services){
			if (service.getId().toString().equalsIgnoreCase(id)) 
				return service;
		}
		return null;
	}
	
	private void prepareListMap(){
		listMap = new HashMap<String, List<SelectItem>>();
		for (ApplicationElement element: fieldMap.values()){
			if(element.getLovId() != null){
				if (element.getName().equalsIgnoreCase("CURRENCY") ||
						element.getName().equalsIgnoreCase("ACCOUNT_TYPE"))
					{
						Map <String, Object> map = new HashMap<String, Object>();
						map.put("PRODUCT_ID", productId);
						if(element.getName().equalsIgnoreCase("ACCOUNT_TYPE")){
							map.put("INSTITUTION_ID", instId);
						}
						listMap.put(element.getName(), 
								dictUtils.getLov(element.getLovId(), map));
					} else {
					listMap.put(element.getName(), 
							dictUtils.getLov(element.getLovId()));
				}
			}
		}
	}	
	
	public Map<String, ApplicationElement> getFieldMap(){
		return fieldMap;
	}
	
	public Map<String, List<SelectItem>> getLovMap(){
		return listMap;
	}
	
	public String getDetailsPage(){
		String result = SystemConstants.EMPTY_PAGE; 
		if (node != null){
			if (AppElements.ACCOUNT.equals(node.getName())){
				result = "/pages/common/application/person/accountDetails.jspx";
			} else if (AppElements.SERVICE_TYPE.equals(node.getName())){
				result = "/pages/common/application/person/serviceTypeDetails.jspx";
			} else if (AppElements.CARD.equalsIgnoreCase(node.getName())){
				result = "/pages/common/application/person/accountToCard.jspx";
			}
		}
		return result;
	}
	
	public void prepareInitialService(){
		ApplicationElement acc = accountElements.get(node.getInnerId() - 1);
		if (prevAccType != null &&
			!prevAccType.equalsIgnoreCase(
				acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV())){
				acc.getChildByName(AppElements.CURRENCY, 1).setValueV(null);
				clearObjectAttr();
			}
			prevAccType = acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV();
		
		if ((acc.getChildByName(AppElements.CURRENCY, 1).getValueV() != null)
				&&
			(acc.getChildByName(AppElements.CURRENCY, 1).getValueV().length() != 0)
				&&
			(acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV() != null)
				&&
			(acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV().length() != 0)){
			ArrayList<Filter> filters = getInitialServiceFilter();
			List<Service> services = new ArrayList<Service>();
			try{
				services = getServices(filters);
			}catch(Exception e){
				FacesUtils.addMessageError(e);
			}
			if (services.size() > 0){
				initialService = services.get(0);
				StringBuilder str = new StringBuilder();
				if ((acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV() != null) && 
					(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV().length() != 0)){
					str.append(acc.getShortDesc()).append(" - ")
						.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
							.getValue())
						.append(initialService.getServiceTypeName());
				} else{
					str.append(acc.getShortDesc()).append(" - ")
					.append(acc.getInnerId())
					.append(initialService.getServiceTypeName());
				}
				String key = str.toString();
			
				if (initialService != null){
					accToService.remove(key);
				}
				selectedService = initialService.getId().toString();
				accToService.put(key, initialService);
				clearObjectAttr();
				prepareAttr(initialService);
			}else{
				clearObjectAttr();
			}
		}else if ((acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV() != null)
				&&
			(acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV().length() != 0)){
			ApplicationElement currency = fieldMap.get(AppElements.CURRENCY);
			Map <String, Object> map = new HashMap<String, Object>();
			map.put(AppElements.PRODUCT_ID, productId);
			map.put(AppElements.ACCOUNT_TYPE, acc.getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV());
			listMap.put(currency.getName(), dictUtils.getLov(currency.getLovId(), map));
		}else{
			if (listMap != null && listMap.containsKey(AppElements.CURRENCY) &&
					listMap.get(AppElements.CURRENCY).size() != 0){
				Map <String, Object> map = new HashMap<String, Object>();
				map.put(AppElements.PRODUCT_ID, productId);
				ApplicationElement currency = fieldMap.get(AppElements.CURRENCY);
				listMap.put(currency.getName(), 
						dictUtils.getLov(currency.getLovId(), map));
			}
		}
	}
	
	public void setInitialService(Service initialService){
		this.initialService = initialService; 
	}
	
	public Service getInitialService(){
		return this.initialService;
	}
	
	
	private void prepareAttr(Service service){
		MbObjectAttributes attrs = ManagedBeanWrapper
				.getManagedBean(MbObjectAttributes.class);
		attrs.fullCleanBean();
		attrs.setServiceId(service.getId());
		attrs.setEntityType(EntityNames.PRODUCT);
		attrs.setInstId(instId);
		attrs.setProductType(service.getProductType());
		MbAttributeValues bean = ManagedBeanWrapper
				.getManagedBean(MbAttributeValues.class);
		bean.setTabName("attributesTab");
		bean.setParentSectionId(getSectionId());
		bean.setTableState(getSateFromDB(bean.getComponentId()));
	}
	
	private String getSectionId() {
		return SectionIdConstants.CONFIGURATION_SERVICING_SERVICE;
	}
	
	private Service getService(){
		for (Service service : services) {
			int idService = service.getId();
			int idSelected = Integer.parseInt(selectedService);
			if (idService == idSelected) {
				return service;
			}

		}
		return null;
	}
	
	public void deleteAccount(){
			if (checkMinLimit(contractElement)) return;
			revomeService();
			restructServices();
			removeElementFromApp(contractElement, AppElements.ACCOUNT);
			leftMenu.remove(node.getInnerId()-1);
			resetSelection(node);
			resetInnerId();
			createMenu();
			prepareDetailsFields();
	}
	
	private void resetInnerId(){
		int count = 1;
		for(ApplicationElement acc: contractElement.getChildrenByName(AppElements.ACCOUNT)){
			acc.setInnerId(count++);
		}
	}
	
	private void restructServices(){
		List <ApplicationElement>accounts = contractElement.getChildrenByName(AppElements.ACCOUNT);
	
		for (int i = node.getInnerId()-1; i < accounts.size() - 1; i++){
			for (ServiceType servType: serviceTypes){
				ApplicationElement oldAcc = accounts.get(i);
				ApplicationElement acc = accounts.get(i + 1);
				StringBuilder str = new StringBuilder();
				StringBuilder oldStr = new StringBuilder();
				if ((acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV() != null) && 
					(!acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV().equals(""))){
					str.append(acc.getShortDesc()).append(" - ")
						.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
							.getValueV()).append(servType.getLabel());
					oldStr.append(oldAcc.getShortDesc()).append(" - ")
					.append(oldAcc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV()).append(servType.getLabel());
				} else{
					str.append(acc.getShortDesc()).append(" - ")
						.append(acc.getInnerId()).append(servType.getLabel());
					oldStr.append(oldAcc.getShortDesc()).append(" - ")
						.append(oldAcc.getInnerId()).append(servType.getLabel());
					
				}
				String key = str.toString();
				String oldKey = oldStr.toString();
				accToService.remove(oldKey);
				if (accToService.containsKey(key)){
					Service serv = accToService.get(key);
					accToService.put(oldKey, serv);
				}
				
			}

		}
	}
	
	private void revomeService(){
		ApplicationElement acc = contractElement.getChildrenByName(AppElements.
				ACCOUNT).get(node.getInnerId()-1);
		for (ServiceType serviceType: serviceTypes){
			StringBuilder str = new StringBuilder();
			if ((acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
					.getValueV() != null) && 
				(!acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
					.getValueV().equals(""))){
				str.append(acc.getShortDesc()).append(" - ")
					.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV()).append(serviceType.getLabel());
				
			} else{
				str.append(acc.getShortDesc()).append(" - ")
					.append(acc.getInnerId()).append(serviceType.getLabel());
			}
			String key = str.toString();
			accToService.remove(key);
		}
		
	}
	
	private void resetSelection(MenuTreeItem targetParen){
		int id = targetParen.getInnerId() - 1;
		if (id > 0){
			nodePath = new TreePath(leftMenu.get(node.getInnerId()-2), null);
			node = leftMenu.get(node.getInnerId()-2);
		} else {
			nodePath = new TreePath(leftMenu.get(node.getInnerId()), null);
			node = leftMenu.get(node.getInnerId());
		}
		
	}
	
	private void removeElementFromApp(ApplicationElement parent, String targetName){
		ApplicationElement elementToDelete = retrive(parent, targetName, node.getInnerId());
		delete(elementToDelete, parent);
	}
	
	private boolean checkMinLimit(ApplicationElement element){
		List<ApplicationElement> acc = element.getChildrenByName(AppElements.ACCOUNT);
		boolean result = (acc.size() > 1);
		if (!result){
			FacesUtils.addMessageError("Cannot delete an element. The minimum limit is reached.");
		}
		return !result;
	}
	
	
	@Override
	public boolean validate() {
		boolean valid;
		valid = validateAccounts();
		return valid;
	}
	
	private boolean validateAccounts(){
		boolean mainValid = true;
		boolean valid;
		boolean validTree;
		List <ApplicationElement> accounts = 
			contractElement.getChildrenByName(AppElements.ACCOUNT);
		for (ApplicationElement acc: accounts){
			validTree = true;
			for (int i = 0; i < acc.getChildren().size(); i++){
				ApplicationElement accCh = acc.getChildren().get(i);
				//if ((accCh.getInfo() != null) 
					//	&& (acc.getInfo())
						//&& (acc.isRequired())){
					if(((accCh.getName().equalsIgnoreCase("ACCOUNT_NUMBER"))||
							(accCh.getName().equalsIgnoreCase("ACCOUNT_TYPE"))||
								(accCh.getName().equalsIgnoreCase("CURRENCY")) && 
								(accCh.isRequired()))){
						 valid = accCh.validate();
						 mainValid &= valid;
						 accCh.setValid(valid);
						 validTree &= valid;
					}
			}
			
			leftMenu.get(acc.getInnerId()-1).setValid(validTree);
			mainValid &= checkService(acc);
			mainValid &= checkAccount(acc);
		}
		return mainValid;
	}
	
	private boolean checkService(ApplicationElement acc){
		boolean mainValid = true;
		for (int i = 0; i < serviceTypes.size(); i++){
			boolean valid;
			StringBuilder str = new StringBuilder();
			if ((acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
					.getValueV() != null) && 
				(!acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV().equals(""))){
				str.append(acc.getShortDesc()).append(" - ")
					.append(acc.getChildByName(AppElements.ACCOUNT_NUMBER, 1)
						.getValueV())
					.append(serviceTypes.get(i).getLabel());
				
			} else{
				str.append(acc.getShortDesc()).append(" - ")
					.append(acc.getInnerId())
					.append(serviceTypes.get(i).getLabel());
			}
			String key = str.toString();
			valid = accToService.containsKey(key);
			mainValid &= valid;
			leftMenu.get(acc.getInnerId()-1).getItems().get(i).setValid(valid);
		}
		return mainValid;
	}
	
	private boolean checkAccount(ApplicationElement acc){
		boolean mainValid = true;
		bindCard = accToCard.get(acc);
		if (bindCard == null || bindCard.size() == 0){
			mainValid = false;
		}
		setAccountValid(mainValid);
		leftMenu.get(acc.getInnerId()-1).getItems().
			get(serviceTypes.size()).setValid(mainValid);
		return mainValid;
	}

	@Override
	public boolean checkKeyModifications() {
		return false;
	}
	
	public List<MenuTreeItem> getNodeChildren(){
		MenuTreeItem treeNode = treeNode();
		if (treeNode == null){
			return leftMenu;
		} else {
			return treeNode.getItems();
		}
	}
	
	public boolean getNodeHasChildren(){
		MenuTreeItem treeNode = treeNode();
		return (treeNode != null) && !treeNode.getItems().isEmpty();
	}
	public MenuTreeItem treeNode(){
		return (MenuTreeItem) Faces.var("item");
	}
	
	public MenuTreeItem getElement(){
		return node;
	}
	
	public void setElement(MenuTreeItem node){
		this.node = node;
	}
	
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}
	
	public TreePath getNodePath(){
		return nodePath;
	}
	
	public MenuTreeItem getNode(){
		return node;
	}
	
	public void setNode(MenuTreeItem node){
		this.node = node;
	}
	
	
	public String getSelectedService() {
		return selectedService;
	}

	public void setSelectedService(String selectedService) {
		this.selectedService = selectedService;
	}


	public boolean isLock() {
		return lock;
	}

	public void setLock(boolean lock) {
		this.lock = lock;
	}


	public boolean isServiceTypeValid() {
		serviceTypeValid = node.isValid();
		return serviceTypeValid;
	}

	public void setServiceTypeValid(boolean serviceTypeValid) {
		this.serviceTypeValid = serviceTypeValid;
	}

	public static class MenuTreeItem{
		private String label;
		private String name;
		private int innerId = 0;
		private String modelId;
		private boolean valid = true;
		private List<MenuTreeItem> items;
		private String cssClass;
		
		public MenuTreeItem(){
			
		}
		
		public MenuTreeItem(String name, Integer innerId){
			this(null, name, innerId);
		}	
		
		public MenuTreeItem(String label, String name){
			this(label, name, 0);
		}
		
		public MenuTreeItem(String label, String name, int innerId){
			this.label = label;
			this.name = name;
			this.innerId = innerId;
		}
		
		public MenuTreeItem(String label, String name, String cssClass){
			this(label, name, 0);
			this.cssClass = cssClass;
		}
		
		public String getLabel() {
			return label;
		}
		
		public void setLabel(String label) {
			this.label = label;
		}
		
		public String getName() {
			return name;
		}
		
		public void setName(String name) {
			this.name = name;
		}
		
		public boolean isValid() {
			return valid;
		}

		public void setValid(boolean valid) {
			this.valid = valid;
		}
		
		public List<MenuTreeItem> getItems() {
			if (items == null){
				items = new ArrayList<MenuTreeItem>();
			}
			return items;
		}
		
		public void setItems(List<MenuTreeItem> items) {
			this.items = items;
		}
		public int getInnerId() {
			return innerId;
		}

		public void setInnerId(int innerId) {
			this.innerId = innerId;
			updateModelId();
		}
		
		private void updateModelId(){
			modelId = name + innerId;
		}
		
		public int getModelId(){
			if (modelId == null){
				updateModelId();
			}
			return modelId.hashCode();
		}
		
		public String getCssClass() {
			return cssClass;
		}

		public void setCssClass(String cssClass) {
			this.cssClass = cssClass;
		}
		
	}

	@Override
	public boolean getLock() {
		return true;
	}

	public boolean isAccountValid() {
		return accountValid;
	}

	public void setAccountValid(boolean accountValid) {
		this.accountValid = accountValid;
	}
	
	public  List<SelectItem> getBindCard() {
		return bindCard;
	}

	public void setBindCard( List<SelectItem>  bindCard) {
		this.bindCard = bindCard;
	}

	public  List<SelectItem>  getUnbindCard() {
		return unbindCard;
	}
	
	public void clearBind(){
		bind = null;
	}
	
	public void clearUnbind(){
		unbind = null;
	}

	public void setUnbindCard( List<SelectItem>  unbindCard) {
		this.unbindCard = unbindCard;
	}

	public String  getBind() {
		if (bind != null){
			return (bind);
		} else {
			return "";
		}
	}

	public void setBind(String  bind) {
		this.bind = bind;
		if (bind != null){
			activeCard = getCard(bind);
			setUnbind(null);
		}
	}

	public String getUnbind() {
		if (unbind != null){
			return (unbind);
		}else{
			return "";
		}
	}
	
	public void setUnbind(String  unbind) {
		this.unbind = unbind;
		if (unbind != null){
			setActiveCard(getCard(unbind));
			setBind(null);
		}
	}

	public void doBind(){
			for(int j = 0; j < unbindCard.size(); j++ ){
				if (unbindCard.get(j).getValue().equals(bind)){
					bindCard.add(unbindCard.get(j));
					unbindCard.remove(j);
				}
		}
		bind = "";
	}
	
	public void doUnbind(){
			for(int j = 0; j < bindCard.size(); j++ ){
				if (bindCard.get(j).getValue().equals(unbind)){
					unbindCard.add(bindCard.get(j));
					bindCard.remove(j);
				}
			}
		unbind = "";
	}

	public Card getActiveCard() {
		return activeCard;
	}

	public void setActiveCard(Card activeCard) {
		this.activeCard = activeCard;
	}
	
	public int getUnbindCardSize(){
		return unbindCard.size();
	}
	
	public int getBindCardSize(){
		return bindCard.size();
	}
	
	private void fillCardLists(){
		boolean removed = false;
		int id = ((MenuTreeItem)(nodePath.getParentPath().getValue())).getInnerId() - 1;
		ApplicationElement currentAcc = accountElements.get(id);
		bindCard = accToCard.get(currentAcc);
		unbindCard = accToUnbindCard.get(currentAcc);
		if (bindCard != null &&
				unbindCard != null){
			return;
		}
		List<Card> newCards = new ArrayList<Card>();
		newCards.addAll(cardsList);
		unbindCard = new ArrayList<SelectItem>();
		bindCard = new ArrayList<SelectItem>();
		List<ApplicationElement>cardsEl = contractElement.getChildrenByName(AppElements.CARD);
		for (ApplicationElement aCardsEl : cardsEl) {
			List<ApplicationElement> objectsList =
					currentAcc.getChildrenByName(AppElements.ACCOUNT_OBJECT);
			BigDecimal objectId = new BigDecimal(aCardsEl.hashCode());
			for (ApplicationElement anObjectsList : objectsList) {
				if (anObjectsList.getValueN().compareTo(objectId) == 0) {
					removeCard(newCards, aCardsEl);
					removed = true;
				}
			}
			if (!removed) {
				String cardNumber = aCardsEl.getChildByName(AppElements.CARD_NUMBER, 1).getValueV();
				unbindCard.add(new SelectItem(cardNumber, cardNumber));
			}
		}

		for (Card newCard : newCards) {
			String cardMask = newCard.getMask();
			String cardNumber = newCard.getCardNumber();
			unbindCard.add(new SelectItem(cardNumber, cardMask));
		}
		accToCard.put(currentAcc, bindCard);
		accToUnbindCard.put(currentAcc, unbindCard);
			
	}
	
	private void removeCard(List<Card> list, ApplicationElement card){
		for (int i = 0; i < list.size(); i++){
			if (list.get(i).getCardNumber().equalsIgnoreCase(
					card.getChildByName(AppElements.CARD_NUMBER, 1).getValueV())){
				bindCard.add(new SelectItem(list.get(i).getCardNumber(),
						list.get(i).getMask()));
				list.remove(i);
				return;
			}
		}
	}
	
	@Override
	public void clearFilter() {
		
	}

}

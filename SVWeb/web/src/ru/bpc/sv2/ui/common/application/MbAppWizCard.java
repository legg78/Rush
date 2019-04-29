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

import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.products.ServiceType;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAppWizCard")
public class MbAppWizCard extends AbstractBean implements AppWizStep, Serializable {
	private static final long serialVersionUID = 1L;
	private static final String ADD_CARD = "ADD_CARD";
	private static final String DONT_CONNECT = "Don't connect";
	
	private String page = "/pages/common/application/person/appWizCard.jspx";
	private ApplicationWizardContext appWizCtx;
	private String language;
	private String userLanguage;
	private boolean mainLock = true;
	private Long userSessionId; 
	private ApplicationElement applicationRoot;
	private ApplicationElement customerElement;
	private ApplicationElement contractElement;
	private Long productId;
	private MenuTreeItem node;
	private TreePath nodePath;
	private Service initialService;
	private DictUtils dictUtils;
	private List <SelectItem> servicesRadio;
	private int instId;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private List <ServiceType> serviceTypes;
	private List<ApplicationElement> accountElements;
	private List<Account>accountsList;
	private Account activeAcc;
	private List<ApplicationElement> cardElements;
	private List <MenuTreeItem>leftMenu;
	private Map<String, ApplicationElement> fieldMap;
	private List <Service> services;
	private Map<String, Service> cardToService;
	private Map<ApplicationElement, List<SelectItem>> cardToAcc;
	private Map<ApplicationElement, List<SelectItem>> cardToUnbindAcc;
	private String selectedService;
	private Map<Integer, ProductAttribute> attributesMap;
	private Map<String, List<SelectItem>> listMap;
	private List<SelectItem>  bindAcc;
	private List<SelectItem>  unbindAcc;
	private String bind;
	private String unbind;
	private MenuTreeItem newCarsGroup;
	private boolean lock;
	private boolean serviceTypeValid;
	private boolean accountValid;
	private boolean person;
	private List<ApplicationElement> oldServices;
	private Map <ApplicationElement, List<ApplicationElement>> linkedMap;
	
	ProductsDao productDao = new ProductsDao();
	AccountsDao accountDao = new AccountsDao();
	ApplicationDao applicationDao = new ApplicationDao();

	@Override
	public ApplicationWizardContext release() {
		clearObjectAttr();
		releaseCards();
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
	
	private void releaseAccounts(){
		cardElements = contractElement.getChildrenByName(AppElements.CARD);
		List<SelectItem> listAccs = new ArrayList<SelectItem>();
		for (int i = 0; i < cardElements.size(); i++){			
			listAccs = cardToAcc.get(cardElements.get(i));
			if (listAccs != null){
				for (int j = 0; j < listAccs.size(); j++){
					Account acc = getAcc(listAccs.get(j).getLabel());
					ApplicationElement accEl = accExist(acc.getAccountNumber()); 
					if (accEl == null){
						try {
							createAcc(acc, cardElements.get(i));				
						} catch (UserException e) {
							e.printStackTrace();
						}
					} else {
						
						try {
							ApplicationElement accountObj = new ApplicationElement();
							accountObj = addBl(AppElements.ACCOUNT_OBJECT, accEl);
							fillAccountObjectBlock(accountObj, cardElements.get(i), true);
						} catch (UserException e) {
							e.printStackTrace();
						}
					}
				}
			}
		}
	}
	
	private ApplicationElement accExist(String accountNumber){
		for (int i = 0; i<accountElements.size(); i++){
			String currenAccountNumber = accountElements.get(i).
					getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueV();
			if (currenAccountNumber.equals(accountNumber)){
				return accountElements.get(i);
			}
		}
		return null;
	}	
	private void createAcc(Account acc, ApplicationElement card) throws UserException{
		ApplicationElement accEl = new ApplicationElement(); 
				accEl = addBl(AppElements.ACCOUNT, contractElement);
		for (int i = 0; i < accEl.getChildren().size(); i++){
			if (accEl.getChildren().get(i).getName().equalsIgnoreCase(AppElements.ACCOUNT_NUMBER)){
				accEl.getChildren().get(i).setValueV(acc.getAccountNumber());
			} else if(accEl.getChildren().get(i).getName().equalsIgnoreCase(AppElements.ACCOUNT_TYPE)){
				accEl.getChildren().get(i).setValueV(acc.getAccountType());
			}  else if(accEl.getChildren().get(i).getName().equalsIgnoreCase(AppElements.CURRENCY)){
				accEl.getChildren().get(i).setValueV(acc.getCurrency());
			}
		}
		ApplicationElement accountObj = addBl(AppElements.ACCOUNT_OBJECT, accEl);
		fillAccountObjectBlock(accountObj, card, true);
	}
	
	private void fillAccountObjectBlock(ApplicationElement accountObjectBlock,
			ApplicationElement linkBlock, boolean isChecked){
		long flag = isChecked ? 1 : 0;
		accountObjectBlock.getChildByName(AppElements.ACCOUNT_LINK_FLAG, 1).setValueN(
				BigDecimal.valueOf(flag));
		accountObjectBlock.setValueN(BigDecimal.valueOf(linkBlock.hashCode()));
		accountObjectBlock.setValueText(linkBlock.getBlockName());
		accountObjectBlock.setFake(true);
		List <ApplicationElement> listObjects = linkedMap.get(linkBlock);
		if (listObjects == null){
			listObjects = new ArrayList<ApplicationElement>();
		}
		listObjects.add(accountObjectBlock);
		linkedMap.put(linkBlock, listObjects);
	}

	
	private void releaseCards(){
		boolean noService;
		List<ApplicationElement> serviceElements =  
				contractElement.getChildrenByName(AppElements.SERVICE);
		if ((serviceElements != null) && 
				(serviceElements.size() > 0)){
			noService = false;
		} else {
			noService = true;
		}
		if (!noService){
			checkOldServices();
		}
		try {
			createServices();
		} catch (Exception e) {
		}
	}
	
	private void checkOldServices(){
		boolean found;
		if (oldServices == null){
			return;
		}
		for (ApplicationElement oldService: oldServices){
		found = false;
			for (String key: cardToService.keySet()){
				Service serv = cardToService.get(key);
				if (oldService.getValueN().compareTo(new BigDecimal(serv.getId())) == 0){
					found = true;
					cardToService.remove(key);
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
		cardElements = contractElement.getChildrenByName(AppElements.CARD);
		addInitialServiceTypes();
		for (ApplicationElement card: cardElements){
			for (ServiceType servType: serviceTypes){
				StringBuffer str = new StringBuffer();
				if ((card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValue() != null) && 
					(card.getChildByName(AppElements.CARD_NUMBER, 1)
							.getValueV().length() != 0)){
					str.append(card.getShortDesc()).append(" - ")
						.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
							.getValueV()).append(servType.getLabel());
				} else{
					str.append(card.getShortDesc()).append(" - ")
					.append(card.getInnerId()).append(servType.getLabel());
				}
				String key = str.toString();
				Service service = cardToService.get(key);
				if(service != null){
					serviceToCard(service, card);
				}
			}
		}
	}
	
	private void addInitialServiceTypes(){
		for (Service initServ : cardToService.values()){
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
	
	private void serviceToCard(Service service, 
			ApplicationElement card) throws Exception{
		ApplicationElement serviceBlock = null;
		try {
			serviceBlock = addBl(AppElements.SERVICE, contractElement);
		} catch (UserException e) {
		}
		
		if (serviceBlock == null){
			throw new Exception("Cannot add service!");
		}
		
		fillServiceBlock(service.getId(), serviceBlock);
		
		ApplicationElement serviceObjectBlock = null;
		serviceObjectBlock = addBl(AppElements.SERVICE_OBJECT, 
				serviceBlock);
		
		if (serviceObjectBlock == null) {
			throw new Exception("Cannot add service object!");
		}
		fillServiceObjectBlock(service, serviceObjectBlock, card);
	}
	
	private void fillServiceBlock(Integer serviceId,
			ApplicationElement serviceBlock) throws Exception {
		if (serviceBlock.getLovId() != null) {
			KeyLabelItem[] lov = dictUtils.getLovItems(serviceBlock.getLovId()
					.intValue());
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
			serviceObjectBlock.getChildByName(AppElements.START_DATE, 1).setValueD(
					new Date());
			ProductAttribute[] attrs = getAttribServise(service.getId()
					.intValue());
			for (ProductAttribute attr : attrs) {
				if (ProductAttribute.DEF_LEVEL_OBJECT
						.equals(attr.getDefLevel())) {
					addAttribute(attr.getId(), serviceObjectBlock, true);
				}
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
	
	private void setAttributeLov(ProductAttribute attr,
			ApplicationElement attrBlock) {
		KeyLabelItem[] lov = dictUtils.getLovItems(attr.getLovId().intValue());
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

	@Override
	public void init(ApplicationWizardContext ctx) {
		setServiceTypeValid(true);
		setAccountValid(true);
		activeAcc = new Account();
		cardToAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		cardToUnbindAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		language = userLanguage = SessionWrapper.getField("language");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		appWizCtx = ctx;
		linkedMap = ctx.getLinkedMap();
		this.applicationRoot = ctx.getApplicationRoot();
		ctx.setStepPage(page);
		applicationFilters = ctx.getApplicationFilters();
		
		customerElement = applicationRoot.retrive(AppElements.CUSTOMER);
		instId = ((BigDecimal) applicationRoot.getChildByName("INSTITUTION_ID", 1).getValue()).intValue();
		initialService = null;
		setPerson(applicationRoot.retrive(AppElements.CUSTOMER_TYPE).getValue().equals(EntityNames.PERSON));
		contractElement = customerElement.retrive(AppElements.CONTRACT);
		productId = ((BigDecimal) contractElement.getChildByName("PRODUCT_ID", 1).getValue()).longValue();
		fillServiceTypes();
		accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
		cardElements = contractElement.getChildrenByName(AppElements.CARD);
		accountsList = new ArrayList<Account>();
		getAccounts();
		cardToService = new HashMap<String, Service>();
		if ( cardElements.size() == 0){			 
			try {
				ApplicationElement card = 
						addBl(AppElements.CARD, contractElement);
				addBl(AppElements.CARDHOLDER, card);
			} catch (UserException e) {
				}
		} else{
			makeListCreatedServices(cardElements);
		}
		
		creatMenu();
		prepareDetailsFields();
	}
	
	private void makeListCreatedServices(List<ApplicationElement> cards){
		oldServices = new ArrayList<ApplicationElement>();
		List<ApplicationElement> serviceElements =  
				contractElement.getChildrenByName(AppElements.SERVICE);
		if (serviceElements.size() > 0){
			for (ApplicationElement serviceEl: serviceElements){
				for (ServiceType type:serviceTypes){
					ArrayList<Filter> filters = getServicesFilter(type.getId());
					try{
						services = getServices(filters);
					}catch (Exception e){
					}
					for (Service service:services){
						if (serviceEl.getValueN().compareTo
								(new BigDecimal(service.getId())) == 0){
							ApplicationElement card = 
								isServiceConnectCard(serviceEl, cards);
							if (card != null){
								StringBuffer str = new StringBuffer();
								if (card.getChildByName(AppElements.CARD_NUMBER, 1)
										.getValueV() != null){
									str.append(card.getShortDesc()).append(" - ")
										.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
											.getValueV()).append(type.getLabel());
								} else{
									str.append(card.getShortDesc()).append(" - ")
									.append(card.getInnerId()).append(type.getLabel());
								}
								String key = str.toString();
								cardToService.put(key, service);
								oldServices.add(serviceEl);
								break;
							}else {
								card = isServiceConnectCardNew(serviceEl, cards);
								if (card != null){
									StringBuffer str = new StringBuffer();
									if (card.getChildByName(AppElements.CARD_NUMBER, 1)
											.getValueV() != null){
										str.append(card.getShortDesc()).append(" - ")
											.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
												.getValueV()).append(type.getLabel());
									} else{
										str.append(card.getShortDesc()).append(" - ")
										.append(card.getInnerId()).append(type.getLabel());
									}
									String key = str.toString();
									cardToService.put(key, service);
									break;	
								}
							}
						}
					}
				}
			}
		}
	}
	
	private ApplicationElement isServiceConnectCard(ApplicationElement serviceEl, 
			List<ApplicationElement>cards){
		for	(ApplicationElement serviceObj:serviceEl.getChildrenByName(AppElements.SERVICE_OBJECT)){
			for(ApplicationElement card: cards){
				if (serviceObj.getValueN().compareTo(
						new BigDecimal(card.getDataId())) == 0){
					return card;
				}
			}
		}
		return null;
	}
	
	private ApplicationElement isServiceConnectCardNew(ApplicationElement serviceEl, 
			List<ApplicationElement>cards){
		for	(ApplicationElement serviceObj:serviceEl.getChildrenByName(AppElements.SERVICE_OBJECT)){
			for(ApplicationElement card: cards){
				if (serviceObj.getValueN().compareTo(
						new BigDecimal(card.hashCode())) == 0){
					return card;
				}
			}
		}
		return null;
	}
	
	private void getAccounts(){
		ArrayList<Filter> filter = new ArrayList<Filter>();
		Filter f = new Filter();
		
		f = new Filter("productId", productId);			
		filter.add(f);
		
		f = new Filter("instId", instId);
		filter.add(f);
		
		f = new Filter("customerNumber", 
					customerElement.getChildByName(AppElements.CUSTOMER_NUMBER, 1)
						.getValueV());
		filter.add(f);
		
		
		
		f = new Filter("lang",language);
		filter.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filter.toArray(new Filter[filter.size()]));
		int count = accountDao.getIssAccountsCount(userSessionId, params);
		if (count > 0){
			accountsList = Arrays.asList(accountDao.getIssAccounts(userSessionId, params));
			
		} else {
			accountsList = new ArrayList<Account>();
		}
	}

	@Override
	public boolean validate() {
		boolean valid = true;
		valid = validateCards();
		return valid;
	}
	
	private boolean validateCards(){
		boolean mainValid = true;
		boolean valid;
		boolean validTree;
		List <ApplicationElement> cards = 
				contractElement.getChildrenByName(AppElements.CARD);
		for (ApplicationElement card: cards){
			validTree = true;
			for (int i = 0; i < card.getChildren().size(); i++){
				valid = true;
				ApplicationElement cardCh = card.getChildren().get(i);
				//if ((accCh.getInfo() != null) 
					//	&& (acc.getInfo())
					//	&& (acc.isRequired())){
					if(((cardCh.getName().equalsIgnoreCase("CARD_NUMBER"))||
							(cardCh.getName().equalsIgnoreCase("CARD_TYPE"))||
								(cardCh.getName().equalsIgnoreCase(AppElements.CURRENCY)) && 
								(cardCh.isRequired()))){
						 valid &= cardCh.validate();
						 mainValid &= valid;
						 cardCh.setValid(valid);
						 validTree &= valid;
					}
					
					if (cardCh.getName().equalsIgnoreCase(AppElements.CARDHOLDER)){
						for(int j = 0; j<cardCh.getChildren().size(); j++){
							ApplicationElement cardHolderCh = cardCh.getChildren().get(j);
							/*if((cardHolderCh.getInfo() != null)
									&& cardHolderCh.getInfo()
									&& cardHolderCh.isRequired()){*/
							if ((cardHolderCh.getName().equalsIgnoreCase("CARDHOLDER_NUMBER") ||
									cardHolderCh.getName().equalsIgnoreCase("CARDHOLDER_NAME")) &&
									(cardHolderCh.isRequired())){
								valid &= cardHolderCh.validate();
								 mainValid &= valid;
								 cardHolderCh.setValid(valid);
								 validTree &= valid;
							}		
						}
					}
			}
			leftMenu.get(card.getInnerId()-1).setValid(validTree);
			mainValid &= checkService(card);
			mainValid &= checkAccount(card);
		}
		return mainValid;
	}
	
	private boolean checkService(ApplicationElement card){
		boolean mainValid = true;
		for (int i = 0; i < serviceTypes.size(); i++){
			boolean valid;
			StringBuffer str = new StringBuffer();
			if ((card.getChildByName(AppElements.CARD_NUMBER, 1)
					.getValueV() != null) || 
				(!card.getChildByName(AppElements.CARD_NUMBER, 1)
					.getValueV().equals(""))){
				str.append(card.getShortDesc()).append(" - ")
					.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV())
					.append(serviceTypes.get(i).getLabel());
			} else{
				str.append(card.getShortDesc()).append(" - ")
				.append(card.getInnerId())
				.append(serviceTypes.get(i).getLabel());
			}
			String key = str.toString();
			valid = cardToService.containsKey(key);
			mainValid &= valid;
			leftMenu.get(card.getInnerId()-1).getItems().get(i).setValid(valid);
		}
		return mainValid;
	}
	
	private boolean checkAccount(ApplicationElement card){
		boolean mainValid = true;
		List<SelectItem> accs = cardToAcc.get(card);
		if (accs == null || accs.size() == 0){
			mainValid = false;
		}
		leftMenu.get(card.getInnerId()-1).getItems().
			get(serviceTypes.size()).setValid(mainValid);
		setAccountValid(mainValid);
		return mainValid;
	}

	@Override
	public boolean checkKeyModifications() {
		// TODO Auto-generated method stub
		return false;
	}
	
	private void fillServiceTypes(){
		ArrayList<Filter> filter = setFilters();
		SelectionParams params = new SelectionParams();		
		params.setRowIndexEnd(-1);
		params.setFilters(filter.toArray(new Filter[filter.size()]));
		int count = productDao.getServiceTypeByProductCount(userSessionId, params);
		if (count > 0){
			serviceTypes = Arrays.asList(productDao.getServiceTypeByProduct(userSessionId, params));
			
		} else {
			serviceTypes = new ArrayList<ServiceType>();
		}
	}
	
	private ArrayList<Filter> setFilters(){
		ArrayList<Filter> result = new ArrayList<Filter>(4);
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		result.add(f);
		f = new Filter();
		f.setElement("productId");
		f.setValue(productId);
		result.add(f);
		f = new Filter();
		f.setElement("entityType");
		f.setValue("ENTTCARD");
		result.add(f);
		f = new Filter();
		f.setElement("isInitial");
		f.setValue(false);
		//f = new Filter("entityType", "ENTTMRCH");
		result.add(f);
		return result;
	}
	
	private ApplicationElement addBl(String name, 
			ApplicationElement parent)throws UserException {
		ApplicationElement result = new ApplicationElement();
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
		if (name.equalsIgnoreCase(AppElements.ACCOUNT)){
			result.retrive(AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
		}
		applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result,
				applicationFilters);
		return result;
	} 
	
	public void updateCardLabel(){
		String number = fieldMap.get("CARD_NUMBER").getValueV();
		if (number != null){
			ApplicationElement card = cardElements.get(node.getInnerId() -1 );
			StringBuffer label = new StringBuffer();
			for (ServiceType serv:serviceTypes){
				label = new StringBuffer();
				label.append(node.getLabel())
					.append(serv.getLabel());
				String key = label.toString();
				if (cardToService.containsKey(key)){
					Service service = cardToService.get(key);
					cardToService.remove(key);
					label = new StringBuffer();
					label.append(card.getShortDesc())
						.append(" - ")
						.append(number)
						.append(serv.getLabel());
					key = label.toString();
					cardToService.put(key, service);
				}
			}
			if (initialService != null){
				label = new StringBuffer();
				label.append(node.getLabel())
					.append(initialService.getServiceTypeName());
				String key = label.toString();
				if (cardToService.containsKey(key)){
					Service service = cardToService.get(key);
					cardToService.remove(key);
					label = new StringBuffer();
					label.append(card.getShortDesc())
						.append(" - ")
						.append(number)
						.append(initialService.getServiceTypeName());
					key = label.toString();
					cardToService.put(key, service);
				}
			}
			label = new StringBuffer();
			label.append(card.getShortDesc())
				.append(" - ")
				.append(number);
			node.setLabel(label.toString());
			
		}
	}
	
	private void creatMenu(){
		MenuTreeItem cardsGroup = new MenuTreeItem();
		leftMenu = new ArrayList<MenuTreeItem>();
		cardElements = contractElement.getChildrenByName(AppElements.CARD);
		for (int i = 0; i < cardElements.size(); i++){
			cardsGroup = new MenuTreeItem(cardElements.get(i).
					getShortDesc() + " - " + cardElements.get(i).
					getInnerId().toString(), AppElements.CARD, 
					cardElements.get(i).getInnerId());
			if (serviceTypes != null){
				for (int b = 0; b < serviceTypes.size(); b++){
					MenuTreeItem serviceTypeItem = new MenuTreeItem
							( serviceTypes.get(b).getLabel(), AppElements.SERVICE_TYPE, 
									b);
					cardsGroup.getItems().add(serviceTypeItem);
				}
			}
			MenuTreeItem accountsItem = new MenuTreeItem(AppElements.ACCOUNT, AppElements.ACCOUNT, 1); 
			cardsGroup.getItems().add(accountsItem);
			leftMenu.add(cardsGroup);
		}
		node = cardsGroup;
		TreePath accountPath = new TreePath(cardsGroup, null);		
		nodePath = accountPath;
		newCarsGroup = new MenuTreeItem("Add new card", ADD_CARD);
		leftMenu.add(newCarsGroup);
	}
	
	public void prepareDetailsFields(){
		if (node != null) {
			prepareFieldMap();
			prepareListMap();
		}
	}
	
	private void prepareListMap(){
		listMap = new HashMap<String, List<SelectItem>>();
		for (ApplicationElement element: fieldMap.values()){
			if(element.getLovId() != null){
				if (element.getName().equalsIgnoreCase("CARD_TYPE")){
					HashMap<String, Object> map = new HashMap<String, Object>();
					map.put("PRODUCT_ID", productId);
					listMap.put(element.getName(), 
							dictUtils.getLov(element.getLovId(), map));
				}else {
				listMap.put(element.getName(), 
						dictUtils.getLov(element.getLovId()));
				}
			}
		}
	}
	
	private void prepareFieldMap(){
		cardElements = contractElement.getChildrenByName(AppElements.CARD);
		fieldMap = new HashMap<String, ApplicationElement>();
		if (node.getName().equalsIgnoreCase(AppElements.ACCOUNT)){
			/*ApplicationElement accounts = accountElements.get(node.getInnerId() - 1);
			for (int i = 0; i < accounts.getChildren().size(); i++){
				ApplicationElement acc = accounts.getChildren().get(i);
				//if ((acc.getInfo() != null) && (acc.getInfo())){
				if((acc.getName().equalsIgnoreCase(AppElements.ACCOUNT_NUMBER))||
						(acc.getName().equalsIgnoreCase(AppElements.ACCOUNT_TYPE))||
							(acc.getName().equalsIgnoreCase(AppElements.CURRENCY))){
					fieldMap.put(acc.getName(), acc);
				}
			}*/
		} else if (node.getName().equalsIgnoreCase(AppElements.SERVICE_TYPE)){
			ArrayList<Filter> filters = getServicesFilter(
					serviceTypes.get(node.getInnerId()).getId());
			try{
				services = getServices(filters);
			}catch(Exception e){
			}
			String key = ((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel() 
					+ node.getLabel();
			if (!cardToService.containsKey(key)){
				selectedService = null;
				clearObjectAttr();
			}else{
				Service selected = cardToService.get(key);
				if (selected == null){
					selectedService = "-1";
				}else{
					selectedService = String.valueOf(selected.getId());
				}
				if (!selectedService.equalsIgnoreCase("-1") ){
					/*fillAttrTree(getAttribServise(
						Integer.parseInt(selectedService)));*/
					prepareAttr(getService());
				}else{
					clearObjectAttr();
				}
			}
		} else if (node.getName().equalsIgnoreCase(AppElements.CARD)){
			bindAcc = new ArrayList<SelectItem>();
			unbindAcc = new ArrayList<SelectItem>();
			fillAccsList();
			ApplicationElement cardEl = cardElements.get(node.getInnerId() - 1);
			for (int i = 0; i < cardEl.getChildren().size(); i++){
				ApplicationElement card = cardEl.getChildren().get(i);
				//if ((acc.getInfo() != null) && (acc.getInfo())){
				if((card.getName().equalsIgnoreCase("CARD_NUMBER"))||
						(card.getName().equalsIgnoreCase("CARD_TYPE"))){
					fieldMap.put(card.getName(), card);
				}
				if (card.getName().equalsIgnoreCase(AppElements.CARDHOLDER)){
					for (int j = 0; j < card.getChildren().size(); j++){
						if ((card.getChildren().get(j).getName().equals("CARDHOLDER_NUMBER")) ||
								(card.getChildren().get(j).getName().equals("CARDHOLDER_NAME"))){
							fieldMap.put(card.getChildren().get(j).getName(), card.getChildren().get(j));
						}
					}
				}
			}
		}
	}
	
	private void prepareAttr(Service service){
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean(MbObjectAttributes.class);
		attrs.fullCleanBean();
		//attrs.setServiceId(Integer.parseInt(selectedService));
		attrs.setServiceId(service.getId());
		attrs.setEntityType(EntityNames.PRODUCT);
		attrs.setInstId(instId);
		//attrs.setProductType(getService().getProductType());
		attrs.setProductType(service.getProductType());
		attrs.setProductId(productId.intValue());
		MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper
				.getManagedBean(MbAttributeValues.class);
		bean.setTabName("attributesTab");
		bean.setParentSectionId(getSectionId());
		bean.setTableState(getSateFromDB(bean.getComponentId()));
	}
	
	private String getSectionId() {
		return SectionIdConstants.CONFIGURATION_SERVICING_SERVICE;
	}
	
	private Service getService(){
		Service result = null;
		for (int i = 0; i<services.size(); i++){
			int idService = services.get(i).getId().intValue();
			int idSelected = Integer.parseInt(selectedService);
			if (idService == idSelected){
				return services.get(i); 
			}
				
		}
		return result;
	}
	
	private void fillAccsList(){
		boolean removed = false;
		List<Account> newAcc = new ArrayList<Account>();
		ApplicationElement currentCard = cardElements.get(node.getInnerId() - 1);
		bindAcc = cardToAcc.get(currentCard);
		unbindAcc = cardToUnbindAcc.get(currentCard);
		if ((bindAcc != null) && 
				(unbindAcc != null)){
			return;
		}
		bindAcc = new ArrayList<SelectItem>();
		unbindAcc = new ArrayList<SelectItem>();
		newAcc.addAll(accountsList);
		for(int i = 0; i<accountElements.size(); i++){
			List<ApplicationElement> object = accountElements.get(i).
					getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for(int j = 0; j<object.size(); j++){
				BigDecimal dataId = new BigDecimal(currentCard.getDataId());
				if (object.get(j).getValueN().compareTo(dataId) == 0){
					removeAcc(newAcc, accountElements.get(i));
					removed = true;
				}
			}
			if (!removed){
				String accNumb = accountElements.get(i).
						getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueV();
				unbindAcc.add(new SelectItem(accNumb,accNumb));
			} else{
				removed = false;
			}
		}
		for (int i = 0; i<newAcc.size(); i++){
			unbindAcc.add(new SelectItem(newAcc.get(i).getAccountNumber(),
					newAcc.get(i).getAccountNumber()));
		}
		cardToAcc.put(currentCard, bindAcc);
		cardToUnbindAcc.put(currentCard, unbindAcc);
	}
	
	private void removeAcc(List<Account>listAcc, ApplicationElement account){
		for (int i = 0; i < listAcc.size(); i++){
			if (listAcc.get(i).getAccountNumber().equalsIgnoreCase(
					account.getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueText())){
				bindAcc.add(new SelectItem(listAcc.get(i).getAccountNumber(),
						listAcc.get(i).getAccountNumber()));
				listAcc.remove(i);
				return;
			}
		}
	}
	
	public void updateAttr(){
		clearObjectAttr();
		String key = ((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel() 
				+ node.getLabel();
		    	if (cardToService.containsKey(key)){
		    		cardToService.remove(key);
		    	}
		if ((selectedService != null) &&
				(Integer.parseInt(selectedService) > 0)){
			cardToService.put(key, getService(selectedService));
			prepareAttr(getService());
		}else {
	    	cardToService.put(key, null);
		}
	}
	
	public boolean getNodeHasChildrenAttr() {
    	return getProductAttribute().hasChildren();
    }
	
	private Service getService(String id){
		for (Service service:services){
			if (service.getId().toString().equalsIgnoreCase(id)) 
				return service;
		}
		return null;
	}
	
	public void setNodePath(TreePath nodePath){
		this.nodePath = nodePath;
	}
	
	public TreePath getNodePath(){
		return nodePath;
	}
	
	public void copyData() throws Exception{
		ApplicationElement cardHolder = cardElements.get(node.getInnerId()-1)
				.retrive(AppElements.CARDHOLDER);
		if (cardHolder == null){
			applicationDao.fillRootChilds(userSessionId, instId, cardHolder, applicationFilters);
		}
		ApplicationElement person = new ApplicationElement();
		try{
			person = customerElement.tryRetrive(AppElements.PERSON);
			if (person == null){
				String msg = new String("Element 'PERSON' has not been found");
				throw new Exception(msg);
			}
		} catch(Exception e){
			FacesUtils.addMessageError(e);
			return;
		}
		ApplicationElement personCardHolder = cardHolder.tryRetrive(AppElements.PERSON);
		if (personCardHolder == null){
			try {
				personCardHolder = addBl(AppElements.PERSON, cardHolder);
			} catch (UserException e) {
				e.printStackTrace();
			}
		}
		personCardHolder = person.clone();
		/*applicationDao.fillRootChilds(userSessionId, personCadHolder,
				applicationFilters);
		for (int i = 0; i < person.getChildren().size(); i++){
			personCadHolder.getChildren().get(i).set(
					person.getChildren().get(i).getValueD());
			personCadHolder.getChildren().get(i).set(
					person.getChildren().get(i).getValueText());
			personCadHolder.getChildren().get(i).set(
					person.getChildren().get(i).getValueV());
			personCadHolder.getChildren().get(i).setValue(
					person.getChildren().get(i).getValue());
			personCadHolder.getChildren().get(i).setValueN(
					person.getChildren().get(i).getValueN());
			personCadHolder.getChildren().get(i).setLov(
					person.getChildren().get(i).getLov());
		}*/
		
		
	}
	
	public void prepareInitialService(){
		BigDecimal id = (BigDecimal)cardElements.get(node.getInnerId() - 1)
				.getChildByName("CARD_TYPE", 1).getValue();
		if (id != null){ 
			ArrayList<Filter> filters = getInitialServiceFilter();
			List<Service>services = new ArrayList<Service>();
			try{
				services = getServices(filters);
			}catch (Exception e){
				FacesUtils.addMessageError("max count of service is reached");
			}
			if (services.size() > 0){
				ApplicationElement card = cardElements.get(node.innerId -1 );
				initialService = services.get(0);
				StringBuffer str = new StringBuffer();
				if ((card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV() != null) && 
					(card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV().length() != 0)){
					str.append(card.getShortDesc()).append(" - ")
						.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
							.getValue())
						.append(initialService.getServiceTypeName());
				} else{
					str.append(card.getShortDesc()).append(" - ")
					.append(card.getInnerId())
					.append(initialService.getServiceTypeName());
				}
				String key = str.toString();
			
				if (initialService != null){
					cardToService.remove(key);
				}
				selectedService = initialService.getId().toString();
				cardToService.put(key, initialService);
				clearObjectAttr();
				prepareAttr(initialService);
			}else{
				clearObjectAttr();
			}
		}
	}
	
	private void clearObjectAttr(){
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean(MbObjectAttributes.class);
		attrs.fullCleanBean();
	}
	
	public List<MenuTreeItem> getNodeChildren(){
		MenuTreeItem treeNode = treeNode();
		if (treeNode == null){
			return leftMenu;
		} else {
			return treeNode.getItems();
		}
	}
	
	public Service getInitialService(){
		return initialService;
	}
	
	public void setInitialService(Service initialService){
		this.initialService = initialService;
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
	
	public MenuTreeItem getNode(){
		return node;
	}
	
	public void setNode(MenuTreeItem node){
		this.node = node;
	}
	
	private ProductAttribute getProductAttribute() {
        return (ProductAttribute) Faces.var("prodAttr");
    }
	
	private ProductAttribute[] getAttribServise(int serviceId){
		if (serviceId > 0){
			SelectionParams params = new SelectionParams();
			List<Filter> filters = setFilterForAttr();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexStart(0);
			params.setRowIndexEnd(Integer.MAX_VALUE);
	    	ProductAttribute[] attrs = null;
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
		//return Arrays.asList(productDao.getServices(userSessionId, params));
		result =  Arrays.asList(productDao.getServicesByCardProduct(userSessionId, params));
		if (result.size() != 0){
			int count = 0;
			for (Service service: cardToService.values()){
				if (service.getId().equals(result.get(0).getId())){
					count++;
				}
			}
			ProductService productService = new ProductService();
			List<Filter> filt = new ArrayList<Filter>();
			filt.add(new Filter("serviceId", result.get(0).getId()));
			filt.add(new Filter("productId", productId));
			filt.add(new Filter("lang", userLanguage));
			params.setFilters(filt.toArray(new Filter[filt.size()]));
			productService = (ProductService) Arrays.asList(
					productDao.getProductServicesHier(userSessionId, params)).get(0);
			if (count == productService.getMaxCount()){
				//throw new Exception();
				removeAddLabel();
			} else if (count > productService.getMaxCount()){
				StringBuffer str = new StringBuffer();
				ApplicationElement card = cardElements.get(node.getInnerId() - 1); 
				if ((card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV() != null) && 
					(card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV().length() != 0)){
					str.append(card.getShortDesc()).append(" - ")
						.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
							.getValue())
						.append(initialService.getServiceTypeName());
				} else{
					str.append(card.getShortDesc()).append(" - ")
					.append(card.getInnerId())
					.append(initialService.getServiceTypeName());
				}
				String key = str.toString();
				String message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "max_number_service");
				card.getChildByName("CARD_TYPE", 1).setValueV(null);
				cardToService.remove(key);
				throw new Exception(message);
			}
		}
		return result;
	}
	
	private void removeAddLabel(){
		if (leftMenu.get(leftMenu.size() - 1).
				getName().equalsIgnoreCase(ADD_CARD)){
			leftMenu.remove(leftMenu.size() - 1);
		}
	}
	
	private ArrayList<Filter>getServicesFilter(int serviceTypeId){
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		filters.add(f);
		f = new Filter("instId", instId);
		filters.add(f);
		f = new Filter("serviceTypeId", serviceTypeId);
		filters.add(f);
		return filters;
	}
	
	private ArrayList<Filter>getInitialServiceFilter(){
		int cardTypeId;
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(userLanguage);
		filters.add(f);
		f = new Filter("instId", instId);
		filters.add(f);
		f = new Filter("isInitial", true);
		filters.add(f);
		BigDecimal id = (BigDecimal)cardElements.get(node.getInnerId() - 1)
				.getChildByName("CARD_TYPE", 1).getValue();
		cardTypeId = id.intValue();

		f = new Filter("cardTypeId", cardTypeId);
		filters.add(f);
		return filters;
	}
	
	public void setSelectedService(String service){
		selectedService = service;
	}
	
	public String getSelectedService(){
		return selectedService;
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
				result = "/pages/common/application/person/accountCardDetails.jspx";
			} else if (AppElements.SERVICE_TYPE.equals(node.getName())){
				result = "/pages/common/application/person/serviceTypeDetails.jspx";
			} else if (AppElements.CARD.equals(node.getName())){
				//checkInitialService();
				result = "/pages/common/application/person/cardDetails.jspx";
			}
		}
		return result;
	}
	
	public void deleteCard(){
		if (checkMinLimit(contractElement)) return;
		revomeService();
		restructServices();
		removeElementFromApp(contractElement, AppElements.CARD);
		leftMenu.remove(node.getInnerId()-1);
		resetSelection(node);
		resetInnerId();
		creatMenu();
		prepareDetailsFields();
	}
	
	private void revomeService(){
		ApplicationElement card = contractElement.getChildrenByName(AppElements.CARD).get(node.getInnerId()-1);
		for (ServiceType serviceType: serviceTypes){
			StringBuffer str = new StringBuffer();
			if ((card.getChildByName(AppElements.CARD_NUMBER, 1)
					.getValueV() != null)&& (
				!card.getChildByName(AppElements.CARD_NUMBER, 1)
					.getValueV().equals(""))){
				str.append(card.getShortDesc()).append(" - ")
					.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV())
					.append(serviceType.getLabel());
			} else{
				str.append(card.getShortDesc()).append(" - ")
					.append(card.getInnerId())
					.append(serviceType.getLabel());
			}
			String key = str.toString();
			cardToService.remove(key);
		}
		
	}
	
	private void restructServices(){
		List <ApplicationElement>cards = contractElement.getChildrenByName(AppElements.CARD);
		for (int i = node.getInnerId()-1; i < cards.size() - 1; i++){
			for (ServiceType servType: serviceTypes){
				ApplicationElement oldCard = cards.get(i);
				ApplicationElement card = cards.get(i + 1);
				StringBuffer str = new StringBuffer();
				StringBuffer oldStr = new StringBuffer();
				if ((card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV() != null) && (
					!card.getChildByName(AppElements.CARD_NUMBER, 1)
						.getValueV().equals(""))){
					str.append(card.getShortDesc()).append(" - ")
						.append(card.getChildByName(AppElements.CARD_NUMBER, 1)
							.getValueV())
						.append(servType.getLabel());
					oldStr.append(oldCard.getShortDesc()).append(" - ")
						.append(oldCard.getChildByName(AppElements.CARD_NUMBER, 1)
							.getValueV())
						.append(servType.getLabel());
				} else{
					str.append(card.getShortDesc()).append(" - ")
						.append(card.getInnerId())
						.append(servType.getLabel());
					oldStr.append(oldCard.getShortDesc()).append(" - ")
						.append(oldCard.getInnerId())
						.append(servType.getLabel());
				}
				String key = str.toString();
				String oldKey = oldStr.toString();
				cardToService.remove(oldKey);
				if (cardToService.containsKey(key)){
					Service serv = cardToService.get(key);
					cardToService.put(oldKey, serv);
				}
			}
		}
	}

	
	private boolean checkMinLimit(ApplicationElement element){
		List <ApplicationElement> cards = element.getChildrenByName(AppElements.CARD);
		boolean result = (cards.size() > 1);
		if (!result){
			FacesUtils.addMessageError("Cannot delete an element. The minimum limit is reached.");
		}
		return !result;
	}
	
	public  List<SelectItem> getServicesRadio(){
		if (services != null){
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
	
	private void removeElementFromApp(ApplicationElement parent, String targetName){
		ApplicationElement elementToDelete = retrive(parent, targetName, node.getInnerId());
		delete(elementToDelete, parent);
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
	
	private void resetInnerId(){
		int count = 1;
		for(ApplicationElement card: contractElement.getChildrenByName(AppElements.CARD)){
			card.setInnerId(count++);
		}
	}
	
	public void addNewCard(){
		clearObjectAttr();
		MenuTreeItem cardGroup = new MenuTreeItem();
		ApplicationElement newCard = new ApplicationElement();
		try {
			newCard = addBl(AppElements.CARD, contractElement);
		} catch (UserException e) {
			e.printStackTrace();
		}
		if (newCard != null){	
			cardGroup = new MenuTreeItem(newCard.getShortDesc() + " - " 
					+ newCard.getInnerId().toString(), AppElements.CARD,
					newCard.getInnerId());
			if (serviceTypes != null){
				for (int b = 0; b < serviceTypes.size(); b++){
					MenuTreeItem serviceTypeItem = new MenuTreeItem
							( serviceTypes.get(b).getLabel(), AppElements.SERVICE_TYPE,
									b);
					cardGroup.getItems().add(serviceTypeItem);
				}
			}
			MenuTreeItem accountsItem = new MenuTreeItem(AppElements.ACCOUNT, AppElements.ACCOUNT, 1);
			cardGroup.getItems().add(accountsItem);
			leftMenu.add(cardGroup);
			leftMenu.remove(leftMenu.indexOf(newCarsGroup));
			leftMenu.add(newCarsGroup);
			node = cardGroup;
			TreePath accountPath = new TreePath(cardGroup, null);		
			nodePath = accountPath;
			cardElements = contractElement.getChildrenByName(AppElements.CARD);
			prepareDetailsFields();
		}
	}
	
	public  List<SelectItem> getBindAcc() {
		return bindAcc;
	}

	public void setBindAcc( List<SelectItem>  bindAcc) {
		this.bindAcc = bindAcc;
	}

	public  List<SelectItem>  getUnbindAcc() {
		return unbindAcc;
	}
	
	public void clearBind(){
		bind = null;
	}
	
	public void clearUnbind(){
		unbind = null;
	}

	public void setUnbindAcc( List<SelectItem>  unbindAcc) {
		this.unbindAcc = unbindAcc;
	}

	public String  getBind() {
		if (bind != null){
			return (bind);
		} else {
			return new String();
		}
	}

	public void setBind(String  bind) {
		this.bind = bind;
		if (bind != null){
			activeAcc = getAcc(bind);
			setUnbind(null);
		}
	}

	public String getUnbind() {
		if (unbind != null){
			return (unbind);
		}else{
			return new String();
		}
	}
	
	public void setUnbind(String  unbind) {
		this.unbind = unbind;
		if (unbind != null){
			activeAcc = getAcc(unbind);
			setBind(null);
		}
	}
	
	private Account getAcc(String accountNumber){
		for (int i = 0; i<accountsList.size(); i++){
			if(accountsList.get(i).getAccountNumber().equals(accountNumber)){
				return accountsList.get(i); 
			}
		}
		for (int i = 0; i<accountElements.size(); i++){
			
			String currenAccountNumber = accountElements.get(i).
					getChildByName(AppElements.ACCOUNT_NUMBER, 1).getValueV();
			if (currenAccountNumber.equals(accountNumber)){
				Account acc = new Account();
				acc.setAccountNumber(currenAccountNumber);
				acc.setAccountType(accountElements.get(i).
						getChildByName(AppElements.ACCOUNT_TYPE, 1).getValueV());
				acc.setCurrency(accountElements.get(i).
					getChildByName(AppElements.CURRENCY, 1).getValueV());
				return acc;
			}
		}
		return null;
	}
	

	public void doBind(){
			for(int j = 0; j < unbindAcc.size(); j++ ){
				if (unbindAcc.get(j).getValue().equals(bind)){
					bindAcc.add(unbindAcc.get(j));
					unbindAcc.remove(j);
				}
		}
		bind = new String();
	}
	
	public void doUnbind(){
			for(int j = 0; j < bindAcc.size(); j++ ){
				if (bindAcc.get(j).getValue().equals(unbind)){
					unbindAcc.add(bindAcc.get(j));
					bindAcc.remove(j);
				}
			}
		unbind = new String();
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
	
	public int getUnbindAccsize(){
		return unbindAcc.size();
	}
	
	public int getBindAccsize(){
		return bindAcc.size();
	}

	public boolean isPerson() {
		return person;
	}

	public void setPerson(boolean person) {
		this.person = person;
	}

	public Account getActiveAcc() {
		return activeAcc;
	}

	public void setActiveAcc(Account activeAcc) {
		this.activeAcc = activeAcc;
	}

	public boolean isAccountValid() {
		return accountValid;
	}

	public void setAccountValid(boolean accountValid) {
		this.accountValid = accountValid;
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
		return mainLock;
	}
	
	@Override
	public void clearFilter() {
		
	}

}

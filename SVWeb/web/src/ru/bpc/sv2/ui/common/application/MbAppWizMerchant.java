package ru.bpc.sv2.ui.common.application;

import org.ajax4jsf.model.KeepAlive;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.ProductAttribute;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.products.ServiceType;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbAppWizMerchant")
public class MbAppWizMerchant extends AbstractBean implements AppWizStep{
	private static final String SERVICE_TYPE = "SERVICE_TYPE";
	private static final String ADD_MERCHANT = "ADD_MERCHANT";
	
	private String page = "/pages/common/application/appWizMerchant.jspx";
	private Merchant activeMerchant;
	private Merchant currentNode;
	private Boolean search;
	private boolean serviceTypeValid;
	private ArrayList<Merchant> coreItems;
	private boolean mainLock = true;
	private List<MenuTreeItem> leftMenu = null;
	private ApplicationWizardContext appWizCtx;
	private Map<ApplicationElement, List<SelectItem>> merchantToAcc;	
	private boolean accountValid;
	private Account activeAcc;
	private ApplicationElement applicationRoot;
	private Map <ApplicationElement, List<ApplicationElement>> linkedMap;
	private DictUtils dictUtils;
	private List<ApplicationElement> accountElements;	
	private boolean lock;
	private Map<String,Service> merchantToService;
	private String language;
	private String userLanguage;
	private Long userSessionId;
	private int instId;
	private Map<Integer, ProductAttribute> attributesMap;
	private Boolean addressTypeLocked = true;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private ApplicationElement contractElement;
	private ApplicationElement customerElement;
	private Long productId;
	private List<ServiceType> serviceTypes;
	private List<ApplicationElement> merchantElements;
	private List<ApplicationElement> oldServices;
	private List<Service> services;
	private Map<String, ApplicationElement> fieldMap;
	private MenuTreeItem node;
	private TreePath nodePath;
	private TreePath nodePathMerch;
	private MenuTreeItem newMerchantsGroup;
	private String selectedService;
	private Map <String, List<SelectItem>>lovMap;
	private List<SelectItem>  bindAcc;
	private List<SelectItem>  unbindAcc;
	private String bind;
	private String unbind;
	private Map<ApplicationElement, List<SelectItem>> merchantToUnbindAcc;
	private List<Account> accountsList;
	private List <SelectItem> servicesRadio;
	private static final String DONT_CONNECT = "Don't connect";
	
	ProductsDao productDao = new ProductsDao();
	ApplicationDao applicationDao = new ApplicationDao();
	AccountsDao accountDao = new AccountsDao();
	AcquiringDao _acquireDao = new AcquiringDao();

	@Override
	public ApplicationWizardContext release() {
		clearObjectAttr();
		releaseMerchants();
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
	
	private void releaseMerchants(){
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
	
	private void releaseAccounts(){
		merchantElements = contractElement.getChildrenByName(AppElements.MERCHANT);
		List<SelectItem> listAccs = new ArrayList<SelectItem>();
		for (int i = 0; i < merchantElements.size(); i++){
			listAccs = merchantToAcc.get(merchantElements.get(i));
			if (listAccs != null){
				for (int j = 0; j < listAccs.size(); j++){
					Account acc = getAcc(listAccs.get(j).getLabel());
					ApplicationElement accEl = accExist(acc.getAccountNumber()); 
					if (accEl == null){
						try {
							createAcc(acc, merchantElements.get(i));				
						} catch (UserException e) {
							e.printStackTrace();
						}
					} else {
						
						try {
							ApplicationElement accountObj = new ApplicationElement();
							accountObj = addBl("ACCOUNT_OBJECT", accEl);
							fillAccountObjectBlock(accountObj, merchantElements.get(i), true);
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
					getChildByName("ACCOUNT_NUMBER", 1).getValueV();
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
			if (accEl.getChildren().get(i).getName().equalsIgnoreCase("ACCOUNT_NUMBER")){
				accEl.getChildren().get(i).setValueV(acc.getAccountNumber());
			} else if(accEl.getChildren().get(i).getName().equalsIgnoreCase("ACCOUNT_TYPE")){
				accEl.getChildren().get(i).setValueV(acc.getAccountType());
			}  else if(accEl.getChildren().get(i).getName().equalsIgnoreCase("CURRENCY")){
				accEl.getChildren().get(i).setValueV(acc.getCurrency());
			}
		}
		ApplicationElement accountObj = addBl("ACCOUNT_OBJECT", accEl);
		fillAccountObjectBlock(accountObj, card, true);
	}
	
	private void fillAccountObjectBlock(ApplicationElement accountObjectBlock,
			ApplicationElement linkBlock, boolean isChecked){
		long flag = isChecked ? 1 : 0;
		accountObjectBlock.getChildByName("ACCOUNT_LINK_FLAG", 1).setValueN(
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
	
	private void checkOldServices(){
		boolean found;
		if (oldServices == null){
			return;
		}
		for (ApplicationElement oldService: oldServices){
		found = false;
			for (String key: merchantToService.keySet()){
				Service serv = merchantToService.get(key);
				if (oldService.getValueN().compareTo(new BigDecimal(serv.getId())) == 0){
					found = true;
					merchantToService.remove(key);
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
		merchantElements = contractElement.getChildrenByName(AppElements.MERCHANT);
		//addInitialServiceTypes();
		for (ApplicationElement merchant: merchantElements){
			for (ServiceType servType: serviceTypes){
				StringBuffer str = new StringBuffer();
				if ((merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
						.getValue() != null) && 
					(merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
							.getValueV().length() != 0)){
					str.append(merchant.getShortDesc()).append(" - ")
						.append(merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
							.getValueV()).append(servType.getLabel());
				} else{
					str.append(merchant.getShortDesc()).append(" - ")
					.append(merchant.getInnerId()).append(servType.getLabel());
				}
				String key = str.toString();
				Service service = merchantToService.get(key);
				if(service != null){
					serviceToMerchant(service, merchant);
				}
			}
		}
	}
	
	private void serviceToMerchant(Service service, 
			ApplicationElement merchant) throws Exception{
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
		fillServiceObjectBlock(service, serviceObjectBlock, merchant);
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
		
		return filters;
	}

	@Override
	public void init(ApplicationWizardContext ctx) {
		setServiceTypeValid(true);
		search = false;
		setAccountValid(true);
		bind = new String("");
		unbind = new String("");
		appWizCtx = ctx;
		activeAcc = new Account();
		merchantToAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		merchantToUnbindAcc = new HashMap<ApplicationElement, List<SelectItem>>();
		this.applicationRoot = ctx.getApplicationRoot();
		linkedMap = ctx.getLinkedMap();
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		merchantToService = new HashMap<String, Service>();
		language = userLanguage = SessionWrapper.getField("language");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		ctx.setStepPage(page);
		instId = ((BigDecimal) applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).getValue()).intValue();
		applicationFilters = ctx.getApplicationFilters();
		customerElement = applicationRoot.retrive(AppElements.CUSTOMER);		
		contractElement =  customerElement.retrive(AppElements.CONTRACT);
		accountElements = contractElement.getChildrenByName(AppElements.ACCOUNT);
		productId = ((BigDecimal) contractElement.getChildByName(AppElements.PRODUCT_ID, 1).getValue()).longValue();
		getAccounts();
		fillServiceTypes();
		merchantElements = contractElement.getChildrenByName(AppElements.MERCHANT);
		if ( merchantElements.size() == 0){			 
			try {
				addBl(AppElements.MERCHANT, contractElement);
			} catch (UserException e) {
				}
		} else {
			makeListCreatedServices(merchantElements);
		}		
		createMenu();
		prepareDetailsFields();
	}
	
	private void createMenu(){
		MenuTreeItem merchantsGroup = new MenuTreeItem();
		leftMenu = new ArrayList<MenuTreeItem>();
		merchantElements = contractElement.getChildrenByName(AppElements.MERCHANT);
		for (int i = 0; i < merchantElements.size(); i++){
			StringBuffer nodeLabel = new StringBuffer();
			if ((merchantElements.get(i)
					.getChildByName(AppElements.MERCHANT_NUMBER, 1)
						.getValueV() != null) &&
						(!merchantElements.get(i).getChildByName(AppElements.MERCHANT_NUMBER, 1)
								.getValueV().equals(""))){
				nodeLabel.append(merchantElements.get(i).getShortDesc())
					.append(" - ")
					.append(merchantElements.get(i)
						.getChildByName(AppElements.MERCHANT_NUMBER, 1).getValueV());	
				
			} else {
				nodeLabel.append(merchantElements.get(i).getShortDesc())
				.append(" - ")
				.append(merchantElements.get(i).getInnerId());
			}
			merchantsGroup = new MenuTreeItem(nodeLabel.toString(),
											  AppElements.MERCHANT, 
											  merchantElements.get(i).getInnerId());
			if (serviceTypes != null){
				for (int b = 0; b < serviceTypes.size(); b++){
					MenuTreeItem serviceTypeItem = new MenuTreeItem
							( serviceTypes.get(b).getLabel(),SERVICE_TYPE, 
									b);
					merchantsGroup.getItems().add(serviceTypeItem);
				}
			}
			MenuTreeItem accountsItem = new MenuTreeItem(AppElements.ACCOUNT, AppElements.ACCOUNT, 1); 
			MenuTreeItem addressesItem = new MenuTreeItem(AppElements.ADDRESS, AppElements.ADDRESS, 1);
			merchantsGroup.getItems().add(accountsItem);
			merchantsGroup.getItems().add(addressesItem);
			leftMenu.add(merchantsGroup);
		}
		node = merchantsGroup;
		TreePath merchantPath = new TreePath(merchantsGroup, null);		
		nodePath = merchantPath;
		newMerchantsGroup = new MenuTreeItem("Add new merchant", ADD_MERCHANT);
		leftMenu.add(newMerchantsGroup);
	}
	
	public void prepareDetailsFields(){
		if (node != null) {
			prepareFieldMap();
			prepareLovMap();
		}
	}
	
	public Map<String, ApplicationElement> getFieldMap(){
		return fieldMap;
	}
	
	private void getAccounts(){
		//TODO change request for accounts 
		ArrayList<Filter> filter = new ArrayList<Filter>();
		Filter f = new Filter();
		
		f = new Filter("productId", productId);			
		filter.add(f);
		
		f = new Filter("lang",language);
		filter.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filter.toArray(new Filter[filter.size()]));
		int count = accountDao.getAcqAccountsCount(userSessionId, params);
		if (count > 0){
			accountsList = Arrays.asList(accountDao.getAcqAccounts(userSessionId, params));
			
		} else {
			accountsList = new ArrayList<Account>();
		}
	}
	
	private void prepareFieldMap(){
		fieldMap = new HashMap<String, ApplicationElement>();
		if (AppElements.MERCHANT.equalsIgnoreCase(node.getName())){			
			ApplicationElement merchants = merchantElements.get(node.getInnerId() - 1);
			for (int i = 0; i < merchants.getChildren().size(); i++){
				ApplicationElement merchant = merchants.getChildren().get(i);
				//if ((acc.getInfo() != null) && (acc.getInfo())){
				if((merchant.getName().equalsIgnoreCase(AppElements.MERCHANT_NUMBER))||
						(merchant.getName().equalsIgnoreCase(AppElements.MERCHANT_TYPE))){
					fieldMap.put(merchant.getName(), merchant);
				}
			}
		} else if (AppElements.SERVICE_TYPE.equalsIgnoreCase(node.getName())){
			ArrayList<Filter>filters = getServiceFilter(
					serviceTypes.get(node.getInnerId()).getId()); 
			services = getServices(filters);
			String key = ((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel() 
					+ node.getLabel();
			if (!merchantToService.containsKey(key)){
				selectedService = null;
				clearObjectAttr();
			}else{
				Service selected = merchantToService.get(key);
				if (selected == null){
					selectedService = "-1";
				}else{
					selectedService = String.valueOf(selected.getId());
					isInishial(selected);
				}
				if (!selectedService.equalsIgnoreCase("-1") ){
					prepareAttr(getService());
				}else{
					clearObjectAttr();
				}
			}
		} else if (AppElements.ADDRESS.equalsIgnoreCase(node.getName())){
			fildAddress();
		} else if (AppElements.ACCOUNT.equalsIgnoreCase(node.getName())){
			bindAcc = new ArrayList<SelectItem>();
			unbindAcc = new ArrayList<SelectItem>();
			fillAccsList();
		}
	}
	
	private void fildAddress(){
		int id = ((MenuTreeItem)nodePath.getParentPath().getValue()).innerId - 1;
		ApplicationElement merchant = merchantElements.get(id);
		List<ApplicationElement>  addresses = merchant.getChildrenByName(AppElements.ADDRESS);
		if ((addresses == null) ||
				addresses.size() == 0){
			try {
				ApplicationElement newAddress = 
						addBl(AppElements.ADDRESS, merchant);
				newAddress.
					getChildByName(AppElements.ADDRESS_TYPE, 1).
						setValueV("ADTPBSNA");
				addresses.add(newAddress);
			} catch (UserException e) {
			}
		}
		for (ApplicationElement address:addresses){
			for (ApplicationElement childrenEl: address.getChildren()){
				if ((!childrenEl.isComplex()) && 
						(!childrenEl.getName().equalsIgnoreCase(AppElements.COMMAND))){
					fieldMap.put(childrenEl.getName(), childrenEl);
				} else if(childrenEl.getName().equalsIgnoreCase(AppElements.ADDRESS_NAME)){
					prepareAddressName(childrenEl);
				}
			}
		}
	}
	
	private void prepareAddressName(ApplicationElement addressName){
		if (addressName.getInnerId() > 0){
		List<ApplicationElement> childrens = addressName.getChildren();
			for (ApplicationElement ch: childrens){
				fieldMap.put(ch.getName(), ch);
			}
		}
	}
	
	private void fillAccsList(){
		boolean removed = false;
		List<Account> newAcc = new ArrayList<Account>();
		int id;
		id = ((MenuTreeItem)nodePath.getParentPath().getValue()).getInnerId() -1; 
		
		ApplicationElement currentMerchant = merchantElements.get(id);
		bindAcc = merchantToAcc.get(currentMerchant);
		unbindAcc = merchantToUnbindAcc.get(currentMerchant);
		if ((bindAcc != null) && 
				(unbindAcc != null)){
			return;
		}
		bindAcc = new ArrayList<SelectItem>();
		unbindAcc = new ArrayList<SelectItem>();
		newAcc.addAll(accountsList);
		for(int i = 0; i< accountElements.size(); i++){
			List<ApplicationElement> object = accountElements.get(i).
					getChildrenByName(AppElements.ACCOUNT_OBJECT);
			for(int j = 0; j<object.size(); j++){
				BigDecimal dataId = new BigDecimal(currentMerchant.getDataId());
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
		merchantToAcc.put(currentMerchant, bindAcc);
		merchantToUnbindAcc.put(currentMerchant, unbindAcc);
		
	}
	
	private void removeAcc(List<Account>listAcc, ApplicationElement account){
		for (int i = 0; i < listAcc.size(); i++){
			if (listAcc.get(i).getAccountNumber().equalsIgnoreCase(
					account.getChildByName("ACCOUNT_NUMBER", 1).getValueText())){
				bindAcc.add(new SelectItem(listAcc.get(i).getAccountNumber(),
						listAcc.get(i).getAccountNumber()));
				listAcc.remove(i);
				return;
			}
		}
	}
	
	public String getDetailsPage(){
		String result = SystemConstants.EMPTY_PAGE; 
		if (node != null){
			if (AppElements.MERCHANT.equals(node.getName())){
				prepareParent();
				result = "/pages/common/application/person/merchantDetails.jspx";
			} else if (AppElements.SERVICE_TYPE.equals(node.getName())){
				result = "/pages/common/application/person/serviceTypeDetails.jspx";
			}else if (AppElements.ACCOUNT.equals(node.getName())){
				result = "/pages/common/application/person/accountCardDetails.jspx";
			}else if (AppElements.ADDRESS.equals(node.getName())){
				result = "/pages/common/application/person/addressDetails.jspx";
			}
		}
		return result;
	}
	
	private void prepareParent(){
		ApplicationElement parent = merchantElements.
				get(node.getInnerId() - 1).getChildByName(AppElements.MERCHANT, 1);
		if (parent == null){
			try {
				parent = addBl(AppElements.MERCHANT, merchantElements.
					get(node.getInnerId() - 1));
			} catch (UserException e) {
			}
		}
		fieldMap.put("PARENT_NUMBER", parent.getChildByName(AppElements.MERCHANT_NUMBER, 1));
		fieldMap.put("PARENT_TYPE", parent.getChildByName(AppElements.MERCHANT_TYPE, 1));
	}
	
	public void doUnbind(){
		for(int j = 0; j < bindAcc.size(); j++ ){
			if (bindAcc.get(j).getValue().equals(unbind)){
				unbindAcc.add(bindAcc.get(j));
				bindAcc.remove(j);
				break;
			}
		}
		unbind = new String("");
	}
	
	public void doBind(){
		for(int j = 0; j < unbindAcc.size(); j++ ){
			if (unbindAcc.get(j).getValue().equals(bind)){
				bindAcc.add(unbindAcc.get(j));
				unbindAcc.remove(j);
				break;
			}
		}
		bind = new String("");
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
	
	@SuppressWarnings("deprecation")
	private void prepareAttr(Service service){
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();
		attrs.setServiceId(service.getId());
		attrs.setEntityType(EntityNames.SERVICE);
		attrs.setInstId(instId);
		attrs.setProductType(service.getProductType());
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
	
	@SuppressWarnings("deprecation")
	private void clearObjectAttr(){
		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();
	}
	
	private void prepareLovMap(){
		lovMap = new HashMap<String, List<SelectItem>>();
		for (ApplicationElement element: fieldMap.values()){
			if(element.getLovId() != null){
				if (AppElements.MERCHANT_TYPE.equalsIgnoreCase(element.getName())){
					Map <String, Object> paramMap = new HashMap<String, Object>();
					paramMap.put(AppElements.INSTITUTION_ID, instId);
					lovMap.put(element.getName(), 
							dictUtils.getLov(element.getLovId(), paramMap));
				}else{
					lovMap.put(element.getName(), 
							dictUtils.getLov(element.getLovId()));
				}	
			}
		}
	}
	
	public Map<String, List<SelectItem>> getLovMap(){
		return lovMap;
	}
	
	public void updateAddressLabel(){
	}
	
	public void switchAddressName(){
	}
	
	public void deleteAddress(){
	}
	
	public void updateMerchantLabel(){
		String number = fieldMap.get("MERCHANT_NUMBER").getValueV();
		if (number != null){
			ApplicationElement merchant = merchantElements.get(node.getInnerId() -1 );
			StringBuffer label = new StringBuffer();
			for (ServiceType serv:serviceTypes){
				label = new StringBuffer();
				label.append(node.getLabel())
					.append(serv.getLabel());
				String key = label.toString();
				if (merchantToService.containsKey(key)){
					Service service = merchantToService.get(key);
					merchantToService.remove(key);
					label = new StringBuffer();
					label.append(merchant.getShortDesc())
						.append(" - ")
						.append(number)
						.append(serv.getLabel());
					key = label.toString();
					merchantToService.put(key, service);
				}
			}
			
			label = new StringBuffer();
			label.append(merchant.getShortDesc())
				.append(" - ")
				.append(number);
			node.setLabel(label.toString());
			
		}
	}
	
	public void addNewCard(){
		clearObjectAttr();
		MenuTreeItem merchantGroup = new MenuTreeItem();
		ApplicationElement newMerchant = new ApplicationElement();
		try {
			newMerchant = addBl(AppElements.MERCHANT, contractElement);
		} catch (UserException e) {
			e.printStackTrace();
		}
		if (newMerchant != null){	
			merchantGroup = new MenuTreeItem(newMerchant.getShortDesc() + " - " 
					+ newMerchant.getInnerId().toString(), AppElements.MERCHANT,
					newMerchant.getInnerId());
			if (serviceTypes != null){
				for (int b = 0; b < serviceTypes.size(); b++){
					MenuTreeItem serviceTypeItem = new MenuTreeItem
							( serviceTypes.get(b).getLabel(),SERVICE_TYPE, 
									b);
					merchantGroup.getItems().add(serviceTypeItem);
				}
			}
			MenuTreeItem accountsItem = new MenuTreeItem(AppElements.ACCOUNT, AppElements.ACCOUNT, 1);
			MenuTreeItem addressesItem = new MenuTreeItem(AppElements.ADDRESS, AppElements.ADDRESS, 1);
			merchantGroup.getItems().add(accountsItem);
			merchantGroup.getItems().add(addressesItem);
			leftMenu.add(merchantGroup);
			leftMenu.remove(leftMenu.indexOf(newMerchantsGroup));
			leftMenu.add(newMerchantsGroup);
			node = merchantGroup;
			TreePath accountPath = new TreePath(merchantGroup, null);		
			nodePath = accountPath;
			merchantElements = contractElement.getChildrenByName(AppElements.MERCHANT);
			prepareDetailsFields();
		}
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
	
	public void deleteMerchant(){
		if (checkMinLimit(contractElement)) return;
		revomeService();
		restructServices();
		removeElementFromApp(contractElement, AppElements.MERCHANT);
		leftMenu.remove(node.getInnerId()-1);
		resetSelection(node);
		resetInnerId();
		createMenu();
		prepareDetailsFields();
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
		for(ApplicationElement merchant: contractElement.getChildrenByName(AppElements.MERCHANT)){
			merchant.setInnerId(count++);
		}
	}
	
	public void activeElement(){
		activeMerchant = getNodeMerch();
		fillParentMerchant(activeMerchant);
		search = false;
		currentNode = null;
		coreItems = null;
	}
	
	private void fillParentMerchant(Merchant parent){
		ApplicationElement merchant = 
				merchantElements.get(node.getInnerId() -1);
		ApplicationElement parentElem = merchant.getChildByName(AppElements.MERCHANT, 1);
		if (parentElem == null){
			try {
				parentElem = addBl(AppElements.MERCHANT, merchant);
			} catch (UserException e) {
				e.printStackTrace();
			}
		}
		parentElem.getChildByName(AppElements.MERCHANT_NUMBER, 1)
			.setValueV(parent.getMerchantNumber());
		parentElem.getChildByName(AppElements.MERCHANT_TYPE, 1)
			.setValueV(parent.getMerchantType());
		parentElem.getChildByName(AppElements.MCC, 1)
			.setValueV(parent.getMcc());
		parentElem.getChildByName(AppElements.MERCHANT_STATUS, 1)
			.setValueV(parent.getStatus());
		parentElem.getChildByName(AppElements.MERCHANT_NAME, 1)
			.setValueV(parent.getMerchantName());
		parentElem.getChildByName(AppElements.MERCHANT_LABEL, 1)
			.setValueV(parent.getLabel());

	}
	
	private void revomeService(){
		ApplicationElement merchant = contractElement.getChildrenByName(AppElements.MERCHANT).get(node.getInnerId()-1);
		for (ServiceType serviceType: serviceTypes){
			StringBuffer str = new StringBuffer();
			if ((merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
					.getValueV() != null) &&
				(!merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
					.getValueV().equals(""))){
				str.append(merchant.getShortDesc()).append(" - ")
					.append(merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
						.getValueV())
					.append(serviceType.getLabel());
			} else{
				str.append(merchant.getShortDesc()).append(" - ")
					.append(merchant.getInnerId())
					.append(serviceType.getLabel());
			}
			String key = str.toString();
			merchantToService.remove(key);
		}
		
	}
	
	private void removeElementFromApp(ApplicationElement parent, String targetName){
		ApplicationElement elementToDelete = retrive(parent, targetName, node.getInnerId());
		delete(elementToDelete, parent);
	}
	
	
	private void restructServices(){
		List <ApplicationElement>merchants = contractElement.getChildrenByName(AppElements.MERCHANT);
		for (int i = node.getInnerId()-1; i < merchants.size() - 1; i++){
			for (ServiceType servType: serviceTypes){
				ApplicationElement oldMerchant = merchants.get(i);
				ApplicationElement merchant = merchants.get(i + 1);
				StringBuffer str = new StringBuffer();
				StringBuffer oldStr = new StringBuffer();
				if ((merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
						.getValueV() != null) &&
					(!merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
						.getValueV().equals(""))){
					str.append(merchant.getShortDesc()).append(" - ")
						.append(merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
							.getValueV())
						.append(servType.getLabel());
					oldStr.append(oldMerchant.getShortDesc()).append(" - ")
						.append(oldMerchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
							.getValueV())
						.append(servType.getLabel());
				} else{
					str.append(merchant.getShortDesc()).append(" - ")
						.append(merchant.getInnerId())
						.append(servType.getLabel());
					oldStr.append(oldMerchant.getShortDesc()).append(" - ")
						.append(oldMerchant.getInnerId())
						.append(servType.getLabel());
				}
				String key = str.toString();
				String oldKey = oldStr.toString();
				merchantToService.remove(oldKey);
				if (merchantToService.containsKey(key)){
					Service serv = merchantToService.get(key);
					merchantToService.put(oldKey, serv);
				}
			}
		}
	}

	
	private boolean checkMinLimit(ApplicationElement element){
		List <ApplicationElement> merchant = element.getChildrenByName(AppElements.MERCHANT);
		boolean result = (merchant.size() > 1);
		if (!result){
			FacesUtils.addMessageError("Cannot delete an element. The minimum limit is reached.");
		}
		return !result;
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
		applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result,
				applicationFilters);
		return result;
	}
	
	private ArrayList<Filter> setFilters(){
		ArrayList<Filter> result = new ArrayList<Filter>(3);
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
		f = new Filter("entityType", "ENTTMRCH");
		result.add(f);
		return result;
	}
	
	private void makeListCreatedServices(List<ApplicationElement> merchants){
		oldServices = new ArrayList<ApplicationElement>();
		List<ApplicationElement> serviceElements =  
				contractElement.getChildrenByName(AppElements.SERVICE);
		if (serviceElements.size() > 0){
			for (ApplicationElement serviceEl: serviceElements){
				for (ServiceType type:serviceTypes){
					ArrayList<Filter> filters = getServiceFilter(type.getId());
					services = getServices(filters);
					for (Service service:services){
						if (serviceEl.getValueN().compareTo
								(new BigDecimal(service.getId()))==0){
							ApplicationElement merchant = 
								isServiceConnectToMerchant(serviceEl, merchants);
							if (merchant != null){
								StringBuffer str = new StringBuffer();
								if (merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
										.getValueV() != null){
									str.append(merchant.getShortDesc()).append(" - ")
										.append(merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
											.getValueV()).append(type.getLabel());
								} else{
									str.append(merchant.getShortDesc()).append(" - ")
									.append(merchant.getInnerId()).append(type.getLabel());
								}
								String key = str.toString();
								merchantToService.put(key, service);
								oldServices.add(serviceEl);
								break;
							}else {
								merchant = isServiceConnectToMerchantNew(serviceEl, merchants);
								if (merchant != null){
									StringBuffer str = new StringBuffer();
									if (merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
											.getValueV() != null){
										str.append(merchant.getShortDesc()).append(" - ")
											.append(merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
												.getValueV()).append(type.getLabel());
									} else{
										str.append(merchant.getShortDesc()).append(" - ")
										.append(merchant.getInnerId()).append(type.getLabel());
									}
									String key = str.toString();
									merchantToService.put(key, service);
									break;	
								}
							}
						}
					}
				}
			}
		}
	}
	
	private List<Service> getServices(ArrayList<Filter> filters){
		SelectionParams params = new SelectionParams();
		params.setRowIndexStart(0);		
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		return Arrays.asList(productDao.getServicesByMerchantProduct(userSessionId, params));
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
	
	private ApplicationElement isServiceConnectToMerchantNew(ApplicationElement serviceEl, 
			List<ApplicationElement> merchants){
		for	(ApplicationElement serviceObj:serviceEl.getChildrenByName(AppElements.SERVICE_OBJECT)){
			for(ApplicationElement merchant: merchants){
				if (serviceObj.getValueN().compareTo(
						new BigDecimal(merchant.hashCode()))==0){
					return merchant;
				}
			}
		}
		return null;
	}
	
	private ApplicationElement isServiceConnectToMerchant(ApplicationElement merchantEl, 
			List<ApplicationElement>merchants){
		for	(ApplicationElement serviceObj:merchantEl.getChildrenByName(AppElements.SERVICE_OBJECT)){
			for(ApplicationElement merchant: merchants){
				if (serviceObj.getValueN().compareTo(
						new BigDecimal(merchant.getDataId()))==0){
					return merchant;
				}
			}
		}
		return null;
	}
	
	public List<MenuTreeItem> getNodeChildren(){
		MenuTreeItem treeNode = treeNode();
		if (treeNode == null){
			return leftMenu;
		} else {
			return treeNode.getItems();
		}
	}
	
	public String getLanguage(){
		return language;
	}
	
	public void setLanguage(String language){
		this.language = language;
	}
	
	public boolean getNodeHasChildren(){
		MenuTreeItem treeNode = treeNode();
		return !treeNode.getItems().isEmpty();
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

	@Override
	public boolean validate() {
		boolean valid = true;
		valid = validateMerchant();
		return valid;
	}
	
	private boolean validateMerchant(){
		boolean mainValid = true;
		boolean valid;
		boolean validTree;
		
		List <ApplicationElement> merchants = 
				contractElement.getChildrenByName(AppElements.MERCHANT);
		for (ApplicationElement merchant: merchants){
			validTree = true;
			for (int i = 0; i < merchant.getChildren().size(); i++){
				valid = true;
				ApplicationElement merchantCh = merchant.getChildren().get(i);
				//if ((accCh.getInfo() != null) 
					//	&& (acc.getInfo())
					//	&& (acc.isRequired())){
					if(((merchantCh.getName().equalsIgnoreCase(AppElements.MERCHANT_NUMBER)||
							merchantCh.getName().equalsIgnoreCase("MERCHANT_TYPE")) && 
								(merchantCh.isRequired()))){
						 valid &= merchantCh.validate();
						 mainValid &= valid;
						 merchantCh.setValid(valid);
						 validTree &= valid;
					}
					
			}
			leftMenu.get(merchant.getInnerId()-1).setValid(validTree);
			mainValid &= checkService(merchant);
			mainValid &= checkAccount(merchant);
			mainValid &= checkAddresses(merchant);
		}
		
		return mainValid;
	}
	
	private boolean checkService(ApplicationElement merchant){
		boolean mainValid = true;
		for (int i = 0; i < serviceTypes.size(); i++){
			boolean valid;
			StringBuffer str = new StringBuffer();
			if ((merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
					.getValueV() != null) && 
				(!merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
					.getValueV().equals(""))){
				str.append(merchant.getShortDesc()).append(" - ")
					.append(merchant.getChildByName(AppElements.MERCHANT_NUMBER, 1)
						.getValueV())
					.append(serviceTypes.get(i).getLabel());
			} else{
				str.append(merchant.getShortDesc()).append(" - ")
				.append(merchant.getInnerId())
				.append(serviceTypes.get(i).getLabel());
			}
			String key = str.toString();
			valid = merchantToService.containsKey(key);
			mainValid &= valid;
			leftMenu.get(merchant.getInnerId()-1).getItems().get(i).setValid(valid);
		}
		return mainValid;
	}
	
	private boolean checkAddresses(ApplicationElement merchant){
		boolean mainValid = true;
		ApplicationElement address = merchant.getChildByName(AppElements.ADDRESS, 1);
		if (address == null){
			try {
				address = addBl(AppElements.ADDRESS, merchant);
				address.
					getChildByName(AppElements.ADDRESS_TYPE, 1).
					setValueV("ADTPBSNA");
				mainValid = false;
			} catch (UserException e) {
			}
		}
		for (ApplicationElement addressEl: address.getChildren()){
			if(address.getName().endsWith(AppElements.ADDRESS_NAME)){
				mainValid &= checkAddressName(addressEl);
			}else if (addressEl.isRequired()){
				boolean valid;
				valid = addressEl.validate();
				addressEl.setValid(valid);
				mainValid &= valid;
			}
				
		}
		leftMenu.get(merchant.getInnerId()-1).getItems().
			get(serviceTypes.size() + 1).setValid(mainValid);
		return mainValid;
	}
	
	private boolean checkAddressName(ApplicationElement address){
		boolean mainValid = true;
		for(ApplicationElement addressName: address.getChildrenByName(AppElements.ADDRESS_NAME)){
			boolean valid;
			if (addressName.isRequired()){
				valid = addressName.validate();
				addressName.setValid(valid);
				mainValid &= valid;
			}
		}
		
		return mainValid;
	}
	
	private boolean checkAccount(ApplicationElement merchant){
		boolean mainValid = true;
		List<SelectItem> accs = merchantToAcc.get(merchant);
		if (accs == null || accs.size() == 0){
			mainValid = false;
		}
		leftMenu.get(merchant.getInnerId()-1).getItems().
			get(serviceTypes.size()).setValid(mainValid);
		setAccountValid(mainValid);
		return mainValid;
	}

	@Override
	public boolean checkKeyModifications() {
		return false;
	}

	public String getPage() {
		return page;
	}

	public void setPage(String page) {
		this.page = page;
	}

	public boolean isServiceTypeValid() {
		return serviceTypeValid;
	}

	public void setServiceTypeValid(boolean serviceTypeValid) {
		this.serviceTypeValid = serviceTypeValid;
	}
	
	public Boolean getAddressTypeLocked() {
		return addressTypeLocked;
	}

	public void setAddressTypeLocked(Boolean addressTypeLocked) {
		this.addressTypeLocked = addressTypeLocked;
	}

	public boolean isAccountValid() {
		return accountValid;
	}

	public void setAccountValid(boolean accountValid) {
		this.accountValid = accountValid;
	}

	public List<SelectItem> getBindAcc() {
		return bindAcc;
	}

	public void setBindAcc(List<SelectItem> bindAcc) {
		this.bindAcc = bindAcc;
	}

	public List<SelectItem> getUnbindAcc() {
		return unbindAcc;
	}

	public void setUnbindAcc(List<SelectItem> unbindAcc) {
		this.unbindAcc = unbindAcc;
	}
	
	public void clearBind(){
		bind = null;
	}
	
	public void clearUnbind(){
		unbind = null;
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
					getChildByName("ACCOUNT_NUMBER", 1).getValueV();
			if (currenAccountNumber.equals(accountNumber)){
				Account acc = new Account();
				acc.setAccountNumber(currenAccountNumber);
				acc.setAccountType(accountElements.get(i).
						getChildByName("ACCOUNT_TYPE", 1).getValueV());
				acc.setCurrency(accountElements.get(i).
					getChildByName("CURRENCY", 1).getValueV());
				return acc;
			}
		}
		return null;
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
	
	public void updateAttr(){
		clearObjectAttr();
		String key = ((MenuTreeItem)nodePath.getParentPath().getValue()).getLabel() 
				+ node.getLabel();
		    	if (merchantToService.containsKey(key)){
		    		merchantToService.remove(key);
		    	}
		if ((selectedService != null) &&
				(Integer.parseInt(selectedService) > 0)){
			merchantToService.put(key, getService(selectedService));
			prepareAttr(getService());
		}else {
			merchantToService.put(key, null);
		}
	}
	
	private Service getService(String id){
		for (Service service:services){
			if (service.getId().toString().equalsIgnoreCase(id)) 
				return service;
		}
		return null;
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

	public Account getActiveAcc() {
		return activeAcc;
	}

	public void setActiveAcc(Account activeAcc) {
		this.activeAcc = activeAcc;
	}
	
	public int getUnbindAccsize(){
		return unbindAcc.size();
	}
	
	public int getBindAccsize(){
		return bindAcc.size();
	}
	
	private int addNodes(int startIndex, ArrayList<Merchant> branches, Merchant[] merchants) {
		// int counter = 1;
		int i;
		int level = merchants[startIndex].getLevel();

		for (i = startIndex; i < merchants.length; i++) {
			if (merchants[i].getLevel() != level) {
				break;
			}
			branches.add(merchants[i]);
			if ((i + 1) != merchants.length && merchants[i + 1].getLevel() > level) {
				merchants[i].setChildren(new ArrayList<Merchant>());
				i = addNodes(i + 1, merchants[i].getChildren(), merchants);
			}
			// counter++;
		}
		return i - 1;
	}
	
	protected int addNodes(int startIndex, List<Merchant> branches, Merchant[] items) {
//      int counter = 1;
		int i;
		int level = items[startIndex].getLevel();

		for (i = startIndex; i < items.length; i++) {
			if (items[i].getLevel() != level) {
				break;
			}
			branches.add(items[i]);
			if ((i + 1) != items.length && items[i + 1].getLevel() > level) {
				items[i].setChildren(new ArrayList<Merchant>());
				i = addNodes(i + 1, items[i].getChildren(), items);
			}
//          counter++;
		}
		return i - 1;
	}
	
	public List<Merchant> getNodeChildrenMerch() {
		Merchant merchant = getMerchant();
		if (merchant == null) {
			if (coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return merchant.getChildren();
		}
	}
	
	public boolean getNodeHasChildrenMerch() {
		Merchant message = getMerchant();
		return message.isHasChildren();
	}
	
	private Merchant getMerchant() {
		return (Merchant) Faces.var("merchant");
	}
	
	public void searchMerchant(){
		nodePathMerch = null;
		currentNode = null;
		search = true;
		loadTree();
	}
	
	public void loadTree() {
		if (search){
		Merchant[] merchants = null;
		coreItems = new ArrayList<Merchant>();
		try {
			List<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("inst_id", instId));
			filters.add(new Filter("lang", language));
			SelectionParams params = new SelectionParams();
			params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
			if (_acquireDao == null) {
				_acquireDao = new AcquiringDao();
			}
			
			int count = 0;
			int threshold = 300;
			params.setThreshold(threshold);
			merchants = _acquireDao.getMerchants(userSessionId, params);
			

			if (merchants != null && merchants.length > 0) {
				count = addNodes(0, coreItems, merchants);
				Merchant[] addedMas = massOfNewMerch();
				if (addedMas != null){
					addNodes(0, coreItems, addedMas);
				}	
				if (nodePathMerch == null) {
					if (currentNode == null) {
						currentNode = coreItems.get(0);
						setNodePathMerch(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePathMerch(formNodePath(merchants));
						} else {
							setNodePathMerch(new TreePath(currentNode, null));
						}
					}
				}
			}
			if (count >= threshold) {
				FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "many_records"));
			}
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
		} finally {
			if (merchants == null)
				merchants = new Merchant[0];
		}
		}
	}
	
	private Merchant[] massOfNewMerch(){
		int i = merchantElements.size() - 1;
		List<ApplicationElement>toMas = merchantToMss();
		if (i > 0){
			Merchant [] mas = new Merchant [i];
			for (int b = 0; b < i; b++){
				Merchant newMerch = new Merchant();
				newMerch.setMerchantNumber(toMas.get(b).
						getChildByName(AppElements.MERCHANT_NUMBER, 1).
						getValueV());
				newMerch.setId(0L);
				mas[b] = newMerch;
			}
			return mas;
		}
		return null;
	}
	
	private List<ApplicationElement> merchantToMss(){
		List <ApplicationElement> toMas = new ArrayList<ApplicationElement>();
		for (ApplicationElement el: merchantElements){
			if (node.getInnerId() != el.getInnerId()){
				toMas.add(el);
			}
		}
		return toMas;
	}
	
	protected TreePath formNodePath(Merchant[] items) {
		ArrayList<Merchant> pathElements = new ArrayList<Merchant>();
		pathElements.add(currentNode);
		Merchant node = currentNode;
		while (node.getParentId() != null) {
			boolean found = false;
			for (Merchant item: items) {
				if (item.getId().equals(node.getParentId())) {
					pathElements.add(item);
					node = item;
					found = true;
					break;
				}
			}
			if (!found) break;	// to evade infinite loops if sor some reason parent is absent 
		}

		Collections.reverse(pathElements); // make current node last and its very first parent - first

		TreePath nodePath = null;
		for (Merchant item: pathElements) {
			nodePath = new TreePath(item, nodePath);
		}

		return nodePath;
	}
	


	public TreePath getNodePathMerch() {
		return nodePathMerch;
	}

	public void setNodePathMerch(TreePath nodePathMerch) {
		this.nodePathMerch = nodePathMerch;
	}
	
	public Merchant getNodeMerch() {
		if (currentNode == null) {
			currentNode = new Merchant();
		}
		return currentNode;
	}

	public void setNodeMerch(Merchant node) {
		if (node == null)
			return;
		this.currentNode = node;
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
		// TODO Auto-generated method stub
		
	}

}

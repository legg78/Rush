package ru.bpc.sv2.ui.common.application;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.*;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAppWizardNewCustomerContract")
public class MbAppWizardNewCustomerContract extends AbstractBean implements AppWizStep, Serializable {
	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	
	private ApplicationDao daoApplication = new ApplicationDao();
	
	private String page = "/pages/common/application/appWizNewCustomerContract.jspx";
	private String customerType;
	private String contractType;
	private Integer product;
	private Long template;
	private Integer instId;
	private Integer flowId;
	private ApplicationElement applicationRoot;
	private DictUtils dictUtils;
	private List<SelectItem> customerTypes;
	private List<SelectItem> contractTypes;
	private List<SelectItem> products;
	private List<SelectItem> templates;
	private Boolean acqApp;
	private String applicationType;
	private long userSessionId;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private ApplicationWizardContext appWizCtx;
	private boolean lock = true;
	private String customerNumber;
	private boolean customerValid;
	private Integer agentId;
	private Customer customer;
	private boolean addCards = false;
	private boolean addAccounts = false;
	private boolean showCustomer;
	private ArrayList<SelectItem> list;
	private Date startDate;
	
	private boolean firstOpen;
	private boolean keyFieldsMofified;

	private boolean valid;
	private boolean contractTypeValid;
	private boolean customerTypeValid;
	private boolean startDateValid;
	
	public MbAppWizardNewCustomerContract(){
		logger.trace("MbAppWizardNewCustomerContract::constructor()...");
	}
	
	@Override
	public ApplicationWizardContext release() {
		logger.trace("MbAppWizardNewCustomerContract::release()...");
		if (!showCustomer){
			retrive(applicationRoot, AppElements.CUSTOMER_TYPE).setValueV(customerType);
		}else{
			applicationRoot.retrive(AppElements.CUSTOMER_TYPE).set(customer.getEntityType());
		}
		
		Integer instId = retrive(applicationRoot, AppElements.INSTITUTION_ID).getValueN().intValue();
		Application appStub = new Application();
		appStub.setInstId(instId);
		
		ApplicationElement customerEl = tryRetrive(applicationRoot, AppElements.CUSTOMER);
		if (keyFieldsMofified || customerEl == null){
			if (customerEl != null){
				silentDelete(customerEl, applicationRoot);
			}
			customerEl = instance(applicationRoot, AppElements.CUSTOMER);
			daoApplication.fillTopChildren(userSessionId, instId, customerEl, applicationFilters);
			if (appWizCtx.isOldCustomer()){
				retrive(customerEl, AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
			}else{
				retrive(customerEl, AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
			}

			daoApplication.applyDependencesWhenAdd(userSessionId, appStub, customerEl, applicationFilters);
			if (showCustomer){
				customerEl.retrive(AppElements.CUSTOMER_NUMBER).set(customer.getCustomerNumber());
			}
			// Create and fill contract
			ApplicationElement contract = tryRetrive(customerEl, AppElements.CONTRACT);
			if (contract != null){
				silentDelete(contract, applicationRoot);
			}
			contract = instance(customerEl, AppElements.CONTRACT);
			daoApplication.fillRootChilds(userSessionId, instId, contract, applicationFilters);
			retrive(contract, AppElements.COMMAND).setValueV(ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
			retrive(contract, AppElements.CONTRACT_TYPE).setValueV(contractType);
			retrive(contract, AppElements.START_DATE).setValueD(startDate);
				
			daoApplication.applyDependencesWhenAdd(userSessionId, appStub, contract, applicationFilters);
			
			// Template obtaining and merging
			if (template != null){
				Application application = new Application();
				application.setId(template);
				ApplicationElement appTemplate = daoApplication.getApplicationForEdit(userSessionId, application);
				merge(applicationRoot, appTemplate);
			}
			appWizCtx.setApplicationTemplateId(template);
			// merge clears PRODUCT_ID value, so we set PRODUCT_ID after merge operation
			retrive(contract, AppElements.PRODUCT_ID).setValueN(product);
		}
		
		appWizCtx.setApplicationRoot(applicationRoot);
		if (isNewCustomer()){ 
			configSteps();
		}
		return appWizCtx;
	}
	
	private void configSteps(){
		ArrayList<AppFlowStep>steps = new ArrayList<AppFlowStep>(appWizCtx.getSteps());
		if (addAccounts){
			boolean found = false;
			for(int i = 1; i < steps.size(); i++){
				if ("MbAppWizAccount".equalsIgnoreCase(steps.get(i)
						.getStepSource())){
					found = true;
				}
			}
			if (!found){
				addElem("MbAppWizAccount", steps);
			}
		}else{
			for(int i = 1; i < steps.size(); i++){
				if ("MbAppWizAccount".equalsIgnoreCase(steps.get(i)
						.getStepSource())){
					steps.remove(i);
				}
			}
			removeAccounts();
		}
		if (addCards){
			boolean found = false;
			for(int i = 1; i < steps.size(); i++){
				if ("MbAppWizCard".equalsIgnoreCase(steps.get(i)
						.getStepSource())){
					found = true;
				}
			}
			if (!found){
				addElem("MbAppWizCard", steps);
			}
		}else{
			for(int i = 1; i < steps.size(); i++){
				if ("MbAppWizCard".equalsIgnoreCase(steps.get(i)
						.getStepSource())){
					steps.remove(i);
				}
			}
			removeCards();
		}
		appWizCtx.setSteps(steps);
	}
	
	private void removeCards(){
		ApplicationElement customer = applicationRoot.getChildByName(AppElements.CUSTOMER, 1);
		if (customer != null){
			ApplicationElement contract = customer.getChildByName(AppElements.CONTRACT, 1); 
			if (contract != null){
				for(int i = 0; i < contract.getChildrenByName("CARD").size(); i++){
					ApplicationElement card = contract.getChildByName("CARD", i + 1);
					removeBlock(card);
				}
			}
		}
	}
	
	public void initCustomerModal(){
		logger.trace("MbAppWizOldCustomerContract::initCustomerModal()...");
		MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
		custBean.clearFilter();
		custBean.setBeanName(MbAppWizardNewCustomerContract.class.getSimpleName());
		custBean.setRerenderList("stepPageInclude:appWizNewCustomerContract");
		custBean.setBlockInstId(true);
		custBean.setDefaultInstId(instId);
		custBean.setBlockAgentId(true);
		custBean.setDefaultAgentId(agentId);
	}
	
	public void selectCustomer(){
		logger.trace("MbAppWizOldCustomerContract::selectCustomer()...");		
		MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
		Customer oldCustomer = customer;
		customer = custBean.getActiveCustomer();
		if (customer != null){
			applicationRoot.retrive(AppElements.CUSTOMER_TYPE).set(customer.getEntityType());
			customerType = customer.getEntityType();
			prepareContractTypes();
			keyFieldsMofified = 
					customer != null &&
					customer.getCustomerNumber() != null &&
					((oldCustomer != null && 
						customer.getCustomerNumber().equals(oldCustomer.getCustomerNumber())) ||
							oldCustomer == null);
		}
	}
	
	public void clearCustomerNumber(){
		customer = null;
	}
	
	private void removeAccounts(){
		ApplicationElement customer = applicationRoot.getChildByName(AppElements.CUSTOMER, 1);
		if (customer != null){
			ApplicationElement contract = customer.getChildByName(AppElements.CONTRACT, 1); 
			if (contract != null){
				for(int i = 0; i < contract.getChildrenByName("ACCOUNT").size(); i++){
					ApplicationElement acc = contract.getChildByName("ACCOUNT", i + 1);
					removeBlock(acc);
				}
			}
		}
	}
	
	private void removeBlock(ApplicationElement block){
		ApplicationElement templateNode = block.getContentBlock();
		ApplicationElement blockToDel = block;
		templateNode.setCopyCount(templateNode.getCopyCount() - 1);
		for (ApplicationElement elem : blockToDel.getChildren()) {
			deleteBlockRecursion(elem);
		}
		blockToDel.getChildren().clear();
		blockToDel.setInnerId(blockToDel.getInnerId() * (-1));
		blockToDel.setVisible(false);
	}
	
	private void deleteBlockRecursion(ApplicationElement block) {
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
	
	private void addElem(String source, ArrayList<AppFlowStep> steps){
		ArrayList<Filter>filters = new ArrayList<Filter>();
		filters.add(new Filter("stepSource", source));
		filters.add(new Filter("flowId", flowId));
		filters.add(new Filter("lang", userLang));
		SelectionParams params = new SelectionParams(filters);
		AppFlowStep[] stepArr = daoApplication
				.getAppFlowSteps(userSessionId, params);
		if (stepArr.length > 0){
			steps.add(stepArr[0]);
		}
	}
	
	private void merge(ApplicationElement app, ApplicationElement template){
		logger.trace("MbAppWizardNewCustomerContract::merge()...");
		List<ApplicationElement> apps = app.getChildren();
		List<ApplicationElement> templates = template.getChildren();
		for (ApplicationElement t : templates){
			logger.trace("Searching element \'" + t.getName() +"\' for merging...");
			ApplicationElement nodeToMerge = null;
			for (ApplicationElement a : apps){
				if (a.equals(t)){
					nodeToMerge = a;
					break;
				}
			}
			if (nodeToMerge == null){
				logger.trace("Element \'" + t.getName() +"\' has not been found. Instantiation of a new element...");
				nodeToMerge = instance(app, t.getName());
				daoApplication.fillRootChilds(userSessionId, instId, nodeToMerge, applicationFilters);
			}
			if (nodeToMerge != null){
				t.setDataId(null);
				shallowApply(t, nodeToMerge);
				if (nodeToMerge.isComplex()){
					merge(nodeToMerge, t);
				}
				logger.trace("Element \'" + t.getName() +"\' has been successfully merged.");
			}
		}
	}
	
	@Override
	public void init(ApplicationWizardContext ctx) {
		logger.trace("MbAppWizardewCustomerContract::init()...");
		valid = true;
		customerTypeValid = true;
		contractTypeValid = true;
		startDateValid = true;
		firstOpen = true;
		keyFieldsMofified = false;
		customerValid = true;
		customerType = null;
		contractType = null;
		startDate = null;
		product = null;
		template = null;
		showCustomer = ctx.isOldCustomer();
		customerTypes = null;
		contractTypes = null;
		products = null;
		templates = null;
		applicationType = null;
		appWizCtx = ctx;
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		this.applicationRoot = ctx.getApplicationRoot();
		instId = applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().intValue();
		flowId = applicationRoot.getChildByName(AppElements.APPLICATION_FLOW_ID, 1).getValueN().intValue();
		applicationType = applicationRoot.getChildByName(AppElements.APPLICATION_TYPE, 1).getValueV();
		agentId = applicationRoot.retrive(AppElements.AGENT_ID).getValueN().intValue();
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		applicationFilters = ctx.getApplicationFilters();
		ctx.setStepPage(page);
		
		ApplicationElement customerTypeEl = tryRetrive(applicationRoot, AppElements.CUSTOMER_TYPE);
		if (customerTypeEl != null && customerTypeEl.getValueV() != null){
			firstOpen = false;
			customerType = customerTypeEl.getValueV();
			prepareCustomerTypes();
		}
		ApplicationElement contractTypeEl = tryRetrive(applicationRoot, AppElements.CUSTOMER, AppElements.CONTRACT, AppElements.CONTRACT_TYPE);
		if (contractTypeEl != null){
			firstOpen = false;
			contractType = contractTypeEl.getValueV();
			prepareContractTypes();
		}
		ApplicationElement productEl = tryRetrive(applicationRoot, AppElements.CUSTOMER, AppElements.CONTRACT, AppElements.PRODUCT_ID);
		if (productEl != null){
			firstOpen = false;
			product = productEl.getValueN().intValue();
			prepareProducts();
		}
		template = ctx.getApplicationTemplateId();
		if (template != null){
			firstOpen = false;
			prepareTemplates();
		}
	}
	
	public List<SelectItem> getCustomerTypes(){
		logger.trace("MbAppWizardNewCustomerContract getCustomerTypes()...");
		if (customerTypes == null) {
			prepareCustomerTypes();
		}
		return customerTypes;
	}
	
	private void prepareCustomerTypes(){
		logger.trace("MbAppWizardNewCustomerContract::prepareCustomerTypes()...");
		customerTypes = dictUtils.getLov(LovConstants.CUSTOMER_TYPES);
		if (customerTypes == null){
			customerTypes = new ArrayList<SelectItem>();
		}
	}
	
	public void onCustomerTypeChanged(){
		prepareContractTypes();
	}
	
	public List<SelectItem> getContractTypes(){
		logger.trace("MbAppWizardNewCustomerContract getContractTypes()...");
		if (contractTypes == null) {
			prepareContractTypes();
		}
		return contractTypes;
	}
	
	private void prepareContractTypes(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("AppElements.CUSTOMER_ENTITY_TYPE", getCustomerType());
		if (ApplicationConstants.TYPE_ACQUIRING.equalsIgnoreCase(applicationType)) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (ApplicationConstants.TYPE_ISSUING.equalsIgnoreCase(applicationType)) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		} 
		contractTypes = dictUtils.getLov(LovConstants.CONTRACT_TYPES, paramMap);
		if (contractTypes == null){
			contractTypes = new ArrayList<SelectItem>();
		} else {
			prepareProducts();
		}
	}
	
	public void onContractTypeChanged(){
		prepareProducts();
	}
	
	public List<SelectItem> getProducts(){
		logger.trace("MbAppWizardNewCustomerContract getProducts()...");
		if (products == null) {
			prepareProducts();
		}
		return products;
	}
	
	private void prepareProducts(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("AppElements.INSTITUTION_ID", instId);
		paramMap.put("STATUS", ProductConstants.STATUS_ACTIVE_PRODUCT);
		paramMap.put("AppElements.CONTRACT_TYPE", contractType);
		if (ApplicationConstants.TYPE_ACQUIRING.equals(applicationType)) {
			products = dictUtils.getLov(LovConstants.ACQUIRING_PRODUCTS, paramMap);
		} else if (ApplicationConstants.TYPE_ISSUING.equals(applicationType)) {
			products = dictUtils.getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
		}
		if (products == null){
			products = new ArrayList<SelectItem>();
		}
	}
	
	public void onProductChanged(){
		prepareTemplates();
	}
	
	public List<SelectItem> getTemplates(){
		logger.trace("MbAppWizardNewCustomerContract getTemplates()...");
		if (templates == null) {
			prepareTemplates();
		}
		return templates;		
	}
	
	private void prepareTemplates(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("FLOW_ID", flowId);
		if (applicationType == ApplicationConstants.TYPE_ACQUIRING) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (applicationType == ApplicationConstants.TYPE_ISSUING) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		}		
		templates = dictUtils.getLov(LovConstants.APP_WIZ_FLOW);
		if (templates == null){
			templates = new ArrayList<SelectItem>();
		}		
	}

	public String getCustomerType() {
		return customerType;
	}

	public void setCustomerType(String customerType) {
		if (customerType != null && !customerType.equals(this.customerType)
				&& this.customerType != null){
			keyFieldsMofified = true;
		}
		this.customerType = customerType;
	}

	public String getContractType() {
		return contractType;
	}

	public void setContractType(String contractType) {
		if (contractType != null && !contractType.equals(this.contractType)
				&& this.contractType != null){
			keyFieldsMofified = true;
		}
		this.contractType = contractType;
	}

	public Long getTemplate() {
		return template;
	}

	public void setTemplate(Long template) {
		if (template != null && !template.equals(this.template)
				&& this.template != null){
			keyFieldsMofified = true;
		}
		this.template = template;
	}

	public Integer getProduct() {
		return product;
	}

	public void setProduct(Integer product) {
		if (product != null && !product.equals(this.product) 
				&& this.product != null){
			keyFieldsMofified = true;
		}		
		this.product = product;
	}

	@Override
	public boolean validate() {
		valid = product != null;
		if (isShowCustomer()){
			customerValid = customer != null;
			valid &= customerValid; 
		}else{
			customerTypeValid = customerType != null;
		}
		contractTypeValid = contractType != null;
		valid &= contractTypeValid;
		startDateValid = startDate != null;
		valid &= startDateValid;
		return valid;
	}
	
	@Override
	public boolean checkKeyModifications() {
		return !firstOpen && keyFieldsMofified;
	}
	
	public boolean isValid(){
		return valid;
	}

	public Boolean getAcqApp() {
		acqApp = ApplicationConstants.TYPE_ACQUIRING.
				equalsIgnoreCase(appWizCtx.getApplicationType());
		return acqApp;
	}

	public void setAcqApp(Boolean acqApp) {
		this.acqApp = acqApp;
	}

	@Override
	public boolean getLock() {
		return lock;
	}
	
		@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

	public boolean isAddCards() {
		return addCards;
	}

	public void setAddCards(boolean addCards) {
		this.addCards = addCards;
	}

	public boolean isAddAccounts() {
		return addAccounts;
	}

	public void setAddAccounts(boolean addAccounts) {
		this.addAccounts = addAccounts;
	}

	public ArrayList<SelectItem> getList() {
		if (list == null){
			list = new ArrayList<SelectItem>();
			list.add(new SelectItem(true, FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"yes")));
			list.add(new SelectItem(false, FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"no")));
		}
		return list;
	}	

	public void setList(ArrayList<SelectItem> list) {
		this.list = list;
	}
	
	public boolean isNewCustomer(){
		return flowId.equals(1001);
	}

	public boolean isShowCustomer() {
		return showCustomer;
	}

	public String getCustomerNumber() {
		if (customer != null){
			String result = null;
			if (customer.getCustomerName() != null && !customer.getCustomerName().isEmpty()){
				result = String.format("%s - %s", customer.getCustomerNumber(), customer.getCustomerName());
			} else {
				result = customer.getCustomerNumber();
			}
			return result;
		} else {
			return null;
		}
	}

	public void setCustomerNumber(String customerNumber) {
		this.customerNumber = customerNumber;
	}
	
	public boolean isCustomerValid(){
		return customerValid;
	}

	public boolean isContractTypeValid() {
		return contractTypeValid;
	}

	public void setContractTypeValid(boolean contractTypeValid) {
		this.contractTypeValid = contractTypeValid;
	}

	public boolean isCustomerTypeValid() {
		return customerTypeValid;
	}

	public void setCustomerTypeValid(boolean customerTypeValid) {
		this.customerTypeValid = customerTypeValid;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public boolean isStartDateValid() {
		return startDateValid;
	}

	public void setStartDateValid(boolean startDateValid) {
		this.startDateValid = startDateValid;
	}
}

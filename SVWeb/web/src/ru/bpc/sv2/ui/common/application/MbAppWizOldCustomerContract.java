package ru.bpc.sv2.ui.common.application;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAppWizOldCustomerContract")
public class MbAppWizOldCustomerContract extends AbstractBean implements AppWizStep, Serializable {

	private ApplicationDao applicationDao = new ApplicationDao();
	private ProductsDao productsDao = new ProductsDao();
	
	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	private static final String PAGE = "/pages/common/application/appWizOldCustomerContract.jspx";
	
	private ApplicationWizardContext context;
	private ApplicationElement applicationRoot;
	private Customer customer;
	private String applicationType;
	private Contract contract;
	private Integer instId;
	private Integer agentId;
	private boolean keyFieldsMofified;
	private long userSessionId;
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private boolean firstOpen;
	private int flowId;
	private List<SelectItem> templates;
	private ArrayList<SelectItem> customerTypes;
	private DictUtils dictUtils;
	private Long template;
	private String userLanguage;
	private boolean contractValid;
	private boolean customerValid;
	private boolean oldCustomer;
	private boolean lock = true;
	private String customerType;
	
	public MbAppWizOldCustomerContract(){
		logger.trace("MbAppWizOldCustomerContract::constructor()...");
	}
	
	@Override
	public ApplicationWizardContext release() {
		logger.trace("MbAppWizOldCustomerContract::release()...");
		
		Integer instId = applicationRoot.retrive(AppElements.INSTITUTION_ID).getValueN().intValue();
		Application appStub = new Application();
		appStub.setInstId(instId);
		
		if (keyFieldsMofified){
			
			ApplicationElement customerEl = applicationRoot.tryRetrive(AppElements.CUSTOMER);
			if (customerEl != null){
				silentDelete(customerEl, applicationRoot);
			}
			customerEl = instance(applicationRoot, AppElements.CUSTOMER);
			applicationDao.fillTopChildren(userSessionId, instId, customerEl, applicationFilters);
			if (context.isOldContract()){
				customerEl.retrive(AppElements.COMMAND).set(ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
			}else {
				customerEl.retrive(AppElements.COMMAND).set(ApplicationConstants.COMMAND_EXCEPT_OR_PROCEED);
			}
			applicationDao.applyFilters(userSessionId, customerEl, applicationFilters, instId);

			if (isOldCustomer() && ApplicationConstants.TYPE_ISSUING.equals(applicationType)){
				ApplicationElement person = tryRetrive(customerEl, AppElements.PERSON);
				if (person != null){
					silentDelete(person, applicationRoot);
				}
				person = instance(customerEl, AppElements.PERSON);
				applicationDao.fillRootChilds(userSessionId, instId, person, applicationFilters);
				person.retrive(AppElements.COMMAND).set(ApplicationConstants.COMMAND_IGNORE);
				applicationRoot.retrive(AppElements.CUSTOMER_TYPE).set(customer.getEntityType());
				customerEl.retrive(AppElements.CUSTOMER_NUMBER).set(customer.getCustomerNumber());
			}else{
				applicationRoot.retrive(AppElements.CUSTOMER_TYPE).set(customerType);
			}
			
			
			
			ApplicationElement contractEl = tryRetrive(customerEl, AppElements.CONTRACT);
			if (contractEl != null){
				silentDelete(contractEl, applicationRoot);
			}
			
			contractEl = instance(customerEl, AppElements.CONTRACT);
			applicationDao.fillRootChilds(userSessionId, instId, contractEl, applicationFilters);
			contractEl.retrive(AppElements.COMMAND).set(ApplicationConstants.COMMAND_CREATE_OR_UPDATE);
			contractEl.retrive(AppElements.CONTRACT_TYPE).set(contract.getContractType());
			contractEl.retrive(AppElements.CONTRACT_NUMBER).set(contract.getContractNumber());
			contractEl.retrive(AppElements.PRODUCT_ID).set(contract.getProductId());
			contractEl.retrive(AppElements.START_DATE).set(contract.getStartDate());
			applicationDao.applyDependencesWhenAdd(userSessionId, appStub, contractEl, applicationFilters);
			
			if (template != null){
				Application application = new Application();
				application.setId(template);
				ApplicationElement appTemplate = applicationDao.getApplicationForEdit(userSessionId, application);
				merge(applicationRoot, appTemplate);
			}
			context.setApplicationTemplateId(template);			
		}
		context.setApplicationRoot(applicationRoot);
		return context;
	}

	private void merge(ApplicationElement app, ApplicationElement template){
		logger.trace("MbAppWizOldCustomerContract::merge()...");
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
				applicationDao.fillRootChilds(userSessionId, instId, nodeToMerge, applicationFilters);
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
	
	private void init(){
		logger.trace("MbAppWizOldCustomerContract::init()...");
		customer = null;
		contract = null;
		instId = null;
		firstOpen = true;
		keyFieldsMofified = false;
		contractValid = true;
		customerValid = true;
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		userLanguage = SessionWrapper.getField("language");
	}
	
	@Override
	public void init(ApplicationWizardContext ctx) {
		logger.trace("MbAppWizOldCustomerContract::init(ApplicationWizardContext)...");
		init();
		context = ctx;
		applicationRoot = ctx.getApplicationRoot();
		applicationType = ctx.getApplicationType();
		applicationFilters = ctx.getApplicationFilters();
		instId = applicationRoot.retrive(AppElements.INSTITUTION_ID).getValueN().intValue();
		agentId = applicationRoot.retrive(AppElements.AGENT_ID).getValueN().intValue();
		flowId = applicationRoot.retrive(AppElements.APPLICATION_FLOW_ID).getValueN().intValue();
		oldCustomer = context.isOldCustomer();
		
		ApplicationElement customerEl = applicationRoot.tryRetrive(AppElements.CUSTOMER);
		if (customerEl != null){
			firstOpen = false;
			if (isOldCustomer()){
				String customerNumber = customerEl.retrive(AppElements.CUSTOMER_NUMBER).getValueV();
				Customer[] customers = getCustomers(customerNumber);
				if (customers.length != 0){
					customer = customers[0];
				}
			}
			
			ApplicationElement contractEl = customerEl.tryRetrive(AppElements.CONTRACT);
			if (contractEl != null){
				String contractNumber = contractEl.retrive(AppElements.CONTRACT_NUMBER).getValueV();
				SelectionParams sp = SelectionParams.build("CONTRACT_NUMBER", contractNumber, "LANG", userLanguage);
				Map<String, Object> paramsMap = new HashMap<String, Object>();
				paramsMap.put("param_tab", sp.getFilters());
				paramsMap.put("tab_name", "CONTRACT");
				Contract[] contracts = productsDao.getContractsCur(userSessionId, sp, paramsMap);
				if (contracts.length != 0){
					contract = contracts[0];
				}
			}
		}
		
		template = ctx.getApplicationTemplateId();
		
		ctx.setStepPage(PAGE);
	}

	@Override
	public boolean validate() {
		logger.trace("MbAppWizOldCustomerContract::validate()...");
		if (isOldCustomer()){
			customerValid = customer != null;
		}else{
			customerValid = customerType != null;
		}
		contractValid = contract != null;
		return contractValid && customerValid;
	}

	@Override
	public boolean checkKeyModifications() {
		logger.trace("MbAppWizOldCustomerContract::checkKeyModifications()...");
		boolean result = !firstOpen && keyFieldsMofified;
		logger.debug("Result of checkKeyModifications(): " + result);
		return result;
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

	public String getContractNumber(){
		if (contract != null){
			String result = null;
			if (contract.getProductName() != null && !contract.getProductName().isEmpty()){
				result = String.format("%s - %s", contract.getContractNumber(), contract.getProductName());
			} else {
				result = contract.getContractNumber();
			}
			return result;
		} else {
			return null;
		}		
	}
	
	public void initCustomerModal(){
		logger.trace("MbAppWizOldCustomerContract::initCustomerModal()...");
		MbCustomerSearchModal custBean = ManagedBeanWrapper.getManagedBean(MbCustomerSearchModal.class);
		custBean.clearFilter();
		custBean.setBeanName(MbAppWizOldCustomerContract.class.getSimpleName());
		custBean.setMethodName("selectCustomer");
		custBean.setRerenderList("stepPageInclude:appWizOldCustomerContract:customerNumber, stepPageInclude:appWizOldCustomerContract:contractNumber");
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
		contract = null;
		keyFieldsMofified = 
				customer != null &&
				customer.getCustomerNumber() != null &&
				((oldCustomer != null && 
					customer.getCustomerNumber().equals(oldCustomer.getCustomerNumber())) ||
						oldCustomer == null);
	}
	
	public void initContractModal(){
		logger.trace("MbAppWizOldCustomerContract::selectContract()...");
		MbContractsModalPanel contractBean = ManagedBeanWrapper.getManagedBean(MbContractsModalPanel.class);
		contractBean.clearFilter();
		contractBean.setApplicationType(applicationType);
		contractBean.getFilterContract().setInstId(instId);
		if (customer != null){
			contractBean.getFilterContract().setCustomerType(customer.getEntityType());
			contractBean.getFilterContract().setCustomerNumber(customer.getCustomerNumber());
			contractBean.setBlockCustomerNumber(true);
			contractBean.searchContracts();
		}
	}
	
	public void selectContract(){
		logger.trace("MbAppWizOldCustomerContract::selectContract()...");
		MbContractsModalPanel contractBean = ManagedBeanWrapper.getManagedBean(MbContractsModalPanel.class);
		Contract oldContract = contract;
		contract = contractBean.getActiveContract();
		keyFieldsMofified = 
				contract != null &&
				contract.getContractNumber() != null &&
				((oldContract != null && 
					contract.getContractNumber().equals(oldContract.getContractNumber())) ||
						oldContract == null);
		if (customer == null && isOldCustomer()){
			Customer [] customers =  getCustomers(contract.getCustomerNumber());
			if (customers.length > 0){
				customer = customers[0];
			}
		}
	}
	
	public void clearCustomerNumber(){
		customer = null;
	}
	
	public void clearContractNumber(){
		contract = null;
	}
	
	public List<SelectItem> getTemplates(){
		logger.trace("MbAppWizOldCustomerContract::getTemplates()...");
		if (templates == null) {
			prepareTemplates();
		}
		return templates;		
	}
	
	private Customer[] getCustomers(String customerNumber){
		ArrayList <Filter>filters = new ArrayList<Filter>();
		filters.add(new Filter(AppElements.LANG, userLanguage));
		filters.add(new Filter(AppElements.CUSTOMER_NUMBER, customerNumber));
		filters.add(new Filter(AppElements.INST_ID, instId));
		filters.add(new Filter(AppElements.AGENT_ID, agentId));
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		params.setRowIndexStart(0);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		Customer [] customers = productsDao.getCombinedCustomersProc(userSessionId, params,
				"CUSTOMER");
		return customers;
	}
	
	private void prepareTemplates(){
		logger.trace("MbAppWizOldCustomerContract::prepareTemplates()...");
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put(AppElements.FLOW_ID, flowId);
		if (applicationType == ApplicationConstants.TYPE_ACQUIRING) {
			paramMap.put(AppElements.PRODUCT_TYPE, ProductConstants.ACQUIRING_PRODUCT);
		} else if (applicationType == ApplicationConstants.TYPE_ISSUING) {
			paramMap.put(AppElements.PRODUCT_TYPE, ProductConstants.ISSUING_PRODUCT);
		}		
		templates = dictUtils.getLov(LovConstants.APP_WIZ_FLOW);
		if (templates == null){
			templates = new ArrayList<SelectItem>();
		}		
	}

	public Long getTemplate() {
		return template;
	}

	public void setTemplate(Long template) {
		if (this.template != null && !this.template.equals(template)){
			keyFieldsMofified = true;
		}
		this.template = template;
	}
	
	public boolean isCustomerValid(){
		return customerValid;
	}
	
	public boolean isContractValid(){
		return contractValid;
	}

	@Override
	public boolean getLock() {
		return lock;
	}
	
	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

	public boolean isOldCustomer() {
		return oldCustomer;
	}

	public String getCustomerType() {
		return customerType;
	}

	public void setCustomerType(String customerType) {
		this.customerType = customerType;
	}

	public ArrayList<SelectItem> getCustomerTypes() {
		if (customerTypes == null){
			customerTypes = (ArrayList<SelectItem>)
					dictUtils.getLov(LovConstants.CUSTOMER_TYPES);
		}
		return customerTypes;
	}

	public Customer getCustomer(){
		return customer;
	}

	public void setCustomerTypes(ArrayList<SelectItem> customerTypes) {
		this.customerTypes = customerTypes;
	}
}

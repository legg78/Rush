package ru.bpc.sv2.ui.common.application;

import static ru.bpc.sv2.utils.AppStructureUtils.instance;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAppWizCardPool")
public class MbAppWizCardPool extends AbstractBean implements AppWizStep, Serializable {
	private static final String AGENT = "ENTTAGNT";
	private static final String CONTR_TYPE = "CNTPINIC";

	private DictUtils dictUtils;
	private Long userSessionId;
	private ApplicationWizardContext appWizCtx;
	private ApplicationElement applicationRoot;
	private String page ="/pages/common/application/appWizCardPool.jspx";
	private Map<Integer, ApplicationFlowFilter> applicationFilters;
	private ApplicationElement customer;
	private ApplicationElement company;
	private ApplicationElement contract;
	private ApplicationElement card;
	private int instId;
	private Map <String, ApplicationElement> fieldMap;
	private Map<String, List<SelectItem>> lovMap;
	private String applicationType;
	private List<SelectItem> products;
	private boolean lock = true;

	ApplicationDao applicationDao = new ApplicationDao();

	@Override
	public ApplicationWizardContext release() {
		applicationRoot.getChildByName(AppElements.CUSTOMER_TYPE, 1).setValueV(AGENT);
		contract.getChildByName(AppElements.CONTRACT_TYPE, 1).setValueV(CONTR_TYPE);
		ApplicationElement cardHolder = card.tryRetrive(AppElements.CARDHOLDER);
		if (cardHolder == null){
			try {
				cardHolder = addBl(AppElements.CARDHOLDER, card);
			} catch (UserException e) {
			}
		}
		
		ApplicationElement cardHolderPerson = cardHolder.tryRetrive(AppElements.PERSON);
		if (cardHolderPerson == null){
			try {
				cardHolderPerson = addBl(AppElements.PERSON, cardHolder);
			} catch (UserException e) {
			}
		}
		prepareProducts();
		int product;
		if (products.size() == 1){
			product = Integer.parseInt((String) products.get(0).getValue());
		} else {
			throw new IllegalArgumentException("Illegal number of products");
		}
		contract.retrive(AppElements.PRODUCT_ID).setValueN(product);
		appWizCtx.setApplicationRoot(applicationRoot);
		
		return appWizCtx;
	}
	
	private void prepareProducts(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put(AppElements.INSTITUTION_ID, instId);
		paramMap.put(AppElements.STATUS, ProductConstants.STATUS_ACTIVE_PRODUCT);
		paramMap.put(AppElements.CONTRACT_TYPE, CONTR_TYPE);
		if (ApplicationConstants.TYPE_ACQUIRING.equals(applicationType)) {
			products = dictUtils.getLov(LovConstants.ACQUIRING_PRODUCTS, paramMap);
		} else if (ApplicationConstants.TYPE_ISSUING.equals(applicationType)) {
			products = dictUtils.getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
		}
		if (products == null){
			products = new ArrayList<SelectItem>();
		}
	}

	@Override
	public void init(ApplicationWizardContext ctx) {
		dictUtils = ManagedBeanWrapper.getManagedBean(DictUtils.class);
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		appWizCtx = ctx;
		this.applicationRoot = ctx.getApplicationRoot();
		ctx.setStepPage(page);
		applicationFilters = ctx.getApplicationFilters();
		customer = applicationRoot.tryRetrive(AppElements.CUSTOMER);
		instId = applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().intValue();
		applicationType = applicationRoot.getChildByName(AppElements.APPLICATION_TYPE, 1).getValueV();
		if (customer == null){
			try {
				customer = addBl(AppElements.CUSTOMER, applicationRoot);
			} catch (UserException e) {
			}
		}
		company = customer.tryRetrive(AppElements.COMPANY);
		if (company == null){
			try {
				company = addBl(AppElements.COMPANY, customer);
			} catch (UserException e) {
			}
		}
		contract = customer.tryRetrive(AppElements.CONTRACT);
		if (contract == null){
			try {
				contract = addBl(AppElements.CONTRACT, customer);
			} catch (UserException e) {
			}
		}
		
		card = contract.tryRetrive(AppElements.CARD);
		if (card == null){
			try {
				card = addBl(AppElements.CARD, contract);
			} catch (UserException e) {
			}
		}
		prepareFieldMap();
		prepareLovMap();
		
	}
	
	private void prepareFieldMap(){
		fieldMap = new HashMap<String, ApplicationElement>();
		ApplicationElement cardType = card.getChildByName(AppElements.CARD_TYPE, 1);
		fieldMap.put(AppElements.CARD_TYPE, cardType);
		ApplicationElement embossedName = company.getChildByName(AppElements.EMBOSSED_NAME, 1);
		fieldMap.put(AppElements.EMBOSSED_NAME, embossedName);
		ApplicationElement cardCount = card.getChildByName(AppElements.CARD_COUNT, 1);
		fieldMap.put(AppElements.CARD_COUNT, cardCount);
	}
	
	private void prepareLovMap(){
		lovMap = new HashMap<String, List<SelectItem>>();
		for (ApplicationElement element: fieldMap.values()){
			if(element.getLovId() != null){
				lovMap.put(element.getName(), 
						dictUtils.getLov(element.getLovId()));
			}
		}
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

	@Override
	public boolean validate() {
		boolean valid = true;
		for (ApplicationElement el: fieldMap.values()){
			valid &= el.validate(); 
		}
		return valid;
	}

	@Override
	public boolean checkKeyModifications() {
		// TODO Auto-generated method stub
		return false;
	}

	public Map <String, ApplicationElement> getFieldMap() {
		return fieldMap;
	}

	public void setFieldMap(Map <String, ApplicationElement> fieldMap) {
		this.fieldMap = fieldMap;
	}

	public Map<String, List<SelectItem>> getLovMap() {
		return lovMap;
	}

	public void setLovMap(Map<String, List<SelectItem>> lovMap) {
		this.lovMap = lovMap;
	}

	@Override
	public boolean getLock() {
		return lock;
	}
	
		@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}


}

package ru.bpc.sv2.ui.products.details;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbCustomerDetails")
public class MbCustomerDetails implements Serializable {
	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private ProductsDao productsDao = new ProductsDao();
	
	private Long id;
	private String language;
	private Long userSessionId;
	private DictUtils dictUtils;
	
	private Customer customer;
	private List<SelectItem> languages;
	
	public MbCustomerDetails(){
		setLanguage(SessionWrapper.getField("language"));
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}
	
	public void initializeModalPanel(){
		logger.debug("MbCustomerDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils
					.getSessionMapValue(CTX_MENU_PARAMS);
			FacesUtils.setSessionMapValue(CTX_MENU_PARAMS, null);
			if (ctxMenuParams.containsKey(OBJECT_ID)){
				id = (Long) ctxMenuParams.get(OBJECT_ID);
			} 
		} else {
			if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
				id = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
			}	
		}
		if (id == null){
//			objectIdIsNotSet();
		}
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Customer getCustomer(){
		if (id == null) 
			initializeModalPanel();
		if ((customer == null) && (id != null)){
			Filter[] filters = new Filter[] { new Filter("id", id), new Filter("lang", language) };
			List<Customer> customers = productsDao.getCustomers(userSessionId, new SelectionParams(filters), language);
			if (customers != null && !customers.isEmpty()) {
				customer = customers.get(0);
			}
		}
		return customer;
	}
	
	public void reset(){
		customer = null;
	}

	public String getLanguage() {
		return language;
	}

	public void setLanguage(String language) {
		this.language = language;
	}
	
	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
	
	public List<SelectItem> getLanguages() {	
		if (languages == null) {
			languages = getDictUtils().getLov(LovConstants.LANGUAGES);
		}
		return languages;
	}

}

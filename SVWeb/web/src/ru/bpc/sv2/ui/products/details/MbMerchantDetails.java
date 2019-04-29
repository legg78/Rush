package ru.bpc.sv2.ui.products.details;

import java.io.Serializable;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;

import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@ManagedBean (name = "MbMerchantDetails")
public class MbMerchantDetails implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private Merchant merchant;
	private String language;
	private Long userSessionId;
	private List<SelectItem> languages;
	private DictUtils dictUtils;
	
	private AcquiringDao acquringBean = new AcquiringDao();

	public MbMerchantDetails(){
		language = SessionWrapper.getField("language");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
	}
	
	public void initializeModalPanel(){
		logger.debug("MbMerchantDetails initializing...");
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
	
	public Merchant getMerchant(){
		if (id == null)
			initializeModalPanel();
		if (merchant == null && id != null){
			Filter[] filters = new Filter[] { new Filter("id", id),
					new Filter("lang", language) };
			Merchant[] merchants = acquringBean.getMerchantsList(userSessionId, new SelectionParams(filters));
			if (merchants.length > 0){
				merchant = merchants[0];
			} 
		}
		return merchant;
	}
	
	public void reset(){
		merchant = null;
	}
	
	public void setLanguage(String language){
		this.language = language;
	}
	
	public String getLanguage(){
		return language;
	}
	
	public List<SelectItem> getLanguages() {	
		if (languages == null) {
			languages = dictUtils
					.getArticles(DictNames.LANGUAGES, false, false);
		}
		return languages;
	}
}

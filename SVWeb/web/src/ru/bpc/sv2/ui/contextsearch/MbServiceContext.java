package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.products.MbServiceProducts;
import ru.bpc.sv2.ui.products.MbServices;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbServiceContext")
public class MbServiceContext extends MbServices {
private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	
	private Long id;
	private Service service;
	
	private ProductsDao productBean = new ProductsDao();
	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Service getDetailService() {
		super.setNode(getService());
		return super.getDetailService();
	}
	
	public Service getService(){
		try {
			if (service == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				Service[] services = productBean.getServices(userSessionId, new SelectionParams(filters));
				if (services.length > 0) {
					service = services[0];
				}
			}
			return service;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e.getMessage());
		}
		return null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbServiceContext initializing...");
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
//				FacesUtils.setSessionMapValue(OBJECT_ID, null);
			}	
		}
		if (id == null){
			objectIdIsNotSet();
		}
		getDetailService();
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	

	public void reset(){
		service = null;
		id = null;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public void loadCurrentTab() {
		loadTab(tabName, false);
	}
	
	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (getActiveService() == null || getActiveService().getId() == null) {
			return;
		}
		
		if (tab.equalsIgnoreCase("attributesContextTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributesContext");
			attrs.fullCleanBean();
			attrs.setServiceId(getActiveService().getId());
			attrs.setEntityType(EntityNames.SERVICE);
			attrs.setInstId(getActiveService().getInstId());
			attrs.setProductType(getActiveService().getProductType());
		}
		if (tab.equalsIgnoreCase("productsContextTab")) {
			MbServiceProducts pServices = (MbServiceProducts) ManagedBeanWrapper
					.getManagedBean("MbServiceProductsContext");
			pServices.clearFilter();
			pServices.setServiceTypeId(getActiveService().getServiceTypeId());
			pServices.setServiceStatus(getActiveService().getStatus());
			pServices.setInstId(getActiveService().getInstId());
			pServices.setServiceInitiating(getActiveService().getIsInitiating());
			pServices.getFilter().setServiceId(getActiveService().getId());
			pServices.getFilter().setServiceName(getActiveService().getLabel());
			pServices.search();
		}

		loadedTabs.put(tab, Boolean.TRUE);
	}
}

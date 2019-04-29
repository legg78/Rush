package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductAccountType;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.issuing.MbProductCardTypesSearch;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.products.MbProductAccountType;
import ru.bpc.sv2.ui.products.MbProductServices;
import ru.bpc.sv2.ui.products.MbProducts;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbProductContext")
public class MbProductContext extends MbProducts {

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private ProductsDao _productsDao = new ProductsDao();
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private Product product;
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Product getDetailNode() {
		super.setNode(getProduct());
		return super.getDetailNode();
	}
	
	public Product getProduct(){
		try {
			if (product == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				Product[] products = _productsDao.getProductsList(userSessionId, new SelectionParams(filters));
				if (products.length > 0) {
					product = products[0];
				}
			}
			return product;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbInstitutionDetails initializing...");
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
		getDetailNode();
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	
	public void reset(){
		product = null;
		id = null;
	}
	
	public void setTabName(String tabName) {
		needRerender = null;
		productsSession.setProductTabName(tabName);
		this.tabName = tabName;

		loadTab(tabName, false);
	}
	
	public void loadCurrentTab() {
		
		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}
		loadTab(tabName, false);
	}
	
	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (currentNode == null || currentNode.getId() == null)
			return;

		if (tab.equalsIgnoreCase("ATTRIBUTESCONTEXTTAB")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributesContext");
			attrs.fullCleanBean();
			//attrs.setObjectId(currentNode.getId().longValue());		// TODO: don't need it anymore
			attrs.setProductId(currentNode.getId().intValue()); // Product's ID is actually an integer
			attrs.setEntityType(EntityNames.PRODUCT);
			attrs.setProductType(currentNode.getProductType());
			attrs.setInstId(currentNode.getInstId());
			attrs.setProductsBackLink(thisBackLink);
			attrs.setProductsModule(isAcquiringType() ? ACQUIRING : (isIssuingType() ? ISSUING
					: (isInstitutionType() ? INSTITUTION : "")));
			if (restoreState) {
				attrs.restoreBean();
			}
		} else if (tab.equalsIgnoreCase("SERVICESCONTEXTTAB")) {
			MbProductServices pServices = (MbProductServices) ManagedBeanWrapper
					.getManagedBean("MbProductServicesContext");
			pServices.fullCleanBean();
			pServices.setProductType(currentNode.getProductType());
			pServices.setInstId(currentNode.getInstId());
			pServices.setChild(currentNode.getParentId() != null);
			pServices.getFilter().setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			pServices.getFilter().setProductName(currentNode.getName());
			pServices.search();
		} else if (tab.equalsIgnoreCase("NOTESCONTEXTTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.PRODUCT);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("CARDTYPESCONTEXTTAB")) {
			MbProductCardTypesSearch cardTypesSearch = (MbProductCardTypesSearch) ManagedBeanWrapper
					.getManagedBean("MbProductCardTypesContextSearch");
			cardTypesSearch.fullCleanBean();
			cardTypesSearch.getFilter().setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			cardTypesSearch.setInstId(currentNode.getInstId());
			cardTypesSearch.search();
		} else if (tab.equalsIgnoreCase("SCHEMESCONTEXTTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjectsContext");
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setInstId(currentNode.getInstId());
			schemeBean.setDefaultEntityType(EntityNames.PRODUCT);
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("ACCOUNTTYPESCONTEXTTAB")){
			MbProductAccountType mbAccType = (MbProductAccountType) 
					ManagedBeanWrapper.getManagedBean("MbProductAccountTypeContext");
			ProductAccountType accType = new ProductAccountType();
			accType.setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			
			if (productType.equalsIgnoreCase(ProductConstants.ACQUIRING_PRODUCT)){
				mbAccType.setProductType(0);
			}else{
				mbAccType.setProductType(1);
			}
			mbAccType.setFilter(accType);
			mbAccType.setProductId(currentNode.getId().intValue());  // Product's ID is actually an integer
			mbAccType.setProdName(currentNode.getName());
			
			mbAccType.search();
			
		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}
	
}

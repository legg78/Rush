package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acquiring.MbMerchant;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbMerchantContext")
public class MbMerchantContext extends MbMerchant {
private static final Logger logger = Logger.getLogger("ACQUIRING");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	
	private Long id;
	private Merchant merchant;
	
	private AcquiringDao _acquireDao = new AcquiringDao();
	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Merchant getNode() {
		super.setNode(getMerchant());
		return super.getNode();
	}
	
	public Merchant getMerchant(){
		try {
			if (merchant == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				Merchant[] merchants = _acquireDao.getMerchantsList(userSessionId,
						new SelectionParams(filters));
				if (merchants.length > 0) {
					merchant = merchants[0];
				}
			}
			return merchant;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e.getMessage());
		}
		return null;
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
//				FacesUtils.setSessionMapValue(OBJECT_ID, null);
			}	
		}
		if (id == null){
			objectIdIsNotSet();
		}
		getNode();
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	

	public void reset(){
		merchant = null;
		id = null;
	}
	
	public void setTabName(String tabName) {
		needRerender = null;
		sessMerchant.setTabName(tabName);
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
		if (currentNode == null || currentNode.getId() == null) {
			needRerender = tab;
			return;
		}

		if (tab.toUpperCase().equals("ACCOUNTSCONTEXTTAB")) {
			MbAccountsSearch accountsBean = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsContextSearch");
			accountsBean.clearFilter();
			accountsBean.getFilter().setObjectId(currentNode.getId().longValue());
			accountsBean.getFilter().setInstId(currentNode.getInstId());
			accountsBean.setSearchByObject(true);
			accountsBean.setBackLink(thisBackLink);
			accountsBean.search();
		} else if (tab.toUpperCase().equals("NOTESCONTEXTTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.MERCHANT);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.toUpperCase().equals("CONTACTSCONTEXTTAB")) {
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearchContext");
			cont.setBackLink("acq_merchants");
			cont.setObjectId(currentNode.getId().longValue());
			cont.setEntityType(EntityNames.MERCHANT);
			cont.setActiveContact(null);
			cont.search();
		} else if (tab.toUpperCase().equals("ADDRESSESCONTEXTTAB")) {
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesContextSearch");
			addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.MERCHANT);
            addr.getFilter().setObjectId(currentNode.getId());
			addr.setCurLang(userLang);
            addr.search();
		} else if (tab.toUpperCase().equals("FLEXFIELDSCONTEXTTAB")) {
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataContextSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(currentNode.getInstId());
			filterFlex.setEntityType(EntityNames.MERCHANT);
			filterFlex.setObjectId(currentNode.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("attrsContextTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectContextAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(currentNode.getId().longValue());
			attrs.setProductId(currentNode.getProductId());
			attrs.setEntityType(EntityNames.MERCHANT);
			attrs.setInstId(currentNode.getInstId());
			attrs.setProductType(currentNode.getProductType());
		} else if (tab.equalsIgnoreCase("limitCountersContextTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCountersContext");
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(currentNode.getId().longValue());
			limitCounters.getFilter().setInstId(currentNode.getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.MERCHANT);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersContextTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCountersContext");
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(currentNode.getId().longValue());
			cycleCounters.getFilter().setInstId(currentNode.getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.MERCHANT);
			cycleCounters.search();
		} else if (tab.equalsIgnoreCase("customerContextTab")) {
			MbCustomersDependent custBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependentContext");
			custBean.getCustomer(currentNode.getCustomerId(), currentNode.getCustomerType());
		} else if (tab.equalsIgnoreCase("SCHEMESCONTEXTTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjectsContext");
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setInstId(currentNode.getInstId());
			schemeBean.setDefaultEntityType(EntityNames.MERCHANT);
			schemeBean.search();
		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}
}

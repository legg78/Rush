package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.pmo.PmoPaymentOrder;
import ru.bpc.sv2.pmo.PmoTemplate;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.accounts.MbObjectDocuments;
import ru.bpc.sv2.ui.acquiring.MbAcquiringHierarchyBottom;
import ru.bpc.sv2.ui.acquiring.MbMerchantsBottom;
import ru.bpc.sv2.ui.acquiring.MbRevenueSharingBottom;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.MbObjectIdsSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.issuing.MbIssuingHierarchyBottom;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.pmo.MbPmoPaymentOrders;
import ru.bpc.sv2.ui.pmo.MbPmoTemplates;
import ru.bpc.sv2.ui.products.MbContractsBottom;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbCustomerContext")
public class MbCustomerContext extends AbstractBean {
private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	protected String tabName;
	
	private Long id;
	private Customer cust;
	
	private ProductsDao _productBean = new ProductsDao();
	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Customer getActiveCustomer() {
		return getCustomer();
	}
	
	public Customer getCustomer(){
		try {
			if (cust == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id), new Filter("lang", curLang)};
				List<Customer> customers = _productBean.getCustomers(userSessionId, new SelectionParams(filters), curLang);
				if (customers != null && !customers.isEmpty()) {
					cust = customers.get(0);
				}
			}
			return cust;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
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
//				FacesUtils.setSessionMapValue(OBJECT_ID, null);
			}	
		}
		if (id == null){
			objectIdIsNotSet();
		}
		getActiveCustomer();
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	

	public void reset(){
		cust = null;
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
		
		if (tab.equalsIgnoreCase("contractsContextTab")) {
			MbContractsBottom contracts = (MbContractsBottom) ManagedBeanWrapper
					.getManagedBean("MbContractsBottomContext");
			contracts.setFilter(null);
			contracts.getFilter().setCustomerId(getActiveCustomer().getId());
			contracts.getFilter().setCustomerName(getActiveCustomer().getId().toString()); // TODO:
			// fix
			// it
			contracts.getFilter().setInstId(getActiveCustomer().getInstId());
			contracts.setBackLink(thisBackLink);
			contracts.setSearchByCustomer(true);
			contracts.search();
		} else if (tab.equalsIgnoreCase("cardsContextTab")) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomContextSearch");
			cardsSearch.clearFilter();
			cardsSearch.getFilter().setCustomerId(getActiveCustomer().getId());
			cardsSearch.setSearchTabName("CUSTOMER");
			cardsSearch.setBackLink(thisBackLink);
			cardsSearch.search();
		} else if (tab.equalsIgnoreCase("merchantsContextTab")) {
			MbMerchantsBottom merchantsSearch = (MbMerchantsBottom) ManagedBeanWrapper
					.getManagedBean("MbMerchantsBottomContext");
			merchantsSearch.clearFilter();
			merchantsSearch.getFilter().setCustomerId(getActiveCustomer().getId());
			merchantsSearch.search();
		} else if (tab.equalsIgnoreCase("terminalsContextTab")) {
			MbTerminalsBottom terminalsSearch = (MbTerminalsBottom) ManagedBeanWrapper
					.getManagedBean("MbTerminalsBottomContext");
			terminalsSearch.clearFilter();
			terminalsSearch.getFilterTerm().setCustomerId(getActiveCustomer().getId());
			terminalsSearch.searchTerminal();
		} else if (tab.equalsIgnoreCase("accountsContextTab")) {
			MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsContextSearch");
			accsSearch.clearFilter();
			accsSearch.getFilter().setCustomerId(getActiveCustomer().getId());
			accsSearch.getFilter().setInstId(getActiveCustomer().getInstId());;
			accsSearch.setBackLink(thisBackLink);
			accsSearch.setSearchByObject(false);
			accsSearch.search();

		} else if (tab.equalsIgnoreCase("PERSONIDSCONTEXTTAB")) {
			MbObjectIdsSearch docsSearch = (MbObjectIdsSearch) ManagedBeanWrapper
					.getManagedBean("MbObjectIdsContextSearch");
			docsSearch.clearFilter();
			docsSearch.getFilter().setObjectId(getActiveCustomer().getObjectId());
			docsSearch.getFilter().setEntityType(getActiveCustomer().getEntityType());
			docsSearch.search();
		} else if (tab.equalsIgnoreCase("attributesContextTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectContextAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(getActiveCustomer().getId());
			attrs.setProductId(getActiveCustomer().getProductId());
			attrs.setEntityType(EntityNames.CUSTOMER);
			attrs.setInstId(getActiveCustomer().getInstId());
			attrs.setProductType(getActiveCustomer().getProductType());
		} else if (tab.equalsIgnoreCase("limitCountersContextTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCountersContext");
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(getActiveCustomer().getId());
			limitCounters.getFilter().setInstId(getActiveCustomer().getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.CUSTOMER);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersContextTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCountersContext");
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(getActiveCustomer().getId());
			cycleCounters.getFilter().setInstId(getActiveCustomer().getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.CUSTOMER);
			cycleCounters.search();
		} else if (tab.equalsIgnoreCase("additionalContextTab")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataContextSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(getActiveCustomer().getInstId());
			filterFlex.setEntityType(EntityNames.CUSTOMER);
			filterFlex.setObjectId(getActiveCustomer().getId());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("notesContextTab")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.CUSTOMER);
			filterNote.setObjectId(getActiveCustomer().getId());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("ADDRESSESCONTEXTTAB")) {
			// get addresses for this institution
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesContextSearch");
            addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.CUSTOMER);
            addr.getFilter().setObjectId(getActiveCustomer().getId());
			addr.setCurLang(userLang);
			addr.search();
		} else if (tab.equalsIgnoreCase("CONTACTSCONTEXTTAB")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearchContext");
			if (restoreState) {
				cont.restoreBean();
			} else {
				cont.fullCleanBean();
				cont.setBackLink(thisBackLink);
				cont.setObjectId(getActiveCustomer().getId());
				cont.setEntityType(EntityNames.CUSTOMER);
			}
		} else if (tab.equalsIgnoreCase("acqHierarchyContextTab")) {
			MbAcquiringHierarchyBottom hierBean = (MbAcquiringHierarchyBottom) ManagedBeanWrapper
					.getManagedBean("MbAcquiringHierarchyBottomContext");
			hierBean.setObjectId(getActiveCustomer().getId());
			hierBean.setObjectType(EntityNames.CUSTOMER);
			hierBean.search();
		} else if (tab.equalsIgnoreCase("issHierarchyContextTab")) {
			MbIssuingHierarchyBottom hierBean = (MbIssuingHierarchyBottom) ManagedBeanWrapper
					.getManagedBean("MbIssuingHierarchyBottomContext");
			hierBean.setObjectId(getActiveCustomer().getId());
			hierBean.setObjectType(EntityNames.CUSTOMER);
			hierBean.search();
		} else if (tab.equalsIgnoreCase("paymentOrdersContextTab")) {
			MbPmoPaymentOrders paymentOrderBean = (MbPmoPaymentOrders) ManagedBeanWrapper
					.getManagedBean("MbPmoPaymentOrdersBottomContext");
			PmoPaymentOrder paymentOrderFilter = new PmoPaymentOrder();
			paymentOrderFilter.setCustomerId(getActiveCustomer().getId());
			paymentOrderBean.setPaymentOrderFilter(paymentOrderFilter);
			paymentOrderBean.search();
		} else if (tab.equalsIgnoreCase("templatesContextTab")) {
			MbPmoTemplates templatesBean = (MbPmoTemplates) ManagedBeanWrapper
					.getManagedBean("MbPmoTemplatesContext");
			PmoTemplate templateFilter = new PmoTemplate();
			templateFilter.setCustomerId(getActiveCustomer().getId());
			templateFilter.setInstId(getActiveCustomer().getInstId());
			templateFilter.setInstName(getActiveCustomer().getInstName());
			templatesBean.setTemplateFilter(templateFilter);
			templatesBean.search();
		} else if (tab.equalsIgnoreCase("revenueSharingContextTab")) {
			MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
					.getManagedBean("MbRevenueSharingBottomContext");
			revenueSharingBean.clearFilter();
			revenueSharingBean.getFilter().setCustomerId(getActiveCustomer().getId());
			revenueSharingBean.search();
		} else if (tab.equalsIgnoreCase("documentsContextTab")){
			MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
					.getManagedBean("MbObjectDocumentsContext");
			mbObjectDocuments.getFilter().setObjectId(getActiveCustomer().getId().longValue());
			mbObjectDocuments.getFilter().setEntityType(EntityNames.CUSTOMER);
			mbObjectDocuments.setBackLink(thisBackLink);
			if (restoreBean) {
				mbObjectDocuments.restoreState();
			}
			mbObjectDocuments.search();
		} else if (tab.equalsIgnoreCase("applicationsContextTab")){
			MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
					.getManagedBean("MbObjectApplicationsContextSearch");
			mbAppObjects.setObjectId(getActiveCustomer().getId().longValue());
			mbAppObjects.setEntityType(EntityNames.CUSTOMER);
//			mbObjectDocuments.setBackLink(thisBackLink);
			mbAppObjects.search();
		}

		loadedTabs.put(tab, Boolean.TRUE);
	}
	
	public String getTabName() {
		return tabName;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
}

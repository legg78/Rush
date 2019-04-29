package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acquiring.MbMerchantsBottom;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.crp.MbCrpDepartment;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.products.MbContracts;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.products.MbServiceObjects;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbContractContext")
public class MbContractContext extends MbContracts {
	
	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private ProductsDao _productsDao = new ProductsDao();
	
	private Long id;
	private Contract contract;

	public Contract getActiveContract() {
		super.setActiveContract(getContract());
		return super.getActiveContract();
	}
	
	public Contract getContract(){
		try {
			if (contract == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("CONTRACT_ID", id),
						new Filter("LANG", curLang)};
				getParamMaps().put("param_tab", filters);
				getParamMaps().put("tab_name", "CONTRACT");
				Contract[] contracts = _productsDao.getContractsCur(userSessionId, new SelectionParams(filters), getParamMaps());
				if (contracts.length > 0) {
					contract = contracts[0];
				}
			}
			return contract;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void reset(){
		contract = null;
		id = null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbCardDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils.getSessionMapValue(CTX_MENU_PARAMS);
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
		getActiveContract();
	}
	
	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
	}
	
	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (contract == null || contract.getId() == null)
			return;
		try {
			if (tab.equalsIgnoreCase("customerContextTab")) {
				MbCustomersDependent customer = (MbCustomersDependent) ManagedBeanWrapper
						.getManagedBean("MbCustomersDependentContext");
				customer
						.getCustomer(contract.getCustomerId(), contract.getCustomerType());
			} else if (tab.equalsIgnoreCase("cardsContextTab")) {
				MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
						.getManagedBean("MbCardsBottomContextSearch");
				cardsSearch.clearFilter();
				cardsSearch.getFilter().setContractId(contract.getId());
				cardsSearch.setSearchTabName("CONTRACT");
				cardsSearch.search();
			} else if (tab.equalsIgnoreCase("accountsContextTab")) {
				MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
						.getManagedBean("MbAccountsContextSearch");
				accsSearch.clearFilter();
				accsSearch.getFilter().setCustomerId(contract.getCustomerId());
				accsSearch.getFilter().setContractId(contract.getId());
				accsSearch.setBackLink(thisBackLink);
				accsSearch.setSearchByObject(false);
				accsSearch.search();
			} else if (tab.equalsIgnoreCase("terminalsContextTab")) {
				MbTerminalsBottom terminalsBean = (MbTerminalsBottom) ManagedBeanWrapper.getManagedBean("MbTerminalsBottomContext");
				terminalsBean.clearFilter();
				terminalsBean.getFilterTerm().setContractId(contract.getId());
				terminalsBean.searchTerminal();
			} else if (tab.equalsIgnoreCase("merchantsContextTab")) {
				MbMerchantsBottom merchantsBean = (MbMerchantsBottom) ManagedBeanWrapper
						.getManagedBean("MbMerchantsBottomContext");
				merchantsBean.clearFilter();
				merchantsBean.getFilter().setContractId(contract.getId());
				merchantsBean.search();
			} else if (tab.equalsIgnoreCase("servicesContextTab")) {
				MbServiceObjects servicesBean = (MbServiceObjects) ManagedBeanWrapper
						.getManagedBean("MbServiceObjectsContext");
				servicesBean.clearFilter();
				servicesBean.getFilter().setContractId(contract.getId());
				servicesBean.search();
			} else if (tab.equalsIgnoreCase("attributesContextTab")) {
				MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
						.getManagedBean("MbObjectAttributesContext");
				attrs.fullCleanBean();
				attrs.setObjectId(contract.getId());
				attrs.setProductId(contract.getProductId());
				attrs.setEntityType(EntityNames.CONTRACT);
				attrs.setInstId(contract.getInstId());
				attrs.setProductType(contract.getProductType());
			} else if (tab.equalsIgnoreCase("limitCountersContextTab")) {
				MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
						.getManagedBean("MbLimitCountersContext");
				limitCounters.setFilter(null);
				limitCounters.getFilter().setObjectId(contract.getId());
				limitCounters.getFilter().setInstId(contract.getInstId());
				limitCounters.getFilter().setEntityType(EntityNames.CONTRACT);
				limitCounters.search();
			} else if (tab.equalsIgnoreCase("cycleCountersContextTab")) {
				MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
						.getManagedBean("MbCycleCountersContext");
				cycleCounters.setFilter(null);
				cycleCounters.getFilter().setObjectId(contract.getId());
				cycleCounters.getFilter().setInstId(contract.getInstId());
				cycleCounters.getFilter().setEntityType(EntityNames.CONTRACT);
				cycleCounters.search();
			}
			if (tab.equalsIgnoreCase("contractsTab")) {
				// MbObjectAttributes attrs = (MbObjectAttributes)
				// ManagedBeanWrapper.getManagedBean("MbObjectAttributes");
				// attrs.fullCleanBean();
				// attrs.setContractId(_activeContract.getId());
				// attrs.setEntityType(EntityNames.SERVICE);
				// attrs.setInstId(_activeContract.getInstId());
			}
			if (tab.equalsIgnoreCase("objectsTabs")) {
				// MbProductContracts pContracts =
				// (MbProductContracts) ManagedBeanWrapper.getManagedBean("MbProductContracts");
				// pContracts.clearFilter();
				// pContracts.getFilter().setContractId(_activeContract.getId());
				// pContracts.getFilter().setContractName(_activeContract.getLabel());
				// pContracts.search();
			}
			if (tab.equalsIgnoreCase("corporationsContextTab")) {
				MbCrpDepartment mbCrpDepartment = (MbCrpDepartment) ManagedBeanWrapper
						.getManagedBean("MbCrpDepartmentContext");
				mbCrpDepartment.setContractId(contract.getId());
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
}

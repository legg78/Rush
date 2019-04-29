package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;

import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.issuing.Cardholder;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.reports.RptDocument;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.accounts.MbObjectDocuments;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.issuing.MbCardInstancesSearch;
import ru.bpc.sv2.ui.issuing.MbCardholdersSearch;
import ru.bpc.sv2.ui.issuing.MbCardsSearch;
import ru.bpc.sv2.ui.operations.MbOperationsBottom;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbCardsContextSearch")
public class MbCardsContextSearch extends MbCardsSearch {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private Card card;
	
	private IssuingDao issuingDao = new IssuingDao();
	
	public Card getActiveCard() {
		super.setActiveCard(getCard());
		return super.getActiveCard();
	}
	
	public Card getCard(){
		try {
			if (card == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("CARD_ID", id),
						new Filter("lang", curLang)};
				Map<String, Object> paramMaps = new HashMap<String, Object>();
				paramMaps.put("param_tab", filters);
				paramMaps.put("tab_name", "CARD");
				Card[] cards = issuingDao.getCardsCur(userSessionId, new SelectionParams(filters), paramMaps);
				if (cards.length > 0) {
					card = cards[0];
				}
			}
			return card;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}
	
	public void reset(){
		card = null;
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
		getActiveCard();
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
		if (card == null)
			return;
		try {
			if(tab.equalsIgnoreCase("ADDRESSESCONTEXTTAB")) {
                MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
                        .getManagedBean("MbAddressesContextSearch");
                addr.fullCleanBean();
                addr.getFilter().setTypeIdPairs("(\'" + EntityNames.CARDHOLDER + "\', " + card.getCardholderId() + "), " +
                        "(\'" + EntityNames.CUSTOMER + "\', " + card.getCustomerId() + ")");
                addr.getFilter().setLang(curLang);
                addr.search();

            } else if (tab.equalsIgnoreCase("INSTANCESCONTEXTTAB")) {
				MbCardInstancesSearch instancesSearch = (MbCardInstancesSearch) ManagedBeanWrapper
						.getManagedBean("MbCardInstancesContextSearch");
				CardInstance instanceFilter = new CardInstance();
				instanceFilter.setCardId(card.getId());
				instancesSearch.setFilter(instanceFilter);
				instancesSearch.search();
			} else if (tab.equalsIgnoreCase("ACCOUNTSCONTEXTTAB")) {
				MbAccountsSearch accountsBean = (MbAccountsSearch) ManagedBeanWrapper
						.getManagedBean("MbAccountsContextSearch");
				accountsBean.clearFilter();
				accountsBean.getFilter().setObjectId(card.getId().longValue());
				accountsBean.getFilter().setInstId(card.getInstId());
				accountsBean.getFilter().setSplitHash(card.getSplitHash());
				accountsBean.setSearchByObject(true);
				accountsBean.setBackLink(thisBackLink);
				accountsBean.setPrivilege(AccountPrivConstants.VIEW_TAB_ACCOUNT);
				accountsBean.search();
			} else if (tab.equalsIgnoreCase("OPERATIONSCONTEXTTAB")) {
				MbOperationsBottom operationsBean = (MbOperationsBottom) ManagedBeanWrapper
						.getManagedBean("MbOperationsBottomContext");
				operationsBean.clearFilter();
				operationsBean.setSearchTabName("CARD");
				operationsBean.getParticipantFilter().setCardId(card.getId());
				operationsBean.getParticipantFilter().setParticipantType("PRTYISS");
				operationsBean.searchByParticipant();
			} else if (tab.equalsIgnoreCase("CARDHOLDERSCONTEXTTAB")) {
				MbCardholdersSearch cardholdersBean = (MbCardholdersSearch) ManagedBeanWrapper
						.getManagedBean("MbCardholdersContextSearch");
				Cardholder filterCardholder = new Cardholder();
				filterCardholder.setId(card.getCardholderId());
				cardholdersBean.setFilter(filterCardholder);
				cardholdersBean.setSearchByCard(true);
				cardholdersBean.search();
				cardholdersBean.getCardholder();
			} else if (tab.equalsIgnoreCase("CUSTOMERSCONTEXTTAB")) {
				MbCustomersDependent customersBean = (MbCustomersDependent) ManagedBeanWrapper
						.getManagedBean("MbCustomersDependentContext");
				//			
				// // do it before clearFilter() or customersBean will clean this bean :)
				// customersBean.setFromCard(true);
				//			
				// customersBean.clearFilter();
				customersBean.getCustomer(card.getCustomerId(), card.getCustomerType());
			} else if (tab.equalsIgnoreCase("attributesContextTab")) {
				MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
						.getManagedBean("MbObjectAttributesContext");
				attrs.fullCleanBean();
				attrs.setObjectId(card.getId());
				attrs.setProductId(card.getProductId());
				attrs.setEntityType(EntityNames.CARD);
				attrs.setInstId(card.getInstId());
				attrs.setProductType(card.getProductType());
			} else if (tab.equalsIgnoreCase("limitCountersContextTab")) {
				MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
						.getManagedBean("MbLimitCountersContext");
				limitCounters.setFilter(null);
				limitCounters.getFilter().setObjectId(card.getId());
				limitCounters.getFilter().setInstId(card.getInstId());
				limitCounters.getFilter().setEntityType(EntityNames.CARD);
				limitCounters.search();
			} else if (tab.equalsIgnoreCase("cycleCountersContextTab")) {
				MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
						.getManagedBean("MbCycleCountersContext");
				cycleCounters.setFilter(null);
				cycleCounters.getFilter().setObjectId(card.getId());
				cycleCounters.getFilter().setInstId(card.getInstId());
				cycleCounters.getFilter().setEntityType(EntityNames.CARD);
				cycleCounters.search();
			} else if (tab.equalsIgnoreCase("statusLogsContextTab")) {
				MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper
						.getManagedBean("MbStatusLogsContext");
				statusLogs.clearFilter();
				statusLogs.getFilter().setObjectId(card.getId());

				// logs are written for card instances
				statusLogs.getFilter().setEntityType(EntityNames.CARD_INSTANCE);
				statusLogs.search();
			} else if (tab.equalsIgnoreCase("SCHEMESCONTEXTTAB")) {
				MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
						.getManagedBean("MbAupSchemeObjectsContext");
				schemeBean.setObjectId(card.getId().longValue());
				schemeBean.setDefaultEntityType(EntityNames.CARD);
				schemeBean.setInstId(card.getInstId());
				schemeBean.search();
			} else if (tab.equalsIgnoreCase("documentsContextTab")){
				MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
						.getManagedBean("MbObjectDocumentsContext");
				RptDocument filter = mbObjectDocuments.getFilter();
				filter.setObjectId(card.getId().longValue());
				filter.setEntityType(EntityNames.CARD);
				mbObjectDocuments.setFilter(filter);
				mbObjectDocuments.search();
			} else if (tab.equalsIgnoreCase("FLEXIBLEFIELDSCONTEXTTAB")) {
				// get flexible data for this institution
				MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
						.getManagedBean("MbFlexFieldsDataContextSearch");
				FlexFieldData filterFlex = new FlexFieldData();
				filterFlex.setInstId(card.getInstId());
				filterFlex.setEntityType(EntityNames.CARD);
				filterFlex.setObjectId(card.getId().longValue());
				flexible.setFilter(filterFlex);
				flexible.search();
			} else if (tab.equalsIgnoreCase("applicationsContextTab")){
				MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
						.getManagedBean("MbObjectApplicationsContextSearch");
				mbAppObjects.setObjectId(card.getId().longValue());
				mbAppObjects.setEntityType(EntityNames.CARD);
//				mbObjectDocuments.setBackLink(thisBackLink);
				mbAppObjects.search();
			}
			needRerender = tab;
			loadedTabs.put(tab, Boolean.TRUE);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
}

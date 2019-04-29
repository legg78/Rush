package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.accounts.Balance;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.ui.accounts.MbAccountsAllSearch;
import ru.bpc.sv2.ui.accounts.MbBalancesSearch;
import ru.bpc.sv2.ui.accounts.MbEntriesForAccount;
import ru.bpc.sv2.ui.accounts.MbObjectDocuments;
import ru.bpc.sv2.ui.acquiring.MbMerchantsBottom;
import ru.bpc.sv2.ui.acquiring.MbTerminalsBottom;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.issuing.MbCardsBottomSearch;
import ru.bpc.sv2.ui.loyalty.MbLoyaltyBonusesSearch;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.operations.MbOperationsBottom;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped

@ManagedBean(name = "MbAccountsAllContextSearch")
public class MbAccountsAllContextSearch extends MbAccountsAllSearch {

	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";

	private Long id;
	private Account account;
	private List<SelectItem> languages;
	private DictUtils dictUtils;
	private HashMap<String, Object> paramMap;

	private AccountsDao accountBean = new AccountsDao();

	public Account getActiveAccount() {
		super.setActiveAccount(getAccount());
		setRenderTabs(true);
		return super.getActiveAccount();
	}

	public void initializeModalPanel(){
		logger.debug("MbAccountDetails initializing...");
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
//			objectIdIsNotSet();
		}
		getActiveAccount();

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

	public Account getAccount(){
		try {
				if (account == null && id != null) {
					Filter[] filters = setFilters();
					Account[] accounts = accountBean.getAccountsCur(userSessionId, new SelectionParams(filters), paramMap);
					if (accounts.length > 0) {
						account = accounts[0];
					}
				}
			return account;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e.getMessage());
		}
		return null;
	}

	private Filter[] setFilters(){
		Filter filters [] = new Filter[]{new Filter("ACCOUNT_ID", id),
										   new Filter("LANG", curLang)};
		getParamMap().put("param_tab", filters);
		getParamMap().put("tab_name", "ACCOUNT");
		return  filters;
	}

	public void reset(){
		id = null;
		account = null;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		sessionBean.setTabName(tabName);
	}

	public void loadCurrentTab() {
		loadTab(tabName, false);
	}

	private void loadTab(String tab, boolean restoreBean) {
		if (tab == null)
			return;
		if (account == null)
			return;

		if (tab.equalsIgnoreCase("CARDSCONTEXTTAB")) {
			MbCardsBottomSearch cardsSearch = (MbCardsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbCardsBottomContextSearch");
			Card cardFilter = new Card();
			cardFilter.setAccountId(account.getId());
			cardsSearch.setFilter(cardFilter);
			cardsSearch.setSearchTabName("ACCOUNT");
			cardsSearch.search();
		} else if (tab.equalsIgnoreCase("OPERATIONSCONTEXTTAB")) {
			MbOperationsBottom operationsBean = (MbOperationsBottom) ManagedBeanWrapper
					.getManagedBean("MbOperationsBottomContext");
			operationsBean.clearFilter();
			operationsBean.getParticipantFilter().setAccountId(account.getId());
			operationsBean.setSearchTabName("ACCOUNT");
			if (isIssuingType()) {
				operationsBean.getParticipantFilter().setParticipantType(Participant.ISS_PARTICIPANT);
				operationsBean.getParticipantFilter().setInstId(account.getInstId());
			} else if (isAcquiringType()) {
				operationsBean.getParticipantFilter().setParticipantType(Participant.ACQ_PARTICIPANT);
				operationsBean.getParticipantFilter().setInstId(account.getInstId());
			}

			ru.bpc.sv2.operations.incoming.Operation filterAdjusment = new ru.bpc.sv2.operations.incoming.Operation();
			filterAdjusment.setAccountNumber(account.getAccountNumber());
			filterAdjusment.setAccountId(account.getId());
			filterAdjusment.setSplitHash(account.getSplitHash());
			filterAdjusment.setAcqInstId(account.getInstId());
			filterAdjusment.setIssInstId(account.getInstId());
			filterAdjusment.setOperationCurrency(account.getCurrency());

			operationsBean.setAdjustmentFilter(filterAdjusment);
			operationsBean.setBackLink(thisBackLink);
			operationsBean.searchByParticipant();
		} else if (tab.equalsIgnoreCase("BALANCESCONTEXTTAB")) {
			MbBalancesSearch balancesSearch = (MbBalancesSearch) ManagedBeanWrapper
					.getManagedBean("MbBalancesContextSearch");
			Balance balanceFilter = new Balance();
			balanceFilter.setAccountId(account.getId());
			balancesSearch.setFilter(balanceFilter);
			balancesSearch.search();
		} else if (tab.equalsIgnoreCase("TRANSACTIONSCONTEXTTAB")) {
			MbEntriesForAccount entriesSearch = (MbEntriesForAccount) ManagedBeanWrapper
					.getManagedBean("MbEntriesForAccountContext");
			Balance balanceFilter = new Balance();
			balanceFilter.setAccountId(account.getId());
			entriesSearch.setFilter(balanceFilter);
			entriesSearch.search();
		} else if (tab.equalsIgnoreCase("attributesContextTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributesContext");
			attrs.fullCleanBean();
			attrs.setObjectId(account.getId());
			attrs.setProductId(account.getProductId());
			attrs.setEntityType(EntityNames.ACCOUNT);
			attrs.setInstId(account.getInstId());
			attrs.setProductType(account.getProductType());
		} else if (tab.equalsIgnoreCase("merchantsContextTab")) {
			MbMerchantsBottom merchantsBean = (MbMerchantsBottom) ManagedBeanWrapper
					.getManagedBean("MbMerchantsBottomContext");
			Merchant merchantFilter = new Merchant();
			merchantFilter.setAccountId(account.getId());
			merchantsBean.setFilter(merchantFilter);
			merchantsBean.setSearchTabName("ACCOUNT");
			merchantsBean.search();
		} else if (tab.equalsIgnoreCase("limitCountersContextTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCountersContext");
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(account.getId());
			limitCounters.getFilter().setInstId(account.getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.ACCOUNT);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersContextTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCountersContext");
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(account.getId());
			cycleCounters.getFilter().setInstId(account.getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.ACCOUNT);
			cycleCounters.search();
		} else if (tab.equalsIgnoreCase("CUSTOMERSCONTEXTTAB")) {
			MbCustomersDependent customersBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependentContext");
			// customersBean.clearFilter();
			customersBean.getCustomer(account.getCustomerId(), account.getCustomerType());
		} else if (tab.equalsIgnoreCase("loyaltyBonusesContextTab")) {
			MbLoyaltyBonusesSearch loaltyBonueseBean = (MbLoyaltyBonusesSearch) ManagedBeanWrapper
					.getManagedBean("MbLoyaltyBonusesContextSearch");
			loaltyBonueseBean.setAccountId(account.getId());
			loaltyBonueseBean.search();
		} else if (tab.equalsIgnoreCase("TERMINALSCONTEXTTAB")) {
			MbTerminalsBottom terminalsBean = (MbTerminalsBottom) ManagedBeanWrapper
					.getManagedBean("MbTerminalsBottomContext");
			terminalsBean.setSearchTabName("ACCOUNT");
			terminalsBean.setAccountId(account.getId());
			terminalsBean.searchTerminal();
		} else if (tab.equalsIgnoreCase("FLEXIBLEFIELDSCONTEXTTAB")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataContextSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(account.getInstId());
			filterFlex.setEntityType(EntityNames.ACCOUNT);
			filterFlex.setObjectId(account.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("NOTESCONTEXTTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.ACCOUNT);
			filterNote.setObjectId(account.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("CONTACTSCONTEXTTAB")){
//			MbAccountContacts mbAccountContacts = (MbAccountContacts) ManagedBeanWrapper
//					.getManagedBean("MbAccountContacts");
//			mbAccountContacts.setAccountId(_activeAccount.getId().longValue());
//			mbAccountContacts.search();
		} else if (tab.equalsIgnoreCase("documentsContextTab")){
			MbObjectDocuments mbObjectDocuments = (MbObjectDocuments) ManagedBeanWrapper
					.getManagedBean("MbObjectDocumentsContext");
			mbObjectDocuments.getFilter().setObjectId(account.getId().longValue());
			mbObjectDocuments.getFilter().setEntityType(EntityNames.ACCOUNT);
			mbObjectDocuments.setBackLink(thisBackLink);
			if (restoreBean) {
				mbObjectDocuments.restoreState();
			}
			mbObjectDocuments.search();
		} else if (tab.equalsIgnoreCase("statusLogsContextTab")) {
			MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper
					.getManagedBean("MbStatusLogsContext");
			statusLogs.clearFilter();
			statusLogs.getFilter().setObjectId(account.getId());
			statusLogs.getFilter().setEntityType(EntityNames.ACCOUNT);
			statusLogs.search();
		} else if (tab.equalsIgnoreCase("applicationsContextTab")){
			MbObjectApplicationsSearch mbAppObjects = (MbObjectApplicationsSearch) ManagedBeanWrapper
					.getManagedBean("MbObjectApplicationsContextSearch");
			mbAppObjects.setObjectId(account.getId().longValue());
			mbAppObjects.setEntityType(EntityNames.ACCOUNT);
//			mbObjectDocuments.setBackLink(thisBackLink);
			mbAppObjects.search();
		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	@Override
	public HashMap<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	@Override
	public void setParamMap(HashMap<String, Object> paramMap) {
		this.paramMap = paramMap;
	}
}

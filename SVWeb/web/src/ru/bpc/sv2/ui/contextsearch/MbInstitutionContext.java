package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.AccountGL;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.ui.accounts.MbGLAccountsSearch;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.network.MbNetworkMembers;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.orgstruct.MbAgent;
import ru.bpc.sv2.ui.orgstruct.MbInstitution;
import ru.bpc.sv2.ui.products.MbCustomersBottom;
import ru.bpc.sv2.ui.settings.MbSettingParamsSearch;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbInstitutionContext")
public class MbInstitutionContext extends MbInstitution {
private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	
	private Long id;
	private Institution inst;
	
	private OrgStructDao orgStructDao = new OrgStructDao();
	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Institution getDetailNode() {
		super.setNode(getInstitution());
		return super.getDetailNode();
	}
	
	public Institution getInstitution(){
		try {
			if (inst == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				Institution[] insts = orgStructDao.getInstitutions(userSessionId,
						new SelectionParams(filters), curLang, true);
				if (insts.length > 0) {
					inst = insts[0];
				}
			}
			return inst;
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
		inst = null;
		id = null;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
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
			return;
		}

		if (tab.equalsIgnoreCase("GLACCOUNTSCONTEXTTAB")) {
			// get GL accounts for this institution

			MbGLAccountsSearch accountsBean = (MbGLAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbGLAccountsContextSearch");
			AccountGL filterAccount = new AccountGL();
			filterAccount.setEntityType(EntityNames.INSTITUTION);
			filterAccount.setEntityId(currentNode.getId().toString());
			filterAccount.setInstId(currentNode.getId().intValue());
			accountsBean.setFilter(filterAccount);
			accountsBean.setBackLink(thisBackLink);
			accountsBean.search();
		} else if (tab.equalsIgnoreCase("ADDRESSESCONTEXTTAB")) {
			// get addresses for this institution
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesContextSearch");
			addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.INSTITUTION);
            addr.getFilter().setObjectId(currentNode.getId());
			addr.setCurLang(userLang);
			addr.search();
		} else if (tab.equalsIgnoreCase("CONTACTSCONTEXTTAB")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactContextSearch");
			if (restoreState) {
				cont.restoreBean();
			} else {
				cont.fullCleanBean();
				cont.setBackLink(thisBackLink);
				cont.setObjectId(currentNode.getId().longValue());
				cont.setEntityType(EntityNames.INSTITUTION);
				cont.search();
			}
		} else if (tab.equalsIgnoreCase("FLEXIBLEFIELDSCONTEXTTAB")) {
			// get flexible data for this institution
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataContextSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(currentNode.getId().intValue());
			filterFlex.setEntityType(EntityNames.INSTITUTION);
			filterFlex.setObjectId(currentNode.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("SETTINGPARAMSCONTEXTTAB")) {
			// get setting params for this institution
			MbSettingParamsSearch setParamsSearchBean = (MbSettingParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbSettingParamsContextSearch");
			SettingParam setParamFilter = new SettingParam();
			setParamFilter.setLevelValue(currentNode.getId().toString());
			setParamFilter.setParamLevel(LevelNames.INSTITUTION);
			setParamsSearchBean.setFilter(setParamFilter);
			setParamsSearchBean.search();
		} else if (tab.equalsIgnoreCase("NOTESCONTEXTTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.INSTITUTION);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("networksContextTab")) {
			MbNetworkMembers networks = (MbNetworkMembers) ManagedBeanWrapper
					.getManagedBean("MbNetworkMembersContext");
			networks.fullCleanBean();
			networks.getFilter().setInstId(currentNode.getId().intValue()); 
			networks.setInstNetrowkId(currentNode.getNetworkId());
			networks.setShowNetworks(true);
			networks.search();
		} else if (tab.equalsIgnoreCase("SCHEMESCONTEXTTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjectsContext");
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setDefaultEntityType(EntityNames.INSTITUTION);
			schemeBean.setInstId(currentNode.getId().intValue()); // Intitution's'ID is actually an integer
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("associationContextTab")){
			MbCustomersBottom customersBottomBean = (MbCustomersBottom) ManagedBeanWrapper.getManagedBean("MbCustomersBottomContext");
			Customer filter = customersBottomBean.getFilter();
			filter.setExtEntityType(EntityNames.INSTITUTION);
			filter.setExtObjectId(currentNode.getId().longValue());
			customersBottomBean.search();		
		} else if (tab.equalsIgnoreCase("agentsContextTab")){
			MbAgent mbAgents = (MbAgent) ManagedBeanWrapper
					.getManagedBean("MbAgentBottomContext");
			Agent agent = mbAgents.getFilter();
			agent.setInstId(currentNode.getId().intValue());
			mbAgents.setFilter(agent);
			mbAgents.searchAgents();
		}
		loadedTabs.put(tab, Boolean.TRUE);
	}
}

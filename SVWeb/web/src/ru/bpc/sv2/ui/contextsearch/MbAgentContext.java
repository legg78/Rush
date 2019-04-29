package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.ui.accounts.MbGLAccountsSearch;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.orgstruct.MbAgent;
import ru.bpc.sv2.ui.products.MbCustomersBottom;
import ru.bpc.sv2.ui.settings.MbSettingParamsSearch;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped

@ManagedBean(name = "MbAgentContext")
public class MbAgentContext extends MbAgent {
	
private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	
	private Long id;
	private Agent agent;
	
	private OrgStructDao orgStructDao = new OrgStructDao();
	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Agent getDetailNode() {
		super.setNode(getInstitution());
		return super.getDetailNode();
	}
	
	public Agent getInstitution(){
		try {
			if (agent == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				Agent[] agents = orgStructDao.getAgentsList(userSessionId,
						new SelectionParams(filters));
				if (agents.length > 0) {
					agent = agents[0];
				}
			}
			return agent;
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
		agent = null;
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

		if (tab.equalsIgnoreCase("flexFieldsContextTab")) {
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataContextSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(currentNode.getInstId());
			filterFlex.setEntityType(EntityNames.AGENT);
			filterFlex.setObjectId(currentNode.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		}
		if (tab.equalsIgnoreCase("accountsContextTab")) {
			MbGLAccountsSearch accountsBean = (MbGLAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbGLAccountsContextSearch");
			accountsBean.clearFilter();
			accountsBean.getFilter().setEntityType(EntityNames.AGENT);
			accountsBean.getFilter().setEntityId(currentNode.getId().toString());
			accountsBean.getFilter().setInstId(currentNode.getInstId());
			accountsBean.setBackLink(thisBackLink);
			accountsBean.search();
		}
		if (tab.equalsIgnoreCase("addressesContextTab")) {
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesContextSearch");
            addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.AGENT);
            addr.getFilter().setObjectId(currentNode.getId());
			addr.setCurLang(userLang);
			addr.search();
		}
		if (tab.equalsIgnoreCase("contactsContextTab")) {
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactContextSearch");
			if (restoreState) {
				cont.restoreBean();
			} else {
				cont.fullCleanBean();
				cont.setBackLink(thisBackLink);
				cont.setObjectId(currentNode.getId().longValue());
				cont.setEntityType(EntityNames.AGENT);
			}
		}
		if (tab.equalsIgnoreCase("settingParamsContextTab")) {
			MbSettingParamsSearch setParamsSearchBean = (MbSettingParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbSettingParamsContextSearch");
			SettingParam setParamFilter = new SettingParam();
			setParamFilter.setLevelValue(currentNode.getId().toString());
			setParamFilter.setParamLevel(LevelNames.AGENT);
			setParamsSearchBean.setFilter(setParamFilter);
			setParamsSearchBean.search();
		}
		if (tab.equalsIgnoreCase("notesContextTab")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.AGENT);
			filterNote.setObjectId(currentNode.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("SCHEMESContextTab")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper.getManagedBean("MbAupSchemeObjectsContext");
			schemeBean.setObjectId(currentNode.getId().longValue());
			schemeBean.setDefaultEntityType(EntityNames.AGENT);
			schemeBean.setInstId(currentNode.getInstId());
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("associationContextTab")){
			MbCustomersBottom customersBottomBean = (MbCustomersBottom) ManagedBeanWrapper.getManagedBean("MbCustomersBottomContext");
			Customer filter = customersBottomBean.getFilter();
			filter.setExtEntityType(EntityNames.AGENT);
			filter.setExtObjectId(currentNode.getId().longValue());
			customersBottomBean.search();		
		}
		loadedTabs.put(tab, Boolean.TRUE);
	}

}

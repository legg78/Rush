package ru.bpc.sv2.ui.settings;

import java.io.Serializable;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.ui.administrative.users.MbUsersSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.MbPersonsSearch;
import ru.bpc.sv2.ui.notifications.MbCustomEvents;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbUserSettingParams")
public class MbUserSettingParams implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private String tabName;
	private final String thisBackLink = "user|list_settings";
	
	public boolean isRestore() {
		Boolean restoreBean = (Boolean) FacesUtils.removeSessionMapValue(thisBackLink);
		if (restoreBean != null && restoreBean) {
			loadTabs(true);
			return true;
		} else{
			loadTabs(false);
		}
		return false;
	}
	
	public String showUserParams() {
		return showUserParams(false);
	}
	
	public String showUserParams(boolean restore) {
		if (!restore) {
			tabName = "settingsTab";
		}
		return thisBackLink;
	}
	
	public void loadTabs(boolean restore){
		UserSession us = ManagedBeanWrapper.getManagedBean("usession");
		
		if (tabName.equalsIgnoreCase("settingsTab")){
			MbSettingParamsSearch setParamsSearchBean = ManagedBeanWrapper.getManagedBean("MbSettingParamsSearch");
	        SettingParam setParamFilter = new SettingParam();
	        setParamFilter.setLevelValue(us.getUserName());
	        setParamFilter.setParamLevel(LevelNames.USER);
	        setParamsSearchBean.setFilter(setParamFilter);
	        setParamsSearchBean.search();
		} 
        
		if (tabName.equalsIgnoreCase("contactsTab")){
	        MbContactSearch cont = ManagedBeanWrapper.getManagedBean("MbContactSearch");
			if (restore) {
				cont.restoreBean();
			} else {
		        cont.fullCleanBean();
		        cont.setObjectId(us.getUser().getPersonId());
		        cont.setEntityType(EntityNames.PERSON);
		        cont.setBackLink(thisBackLink);
		        cont.search();
			}
		}
		
		if (tabName.equalsIgnoreCase("personalDataTab")){
			MbPersonsSearch personBean = ManagedBeanWrapper.getManagedBean("MbPersonsSearch");
			personBean.setActivePerson(us.getUser().getPerson());
			personBean.viewPerson();

			MbUsersSearch usersSearch = ManagedBeanWrapper.getManagedBean(MbUsersSearch.class);
			UserSession userSession = ManagedBeanWrapper.getManagedBean("usession");
			usersSearch.setActiveUser(userSession.getUser());
			personBean.setAllowPasswordChange(true);
		}

		if (tabName.equalsIgnoreCase("customEventsTab")){
			MbCustomEvents customEvents = ManagedBeanWrapper.getManagedBean("MbCustomEvents");
			customEvents.clearFilter();
			customEvents.getFilter().setObjectId(us.getUser().getId().longValue());
			customEvents.getFilter().setEntityType(EntityNames.USER);
			customEvents.setEventOwnerEntityType(EntityNames.USER);
			customEvents.search();
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		loadTabs(false);
	}

}

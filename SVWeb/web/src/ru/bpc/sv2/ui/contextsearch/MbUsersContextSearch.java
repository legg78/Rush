package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.ui.administrative.roles.MbUserRolesSearch;
import ru.bpc.sv2.ui.administrative.users.MbUserInstsNAgents;
import ru.bpc.sv2.ui.administrative.users.MbUserPrivileges;
import ru.bpc.sv2.ui.administrative.users.MbUsersSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbUsersContextSearch")
public class MbUsersContextSearch extends MbUsersSearch {
private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";	
	
	private Long id;
	private User user;
	
	private UsersDao _usersDao = new UsersDao();
	
	
	public void setId(Long id){
		this.id = id;
	}
	
	public User getActiveUser() {
		super.setActiveUser(getUser());
		return super.getActiveUser();
	}
	
	public User getUser(){
		try {
			if (user == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				User[] users = _usersDao.getUsers(userSessionId,
						new SelectionParams(filters));
				if (users.length > 0) {
					user = users[0];
				}
				loadedTabs.clear();
			}
			return user;
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
		getActiveUser();
	}	
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}	
	

	public void reset(){
		user = null;
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
		if (user == null)
			return;

		if (tab.equalsIgnoreCase("ROLESCONTEXTTAB")) {
			MbUserRolesSearch userRolesBean = (MbUserRolesSearch) ManagedBeanWrapper
					.getManagedBean("MbUserRolesContextSearch");
			userRolesBean.setFilter(new ComplexRole());
			userRolesBean.setUserId(user.getId());
			userRolesBean.setBackLink(thisBackLink);
			userRolesBean.search();
		}
		if (tab.equalsIgnoreCase("INSTSCONTEXTTAB")) {
			MbUserInstsNAgents userInstAgentsBean = (MbUserInstsNAgents) ManagedBeanWrapper
					.getManagedBean("MbUserInstsNAgentsContext");
			userInstAgentsBean.setUserId(user.getId());
			userInstAgentsBean.setUser(user);
			userInstAgentsBean.searchOrgStructTypes();
		}
		if (tab.equalsIgnoreCase("NOTESCONTEXTTAB")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesContextSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.USER);
			filterNote.setObjectId(user.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		}
		if (tab.equalsIgnoreCase("PRIVSCONTEXTTAB")) {
			MbUserPrivileges privsBean = (MbUserPrivileges) ManagedBeanWrapper
					.getManagedBean("MbUserPrivilegesContext");
			privsBean.setUserId(user.getId());
			privsBean.search();
		} else if (tab.equalsIgnoreCase("CONTACTSCONTEXTTAB")) {
			// get contacts for this institution
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
			        .getManagedBean("MbContactContextSearch");
			if (restoreState) {
				cont.restoreBean();
			} else {
				cont.fullCleanBean();
				cont.setBackLink(thisBackLink);
				cont.setObjectId(user.getPersonId());
				cont.setEntityType(EntityNames.PERSON);
			}
		}
		loadedTabs.put(tab, Boolean.TRUE);
	}
}

package ru.bpc.sv2.ui.administrative.users;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.security.SecurityUtils;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.system.MbSystemInfo;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.acm.MbLogin;
import ru.bpc.sv2.ui.administrative.groups.MbUserGroupsSearchBottom;
import ru.bpc.sv2.ui.administrative.roles.MbUserRolesSearch;
import ru.bpc.sv2.ui.application.MbObjectApplicationsSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.MbPerson;
import ru.bpc.sv2.ui.common.MbPersonsSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbUsersSearch")
public class MbUsersSearch extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
    private static final String ROLES_TAB = "rolesTab";
    private static final String INSTITUTIONS_TAB = "instsTab";
    private static final String NOTES_TAB = "notesTab";
    private static final String PRIVILEGES_TAB = "privsTab";
    private static final String CONTACTS_TAB = "contactsTab";
    private static final String APPLICATIONS_TAB = "applicationsTab";
	private static final String GROUPS_TAB = "groupsTab";

    private UsersDao usersDao = new UsersDao();
    private CommonDao commonDao = new CommonDao();
    private RolesDao rolesDao = new RolesDao();
    private OrgStructDao orgStructDao = new OrgStructDao();

    private User _activeUser;
    private User newUser;

    private User filter;
    private String backLink;
    private MbUsers userBean;
    private MbSystemInfo systemInfo;
    private boolean showModal;
    private boolean searchByPriv;
    private Integer privId;
    private Integer defaultInstId;
    private Integer defaultRoleId;
    private ArrayList<SelectItem> institutions;
    private String oldPassword;
    private String newPassword;
    private String newPasswordConfirmation;

    protected HashMap<String, Boolean> loadedTabs = new HashMap<>();
    private String needRerender;

    private final DaoDataModel<User> _usersSource;
    private final TableRowSelection<User> _itemSelection;

    private boolean _managingNew;
    private boolean updateOnCancel = false;


    private String instsTabElems;    // defines which elements on instsTab should be updated
    private String rerenderCancelList;

    private static final String COMPONENT_ID = "bottomRoleUsersTable";
    protected String tabName;
    private String parentSectionId;

    private String ctxItemEntityType;
    private ContextType ctxType;

    public MbUsersSearch() {
        tabName = "detailsTab";
        pageLink = "admin|manage_users|list_users";
        userBean = ManagedBeanWrapper.getManagedBean("MbUsers");
        systemInfo = ManagedBeanWrapper.getManagedBean("MbSystemInfo");
        searchByPriv = false;
        thisBackLink = "acm_users";

        restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
        if (restoreBean == null || !restoreBean) {
            clearBeansState();
            restoreBean = Boolean.FALSE;
        } else {
            _activeUser = userBean.getUser();
            newUser = userBean.getNewUser();
            backLink = userBean.getBackLink();
            searching = userBean.isSearching();
            pageNumber = userBean.getPageNum();
            tabName = userBean.getTabName();
            defaultInstId = userBean.getDefaultInst();
            defaultRoleId = userBean.getDefaultRole();
            _managingNew = userBean.isManagingNew();
            rowsNum = userBean.getRowsNum();
            loadTab(tabName, true);
            FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
            if (userBean.isPersonNeeded()) {
                showModal = true;
                setPersonFromPersonBean();
                userBean.setPersonNeeded(false);
            }
        }
        _usersSource = new DaoDataModel<User>() {
            private static final long serialVersionUID = 1L;

            @Override
            protected User[] loadDaoData(SelectionParams params) {
                if (restoreBean) {
                    FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
                    if (userBean.getUsersList() != null) {
                        List<User> usersList = userBean.getUsersList();
                        userBean.setUsersList(null);
                        return usersList.toArray(new User[usersList.size()]);
                    }
                }
                if (!isSearching())
                    return new User[0];
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    if (searchByPriv)
                        return usersDao.getUsersByPriv(userSessionId, params);
                    return usersDao.getUsers(userSessionId, params);
                } catch (Exception e) {
                    setDataSize(0);
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
                return new User[0];
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (restoreBean && userBean.getUsersList() != null) {
                    return userBean.getNumberOfUser();
                }
                if (!isSearching())
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    if (searchByPriv)
                        return usersDao.getUsersByPrivCount(userSessionId, params);
                    return usersDao.getUsersCount(userSessionId, params);
                } catch (Exception e) {
                    logger.error("", e);
                    FacesUtils.addMessageError(e);
                }
                return 0;
            }
        };

        _itemSelection = new TableRowSelection<>(null, _usersSource);
    }

    public DaoDataModel<User> getUsers() {
        return _usersSource;
    }

    public User getActiveUser() {
        return _activeUser;
    }

    public void setActiveUser(User activeUser) {
        _activeUser = activeUser;
    }

    public SimpleSelection getItemSelection() {
        if (_activeUser == null && _usersSource.getRowCount() > 0) {
            _usersSource.setRowIndex(0);
            SimpleSelection selection = new SimpleSelection();
            _activeUser = (User) _usersSource.getRowData();
            selection.addKey(_activeUser.getModelId());
            _itemSelection.setWrappedSelection(selection);
            userBean.setUser(_activeUser);
            setInfo();
        } else if (_activeUser != null && _usersSource.getRowCount() > 0) {
            SimpleSelection selection = new SimpleSelection();
            selection.addKey(_activeUser.getModelId());
            _itemSelection.setWrappedSelection(selection);
            _activeUser = _itemSelection.getSingleSelection();
            userBean.setUser(_activeUser);
        }
        return _itemSelection.getWrappedSelection();
    }

    public void setItemSelection(SimpleSelection selection) {
        _itemSelection.setWrappedSelection(selection);
        _activeUser = _itemSelection.getSingleSelection();
        userBean.setUser(_activeUser);
        setInfo();
    }

    public void setInfo() {
        if (_activeUser != null) {
            MbPersonsSearch personBean = ManagedBeanWrapper
                    .getManagedBean("MbPersonsSearch");
            personBean.setActivePerson(_activeUser.getPerson());

            MbFlexFieldsDataSearch flexible = ManagedBeanWrapper
                    .getManagedBean("MbFlexFieldsDataSearch");
            FlexFieldData filterFlex = new FlexFieldData();
            filterFlex.setEntityType(EntityNames.USER);
            filterFlex.setObjectId(_activeUser.getId().longValue());
            flexible.setFilter(filterFlex);
            flexible.search();
        }
        loadedTabs.clear();
        loadTab(getTabName(), false);
    }

    public void clearState() {
        _activeUser = null;
        _itemSelection.clearSelection();
        _usersSource.flushCache();
        loadedTabs.clear();
        clearBeansState();
    }

    public void clearBeansState() {
        MbPersonsSearch personBean = ManagedBeanWrapper
                .getManagedBean("MbPersonsSearch");
        personBean.setActivePerson(new Person());
        personBean.clearBean();

        MbUserInstsNAgents userInstsBean = ManagedBeanWrapper
                .getManagedBean("MbUserInstsNAgents");
        userInstsBean.setUserId(null);
        userInstsBean.searchOrgStructTypes();

        MbUserAgents userAgentsBean = ManagedBeanWrapper
                .getManagedBean("MbUserAgents");
        userAgentsBean.setUserId(null);
        userAgentsBean.searchAgents();

        MbNotesSearch notesSearch = ManagedBeanWrapper
                .getManagedBean("MbNotesSearch");
        notesSearch.clearFilter();

        MbUserPrivileges privsBean = ManagedBeanWrapper
                .getManagedBean("MbUserPrivileges");
        privsBean.setUserId(null);
        privsBean.clearBean();

        MbFlexFieldsDataSearch flexible = ManagedBeanWrapper
                .getManagedBean("MbFlexFieldsDataSearch");
        flexible.clearFilter();

        MbUserRolesSearch userRoles = ManagedBeanWrapper
                .getManagedBean(MbUserRolesSearch.class);
        userRoles.setUserId(null);
        userRoles.clearFilter();
    }

    public void createUser() {
        newUser = new User();
        _managingNew = true;
        defaultInstId = null;
        defaultRoleId = null;
    }

    public void editUser() {
        try {
            newUser = _activeUser.clone();
        } catch (CloneNotSupportedException e) {
            newUser = _activeUser;
            logger.error("", e);
        }
        userBean.setNewUser(newUser);
        userBean.setManagingNew(false);

        // may be there ought to be something else?
        // setActiveUser( _activeUser );
        userBean.setSearching(isSearching());
        _managingNew = false;
    }

    public void save() {
        String password = newUser.getPassword();
        if (newUser.getPersonId() == null) {
            FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
                    "ru.bpc.sv2.ui.bundles.Acm", "need_person")));
            return;
        }

        try {
            if (_managingNew) {
                boolean passwordChangeNeeded = newUser.isPasswordChangeNeeded();

                List<String> errors = SecurityUtils.validatePassword(password);
                if (!errors.isEmpty()) {
                    for (String error : errors) {
                        FacesUtils.addMessageError(error);
                    }
                    return;
                }

                newUser.setPassword(SecurityUtils.encodePassword(password));
                newUser = usersDao.createUser(userSessionId, newUser, defaultInstId.longValue());

                // Adding of default agent
                Integer defaultAgentId = orgStructDao.getDefaultAgentId(userSessionId, defaultInstId);
                Agent agent = new Agent();
                agent.setId(defaultAgentId.longValue());
                agent.setDefaultForUser(true);
                agent.setAssignedToUser(true);
                Agent[] agents = new Agent[]{agent};
                usersDao.addAgentsToUser(userSessionId, newUser, agents);
                // Adding of default role
                if (defaultRoleId != null) {
                    ComplexRole[] roles = new ComplexRole[1];
                    ComplexRole role = new ComplexRole();
                    role.setId(defaultRoleId);
                    roles[0] = role;
                    rolesDao.addRolesToUser(userSessionId, newUser.getId(), roles);
                }
                _itemSelection.addNewObjectToList(newUser);

                if(passwordChangeNeeded){
                    usersDao.avoidExpireDate(userSessionId, newUser);
                }
            }
            userBean.setPersonNeeded(false);

            _activeUser = newUser;
            setInfo();
            setShowModal(false);

        } catch (Exception e) {
            String exceptionMessage = e.getMessage();
            if (exceptionMessage == null || exceptionMessage.isEmpty()) {
                FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "add_user_error"));
            } else {
                FacesUtils.addMessageError(e);
            }
            logger.error("", e);
        }
    }

    public void cancel() {
//		setShowModal(false);
    }

    public String selectPerson() {
        userBean.setPersonNeeded(true);
        userBean.setNewUser(newUser);
        userBean.setUser(_activeUser);
        userBean.setManagingNew(_managingNew);
        userBean.setBackLink(backLink);
        userBean.setDefaultInst(defaultInstId);
        userBean.setDefaultRole(defaultRoleId);
        userBean.setSearching(searching);
        userBean.setTabName(tabName);
        userBean.setPageNum(pageNumber);
        userBean.setUsersList(_usersSource.getActivePage());
        userBean.setNumberOfUser(_usersSource.getDataSize());

        HashMap<String, Object> queueFilter = new HashMap<>();
        queueFilter.put("backLink", thisBackLink);
        addFilterToQueue("MbPersonsSearch", queueFilter);

        return "selectPerson";
    }

    public void setPersonFromPersonBean() {
        MbPerson pers = ManagedBeanWrapper.getManagedBean("MbPerson");
        if (pers.getPerson().getPersonId() != null) {
            newUser.setPersonId(pers.getPerson().getPersonId());
            newUser.setPerson(pers.getPerson());
        }
        if (FacesUtils.getSessionMapValue("updateOnCancel") != null) {
            updateOnCancel = (Boolean) FacesUtils.getSessionMapValue("updateOnCancel");
        }

    }

    public void blockUser() {
        try {
            User user = usersDao.blockUser(userSessionId, _activeUser.getId());
            _usersSource.replaceObject(_activeUser, user);
            _activeUser = user;
        } catch (Exception ee) {
            FacesUtils.addMessageError(ee);
            logger.error("", ee);
        }
    }

    public void unblockUser() {
        try {
            User user = usersDao.unblockUser(userSessionId, _activeUser.getId());
            _usersSource.replaceObject(_activeUser, user);
            _activeUser = user;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void changePassword() {
        if (ManagedBeanWrapper.getManagedBean(MbLogin.class).changePassword(_activeUser.getName(), oldPassword, newPassword, newPasswordConfirmation)) {
            oldPassword = null;
            newPassword = null;
            newPasswordConfirmation = null;
        }
    }

    public void changeAuthScheme() {
        usersDao.changeUserAuthScheme(userSessionId, _activeUser.getId(), _activeUser.getAuthScheme());
    }

    public void search() {
        clearState();
        clearBeansState();
        setSearching(true);
    }

    public void setFilters() {
        filters = new ArrayList<>();

        Filter paramFilter = new Filter();
        paramFilter.setElement("lang");
        paramFilter.setOp(Operator.eq);
        paramFilter.setValue(curLang);
        filters.add(paramFilter);

        if (getFilter().getStatus() != null && !getFilter().getStatus().equals("")) {
            paramFilter = new Filter();
            paramFilter.setElement("status");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(getFilter().getStatus());
            filters.add(paramFilter);
        }
        if (getFilter().getName() != null && !getFilter().getName().equals("")) {
            paramFilter = new Filter();
            paramFilter.setElement("name");
            paramFilter.setOp(Operator.like);
            paramFilter.setValue(getFilter().getName().toUpperCase().replaceAll("[*]", "%")
                    .replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
        if (getFilter().getPerson().getSurname() != null
                && !getFilter().getPerson().getSurname().equals("")) {
            paramFilter = new Filter();
            paramFilter.setElement("surname");
            paramFilter.setOp(Operator.like);
            paramFilter.setValue(getFilter().getPerson().getSurname().toUpperCase().replaceAll(
                    "[*]", "%").replaceAll("[?]", "_"));
            filters.add(paramFilter);
        }
        if (searchByPriv) {
            if (privId != null) {
                paramFilter = new Filter();
                paramFilter.setElement("privId");
                paramFilter.setOp(Operator.eq);
                paramFilter.setValue(privId.toString());
                filters.add(paramFilter);
            }
        }
    }

    public User getFilter() {
        if (filter == null)
            filter = new User();
        return filter;
    }

    public void setFilter(User filter) {
        this.filter = filter;
    }

    public String getBackLink() {
        return backLink;
    }

    public void setBackLink(String backLink) {
        this.backLink = backLink;
    }

    public boolean isShowModal() {
        return showModal;
    }

    public void setShowModal(boolean showModal) {
        this.showModal = showModal;
    }

    public void setSearching(boolean searching) {
        this.searching = searching;
        userBean.setSearching(searching);
    }

    public ArrayList<SelectItem> getStatuses() {
        return getDictUtils().getArticles(DictNames.USER_STATUSES, true, false);
    }

    public boolean isSearchByPriv() {
        return searchByPriv;
    }

    public void setSearchByPriv(boolean searchByPriv) {
        this.searchByPriv = searchByPriv;
    }

    public Integer getPrivId() {
        return privId;
    }

    public void setPrivId(Integer privId) {
        this.privId = privId;
    }

    public void changeLanguage(ValueChangeEvent event) {
        if (_activeUser != null) {
            String lang = (String) event.getNewValue();
            if (lang != null) {
                try {
                    _activeUser.setPerson(commonDao.getPersonById(userSessionId, _activeUser
                            .getPersonId(), lang));
                } catch (DataAccessException e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
            }
        }
    }

    public boolean isManagingNew() {
        return _managingNew;
    }

    public void setManagingNew(boolean managingNew) {
        _managingNew = managingNew;
    }

    public void clearFilter() {
        _activeUser = null;
        filter = new User();
        _usersSource.flushCache();
        searching = false;

        clearState();
    }

    public ArrayList<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
        }
        if (institutions == null)
            institutions = new ArrayList<>();
        return institutions;
    }

    public ArrayList<SelectItem> getRoles() {
	    ArrayList<SelectItem> roles = null;

        Filter[] filters = new Filter[1];
        filters[0] = new Filter();
        filters[0].setElement("lang");
        filters[0].setValue(curLang);

        SelectionParams params = new SelectionParams();
        params.setRowIndexEnd(-1);
        params.setFilters(filters);
        try {
            ComplexRole[] rolesList = rolesDao.getRoles(userSessionId, params);
            roles = new ArrayList<>(rolesList.length);
            for (ComplexRole role : rolesList) {
                roles.add(new SelectItem(role.getId(), role.getShortDesc(), role.getFullDesc()));
            }
        } catch (Exception e) {
            logger.error("", e);
            if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
                FacesUtils.addMessageError(e);
            }
        }

        if (roles == null)
            roles = new ArrayList<>(0);

        return roles;
    }

    public ArrayList<SelectItem> getWebAuthSchemes() {
        return (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.WEB_AUTH_SCHEME);
    }

    public void setPageNumber(int pageNumber) {
        this.pageNumber = pageNumber;
        userBean.setPageNum(pageNumber);
    }

    public void setRowsNum(int rowsNum) {
        this.rowsNum = rowsNum;
        userBean.setRowsNum(rowsNum);
    }

    public void showPerson() {
        MbPersonsSearch personBean = ManagedBeanWrapper
                .getManagedBean("MbPersonsSearch");
        personBean.setActivePerson(_activeUser.getPerson());
        personBean.viewPerson();
    }

    public void editPerson() {
        MbPersonsSearch personBean = ManagedBeanWrapper
                .getManagedBean("MbPersonsSearch");
        personBean.setDetailPerson(_activeUser.getPerson());
        personBean.setExtObjectSource(_usersSource);
        personBean.editPerson();
    }

    public String getTabName() {
        return tabName;
    }

    public void setTabName(String tabName) {
        needRerender = null;
        userBean.setTabName(tabName);
        this.tabName = tabName;

        Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

        if (isLoadedCurrentTab == null) {
            isLoadedCurrentTab = Boolean.FALSE;
        }

        if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
            return;
        }

        loadTab(tabName, false);

        if (tabName.equalsIgnoreCase("ROLESTAB")) {
            MbUserRolesSearch userRolesBean = ManagedBeanWrapper
                    .getManagedBean("MbUserRolesSearch");
            userRolesBean.setTabName(tabName);
            userRolesBean.setParentSectionId(getSectionId());
            userRolesBean.setTableState(getSateFromDB(userRolesBean.getComponentId()));
        } else if (tabName.equalsIgnoreCase("PRIVSTAB")) {
            MbUserPrivileges privsBean = ManagedBeanWrapper
                    .getManagedBean("MbUserPrivileges");
            privsBean.setTabName(tabName);
            privsBean.setParentSectionId(getSectionId());
            privsBean.setTableState(getSateFromDB(privsBean.getComponentId()));
        }
    }

    private void loadTab(String tab, boolean restoreState) {
        if (tab == null || _activeUser == null) {
            return;
        }
        if (tab.equalsIgnoreCase(ROLES_TAB)) {
            MbUserRolesSearch bean = ManagedBeanWrapper.getManagedBean(MbUserRolesSearch.class);
            bean.setFilter(new ComplexRole());
            bean.setUserId(_activeUser.getId());
            bean.setBackLink(thisBackLink);
            bean.search();
            needRerender = tab;
        } else if (tab.equalsIgnoreCase(INSTITUTIONS_TAB)) {
            MbUserInstsNAgents bean = ManagedBeanWrapper.getManagedBean(MbUserInstsNAgents.class);
            bean.setUserId(_activeUser.getId());
            bean.setUser(_activeUser);
            bean.searchOrgStructTypes();
            needRerender = instsTabElems;
        } else if (tab.equalsIgnoreCase(NOTES_TAB)) {
            MbNotesSearch bean = ManagedBeanWrapper.getManagedBean(MbNotesSearch.class);
            ObjectNoteFilter filterNote = new ObjectNoteFilter();
            filterNote.setEntityType(EntityNames.USER);
            filterNote.setObjectId(_activeUser.getId().longValue());
            bean.setFilter(filterNote);
            bean.search();
            needRerender = tab;
        } else if (tab.equalsIgnoreCase(PRIVILEGES_TAB)) {
            MbUserPrivileges bean = ManagedBeanWrapper.getManagedBean(MbUserPrivileges.class);
            bean.setUserId(_activeUser.getId());
            bean.search();
            needRerender = tab;
        } else if (tab.equalsIgnoreCase(CONTACTS_TAB)) {
            MbContactSearch bean = ManagedBeanWrapper.getManagedBean(MbContactSearch.class);
            if (restoreState) {
                bean.restoreBean();
            } else {
                bean.fullCleanBean();
                bean.setBackLink(thisBackLink);
                bean.setObjectId(_activeUser.getId().longValue());
                bean.setPersonId(_activeUser.getPersonId());
                bean.setEntityType(EntityNames.USER);
            }
        } else if (tab.equalsIgnoreCase(APPLICATIONS_TAB)) {
            MbObjectApplicationsSearch bean = ManagedBeanWrapper.getManagedBean(MbObjectApplicationsSearch.class);
            bean.setObjectId(_activeUser.getId().longValue());
            bean.setEntityType(EntityNames.USER);
            bean.search();
            needRerender = tab;
        } else if (tab.equalsIgnoreCase(GROUPS_TAB)) {
	        MbUserGroupsSearchBottom bean = ManagedBeanWrapper.getManagedBean(MbUserGroupsSearchBottom.class);
	        bean.clearFilter();
	        bean.setUserId(_activeUser.getId());
	        bean.setInstIds(usersDao.getUserInstitionIds(userSessionId, _activeUser.getId()));
	        bean.search();
	        needRerender = tab;
        }
        needRerender = tab;
        loadedTabs.put(tab, Boolean.TRUE);
    }

    public List<String> getRerenderList() {
	    List<String> rerenderList = new ArrayList<>();
        if (needRerender != null) {
            rerenderList.add(needRerender);
        }
        rerenderList.add(tabName);
        rerenderList.add("err_ajax");
        return rerenderList;
    }

    public HashMap<String, Boolean> getLoadedTabs() {
        return loadedTabs;
    }

    public User getNewUser() {
        return newUser;
    }

    public void setNewUser(User newUser) {
        this.newUser = newUser;
    }

    public Integer getDefaultInstId() {
        return defaultInstId;
    }

    public void setDefaultInstId(Integer defaultInstId) {
        this.defaultInstId = defaultInstId;
    }

    public Integer getDefaultRoleId() {
        return defaultRoleId;
    }

    public void setDefaultRoleId(Integer defaultRoleId) {
        this.defaultRoleId = defaultRoleId;
    }

    public String getInstsTabElems() {
        return instsTabElems;
    }

    public void setInstsTabElems(String instsTabElems) {
        this.instsTabElems = instsTabElems;
    }

    public String getElemsToUpdate() {
        if (tabName.equalsIgnoreCase("instsTab")) {
            return instsTabElems;
        }
        return tabName;
    }

    public Logger getLogger() {
        return logger;
    }

    public String getComponentId() {
        if (parentSectionId != null && tabName != null) {
            return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
        } else {
            return "1080:mainTable";
        }
    }

    public void keepTabName(String tabName) {
        this.tabName = tabName;
    }

    public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public String getSectionId() {
        return SectionIdConstants.ADMIN_PERMISSION_USER;
    }

    public String getCtxItemEntityType() {
        return ctxItemEntityType;
    }

    public void setCtxItemEntityType() {
        MbContextMenu ctxBean = ManagedBeanWrapper.getManagedBean("MbContextMenu");
        String ctx = ctxBean.getEntityType();
        if (ctx == null || !ctx.equals(this.ctxItemEntityType)) {
            ctxType = ContextTypeFactory.getInstance(ctx);
        }
        this.ctxItemEntityType = ctx;
    }

    public ContextType getCtxType() {
        if (ctxType == null) return null;
        Map<String, Object> map = new HashMap<>();
        if (_activeUser != null) {
            if (EntityNames.USER.equals(ctxItemEntityType)) {
                map.put("id", _activeUser.getId());
            }
        }

        ctxType.setParams(map);
        return ctxType;
    }

    public boolean isForward() {
        return !ctxItemEntityType.equals(EntityNames.USER);
    }

    public void initUserPanel() {
        restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
        if (restoreBean == null || !restoreBean) {
            clearBeansState();
            restoreBean = Boolean.FALSE;
        } else {
            _activeUser = userBean.getUser();
            newUser = userBean.getNewUser();
            backLink = userBean.getBackLink();
            searching = userBean.isSearching();
            pageNumber = userBean.getPageNum();
            tabName = userBean.getTabName();
            defaultInstId = userBean.getDefaultInst();
            defaultRoleId = userBean.getDefaultRole();
            _managingNew = userBean.isManagingNew();
            rowsNum = userBean.getRowsNum();
            loadTab(tabName, true);
            FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
            if (userBean.isPersonNeeded()) {
                showModal = true;
                setPersonFromPersonBean();
                userBean.setPersonNeeded(false);
            }
        }
    }

    public String getOldPassword() {
        return oldPassword;
    }

    public void setOldPassword(String oldPassword) {
        this.oldPassword = oldPassword;
    }

    public String getNewPassword() {
        return newPassword;
    }

    public void setNewPassword(String newPassword) {
        this.newPassword = newPassword;
    }

    public String getNewPasswordConfirmation() {
        return newPasswordConfirmation;
    }

    public void setNewPasswordConfirmation(String newPasswordConfirmation) {
        this.newPasswordConfirmation = newPasswordConfirmation;
    }

    public String getRerenderCancelList() {
        StringBuilder result = new StringBuilder();
        result.append("userDiv");
        if (updateOnCancel) {
            result.append(", usersFormBtnForm, usersForm, workplacePanel");
            _usersSource.flushCache();
        }
        rerenderCancelList = result.toString();
        return rerenderCancelList;
    }

    public void setRerenderCancelList(String rerenderCancelList) {
        this.rerenderCancelList = rerenderCancelList;
    }

    @Override
    protected void applySectionFilter(Integer filterId) {
        try {
            FilterFactory factory = ManagedBeanWrapper
                    .getManagedBean("filterFactory");
            Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
            sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
            if (filterRec != null) {
                filter = new User();
                if (filterRec.get("name") != null) {
                    filter.setName(filterRec.get("name"));
                }
                if (filterRec.get("surname") != null) {
                    filter.getPerson().setSurname(filterRec.get("surname"));
                }
                if (filterRec.get("status") != null) {
                    filter.setStatus(filterRec.get("status"));
                }
            }
            if (searchAutomatically) {
                search();
            }
            sectionFilterModeEdit = true;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    @Override
    public void saveSectionFilter() {
        try {
            FilterFactory factory = ManagedBeanWrapper
                    .getManagedBean("filterFactory");

            Map<String, String> filterRec = new HashMap<>();
            filter = getFilter();
            if (filter.getName() != null) {
                filterRec.put("name", filter.getName());
            }
            if (filter.getPerson().getSurname() != null) {
                filterRec.put("surname", filter.getPerson().getSurname());
            }
            if (filter.getStatus() != null) {
                filterRec.put("status", filter.getStatus());
            }
            sectionFilter = getSectionFilter();
            sectionFilter.setRecs(filterRec);

            factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
            selectedSectionFilter = sectionFilter.getId();
            sectionFilterModeEdit = true;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public void unlockUser() {
        if (_activeUser != null) {
            try {
                usersDao.resetLockout(userSessionId, _activeUser);
                search();
            } catch (Exception e) {
                FacesUtils.addMessageError(e);
                logger.error("", e);
            }
        }
    }

    public boolean isLdapActive() {
    	try {
		    return Boolean.TRUE.equals(SettingsCache.getInstance().getParameterBooleanValue(SettingsConstants.LDAP_ACTIVE));
	    } catch (Exception e) {
		    FacesUtils.addMessageError(e);
		    logger.error("", e);
	    }
    	return false;
    }
}

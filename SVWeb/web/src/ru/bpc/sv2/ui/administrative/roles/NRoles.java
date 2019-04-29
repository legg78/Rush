package ru.bpc.sv2.ui.administrative.roles;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.administrative.roles.PrivilegeGroupNode;
import ru.bpc.sv2.administrative.roles.PrivilegeNode;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.notifications.Scheme;
import ru.bpc.sv2.ui.administrative.users.MbUsers;
import ru.bpc.sv2.ui.administrative.users.MbUsersSearchBottom;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "roles")
public class NRoles extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private RolesDao _rolesDao = new RolesDao();

	private NotificationsDao _notificationsDao = new NotificationsDao();

	private ComplexRole _activeRole;
	private ComplexRole newRole;
	private ComplexRole _activeSubrole;
	private ComplexRole detailRole;

	private ComplexRole roleFilter;
	private List<Filter> roleFilters;

	private ComplexRole subroleFilter;
	private List<Filter> subroleFilters;

	private String backLink;
	private boolean selectMode;
	private boolean addRolesToUser;
	private boolean addRolesToProcess;
	private boolean addRolesToReport;
	private boolean addRolesToObject;
	private boolean showSubroles;
	private boolean slaveMode = false;

	private PrivilegeGroupNode _rolesTree = null;

	private final DaoDataModel<ComplexRole> _rolesSource;
	private final DaoDataModel<ComplexRole> _subrolesSource;

	private String tabName;

	private Long objectId; // id of any master object (long can be converted
	private String entityType;
	// into any needed integer)

	private final TableRowSelection<ComplexRole> _roleSelection;

	private final TableRowSelection<ComplexRole> _subroleSelection;

	private String _privilegeFilteringName;

	private boolean _managingNew;
	private MbRoles roleBean;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	private String parentSectionId;

	
	public NRoles() {
		thisBackLink = "admin|manage_roles|list";
		pageLink = "admin|manage_roles|list";
		
		roleBean = (MbRoles) ManagedBeanWrapper.getManagedBean("MbRoles");
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean == null || !restoreBean) {
			tabName = "detailsTab";
		} else {
			_activeRole = roleBean.getRole();
			if (_activeRole != null) {
				try {
					detailRole = (ComplexRole) _activeRole.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
			backLink = roleBean.getBackLink();
			searching = roleBean.isSearching();
			roleFilter = roleBean.getRoleFilter();
			rowsNum = roleBean.getRowsNum();
			pageNumber = roleBean.getPageNumber();
			tabName = roleBean.getTabName();
			selectMode = roleBean.isSelectMode();
			addRolesToProcess = roleBean.isAddRolesToProcess();
			addRolesToUser = roleBean.isAddRolesToUser();
			addRolesToReport = roleBean.isAddRolesToReport();
			objectId = roleBean.getObjectId();

			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		}

		_rolesSource = new DaoDataModel<ComplexRole>() {
			@Override
			protected ComplexRole[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ComplexRole[0];
				try {
					setRolesFilters();
					params.setFilters(roleFilters.toArray(new Filter[roleFilters.size()]));

					if (addRolesToUser || addRolesToProcess || addRolesToReport) {
						return _rolesDao.getRolesUnassignedToObject(userSessionId, params);
					}
					return _rolesDao.getRoles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ComplexRole[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setRolesFilters();
					params.setFilters(roleFilters.toArray(new Filter[roleFilters.size()]));

					if (addRolesToUser || addRolesToProcess || addRolesToReport) {
						return _rolesDao.getRolesUnassignedToObjectCount(userSessionId, params);
					}
					return _rolesDao.getRolesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_subrolesSource = new DaoDataModel<ComplexRole>() {
			@Override
			protected ComplexRole[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ComplexRole[0];
				try {
					setSubrolesFilters();
					params.setFilters(subroleFilters.toArray(new Filter[subroleFilters.size()]));

					if (addRolesToUser || addRolesToProcess || addRolesToReport) {
						return _rolesDao.getRolesUnassignedToObject(userSessionId, params);
					}
					return _rolesDao.getRoles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ComplexRole[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setSubrolesFilters();
					params.setFilters(subroleFilters.toArray(new Filter[subroleFilters.size()]));

					if (addRolesToUser || addRolesToProcess || addRolesToReport) {
						return _rolesDao.getRolesUnassignedToObjectCount(userSessionId, params);
					}
					return _rolesDao.getRolesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		if (_activeRole != null) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeRole.getModelId());
			_roleSelection = new TableRowSelection<ComplexRole>(selection, _rolesSource);
			setInfo();
		} else {
			_roleSelection = new TableRowSelection<ComplexRole>(null, _rolesSource);
		}
		_subroleSelection = new TableRowSelection<ComplexRole>(null, _subrolesSource);
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("roles");
		if (queueFilter==null)
			return;
		setSelectMode(true);
		clearFilter();
		if (queueFilter.containsKey("selectMode")){
			setSelectMode(((String)queueFilter.get("selectMode")).equals("true"));
		}
		if (queueFilter.containsKey("objectId")){
			setObjectId((Long)queueFilter.get("objectId"));
		}
		if (queueFilter.containsKey("addRolesToProcess")){
			setAddRolesToProcess(((String)queueFilter.get("addRolesToProcess")).equals("true"));
		}
		if (queueFilter.containsKey("setAddRolesToReport")){
			setAddRolesToReport(((String)queueFilter.get("setAddRolesToReport")).equals("true"));
		}
		if (queueFilter.containsKey("setAddRolesToObject")){
			setAddRolesToObject(((String)queueFilter.get("setAddRolesToObject")).equals("true"));
		}
		if (queueFilter.containsKey("backLink")){
			setBackLink((String)queueFilter.get("backLink"));
		}
		if (queueFilter.containsKey("entityType")){
			setEntityType((String)queueFilter.get("entityType"));
		}
		search();
	}

	public DaoDataModel<ComplexRole> getRoles() {
		return _rolesSource;
	}

	public ComplexRole getActiveRole() {
		return _activeRole;
	}

	public void setActiveRole(ComplexRole activeRole) {
		_activeRole = activeRole;
	}

	public SimpleSelection getRoleSelection() {
		try {
			if (_activeRole == null && _rolesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeRole != null && _rolesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeRole.getModelId());
				_roleSelection.setWrappedSelection(selection);
				_activeRole = _roleSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _roleSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_rolesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRole = (ComplexRole) _rolesSource.getRowData();
		selection.addKey(_activeRole.getModelId());
		_roleSelection.setWrappedSelection(selection);
		if (_activeRole != null) {
			setInfo();
			detailRole = (ComplexRole) _activeRole.clone();
		}
	}

	public void setRoleSelection(SimpleSelection selection) {
		try {
			_roleSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_roleSelection.getSingleSelection() != null
					&& !_roleSelection.getSingleSelection().getId().equals(_activeRole.getId())) {
				changeSelect = true;
			}
			_activeRole = _roleSelection.getSingleSelection();
			setInfo();
			if (changeSelect) {
				detailRole = (ComplexRole) _activeRole.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setInfo() {
		if (_activeRole != null && !slaveMode) {
			loadedTabs.clear();
			roleBean.setRole(_activeRole);
			roleBean.setPageNumber(pageNumber);
			roleBean.setRowsNum(rowsNum);
			roleBean.setSelectMode(selectMode);
			roleBean.setBackLink(backLink);
			roleBean.setAddRolesToProcess(addRolesToProcess);
			roleBean.setAddRolesToReport(addRolesToReport);
			roleBean.setAddRolesToUser(addRolesToUser);
			roleBean.setObjectId(objectId);
			loadTab(tabName);
		}
	}

	public DaoDataModel<ComplexRole> getSubroles() {
		return _subrolesSource;
	}

	public ComplexRole getActiveSubrole() {
		return _activeSubrole;
	}

	public void setActiveSubrole(ComplexRole activeSubrole) {
		_activeSubrole = activeSubrole;
	}

	public SimpleSelection getSubroleSelection() {
		return _subroleSelection.getWrappedSelection();
	}

	public void setSubroleSelection(SimpleSelection selection) {
		_subroleSelection.setWrappedSelection(selection);
		_activeSubrole = _subroleSelection.getSingleSelection();
	}

	public PrivilegeNode getRolesTree() {
		return _rolesTree;
	}

	public PrivilegeGroupNode getActivePrivilegeTree() {
		if (_activeRole == null) {
			return null;
		}
		PrivilegeGroupNode fullPrivTree = null;
		try {
			fullPrivTree = _rolesDao.getRoleSections(userSessionId, _activeRole.getId());
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return null;
		} finally {
		}

		return (PrivilegeGroupNode) (new NameAssignedPrivilegeSubtreeBuilder(fullPrivTree,
				_privilegeFilteringName)).createSubtree();
	}

	public String getPrivilegeFilteringName() {
		return _privilegeFilteringName;
	}

	public void setPrivilegeFilteringName(String privilegeFilteringName) {
		_privilegeFilteringName = privilegeFilteringName;
	}

	public void createRole() {
		curMode = NEW_MODE;
		newRole = new ComplexRole();
		newRole.setLang(userLang);
		curLang = newRole.getLang();
		_managingNew = true;
	}

	public void translateRole() {
		ComplexRole role = new ComplexRole();
		role.setName(_activeRole.getName());

		roleBean.setSearching(isSearching());
		roleBean.setRole(role);
		_managingNew = false;
	}

	public void editExistingRole() {
		curMode = EDIT_MODE;
		roleBean.setSearching(isSearching());
		try {
			newRole = detailRole.clone();
		} catch (CloneNotSupportedException e) {
			newRole = _activeRole;
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		_managingNew = false;
	}

	public void deleteRole() {
		try {
			_rolesDao.deleteRole(userSessionId, _activeRole.getId());
			roleBean.setRole(null);

			_activeRole = _roleSelection.removeObjectFromList(_activeRole);
			if (_activeRole == null) {
				clearBean();
			} else {
				setInfo();
				detailRole = (ComplexRole) _activeRole.clone();
			}
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}

	}

	// private List<Integer> getSelectedPrivileges(PrivilegeGroupNode
	// privilegeNode) {
	// List<Integer> innerPrivileges = new ArrayList<Integer>();
	//
	// for (PrivilegeGroupNode child : privilegeNode.getMembers()) {
	// innerPrivileges.addAll(getSelectedPrivileges(child));
	// }
	//
	// for (PrivilegeNode child : privilegeNode.getPrivileges()) {
	// if (child.isAssigned()) {
	// innerPrivileges.add(child.getId());
	// }
	// }
	//
	// return innerPrivileges;
	// }

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	private PrivilegeGroupNode getPriv() {
		return (PrivilegeGroupNode) Faces.var("priv");
	}

	public boolean getNodeHasChildren() {
		PrivilegeGroupNode privNode = getPriv();
		return (privNode != null) && privNode.getChilds().size() > 0;
	}

	/*
	 * public List<PrivilegeGroupNode> getPrivNodeChildren() { if (_activeRole
	 * != null) { PrivilegeGroupNode privNode = getPriv(); if (privNode == null)
	 * { PrivilegeGroupNode fullPrivTree = _rolesDao.getRoleSections(
	 * userSessionId, _activeRole.getId() ); return ((PrivilegeGroupNode)( new
	 * NameAssignedPrivilegeSubtreeBuilder( fullPrivTree,
	 * _privilegeFilteringName ) ).createSubtree()).getChilds();
	 * 
	 * } else { return privNode.getChilds(); }
	 * 
	 * } return new ArrayList<PrivilegeGroupNode>(); }
	 */

	public void setRolesFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;
		if (getRoleFilter().getShortDesc() != null && !getRoleFilter().getShortDesc().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getRoleFilter().getShortDesc().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getRoleFilter().getName() != null && !getRoleFilter().getName().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getRoleFilter().getName().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getRoleFilter().getPrivilege() != null && !getRoleFilter().getPrivilege().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("privilegeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getRoleFilter().getPrivilege().toString());
			filtersList.add(paramFilter);
		}

		if (addRolesToUser) {
			// When adding role to user we should find only those roles which
			// are not added to active user
			MbUsers userBean = (MbUsers) ManagedBeanWrapper.getManagedBean("MbUsers");
			User user = userBean.getUser();
			if (user != null) {
				paramFilter = new Filter();
				paramFilter.setElement("userId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(Integer.toString(user.getId()));
				filtersList.add(paramFilter);
			}
		} else if (addRolesToProcess) {
			// When adding role to process we should find only those roles which
			// are not added to active process
			paramFilter = new Filter();
			paramFilter.setElement("processId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(objectId.toString());
			filtersList.add(paramFilter);
		} else if (addRolesToReport) {
			paramFilter = new Filter();
			paramFilter.setElement("reportId");
			paramFilter.setValue(objectId.toString());
			filtersList.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		roleFilters = filtersList;
	}

	public void setSubrolesFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = null;
		if (getSubroleFilter().getShortDesc() != null
				&& !getSubroleFilter().getShortDesc().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getSubroleFilter().getShortDesc().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getSubroleFilter().getName() != null && !getSubroleFilter().getName().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getSubroleFilter().getName().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getSubroleFilter().getPrivilege() != null
				&& !getSubroleFilter().getPrivilege().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("privilegeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getSubroleFilter().getPrivilege().toString());
			filtersList.add(paramFilter);
		}

		if (addRolesToUser) {
			// When adding role to user we should find only those roles which
			// are not added to active user
			MbUsers userBean = (MbUsers) ManagedBeanWrapper.getManagedBean("MbUsers");
			User user = userBean.getUser();
			if (user != null) {
				paramFilter = new Filter();
				paramFilter.setElement("userId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(Integer.toString(user.getId()));
				filtersList.add(paramFilter);
			}
		} else if (addRolesToProcess) {
			// When adding role to process we should find only those roles which
			// are not added to active process
			paramFilter = new Filter();
			paramFilter.setElement("processId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(objectId.toString());
			filtersList.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		subroleFilters = filtersList;
	}

	public ComplexRole getSubroleFilter() {
		if (subroleFilter == null)
			subroleFilter = new ComplexRole();
		return subroleFilter;
	}

	public void setSubroleFilter(ComplexRole subroleFilter) {
		this.subroleFilter = subroleFilter;
	}

	public ComplexRole getRoleFilter() {
		if (roleFilter == null)
			roleFilter = new ComplexRole();
		return roleFilter;
	}

	public void setRoleFilter(ComplexRole roleFilter) {
		this.roleFilter = roleFilter;
	}

	public List<Filter> getRoleFilters() {
		return roleFilters;
	}

	public void setRoleFilters(List<Filter> roleFilters) {
		this.roleFilters = roleFilters;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String select() {
		roleBean.setRole(_activeRole);
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public String cancelSelect() {
		if (!showSubroles) {
			FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
			return backLink;
		}
		showSubroles = false;
		return "acm_roles";
	}

	public boolean isAddRolesToUser() {
		return addRolesToUser;
	}

	public void setAddRolesToUser(boolean addRolesToUser) {
		this.addRolesToUser = addRolesToUser;
	}

	public boolean isAddRolesToProcess() {
		return addRolesToProcess;
	}

	public void setAddRolesToProcess(boolean addRolesToProcess) {
		this.addRolesToProcess = addRolesToProcess;
	}

	public boolean isAddRolesToReport() {
		return addRolesToReport;
	}

	public void setAddRolesToReport(boolean addRolesToReport) {
		this.addRolesToReport = addRolesToReport;
	}
	
	public boolean isAddRolesToObject() {
		return addRolesToObject;
	}
	
	public void setAddRolesToObject(boolean addRolesToObject) {
		this.addRolesToObject = addRolesToObject;
	}

	public String addSelectedRolesToObject() {
		if (addRolesToUser) {
			addSelectedRolesToUser();
		} else if (addRolesToProcess) {
			addSelectedRolesToProcess();
		} else if (addRolesToReport) {
			addSelectedRolesToReport();
		} else if (addRolesToObject) {
			addSelectedRolesToEntityObject();
		}

		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	private void addSelectedRolesToEntityObject() {
		List<ComplexRole> rolesToAdd = _roleSelection.getMultiSelection();
		if (objectId != null) {
			try {
				_rolesDao.addRolesToEntityObject(userSessionId, objectId.intValue(), entityType,  rolesToAdd.toArray(new ComplexRole[rolesToAdd.size()]));
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
	}
	
	private void addSelectedRolesToReport() {
		List<ComplexRole> rolesToAdd = _roleSelection.getMultiSelection();
		if (objectId != null) {
			try {
				_rolesDao.addRolesToReport(userSessionId, objectId.intValue(), rolesToAdd
						.toArray(new ComplexRole[rolesToAdd.size()]));
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
	}

	private void addSelectedRolesToUser() {

		List<ComplexRole> rolesToAdd = _roleSelection.getMultiSelection();
		MbUsers userBean = (MbUsers) ManagedBeanWrapper.getManagedBean("MbUsers");
		User user = userBean.getUser();
		if (user != null) {
			try {
				_rolesDao.addRolesToUser(userSessionId, userBean.getUser().getId(), rolesToAdd
						.toArray(new ComplexRole[rolesToAdd.size()]));
			} catch (Exception ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
	}

	private void addSelectedRolesToProcess() {
		List<ComplexRole> rolesToAdd = _roleSelection.getMultiSelection();
		if (objectId != null) {
			try {
				_rolesDao.addRolesToProcess(userSessionId, objectId.intValue(), rolesToAdd
						.toArray(new ComplexRole[rolesToAdd.size()]));
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		roleBean.setSearching(searching);
	}

	public void search() {
		curLang = userLang;
		setSearching(true);
		roleBean.setRoleFilter(roleFilter);
		_rolesSource.flushCache();
		_activeRole = null;
		resetBeans();
	}

	public boolean isSlaveMode() {
		return slaveMode;
	}

	public void setSlaveMode(boolean slaveMode) {
		this.slaveMode = slaveMode;
	}

	public ArrayList<SelectItem> getPriviliges() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			Privilege[] privs = _rolesDao.getPrivsForCombo(userSessionId);
			for (Privilege priv : privs) {
				items.add(new SelectItem(priv.getId(), priv.getShortDesc()));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return items;
	}

	private void resetBeans() {
		MbRolePrivilegesSearch rolePrivsBean = (MbRolePrivilegesSearch) ManagedBeanWrapper
				.getManagedBean("MbRolePrivilegesSearch");
		rolePrivsBean.setPrivFilter(new Privilege());
		rolePrivsBean.setRoleId(null);
		rolePrivsBean.search();

		MbRoleSubrolesSearch roleSubrolesBean = (MbRoleSubrolesSearch) ManagedBeanWrapper
				.getManagedBean("MbRoleSubrolesSearch");
		roleSubrolesBean.setFilter(new ComplexRole());
		roleSubrolesBean.search();
	}

	public void searchSubroles() {
		setSearching(true);
		_subrolesSource.flushCache();
		_activeSubrole = null;
	}

	public String addSubrole() {
		this.showSubroles = true;
		return "acm_roles";
	}

	public boolean isShowSubroles() {
		return showSubroles;
	}

	public void setShowSubroles(boolean showSubroles) {
		this.showSubroles = showSubroles;
	}

	public String addSelectedSubrolesToRole() {

		List<ComplexRole> subrolesToAdd = _subroleSelection.getMultiSelection();
		if (_activeRole != null) {
			try {
				_rolesDao.addSubrolesToRole(userSessionId, _activeRole.getId(), subrolesToAdd
						.toArray(new ComplexRole[subrolesToAdd.size()]));
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
		MbRoleSubrolesSearch subrolesBean = (MbRoleSubrolesSearch) ManagedBeanWrapper
				.getManagedBean("MbRoleSubrolesSearch");
		subrolesBean.search();

		// clear role's privileges so that they can be reloaded 
		MbRolePrivilegesSearch privs = (MbRolePrivilegesSearch) ManagedBeanWrapper
				.getManagedBean("MbRolePrivilegesSearch");
		privs.clearBean();

		MbUsersSearchBottom usersSearchBottom = ManagedBeanWrapper.getManagedBean("MbUsersSearchBottom");
		usersSearchBottom.search();

		loadedTabs.clear();

		this.showSubroles = false;
		return "acm_roles";
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailRole = getNodeByLang(detailRole.getId(), curLang);
	}
	
	public ComplexRole getNodeByLang(Integer id, String lang) {
		if (_activeRole != null) {
			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(String.valueOf(id));
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(lang);
			filtersList.add(paramFilter);

			SelectionParams params = new SelectionParams();
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			try {
				ComplexRole[] roles = _rolesDao.getRoles(userSessionId, params);
				if (roles != null && roles.length > 0) {
					return roles[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public void clearBean() {
		_roleSelection.clearSelection();
		_activeRole = null;
		detailRole = null;
		_rolesSource.flushCache();
		resetBeans();
	}

	public void clearFilter() {
		curLang = userLang;
		roleFilter = new ComplexRole();
		roleBean.setRoleFilter(roleFilter);
		pageNumber = 1;

		clearBean();
		searching = false;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public ComplexRole getNewRole() {
		if (newRole == null) {
			newRole = new ComplexRole();
		}
		return newRole;
	}

	public void setNewRole(ComplexRole newRole) {
		this.newRole = newRole;
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void saveRole() {
		try {
			if (isNewMode()) {
				newRole = _rolesDao.createRole(userSessionId, newRole);
				detailRole = (ComplexRole) newRole.clone();
				_roleSelection.addNewObjectToList(newRole);
			} else {
				newRole = _rolesDao.updateRole(userSessionId, newRole);
				detailRole = (ComplexRole) newRole.clone();
				if (!userLang.equals(newRole.getLang())) {
					newRole = getNodeByLang(_activeRole.getId(), userLang);
				}
				_rolesSource.replaceObject(_activeRole, newRole);
			}
			_activeRole = newRole;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		roleBean.setTabName(tabName);
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
		
		if (tabName.equalsIgnoreCase("privsTab")) {
			MbRolePrivilegesSearch rolePrivsBean = (MbRolePrivilegesSearch) ManagedBeanWrapper
					.getManagedBean("MbRolePrivilegesSearch");
			rolePrivsBean.setTabName(tabName);
			rolePrivsBean.setParentSectionId(getSectionId());
			rolePrivsBean.setTableState(getSateFromDB(rolePrivsBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("usersTab")) {
			MbUsersSearchBottom usersSearchBottom = ManagedBeanWrapper.getManagedBean("MbUsersSearchBottom");
			usersSearchBottom.setTableState(getSateFromDB(usersSearchBottom.getComponentId()));
		}
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		
		if (_activeRole == null || _activeRole.getId() == null)
			return;

		if (tab.equalsIgnoreCase("subrolesTab")) {
			MbRoleSubrolesSearch roleSubrolesBean = (MbRoleSubrolesSearch) ManagedBeanWrapper
					.getManagedBean("MbRoleSubrolesSearch");
			ComplexRole subroleFilter = new ComplexRole();
			subroleFilter.setId(_activeRole.getId());
			roleSubrolesBean.fullCleanBean();
			roleSubrolesBean.setFilter(subroleFilter);
			roleSubrolesBean.search();
		} else if (tab.equalsIgnoreCase("privsTab")) {
			MbRoleSubrolesSearch roleSubrolesBean = (MbRoleSubrolesSearch) ManagedBeanWrapper
					.getManagedBean("MbRoleSubrolesSearch");
			MbRolePrivilegesSearch rolePrivsBean = (MbRolePrivilegesSearch) ManagedBeanWrapper
					.getManagedBean("MbRolePrivilegesSearch");
			rolePrivsBean.setPrivFilter(new Privilege());
			rolePrivsBean.setRoleId(_activeRole.getId());
			rolePrivsBean.setChildren(roleSubrolesBean.getSubrolesByRoleId(_activeRole.getId()));
			rolePrivsBean.setBackLink(thisBackLink);
			rolePrivsBean.search();
		} else if (tab.equalsIgnoreCase("usersTab")) {
			MbUsersSearchBottom usersSearchBottom = ManagedBeanWrapper.getManagedBean("MbUsersSearchBottom");
			usersSearchBottom.addObjectFilter(Filter.create(MbUsersSearchBottom.ROLE_ID_FILTER, _activeRole.getId().toString()));
			usersSearchBottom.setParentSectionId(getSectionId());
			usersSearchBottom.search();
		} /*else if (tab.equalsIgnoreCase("custEventsTab")) {
			MbCustomEvents events = (MbCustomEvents) ManagedBeanWrapper
					.getManagedBean("MbCustomEvents");
			events.fullCleanBean();
			events.getFilter().setObjectId(_activeRole.getId().longValue());
			events.getFilter().setEntityType(EntityNames.USER); // user custom events are used for roles
			events.setEventOwnerEntityType(EntityNames.ROLE); // but they are saved for roles not for users
			events.setNotifSchemeId(_activeRole.getNotifSchemeId() == null ? -1 : _activeRole
					.getNotifSchemeId());
			events.search();
		}*/
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
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

	public ArrayList<SelectItem> getNotifSchemes() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("schemeType");
		filters[1].setValue(ApplicationConstants.USER_SCHEME_TYPE);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			Scheme[] schemes = _notificationsDao.getSchemes(userSessionId, params);
			ArrayList<SelectItem> result = new ArrayList<SelectItem>(schemes.length);
			for (Scheme scheme : schemes) {
				result.add(new SelectItem(scheme.getId(), scheme.getName()));
			}

			return result;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}
	}

	public void confirmEditLanguage() {
		curLang = newRole.getLang();
		ComplexRole tmp = getNodeByLang(newRole.getId(), newRole.getLang());
		if (tmp != null) {
			newRole.setName(tmp.getName());
			newRole.setFullDesc(tmp.getFullDesc());
		}
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + MbUsersSearchBottom.COMPONENT_ID;
		} else {
			if (showSubroles) {
				return "1079:" + "mainTable1";
			} else {
				return "1079:" + "mainTable";
			}
		}
	}

	public Logger getLogger() {
		return logger;
	}

	public ComplexRole getDetailRole() {
		return detailRole;
	}

	public void setDetailRole(ComplexRole detailRole) {
		this.detailRole = detailRole;
	}
	
	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public String getTableState() {
		setParentSectionId(getSectionId());
		return super.getTableState();
	}
	
	public String getSectionId() {
		return SectionIdConstants.ADMIN_PERMISSION_ROLE;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}
	
	

}

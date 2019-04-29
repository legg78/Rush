package ru.bpc.sv2.ui.administrative.roles;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.administrative.users.MbUsers;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean(name = "bottomRoles")
public class NRolesBottom extends AbstractBean implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private RolesDao _rolesDao = new RolesDao();

	private ComplexRole _activeRole;

	private DictUtils dictUtils;
	private List<Filter> userFilters;

	private ComplexRole roleFilter;
	private List<Filter> roleFilters;

	private String backLink;
	private boolean selectMode;
	private boolean addRolesToUser;
	private boolean searching;
	private boolean slaveMode = false;

	private final DaoDataModel<ComplexRole> _rolesSource;

	private String curLang;
	private String defaultLang;

	private final TableRowSelection<ComplexRole> _roleSelection;

	private MbRoles roleBean;

	private Long userSessionId = null;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;

	public NRolesBottom() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();

		
		roleBean = (MbRoles) ManagedBeanWrapper.getManagedBean("MbRoles");
		curLang = defaultLang = SessionWrapper.getField("language");

		_rolesSource = new DaoDataModel<ComplexRole>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ComplexRole[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ComplexRole[0];
				try {
					setRolesFilters();
					params.setFilters(roleFilters.toArray(new Filter[roleFilters.size()]));

					if (addRolesToUser) {
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

					if (addRolesToUser) {
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
		_roleSelection = new TableRowSelection<ComplexRole>(null, _rolesSource);
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
		return _roleSelection.getWrappedSelection();
	}

	public void setRoleSelection(SimpleSelection selection) {
		_roleSelection.setWrappedSelection(selection);
		_activeRole = _roleSelection.getSingleSelection();
		roleBean.setRole(_activeRole);
	}

	/*
	 * private List<Integer> getSelectedPrivileges( PrivilegeGroupNode
	 * privilegeNode ) { List<Integer> innerPrivileges = new
	 * ArrayList<Integer>();
	 * 
	 * for ( PrivilegeGroupNode child : privilegeNode.getMembers() ) {
	 * innerPrivileges.addAll( getSelectedPrivileges( child ) ); }
	 * 
	 * for (PrivilegeNode child: privilegeNode.getPrivileges()) { if
	 * (child.isAssigned()) { innerPrivileges.add(child.getId()); } }
	 * 
	 * return innerPrivileges; }
	 */
	public void setRolesFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		
		filtersList.add(new Filter("lang", curLang));
		
		if (getRoleFilter().getPrivilege() != null && !getRoleFilter().getPrivilege().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("privilegeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getRoleFilter().getPrivilege().toString());
			filtersList.add(paramFilter);
		}

		if (addRolesToUser) { //When adding role to user we should find only those roles which are not added to active user
			MbUsers userBean = (MbUsers) ManagedBeanWrapper.getManagedBean("MbUsers");
			User user = userBean.getUser();
			if (user != null) {
				Filter paramFilter = new Filter();
				paramFilter.setElement("userId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(Integer.toString(user.getId()));
				filtersList.add(paramFilter);
			}
		}
		roleFilters = filtersList;
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

	public List<Filter> getPrivFilters() {
		return userFilters;
	}

	public void setPrivFilters(List<Filter> privFilters) {
		this.userFilters = privFilters;
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
		return backLink;
	}

	public String cancelSelect() {
		roleBean.setRole(null);
		return backLink;
	}

	public boolean isAddRolesToUser() {
		return addRolesToUser;
	}

	public void setAddRolesToUser(boolean addRolesToUser) {
		this.addRolesToUser = addRolesToUser;
	}

	public String addSelectedRolesToUser() {

		List<ComplexRole> rolesToAdd = _roleSelection.getMultiSelection();
		MbUsers userBean = (MbUsers) ManagedBeanWrapper.getManagedBean("MbUsers");
		User user = userBean.getUser();
		if (user != null) {
			try {
				_rolesDao.addRolesToUser(userSessionId, userBean.getUser().getId(),
						rolesToAdd.toArray(new ComplexRole[rolesToAdd.size()]));
			} catch (Exception ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
		return backLink;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		roleBean.setSearching(searching);
	}

	public void search() {
		curLang = defaultLang;
		setSearching(true);
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

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeRole != null) {
			String lang = (String) event.getNewValue();

			_activeRole = _rolesDao.getRoleById(userSessionId, _activeRole.getId(), lang);
		}
	}

	public void clearBean() {
		curLang = defaultLang;
		_rolesSource.flushCache();
		_roleSelection.clearSelection();
		_activeRole = null;
	}
	
	public void clearFilter() {
		roleFilter = null;
		roleFilters = null;
		userFilters = null;
		searching = false;
		clearBean();
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
}

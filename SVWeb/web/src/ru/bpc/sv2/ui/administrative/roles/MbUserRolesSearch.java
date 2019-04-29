package ru.bpc.sv2.ui.administrative.roles;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.administrative.users.MbUsersSearch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;
@ViewScoped
@ManagedBean (name = "MbUserRolesSearch")
public class MbUserRolesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private RolesDao _rolesDao = new RolesDao();

	private ComplexRole _activeComplexRole;
	private ComplexRole filter;
	private List<Filter> filters;
	private String backLink;

	private boolean showModal;

	private final DaoDataModel<ComplexRole> _rolesSource;

	protected final TableRowSelection<ComplexRole> _itemSelection;

	private Integer userId;
	
	private static String COMPONENT_ID = "bottomUserRolesTable";
	private boolean update = false;
	private String tabName;
	private String parentSectionId;

	protected MbUserRolesSelect roleSelect;

    protected List<SelectItem> avaliableRoles = new ArrayList<SelectItem>(0);
    private List<String> rolesToAdding = new ArrayList<String>();

	public MbUserRolesSearch() {
			_rolesSource = new DaoDataModel<ComplexRole>() {
			@Override
			protected ComplexRole[] loadDaoData(SelectionParams params) {
				if (userId == null)
					return new ComplexRole[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rolesDao.getUserRoles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new ComplexRole[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (userId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rolesDao.getUserRolesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ComplexRole>(null, _rolesSource);
	}

	public DaoDataModel<ComplexRole> getRoles() {
		return _rolesSource;
	}

	public ComplexRole getActiveRole() {
		return _activeComplexRole;
	}

	public void setActiveRole(ComplexRole activeRole) {
		_activeComplexRole = activeRole;
	}

	public SimpleSelection getItemSelection() {
		if (_activeComplexRole == null && _rolesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeComplexRole != null && _rolesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeComplexRole.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeComplexRole = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeComplexRole = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_rolesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeComplexRole = (ComplexRole) _rolesSource.getRowData();
		selection.addKey(_activeComplexRole.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeComplexRole != null) {

		}
	}

	public void search() {
		_rolesSource.flushCache();
		_activeComplexRole = null;
	}

	public void deleteRole() {
		try {
			_rolesDao.deleteUserRole(userSessionId, userId, _activeComplexRole.getId());
			_rolesSource.flushCache();
			_itemSelection.clearSelection();
			_activeComplexRole = null;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String addSelectedRolesToUser() {
		try {
			List<ComplexRole> rolesToAdd = _itemSelection.getMultiSelection();
			if (userId != null) {
				_rolesDao.addRolesToUser(userSessionId, userId, rolesToAdd
						.toArray(new ComplexRole[rolesToAdd.size()]));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return backLink;
	}

	public void deleteSelectedRolesFromUser() {
		try {
			List<ComplexRole> rolesToDel = _itemSelection.getMultiSelection();
			if (userId != null) {
				_rolesDao.deleteRolesFromUser(userSessionId, userId, rolesToDel
						.toArray(new ComplexRole[rolesToDel.size()]));
				_rolesSource.flushCache();
				_itemSelection.clearSelection();
				_activeComplexRole = null;
	
				// clear tabs' state so that the tab with privileges will be re reloaded
				MbUsersSearch users = (MbUsersSearch) ManagedBeanWrapper
						.getManagedBean("MbUsersSearch");
				users.getLoadedTabs().clear();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getShortDesc() != null && !getFilter().getShortDesc().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getShortDesc().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filtersList.add(paramFilter);
		}
		if (getFilter().getName() != null && !getFilter().getName().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getName().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filtersList.add(paramFilter);
		}

		Filter paramFilter = new Filter();
		paramFilter.setElement("userId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userId.toString());
		filtersList.add(paramFilter);

		filters = filtersList;
	}

	public String addRole() {
//		addSelectedRolesToUser
//		Session
		update = true;
		NRoles rolesBean = (NRoles) ManagedBeanWrapper.getManagedBean("roles");
		rolesBean.setSelectMode(true);
		rolesBean.setBackLink(backLink);
		rolesBean.setAddRolesToUser(true);
		return "acm_roles";
	}
	
	public void updateRoles(){
		if (update){
			update = false;
			search();
		}
	}

	public ComplexRole getFilter() {
		if (filter == null)
			filter = new ComplexRole();
		return filter;
	}

    public List<String> getRolesToAdding() {
        return rolesToAdding;
    }

    public void setRolesToAdding(List<String> rolesToAdding) {
        this.rolesToAdding = rolesToAdding;
    }

    public void prepareAvaliableRoles() {
		roleSelect = (MbUserRolesSelect)ManagedBeanWrapper.getManagedBean("MbUserRolesSelect");
		roleSelect.clearFilter();
		roleSelect.setUserId(userId);
		roleSelect.search();
	}

    public void addSelectedRoles() {
		if (roleSelect == null || roleSelect.getRolesSelected().getActivePage() == null
				|| roleSelect.getRolesSelected().getActivePage().size() <= 0) {
			return;
		}
		List<ComplexRole> selectedPrivList = roleSelect.getRolesSelected().getActivePage();
		ComplexRole[] roles = selectedPrivList.toArray(new ComplexRole[selectedPrivList.size()]);
        try {
            _rolesDao.addRolesToUser(userSessionId, userId, roles);
            // todo?  treeLoaded = false;
            //NRoles rolesBean = (NRoles) ManagedBeanWrapper.getManagedBean("roles");
            //rolesBean.getLoadedTabs().clear();
            search();
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }


	public void setFilter(ComplexRole filter) {
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

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	@Override
	public void clearFilter() {
		filter = null;
		searching = false;
		clearBean();
	}
	public void clearBean() {
		_activeComplexRole = null;
		_itemSelection.clearSelection();
		_rolesSource.flushCache();
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

    public List<SelectItem> getAvaliableRoles() {
        return avaliableRoles;
    }
}

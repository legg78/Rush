package ru.bpc.sv2.ui.administrative.roles;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acm.PrivLimitation;
import ru.bpc.sv2.acm.PrivLimitationField;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.administrative.roles.PrivilegeGroupNode;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbRolePrivilegesSearch")
public class MbRolePrivilegesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private RolesDao _rolesDao = new RolesDao();
	private AccessManagementDao acmDao = new AccessManagementDao();

	private Privilege _activePriv;

	
	private Privilege privFilter;
	private List<Filter> privFilters;

	private String backLink;
	private Integer roleId;
	private List<ComplexRole> children;

	private final DaoDataModel<Privilege> _privsSource;

	private final TableRowSelection<Privilege> _privSelection;

	private boolean _managingNew;

	private static String COMPONENT_ID = "bottomPrivsTable";
	private String tabName;
	private String parentSectionId;
	private MbPrivilegesSelect privSelect;








    public MbRolePrivilegesSearch() {
		

		_privsSource = new DaoDataModel<Privilege>() {
			@Override
			protected Privilege[] loadDaoData(SelectionParams params) {
				if (!isSearching() || roleId == null)
					return new Privilege[0];
				try {
					setPrivsFilters();
					params.setFilters(privFilters
							.toArray(new Filter[privFilters.size()]));
					return _rolesDao.getRolePrivs(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Privilege[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching() || roleId == null)
					return 0;
				try {
					setPrivsFilters();
					params.setFilters(privFilters
							.toArray(new Filter[privFilters.size()]));
					return _rolesDao.getRolePrivsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_privSelection = new TableRowSelection<Privilege>(null, _privsSource);
	}

	public void createPrivLimitation() {
		_activePriv.setRoleId(roleId);
	}

	public void savePrivLimitation() {
		try {
			Privilege newPriv = acmDao.addPrivLimitation(userSessionId, _activePriv);
			_privsSource.replaceObject(_activePriv, newPriv);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void resetPrivLimitation() {
	}

	public Privilege getActivePriv() {
		return _activePriv;
	}

	public void setActivePriv(Privilege activePriv) {
		this._activePriv = activePriv;
	}

	public SimpleSelection getPrivSelection() {
		if (_activePriv == null && _privsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activePriv != null && _privsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePriv.getModelId());
			_privSelection.setWrappedSelection(selection);
			_activePriv = _privSelection.getSingleSelection();
		}
		return _privSelection.getWrappedSelection();
	}

	public void setPrivSelection(SimpleSelection selection) {
		_privSelection.setWrappedSelection(selection);
		_activePriv = _privSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_privsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePriv = (Privilege) _privsSource.getRowData();
		selection.addKey(_activePriv.getModelId());
		_privSelection.setWrappedSelection(selection);
		if (_activePriv != null) {

		}
	}

	public DaoDataModel<Privilege> getPrivs() {
		return _privsSource;
	}

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

	public void setPrivsFilters() {
		privFilters = new ArrayList<Filter>();
		Filter paramFilter;

		if (getPrivFilter().getShortDesc() != null
				&& !getPrivFilter().getShortDesc().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getPrivFilter().getShortDesc()
					.replaceAll("[*]", "%").replaceAll("[?]", "_")
					.toUpperCase());
			privFilters.add(paramFilter);
		}
		if (getPrivFilter().getName() != null
				&& !getPrivFilter().getName().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getPrivFilter().getName()
					.replaceAll("[*]", "%").replaceAll("[?]", "_")
					.toUpperCase());
			privFilters.add(paramFilter);
		}
		if (children != null && children.size() > 0) {
			String roleIds = roleId.toString();
			for (ComplexRole child : children) {
				roleIds += "," + child.getId();
			}
			paramFilter = new Filter();
			paramFilter.setElement("roleIds");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(roleIds);
			privFilters.add(paramFilter);
		} else {
			paramFilter = new Filter();
			paramFilter.setElement("roleId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(roleId.toString());
			privFilters.add(paramFilter);
		}
	}

	public Privilege getPrivFilter() {
		if (privFilter == null)
			privFilter = new Privilege();
		return privFilter;
	}

	public void setPrivFilter(Privilege privFilter) {
		this.privFilter = privFilter;
	}

	public List<Filter> getPrivFilters() {
		return privFilters;
	}

	public void setPrivFilters(List<Filter> privFilters) {
		this.privFilters = privFilters;
	}

	public void clearBean() {
		_privSelection.clearSelection();
		_activePriv = null;
		_privsSource.flushCache();
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public void search() {
		setSearching(true);
		_privsSource.flushCache();
		_activePriv = null;
	}

	public Integer getRoleId() {
		return roleId;
	}

	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	public void deleteSelectedPrivsFromRole() {

		List<Privilege> privsToDel = _privSelection.getMultiSelection();
		if (roleId != null) {
			try {
				_rolesDao.deletePrivsFromRole(userSessionId, roleId,
						privsToDel.toArray(new Privilege[privsToDel.size()]));
				_privsSource.flushCache();
				_privSelection.clearSelection();
				_activePriv = null;
			} catch (DataAccessException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}		
	}

	public String addPrivs() {
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("selectMode", "true");
		queueFilter.put("objectId", roleId);
		queueFilter.put("addPrivToRole", "true");
		queueFilter.put("backLink", backLink);
		addFilterToQueue("MbPrivilegesSearch", queueFilter);
		
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect("admin|manage_privileges|list_privileges");
		return "acm_privileges";
	}






	public List<ComplexRole> getChildren() {
		return children;
	}

	public void setChildren(List<ComplexRole> children) {
		this.children = children;
	}

	public String getInheritedText() {
		Privilege priv = getPrivilege();
		return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm",
				"inherited_privilege", priv.getRoleName().split(",")[0], "");
		// return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm",
		// "inherited_privilege",
		// priv.getRoleName(), "");
	}

	public List<SelectItem> getPrivsLimitationResult() {
		if (_activePriv == null){
			return new ArrayList<SelectItem>();
		}
		Map<String,Object> parameters = new HashMap<String,Object>();
		parameters.put("PRIV_ID",_activePriv.getId());
		parameters.put("LIMITATION_TYPE", PrivLimitation.LIMITATION_TYPE_RESULT);
		List<SelectItem> privsLimitations = getDictUtils().getLov(LovConstants.LIST_OF_LIMITATIONS, parameters);
		return privsLimitations;
	}

	public List<SelectItem> getPrivsLimitationFilter() {
		if (_activePriv == null){
			return new ArrayList<SelectItem>();
		}
		Map<String,Object> parameters = new HashMap<String,Object>();
		parameters.put("PRIV_ID",_activePriv.getId());
		parameters.put("LIMITATION_TYPE", PrivLimitation.LIMITATION_TYPE_FILTER);
		List<SelectItem> privsLimitations = getDictUtils().getLov(LovConstants.LIST_OF_LIMITATIONS, parameters);
		return privsLimitations;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	
	private Privilege getPrivilege() {
		return (Privilege) FacesUtils.var("item");
	}
	
	public boolean isDirectPrivilege() {
		Privilege priv = getPrivilege();
		for (String role : priv.getRoles().split(",")) {
			if (Integer.parseInt(role) == roleId) {
				return true;
			}
		}
		return false;
	}
	
	public boolean isSelectedPrivilegeDirect(){
		String[] roles = _activePriv.getRoles().split(",");
		for (String role : roles){
			if (Integer.parseInt(role) == roleId) {
				return true;
			}
		}
		return false;
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



    // modal window privileges ======================================================================

    private String module = null;
    private String systemName = null;
    private String shortDesc = null;
    private static final String MODULE_SEPARATOR = "-";

    private List<SelectItem> availablePrivileges = new ArrayList<SelectItem>(0);
    private List<String> privilegesToAdding = new ArrayList<String>(0);

    private List<SelectItem> selectedPrivileges = new ArrayList<SelectItem>(0);
    private List<String> privilegesToRemove = new ArrayList<String>(0);

    private Privilege[] modalUnassignedPriveleges = new Privilege[0];

    public void prepareData() {
        module = null;
        systemName = null;
        shortDesc = null;
        modalUnassignedPriveleges = new Privilege[0];

        availablePrivileges = new ArrayList<SelectItem>(0);
        privilegesToAdding = new ArrayList<String>(0);

        selectedPrivileges = new ArrayList<SelectItem>(0);
        privilegesToRemove = new ArrayList<String>(0);

		privSelect = (MbPrivilegesSelect)ManagedBeanWrapper.getManagedBean("MbPrivilegesSelect");
		privSelect.clearFilter();
		privSelect.setRoleId(roleId);
		privSelect.search();

        //prepareModalPrivileges();
    }

    public String add() {
        for (String nextId : privilegesToAdding) {
            List<SelectItem> selected = new ArrayList<SelectItem>();
            for (SelectItem nextSi : availablePrivileges) {
                if (nextId.equals(nextSi.getValue())) {
                    selected.add(nextSi);
                }
            }
            availablePrivileges.removeAll(selected);
            selectedPrivileges.addAll(selected);
        }
        privilegesToAdding.clear();
        return null;
    }

    public String remove() {
        for (String nextId : privilegesToRemove) {
            List<SelectItem> selected = new ArrayList<SelectItem>();
            for (SelectItem nextSi : selectedPrivileges) {
                if (nextId.equals(nextSi.getValue())) {
                    selected.add(nextSi);
                }
            }
            selectedPrivileges.removeAll(selected);

            List<SelectItem> filtered = new ArrayList<SelectItem>();
            for (SelectItem nextSi : selected) {
                if (module == null || module.isEmpty() || module.equals(getPrivilegeSiMc(nextSi))) {
                    filtered.add(nextSi);
                }
            }
            availablePrivileges.addAll(filtered);
        }
        privilegesToRemove.clear();
        return null;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
    }

    public List<SelectItem> getModules() {
        return getDictUtils().getLov(LovConstants.MODULE_CODE);
    }

    public List<SelectItem> getAvailablePrivileges() {
        return availablePrivileges;
    }

    public void setAvailablePrivileges(List<SelectItem> availablePrivileges) {
        this.availablePrivileges = availablePrivileges;
    }

    public List<String> getPrivilegesToAdding() {
        return privilegesToAdding;
    }

    public void setPrivilegesToAdding(List<String> privilegesToAdding) {
        this.privilegesToAdding = privilegesToAdding;
    }

    public void prepareModalPrivileges() {
        ArrayList<Filter> filters = new ArrayList<Filter>();
        SelectionParams params = new SelectionParams();
        Filter f = new Filter();
        f.setElement("roleId");
        f.setValue(roleId);
        filters.add(f);

        f = new Filter();
        f.setElement("lang");
        f.setValue(curLang);
        filters.add(f);

        if (module != null) {
            f = new Filter();
            f.setElement("moduleCode");
            f.setValue(module);
            filters.add(f);
        }
        if (shortDesc != null && !shortDesc.equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(shortDesc.toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (systemName != null && !systemName.equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(systemName.replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

        SortElement[] sorters = new SortElement[1];
        sorters[0] = new SortElement("moduleCode", SortElement.Direction.ASC);

        params.setFilters(filters.toArray(new Filter[0]));
        params.setRowIndexEnd(999);
        params.setSortElement(sorters);
        try {
            modalUnassignedPriveleges = _rolesDao.getPrivs(userSessionId, params, true);
            availablePrivileges = new ArrayList<SelectItem>();
            for (Privilege privilege : modalUnassignedPriveleges) {
                String caption = privilege.getName() + " - " + privilege.getShortDesc();
                SelectItem selectItem = new SelectItem(getPrivilegeSiValue(privilege), caption, privilege.getModuleCode().toUpperCase());
                boolean alreadyAdded = false;
                for (SelectItem si : selectedPrivileges) {
                    if (String.valueOf(si.getValue()).equals(getPrivilegeSiValue(privilege))) {
                        alreadyAdded = true;
                    }
                }
                if (!alreadyAdded) {
                    availablePrivileges.add(selectItem);
                }
            }
        } catch (DataAccessException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public String getPrivilegeSiValue(Privilege privilege) {
        return privilege.getModuleCode() + MODULE_SEPARATOR + String.valueOf(privilege.getId());
    }

    public String getPrivilegeSiMc(SelectItem si) {
        return String.valueOf(si.getValue()).split(MODULE_SEPARATOR)[0];
    }

    public Integer getPrivilegeSiId(SelectItem si) {
        return Integer.valueOf(String.valueOf(si.getValue()).split(MODULE_SEPARATOR)[1]);
    }

    public void addSelectedPrivileges() {
        if (privSelect == null || privSelect.getPrivilegesSelected().getActivePage() == null
				|| privSelect.getPrivilegesSelected().getActivePage().size() <= 0) {
            return;
        }
		List<Privilege> selectedPrivList = privSelect.getPrivilegesSelected().getActivePage();
        Privilege[] privileges = selectedPrivList.toArray(new Privilege[selectedPrivList.size()]);
        try {
            _rolesDao.addPrivsToRole(userSessionId, roleId, privileges);
            search();
        } catch (DataAccessException e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    public List<SelectItem> getSelectedPrivileges() {
        return selectedPrivileges;
    }

    public void setSelectedPrivileges(List<SelectItem> selectedPrivileges) {
        this.selectedPrivileges = selectedPrivileges;
    }

    public List<String> getPrivilegesToRemove() {
        return privilegesToRemove;
    }

    public void setPrivilegesToRemove(List<String> privilegesToRemove) {
        this.privilegesToRemove = privilegesToRemove;
    }

	public String getSystemName() {
		return systemName;
	}

	public void setSystemName(String systemName) {
		this.systemName = systemName;
	}

	public String getShortDesc() {
		return shortDesc;
	}

	public void setShortDesc(String shortDesc) {
		this.shortDesc = shortDesc;
	}
}

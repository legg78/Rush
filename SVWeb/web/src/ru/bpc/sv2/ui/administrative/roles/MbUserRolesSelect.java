package ru.bpc.sv2.ui.administrative.roles;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbUserRolesSelect")
public class MbUserRolesSelect extends AbstractBean {
    private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

    private static final String COMPONENT_SELECT_ROLES = "selectRoles";
    private static final String COMPONENT_UNSELECT_ROLES = "unselectRoles";
    private static final String COMPONENT_SELECT_ALL = "selectAll";
    private static final String COMPONENT_UNSELECT_ALL = "unselectAll";

    private RolesDao rolesDao = new RolesDao();

    private final DaoDataModel<ComplexRole> _rolesSourceAvaliable;
    private final DaoDataModel<ComplexRole> _rolesSourceSelected;

    private final TableRowSelection<ComplexRole> _roleSelectionAvaliable;
    private final TableRowSelection<ComplexRole> _roleSelectionSelected;

    private List<ComplexRole> activeRolesAvaliable;
    private List<ComplexRole> activeRolesSelected;

    private Integer userId;
    private List<String> selectedRoles;
    private List<Filter> filtersSelected;

    public MbUserRolesSelect() {
        _rolesSourceAvaliable = new DaoDataListModel<ComplexRole>(logger) {
            @Override
            protected List<ComplexRole> loadDaoListData(SelectionParams params) {
                if (isSearching() && getUserId() != null) {
                    setFilters();
                    params.setFilters(filters);
                    params.setRowIndexEnd(999);
                    return new ArrayList<ComplexRole>(Arrays.asList(rolesDao.getRolesUnassignedToObject(userSessionId, params)));
                }
                return new ArrayList<ComplexRole>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (isSearching() && getUserId() != null) {
                    setFilters();
                    params.setFilters(filters);
                    return rolesDao.getRolesUnassignedToObjectCount(userSessionId, params);
                }
                return 0;
            }
        };
        _roleSelectionAvaliable = new TableRowSelection<ComplexRole>(null, _rolesSourceAvaliable);

        _rolesSourceSelected = new DaoDataListModel<ComplexRole>(logger) {
            @Override
            protected List<ComplexRole> loadDaoListData(SelectionParams params) {
                if(selectedRoles != null && !selectedRoles.isEmpty()) {
                    setFiltersSelected();
                    params.setFilters(filtersSelected);
                    params.setRowIndexEnd(999);
                    return new ArrayList<ComplexRole>(Arrays.asList(rolesDao.getRoles(userSessionId, params)));
                }
                return new ArrayList<ComplexRole>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if(selectedRoles != null && !selectedRoles.isEmpty()) {
                    setFiltersSelected();
                    params.setFilters(filtersSelected);
                    return rolesDao.getRolesCount(userSessionId, params);
                }
                return 0;
            }
        };
        _roleSelectionSelected = new TableRowSelection<ComplexRole>(null, _rolesSourceSelected);
    }

    public DaoDataModel<ComplexRole> getRolesAvaliable() {
        return _rolesSourceAvaliable;
    }
    public DaoDataModel<ComplexRole> getRolesSelected() {
        return _rolesSourceSelected;
    }

    public List<String> getSelectedRoles() {
        return selectedRoles;
    }
    public void setSelectedRoles(List<String> selectedRoles) {
        this.selectedRoles = selectedRoles;
    }

    public SimpleSelection getItemSelectionAvaliable() {
        try {
            if (activeRolesAvaliable == null && _rolesSourceAvaliable.getRowCount() > 0) {
                setFirstRowActiveAvaliable();
            } else if (activeRolesAvaliable != null && _rolesSourceAvaliable.getRowCount() > 0) {
                activeRolesAvaliable = _roleSelectionAvaliable.getMultiSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return _roleSelectionAvaliable.getWrappedSelection();
    }
    public void setItemSelectionAvaliable(SimpleSelection selection) {
        _roleSelectionAvaliable.setWrappedSelection(selection);
        activeRolesAvaliable = _roleSelectionAvaliable.getMultiSelection();
    }

    public void setFirstRowActiveAvaliable() throws CloneNotSupportedException {
        _rolesSourceAvaliable.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activeRolesAvaliable = new ArrayList<ComplexRole>(1);
        activeRolesAvaliable.add(0, (ComplexRole) _rolesSourceAvaliable.getRowData());
        selection.addKey(activeRolesAvaliable.get(0).getModelId());
        _roleSelectionAvaliable.setWrappedSelection(selection);
    }

    public SimpleSelection getItemSelectionSelected() {
        try {
            if (activeRolesSelected != null && _rolesSourceSelected.getRowCount() > 0) {
                activeRolesSelected = _roleSelectionSelected.getMultiSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return _roleSelectionSelected.getWrappedSelection();
    }
    public void setItemSelectionSelected(SimpleSelection selection) {
        _roleSelectionSelected.setWrappedSelection(selection);
        activeRolesSelected = _roleSelectionSelected.getMultiSelection();
    }

    @Override
    public void clearFilter() {
        filters = null;
        filtersSelected = null;
        curLang = userLang;

        clearAvailable();

        clearSelected();

        selectedRoles = null;
        searching = false;
    }

    public void clearAvailable() {
        _roleSelectionAvaliable.clearSelection();
        activeRolesAvaliable = null;
        _rolesSourceAvaliable.flushCache();
    }

    public void clearSelected() {
        _roleSelectionSelected.clearSelection();
        activeRolesSelected = null;
        _rolesSourceSelected.flushCache();
    }

    public void search() {
        curMode = VIEW_MODE;
        _roleSelectionAvaliable.clearSelection();
        activeRolesAvaliable = null;
        _rolesSourceAvaliable.flushCache();
        searching = true;
    }

    private void setFilters() {
        filters = new ArrayList<>();
        filters.add(new Filter("lang", curLang));
        filters.add(new Filter("userId", userId));
        if (selectedRoles != null && !selectedRoles.isEmpty()) {
            filters.add(new Filter("selectedRoles", null, selectedRoles));
        }
    }

    private void setFiltersSelected() {
        filtersSelected = new ArrayList<>();
        filtersSelected.add(new Filter("lang", curLang));
        if (selectedRoles != null && !selectedRoles.isEmpty()) {
            filtersSelected.add(new Filter("ids", null, selectedRoles));
        }

    }

    public void selectRoles() {
        if(activeRolesAvaliable != null && activeRolesAvaliable.size() > 0) {
            if(selectedRoles == null) {
                selectedRoles = new ArrayList<>();
            }
            for (ComplexRole role : activeRolesAvaliable) {
                _rolesSourceSelected.addNewObjectToList(role, null);
                _rolesSourceAvaliable.removeObjectFromList(role);
                selectedRoles.add(role.getId().toString());
            }
        }
        activeRolesAvaliable = null;
    }

    public void unselectRoles() {
        if(activeRolesSelected != null && activeRolesSelected.size() > 0) {
            for(ComplexRole role : activeRolesSelected) {
                _rolesSourceAvaliable.addNewObjectToList(role, null);
                _rolesSourceSelected.removeObjectFromList(role);
                selectedRoles.remove(role.getId().toString());
            }
        }
        activeRolesSelected = null;
    }

    public void selectAllRoles() {
        if (selectedRoles == null) {
            selectedRoles = new ArrayList<>();
        }
        for (ComplexRole role : _rolesSourceAvaliable.getActivePage()) {
            _rolesSourceSelected.addNewObjectToList(role, null);
            selectedRoles.add(role.getId().toString());
        }
        clearAvailable();
    }

    public void unselectAllRoles() {
        for (ComplexRole role : _rolesSourceSelected.getActivePage()) {
            _rolesSourceAvaliable.addNewObjectToList(role, null);
        }
        selectedRoles = null;
        clearSelected();
    }

    public boolean isDisabled(String component) {
        if (COMPONENT_SELECT_ROLES.equals(component)) {
            if(activeRolesAvaliable != null && activeRolesAvaliable.size() > 0) {
                return false;
            }
        } else if (COMPONENT_SELECT_ALL.equals(component)) {
            if (_rolesSourceAvaliable.getRowCount() > 0) {
                return false;
            }
        } else if (COMPONENT_UNSELECT_ROLES.equals(component)) {
            if(activeRolesSelected != null && activeRolesSelected.size() > 0) {
                return false;
            }
        } else if (COMPONENT_UNSELECT_ALL.equals(component)) {
            if(_rolesSourceSelected.getRowCount() > 0) {
                return false;
            }
        }
        return true;
    }

    public Integer getUserId() {
        return userId;
    }
    public void setUserId(Integer userId) {
        this.userId = userId;
    }
}

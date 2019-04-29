package ru.bpc.sv2.ui.administrative.roles;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbPrivilegesSelect")
public class MbPrivilegesSelect extends AbstractBean {

    private RolesDao _rolesDao = new RolesDao();

    private final DaoDataModel<Privilege> _privsSourceAvaliable;
    private final DaoDataModel<Privilege> _privsSourceSelected;

    private final TableRowSelection<Privilege> _privSelectionAvaliable;
    private final TableRowSelection<Privilege> _privSelectionSelected;

    private List<Privilege> activePrivilegesAvaliable;
    private List<Privilege> activePrivilegesSelected;

    private Integer roleId;

    private String module = null;
    private String systemName = null;
    private String shortDesc = null;
    private List<String> selectedPrivs;

    private List<Filter> filtersSelected;

    private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

    public MbPrivilegesSelect() {
        _privsSourceAvaliable = new DaoDataListModel<Privilege>(logger) {
            @Override
            protected List<Privilege> loadDaoListData(SelectionParams params) {
                if (!isSearching() || roleId == null)
                    return new ArrayList<Privilege>();
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    params.setRowIndexEnd(999);
                    return new ArrayList<Privilege>(Arrays.asList(_rolesDao.getPrivs(userSessionId, params, true)));
                } catch (Exception e) {
                    setDataSize(0);
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return new ArrayList<Privilege>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (!isSearching() || roleId == null)
                    return 0;
                try {
                    setFilters();
                    params.setFilters(filters.toArray(new Filter[filters.size()]));
                    return _rolesDao.getPrivsCount(userSessionId, params, true);
                } catch (Exception e) {
                    FacesUtils.addMessageError(e);
                    logger.error("", e);
                }
                return 0;
            }
        };
        _privSelectionAvaliable = new TableRowSelection<Privilege>(null, _privsSourceAvaliable);

        _privsSourceSelected = new DaoDataListModel<Privilege>(logger) {
            @Override
            protected List<Privilege> loadDaoListData(SelectionParams params) {
                if(selectedPrivs != null && !selectedPrivs.isEmpty()) {
                    setFiltersSelected();
                    params.setFilters(filtersSelected.toArray(new Filter[filtersSelected.size()]));
                    params.setRowIndexEnd(999);
                    return new ArrayList<Privilege>(Arrays.asList(_rolesDao.getPrivs(userSessionId, params, false)));
                }
                return new ArrayList<Privilege>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if(selectedPrivs != null && !selectedPrivs.isEmpty()) {
                    setFiltersSelected();
                    params.setFilters(filtersSelected.toArray(new Filter[filtersSelected.size()]));
                    return _rolesDao.getPrivsCount(userSessionId, params, false);
                }
                return 0;
            }
        };
        _privSelectionSelected = new TableRowSelection<Privilege>(null, _privsSourceSelected);
    }

    public DaoDataModel<Privilege> getPrivilegesAvaliable() {
        return _privsSourceAvaliable;
    }

    public DaoDataModel<Privilege> getPrivilegesSelected() {
        return _privsSourceSelected;
    }

    public SimpleSelection getItemSelectionAvaliable() {
        try {
            if (activePrivilegesAvaliable == null && _privsSourceAvaliable.getRowCount() > 0) {
                setFirstRowActiveAvaliable();
            } else if (activePrivilegesAvaliable != null && _privsSourceAvaliable.getRowCount() > 0) {
                activePrivilegesAvaliable = _privSelectionAvaliable.getMultiSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return _privSelectionAvaliable.getWrappedSelection();
    }

    public void setItemSelectionAvaliable(SimpleSelection selection) {
        _privSelectionAvaliable.setWrappedSelection(selection);
        activePrivilegesAvaliable = _privSelectionAvaliable.getMultiSelection();
    }

    public void setFirstRowActiveAvaliable() throws CloneNotSupportedException {
        _privsSourceAvaliable.setRowIndex(0);
        SimpleSelection selection = new SimpleSelection();
        activePrivilegesAvaliable = new ArrayList<Privilege>(1);
        activePrivilegesAvaliable.add(0, (Privilege) _privsSourceAvaliable.getRowData());
        selection.addKey(activePrivilegesAvaliable.get(0).getModelId());
        _privSelectionAvaliable.setWrappedSelection(selection);
    }

    public SimpleSelection getItemSelectionSelected() {
        try {
            if (activePrivilegesSelected != null && _privsSourceSelected.getRowCount() > 0) {
                activePrivilegesSelected = _privSelectionSelected.getMultiSelection();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return _privSelectionSelected.getWrappedSelection();
    }

    public void setItemSelectionSelected(SimpleSelection selection) {
        _privSelectionSelected.setWrappedSelection(selection);
        activePrivilegesSelected = _privSelectionSelected.getMultiSelection();
    }


    @Override
    public void clearFilter() {
        filters = null;
        filtersSelected = null;
        curLang = userLang;

        _privSelectionAvaliable.clearSelection();
        activePrivilegesAvaliable = null;
        _privsSourceAvaliable.flushCache();

        _privSelectionSelected.clearSelection();
        activePrivilegesSelected = null;
        _privsSourceSelected.flushCache();

        module = null;
        shortDesc = null;
        systemName = null;
        selectedPrivs = null;
        searching = false;
    }

    public void search() {
        curMode = VIEW_MODE;
        _privSelectionAvaliable.clearSelection();
        activePrivilegesAvaliable = null;
        _privsSourceAvaliable.flushCache();
        searching = true;
    }

    private void setFilters() {
        filters = new ArrayList<>();
        filters.add(new Filter("lang", curLang));
        filters.add(new Filter("roleId", roleId));
        if (module != null) {
            filters.add(new Filter("moduleCode", module));
        }
        if (shortDesc != null && !shortDesc.isEmpty()) {
            filters.add(new Filter("shortDesc", shortDesc.toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_")));
        }
        if (systemName != null && !systemName.isEmpty()) {
            filters.add(new Filter("name", systemName.replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase()));
        }
        if (selectedPrivs != null && !selectedPrivs.isEmpty()) {
            filters.add(new Filter("selectedPrivs", null, selectedPrivs));
        }

    }

    private void setFiltersSelected() {
        filtersSelected = new ArrayList<>();
        filtersSelected.add(new Filter("lang", curLang));
        if (selectedPrivs != null && !selectedPrivs.isEmpty()) {
            filtersSelected.add(new Filter("ids", null, selectedPrivs));
        }

    }

    public void selectPrivileges() {
        if(activePrivilegesAvaliable != null && activePrivilegesAvaliable.size() > 0) {
            Iterator<Privilege> iter = activePrivilegesAvaliable.iterator();
            if (selectedPrivs == null) {
                selectedPrivs = new ArrayList<>();
            }
            while (iter.hasNext()) {
                Privilege priv = iter.next();
                _privsSourceSelected.addNewObjectToList(priv, null);
                _privsSourceAvaliable.removeObjectFromList(priv);
                selectedPrivs.add(priv.getId().toString());
            }
        }
        activePrivilegesAvaliable = null;
    }

    public void unselectPrivileges() {
        if(activePrivilegesSelected != null && activePrivilegesSelected.size() > 0) {
            for(Privilege priv : activePrivilegesSelected) {
                _privsSourceAvaliable.addNewObjectToList(priv, null);
                _privsSourceSelected.removeObjectFromList(priv);
                selectedPrivs.remove(priv.getId().toString());
            }
        }
        activePrivilegesSelected = null;
    }

    public boolean isDisabled(String component) {
        if("selectPrivs".equals(component)) {
            if(activePrivilegesAvaliable != null && activePrivilegesAvaliable.size() > 0) {
                return false;
            }
            return true;
        } else if ("unselectPrivs".equals(component)) {
            if(activePrivilegesSelected != null && activePrivilegesSelected.size() > 0) {
                return false;
            }
            return true;
        }
        return true;
    }

    public List<SelectItem> getModules() {
        return getDictUtils().getLov(LovConstants.MODULE_CODE);
    }

    public Integer getRoleId() {
        return roleId;
    }

    public void setRoleId(Integer roleId) {
        this.roleId = roleId;
    }

    public String getModule() {
        return module;
    }

    public void setModule(String module) {
        this.module = module;
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

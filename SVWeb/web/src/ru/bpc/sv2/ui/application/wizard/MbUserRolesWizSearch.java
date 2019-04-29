package ru.bpc.sv2.ui.application.wizard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.administrative.roles.MbUserRolesSearch;
import ru.bpc.sv2.ui.administrative.roles.MbUserRolesSelect;
import ru.bpc.sv2.ui.utils.FacesUtils;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by Gasanov on 18.11.2015.
 */
@ViewScoped
@ManagedBean(name="MbUserRolesWizSearch")
public class MbUserRolesWizSearch extends MbUserRolesSearch {
    private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

    private RolesDao _rolesDao = new RolesDao();

    private Map<Integer, ComplexRole> addRoles = new HashMap<Integer, ComplexRole>();
    private Map<Integer, ComplexRole> deleteRoles = new HashMap<Integer, ComplexRole>();

    private boolean isPreFind = false;

    @Override
    public void prepareAvaliableRoles() {
        if(isPreFind){
            return;
        }
        roleSelect = (MbUserRolesSelect) ManagedBeanWrapper.getManagedBean("MbUserRolesSelect");
        roleSelect.clearFilter();
        roleSelect.setUserId(getUserId());
        roleSelect.search();
        isPreFind = true;
    }

    @Override
    public void addSelectedRoles() {
        if (roleSelect == null || roleSelect.getRolesSelected().getActivePage() == null
                || roleSelect.getRolesSelected().getActivePage().size() <= 0) {
            return;
        }
        List<ComplexRole> selectedRoleList = roleSelect.getRolesSelected().getActivePage();
        for (ComplexRole role : selectedRoleList) {
            _itemSelection.addNewObjectToList(role);
            addRoles.put(role.getId(), role);
        }
        roleSelect.setSelectedRoles(null);
        roleSelect.clearSelected();
    }

    @Override
    public void clearFilter() {
        super.clearFilter();
        addRoles.clear();
        deleteRoles.clear();
    }

    public void deleteSelectedRolesFromUser() {
        List<ComplexRole> rolesToDel = _itemSelection.getMultiSelection();
        for(ComplexRole role : rolesToDel) {
            if (addRoles.containsKey(role.getId())) {
                _itemSelection.removeObjectFromList(role);
                roleSelect.getRolesAvaliable().addNewObjectToList(role, null);
                addRoles.remove(role.getId());
            } else {
                deleteRoles.put(role.getId(), role);
            }
        }
    }

    public void restoreRoles() {
        List<ComplexRole> rolesToRestore = _itemSelection.getMultiSelection();
        for(ComplexRole role : rolesToRestore) {
            deleteRoles.remove(role.getId());
        }
    }

    public List<ComplexRole> getList(){
        return getRoles().getActivePage();
    }

    public Map<Integer, ComplexRole> getAddRoles() {
        return addRoles;
    }

    public Map<Integer, ComplexRole> getDeleteRoles() {
        return deleteRoles;
    }

    public Boolean isAddRole(Integer roleId){
        return addRoles.containsKey(roleId);
    }

    public Boolean isDeleteRole(Integer roleId){
        return deleteRoles.containsKey(roleId);
    }

    public Boolean isNoActionRole(Integer roleId){
        return !isAddRole(roleId) && !isDeleteRole(roleId);
    }

    public Boolean isDeletedRoles() {
        List<ComplexRole> roles = _itemSelection.getMultiSelection();
        for(ComplexRole role : roles) {
            if (!isDeleteRole(role.getId())) {
                return false;
            }
        }
        return true;
    }

    public Boolean isNotDeletedRoles() {
        List<ComplexRole> roles = _itemSelection.getMultiSelection();
        for(ComplexRole role : roles) {
            if (isDeleteRole(role.getId())) {
                return false;
            }
        }
        return true;
    }

    public Integer getTotalRolesCount() {
        return getList().size();
    }

    public void setPreFind(boolean preFind) {
        isPreFind = preFind;
    }
}

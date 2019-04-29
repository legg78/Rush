package ru.bpc.sv2.ui.application.wizard;

import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.common.arrays.Array;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.administrative.users.MbUserInstitutions;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.List;

/**
 * Created by Gasanov on 16.11.2015.
 */
@ViewScoped
@ManagedBean(name = "MbUserInstitutionsWiz")
public class MbUserInstitutionsWiz extends MbUserInstitutions {
    private List<Institution> addList = new ArrayList<Institution>();
    private List<Institution> removeList = new ArrayList<Institution>();

    @Override
    public void assignInstitutionToUser(){
        Institution activeInst = getInstitution();
        if (!activeInst.isAssignedToUser() && activeInst.isEntirelyForUser()) {
            activeInst.setEntirelyForUser(false);
        }

        logger.debug("inst:" + activeInst.getId());
        if(activeInst.isAssignedToUser()){
            if (removeList.indexOf(activeInst) >= 0) {
                removeList.remove(activeInst);
            }
            int i;
            if ((i = addList.indexOf(activeInst)) >= 0) {
                addList.set(i, activeInst);
            } else {
                addList.add(activeInst);
            }
        } else {
            if (addList.indexOf(activeInst)>=0) {
                addList.remove(activeInst);
            }
            removeList.add(activeInst);
        }
    }
    public void load(){
        List<Institution> newInsts = new ArrayList<Institution>();
        int i;
        for (Institution inst : insts) {
            if ((i = addList.indexOf(inst))>=0) {
                addList.get(i).setChildren(null);
                newInsts.add(addList.get(i));
            } else if (!removeList.contains(inst)) {
                newInsts.add(inst);
            }
        }
        insts = newInsts;
    }

    public void restructure(){
        coreItems = new ArrayList<Institution>();
        if (insts != null && insts.size() > 0) {
            addNodes(0, coreItems, insts);
            setNode(coreItems.get(0));
        }
        treeLoaded = true;
    }

    public void correctListItems(){
        load();
        restructure();
    }
    public List<Institution> getAddList(){
        return addList;
    }
    public List<Institution> getRemoveList(){
        return removeList;
    }
}

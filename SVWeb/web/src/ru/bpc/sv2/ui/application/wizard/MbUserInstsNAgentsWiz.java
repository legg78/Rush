package ru.bpc.sv2.ui.application.wizard;

import org.openfaces.component.table.TreePath;
import ru.bpc.sv2.common.arrays.Array;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.orgstruct.OrgStructType;
import ru.bpc.sv2.ui.administrative.users.MbUserAgents;
import ru.bpc.sv2.ui.administrative.users.MbUserInstitutions;
import ru.bpc.sv2.ui.administrative.users.MbUserInstsNAgents;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.*;

/**
 * Created by Gasanov on 16.11.2015.
 */
@ViewScoped
@ManagedBean(name="MbUserInstsNAgentsWiz")
public class MbUserInstsNAgentsWiz extends MbUserInstsNAgents {
    private Map<Integer, List<Agent>> agentsMap = new HashMap<Integer, List<Agent>>();
    private List<Institution> addedInsts = new ArrayList<Institution>();
    private List<Institution> removesInsts = new ArrayList<Institution>();

    public void setInsts() {
        MbUserInstitutionsWiz userInstsBean = ManagedBeanWrapper.getManagedBean(MbUserInstitutionsWiz.class);
        userInstsBean.setUserId(getUserId());
        userInstsBean.searchInstitutions();
        userInstsBean.correctListItems();
    }

    public void setAgents() {
        if (currentNode.getId() == null) {
            return;
        }

        Integer instId;
        if (currentNode.isAgent()) {
            instId = ((Agent) currentNode).getInstId();
        } else {
            instId = currentNode.getId().intValue();
        }
        boolean isDefaultForUser;
        boolean isBlockAgents = false;
        if (currentNode.isAgent()) {
            instId = ((Agent) currentNode).getInstId();
            for (OrgStructType type: insts) {
                if (type.getId().equals(instId)) {
                    isBlockAgents = type.isEntirelyForUser();
                }
            }
        } else {
            instId = currentNode.getId().intValue();
            isBlockAgents = checkEntirelyForUser(currentNode.getId());
        }
        isDefaultForUser = currentNode.isDefaultForUser();
        Agent[] agents = loadAgents(instId, isBlockAgents, isDefaultForUser);
        if (agentsMap.get(instId) != null) {
            List<Agent> store = agentsMap.get(instId);
            for (Agent item : store) {
                for (int i = 0; i < agents.length; i++) {
                    if (item.getId().equals(agents[i].getId())) {
                        agents[i].setAssignedToUser(item.isAssignedToUser());
                        agents[i].setDefaultForUser(item.isDefaultForUser());
                    }
                }
            }

        }
    }

    public Agent [] loadAgents(Integer instId, boolean blockAgents, boolean isDefaultForUser){
        MbUserAgents userAgentsBean = ManagedBeanWrapper.getManagedBean(MbUserAgents.class);
        userAgentsBean.setInstId(instId);
        userAgentsBean.setBlockAgents(blockAgents);
        userAgentsBean.setUserId(getUserId());
        userAgentsBean.setDefaultInst(isDefaultForUser);
        userAgentsBean.searchAgents();
        return userAgentsBean.getAgents();
    }

    public void saveUserAgents() {
        MbUserAgents agentsBean = ManagedBeanWrapper.getManagedBean(MbUserAgents.class);
        Agent[] agentsList = agentsBean.getAgents();
        agentsMap.put(agentsBean.getInstId(), new ArrayList<Agent>(Arrays.asList(agentsList)));
        List<OrgStructType> newInsts = new ArrayList<OrgStructType>(Arrays.asList(insts));
        for (OrgStructType agent : agentsList) {
            addAgent(newInsts, agent);
        }
        insts = newInsts.toArray(new OrgStructType[newInsts.size()]);
        restructure();
    }

    private void addAgent(List<OrgStructType> newInst, OrgStructType item){
        Agent agent = (Agent)item;
        boolean findInst = false;
        int index = 0;
        boolean find = false;
        while (newInst.size() > index && !find) {
            if (!findInst) {
                if (newInst.get(index).getId().toString().equals(agent.getInstId().toString())) {
                    findInst = true;
                }
            } else if (!newInst.get(index).isAgent()) {
                if (agent.isAssignedToUser()) {
                    newInst.add(index, item);
                    find = true;
                }
            } else if (newInst.get(index).getId().equals(agent.getId())) {
                if (agent.isAssignedToUser()) {
                    newInst.set(index, item);
                    find = true;
                } else {
                    newInst.remove(index);
                }
            }
            index++;
        }
    }

    public void load(){
        List<OrgStructType> newInsts = new ArrayList<OrgStructType>();
        boolean removed = false;
        for (OrgStructType inst:insts) {
            if (!removesInsts.contains(inst)) {
                if (!inst.isAgent()) {
                    newInsts.add(inst);
                    removed = false;
                } else {
                    if (!removed) {
                        newInsts.add(inst);
                    }
                }

            } else {
                removed = true;
            }
        }
        Agent[] agents;
        for (OrgStructType item : addedInsts) {
            int i;
            if ((i=newInsts.indexOf(item))>=0) {
                newInsts.set(i, item);
            } else {
                newInsts.add(item);
            }
        }
        int n = newInsts.size();
        for (int i = 0; i < n; i++) {
            OrgStructType item = newInsts.get(i);
            if (!item.isAgent() && item.isEntirelyForUser()) {
                agents = loadAgents(item.getId().intValue(), true, item.isDefaultForUser());
                if (agents == null || agents.length == 0) {
                    continue;
                }
                removeSubAgents(newInsts, i + 1);
                newInsts.addAll(i + 1, new ArrayList(Arrays.asList(agents)));
                n = newInsts.size();
                i+=agents.length;
            }
        }
        insts = newInsts.toArray(new OrgStructType[newInsts.size()]);
    }

    private void removeSubAgents(List<OrgStructType> list, int index){
        while (list.size() > index && list.get(index).isAgent()) {
            list.remove(index);
        }
    }

    public void restructure(){
        coreItems = new ArrayList<OrgStructType>();

        if (insts != null && insts.length > 0) {
            addNodes(0, coreItems, insts, 0);
            if (nodePath == null || renewCurrentNode() == null) {
                if (currentNode == null) {
                    currentNode = coreItems.get(0);
                    setNodePath(new TreePath(currentNode, null));
                } else {
                    if (currentNode.getParentId() != null) {
                        setNodePath(formNodePath(insts));
                    } else {
                        setNodePath(new TreePath(currentNode, null));
                    }
                }
            }
        } else {
            currentNode = null;
        }
    }

    public void reloadInstitutions() {
        MbUserInstitutionsWiz instBean = ManagedBeanWrapper.getManagedBean(MbUserInstitutionsWiz.class);
        addedInsts = instBean.getAddList();
        removesInsts = instBean.getRemoveList();
        load();
        restructure();
        treeLoaded = true;
    }

    public List<Agent> getAgents(Integer instId){
        return agentsMap.get(instId);
    }

    public OrgStructType[] getTree(){
        return insts;
    }
}

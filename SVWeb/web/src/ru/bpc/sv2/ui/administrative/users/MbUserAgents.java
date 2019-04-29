package ru.bpc.sv2.ui.administrative.users;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.orgstruct.Agent;

import ru.bpc.sv2.ui.utils.AbstractBean;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbUserAgents")
public class MbUserAgents extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	
	private UsersDao _usersDao = new UsersDao();

    private Agent currentNode;	// node we are working with
    private Agent[] agents;
    private ArrayList<Agent> currentAgents;
    private ArrayList<Agent> coreItems;
    private boolean blockAgents;
    private boolean defaultInst;
    
    private Integer instId;
    private Integer userId;
    private List<Filter> filters;
    private Agent filter;
    private boolean treeLoaded = false;
    private TreePath nodePath;

    private Long userSessionId = null;

	public MbUserAgents() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
    }

    @Override
    public void clearFilter() {
        // do nothing
    }

    public Agent getNode() {
    	if (currentNode == null) {
    		currentNode = new Agent();
    	}
        return currentNode;
    }

    public void setNode(Agent node) {
    	if (node == null) return;
    	this.currentNode = node;

    }

    public void onInstDefaultChanged(ValueChangeEvent event){
		System.out.println(currentNode.getDescription() + ": Test = " + event.getOldValue()+ "; New = " + event.getNewValue());
//		boolean newVal = (Boolean)event.getNewValue();
//		boolean oldVal = (Boolean)event.getOldValue();

	}

	private int addNodes(int startIndex, List<Agent> branches, Agent[] agents) {
//        int counter = 1;
        int i;
    	int level = agents[startIndex].getLevel();

    	for (i = startIndex; i < agents.length; i++) {
            if (agents[i].getLevel() != level) {
            	break;
            }
    		currentAgents.add(agents[i]);	// add this agent to global agents list
        	branches.add(agents[i]);
            if ((i + 1) != agents.length && agents[i + 1].getLevel() > level) {
            	agents[i].setChildren(new ArrayList<Agent>());
	            i = addNodes(i + 1, agents[i].getChildren(), agents);
            }
//            counter++;
        }
        return i - 1;
    }

    private void loadTree() {
    	SelectionParams params = new SelectionParams();
    	setFilters();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
    	agents = new Agent[0];
    	if (userId != null && instId != null)
    		agents = _usersDao.getAgentsForUser( userSessionId, params);
    	coreItems = new ArrayList<Agent>();
    	currentAgents = new ArrayList<Agent>();

    	if (agents != null && agents.length > 0) {
	        addNodes(0, coreItems, agents);
    	}
    	treeLoaded = true;
    }

    public List<Agent> getNodeChildren() {
    	Agent agent = getAgent();
        if (agent == null) {
        	if (!treeLoaded || coreItems == null) {
	        	loadTree();
        	}
	        return coreItems;
        } else {
        	return agent.getChildren();
        }
    }

    private Agent getAgent() {
        return (Agent) Faces.var("agent");
    }

    public boolean getNodeHasChildren() {
    	Agent message = getAgent();
        return (message != null) && message.isHasChildren();
    }

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public Agent[] getAgents() {
		return agents;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public void clearBeansStates() {
	}

	public void searchAgents() {
		nodePath = null;
    	currentNode = null;
		clearBeansStates();
		loadTree();
	}

	public void setFilters()
	{
		List<Filter> filtersList = new ArrayList<Filter>();

		if (instId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(instId.toString());
			filtersList.add(paramFilter);
		}
		if (userId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("userId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userId.toString());
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public Agent getFilter() {
		if (filter == null) {
			filter = new Agent();
		}
		return filter;
	}

	public void setFilter(Agent filter) {
		this.filter = filter;
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public boolean isBlockAgents() {
		return blockAgents;
	}

	public void setBlockAgents(boolean blockAgents) {
		this.blockAgents = blockAgents;
	}

	public boolean getDefaultInst() {
		return !defaultInst;
	}

	public void setDefaultInst(boolean defaultInst) {
		this.defaultInst = defaultInst;
	}
	
	public void selectGranted(){
		if (currentNode != null) {
			if (currentNode.isDefaultForUser()){
				currentNode.setAssignedToUser(true);
			}
		}
	}

}

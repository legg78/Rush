package ru.bpc.sv2.ui.administrative.users;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.orgstruct.Agent;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.orgstruct.OrgStructType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbUserInstsNAgents")
public class MbUserInstsNAgents extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private UsersDao _usersDao = new UsersDao();

	protected OrgStructType currentNode; // node we are working with
	protected OrgStructType[] insts;
	protected boolean treeLoaded = false;
	private List<OrgStructType> selectedNodeDatas;
	private List<OrgStructType> selectedDefInst;
	private List<OrgStructType> assigned;
	private List<Filter> filters;
	protected TreePath nodePath;
	private Integer userId;
	private User user;
	private OrgStructType defNode;
	protected ArrayList<OrgStructType> coreItems;

	private Long userSessionId = null;

	public MbUserInstsNAgents() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}

    @Override
    public void clearFilter() {}

    public OrgStructType getNode() {
		if (currentNode == null) {
			currentNode = new Institution();
		}
		return currentNode;
	}

	public void setNode(OrgStructType node) {
		if (node != null) {
			MbUserAgents userAgentsBean = ManagedBeanWrapper.getManagedBean(MbUserAgents.class);
			if (node.isAssignedToUser()) {
				userAgentsBean.setInstId(node.getId().intValue()); // OrgStruct's ID is actually an integer
			} else {
				userAgentsBean.setInstId(null);
			}
			userAgentsBean.setUserId(getUserId());
			userAgentsBean.searchAgents();
		}
		this.currentNode = node;

	}

	public void onInstDefaultChanged(ValueChangeEvent event) {
		System.out.println(currentNode.getName() + ": Test = " + event.getOldValue() + "; New = "
				+ event.getNewValue());
		for (OrgStructType inst: insts) { //look through the institutions to find prev default to set it to 'false'
			inst.isDefaultForUser();
		}
	}

	public void instDefaultChanged() {
		System.out.println(getDefNode().getName());
	}

	protected int addNodes(int startIndex, List<OrgStructType> branches, OrgStructType[] items, int lastInstLevel) {
		int i;
		int level = items[startIndex].getLevel();
		if (items[startIndex].isAgent()) {
			level = level + lastInstLevel;
		}

		for (i = startIndex; i < items.length; i++) {
			// set correct level so that we have one level enumeration
			// based on level of institutions
			if (items[i].isAgent()) {
				items[i].setLevel(items[i].getLevel() + lastInstLevel);
			}

			if (items[i].getLevel() != level) {
				// before exit from cycle return original level value if needed
				// TODO: do we need to?
				if (items[i].isAgent()) {
					items[i].setLevel(items[i].getLevel() - lastInstLevel);
				}
				break;
			}
			branches.add(items[i]);

			// Add subnodes (if next node exists ((i + 1) != items.length) and if either:
			// - current node is not an agent while next node is an agent which belongs to current node (1 condition)
			// - or next node is of the same type as current and it has a bigger level (2 similar conditions)
			// then it's a subnode of current node)
			
			if ((i + 1) != items.length) {
				Long agentInst = null;
				if (items[i + 1].isAgent()) {
					agentInst = Long.valueOf(((Agent) items[i + 1]).getInstId().longValue());
				}
				if (((!items[i].isAgent() && items[i + 1].isAgent() && agentInst.equals(items[i].getId()))
							|| (!items[i].isAgent() && !items[i + 1].isAgent() && items[i + 1]
									.getLevel() > level) || (items[i].isAgent()
							&& items[i + 1].isAgent() && (items[i + 1].getLevel() + lastInstLevel) > level))) {
					items[i].setChildren(new ArrayList<OrgStructType>());
					i = addNodes(i + 1, items[i].getChildren(), items,
							items[i].isAgent() ? lastInstLevel : (lastInstLevel + 1));
				}
			}
		}
		return i - 1;
	}

	private void loadTree() {
		setFilters();
		SelectionParams params = new SelectionParams(filters);
		insts = new OrgStructType[0];
		if (userId != null) { //if user is not defined then load nothing
			try {
				insts = _usersDao.getStructTypesForUser(userSessionId, params);
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}

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
		}
		treeLoaded = true;
	}

	/**
	 * <p>
	 * Seeks for node with same id as <code>currentNode</code>'s among
	 * <code>insts</code> and updates it if it's found.
	 * </p>
	 * 
	 * @return - updated <code>currentNode</code> or <code>null</code> if node
	 *         wasn't found.
	 */
	protected OrgStructType renewCurrentNode() {
		if (currentNode == null) return null;
		
		boolean renewed = false;
		for (OrgStructType inst: insts) {
			if (currentNode.getId() != null && currentNode.getId().equals(inst.getId())) {
				currentNode = inst;
				renewed = true;
				break;
			}
		}
		
		if (!renewed) {
			currentNode = null;
		}
		return currentNode;
	}
	
	protected TreePath formNodePath(OrgStructType[] insts) {
		ArrayList<OrgStructType> pathInsts = new ArrayList<OrgStructType>();
		pathInsts.add(currentNode);
		OrgStructType node = currentNode;
		while (node.getParentId() != null) {
			for (OrgStructType inst: insts) {
				if (inst.getId().equals(node.getParentId())) {
					pathInsts.add(inst);
					node = inst;
					break;
				}
			}
		}

		Collections.reverse(pathInsts); // make current node last and its very first parent - first

		TreePath nodePath = null;
		for (OrgStructType inst: pathInsts) {
			nodePath = new TreePath(inst, nodePath);
		}

		return nodePath;
	}

	public List<OrgStructType> getNodeChildren() {
		OrgStructType inst = getOrgStructType();
		if (inst == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return inst.getChildren();
		}
	}

	private OrgStructType getOrgStructType() {
		return (OrgStructType) Faces.var("inst");
	}

	public boolean getNodeHasChildren() {
		OrgStructType message = getOrgStructType();
		return (message != null) && message.isHasChildren();
	}

	public void searchOrgStructTypes() {
		clearBean();
		loadTree();
	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		clearBeansStates();
	}
	
	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public void clearBeansStates() {}

	public List<OrgStructType> getSelectedNodeDatas() {

		selectedNodeDatas = new ArrayList<OrgStructType>();
		for (OrgStructType inst: insts) {
			if (inst.isAssignedToUser()) {
				selectedNodeDatas.add(inst);
			}
		}
		return selectedNodeDatas;
	}

	public void setSelectedNodeDatas(List<OrgStructType> selectedNodeDatas) {
		assigned = new ArrayList<OrgStructType>();
		if (selectedNodeDatas != null) {
			for (OrgStructType inst: selectedNodeDatas) {
				assigned.add(inst);
			}
		}
		this.selectedNodeDatas = selectedNodeDatas;
	}

	public boolean isInSelectedList() {
		if (assigned.contains(currentNode))
			return true;
		return false;
	}

	public boolean isInSelectedList(OrgStructType inst) {
		if (assigned.contains(inst))
			return true;
		return false;
	}

	public void instSelectionChange() {
		MbUserAgents userAgentsBean = ManagedBeanWrapper.getManagedBean(MbUserAgents.class);
		userAgentsBean.setUserId(getUserId());
		userAgentsBean.setInstId(currentNode.getId().intValue());
		userAgentsBean.searchAgents();
	}

	public void setFilters() {
		filters = new ArrayList<Filter>(1);

		if (userId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("userId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userId.toString());
			filters.add(paramFilter);
		}
	}

	public Integer getUserId() {
		return userId;
	}

	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public OrgStructType[] getUserInsts() {
		for (OrgStructType inst: insts) {
			inst.setAssignedToUser(isInSelectedList(inst));
		}
		return insts;
	}

	public OrgStructType getDefNode() {
		if (defNode == null) {
			defNode = new Institution();
		}
		return defNode;
	}

	public void setDefNode(OrgStructType defNode) {
		this.defNode = defNode;
	}

	public List<OrgStructType> getSelectedDefInst() {
		return selectedDefInst;
	}

	public void setSelectedDefInst(List<OrgStructType> selectedDefInst) {
		this.selectedDefInst = selectedDefInst;
	}

	public void setInsts() {
		MbUserInstitutions userInstsBean = ManagedBeanWrapper.getManagedBean(MbUserInstitutions.class);
		userInstsBean.setUserId(userId);
		userInstsBean.searchInstitutions();
	}

	public void setAgents() {
		if (currentNode.getId() == null) {
			return;
		}

		MbUserAgents userAgentsBean = ManagedBeanWrapper.getManagedBean(MbUserAgents.class);
		if (currentNode.isAgent()) {
			Integer instId = ((Agent) currentNode).getInstId();
			userAgentsBean.setInstId(((Agent) currentNode).getInstId());
			for (OrgStructType type: insts) {
				if (type.getId().equals(instId)) {
					userAgentsBean.setBlockAgents(type.isEntirelyForUser());
				}
			}
		} else {
			userAgentsBean.setInstId(currentNode.getId().intValue());
			userAgentsBean.setBlockAgents(checkEntirelyForUser(currentNode.getId()));
		}
		userAgentsBean.setUserId(getUserId());
		userAgentsBean.setDefaultInst(currentNode.isDefaultForUser());
		userAgentsBean.searchAgents();
	}
	
	protected boolean checkEntirelyForUser(Long id){
		OrgStructType nodeById = getNodeById(id);
		boolean check = false;
		if(nodeById.isEntirelyForUser()){
			check = true;
		} else if(nodeById.getParentId()!=null){
			check = checkEntirelyForUser(nodeById.getParentId());
		} 
		return check;
	}
	
	private OrgStructType getNodeById(Long id){
		for (OrgStructType inst: insts) {
			if(id.equals(inst.getId())){
				return inst;
			}
		}
		return null;
	}

	public void saveInstitutions() {
		MbUserInstitutions bean = ManagedBeanWrapper.getManagedBean(MbUserInstitutions.class);
		if (bean != null) {
			try {
				for (Institution inst : bean.getInsts()) {
					inst.setUserId(userId.longValue());
				}
				_usersDao.modifyUserInstData(userSessionId, bean.getInsts());
			} catch (Exception e) {
				FacesUtils.addErrorExceptionMessage(e);
				logger.error(e);
			}
		}
		reloadInstitutions();
	}

	public void reloadInstitutions() {
		treeLoaded = false;
		loadTree();
		if (insts == null || insts.length == 0) {
			MbUserAgents agentsBean = ManagedBeanWrapper.getManagedBean(MbUserAgents.class);
			agentsBean.setInstId(null);
			currentNode = null;
		}
	}

	public void saveUserAgents() {
		MbUserAgents agentsBean = ManagedBeanWrapper.getManagedBean(MbUserAgents.class);
		List<Agent> agents = new ArrayList<Agent> (Arrays.asList(agentsBean.getAgents()));
		checkDefaultForUser(agents);
		try {
			for (Agent agent : agents) {
				agent.setUserId(userId.longValue());
				if (agent.isDefaultForUser()) {
					logger.debug("Set agent [" + agent.getId() + "] as default for user [" + userId.longValue() + "]");
				}
			}
			_usersDao.modifyUserAgentData(userSessionId, agents);
			treeLoaded = false;
			loadTree();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	protected void checkDefaultForUser(List<Agent> agents) {
		boolean selected = false;
		int i = 0;
		int defaultForInst = -1;
		if (agents != null) {
			while (!selected && i < agents.size()) {
				if (agents.get(i).isDefaultForUser()) {
					selected = true;
				}
				if (agents.get(i).isDefaultForInst()) {
					defaultForInst = i;
				}
				i++;
			}
			if (!selected && defaultForInst >= 0) {
				agents.get(defaultForInst).setDefaultForUser(true);
				logger.debug("Set agent " + agents.get(defaultForInst).getId() + " as default forcedly");
			}
		}
	}

	public void setDefaultInst() {
		try {
			_usersDao.setUserDefaultInst(userSessionId, user, currentNode.getId());
			treeLoaded = false;
			loadTree();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public User getUser() {
		return user;
	}

	public void setUser(User user) {
		this.user = user;
	}
	
	public void cancel() {
		
	}
}

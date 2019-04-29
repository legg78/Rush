package ru.bpc.sv2.ui.administrative.users;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.validator.ValidatorException;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean (name = "MbUserInstitutions")
public class MbUserInstitutions extends AbstractBean {
	protected static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private UsersDao usersDao = new UsersDao();

	private Institution currentNode;
	protected List<Institution> insts;
	protected boolean treeLoaded = false;
	private List<Institution> selectedNodeDatas;
	private List<Institution> selectedDefInst;
	private List<Institution> assigned;
	private List<Filter> filters;
	private Institution filter;
	private TreePath nodePath;
	private Integer userId;
	private Institution defNode;
	protected ArrayList<Institution> coreItems;

	private Long userSessionId = null;

	public MbUserInstitutions() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}

    @Override
    public void clearFilter() {}

	public Institution getNode() {
		if (currentNode == null) {
			currentNode = new Institution();
		}
		return currentNode;
	}

	public void setNode(Institution node) {
		if (node == null) {
			return;
		}
		this.currentNode = node;
	}

    public void onInstDefaultChanged(ValueChangeEvent event){
		System.out.println(currentNode.getName() + ": Test = " + event.getOldValue()+ "; New = " + event.getNewValue());
		boolean newVal = (Boolean)event.getNewValue();
		boolean oldVal = (Boolean)event.getOldValue();
		for (Institution inst : insts) { //look through the institutions to find prev default to set it to 'false'
			inst.isDefaultForUser();
		}
	}

	public void instDefaultChanged(){
		System.out.println(getDefNode().getName());
	}

	protected int addNodes(int startIndex, List<Institution> branches, List<Institution> insts) {
		int i = 0;
		if (insts != null && insts.size() > 0) {
			int level = insts.get(startIndex).getLevel();
			for (i = startIndex; i < insts.size(); i++) {
				if (insts.get(i).getLevel() != level) {
					break;
				}
				branches.add(insts.get(i));
				if ((i + 1) != insts.size() && insts.get(i + 1).getLevel() > level) {
					insts.get(i).setChildren(new ArrayList<Institution>());
					i = addNodes(i + 1, insts.get(i).getChildren(), insts);
				}
			}
		}
		return i - 1;
	}

	private void loadTree() {
		SelectionParams params = new SelectionParams();
		setFilters();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		if (userId != null) {
			insts = Arrays.asList(usersDao.getInstitutionsForUser(userSessionId, params));
		} else {
			insts = new ArrayList<Institution>(0);
		}
		coreItems = new ArrayList<Institution>(0);

		if (insts != null && insts.size() > 0) {
			addNodes(0, coreItems, insts);
			setNode(coreItems.get(0));
		}
		treeLoaded = true;
	}

	public void applySelected(List<Institution> insts){
		for(Institution coreItem : coreItems) {
			for(Institution inst : insts) {
				if (coreItem.getId().equals(inst.getId())) {
					coreItem.setAssignedToUser(inst.isAssignedToUser());
					coreItem.setEntirelyForUser(inst.isEntirelyForUser());
				}
			}
		}
	};

	public ArrayList<Institution> getNodeChildren() {
		Institution inst = getInstitution();
		if (inst == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return inst.getChildren();
		}
	}

	protected Institution getInstitution() {
		Object obj = Faces.var("inst");
		return (obj == null) ? null : (Institution) Faces.var("inst");
	}

	public boolean getNodeHasChildren() {
		Institution message = getInstitution();
		return (message != null) && message.isHasChildren();
	}

	public void searchInstitutions() {
		nodePath = null;
		currentNode = null;
		clearBeansStates();
		loadTree();
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public void clearBeansStates() {}

	public List<Institution> getSelectedNodeDatas() {
		selectedNodeDatas = new ArrayList<Institution>();
		for (Institution inst : insts) {
			if (inst.isAssignedToUser())
				selectedNodeDatas.add(inst);
		}
		return selectedNodeDatas;
	}

	public void setSelectedNodeDatas(List<Institution> selectedNodeDatas) {
		assigned = new ArrayList<Institution>();
		if (selectedNodeDatas != null) {
			for (Institution inst : selectedNodeDatas ) {
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

	public boolean isInSelectedList(Institution inst) {
		if (assigned.contains(inst))
			return true;
		return false;
	}

	public void instSelectionChange() {
		MbUserAgents userAgentsBean = (MbUserAgents)ManagedBeanWrapper.getManagedBean("MbUserAgents");
		userAgentsBean.setUserId(getUserId());
		userAgentsBean.setInstId(currentNode.getId().intValue()); // Institution's ID is actually an integer
		userAgentsBean.searchAgents();
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (userId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("userId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userId.toString());
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public Institution getFilter() {
		if (filter == null) {
			filter = new Institution();
		}
		return filter;
	}

	public void setFilter(Institution filter) {
		this.filter = filter;
	}

	public Integer getUserId() {
		return userId;
	}
	public void setUserId(Integer userId) {
		this.userId = userId;
	}

	public Institution getDefNode() {
		if (defNode == null)
			defNode = new Institution();
		return defNode;
	}
	public void setDefNode(Institution defNode) {
		this.defNode = defNode;
	}

	public List<Institution> getSelectedDefInst() {
		return selectedDefInst;
	}
	public void setSelectedDefInst(List<Institution> selectedDefInst) {
		this.selectedDefInst = selectedDefInst;
	}

	public void onAccessGrantedChanged(ValueChangeEvent event) {
		Boolean granted = (Boolean) event.getNewValue();
		Institution inst = getInstitution();
		if (granted.booleanValue() && inst.isHasChildren()) {
			setChildrenInsts(inst);
		} else if (!granted.booleanValue() && inst.getParentId() != null) {
			unsetParentInst(inst);
		}
	}

	private void setChildrenInsts(Institution parent) {
		for (Institution child: parent.getChildren()) {
			child.setAssignedToUser(true);
			if (child.isHasChildren()) {
				setChildrenInsts(child);
			}
		}
	}

	private void unsetParentInst(Institution child) {
		child.setAssignedToUser(false);
		for (Institution inst: coreItems) {
			if (inst.getId().equals(child.getParentId())) {
				unsetParentInst(inst);
				break;
			}
		}
	}

	public void validateCheckBox(FacesContext context, UIComponent component, Object value) throws ValidatorException {
		Boolean granted = (Boolean) value;
		Institution inst = getInstitution();
		if (granted.booleanValue() && inst.isHasChildren()) {
			setChildrenInsts(inst);
		} else if (!granted.booleanValue() && inst.getParentId() != null){
			unsetParentInst(inst);
		}
	}

	public List<Institution> getInsts() {
		return insts;
	}

	public void checkBoxes() {
		Institution inst = getInstitution();
		if (inst.isAssignedToUser() && inst.isHasChildren()) {
			setChildrenInsts(inst);
		} else if (!inst.isAssignedToUser() && inst.getParentId() != null){
			unsetParentInst(inst);
		}
	}

	public void assignInstitutionToUser(){
		Institution activeInst = getInstitution();
		try {
			for (Institution inst : insts) {
				if (activeInst.getModelId().equals(inst.getModelId())) {
					inst.setChanged(true);
					break;
				}
			}
		} catch (Exception e) {
			FacesUtils.addErrorExceptionMessage(e);
			logger.error(e);
		}
	}
}


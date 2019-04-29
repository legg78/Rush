package ru.bpc.sv2.ui.administrative.roles;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbRoleSubrolesSearch")
public class MbRoleSubrolesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private RolesDao _rolesDao = new RolesDao();

	private ComplexRole currentNode; // node we are working with
	private boolean treeLoaded = true;
	private List<Filter> filters;
	private ComplexRole filter;
	private TreePath nodePath;
	private ArrayList<ComplexRole> coreItems;
	private List<ComplexRole> selectedNodeDatas;
	private MbRoleSubroles subrolesBean;
	private boolean searching;
	private Long userSessionId = null;

	private List<SelectItem> avaliableSubroles = new ArrayList<SelectItem>(0);
	private List<String> subrolesToAdding = new ArrayList<String>();

	public MbRoleSubrolesSearch() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();

		Menu menu = ManagedBeanWrapper.getManagedBean("menu");
		subrolesBean = ManagedBeanWrapper
				.getManagedBean("MbRoleSubroles");
		if (menu.isKeepState()) {
			nodePath = subrolesBean.getNodePath();
			if (nodePath != null) {
				currentNode = (ComplexRole) nodePath.getValue();
			}
		}
	}

	public ComplexRole getNode() {
		if (currentNode == null) {
			currentNode = new ComplexRole();
		}
		return currentNode;
	}

	public void setNode(ComplexRole node) {
		if (node == null)
			return;
		this.currentNode = node;
	}

	private void loadTree() {
		try {
			coreItems = new ArrayList<ComplexRole>();
			if (!searching)
				return;
			ComplexRole[] params = new ComplexRole[0];
			if (getFilter().getId() != null) {
				SelectionParams selectionParams = new SelectionParams();
				setFilters();
				selectionParams.setFilters(filters.toArray(new Filter[filters
						.size()]));
				params = _rolesDao.getRoleSubroles(userSessionId,
						selectionParams);
			}

			if (params != null && params.length > 0) {
				addNodes(0, coreItems, params);
				if (currentNode == null) {
					currentNode = coreItems.get(0);
					selectedNodeDatas = new ArrayList<ComplexRole>();
					selectedNodeDatas.add(currentNode);
				}
			}
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void search() {
		setSearching(true);
		loadTree();
	}

	public void fullCleanBean() {
		filter = null;
		currentNode = null;
		nodePath = null;
		treeLoaded = false;
		searching = false;
	}

	private int addNodes(int startIndex, ArrayList<ComplexRole> branches,
			ComplexRole[] params) {
		int i;
		int level = params[startIndex].getLevel();

		for (i = startIndex; i < params.length; i++) {
			if (params[i].getLevel() != level) {
				break;
			}
			branches.add(params[i]);
			if ((i + 1) != params.length && params[i + 1].getLevel() > level) {
				params[i].setChildren(new ArrayList<ComplexRole>());
				i = addNodes(i + 1, params[i].getChildren(), params);
			}
		}
		return i - 1;
	}

	public ArrayList<ComplexRole> getNodeChildren() {
		ComplexRole param = getSubrole();
		if (param == null) {
			if (!treeLoaded || coreItems == null) {
				coreItems = new ArrayList<ComplexRole>();
				loadTree();
				treeLoaded = true;
			}
			if (coreItems == null)
				coreItems = new ArrayList<ComplexRole>();
			return coreItems;
		} else {
			return param.getChildren();
		}
	}

	private ComplexRole getSubrole() {
		return (ComplexRole) Faces.var("subrole");
	}

	public boolean getNodeHasChildren() {
		ComplexRole message = getSubrole();
		return (message != null) && message.hasChildren();
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		subrolesBean.setNodePath(nodePath);
		this.nodePath = nodePath;
	}

	public ComplexRole getFilter() {
		if (filter == null)
			filter = new ComplexRole();
		return filter;
	}

	public void setFilter(ComplexRole filter) {
		this.filter = filter;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("parentRoleId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getId().toString());
			filtersList.add(paramFilter);
		}

		filters = filtersList;
	}

	public List<ComplexRole> getSelectedNodeDatas() {
		return selectedNodeDatas;
	}

	public void setSelectedNodeDatas(List<ComplexRole> selectedNodeDatas) {
		if (selectedNodeDatas != null && selectedNodeDatas.size() > 0)
			currentNode = selectedNodeDatas.get(0);
		else
			currentNode = null;
		this.selectedNodeDatas = selectedNodeDatas;
	}

	public void deleteSelectedSubrolesFromRole() {

		List<ComplexRole> subrolesToDel = getSelectedNodeDatas();
		if (getFilter().getId() != null) {
			try {
				_rolesDao.deleteSubrolesFromRole(userSessionId, getFilter()
						.getId(), subrolesToDel
						.toArray(new ComplexRole[subrolesToDel.size()]));
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}

		// clear role's privileges so that they can be reloaded
		MbRolePrivilegesSearch privs = ManagedBeanWrapper
				.getManagedBean("MbRolePrivilegesSearch");
		privs.clearBean();

		// clear tabs' state so that the tab with privileges will be re reloaded
		NRoles roles = ManagedBeanWrapper.getManagedBean("roles");
		roles.getLoadedTabs().clear();
		setSelectedNodeDatas(null);
		search();
	}

	public ComplexRole getCurrentNode() {
		return currentNode;
	}

	public void setCurrentNode(ComplexRole currentNode) {
		this.currentNode = currentNode;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

    public ArrayList<ComplexRole> getSubrolesByRoleId(Integer roleId) {
		SelectionParams selectionParams = new SelectionParams();
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("parentRoleId");
		filters[0].setValue(roleId.toString());
		selectionParams.setFilters(filters);
		try {
			ComplexRole[] subs = _rolesDao.getRoleSubroles(userSessionId,
					selectionParams);
			ArrayList<ComplexRole> result = new ArrayList<ComplexRole>(
					subs.length);
			Collections.addAll(result, subs);
			return result;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
			return null;
		}
	}

	public List<SelectItem> getAvaliableSubroles() {
		return avaliableSubroles;
	}

	public List<String> getSubrolesToAdding() {
		return subrolesToAdding;
	}

	public void setSubrolesToAdding(List<String> subrolesToAdding) {
		this.subrolesToAdding = subrolesToAdding;
	}

	public void prepareAvaliableSubroles() {
		Filter[] filters = new Filter[1];
		Filter f = new Filter();
		f.setElement("roleId");
		f.setValue(getFilter().getId());
		filters[0] = f;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(999);
		ComplexRole[] result;
		avaliableSubroles = new ArrayList<SelectItem>();
		try {
			result = _rolesDao
					.getRolesUnassignedToObject(userSessionId, params);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}

		for (ComplexRole crole : result) {
			String caption = crole.getName() + " - " + crole.getShortDesc();
			SelectItem selectItem = new SelectItem(crole.getId(),
					caption);
			avaliableSubroles.add(selectItem);
		}
	}

	public void addSelectedSubroles() {
		if (subrolesToAdding == null || subrolesToAdding.isEmpty()) {
			return;
		}

		ComplexRole[] roles = new ComplexRole[subrolesToAdding.size()];
		int i = 0;
		for (String roleIdStr : subrolesToAdding) {
			Integer roleId = Integer.valueOf(roleIdStr);
			ComplexRole role = new ComplexRole();
			role.setId(roleId);
			roles[i++] = role;
		}
		try {
			_rolesDao.addRolesToRole(userSessionId, getFilter().getId(),
					roles);
			treeLoaded = false;
			NRoles rolesBean = ManagedBeanWrapper.getManagedBean("roles");
			rolesBean.getLoadedTabs().clear();
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		

	}
}

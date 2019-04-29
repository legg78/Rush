package ru.bpc.sv2.ui.acm;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.AllNodesCollapsed;
import org.openfaces.component.table.DynamicNodeExpansionState;
import org.openfaces.component.table.ExpansionState;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.acm.AcmActionGroup;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.orgstruct.Institution;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbAcmActionGroups")
public class MbAcmActionGroups extends AbstractTreeBean<AcmActionGroup> {

	private static final long serialVersionUID = 4731375574749103997L;

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private AccessManagementDao _acmDao = new AccessManagementDao();

	private AcmActionGroup filter;
	private ArrayList<SelectItem> institutionsList;
	private ArrayList<SelectItem> actionGroups;
	private ArrayList<SelectItem> entityTypes;
	
	private AcmActionGroup newNode;
	private AcmActionGroup detailNode;
	private String tabName;
	private ExpansionState expandLevel;

	private String needRerender;
	private List<String> rerenderList;

	public MbAcmActionGroups() {
		pageLink = "acm|action|groups";
		expandLevel = new DynamicNodeExpansionState(new AllNodesCollapsed());
		tabName = "detailsTab";

		if (nodePath != null) {
			currentNode = (AcmActionGroup) nodePath.getValue();

			ArrayList<TreePath> nodesToExpand = new ArrayList<TreePath>();
			nodesToExpand.add(nodePath);
			TreePath parent = nodePath.getParentPath();
			while (parent != null) {
				nodesToExpand.add(0, parent);
				parent = parent.getParentPath();
			}

			parent = null;
			for (TreePath path : nodesToExpand) {
				// actually curPath is useless, it's introduced only for
				// better readability :)
				TreePath curPath = new TreePath(((Institution) path.getValue()).getId(), parent);
				expandLevel.setNodeExpanded(curPath, true);
				parent = curPath;
			}
			setInfo();
		}
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
	}
	
	@Override
	protected void loadTree() {
		coreItems = new ArrayList<AcmActionGroup>();
		if (!searching) {
			return;
		}

		try {
			setFilters();

			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			AcmActionGroup[] attrs = _acmDao.getAcmActionGroupsTree(userSessionId, params);

			coreItems = new ArrayList<AcmActionGroup>();

			if (attrs != null && attrs.length > 0) {
				addNodes(0, coreItems, attrs);
				if (nodePath == null) {
					if (currentNode == null) {
						currentNode = coreItems.get(0);
						detailNode = (AcmActionGroup) currentNode.clone();
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(attrs));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
						setInfo();
					}
				}
			}
			if (currentNode != null && !coreItems.contains(currentNode)) {
				// when bean state was restored in constructor and selected node
				// doesn't correspond to filter conditions we should add it to
				// list manually
				coreItems.add(currentNode);
			}
			treeLoaded = true;
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<AcmActionGroup> getNodeChildren() {
		AcmActionGroup actionGroup = getAcmActionGroup();
		if (actionGroup == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return actionGroup.getChildren();
		}
	}

	private AcmActionGroup getAcmActionGroup() {
		return (AcmActionGroup) Faces.var("actionGroup");
	}

	public boolean getNodeHasChildren() {
		AcmActionGroup message = getAcmActionGroup();
		return (message != null) && message.isHasChildren();
	}

	@Override
	public TreePath getNodePath() {
		return nodePath;
	}

	@Override
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public AcmActionGroup getNode() {
		if (currentNode == null) {
			currentNode = new AcmActionGroup();
		}
		return currentNode;
	}

	public void setNode(AcmActionGroup node) {
		try {
			curLang = userLang;
			if (node == null)
				return;
			
			boolean changeSelect = false;
			if (node !=null && !node.getId().equals(currentNode.getId())) {
				changeSelect = true;
			}
			
			this.currentNode = node;
			setInfo();
			
			if (changeSelect) {
				detailNode = (AcmActionGroup) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public AcmActionGroup getNewNode() {
		if (newNode == null) {
			newNode = new AcmActionGroup();
		}
		return newNode;
	}

	public void setNewNode(AcmActionGroup newNode) {
		this.newNode = newNode;
	}

	public void add() {
		newNode = new AcmActionGroup();
		newNode.setLang(userLang);
		curLang = newNode.getLang();
		if (currentNode != null) {
			newNode.setParentId(currentNode.getId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newNode = detailNode.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newNode = currentNode;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_acmDao.removeAcmAction(userSessionId, currentNode);
			curMode = VIEW_MODE;
			FacesUtils
					.addMessageInfo("Product (id = " + currentNode.getId() + " has been deleted!");
			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			detailNode = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
				setInfo();
				detailNode = (AcmActionGroup) currentNode.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newNode = _acmDao.addAcmActionGroup(userSessionId, newNode);
				detailNode = (AcmActionGroup) newNode.clone();
				addElementToTree(newNode);
			} else {
				if (newNode.getId().equals(newNode.getParentId())) {
					throw new Exception("Cannot set group itself as it's parent");
				}
				newNode = _acmDao.modifyAcmActionGroup(userSessionId, newNode);
				detailNode = (AcmActionGroup) newNode.clone();
				//adjust newProvider according userLang
				if (!userLang.equals(newNode.getLang())) {
					newNode = getNodeByLang(currentNode.getId(), userLang);
				}
				replaceCurrentNode(newNode);
			}
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
		newNode = new AcmActionGroup();
	}

	public void setInfo() {
		MbAcmActions acmAction = (MbAcmActions) ManagedBeanWrapper.getManagedBean("MbAcmActions");
		acmAction.setGroupId(currentNode.getId().intValue()); // AcmActionGroup's ID is actually an integer
		acmAction.getFilter().setInstId(null);
		acmAction.search();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		loadTab(tabName);
		
		if (tabName.equalsIgnoreCase("ACTIONSTAB")) {
			MbAcmActions acmActionBean = (MbAcmActions) ManagedBeanWrapper.getManagedBean("MbAcmActions");
			acmActionBean.setTabName(tabName);
			acmActionBean.setParentSectionId(getSectionId());
			acmActionBean.setTableState(getSateFromDB(acmActionBean.getComponentId()));
		}
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (currentNode == null || currentNode.getId() == null) {
			return;
		}
		if (tab.equalsIgnoreCase("actionsTab")) {
			MbAcmActions acmAction = (MbAcmActions) ManagedBeanWrapper
					.getManagedBean("MbAcmActions");
			acmAction.setGroupId(currentNode.getId().intValue()); // AcmActionGroup's ID is actually an integer
			acmAction.search();
		}
		needRerender = tab;
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add(tabName);
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public AcmActionGroup getFilter() {
		if (filter == null) {
			filter = new AcmActionGroup();
		}
		return filter;
	}

	public void setFilter(AcmActionGroup filter) {
		this.filter = filter;
	}

	public void search() {
		curMode = VIEW_MODE;
		nodePath = null;
		currentNode = null;
		setSearching(true);
		clearBean();
		loadTree();
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		filter = null;
		searching = false;
		currentNode = null;
		nodePath = null;
		treeLoaded = false;
		clearBean();
		setDefaultValues();
	}

	public void clearBean() {
		coreItems = null;
		nodePath = null;
		currentNode = null;
		detailNode = null;
		treeLoaded = false;
		clearBeansStates();
	}

	public void clearBeansStates() {
		// clear dependent beans
		MbAcmActions acmAction = (MbAcmActions) ManagedBeanWrapper.getManagedBean("MbAcmActions");
		acmAction.clearBean();
	}

	public ExpansionState getExpandLevel() {
		return expandLevel;
	}

	public void setExpandLevel(ExpansionState expandLevel) {
		this.expandLevel = expandLevel;
	}

	public AcmActionGroup getNodeByLang(Long id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(String.valueOf(id));
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			AcmActionGroup[] actionGroup = _acmDao.getAcmActionGroups(userSessionId, params);
			if (actionGroup != null && actionGroup.length > 0) {
				return actionGroup[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailNode = getNodeByLang(detailNode.getId(), curLang);
	}
	
	public void confirmEditLanguage() {
		curLang = newNode.getLang();
		AcmActionGroup tmp = getNodeByLang(newNode.getId(), newNode.getLang());
		if (tmp != null) {
			newNode.setName(tmp.getName());
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutionsList == null) {
			institutionsList = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutionsList == null)
			institutionsList = new ArrayList<SelectItem>();
		return institutionsList;
	}

	public ArrayList<SelectItem> getEntityTypes() {
		if(entityTypes == null){
			entityTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ENTITY_TYPES);
		}
		if (entityTypes == null)
			entityTypes = new ArrayList<SelectItem>();
		return entityTypes;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
	}

	public List<SelectItem> getActionGroups() {
		if(actionGroups == null){
			actionGroups = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ACM_ACTION_GROUPS);
		}
		if (actionGroups == null) {
			actionGroups = new ArrayList<SelectItem>();
		}
		return actionGroups;
	}

	public AcmActionGroup getDetailNode() {
		return detailNode;
	}

	public void setDetailNode(AcmActionGroup detailNode) {
		this.detailNode = detailNode;
	}
	
	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		filter = new AcmActionGroup();
		filter.setInstId(userInstId);
	}
	
	public String getSectionId() {
		return SectionIdConstants.ADMIN_INTERFACE_ACTION_GROUP;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new AcmActionGroup();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("entityType") != null) {
					filter.setEntityType(filterRec.get("entityType"));
				}
				if (filterRec.get("name") != null) {
					filter.setName(filterRec.get("name"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getInstId() != null) {
				filterRec.put("instId", filter.getInstId().toString());
			}
			if (filter.getEntityType() != null) {
				filterRec.put("entityType", filter.getEntityType());
			}
			if (filter.getName() != null) {
				filterRec.put("name", filter.getName());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}

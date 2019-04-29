package ru.bpc.sv2.ui.fcl.cycles;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.cycles.TreeCycleCounter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import java.util.ArrayList;
import java.util.List;

@RequestScoped @KeepAlive
@ManagedBean (name = "MbAccountCycleCounters")
public class MbAccountCycleCounters extends AbstractTreeBean<TreeCycleCounter> {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private CyclesDao _cyclesDao = new CyclesDao();

	private TreeCycleCounter filter;

	private TreeCycleCounter _activeEntry;
	private Long operationId;
	private String entityType;

	private boolean tableView = false;
	private String backLink;

	private static String COMPONENT_ID = "cardCycleCountersTable";
	private String tabName;
	private String parentSectionId;
	private boolean errorSearch;

	public MbAccountCycleCounters() {
		
		
	}

	public TreeCycleCounter getActiveEntry() {
		return _activeEntry;
	}

	public void setActiveEntry(TreeCycleCounter activeEntry) {
		_activeEntry = activeEntry;
	}

	public void clearFilter() {
		filter = null;
		curMode = VIEW_MODE;
		operationId = null;
		entityType = null;
		clearBean();
		searching = false;
		errorSearch = false;
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getCycleType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cycleType");
			paramFilter.setValue(filter.getCycleType());
			filters.add(paramFilter);
		}
		
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

	}

	public TreeCycleCounter getNode() {
		if (currentNode == null) {
			currentNode = new TreeCycleCounter();
		}
		return currentNode;
	}

	public void setNode(TreeCycleCounter node) {
		if (node == null)
			return;

		this.currentNode = node;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private TreeCycleCounter getTreeCycleCounter() {
		return (TreeCycleCounter) Faces.var("item");
	}

	protected void loadTree() {
		coreItems = new ArrayList<TreeCycleCounter>();

		if (!searching && getFilter().getObjectId() == null) {
			return;
		}

		try {

			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			TreeCycleCounter[] trans = _cyclesDao.getAccountCycleCounters(userSessionId, params);
			if (trans != null && trans.length > 0) {
				addNodes1(0, coreItems, trans, 1);
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			errorSearch = true;
		}
	}

	public List<TreeCycleCounter> getNodeChildren() {
		TreeCycleCounter type = getTreeCycleCounter();
		if (type == null) {
			if ((!treeLoaded || coreItems == null) && !errorSearch) {
				loadTree();
			}
			return coreItems;
		} else {
			return type.getChildren();
		}
	}

	public boolean getNodeHasChildren() {
		return (getTreeCycleCounter() != null ) && getTreeCycleCounter().isHasChildren();
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
		errorSearch = false;
		loadTree();
	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		_activeEntry = null;

		curLang = userLang;
	}

	public void saveState() {
		FacesUtils.setSessionMapValue("viewTypeEntryForOperation", tableView);
		FacesUtils.setSessionMapValue("activeEntryForOperation", _activeEntry);
		FacesUtils.setSessionMapValue("currentNodeEntryForOperation", currentNode);
	}

	public void restoreState() {
		tableView = (Boolean) FacesUtils.getSessionMapValue("viewTypeEntryForOperation");
		_activeEntry = (TreeCycleCounter) FacesUtils.getSessionMapValue("activeEntryForOperation");
		currentNode = (TreeCycleCounter) FacesUtils.getSessionMapValue("currentNodeEntryForOperation");
	}

	@Override
	protected int addNodes(int startIndex, List<TreeCycleCounter> branches, TreeCycleCounter[] items) {
		// int counter = 1;
		int i;
		int level = items[startIndex].getLevel();

		for (i = startIndex; i < items.length; i++) {
			if (items[i].getLevel() != level) {
				break;
			}
			branches.add(items[i]);
			if ((i + 1) != items.length && items[i + 1].getLevel() > level) {
				items[i].setChildren(new ArrayList<TreeCycleCounter>());
				i = addNodes(i + 1, items[i].getChildren(), items);
			}
			// counter++;
		}
		return i - 1;
	}

	protected int addNodes1(int startIndex, List<TreeCycleCounter> branches, TreeCycleCounter[] items,
			int level) {
		// int counter = 1;
		int i;
		long objectId = 0;
		long counterId = 0;
		
		String entityType = null;

		if (level == 1) {
			entityType = EntityNames.CARD;
		} else if (level == 2) {
			entityType = EntityNames.CYCLE;
			objectId = items[startIndex].getObjectId();
		}

		boolean checkParent = false;

		for (i = startIndex; i < items.length; i++) {

			if (level == 1) {
				checkParent = items[i].getObjectId() != objectId;
			} else if (level == 2) {
				checkParent = items[i].getObjectId() == objectId &&
						items[i].getId() != counterId;
			}

			if (checkParent) {
				TreeCycleCounter tr = null;
				tr = items[i].clone();
				tr.setLevel(level);
				branches.add(tr);
				tr.setChildren(new ArrayList<TreeCycleCounter>());
				if (level < 2) {
					i = addNodes1(i, tr.getChildren(), items, level + 1);
				}
			} else {
				break;
			}

			// counter++;
		}
		return i - 1;
	}

	public TreeCycleCounter getFilter() {
		if (filter == null) {
			filter = new TreeCycleCounter();
		}
		return filter;
	}

	public void setFilter(TreeCycleCounter filter) {
		this.filter = filter;
	}

	public boolean isTableView() {
		return tableView;
	}

	public void setTableView(boolean tableView) {
		logger.debug("ViewMode has been changed. Actual value tableView=" + tableView);
		this.tableView = tableView;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}

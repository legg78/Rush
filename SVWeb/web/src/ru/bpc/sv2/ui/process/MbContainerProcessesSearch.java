package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import ru.bpc.sv2.constants.LovConstants;

@ViewScoped
@ManagedBean (name = "MbContainerProcessesSearch")
public class MbContainerProcessesSearch extends AbstractBean {
	private static final long serialVersionUID = 2941824798506244273L;

	private static final Logger logger = Logger.getLogger("PROCESSES");

	private ProcessDao _processDao = new ProcessDao();

	private ProcessBO filter;

	private String backLink;
	private boolean selectMode;

	private ProcessBO currentNode;
	private ProcessBO newNode;
	
	private ArrayList<ProcessBO> coreItems;
	private boolean treeLoaded;
	private TreePath nodePath;
	private boolean useCustomValue;

	List<SelectItem> traceLevels;
	List<SelectItem> debugWritingModes;

	public MbContainerProcessesSearch() {

	}

	private int addNodes(int startIndex, ArrayList<ProcessBO> branches, ProcessBO[] processes) {
//      int counter = 1;
		int i;
		int level = processes[startIndex].getLevel();

		for (i = startIndex; i < processes.length; i++) {
			if (processes[i].getLevel() != level) {
				break;
			}
			branches.add(processes[i]);
			if ((i + 1) != processes.length && processes[i + 1].getLevel() > level) {
				processes[i].setChildren(new ArrayList<ProcessBO>());
				i = addNodes(i + 1, processes[i].getChildren(), processes);
			}
//          counter++;
		}
		return i - 1;
	}

	public ProcessBO getNode() {
		return currentNode;
	}

	public void setNode(ProcessBO node) {
		if (node == null)
			return;

		this.currentNode = node;
		setInfo();
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private ProcessBO getContainerProcess() {
		return (ProcessBO) Faces.var("contProcess");
	}

	private void loadTree() {
		if (!searching)
			return;

		try {
			setFilters();

			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			ProcessBO[] attrs = _processDao.getProcessesByContainerHier(userSessionId, params);

			coreItems = new ArrayList<ProcessBO>();

			if (attrs != null && attrs.length > 0) {
				addNodes(0, coreItems, attrs);
				if (currentNode == null) {
					currentNode = coreItems.get(0);
					setNodePath(new TreePath(currentNode, null));
				} else {
					if (!currentNode.getContainerId().equals(getFilter().getContainerId())) {
						setNodePath(formNodePath(attrs));
					} else {
						setNodePath(new TreePath(currentNode, null));
					}
				}
			}
			setInfo();
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	private TreePath formNodePath(ProcessBO[] attrs) {
		ArrayList<ProcessBO> pathAttributes = new ArrayList<ProcessBO>();
		pathAttributes.add(currentNode);
		ProcessBO node = currentNode;
		while (!node.getContainerId().equals(getFilter().getContainerId())) {
			for (ProcessBO attr: attrs) {
				if (attr.getId().equals(node.getContainerId())) {
					pathAttributes.add(attr);
					node = attr;
					break;
				}
			}
		}

		Collections.reverse(pathAttributes); // make current node last and its very first parent - first

		TreePath nodePath = null;
		for (ProcessBO agent: pathAttributes) {
			nodePath = new TreePath(agent, nodePath);
		}

		return nodePath;
	}

	public ArrayList<ProcessBO> getNodeChildren() {
		ProcessBO prc = getContainerProcess();
		if (prc == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return prc.getChildren();
		}
	}

	public boolean getNodeHasChildren() {
		return (getContainerProcess() != null) && getContainerProcess().hasChildren();
	}

	public ProcessBO getNewNode() {
		if (newNode == null) {
			newNode = new ProcessBO();
			newNode.setTrackThreshold(1);
		}
		return newNode;
	}

	public void setNewNode(ProcessBO newNode) {
		this.newNode = newNode;
	}

	public void setInfo() {
		if (currentNode != null) {
			MbProcessParamsSearch procParamBean = (MbProcessParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbProcessParamsSearch");
			procParamBean.clearFilter();
			procParamBean.getFilter().setProcessId(currentNode.getId());
			procParamBean.getFilter().setContainerBindId(currentNode.getContainerBindId());
			procParamBean.getFilter().setContainerId(currentNode.getContainerId());
			procParamBean.setContainerProcessParams(true);
			procParamBean.setContainer(currentNode.isContainer());
			if (!currentNode.isContainer()) {
				procParamBean.search();
			}
		}
	}

	public void clearBeansStates() {
		MbProcessParamsSearch procParamBean = (MbProcessParamsSearch) ManagedBeanWrapper
				.getManagedBean("MbProcessParamsSearch");
		procParamBean.clearFilter();
	}

	public void search() {
		curMode = VIEW_MODE;
		clearState();
		loadTree();
		searching = true;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = null;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getProcedureName() != null && filter.getProcedureName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("procedureName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getProcedureName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}
		if (getFilter().getGroupId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("groupId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getGroupId().toString());
			filters.add(paramFilter);
		}
		if (getFilter().getContainerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getContainerId().toString());
			filters.add(paramFilter);
		}
	}

	public ProcessBO getFilter() {
		if (filter == null)
			filter = new ProcessBO();
		return filter;
	}

	public void setFilter(ProcessBO filter) {
		this.filter = filter;
	}

//	public void storeObjects() {
//		sessBean.setSavedFilter(filter);
//		sessBean.setSavedActiveProcess(_activeProcess);
//		sessBean.setSavedNewProcess(newProcess);
//		sessBean.setSavedBackLink(backLink);
//		sessBean.setSavedCurMode(curMode);
//		// for outer form (e.g. for Products)
//		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
//		menu.setKeepState(true);
//	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public String cancelSelect() {
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void clearState() {
//		_processesSource.flushCache();
//		_itemSelection.clearSelection();
//		_activeProcess = null;
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;
		
		clearBeansStates();
	}
	
	public void clearFilter() {
		filter = null;
		searching = false;
		clearState();
	}

	public void add() {
		newNode = new ProcessBO();
		newNode.setTrackThreshold(1);
		newNode.setContainerId(getFilter().getContainerId());
		newNode.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newNode = (ProcessBO) currentNode.clone();
			useCustomValue=(newNode.getParallelDegree()!=null);
		} catch (CloneNotSupportedException e) {
			newNode = currentNode;
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (!useCustomValue) {
				newNode.setParallelDegree(null);
			}
			if (isNewMode()) {
				currentNode = _processDao.addProcessToContainer(userSessionId, newNode);
			} else if (isEditMode()) {
				currentNode = _processDao.modifyContainerProcess(userSessionId, newNode);
			}
	    	curMode = VIEW_MODE;
			treeLoaded = false;
			nodePath = null;
			useCustomValue=false;
			loadTree();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_processDao.deleteProcessFromContainer(userSessionId, currentNode);
			clearState();
			loadTree();
			useCustomValue=false;
			curMode = VIEW_MODE;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
		useCustomValue=false;
	}

	public boolean isShowModal() {
		return isEditMode() || isNewMode();
	}

	private HashMap<Integer, ProcessBO> processesMap;

	public ArrayList<SelectItem> getProcessesToAdd() {
		if (processesMap == null) {
			processesMap = new HashMap<Integer, ProcessBO>();
		} else {
			processesMap.clear();
		}
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (getFilter().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instIdIn");
				paramFilter.setValue(getFilter().getInstId().toString());
				filtersList.add(paramFilter);
			}

			SortElement[] sortElements = new SortElement[2];
			sortElements[0] = new SortElement("isContainer", Direction.ASC);
			sortElements[1] = new SortElement("name", Direction.ASC);
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			params.setSortElement(sortElements);
			
			ProcessBO[] processes = _processDao.getAllProcesses(userSessionId, params);
			for (ProcessBO prc : processes) {
				if (prc.isContainer()) {
					items.add(new SelectItem(prc.getId(), prc.getId() + " - * " + prc.getName(), prc.getDescription()));
				} else {
					items.add(new SelectItem(prc.getId(), prc.getId() + " - " +prc.getName(), prc.getDescription()));
				}
				processesMap.put(prc.getId(), prc);
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}

		return items;
	}

	public void changeProcess(ValueChangeEvent event) {
		ProcessBO prc = getNewNode();
		Integer newValue = (Integer) event.getNewValue();
		if (newValue != null) {
			ProcessBO selected = processesMap.get(newValue);
			if (selected != null) {
				prc.setParallelAllowed(selected.isParallel());
				if (!selected.isParallel()) {
					prc.setParallel(false);
				}
			}
		}
	}

	public boolean isUseCustomValue() {
		return useCustomValue;
	}

	public void setUseCustomValue(boolean useCustomValue) {
		this.useCustomValue = useCustomValue;
	}

	public List<SelectItem> getTraceLevels() {
		if (traceLevels == null) {
			traceLevels = getDictUtils().getLov(LovConstants.TRACE_LEVELS);
			traceLevels.add(0, new SelectItem(null));
		}
		return traceLevels;
	}

	public List<SelectItem> getDebugWritingModes() {
		if (debugWritingModes == null) {
			debugWritingModes = getDictUtils().getLov(LovConstants.DEBUG_WRITING_MODES);
			debugWritingModes.add(0, new SelectItem(null));
		}
		return debugWritingModes;
	}
}

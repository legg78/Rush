package ru.bpc.sv2.ui.process;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import javax.annotation.PostConstruct;

import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFile;
import ru.bpc.sv2.ui.common.events.MbEventsBottomSearch;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.process.files.MbProcessFilesSearch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbProcessesSearch")
public class MbProcessesSearch extends AbstractBean {
	private static final long serialVersionUID = 7380543777184518195L;

	private ProcessDao _processDao = new ProcessDao();

	private ProcessBO filter;

	private ProcessBO _activeProcess;
	private ProcessBO newProcess;
	private ProcessBO detailProcess;

	private String backLink;
	private boolean showModal;
	private boolean selectMode;
	private MbProcesses procBean;
	private boolean bottomMode;
	private boolean addToGroupMode;

	private String tabName;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<ProcessBO> _processesSource;

	private final TableRowSelection<ProcessBO> _itemSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	private static String COMPONENT_ID = "processesTableBottom";
	private String parentSectionId;

	public MbProcessesSearch() {
		pageLink = "processes|processes";
		bottomMode = false;
		tabName = "detailsTab";
		thisBackLink = "processes|processes";
		
		procBean = (MbProcesses) ManagedBeanWrapper.getManagedBean("MbProcesses");

		_processesSource = new DaoDataModel<ProcessBO>() {
			private static final long serialVersionUID = 7766897214125573055L;

			@Override
			protected ProcessBO[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ProcessBO[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (getFilter().getGroupId() != null)
						return _processDao.getProcessesByGroup(userSessionId, params);
					else if (getFilter().getContainerId() != null)
						return _processDao.getProcessesByContainer(userSessionId, params);
					else
						return _processDao.getProcesses(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessBO[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (getFilter().getGroupId() != null)
						return _processDao.getProcessesByGroupCount(userSessionId, params);
					else if (getFilter().getContainerId() != null)
						return _processDao.getProcessesByContainerCount(userSessionId, params);
					else
						return _processDao.getProcessesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ProcessBO>(null, _processesSource);
	}

	@PostConstruct
	public void init() {
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;	// just to be sure it's not NULL
			
			clearBeansStates();
			setDefaultValues();
		} else {
			_activeProcess = procBean.getProcess();
			if (_activeProcess != null) {
				try {
					detailProcess = (ProcessBO) _activeProcess.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
			backLink = procBean.getBackLink();
			searching = procBean.isSearching();
			filter = procBean.getSavedFilter();
			tabName = procBean.getTabName();
			pageNumber = procBean.getPageNumber();
			rowsNum = procBean.getRowsNum();
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		}
	}
	
	public DaoDataModel<ProcessBO> getProcesses() {
		return _processesSource;
	}

	public ProcessBO getActiveProcess() {
		return _activeProcess;
	}

	public void setActiveProcess(ProcessBO activeProcess) {
		_activeProcess = activeProcess;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeProcess == null && _processesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeProcess != null && _processesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeProcess.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeProcess = _itemSelection.getSingleSelection();
	
				if (restoreBean) {
					setInfo(true);
					restoreBean = false;
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_processesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProcess = (ProcessBO) _processesSource.getRowData();
		detailProcess = (ProcessBO) _activeProcess.clone();
		selection.addKey(_activeProcess.getModelId());
		_itemSelection.setWrappedSelection(selection);
		procBean.setProcess(_activeProcess);
		setInfo(false);
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeProcess.getId())) {
				changeSelect = true;
			}
			_activeProcess = _itemSelection.getSingleSelection();
			procBean.setProcess(_activeProcess);
			setInfo(false);
			if (changeSelect) {
				detailProcess = (ProcessBO) _activeProcess.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setInfo(boolean restoreState) {
		loadedTabs.clear();
		loadTab(getTabName(), restoreState);
		procBean.setPageNumber(pageNumber);
		procBean.setRowsNum(rowsNum);
	}

	public void search() {
		clearState();
		setSearching(true);
		procBean.setSavedFilter(filter);
	}

	public void add() {
		newProcess = new ProcessBO();
		newProcess.setLang(userLang);
		curLang = newProcess.getLang();
		curMode = NEW_MODE;
	}

	public void addContainer() {
		newProcess = new ProcessBO();
		newProcess.setContainer(true);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newProcess = (ProcessBO) detailProcess.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newProcess = _processDao.modifyProcess(userSessionId, newProcess);
				detailProcess = (ProcessBO) newProcess.clone();
				if (!userLang.equals(newProcess.getLang())) {
					newProcess = getNodeByLang(_activeProcess.getId(), userLang);
				}
				_processesSource.replaceObject(_activeProcess, newProcess);
			} else if (isNewMode()) {
				newProcess = _processDao.addProcess(userSessionId, newProcess);
				detailProcess = (ProcessBO) newProcess.clone();
				_itemSelection.addNewObjectToList(newProcess);
			}
			_activeProcess = newProcess;
			procBean.setProcess(_activeProcess);
			setInfo(false);
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_processDao.deleteProcess(userSessionId, _activeProcess);
			_activeProcess = _itemSelection.removeObjectFromList(_activeProcess);
			if (_activeProcess == null) {
				clearState();
			} else {
				setInfo(false);
				detailProcess = (ProcessBO) _activeProcess.clone();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public ProcessBO getNewProcess() {
		if (newProcess == null) {
			newProcess = new ProcessBO();
		}
		return newProcess;
	}

	public void setNewProcess(ProcessBO newProcess) {
		this.newProcess = newProcess;
	}

	public void deleteProcessFromGroup() {
		try {
			_processDao.deleteProcessFromGroup(userSessionId, _activeProcess.getGroupBindId());
			_processesSource.flushCache();
			_itemSelection.clearSelection();
			_activeProcess = null;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public String addSelectedProcessesToGroup() {
		MbProcessGroup groupBean = (MbProcessGroup) ManagedBeanWrapper
				.getManagedBean("MbProcessGroup");
		List<ProcessBO> processesToAdd = _itemSelection.getMultiSelection();
		Integer groupId = groupBean.getGroup().getId();
		try {
			if (groupId != null) {
				_processDao.addProcessesToGroup(userSessionId, groupId, processesToAdd
						.toArray(new ProcessBO[processesToAdd.size()]));
			}
			clearState();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
		return backLink;
	}

	public String deleteSelectedProcessesFromGroup() {
		MbProcessGroup groupBean = (MbProcessGroup) ManagedBeanWrapper
				.getManagedBean("MbProcessGroup");
		List<ProcessBO> processesToDel = _itemSelection.getMultiSelection();
		Integer groupId = groupBean.getGroup().getId();
		try {
			if (groupId != null) {
				_processDao.deleteProcessesFromGroup(userSessionId, processesToDel
						.toArray(new ProcessBO[processesToDel.size()]));
				clearState();
			}
			clearState();
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
		return backLink;
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
			paramFilter.setValue(filter.getProcedureName().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
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
		
		if (getFilter().getInstId() != null){
			filters.add(new Filter("instId", getFilter().getInstId()));
		}
	}

	public ProcessBO getFilter() {
		if (filter == null) {
			filter = new ProcessBO();
		}
		return filter;
	}

	public void setFilter(ProcessBO filter) {
		this.filter = filter;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		procBean.setSearching(searching);
	}

	public String cancelSelect() {
		MbContainerProcesses containerPrcBean = (MbContainerProcesses) ManagedBeanWrapper
				.getManagedBean("MbContainerProcesses");
		containerPrcBean.setKeepState(true);
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String addProcess() {

		setSelectMode(true);
		getFilter().setGroupId(null);
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
		clearState();
		search();
		return "prc_processes";
	}

	public void clearBeansStates() {
		MbProcessFilesSearch procFilesBean = (MbProcessFilesSearch) ManagedBeanWrapper
				.getManagedBean("MbProcessFilesSearch");
		procFilesBean.clearState();
		procFilesBean.setSearching(false);

		MbProcessParamsSearch paramsBean = (MbProcessParamsSearch) ManagedBeanWrapper
				.getManagedBean("MbProcessParamsSearch");
		paramsBean.clearFilter();
		paramsBean.setSearching(false);
		
		MbContainersBottomSearch containersBean = (MbContainersBottomSearch) ManagedBeanWrapper
				.getManagedBean("MbContainersBottomSearch");
		containersBean.clearFilter();
		containersBean.setSearching(false);

		MbEventsBottomSearch eventsBean = (MbEventsBottomSearch) ManagedBeanWrapper
				.getManagedBean("MbEventsBottomSearch");
		eventsBean.clearFilter();
		eventsBean.setSearching(false);
		
	}

	public void clearFilter() {
		filter = new ProcessBO();
		curLang = userLang;
		curMode = VIEW_MODE;
		clearState();
		setDefaultValues();
		
		searching = false;
	}
	
	public void clearState() {

		_itemSelection.clearSelection();
		_activeProcess = null;
		detailProcess = null;
		_processesSource.flushCache();
		// clear dependent beans
		clearBeansStates();
	}

	public boolean isBottomMode() {
		return bottomMode;
	}

	public void setBottomMode(boolean bottomMode) {
		this.bottomMode = bottomMode;
	}

	public String selectProcess() {
		MbContainerProcesses containerPrcBean = (MbContainerProcesses) ManagedBeanWrapper
				.getManagedBean("MbContainerProcesses");
		containerPrcBean.setKeepState(true);
		return backLink;
	}

	public boolean isAddToGroupMode() {
		return addToGroupMode;
	}

	public void setAddToGroupMode(boolean addToGroupMode) {
		this.addToGroupMode = addToGroupMode;
	}

	public void setRowsNum(int rowsNum) {
		procBean.setRowsNum(rowsNum);
		this.rowsNum = rowsNum;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailProcess = getNodeByLang(detailProcess.getId(), curLang);
	}
	
	public ProcessBO getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
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
			ProcessBO[] processes = _processDao.getProcesses(userSessionId, params);
			if (processes != null && processes.length > 0) {
				return processes[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		procBean.setTabName(tabName);
		if (tabName.equalsIgnoreCase("paramsTab")) {
			MbProcessParamsSearch procParamBean = (MbProcessParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbProcessParamsSearch");
			procParamBean.setTabName(tabName);
			procParamBean.setParentSectionId(getSectionId());
			procParamBean.setTableState(getSateFromDB(procParamBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("filesTab")) {
			MbProcessFilesSearch procFileBean = (MbProcessFilesSearch) ManagedBeanWrapper
					.getManagedBean("MbProcessFilesSearch");
			procFileBean.setTabName(tabName);
			procFileBean.setParentSectionId(getSectionId());
			procFileBean.setTableState(getSateFromDB(procFileBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("containerTab")) {
			MbContainersBottomSearch containersBean = (MbContainersBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbContainersBottomSearch");
			containersBean.setTabName(tabName);
			containersBean.setParentSectionId(getSectionId());
			containersBean.setTableState(getSateFromDB(containersBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("eventsTab")) {
			MbEventsBottomSearch eventsBean = (MbEventsBottomSearch) ManagedBeanWrapper
					.getManagedBean("MbEventsBottomSearch");
			eventsBean.setTabName(tabName);
			eventsBean.setParentSectionId(getSectionId());
			eventsBean.setTableState(getSateFromDB(eventsBean.getComponentId()));
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName, false);
	}
	
	private void loadTab(String tab, boolean restoreState) {
		if (tab == null)
			return;
		if (_activeProcess == null || _activeProcess.getId() == null)
			return;
		try {
			if (tab.equalsIgnoreCase("detailsTab")) {
	
			}
	
			if (tab.equalsIgnoreCase("paramsTab")) {
				MbProcessParamsSearch procParamBean = (MbProcessParamsSearch) ManagedBeanWrapper
						.getManagedBean("MbProcessParamsSearch");
				procParamBean.clearFilter();
				procParamBean.getFilter().setProcessId(_activeProcess.getId());
				procParamBean.getFilter().setContainerId(getFilter().getContainerId());
				procParamBean.setContainerProcessParams(false);
				procParamBean.setBackLink(thisBackLink);
				procParamBean.search();
				if (restoreBean) {
					procParamBean.restoreBean();
				}
			}
	
			if (tab.equalsIgnoreCase("filesTab")) {
				MbProcessFilesSearch procFileBean = (MbProcessFilesSearch) ManagedBeanWrapper
						.getManagedBean("MbProcessFilesSearch");
				ProcessFile fileFilter = new ProcessFile();
				fileFilter.setProcessId(_activeProcess.getId());
				procFileBean.setFilter(fileFilter);
				procFileBean.setSearching(true);
				procFileBean.search();
			}
			
			if (tab.equalsIgnoreCase("containerTab")) {
				MbContainersBottomSearch containerBean = (MbContainersBottomSearch) ManagedBeanWrapper
						.getManagedBean("MbContainersBottomSearch");
				containerBean.getFilter().put("processId", _activeProcess.getId().toString());
				containerBean.search();
			}

			if (tab.equalsIgnoreCase("eventsTab")) {
				MbEventsBottomSearch eventsBean = (MbEventsBottomSearch) ManagedBeanWrapper
						.getManagedBean("MbEventsBottomSearch");
				eventsBean.setProcedureName(_activeProcess.getProcedureName());
				eventsBean.setInstId(_activeProcess.getInstId());
				eventsBean.search();
			}
			needRerender = tab;
			loadedTabs.put(tab, Boolean.TRUE);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public String getRerenderString() {
		List<String> strList = getRerenderList();
		StringBuffer buffer = new StringBuffer();
		for (String str : strList) {
			buffer.append(str + ",");
		}
		buffer.delete(buffer.length() - 1, buffer.length());
		return buffer.toString();
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public void setPageNumber(int pageNumber) {
		procBean.setPageNumber(pageNumber);
		this.pageNumber = pageNumber;
	}
	
	public void confirmEditLanguage() {
		curLang = newProcess.getLang();
		ProcessBO tmp = getNodeByLang(newProcess.getId(), newProcess.getLang());
		if (tmp != null) {
			newProcess.setName(tmp.getName());
			newProcess.setDescription(tmp.getDescription());
		}
	}

	public ProcessBO getDetailProcess() {
		return detailProcess;
	}

	public void setDetailProcess(ProcessBO detailProcess) {
		this.detailProcess = detailProcess;
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		filter = new ProcessBO();
		filter.setInstId(userInstId);
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void keepTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	public String getSectionId() {
		return SectionIdConstants.ADMIN_PROCESS_PROCESS;
	}
	
}

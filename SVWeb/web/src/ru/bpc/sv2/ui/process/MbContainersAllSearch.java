package ru.bpc.sv2.ui.process;

import org.apache.commons.vfs.*;
import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.process.*;
import ru.bpc.sv2.process.ProcessBO.ProcessState;
import ru.bpc.sv2.schedule.ScheduledTask;
import ru.bpc.sv2.scheduler.process.ContainerLauncher;
import ru.bpc.sv2.scheduler.process.ProcessExecutorAdapter;
import ru.bpc.sv2.trace.TraceConstants;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.process.files.MbFileAttributesSearch;
import ru.bpc.sv2.ui.process.monitoring.MbOracleTracing;
import ru.bpc.sv2.ui.process.monitoring.MbProcessTrace;
import ru.bpc.sv2.ui.process.monitoring.MbSessionFiles;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.utils.MaskFileSelector;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.Resource;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.ExternalContext;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.Serializable;
import java.math.BigDecimal;
import java.nio.channels.FileChannel;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

@ViewScoped
@ManagedBean(name = "MbContainersAllSearch")
public class MbContainersAllSearch extends AbstractBean {

	private static final long serialVersionUID = 1L;

	private static final String COMPONENT_ID = "1068:mainTable";

	private ProcessDao _processDao = new ProcessDao();

	private CommonDao commonDao = new CommonDao();

	private ProcessBO _activeProcess;
	private ProcessBO newProcess;
	private ProcessBO detailProcess;
	private String tabName;
	private String location;
	private String processName;

	private ProcessBO filter;

	private String backLink;
	private boolean selectMode;
	private boolean loadState;
	private MbContainersAll procBean;
	private boolean uploadRequired;

	private Long sessionId;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<ProcessBO> _processesSource;
	private final TableRowSelection<ProcessBO> _itemSelection;

	private ProcessParameter _activeLaunchParam;
	private MbOracleTracing launchTraceParam;
	private Integer previousProcessId;

	private List<Filter> filtersLaunch;
	private boolean searchingLaunch;

	private final DaoDataModel<ProcessParameter> _launchParamSource;

	private final TableRowSelection<ProcessParameter> _launchSelection;

	private static final Logger logger = Logger.getLogger("PROCESSES");

	private ContainerLaunchData containerLaunchData;
	private HashMap<Long, ContainerLaunchData> containerLaunchDataMap;
	private transient ContainerLauncher containerLauncher;

	private boolean addOneItem;

	public MbContainersAllSearch() {
		pageLink = "processes|containers";
		tabName = "detailsTab";
		thisBackLink = "processes|containers";
		procBean = (MbContainersAll) ManagedBeanWrapper.getManagedBean("MbContainersAll");
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		containerLaunchDataMap = new HashMap<Long, ContainerLaunchData>();

		_processesSource = new DaoDataModel<ProcessBO>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProcessBO[] loadDaoData(SelectionParams params) {
				if (!isSearching()) {
					if(addOneItem){
						addOneItem = false;
						ProcessBO[] processBO =  {_activeProcess};
						return processBO;
					}
					return new ProcessBO[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					ProcessBO[] result = _processDao.getContainersAll(userSessionId, params);
					if (_activeProcess != null && Boolean.TRUE.equals(restoreBean)) {
						boolean itemFound = false;
						for (ProcessBO aResult : result) {
							if (aResult.getId().equals(_activeProcess.getId())) {
								itemFound = true;
								break;
							}
						}
						if (!itemFound) {
							ProcessBO[] newResult = new ProcessBO[result.length];
							newResult[0] = _activeProcess;
							System.arraycopy(result, 0, newResult, 1, result.length - 1);
							result = newResult;
						}
						restoreBean = Boolean.FALSE;
					}
					logger.info("Records length (MbContainersAll):" + result.length);
					return result;
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessBO[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching()) {
					if(addOneItem){
						return 1;
					}
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					int result = _processDao.getContainersAllCount(userSessionId, params);
					logger.info("Records count (MbContainersAll):" + result);
					return result;
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ProcessBO>(null, _processesSource);

		_launchParamSource = new DaoDataModel<ProcessParameter>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ProcessParameter[] loadDaoData(SelectionParams params) {
				if (!isSearchingLaunch() || _activeProcess == null ||
						_activeProcess.getId() == null)
					return new ProcessParameter[0];
				try {
					setFiltersLaunch();
					params.setFilters(filtersLaunch.toArray(new Filter[filtersLaunch.size()]));
					return _processDao.getContainerLaunchParams(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearchingLaunch() || _activeProcess == null ||
						_activeProcess.getId() == null)
					return 0;
				try {
					setFiltersLaunch();
					params.setFilters(filtersLaunch.toArray(new Filter[filtersLaunch.size()]));
					return _processDao.getContainerLaunchParamsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_launchSelection = new TableRowSelection<ProcessParameter>(null, _launchParamSource);
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);

		if (Boolean.TRUE.equals(restoreBean) || menu.isKeepState()) {
			_activeProcess = procBean.getProcess();
			searching = procBean.isSearching();
			if (_activeProcess != null) {
				try {
					detailProcess = _activeProcess.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				if(!searching){
					addOneItem = true;
				}
			}
			backLink = procBean.getBackLink();

			filter = procBean.getSavedFilter();
			loadState = true;
			tabName = procBean.getTabName();
			pageNumber = procBean.getPageNumber();
			FacesUtils.setSessionMapValue(thisBackLink, false);
		} else {
			procBean.setTabName("");
		}
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE; // just to be sure it's not NULL
			clearBeansStates();
		}

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
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

				if (loadState) {
					setInfo();
					loadState = false;
				}
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addErrorExceptionMessage(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_processesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeProcess = (ProcessBO) _processesSource.getRowData();
		detailProcess = _activeProcess.clone();
		selection.addKey(_activeProcess.getModelId());
		_itemSelection.setWrappedSelection(selection);
		procBean.setProcess(_activeProcess);
		setInfo();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null
					&& !_itemSelection.getSingleSelection().getId().equals(_activeProcess.getId())) {
				changeSelect = true;
			}
			ProcessBO tmp = _itemSelection.getSingleSelection();
			if (tmp == null || tmp.getModelId().equals(_activeProcess.getModelId())) {
				return;
			} else {
				_activeProcess = tmp;
				if (changeSelect) {
					detailProcess = _activeProcess.clone();
				}
			}
			procBean.setProcess(_activeProcess);
			setInfo();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setInfo() {
		loadedTabs.clear();
		if (_activeProcess != null) {
			_launchParamSource.flushCache();
			_launchSelection.clearSelection();
			setSearchingLaunch(true);
		}
		loadTab(getTabName());
	}

	public void search() {
		clearState();
		setSearching(true);
		procBean.setSavedFilter(filter);
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filter = getFilter();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getProcedureName() != null && filter.getProcedureName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("procedureName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getProcedureName().trim().toUpperCase().replaceAll("[*]", "%")
										 .replaceAll("[?]", "_"));
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
			paramFilter.setValue(filter.getName().trim().toUpperCase()
										 .replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getGroupId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("groupId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getGroupId().toString());
			filters.add(paramFilter);
		}
		if (filter.getContainerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getContainerId().toString());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newProcess = new ProcessBO();
		newProcess.setContainer(true);
		newProcess.setLang(userLang);
		curLang = newProcess.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newProcess = detailProcess.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newProcess = _activeProcess;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newProcess = _processDao.modifyProcess(userSessionId, newProcess);
				detailProcess = newProcess.clone();
				if (!userLang.equals(newProcess.getLang())) {
					newProcess = getNodeByLang(_activeProcess.getId(), userLang);
				}
				_processesSource.replaceObject(_activeProcess, newProcess);
				clearBeansStates();
			} else if (isNewMode()) {
				newProcess = _processDao.addProcess(userSessionId, newProcess);
				detailProcess = newProcess.clone();
				_itemSelection.addNewObjectToList(newProcess);
			}
			_activeProcess = newProcess;
			procBean.setProcess(_activeProcess);
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void delete() {
		try {
			_processDao.removeContainer(userSessionId, _activeProcess);
			_activeProcess = _itemSelection.removeObjectFromList(_activeProcess);
			if (_activeProcess == null) {
				clearState();
			} else {
				setInfo();
				detailProcess = _activeProcess.clone();
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

	public ProcessBO getFilter() {
		if (filter == null) {
			filter = new ProcessBO();
			filter.setInstId(userInstId);
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

	public void setSearching(boolean searching) {
		this.searching = searching;
		procBean.setSearching(searching);
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

	public String addProcess() {
		setSelectMode(true);
		getFilter().setGroupId(null);
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
		MbProcesses prcBean = (MbProcesses) ManagedBeanWrapper.getManagedBean("MbProcesses");
		prcBean.setProcess(null);
		return "prc_prc_to_container";
	}

	public void clearState() {
		_processesSource.flushCache();
		_itemSelection.clearSelection();
		_activeProcess = null;
		detailProcess = null;
		clearStateLaunch();
		clearBeansStates();
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}

	public void clearBeansStates() {
		MbContainerProcessesSearch procBean = (MbContainerProcessesSearch) ManagedBeanWrapper
				.getManagedBean("MbContainerProcessesSearch");
		procBean.clearFilter();

		MbContainerTasksSearch taskBean = (MbContainerTasksSearch) ManagedBeanWrapper
				.getManagedBean("MbContainerTasksSearch");
		taskBean.clearState();
		taskBean.setSearching(false);

		MbFileAttributesSearch fileAttrSearchBean = (MbFileAttributesSearch) ManagedBeanWrapper
				.getManagedBean("MbFileAttributesSearch");
		fileAttrSearchBean.clearState();
		fileAttrSearchBean.setSearching(false);


		MbProcessRoles rolesForProcess = (MbProcessRoles) ManagedBeanWrapper
				.getManagedBean("MbProcessRoles");
		rolesForProcess.fullCleanBean();
		rolesForProcess.setSearching(false);
	}

	public String addProcessToContainer() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);

		this.selectMode = true;
		return "prc_processes";
	}

	public void launch() {
		sessionId = null;
		_activeStat = null;

		searchLaunch();
	}

	public void prepareContainerLaunchData() {
		Filter[] filters = new Filter[2];
		Filter filter = new Filter();
		filter.setElement("containerId");
		filter.setValue(_activeProcess.getId());
		filters[0] = filter;
		filter = new Filter();
		filter.setElement("lang");
		filter.setValue(curLang);
		filters[1] = filter;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		ProcessBO[] containerArray = _processDao.getProcessesByContainerHier(userSessionId, params);
		List<ProcessBO> containerList = new ArrayList<ProcessBO>();
		Collections.addAll(containerList, containerArray);

		filter = new Filter();
		filter.setElement("processId");
		filter.setValue(_activeProcess.getId());
		filters[0] = filter;
		filter = new Filter();
		filter.setElement("lang");
		filter.setValue(curLang);
		filters[1] = filter;
		ProcessParameter[] containerParameters = _processDao.getContainerLaunchParams(
				userSessionId, params);

		containerLaunchData = new ContainerLaunchData();
		containerLaunchData.setContainerList(containerList);
		containerLaunchData.setProcessParameters(containerParameters);

		MbProcessTrace mbProcessTrace = (MbProcessTrace) ManagedBeanWrapper.getManagedBean("MbProcessTrace");
		mbProcessTrace.fullCleanBean();

		MbSessionFiles mbSessionFiles = (MbSessionFiles) ManagedBeanWrapper.getManagedBean("MbSessionFiles");
		mbSessionFiles.fullCleanBean();
	}


	public void launchContainer() {
		containerLaunchData.setInProcessing(true);

		// getting uiParams
		ProcessParameter[] parameters = containerLaunchData.getProcessParameters();

		ProcessDao processDao = new ProcessDao();

		Integer containerId = _activeProcess.getId();

		// getting container
		ProcessBO container = new ProcessBO();
		container.setId(containerId);

		// getting correcponding container in dialog
		ProcessBO containerInDialog = new ProcessBO();
		containerInDialog.setChildren(containerLaunchData.getContainerTree());

		ProcessExecutorAdapter listener = new ProcessExecutorAdapter() {
			@Override
			public void containerFinished(ContainerLauncher source) {
				ContainerLaunchData cld = containerLaunchDataMap.get(source.getContainerSessionId());
				if (source.getContainerSessionId() != null && cld != null) {
					updateProcessStatistics();
					cld.setRunningProcess(null);
				}
			}

			@Override
			public void containerFailed(ContainerLauncher source) {
				ProcessBO procInDialog = source.getViewContainer();
				failContainer(procInDialog);
			}

			private void failContainer(ProcessBO container) {
				for (ProcessBO process : container.getChildren()) {
					if (ProcessState.UNDEFINE == process.getState()) {
						process.setState(ProcessState.NOT_SUCCESSFULLY_COMPLETED);
						if (process.hasChildren()) {
							failContainer(process);
						}
					}
				}
			}
		};

		FacesContext fc = FacesContext.getCurrentInstance();
		ExternalContext externalContext = fc.getExternalContext();

		containerLauncher = new ContainerLauncher();
		containerLauncher.setContainer(container);
		containerLauncher.setEffectiveDate(containerLaunchData.getProcessDate());
		containerLauncher.setListener(listener);
		containerLauncher.setMasParameters(parameters);
		containerLauncher.setProcessDao(processDao);
		containerLauncher.setUserSessionId(userSessionId);
		containerLauncher.setViewContainer(containerInDialog);
		containerLauncher.setUserName(externalContext.getUserPrincipal().getName());
		containerLauncher.setThreadNumber(getLaunchTraceParam().getThreadNumber());
		containerLauncher.setTraceLevel(getLaunchTraceParam().getTraceLevel());
		containerLauncher.setTraceLimit(getLaunchTraceParam().getTraceLimit());
		try {
			containerLauncher.launch();
		} catch (SystemException e) {
			FacesUtils.addSystemError(e);
		} catch (UserException e) {
			FacesUtils.addErrorExceptionMessage(e);
		}
	}

	public void clearContainerLaunchData() {
		containerLaunchData = null;
	}

	public void checkFileUpload() {

		FileSystemManager fsManager;
		uploadRequired = false;
		try {
			List<ProcessBO> containerFloatTree = containerLaunchData.getContainerTree();
			fsManager = VFS.getManager();
			for (ProcessBO container : containerFloatTree) {
				ProcessFileAttribute[] fileAttrs = getFileInAttributes(container.getContainerBindId());

				for (ProcessFileAttribute file : fileAttrs) {
					if (file.getLocation() != null) {
						FileObject locationV = fsManager.resolveFile(file.getLocation());
						boolean isDirectory = FileType.FOLDER.equals(locationV.getType());

						if (isDirectory && file.getIsFileRequired().equals(true)) {
							if (file.getFileNameMask() == null) {
								file.setFileNameMask("");
							}
							try {
								// Just to check pattern is correct
								// noinspection ResultOfMethodCallIgnored
								Pattern.compile(file.getFileNameMask());
							} catch (PatternSyntaxException e) {
								String m = "Regular expression error: " + e.getMessage();
								throw new UserException(m, e);
							}

							FileSelector selector = new MaskFileSelector(file.getFileNameMask());
							FileObject[] fileObjects = locationV.findFiles(selector);
							locationV.close();
							if (fileObjects.length == 0) {
								uploadRequired = true;
								location = file.getLocation();
								processName = container.getName();
							}
						}
					}
				}

			}
		} catch (SystemException e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		} catch (FileSystemException e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		} catch (UserException e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void fileUploadListener(UploadEvent event) throws Exception {
		UploadItem item = event.getUploadItem();
		if (!checkMaximumFileSize(item.getFileSize())) {
			FacesUtils.addMessageError("File size is too big");
			logger.error("File size is too big");
		}

		FileChannel sourceChannel = null;
		FileChannel destChannel = null;
		try {
			sourceChannel = new FileInputStream(item.getFile()).getChannel();
			if (!location.endsWith("\\") && !location.endsWith("/")) {
				location = location + "/";
			}
			destChannel = new FileOutputStream(new File(location + item.getFileName())).getChannel();
			destChannel.transferFrom(sourceChannel, 0, sourceChannel.size());
		} finally {
			if (sourceChannel != null)
				sourceChannel.close();
			if (destChannel != null)
				destChannel.close();
		}
	}

	private ProcessFileAttribute[] getFileInAttributes(Integer containerBindId) throws SystemException {
		ProcessFileAttribute[] result;
		try {
			result = _processDao.getIncomingFilesForProcess(userSessionId,
															null,
															containerBindId);
		} catch (DataAccessException e) {
			logger.error(e.getMessage(), e);
			throw new SystemException(e.getMessage(), e);
		}
		return result;
	}

	public void enableLaunchingStateRefreshing() {
		containerLaunchData.setInProcessing(true);
	}

	public void updateRunningProcStatSummary(Long containerSessionId) {
		if (containerLaunchDataMap.get(containerSessionId) != null) {
			updateRunningProcStatSummary(containerLaunchDataMap.get(containerSessionId));
		}
	}

	public void updateRunningProcStatSummary() {
		if (containerLaunchData != null) {
			updateRunningProcStatSummary(containerLaunchData);
			updateTrace();
			updateProcessStatistics();

			if (!containerLauncher.isRunning()) {
				containerLaunchData.setProcessed(true);
				containerLaunchData.setInProcessing(false);
			}
			try {
				containerLauncher.updateProgress();
			} catch (SystemException e) {
				logger.error(e.getMessage(), e);
				FacesUtils.addSystemError(e);
			}
		}
	}

	public void updateRunningProcStatSummary(ContainerLaunchData containerLaunchData) {
		ProcessBO runningProcess = containerLaunchData.getRunningProcess();
		if (runningProcess == null) {
			return;
		}
		Long sessionId = runningProcess.getProcessStatSummary().getSessionId();
		ProcessStatSummary processStatSummary = _processDao.getStatSummaryBySessionId(userSessionId, sessionId);
		runningProcess.setProcessStatSummary(processStatSummary);
	}

	private void updateProcessStatistics() {
		ProcessBO currentStructureItem = containerLaunchData.getCurrentStructureItem();
		if (currentStructureItem == null) {
			return;
		}
		Long sessionId = currentStructureItem.getProcessStatSummary().getSessionId();
		List<ProcessStatSummary> processStatSummary = _processDao.getProcessThreads(userSessionId, sessionId);
		containerLaunchData.setProcessThreads(processStatSummary);
	}

	private synchronized void updateTrace() {
		MbSessionFiles mbSessionFiles = (MbSessionFiles) ManagedBeanWrapper.getManagedBean("MbSessionFiles");
		mbSessionFiles.clearBean();
		if (containerLaunchData.getCurrentStructureItem() != null) {
			mbSessionFiles.setSessionId(containerLaunchData.
					getCurrentStructureItem().
					getProcessStatSummary().
					getSessionId());
		} else {
			mbSessionFiles.setSessionId(null);
		}

		mbSessionFiles.setContainerId(containerLaunchData.getCurrentStructureItem() != null ?
									  containerLaunchData.getCurrentStructureItem().getContainerBindId() : null);

		if (containerLaunchData.getCurrentStructureItem() == null) {
			return;
		}
		ProcessStatSummary currentProcessStatSummary = containerLaunchData
				.getCurrentStructureItem().getProcessStatSummary();
		Long sessionId = currentProcessStatSummary.getSessionId();
		Integer threadCount = currentProcessStatSummary.getThreadCount();
		MbProcessTrace mbProcessTrace = (MbProcessTrace) ManagedBeanWrapper
				.getManagedBean("MbProcessTrace");
		mbProcessTrace.clearBean();
		mbProcessTrace.setSessionId(sessionId);
		mbProcessTrace.setThreadCount(threadCount);
		if (containerLaunchData.getCurrentStructureItem() != null) {
			mbProcessTrace.search();
			mbSessionFiles.search();
		}


	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void resetLaunchData() {
		containerLaunchData = null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
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
			ProcessBO[] processes = _processDao.getContainersAll(userSessionId, params);
			if (processes != null && processes.length > 0) {
				return processes[0];
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		procBean.setTabName(tabName);
		this.tabName = tabName;

		loadTab(tabName);

		if (tabName.equalsIgnoreCase("processesTab")) {
			MbProcessParamsSearch procBean = (MbProcessParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbProcessParamsSearch");
			procBean.setTabName(tabName);
			procBean.setParentSectionId(getSectionId());
			procBean.setTableState(getSateFromDB(procBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("paramsTab")) {
			MbContainerParamsSearch procParamBean = (MbContainerParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbContainerParamsSearch");
			procParamBean.setTabName(tabName);
			procParamBean.setParentSectionId(getSectionId());
			procParamBean.setTableState(getSateFromDB(procParamBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("filesTab")) {
			MbFileAttributesSearch fileAttrSearchBean = (MbFileAttributesSearch) ManagedBeanWrapper
					.getManagedBean("MbFileAttributesSearch");
			fileAttrSearchBean.setTabName(tabName);
			fileAttrSearchBean.setParentSectionId(getSectionId());
			fileAttrSearchBean.setTableState(getSateFromDB(fileAttrSearchBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("tasksTab")) {
			MbContainerTasksSearch taskBean = (MbContainerTasksSearch) ManagedBeanWrapper
					.getManagedBean("MbContainerTasksSearch");
			taskBean.setTabName(tabName);
			taskBean.setParentSectionId(getSectionId());
			taskBean.setTableState(getSateFromDB(taskBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("rolesTab")) {
			MbProcessRoles rolesForProcess = (MbProcessRoles) ManagedBeanWrapper
					.getManagedBean("MbProcessRoles");
			rolesForProcess.setTabName(tabName);
			rolesForProcess.setParentSectionId(getSectionId());
			rolesForProcess.setTableState(getSateFromDB(rolesForProcess.getComponentId()));
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeProcess == null || _activeProcess.getId() == null)
			return;

		if (tab.equalsIgnoreCase("processesTab")) {
			MbContainerProcessesSearch procBean = (MbContainerProcessesSearch) ManagedBeanWrapper
					.getManagedBean("MbContainerProcessesSearch");
			procBean.setFilter(null);
			procBean.getFilter().setContainerId(_activeProcess.getId());
			procBean.getFilter().setInstId(_activeProcess.getInstId());
			procBean.search();
		}

		if (tab.equalsIgnoreCase("paramsTab")) {
			MbContainerParamsSearch procParamBean = (MbContainerParamsSearch) ManagedBeanWrapper
					.getManagedBean("MbContainerParamsSearch");
			ProcessParameter paramFilter = new ProcessParameter();
			paramFilter.setProcessId(_activeProcess.getId());
			paramFilter.setContainerId(getFilter().getContainerId());
			procParamBean.setFilter(paramFilter);
			procParamBean.search();
		}

		if (tab.equalsIgnoreCase("tasksTab")) {
			MbContainerTasksSearch taskBean = (MbContainerTasksSearch) ManagedBeanWrapper
					.getManagedBean("MbContainerTasksSearch");
			ScheduledTask task = new ScheduledTask();
			task.setContainerId(_activeProcess.getId());
			taskBean.setFilter(task);
			taskBean.search();
		}

		if (tab.equalsIgnoreCase("filesTab")) {
			MbFileAttributesSearch fileAttrSearchBean = (MbFileAttributesSearch) ManagedBeanWrapper
					.getManagedBean("MbFileAttributesSearch");
			ProcessFileAttribute attribute = new ProcessFileAttribute();
			attribute.setContainerId(_activeProcess.getId());
			attribute.setInstId(_activeProcess.getInstId());
			fileAttrSearchBean.setFilter(attribute);
			fileAttrSearchBean.search();

		}

		if (tab.equalsIgnoreCase("rolesTab")) {
			MbProcessRoles rolesForProcess = (MbProcessRoles) ManagedBeanWrapper
					.getManagedBean("MbProcessRoles");
			rolesForProcess.fullCleanBean();
			rolesForProcess.setProcessId(_activeProcess.getId());
			rolesForProcess.setBackLink(thisBackLink);
			rolesForProcess.search();
		}

		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		List<String> rerenderList = new ArrayList<String>();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	private ProcessStatSummary _activeStat;

	public ProcessStatSummary getNode() {
		if (_activeStat == null) {
			_activeStat = new ProcessStatSummary();
		}
		return _activeStat;
	}

	public void setNode(ProcessStatSummary node) {
		if (node == null)
			return;
		this._activeStat = node;
		setStatInfo();
	}

	public void closeFinishPanel() {
		sessionId = null;
	}

	public Long getSessionId() {
		return sessionId;
	}

	private void setStatInfo() {
		if (_activeStat != null) {
			MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper
					.getManagedBean("MbProcessTrace");
			traceBean.setSessionId(_activeStat.getSessionId());
			ProcessTrace filterTrace = new ProcessTrace();
			filterTrace.setTraceLevelFilter(TraceConstants.TRACE_LEVEL_INFO);
			traceBean.setFilter(filterTrace);
			traceBean.search();
		}
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new ProcessBO();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("description") != null) {
					filter.setDescription(filterRec.get("description"));
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
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
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
			if (filter.getDescription() != null && !filter.getDescription().trim().equals("")) {
				filterRec.put("description", filter.getDescription());
			}
			if (filter.getName() != null && !filter.getName().trim().equals("")) {
				filterRec.put("name", filter.getName());
			}

			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public DaoDataModel<ProcessParameter> getLaunchParams() {
		return _launchParamSource;
	}

	public ProcessParameter getActiveLaunchParam() {
		return _activeLaunchParam;
	}

	public void setActiveLaunchParam(ProcessParameter activeLaunchParam) {
		_activeLaunchParam = activeLaunchParam;
	}

	public SimpleSelection getLaunchSelection() {
		try {
			if (_activeLaunchParam == null && _launchParamSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeLaunchParam != null && _launchParamSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeLaunchParam.getModelId());
				_launchSelection.setWrappedSelection(selection);
				_activeLaunchParam = _launchSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addErrorExceptionMessage(e);
		}
		return _launchSelection.getWrappedSelection();
	}

	public void setLaunchRowActive() {
		_launchParamSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeLaunchParam = (ProcessParameter) _launchParamSource.getRowData();
		selection.addKey(_activeLaunchParam.getModelId());
		_launchSelection.setWrappedSelection(selection);
	}

	public void setLaunchSelection(SimpleSelection selection) {
		_launchSelection.setWrappedSelection(selection);
		_activeLaunchParam = _launchSelection.getSingleSelection();
	}

	public void searchLaunch() {
		clearStateLaunch();
		setSearchingLaunch(true);
	}

	public void setFiltersLaunch() {
		filtersLaunch = new ArrayList<Filter>();

		Filter paramFilter;

		if (_activeProcess.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("processId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeProcess.getId());
			filtersLaunch.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersLaunch.add(paramFilter);

	}

	public List<Filter> getFiltersLaunch() {
		return filtersLaunch;
	}

	public void setFiltersLaunch(List<Filter> filtersLaunch) {
		this.filtersLaunch = filtersLaunch;
	}

	public void clearStateLaunch() {
		_launchParamSource.flushCache();
		_launchSelection.clearSelection();
		_activeLaunchParam = null;
	}

	public List<SelectItem> getListValues() {
		List<SelectItem> list = null;
		try {
			ProcessParameter param = (ProcessParameter) Faces.var("item");
			if (param != null && param.getLovId() != null) {
				boolean isParentPresents = false;
				if (param.getParentId() != null) {
					if(param.getParentValue() != null) {
						isParentPresents = true;
						Map<String, Object> params = new HashMap<String, Object>();
						if(DataTypes.CHAR.equals(param.getParentType())) {
							params.put(param.getParentName(), param.getParentValue());
						}
						else if (DataTypes.NUMBER.equals(param.getParentType())) {
							params.put(param.getParentName(), new BigDecimal(param.getParentValue()));
						}
						else if (DataTypes.DATE.equals(param.getParentType())) {
							SimpleDateFormat formatter = new SimpleDateFormat(DatePatterns.DB_CONVERT_DATE_PATTERN);
							Date date = formatter.parse(param.getParentValue());
							params.put(param.getParentName(), date);
						}
						list = getDictUtils().getLov(param.getLovId(), params);
					}
					else {
						for (ProcessParameter parameter : containerLaunchData.getProcessParameters()) {
							if (parameter.getId() != null && parameter.getId().equals(param.getParentId())
									&& parameter.getExecOrder().equals(param.getExecOrder())) {
								isParentPresents = true;
								Map<String, Object> params = new HashMap<String, Object>();
								params.put(parameter.getSystemName(), parameter.getValue());
								list = getDictUtils().getLov(param.getLovId(), params);
							}
						}
					}
				}
				if (!isParentPresents) {
					list = getDictUtils().getLov(param.getLovId());
				}
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		} finally {
			if (list == null) {
				list = new ArrayList<SelectItem>(0);
			}
		}
		return list;
	}

	public boolean isSearchingLaunch() {
		return searchingLaunch;
	}

	public void setSearchingLaunch(boolean searchingLaunch) {
		this.searchingLaunch = searchingLaunch;
	}

	public void confirmEditLanguage() {
		curLang = newProcess.getLang();
		ProcessBO tmp = getNodeByLang(newProcess.getId(), newProcess.getLang());
		if (tmp != null) {
			newProcess.setName(tmp.getName());
			newProcess.setDescription(tmp.getDescription());
		}
	}

	public ContainerLaunchData getContainerLaunchData() {
		if (containerLaunchData == null) {
			containerLaunchData = new ContainerLaunchData();
		}
		return containerLaunchData;
	}

	public void setContainerLaunchData(ContainerLaunchData containerLaunchData) {
		this.containerLaunchData = containerLaunchData;
	}

	public class ContainerLaunchData implements Serializable {

		private static final long serialVersionUID = 1L;
		private List<ProcessBO> containerTree = new ArrayList<ProcessBO>();

		private List<ProcessBO> containerList;
		private ProcessBO currentStructureItem;
		private TreePath currentStructureItemPath;
		private ProcessParameter[] processParameters;
		private Date processDate;
		private boolean inProcessing = false;
		private List<ProcessStatSummary> processThreads;
		private boolean processed = false;
		private ProcessBO runningProcess;
		private Integer traceLevel;

		public List<ProcessBO> getStructNodeChildren() {
			ProcessBO structureItem = getStructureItem();
			if (structureItem == null) {
				return containerTree;
			} else {
				return structureItem.getChildren();
			}
		}

		public boolean getStructNodeHashChildren() {
			return getStructureItem().hasChildren();
		}

		private ProcessBO getStructureItem() {
			return (ProcessBO) Faces.var("structureItem");
		}

		private void loadContainerTree() {
			if (containerList != null && containerList.size() > 0) {
				for (Integer i = 0; i < containerList.size(); i++) {
					containerList.get(i).setOrderNumber(i+1);
				}
				fillBranches(0, containerTree, containerList);
			}
		}

		private int fillBranches(int startIndex, List<ProcessBO> branches, List<ProcessBO> source) {
			int i;
			int level = source.get(startIndex).getLevel();

			for (i = startIndex; i < source.size(); i++) {
				if (source.get(i).getLevel() != level) {
					break;
				}
				branches.add(source.get(i));
				if ((i + 1) != source.size() && source.get(i + 1).getLevel() > level) {
					source.get(i).setChildren(new ArrayList<ProcessBO>());
					i = fillBranches(i + 1, source.get(i).getChildren(), source);
				}
			}
			return i - 1;
		}

		public void setContainerList(List<ProcessBO> containerList) {
			this.containerList = containerList;
			loadContainerTree();
		}

		public ProcessBO getCurrentStructureItem() {
			return currentStructureItem;
		}

		public void setCurrentStructureItem(ProcessBO currentStructureItem) {
			ProcessBO prevStructItem = this.currentStructureItem;
			this.currentStructureItem = currentStructureItem;
			if (currentStructureItem != null && (prevStructItem == null || !prevStructItem.getModelId().equals(currentStructureItem.getModelId()))) {
				updateProcessStatistics();
				updateTrace();
			}
		}

		public ProcessParameter[] getProcessParameters() {
			return processParameters;
		}

		public void setProcessParameters(ProcessParameter[] processParameters) {
			if (processParameters != null && processParameters.length > 0) {
				ArrayList<ProcessParameter> ppList = new ArrayList<ProcessParameter>();
				String previousExecOrder = "";
				for (ProcessParameter pp : processParameters) {
					if (pp.getExecOrder().compareTo(previousExecOrder) > 0) {
						if (previousExecOrder.compareTo("") > 0){
							ppList.add( new ProcessParameter() );
						}
						previousExecOrder = pp.getExecOrder();
					}
					ppList.add( pp );
				}
				if (this.processParameters == null) {
					this.processParameters = new ProcessParameter[ppList.size()];
				}
				ppList.toArray( this.processParameters );
			}
		}

		public Date getProcessDate() {
			return processDate;
		}

		public void setProcessDate(Date processDate) {
			this.processDate = processDate;
		}

		public boolean getInProcessing() {
			return inProcessing;
		}

		public void setInProcessing(boolean inProcessing) {
			this.inProcessing = inProcessing;
		}

		public List<ProcessBO> getContainerTree() {
			return containerTree;
		}

		public List<ProcessStatSummary> getProcessThreads() {
			return processThreads;
		}

		public void setProcessThreads(List<ProcessStatSummary> processThreads) {
			this.processThreads = processThreads;
		}

		public TreePath getCurrentStructureItemPath() {
			return currentStructureItemPath;
		}

		public void setCurrentStructureItemPath(TreePath currentStructureItemPath) {
			this.currentStructureItemPath = currentStructureItemPath;
		}

		public boolean isProcessed() {
			return processed;
		}

		public void setProcessed(boolean processed) {
			this.processed = processed;
		}

		public ProcessBO getRunningProcess() {
			return runningProcess;
		}

		public void setRunningProcess(ProcessBO runningProcess) {
			this.runningProcess = runningProcess;
		}

		public void setTraceLevel(Integer traceLevel) {
			this.traceLevel = traceLevel;
		}
		public Integer getTraceLevel() {
			return traceLevel;
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ProcessBO getDetailProcess() {
		return detailProcess;
	}

	public void setDetailProcess(ProcessBO detailProcess) {
		this.detailProcess = detailProcess;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
		procBean.setPageNumber(pageNumber);
	}

	public String getSectionId() {
		return SectionIdConstants.ADMIN_PROCESS_CONTAINER;
	}

	public boolean isUploadRequired() {
		return uploadRequired;
	}

	public String getProcessName() {
		return processName;
	}

	@SuppressWarnings("UnusedParameters")
	public void setCurrentProcess(Integer p) {
	}

	public MbOracleTracing getLaunchTraceParam() {
		if (launchTraceParam == null) {
			launchTraceParam = (MbOracleTracing)ManagedBeanWrapper.getManagedBean("MbOracleTracing");
		} else if (_activeProcess.getId().equals(previousProcessId) == Boolean.FALSE) {
			launchTraceParam.cleanup();
		}
		previousProcessId = _activeProcess.getId();
		return launchTraceParam;
	}
	public void setLaunchTraceParam(MbOracleTracing launchTraceParam) {
		this.launchTraceParam = launchTraceParam;
	}
}

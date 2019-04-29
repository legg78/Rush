package ru.bpc.sv2.ui.process.monitoring;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbProcessSessionsSearch")
public class MbProcessSessionsSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PROCESSES");

	private static String COMPONENT_ID = "1028:mainTable";

	private ProcessDao _processDao = new ProcessDao();

	private final DaoDataModel<ProcessSession> processSessionSource;
	private final TableRowSelection<ProcessSession> processSessionSelection;
	private ProcessSession filter;
	private ProcessSession activeProcessSession;

	private ArrayList<SelectItem> processes;

	private String tabName;
	private String needRerender;
	private List<String> rerenderList;

	private String ctxItemEntityType;
	private ContextType ctxType;

	public MbProcessSessionsSearch() {

		pageLink = "processes|sessions";
		tabName = "detailsTab";
		processSessionSource = new DaoDataModel<ProcessSession>() {
			@Override
			protected ProcessSession[] loadDaoData(SelectionParams params) {
				ProcessSession[] result;
				if (!isSearching()) {
					result = new ProcessSession[0];
				} else {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters
								.size()]));

						result = _processDao.getProcessSessions(userSessionId,
								params);
					} catch (Exception e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
						result = new ProcessSession[0];
					}
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (isSearching()) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters
								.size()]));
						result = _processDao.getProcessSessionsCount(
								userSessionId, params);
					} catch (Exception e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return result;
			}
		};
		processSessionSelection = new TableRowSelection<ProcessSession>(null, processSessionSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals(getSectionId())) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (getFilter().getContainerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerId");
			paramFilter.setValue(getFilter().getContainerId().toString());
			filters.add(paramFilter);
		}
		if (getFilter().getContainerProcessId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("containerProcessId");
			paramFilter.setValue(getFilter().getContainerProcessId().toString());
			filters.add(paramFilter);
		}
//		DateFormat sdf = DateFormat.getInstance();
//		sdf.setCalendar(Calendar.getInstance());
//		sdf.getTimeZone().getID();
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
//		df.setTimeZone(TimeZone.getTimeZone(timeZone));
		if (getFilter().getStartDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("startDate");
			paramFilter.setValue(df.format(getFilter().getStartDate()));
			filters.add(paramFilter);
		}
		if (getFilter().getEndDate() != null) {
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(getFilter().getEndDate());
			calendar.add(Calendar.DAY_OF_MONTH, 1);
			paramFilter = new Filter();
			paramFilter.setElement("endDate");
			paramFilter.setValue(df.format(calendar.getTime()));
			filters.add(paramFilter);
		}
		if (getFilter().getProcessName() != null
				&& getFilter().getProcessName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("processName");
			paramFilter.setValue(getFilter().getProcessName().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (getFilter().getProcessId() != null) {
			filters.add(new Filter("processId", getFilter().getProcessId()));
		}
		if (getFilter().getSessionIdFilter() != null && getFilter().getSessionIdFilter().trim().length() > 0) {
			filters.add(new Filter("sessionId", getFilter().getSessionIdFilter().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_")));
		}
	}

	public DaoDataModel<ProcessSession> getProcessSessions() {
		return processSessionSource;
	}

	public void search() {
		clear();
		setSearching(true);
		processSessionSource.flushCache();
	}

	public void clearFilter() {
		filter = new ProcessSession();
		activeProcessSession = null;
		setSearching(false);
		processSessionSource.flushCache();
		clear();
		clearSectionFilter();
	}

	private void clear() {
		MbProcessHierarchy mbProcessHierarchy = (MbProcessHierarchy) ManagedBeanWrapper
				.getManagedBean("MbProcessHierarchy");
		mbProcessHierarchy.setSearching(false);

		MbProcessLaunchParameters mbProcessLaunchParameters = (MbProcessLaunchParameters) ManagedBeanWrapper
				.getManagedBean("MbProcessLaunchParameters");
		mbProcessLaunchParameters.setSessionId(null);

		MbOperationsStat opersBean = (MbOperationsStat) ManagedBeanWrapper
				.getManagedBean("MbOperationsStat");
		opersBean.clearFilter();

	}

	public SimpleSelection getItemSelection() {
		if (activeProcessSession == null && processSessionSource.getRowCount() > 0) {
			processSessionSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			activeProcessSession = (ProcessSession) processSessionSource.getRowData();
			selection.addKey(activeProcessSession.getModelId());
			processSessionSelection.setWrappedSelection(selection);
			setInfo();
		} else if (activeProcessSession != null && processSessionSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeProcessSession.getModelId());
			processSessionSelection.setWrappedSelection(selection);
			activeProcessSession = processSessionSelection.getSingleSelection();
		}
		return processSessionSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		processSessionSelection.setWrappedSelection(selection);
		activeProcessSession = processSessionSelection.getSingleSelection();
		setInfo();
	}

	private void setInfo() {
		if (activeProcessSession != null) {
			if (tabName.equalsIgnoreCase("traceTab")) {
				MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper
						.getManagedBean("MbProcessTrace");
				traceBean.setSessionId(activeProcessSession.getSessionId());
				traceBean.setThreadCount(activeProcessSession.getThreadCount());
				traceBean.search();
			} else if (tabName.equalsIgnoreCase("statTab")) {
				MbProcessStat statBean = (MbProcessStat) ManagedBeanWrapper
						.getManagedBean("MbProcessStat");
				statBean.setSessionId(activeProcessSession.getSessionId());
				statBean.search();
			} else if (tabName.equalsIgnoreCase("hierarchyTab")) {
				MbProcessHierarchy mbProcessHierarchy = (MbProcessHierarchy) ManagedBeanWrapper
						.getManagedBean("MbProcessHierarchy");
				mbProcessHierarchy.setSessionId(activeProcessSession.getSessionId());
			} else if (tabName.equalsIgnoreCase("paramTab")) {
				MbProcessLaunchParameters mbProcessLaunchParameters = (MbProcessLaunchParameters) ManagedBeanWrapper
						.getManagedBean("MbProcessLaunchParameters");
				mbProcessLaunchParameters.setSessionId(activeProcessSession.getSessionId());
			} else if (tabName.equalsIgnoreCase("fileTab")) {
				MbSessionFiles mbSessionFiles = (MbSessionFiles) ManagedBeanWrapper
						.getManagedBean("MbSessionFiles");
				mbSessionFiles.setSessionId(activeProcessSession.getSessionId());
			} else if (tabName.equalsIgnoreCase("operStatsTab")) {
				MbOperationsStat opersBean = (MbOperationsStat) ManagedBeanWrapper
						.getManagedBean("MbOperationsStat");
				opersBean.setSessionId(activeProcessSession.getSessionId());
				opersBean.search();
			}
		}
	}

	public ProcessSession getFilter() {
		if (filter == null) {
			filter = new ProcessSession();
			Calendar cal = Calendar.getInstance();
			cal.setTime(new Date());
			cal.set(Calendar.HOUR_OF_DAY, 0);
			cal.set(Calendar.MINUTE, 0);
			cal.set(Calendar.SECOND, 0);
			cal.set(Calendar.MILLISECOND, 0);
			filter.setStartDate(new Date(cal.getTimeInMillis()));
		}
		return filter;
	}

	public void setFilter(ProcessSession filter) {
		this.filter = filter;
	}

	public ProcessSession getActiveProcessSession() {
		return activeProcessSession;
	}

	public void setActiveProcessSession(ProcessSession activeProcessSession) {
		this.activeProcessSession = activeProcessSession;
	}

	public boolean isPollingEnabled() {
		if (activeProcessSession == null) {
			return false;
		}
		if ("PROCESS WORKS".equals(activeProcessSession.getProcessState())) {
			return true;
		}
		return false;
	}

	public void updateSessions() {
		ProcessSession updatedSession = null;
		SelectionParams params = SelectionParams.build("id", activeProcessSession.getId());
		ProcessSession[] sessions = _processDao.getProcessSessions(userSessionId, params);
		if (sessions.length != 0) {
			updatedSession = sessions[0];
		}
		try {
			processSessionSource.replaceObject(activeProcessSession, updatedSession);
			activeProcessSession = updatedSession;
		} catch (Exception e) {
			throw new IllegalStateException(e);
		}
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(activeProcessSession.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		try {
			ProcessSession[] items = _processDao.getProcessSessions(userSessionId, params);
			if (items != null && items.length > 0) {
				activeProcessSession = items[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;

		if (tabName.equalsIgnoreCase("processTab")) {
			MbProcessStat bean = (MbProcessStat) ManagedBeanWrapper
					.getManagedBean("MbProcessStat");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("traceTab")) {
			MbProcessTrace bean = (MbProcessTrace) ManagedBeanWrapper
					.getManagedBean("MbProcessTrace");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));

		} else if (tabName.equalsIgnoreCase("paramTab")) {
			MbProcessLaunchParameters bean = (MbProcessLaunchParameters) ManagedBeanWrapper
					.getManagedBean("MbProcessLaunchParameters");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("fileTab")) {
			MbSessionFiles bean = (MbSessionFiles) ManagedBeanWrapper
					.getManagedBean("MbSessionFiles");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("operStatsTab")) {
			MbOperationsStat bean = (MbOperationsStat) ManagedBeanWrapper
					.getManagedBean("MbOperationsStat");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {
		setInfo();
	}

	public String getSectionId() {
		return SectionIdConstants.MONITORING_PROCESS_LOG;
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

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new ProcessSession();
				setFilterForm(filterRec);
				if (searchAutomatically)
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
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

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

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		getFilter();
		filters = new ArrayList<Filter>();
		if (filterRec.get("processName") != null) {
			filter.setProcessName(filterRec.get("processName"));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("startDate") != null) {
			filter.setStartDate(df.parse(filterRec.get("startDate")));
		}
		if (filterRec.get("endDate") != null) {
			filter.setEndDate(df.parse(filterRec.get("endDate")));
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {
		if (filter.getProcessName() != null) {
			filterRec.put("processName", filter.getProcessName());
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getEndDate() != null) {
			filterRec.put("startDate", df.format(filter.getEndDate()));
		}
		if (filter.getStartDate() != null) {
			filterRec.put("endDate", df.format(filter.getStartDate()));
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ArrayList<SelectItem> getprocesses() {
		if (processes == null) {
			processes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.PROCESSES_AND_CONTAINERS);
		}
		if (processes == null)
			processes = new ArrayList<SelectItem>();
		return processes;
	}

	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)) {
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}

	public ContextType getCtxType() {
		if (ctxType == null) return null;
		Map<String, Object> map = new HashMap<String, Object>();
		if (activeProcessSession != null) {
			if (EntityNames.SESSION.equals(ctxItemEntityType)) {
				map.put("id", activeProcessSession.getSessionId());
			}

		}

		ctxType.setParams(map);
		return ctxType;
	}

	public boolean isForward() {
		return !ctxItemEntityType.equals(EntityNames.SESSION);
	}

	public void setupOperTypeSelection() {
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr", "select_oper_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);

		context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.SESSION);
		context.put(MbOperTypeSelectionStep.OBJECT_ID, activeProcessSession.getSessionId());
		context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);
	}

}

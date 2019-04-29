package ru.bpc.sv2.ui.process.monitoring;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.reports.MbEntityObjectInfoBottom;
import ru.bpc.sv2.ui.reports.MbReportsBottom;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;
import util.servlet.FileServlet;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.net.URLEncoder;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbProcessFilesMonitor")
public class MbProcessFilesMonitor  extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PROCESSES");

	private static String COMPONENT_ID = "2321:mainTable";

	private ProcessDao _processDao = new ProcessDao();

	private final DaoDataModel<ProcessSession> processSessionSource;
	private final TableRowSelection<ProcessSession> processSessionSelection;
	private ProcessSession filter;
	private ProcessSession activeProcessSession;
	private String action = null;
	private String fileLink = null;

	private ArrayList<SelectItem> processes;	
	private ArrayList<SelectItem> filePurpose;
	private ArrayList<SelectItem> fileType;

	private String tabName;
	private String needRerender;
	private List<String> rerenderList;
	
	private String ctxItemEntityType;
	private ContextType ctxType;

	public MbProcessFilesMonitor() {
		tabName = "traceTab";
		pageLink = "processes|files_list";
		processSessionSource = new DaoDataModel<ProcessSession>() {
			@Override
			protected ProcessSession[] loadDaoData(SelectionParams params) {
				ProcessSession[] result;
				if (!isSearching()) {
					result = new ProcessSession[0];
				} else {
					try {
						setFilters();
						params.setFilters(filters);
						result = _processDao.getSessionFilesList(userSessionId, params, true);
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
						params.setFilters(filters);
						result = _processDao.getSessionFilesListCount(userSessionId, params, true);
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

	public void link(){

		File file = getFileLocation(activeProcessSession);
		if (file.exists()){
			try {
				action = "click";
				fileLink = URLEncoder.encode(file.getName(), "UTF-8");
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				action = "show";
			}
		}else {
			action = "show";
		}
		HttpServletRequest req = RequestContextHolder.getRequest();
		HttpSession session = req.getSession();
		ByteArrayOutputStream outStream = new ByteArrayOutputStream();
		try {
			getFileContent(file.getPath(), outStream);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
		session.setAttribute(FileServlet.FILE_SERVLET_FILE_CONTENT, outStream.toByteArray());
	}
	
	private File getFileLocation(ProcessSession item){
		String subDir = "";
		String location = item.getLocation();
		String fileName = item.getFileName();
		
		if (item.getPurpose().equals(ProcessConstants.FILE_PURPOSE_INCOMING)){
			subDir = "processed";
			String path = location + (location.endsWith("/")?"":"/") +subDir+ "/" + fileName;
			File file = new File(path);
			if (!file.exists()) {
				subDir = "rejected";
			}
		}
		String path = location + (location.endsWith("/")?"":"/") +subDir+ "/" + fileName;
		return new File(path);
	}
	
	public void getFileContent(String savePath, ByteArrayOutputStream outStream) throws IOException {
		FileInputStream in = null;
		try {
			in = new FileInputStream(savePath);
			byte[] buf = new byte[1024];
			int len;
			while ((len = in.read(buf)) > 0){
				outStream.write(buf, 0, len);
			}
		} catch (IOException e) {
			throw e;
		} finally {
			if (in != null) {
				in.close();
			}
		}
	}
	
	public String getAction(){
		return action;
	}
	
	public String getFileLink(){
		return fileLink;
	}
	
	public void setFilters() {
		filters = new ArrayList<Filter>();
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);

		filters.add(Filter.create("lang", userLang));
		filters.add(Filter.create("notStatus", ProcessConstants.FILE_STATUS_MERGED));

		if (getFilter().getStartDate() != null) {
			filters.add(Filter.create("startDate", df.format(getFilter().getStartDate())));
		}
		if (getFilter().getEndDate() != null) {
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(getFilter().getEndDate());
			calendar.add(Calendar.DAY_OF_MONTH, 1);
			filters.add(Filter.create("endDate", df.format(calendar.getTime())));
		}
		if (getFilter().getProcessId() != null) {
			filters.add(Filter.create("processId", getFilter().getProcessId().toString()));
		}
		if (StringUtils.isNotBlank(getFilter().getSessionIdFilter())) {
			filters.add(Filter.create("sessionId", Filter.mask(getFilter().getSessionIdFilter())));
		}
		if (StringUtils.isNotBlank(getFilter().getFileName())) {
			filters.add(Filter.create("fileName", Filter.mask(getFilter().getFileName())));
		}
		if (StringUtils.isNotBlank(getFilter().getFileType())) {
			filters.add(Filter.create("fileType", getFilter().getFileType()));
		}
		if (StringUtils.isNotBlank(getFilter().getPurpose())) {
			filters.add(Filter.create("purpose", getFilter().getPurpose()));
		}
	}

	public ProcessSession getFilter() {
		if (filter == null)
			filter = new ProcessSession();
		return filter;
	}
	
	public String getSectionId() {
		return SectionIdConstants.MONITORING_PROCESS_FILES;
	}
	
	public ArrayList<SelectItem> getprocesses() {
		if (processes == null) {
			processes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.PROCESSES_AND_CONTAINERS);
		}
		return processes;
	}
	
	public ArrayList<SelectItem> getFilePurpose() {
		if (filePurpose == null) {
			filePurpose = getDictUtils().getArticles(DictNames.PROCESS_FILE_PURPOSE, true, true);
		}
		return filePurpose;
	}
	
	public ArrayList<SelectItem> getFileType() {
		if (fileType == null) {
			fileType = getDictUtils().getArticles(DictNames.PROCESS_FILE_TYPE, true, true);
		}
		return fileType;
	}


	public DaoDataModel<ProcessSession> getProcessSessions() {
		return processSessionSource;
	}

	public void search() {
		clear();
		activeProcessSession = null;
		setSearching(true);
		processSessionSource.flushCache();
	}

	public void clearFilter() {
		filter = new ProcessSession();
		activeProcessSession = null;
		setSearching(false);
		processSessionSource.flushCache();
		clearSectionFilter();
		clear();
	}
	private void clear() {
		MbOperationsStat opersBean = (MbOperationsStat) ManagedBeanWrapper
				.getManagedBean("MbOperationsStat");
		opersBean.clearFilter();
		
		MbReportsBottom reportsBean = (MbReportsBottom) ManagedBeanWrapper
				.getManagedBean("MbReportsBottom");
		reportsBean.clearFilter();
		
		MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper
				.getManagedBean("MbProcessTrace");
		traceBean.clearFilter();
		
		MbEntityObjectInfoBottom info = (MbEntityObjectInfoBottom) ManagedBeanWrapper
				.getManagedBean("MbEntityObjectInfoBottom");
		info.clearFilter();
		
		
		
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
			} else if (tabName.equalsIgnoreCase("operStatTab")) {
				MbOperationsStat opersBean = (MbOperationsStat) ManagedBeanWrapper
						.getManagedBean("MbOperationsStat");

                opersBean.clearFilter();
				opersBean.setSessionFileId(activeProcessSession.getId());
				opersBean.search();
			} else if (tabName.equalsIgnoreCase("reportTab")) {
				MbReportsBottom reportsBean = (MbReportsBottom) ManagedBeanWrapper
						.getManagedBean("MbReportsBottom");
				reportsBean.setEntityType("ENTTSSFL");
				reportsBean.setObjectType(activeProcessSession.getFileType());
				reportsBean.setObjectId(activeProcessSession.getId());
				reportsBean.search();
			} else if (tabName.equalsIgnoreCase("info")) {
				MbEntityObjectInfoBottom infoBean = (MbEntityObjectInfoBottom) ManagedBeanWrapper
						.getManagedBean("MbEntityObjectInfoBottom");
				infoBean.setEntityType("ENTTSSFL");
				infoBean.setObjectType(activeProcessSession.getFileType());
				infoBean.setObjectId(activeProcessSession.getId());
				infoBean.search();
			}
		}
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

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		
		 if (tabName.equalsIgnoreCase("traceTab")) {
			MbProcessTrace bean = (MbProcessTrace) ManagedBeanWrapper
					.getManagedBean("MbProcessTrace");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		 } else if (tabName.equalsIgnoreCase("operStatTab")) {
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
		if (filterRec.get("processId") != null) {
			filter.setProcessName(filterRec.get("processId"));
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("startDate") != null) {
			filter.setStartDate(df.parse(filterRec.get("startDate")));
		}
		if (filterRec.get("endDate") != null) {
			filter.setEndDate(df.parse(filterRec.get("endDate")));
		}
		if (filterRec.get("fileName") != null) {
			filter.setFileName(filterRec.get("fileName"));
		}
		if (filterRec.get("fileType") != null) {
			filter.setFileType(filterRec.get("fileType"));
		}
		if (filterRec.get("purpose") != null) {
			filter.setPurpose(filterRec.get("purpose"));
		}
		
	}

	private void setFilterRec(Map<String, String> filterRec) {
		if (filter.getProcessId() != null) {
			filterRec.put("processId", filter.getProcessId().toString());
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getEndDate() != null) {
			filterRec.put("startDate", df.format(filter.getEndDate()));
		}
		if (filter.getStartDate() != null) {
			filterRec.put("endDate", df.format(filter.getStartDate()));
		}
		if (filter.getFileName() != null) {
			filterRec.put("fileName", filter.getFileName());
		}
		if (filter.getFileType() != null) {
			filterRec.put("fileType", filter.getFileType());
		}
		if (filter.getPurpose() != null) {
			filterRec.put("purpose", filter.getPurpose());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		if (activeProcessSession != null){
			if (EntityNames.SESSION.equals(ctxItemEntityType)) {
				map.put("id", activeProcessSession.getSessionId());
			}
			
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.SESSION);
	}
	
	public void setupOperTypeSelection(){
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr","select_oper_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);
		
		context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.SESSION_FILE);
		context.put(MbOperTypeSelectionStep.OBJECT_ID, activeProcessSession.getId());
        context.put(MbOperTypeSelectionStep.INST_ID, activeProcessSession.getInstId());

		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);		
	}
	
	public void updateSessionFiles(){
		ProcessSession updatedSession = null;		
		SelectionParams params = SelectionParams.build("id", activeProcessSession.getId());
		ProcessSession[] sessions = _processDao.getSessionFilesList(userSessionId, params, true);
		if (sessions.length != 0){
			updatedSession = sessions[0];
		}
		try {
			processSessionSource.replaceObject(activeProcessSession, updatedSession);
			activeProcessSession = updatedSession;
		} catch (Exception e) {
			throw new IllegalStateException(e);
		}
	}
}

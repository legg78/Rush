package ru.bpc.sv2.ui.process.monitoring;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbProcessSessions")
public class MbProcessSessions extends AbstractTreeBean<ProcessSession> {
    private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PROCESSES");

	private static String COMPONENT_ID = "1028:mainTable";

	private ProcessDao _processDao = new ProcessDao();

    private ProcessSession newNode;
    private ProcessSession detailNode;
	private MbOracleTracing traceNode;

    private String tabName;

    private MbProcSess procSess;

	private ProcessSession filter;

	private ArrayList<SelectItem> processes;

    protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
    private String needRerender;
	private List<String> rerenderList;
	private ArrayList<SelectItem> institutions;
	private String ctxItemEntityType;
	private ContextType ctxType;

	private int rowFrom = 0;
	private int currentPage = 1;
	List<Integer> pagesList;
	private int listStart = 1;
	private int listEnd = 1;
	
	/* CommonUtils's rowsNumsList is not suitable as 
	 * 300 records usually can not be rendered */
	private static List<SelectItem> rowsNumsList;	
	static {
		rowsNumsList = new ArrayList<SelectItem>();
		rowsNumsList.add(new SelectItem(10, "10"));
		rowsNumsList.add(new SelectItem(20, "20"));
		rowsNumsList.add(new SelectItem(30, "30"));
		rowsNumsList.add(new SelectItem(50, "50"));		
		rowsNumsList.add(new SelectItem(100, "100"));
	}

	public MbProcessSessions() {

		pageLink = "processes|sessions";
		tabName = "detailsTab";

        procSess = (MbProcSess) ManagedBeanWrapper.getManagedBean("MbProcSess");
        Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");

        // restore state
        if (menu.isKeepState()) {
            nodePath = procSess.getNodePath();
            filter = procSess.getFilter();
            tabName = procSess.getTabName();
            if (nodePath != null) {
                currentNode = (ProcessSession) nodePath.getValue();
                if (currentNode != null) {
                    try {
                        detailNode = currentNode.clone();
                    } catch (CloneNotSupportedException e) {
                        FacesUtils.addMessageError(e);
                        logger.error("", e);
                    }
                }
                setInfo(true);
            }
            searching = true;
            // reset keep state flag
            menu.setKeepState(false);
        } else {
            searching = false;
        }
	}

	public MbOracleTracing getTraceNode(){
		if (traceNode == null) {
			traceNode = (MbOracleTracing)ManagedBeanWrapper.getManagedBean("MbOracleTracing");
		}
		traceNode.setUserSessionId( userSessionId );
		traceNode.setSessionId( getNode().getSessionId() );
		traceNode.setTraceLevel( getNode().getTraceLevel() );
		traceNode.setTraceLimit( getNode().getTraceLimit() );
		traceNode.setThreadNumber( getNode().getThreadNumber() );
		return traceNode;
	}

    public ProcessSession getNode() {
        if (currentNode == null) {
            currentNode = new ProcessSession();
        }
        return currentNode;
    }

    public void setNode(ProcessSession node) {
        try {
            curLang = userLang;
            if (node == null)
                return;

            boolean changeSelect = false;
            if (!node.getSessionId().equals(getNode().getSessionId())) {
                changeSelect = true;
            }

            this.currentNode = node;
            setInfo(false);

            if (changeSelect) {
                detailNode = (ProcessSession) currentNode.clone();
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
    }

    private void setInfo(boolean restoreState) {
        loadedTabs.clear();
        loadTab(getTabName(), restoreState);
    }

    public boolean getNodeHasChildren() {
        return getProcessSession() != null && getProcessSession().isHasChildren();
    }

    public List<ProcessSession> getNodeChildren() {
        ProcessSession processSession = getProcessSession();
        if (processSession == null) {
            if (!treeLoaded || coreItems == null) {
                loadTree();
            }   
            return coreItems.subList(Math.min(coreItems.size(), rowFrom), Math.min(coreItems.size(), rowFrom + super.rowsNum));            
        } else {
            return processSession.getChildren();
        }
    }
    
	public void nextPage() {
		if (getHasNextPage()) {
			rowFrom += super.rowsNum;
			++currentPage;
		}
	}

	public void prevPage() {
		if (getHasPrevPage()) {
			rowFrom -= super.rowsNum;
			--currentPage;
		}
	}

	public void firstPage() {
		rowFrom = 0;
		currentPage = 1;
		listStart = 1;
	}
    
    public void lastPage(){
        currentPage = this.getPageCount();
        rowFrom = (currentPage - 1) * super.rowsNum;    
    }
    
	public List<Integer> getPagesList() {
		pagesList = new ArrayList<Integer>();
		int pgMax = 10;
		int curPage = getCurrentPage();
		int pgCount = getPageCount();
		if (pgCount <= pgMax) { /* all pages can fit into the list */
			listStart = 1;
			listEnd = pgCount;
		} else { /* pgCount > pgMax: we have to use $pgMax-page 'window' */
			if (curPage <= listStart) { /* first in a list page has been selected */
				listStart = Math.max(listStart - 1, 1);
				listEnd = Math.min(listStart + pgMax - 1, pgCount);
			} else {
				if (curPage >= listEnd) { /* last in a list page has been selected */
					listEnd = Math.min(curPage + 1, pgCount);
					listStart = Math.max(listEnd - pgMax + 1, 1);			
				} 
				/* else leave the list as it is */
			}
		}
		
		for (int i = listStart; i <= listEnd; i++) {
			pagesList.add(i);
		}
		return pagesList;
	}
    
    public boolean getHasNextPage() {
    	return currentPage < getPageCount();
    }
    
    public boolean getHasPrevPage() {
    	return currentPage > 1 ;
    }
    
	public List<SelectItem> getRowNumsList() {
		return rowsNumsList;
	}

    private void loadTab(String tab, boolean restoreState) {
        if (tab == null)
            return;
        if (currentNode == null || currentNode.getSessionId() == null) {
            needRerender = tab;
            return;
        }
        if (tab.equalsIgnoreCase("traceTab")) {
            MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper
                    .getManagedBean("MbProcessTrace");
            traceBean.setSessionId(currentNode.getSessionId());
            traceBean.setThreadCount(currentNode.getThreadCount());
            traceBean.search();
        } else if (tab.equalsIgnoreCase("statTab")) {
            MbProcessStat statBean = (MbProcessStat) ManagedBeanWrapper
                    .getManagedBean("MbProcessStat");
            statBean.setSessionId(currentNode.getSessionId());
            statBean.search();
        } else if (tab.equalsIgnoreCase("hierarchyTab")) {
            MbProcessHierarchy mbProcessHierarchy = (MbProcessHierarchy) ManagedBeanWrapper
                    .getManagedBean("MbProcessHierarchy");
            mbProcessHierarchy.setSessionId(currentNode.getSessionId());
        } else if (tab.equalsIgnoreCase("paramTab")) {
            MbProcessLaunchParameters mbProcessLaunchParameters = (MbProcessLaunchParameters) ManagedBeanWrapper
                    .getManagedBean("MbProcessLaunchParameters");
            mbProcessLaunchParameters.setSessionId(currentNode.getSessionId());
        } else if (tab.equalsIgnoreCase("fileTab")) {
            MbSessionFiles mbSessionFiles = (MbSessionFiles) ManagedBeanWrapper
                    .getManagedBean("MbSessionFiles");
            mbSessionFiles.setSessionId(currentNode.getSessionId());
        } else if (tab.equalsIgnoreCase("operStatsTab")) {
            MbOperationsStat opersBean = (MbOperationsStat) ManagedBeanWrapper
                    .getManagedBean("MbOperationsStat");
            opersBean.clearFilter();
            opersBean.setSessionId(currentNode.getSessionId());
            opersBean.search();
        }
        needRerender = tab;
        loadedTabs.put(tab, Boolean.TRUE);
    }

    public HashMap<String, Boolean> getLoadedTabs() {
        return loadedTabs;
    }

    public void clearLoadedTabs() {
        loadedTabs.clear();
    }

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);

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
		if (getFilter().getInstId() != null) {
			filters.add(new Filter("instId", getFilter().getInstId()));
		}
	}

	public void search() {
        curMode = VIEW_MODE;
        nodePath = null;
        currentNode = null;
        searching = true;
        firstPage();
        clear();
        loadTree();
	}

	public void clearFilter() {
        curMode = VIEW_MODE;
        currentNode = null;
        detailNode = null;
        nodePath = null;
        treeLoaded = false;
        searching = false;
        filter = null;
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


	public boolean isPollingEnabled() {
		if (currentNode == null) {
			return false;
		}
		if ("PROCESS WORKS".equals(currentNode.getProcessState())) {
			return true;
		}
		return false;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(currentNode.getSessionId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		try {
			ProcessSession[] items = _processDao.getProcessSessions(userSessionId, params);
			if (items != null && items.length > 0) {
                currentNode = items[0];
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
        procSess.setTabName(tabName);
		this.tabName = tabName;

        Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

        if (isLoadedCurrentTab == null) {
            isLoadedCurrentTab = Boolean.FALSE;
        }

        if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
            return;
        }

        loadTab(tabName, false);

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
			filterRec.put("endDate", df.format(filter.getEndDate()));
		}
		if (filter.getStartDate() != null) {
			filterRec.put("startDate", df.format(filter.getStartDate()));
		}
		if (filter.getProcessId() != null) {
			filterRec.put("processId", filter.getProcessId().toString());
		}
		if (filter.getSessionIdFilter() != null && filter.getSessionIdFilter().length() > 0) {
			filterRec.put("sessionId", filter.getSessionIdFilter());
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ArrayList<SelectItem> getProcesses() {
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
		if (currentNode != null) {
			if (EntityNames.SESSION.equals(ctxItemEntityType)) {
				map.put("id", currentNode.getSessionId());
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
		context.put(MbOperTypeSelectionStep.OBJECT_ID, currentNode.getSessionId());
		context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
        context.put(MbOperTypeSelectionStep.INST_ID, currentNode.getInstId());

		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);
	}

    private ProcessSession getProcessSession() {
        return (ProcessSession) Faces.var("prcss");
    }

    protected void loadTree() {
        try{
            coreItems = new ArrayList<ProcessSession>();
            if (!searching)
                return;

            setFilters();
			if (getFilter().getProcessId() != null) {
				SelectionParams paramsBO = new SelectionParams();
				paramsBO.setFilters(new Filter[]{new Filter("id", getFilter().getProcessId())});
				ProcessBO[] processBOs = _processDao.getAllProcesses(userSessionId, paramsBO);
				if (processBOs.length > 0){
					if (processBOs[0].isContainer()) {
						filters.add(new Filter("container", processBOs[0].isContainer()));
					} else {
						filters.add(new Filter("process", processBOs[0].isContainer()));
					}
				}
			}
            SelectionParams params = new SelectionParams();
            params.setFilters(filters.toArray(new Filter[filters.size()]));
            
            //TreeTable has sortColumnId="sessionId", so apply sessionId as default sorter
          	SortElement[] sorters = new SortElement[1];
    		sorters[0] = new SortElement("sessionId", Direction.DESC);
    		params.setSortElement(sorters);    
    		
            ProcessSession[] processSessions;
//			if (getFilter().getProcessId() != null){
//				processSessions = _processDao.getProcessSessionsWithParams(userSessionId, params);
//			}else{
				processSessions = _processDao.getProcessSessions(userSessionId, params);
//			}
            if (processSessions != null && processSessions.length > 0) {
                addNodes(0, coreItems, processSessions);
                if (nodePath == null) {
                    if (currentNode == null) {
                        currentNode = coreItems.get(0);
                        detailNode = currentNode.clone();
                        setNodePath(new TreePath(currentNode, null));
                    } else {
                        if (currentNode.getParentId() != null) {
                            setNodePath(formNodePath(processSessions));
                        } else {
                            setNodePath(new TreePath(currentNode, null));
                        }
                    }
                }
                setInfo(false);
            }
            treeLoaded = true;
        } catch (Exception ee) {
            FacesUtils.addMessageError(ee);
            logger.error("", ee);
        }
    }

    public TreePath getNodePath() {
        return nodePath;
    }

    public void setNodePath(TreePath nodePath) {
        this.nodePath = nodePath;
        procSess.setNodePath(nodePath);
    }

    public Comparator<Object> getNameComparator() {
        return new Comparator<Object>() {
            @Override
            public int compare(Object o10, Object o20) {
                if (o10 instanceof String && o20 instanceof String){
                    String o1=(String)o10;
                    String o2=(String)o20;
                    if (o1 == null || o1.equals(""))
                        return -1;
                    if (o2 == null || o2.equals(""))
                        return 1;
                    return o1.toUpperCase().compareTo(o2.toUpperCase());
                }
                if (o10 instanceof Long && o20 instanceof Long){
                    Long o1=(Long)o10;
                    Long o2=(Long)o20;
                    if (o1 == null)
                        return -1;
                    if (o2 == null)
                        return 1;
                    return o1.compareTo(o2);
                }
				if (o10 instanceof Date && o20 instanceof Date){
					Date o1=(Date)o10;
					Date o2=(Date)o20;
					if (o1 == null)
						return -1;
					if (o2 == null)
						return 1;
					return o1.compareTo(o2);
				}
                return 0;
            }
        };
    }
    

	@Override
	public void setRowsNum(int rowsNum) {
		if (super.rowsNum != rowsNum) {
			super.rowsNum = rowsNum;
			this.firstPage();
		}
	}

	public int getCurrentPage() {
		return currentPage;
	}

	public void setCurrentPage(int currentPage) {
		if (currentPage > 0) {
			rowFrom = (currentPage - 1) * super.rowsNum;
			this.currentPage = currentPage;
		}
	}

	public int getPageCount() {
		return (int) Math.ceil((double) (coreItems != null ? coreItems.size() : 0) / super.rowsNum);
	}

	public int getRowCount() {
		return (coreItems != null ? coreItems.size() : 0);
	}

	public void enableTracing() {
		getTraceNode().enableTracing();
	}

	public void setInstitutions(ArrayList<SelectItem> institutions) {
		this.institutions = institutions;
	}
}

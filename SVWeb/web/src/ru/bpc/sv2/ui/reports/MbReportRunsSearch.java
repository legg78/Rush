package ru.bpc.sv2.ui.reports;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
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

import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.reports.ReportRun;
import ru.bpc.sv2.reports.ReportRunParameter;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbReportRunsSearch")
public class MbReportRunsSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("REPORTS");
	
	private static String COMPONENT_ID = "1513:reportsTable";

	private ReportsDao _reportsDao = new ReportsDao();
	
	DictUtils dictUtils;
    
	private List<Filter> filters;
    
    private ReportRun filter;
    private ReportRun _activeReportRun;
    private ReportRun newReportRun;

	private final DaoDataModel<ReportRun> _reportRunsSource;

	private final TableRowSelection<ReportRun> _itemSelection;

	private String tabName = "detailsTab";
	private String needRerender;
	private List<String> rerenderList;

	public MbReportRunsSearch() {
		pageLink = "reports|runs";
		dictUtils = (DictUtils)ManagedBeanWrapper.getManagedBean("DictUtils");
		filters = new ArrayList<Filter>();

		_reportRunsSource = new DaoDataModel<ReportRun>()
		{
			@Override
			protected ReportRun[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReportRun[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportRuns( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new ReportRun[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _reportsDao.getReportRunsCount( userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ReportRun>( null, _reportRunsSource);

		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals(getSectionId())) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
    }

    public DaoDataModel<ReportRun> getReportRuns() {
		return _reportRunsSource;
	}

	public ReportRun getActiveReportRun() {
		return _activeReportRun;
	}

	public void setActiveReportRun(ReportRun activeReportRun) {
		_activeReportRun = activeReportRun;
	}

	public SimpleSelection getItemSelection() {
		if (_activeReportRun == null && _reportRunsSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeReportRun != null && _reportRunsSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeReportRun.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeReportRun = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_reportRunsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeReportRun = (ReportRun) _reportRunsSource.getRowData();
		selection.addKey(_activeReportRun.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeReportRun != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeReportRun = _itemSelection.getSingleSelection();
		if (_activeReportRun != null) {
			setInfo();
		}
	}

	public void setInfo() {
		loadCurrentTab();
	}
	
	public void clearBeansStates() {
		MbReportRunParametersSearch paramsSearch = (MbReportRunParametersSearch)ManagedBeanWrapper.getManagedBean("MbReportRunParametersSearch");
		paramsSearch.clearState();
		paramsSearch.setFilter(null);
		paramsSearch.setSearching(false);
	}
	
	public void search() {
		clearState();
		searching = true;		
	}
	
	public void clearFilter() {
		filter = new ReportRun();		
		clearState();
		searching = false;	
		clearSectionFilter();
	}
	
	public ReportRun getFilter() {
		if (filter == null)
			filter = new ReportRun();
		return filter;
	}

	public void setFilter(ReportRun filter) {
		this.filter = filter;
	}

	private void setFilters() {
	
		Filter paramFilter;
		filter = getFilter();
		filters = new ArrayList<Filter>();

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
	
		if (filter.getReportId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("reportId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getReportId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		
		if (filter.getDescription() != null && filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		
		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStatus());
			filters.add(paramFilter);
		}
		
		if (filter.getUser() != null && filter.getUser().trim().length() > 0) {
			filters.add(new Filter("user", filter.getUser().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase()));
		}
		
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (filter.getStartDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("startDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getStartDateFrom()));
			filters.add(paramFilter);
		}
		if (filter.getStartDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("startDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getStartDateTo()));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newReportRun = new ReportRun();
		newReportRun.setReportId(getFilter().getReportId());
		newReportRun.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newReportRun = (ReportRun) _activeReportRun.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newReportRun = _activeReportRun;
		}
		curMode = EDIT_MODE;
	}

	public void view() {
		
	}
	
	public void save() {
		try {
			if (isNewMode()) {
				
			} else if (isEditMode()) {
			
			}
						
			curMode = VIEW_MODE;
			_reportRunsSource.flushCache();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}

	public void delete() {
		try {
				
			_itemSelection.clearSelection();
			_reportRunsSource.flushCache();
			_activeReportRun = null;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public ReportRun getNewReportRun() {
		if (newReportRun == null) {
			newReportRun = new ReportRun();		
		}
		return newReportRun;
	}

	public void setNewReportRun(ReportRun newReportRun) {
		this.newReportRun = newReportRun;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeReportRun = null;			
		_reportRunsSource.flushCache();
		curLang = userLang;
	}
	
	public ArrayList<SelectItem> getReportStatuses() {
		return getDictUtils().getArticles(DictNames.REPORT_STATUSES, false, false);		
	}
	
	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();
		_reportRunsSource.flushCache();
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		
		if (tabName == null)
			return;

		if (tabName.equalsIgnoreCase("parametersTab")) {
			MbReportRunParametersSearch bean = (MbReportRunParametersSearch) ManagedBeanWrapper
					.getManagedBean("MbReportRunParametersSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeReportRun == null) {
			MbReportRunParametersSearch paramsSearch = (MbReportRunParametersSearch)ManagedBeanWrapper.getManagedBean("MbReportRunParametersSearch");
			paramsSearch.clearFilter();
			return;
		}
		if (tab.equalsIgnoreCase("parametersTab")) {
			MbReportRunParametersSearch paramsSearch = (MbReportRunParametersSearch)ManagedBeanWrapper.getManagedBean("MbReportRunParametersSearch");
			ReportRunParameter paramFilter = new ReportRunParameter();
			paramFilter.setRunId(_activeReportRun.getId());
			paramsSearch.setFilter(paramFilter);
			paramsSearch.search();
		} else if (tabName.equalsIgnoreCase("logsTab")){
			MbReportRunLogsSearch bean = (MbReportRunLogsSearch)
					ManagedBeanWrapper.getManagedBean(MbReportRunLogsSearch.class);
			bean.getFilter().setObjectId(_activeReportRun.getReportId().longValue());
			bean.getFilter().setEntityType("ENTTREPT");
			bean.search();
		}
	}

	public String getSectionId() {
		return SectionIdConstants.MONITORING_REPORT;
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
				filter = new ReportRun();
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
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("id") != null) {
			filter.setId(Long.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		if (filterRec.get("user") != null) {
			filter.setUser(filterRec.get("user"));
		}
		if (filterRec.get("name") != null) {
			filter.setName(filterRec.get("name"));
		}
		if (filterRec.get("startDateFrom") != null) {
			filter.setStartDateFrom(df.parse(filterRec.get("startDateFrom")));
		}
		if (filterRec.get("startDateTo") != null) {
			filter.setStartDateTo(df.parse(filterRec.get("startDateTo")));
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getStatus() != null) {
			filterRec.put("status", filter.getStatus());
		}
		if (filter.getUser() != null) {
			filterRec.put("user", filter.getUser().toString());
		}
		if (filter.getName() != null) {
			filterRec.put("name", filter.getName());
		}
		if (filter.getStartDateFrom() != null) {
			filterRec.put("startDateFrom", df.format(filter.getStartDateFrom()));
		}
		if (filter.getStartDateTo() != null) {
			filterRec.put("startDateTo", df.format(filter.getStartDateTo()));
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}

package ru.bpc.sv2.ui.process.monitoring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessUserSession;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbProcessUserSessions")
public class MbProcessUserSessions extends AbstractBean {
	private static final long serialVersionUID = 8359981452740374087L;

	private static final Logger logger = Logger.getLogger("PROCESSES");

	private static String COMPONENT_ID = "1615:usessionsTable";

	private ProcessDao _processDao = new ProcessDao();

	private boolean filterError = false;
	private ProcessUserSession oldFilter;

	private ProcessUserSession filter;
	private ProcessUserSession _activeUserSession;

	private final DaoDataModel<ProcessUserSession> _userSessionsSource;
	private final TableRowSelection<ProcessUserSession> _itemSelection;

	private String tabName;

	public MbProcessUserSessions() {
		oldFilter = new ProcessUserSession();
		pageLink = "processes|user_sessions";
		_userSessionsSource = new DaoDataModel<ProcessUserSession>() {
			private static final long serialVersionUID = 8218009706779661588L;

			@Override
			protected ProcessUserSession[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ProcessUserSession[0];
				}

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getProcessUserSessions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessUserSession[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				int count = 0;
				int threshold = 300;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setThreshold(threshold);
					count = _processDao.getProcessUserSessionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				if (count >= threshold) {
					FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "many_records"));
				}
				return count;
			}
		};

		_itemSelection = new TableRowSelection<ProcessUserSession>(null, _userSessionsSource);
		tabName = "traceTab";
	}

	public DaoDataModel<ProcessUserSession> getUserSessions() {
		return _userSessionsSource;
	}

	public ProcessUserSession getActiveUserSession() {
		return _activeUserSession;
	}

	public void setActiveUserSession(ProcessUserSession activeUserSession) {
		_activeUserSession = activeUserSession;
	}

	public SimpleSelection getItemSelection() {
		if (_activeUserSession == null && _userSessionsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeUserSession != null && _userSessionsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeUserSession.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeUserSession = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeUserSession = _itemSelection.getSingleSelection();

		if (_activeUserSession != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_userSessionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeUserSession = (ProcessUserSession) _userSessionsSource.getRowData();
		selection.addKey(_activeUserSession.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeUserSession != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper.getManagedBean("MbProcessTrace");
		traceBean.setSessionId(_activeUserSession.getId());
		traceBean.search();
	}

	public void clearFilter() {
		filter = new ProcessUserSession();
		oldFilter = new ProcessUserSession();
		clearBean();

		searching = false;
	}

	public void search() {
		if (filter.getStartDate() != null && filter.getLastUsed() != null
				&& filter.getStartDate().after(filter.getLastUsed())) {
			filterError = true;
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"start_date_gt_last_used")));
			// logger2.error("tralala", new Exception(
			// FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "start_date_gt_last_used")));
			return;
		}

		clearBean();
		oldFilter = filter.copy();
		filterError = false;
		searching = true;
	}

	private void setFilters() {
		// if there is a filter error then we use old filter,
		// otherwise - apply current filter values
		if (filterError) {
			filter = oldFilter.copy();
		} else {
			filter = getFilter();
		}
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("allSessionslang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		filters.add(new Filter("ipAddressNot", ProcessConstants.OLTP_IP_ADDRESS_IN_USER_SESSION));

		if (filter.getUserName() != null && filter.getUserName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("userName");
			paramFilter.setValue(filter.getUserName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getSurname() != null && filter.getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("surname");
			paramFilter
					.setValue(filter.getSurname().trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (filter.getStartDate() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("startDate");
			paramFilter.setValue(df.format(filter.getStartDate()));
			filters.add(paramFilter);
		}

		if (filter.getLastUsed() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("lastUsed");
			paramFilter.setValue(df.format(filter.getLastUsed()));
			filters.add(paramFilter);
		}

		if (filter.getIpAddress() != null && filter.getIpAddress().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("ipAddress");
			paramFilter.setValue(filter.getIpAddress().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public ProcessUserSession getFilter() {
		if (filter == null) {
			filter = new ProcessUserSession();
			filter.setStartDate(new Date());
			filter.setLastUsed(new Date());
		}
		return filter;
	}

	public void setFilter(ProcessUserSession filter) {
		this.filter = filter;
	}

	public void cancel() {

	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeUserSession = null;
		_userSessionsSource.flushCache();

		clearBeans();
	}

	public void clearBeans() {
		MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper.getManagedBean("MbProcessTrace");
		traceBean.fullCleanBean();
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeUserSession.getId());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			ProcessUserSession[] nets = _processDao.getProcessUserSessions(userSessionId, params);
			if (nets != null && nets.length > 0) {
				_activeUserSession = nets[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public String getSectionId() {
		return SectionIdConstants.MONITORING_USER_SESSION;
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

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

	private void setFilterRec(Map<String, String> filterRec) {
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getUserName() != null && filter.getUserName().length() > 0) {
			filterRec.put("userName", filter.getUserName());
		}
		if (filter.getSurname() != null && filter.getSurname().length() > 0){
			filterRec.put("surname", filter.getSurname());
		}
		if (filter.getStartDate() != null){
			filterRec.put("startDate", df.format(filter.getStartDate()));
		}
		if (filter.getLastUsed() != null){
			filterRec.put("lastUsed", df.format(filter.getLastUsed()));
		}
		if (filter.getIpAddress() != null && filter.getIpAddress().length() > 0){
			filterRec.put("ipAddress", filter.getIpAddress());
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
				filter = new ProcessUserSession();
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

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		getFilter();
		filters = new ArrayList<Filter>();
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("userName") != null){
			filter.setUserName(filterRec.get("userName"));
		}
		if (filterRec.get("surname") != null){
			filter.setSurname(filterRec.get("surname"));
		}
		if (filterRec.get("startDate") != null){
			filter.setStartDate(df.parse(filterRec.get("startDate")));
		}
		if (filterRec.get("lastUsed") != null){
			filter.setLastUsed(df.parse(filterRec.get("lastUsed")));
		}
		if (filterRec.get("ipAddress") != null){
			filter.setIpAddress(filterRec.get("ipAddress"));
		}
	}
}

package ru.bpc.sv2.ui.process;

import java.text.DateFormatSymbols;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.schedule.CronFormatException;
import ru.bpc.sv2.schedule.CronFormatter;
import ru.bpc.sv2.schedule.ScheduledTask;
import ru.bpc.sv2.scheduler.WebSchedule;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbContainerTasksSearch")
public class MbContainerTasksSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private ProcessDao _processDao = new ProcessDao();

	private MbContainersAll procBean;

	private ScheduledTask _activeTask;
	private ScheduledTask newTask;

	
	private ScheduledTask filter;

	private String backLink;
	private boolean showModal;
	private boolean selectMode;

	public int dayType; // we use strictly either day of month or day of week
						// option, not both

	private final DaoDataModel<ScheduledTask> _tasksSource;

	private final TableRowSelection<ScheduledTask> _itemSelection;
	private static final Logger logger = Logger.getLogger("PROCESSES");
	private final List<SelectItem> months;
	private final String FEBRUARY = "FEB";
	private final String[] monthsShort = { "JAN", FEBRUARY, "MAR", "APR", "MAY", "JUN", "JUL", "AUG",
			"SEP", "OCT", "NOV", "DEC" };	
	
	private boolean error;
	private boolean warning;
	private String message;
	
	@SuppressWarnings("serial")
	private final Map<String, String> shortMonths = new HashMap<String, String>() {
		{
			put(FEBRUARY, "");
			put("APR", "");
			put("JUN", "");
			put("SEP", "");
			put("NOV", "");
		}
	};
	
	private static String COMPONENT_ID = "accountsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbContainerTasksSearch() {

		_tasksSource = new DaoDataModel<ScheduledTask>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ScheduledTask[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ScheduledTask[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getTasks(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ScheduledTask[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _processDao.getTasksCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<ScheduledTask>(null, _tasksSource);
		procBean = (MbContainersAll) ManagedBeanWrapper.getManagedBean("MbContainersAll");

		DateFormatSymbols symbols = new DateFormatSymbols(FacesContext.getCurrentInstance()
				.getViewRoot().getLocale());
		months = new ArrayList<SelectItem>(12);
		String[] monthNames = symbols.getMonths();
		// give months normal short names not ambiguous numbers
		// java.text.DateFormatSymbols.getMonths() returns 13 months
		for (int i = 0; i < 12; i++) {
			months.add(new SelectItem(monthsShort[i], monthNames[i]));
		}
	}

	public DaoDataModel<ScheduledTask> getTasks() {
		return _tasksSource;
	}

	public ScheduledTask getActiveTask() {
		return _activeTask;
	}

	public void setActiveTask(ScheduledTask activeTask) {
		_activeTask = activeTask;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeTask == null && _tasksSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeTask != null && _tasksSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeTask.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeTask = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_tasksSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTask = (ScheduledTask) _tasksSource.getRowData();
		selection.addKey(_activeTask.getModelId());
		_itemSelection.setWrappedSelection(selection);
		setInfo();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTask = _itemSelection.getSingleSelection();
		setInfo();
	}

	public void setInfo() {

	}

	public void search() {
		setSearching(true);
		_tasksSource.flushCache();
		_activeTask = null;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filter = getFilter();

		Filter paramFilter = null;

		if (filter.getShortDesc() != null && !filter.getShortDesc().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getShortDesc().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
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

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}

	public ScheduledTask getFilter() {
		if (filter == null)
			filter = new ScheduledTask();
		return filter;
	}

	public void setFilter(ScheduledTask filter) {
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

	public String cancelSelect() {
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void view() {
		try {
			_activeTask.setFormedCronString(_activeTask.getCronString());
			_activeTask.getCronFormatter().setSkipHolidays(_activeTask.isSkipHolidays());
		} catch (UserException e) {
			logger.error("", e);
		}
		curMode = VIEW_MODE;
	}

	public void add() {
		newTask = new ScheduledTask();
		newTask.setLang(userLang);
		newTask.getCronFormatter().setDayType(CronFormatter.WEEK_DAY);
		newTask.getCronFormatter().setEveryMonth(true);

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			_activeTask.getCronFormatter().setSkipHolidays(_activeTask.isSkipHolidays());
			newTask = (ScheduledTask) _activeTask.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newTask = _activeTask;
		}
		try {
			newTask.setFormedCronString(newTask.getCronString());
			newTask.getCronFormatter().setSkipHolidays(newTask.isSkipHolidays());
		} catch (UserException e) {
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		clearErrors();
		try {
			checkCronString(newTask);
			if (checkDaysOfMonth(newTask)) {
				saveConfirmed();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void saveConfirmed() {
		clearErrors();
		try {
			procBean.stop();
			newTask.setCronString(newTask.getCronFormatter().formCronString());
			newTask.setPrcId(getFilter().getContainerId());
			newTask.setSkipHolidays(newTask.getCronFormatter().isSkipHolidays());
			if (isNewMode()) {
				newTask = _processDao.createTask(userSessionId, newTask);
				_itemSelection.addNewObjectToList(newTask);
				if (newTask.isActive()){
					WebSchedule schedule = WebSchedule.getInstance();
					if (schedule.isStarted()) {
						schedule.addScheduledTask(newTask);
					}					
				}
			} else {
				newTask = _processDao.modifyTask(userSessionId, newTask);
				_tasksSource.replaceObject(_activeTask, newTask);
				if (newTask.isActive()){
					WebSchedule schedule = WebSchedule.getInstance();
					if (schedule.isStarted()) {
						schedule.modifyScheduledTask(newTask);
					}					
				}
			}
			_activeTask = newTask;
			curMode = VIEW_MODE;
			setInfo();
			procBean.start();
		} catch (CronFormatException ce) {
			FacesUtils.addMessageError(ce);
			logger.error("", ce);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		List<ScheduledTask> tasksToDel = _itemSelection.getMultiSelection();
		if (_activeTask != null) {
			try {
				_processDao.deleteTasks(userSessionId, tasksToDel
						.toArray(new ScheduledTask[tasksToDel.size()]));
				WebSchedule schedule = WebSchedule.getInstance();
				if (schedule.isStarted()) {
					for (ScheduledTask task : tasksToDel) {
						schedule.removeScheduledTask(task);
					}
				}
			} catch (Exception ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
		_activeTask = null;
		_itemSelection.clearSelection();
		_tasksSource.flushCache();
	}

	private void checkCronString(ScheduledTask qr) throws Exception {
		if (!qr.getCronFormatter().isEveryMinute()
				&& (qr.getCronFormatter().getCronMinutes().getStartTime() == null || qr
						.getCronFormatter().getCronMinutes().getStartTime().equals("")))
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "minute_sched_req"));
		
		if (!qr.getCronFormatter().isEveryHour()
				&& (qr.getCronFormatter().getCronHours().getStartTime() == null || qr
						.getCronFormatter().getCronHours().getStartTime().equals("")))
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "hour_sched_req"));
		
		if (!qr.getCronFormatter().isEveryDay() && !qr.getCronFormatter().isDailyScheduled()
				&& !qr.getCronFormatter().isWeeklyScheduled())
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "day_sched_req"));

		if (qr.getCronFormatter().isDailyScheduled() && qr.getCronFormatter().getDays().size() == 0)
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "day_sched_req"));

		if (qr.getCronFormatter().isWeeklyScheduled()
				&& qr.getCronFormatter().getDaysList().size() == 0)
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "day_sched_req"));
		
		if (!qr.getCronFormatter().isEveryMonth()
				&& (qr.getCronFormatter().getCronMonths().getStartTime() == null || qr
						.getCronFormatter().getCronMonths().getStartTime().equals("")))
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "month_sched_req"));
	}

	public void deleteTask() {
		try {
			_processDao.deleteTask(userSessionId, _activeTask.getId());

			_tasksSource.flushCache();
			_itemSelection.clearSelection();
			_activeTask = null;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void clearState() {
		_tasksSource.flushCache();
		_itemSelection.clearSelection();
		_activeTask = null;

		curLang = userLang;
	}

	public String selectTask() {

		return backLink;
	}

	public List<SelectItem> getDays() {
		List<SelectItem> arr = new ArrayList<SelectItem>(32);
		arr.add(new SelectItem("1"));
		arr.add(new SelectItem("2"));
		arr.add(new SelectItem("3"));
		arr.add(new SelectItem("4"));
		arr.add(new SelectItem("5"));
		arr.add(new SelectItem("6"));
		arr.add(new SelectItem("7"));
		arr.add(new SelectItem("8"));
		arr.add(new SelectItem("9"));
		arr.add(new SelectItem("10"));
		arr.add(new SelectItem("11"));
		arr.add(new SelectItem("12"));
		arr.add(new SelectItem("13"));
		arr.add(new SelectItem("14"));
		arr.add(new SelectItem("15"));
		arr.add(new SelectItem("16"));
		arr.add(new SelectItem("17"));
		arr.add(new SelectItem("18"));
		arr.add(new SelectItem("19"));
		arr.add(new SelectItem("20"));
		arr.add(new SelectItem("21"));
		arr.add(new SelectItem("22"));
		arr.add(new SelectItem("23"));
		arr.add(new SelectItem("24"));
		arr.add(new SelectItem("25"));
		arr.add(new SelectItem("26"));
		arr.add(new SelectItem("27"));
		arr.add(new SelectItem("28"));
		arr.add(new SelectItem("29"));
		arr.add(new SelectItem("30"));
		arr.add(new SelectItem("31"));
		arr.add(new SelectItem("L"));
		return arr;
	}

	public ScheduledTask getNewTask() {
		return newTask;
	}

	public void setNewTask(ScheduledTask newTask) {
		this.newTask = newTask;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_tasksSource.flushCache();
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newTask.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newTask.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ScheduledTask[] items = _processDao.getTasks(userSessionId, params);
			if (items != null && items.length > 0) {
				newTask.setShortDesc(items[0].getShortDesc());
				newTask.setFullDesc(items[0].getFullDesc());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<SelectItem> getMonths() {
		return months;
	}
	
	public void activateTask() {
		List<ScheduledTask> tasks = _itemSelection.getMultiSelection();
		
		WebSchedule schedule = WebSchedule.getInstance();
		
		for (ScheduledTask task: tasks) {
			if (task.isActive()) {
				continue;
			}
			
			task.setActive(true);
			try {
				task = _processDao.modifyTask(userSessionId, task);
			} catch (Exception e) {
				logger.error("", e);
				task.setActive(false);
				continue;
			}
			
			if (!schedule.isStarted()) {
				continue;
			}
			
			try {
				schedule.addScheduledTask(task);
			} catch (Exception e) {
				logger.error("", e);
				
				task.setActive(false);
				try {
					task = _processDao.modifyTask(userSessionId, task);
				} catch (Exception ex) {
					logger.error("", ex);
				}
			}
		}
	}

	public void deactivateTask() {
		List<ScheduledTask> tasks = _itemSelection.getMultiSelection();

		WebSchedule schedule = WebSchedule.getInstance();
		
		for (ScheduledTask task: tasks) {
			if (!task.isActive()) {
				continue;
			}
			
			task.setActive(false);
			try {
				task = _processDao.modifyTask(userSessionId, task);
			} catch (Exception e) {
				logger.error("", e);
				task.setActive(true);
				continue;
			}
			
			if (!schedule.isStarted()) {
				continue;
			}
			
			try {
				schedule.removeScheduledTask(task);
			} catch (Exception e) {
				logger.error("", e);
				
				task.setActive(true);
				try {
					task = _processDao.modifyTask(userSessionId, task);
				} catch (Exception ex) {
					logger.error("", ex);
				}
			}
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	
	private boolean checkDaysOfMonth(ScheduledTask newTask) {
		if (newTask.getCronFormatter().isEveryDay() || newTask.getCronFormatter().isWeeklyScheduled()) {
			return true;
		}
		
		boolean februaryRestricted = false;
		boolean shortMonthsRestricted = false;
		boolean goodDate = false;
		
		for (String day : newTask.getCronFormatter().getDays()) {
			if ("L".equals(day)) continue;
			int x = Integer.parseInt(day);
			if (x == 30) {
				februaryRestricted = true;
			} else if (x == 31) {
				shortMonthsRestricted = true;
			} else {
				goodDate = true;
			}
		}
		
		if (goodDate && !februaryRestricted && !shortMonthsRestricted) {
			return true;
		}
		
		if (newTask.getCronFormatter().getCronMonths().isPeriodicalRepeatEnabled()
				&& !newTask.getCronFormatter().isEveryMonth()) {
			int next = -1;
			int first = -1;
			int interval = Integer.parseInt(newTask.getCronFormatter().getCronMonths().getTimePeriod());
			for (int i = 0; i < monthsShort.length; i++) {
				if (newTask.getCronFormatter().getCronMonths().getStartTime().equals(monthsShort[i])) {
					next = first = i;
					break;
				}
			}
			
			boolean elsaGood = false;
			boolean killEmAll = false;
			for (int i = 0; i < monthsShort.length; i++) {
				if (shortMonths.containsKey(monthsShort[next])
						&& (shortMonthsRestricted || (FEBRUARY.equals(monthsShort[next]) && februaryRestricted))) {
					killEmAll = true;
				} else {
					elsaGood = true;
				}
				next += interval;
				if (next >= monthsShort.length) {
					next -= monthsShort.length;
				}
				if (next == first) {
					break;
				}
			}
			
			if (killEmAll) {
				if (elsaGood) {
					message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "dates_are_not_in_months");
					setWarning();
				} else {
					message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "sched_not_executable");
					setError();
				}
				return false;
			}
		} else {
			if (newTask.getCronFormatter().isEveryMonth() && (februaryRestricted || shortMonthsRestricted)) {
				message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "dates_are_not_in_months");
				setWarning();
				return false;
			}
			if (FEBRUARY.equals(newTask.getCronFormatter().getCronMonths().getStartTime()) && februaryRestricted) {
				if (goodDate) {
					message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "dates_are_not_in_month");
					setWarning();
				} else {
					message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "sched_not_executable");
					setError();
				}
				return false;
			}
			if (shortMonths.get(newTask.getCronFormatter().getCronMonths().getStartTime()) != null
					&& shortMonthsRestricted) {
				if (goodDate || februaryRestricted) {
					message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "dates_are_not_in_month");
					setWarning();
				} else {
					message = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Process", "sched_not_executable");
					setError();
				}
				return false;
			}
		}
		return true;
	}

	public boolean isError() {
		return error;
	}

	public boolean isWarning() {
		return warning;
	}

	public String getMessage() {
		return message;
	}
	
	private void setWarning() {
		warning = true;
		error = false;
	}

	private void setError() {
		error = true;
		warning = false;
	}
	
	private void clearErrors() {
		error = false;
		warning = false;
		message = null;
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

package ru.bpc.sv2.ui.common.days;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.StateHoliday;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleShiftsSearch;
import ru.bpc.sv2.ui.fcl.cycles.MbCyclesSearch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbStateHoliday")
public class MbStateHoliday extends AbstractBean{
	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "stateHolidaysTable";

	private CommonDao _commonDao = new CommonDao();

	private ArrayList<SelectItem> institutions;

	private StateHoliday _activeStateHoliday;
	private final DaoDataModel<StateHoliday> _stateHolidaySource;
	private final TableRowSelection<StateHoliday> _itemSelection;

	private StateHoliday newStateHoliday;

	private Integer day;
	private Integer month;

	
	private MbCycleShiftsSearch shiftsBean;
	private MbCyclesSearch cyclesBean;

	public MbStateHoliday() {
		
		shiftsBean = (MbCycleShiftsSearch) ManagedBeanWrapper.getManagedBean("MbCycleShiftsSearch");
		cyclesBean = (MbCyclesSearch) ManagedBeanWrapper.getManagedBean("MbCyclesSearch");

		_stateHolidaySource = new DaoDataModel<StateHoliday>() {
			@Override
			protected StateHoliday[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new StateHoliday[0];
				}
				setFilters();
				try {
					return _commonDao.getStateHolidays(userSessionId, params, userLang);
				} catch (Exception e) {
					setDataSize(0);
					logger.error(e);
					FacesUtils.addMessageError(e);
					return new StateHoliday[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				setFilters();
				try {
					return _commonDao.getStateHolidayCounts(userSessionId);
				} catch (Exception e) {
					logger.error(e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<StateHoliday>(null, _stateHolidaySource);
	}

	public DaoDataModel<StateHoliday> getStateHolidays() {
		return _stateHolidaySource;
	}

	public StateHoliday getActiveStateHoliday() {
		return _activeStateHoliday;
	}

	public void setActiveStateHoliday(StateHoliday activeStateHoliday) {
		_activeStateHoliday = activeStateHoliday;
	}

	public SimpleSelection getItemSelection() {
		if (_activeStateHoliday == null && _stateHolidaySource.getRowCount() > 0) {
			setFirstRowActive();
		}
		if (_activeStateHoliday != null && _stateHolidaySource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeStateHoliday.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeStateHoliday = _itemSelection.getSingleSelection();
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeStateHoliday = _itemSelection.getSingleSelection();
		if (_activeStateHoliday != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_stateHolidaySource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeStateHoliday = (StateHoliday) _stateHolidaySource.getRowData();
		selection.addKey(_activeStateHoliday.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	private void setBeans() {

	}

	private void setFilters() {

	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		clearBean();
		searching = false;
	}

	public void clearBean() {
		_stateHolidaySource.flushCache();
		_itemSelection.clearSelection();
		_activeStateHoliday = null;
	}

	public void add() {
		curMode = NEW_MODE;
		day = null;
		month = null;
		newStateHoliday = new StateHoliday();
		newStateHoliday.setLang(userLang);
		// initialize cycles' bean
		cyclesBean.add();

		// initialize shifts' bean
		shiftsBean.setSearching(true);
		shiftsBean.fullCleanBean();
		shiftsBean.setDontSave(true);
		shiftsBean.setCycleId(-1); // just temporary id to unblock buttons
		shiftsBean.setDisableAll(false);
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newStateHoliday = _activeStateHoliday.clone();
		} catch (CloneNotSupportedException e) {
			newStateHoliday = _activeStateHoliday;
		}
		// initialize cycles' bean
		cyclesBean.setNewCycle(cyclesBean.getCycleById(newStateHoliday.getCycleId()));
		cyclesBean.setCurMode(MbCyclesSearch.EDIT_MODE);

		// initialize shifts' bean
		shiftsBean.setSearching(true);
		shiftsBean.fullCleanBean();
		shiftsBean.setDontSave(true);
		shiftsBean.setCycleId(newStateHoliday.getCycleId());
		shiftsBean.setDisableAll(false);
	}

	public void delete() {
		try {
			_commonDao.removeStateHoliday(userSessionId, _activeStateHoliday.getId());
			_activeStateHoliday = _itemSelection.removeObjectFromList(_activeStateHoliday);

			if (_activeStateHoliday == null) {
				clearBean();
			} else {
				setBeans();
			}
			FacesUtils.addMessageInfo("State holiday has been deleted.");
			curMode = VIEW_MODE;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			Cycle cycle = cyclesBean.getNewCycle();
			cycle.setInstId(newStateHoliday.getInstId());
			ArrayList<CycleShift> newShifts = shiftsBean.getStoredCycleShifts();

			if (isNewMode()) {
				newStateHoliday = _commonDao.addStateHoliday(userSessionId, newStateHoliday, cycle,
						newShifts);
				_itemSelection.addNewObjectToList(newStateHoliday);
			} else {
				ArrayList<CycleShift> oldShifts = shiftsBean.getInitialCycleShifts();
				newStateHoliday = _commonDao.editStateHoliday(userSessionId, newStateHoliday,
						cycle, newShifts, oldShifts);
				_stateHolidaySource.replaceObject(_activeStateHoliday, newStateHoliday);
			}

			FacesUtils.addMessageInfo("State holiday has been added.");
			_activeStateHoliday = newStateHoliday;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public StateHoliday getNewStateHoliday() {
		return newStateHoliday;
	}

	public void setNewStateHoliday(StateHoliday newStateHoliday) {
		this.newStateHoliday = newStateHoliday;
	}

	public SelectItem[] getDays() {
		ArrayList<SelectItem> arr = new ArrayList<SelectItem>();
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
		if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10
				|| month == 12) {
			return (SelectItem[]) arr.subList(0, 31).toArray(new SelectItem[31]);
		} else if (month == 4 || month == 6 || month == 9 || month == 11) {
			return (SelectItem[]) arr.subList(0, 30).toArray(new SelectItem[30]);
		} else {
			return (SelectItem[]) arr.subList(0, 29).toArray(new SelectItem[29]);
		}
	}

	public Integer getDay() {
		return day;
	}

	public void setDay(Integer day) {
		this.day = day;
	}

	public Integer getMonth() {
		return month;
	}

	public void setMonth(Integer month) {
		this.month = month;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
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

}

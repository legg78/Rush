package ru.bpc.sv2.ui.fcl.cycles;

import java.util.ArrayList;



import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@SessionScoped
@ManagedBean (name = "MbCycleShifts")
public class MbCycleShifts extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("FCL");

	private CyclesDao _cyclesDao = new CyclesDao();

	private CycleShift _activeCycleShift;

	private final DaoDataModel<CycleShift> _cycleShiftsSource;

	private final TableRowSelection<CycleShift> _itemSelection;

	private boolean _managingNew;

	private String fromOutcome;

	private CycleShift filter;
	private Filter[] filters;
	transient 
	private String backLink;

	public MbCycleShifts() {
		_cycleShiftsSource = new DaoDataModel<CycleShift>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected CycleShift[] loadDaoData(SelectionParams params) {
				if (getFilter().getCycleId() == null)
					return new CycleShift[0];
				try {
					setFilters();
					params.setFilters(filters);
					return _cyclesDao.getCycleShifts(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CycleShift[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (getFilter().getCycleId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters);
					return _cyclesDao.getCycleShiftsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CycleShift>(null, _cycleShiftsSource);
	}

	public DaoDataModel<CycleShift> getCycleShifts() {
		return _cycleShiftsSource;
	}

	public CycleShift getActiveCycleShift() {
		return _activeCycleShift;
	}

	public void setActiveCycleShift(CycleShift activeCycleShift) {
		_activeCycleShift = activeCycleShift;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCycleShift = _itemSelection.getSingleSelection();
	}

	public String createCycleShift() {
		if (_activeCycleShift != null)
			_itemSelection.unselect(_activeCycleShift);
		setActiveCycleShift(new CycleShift());
		_managingNew = true;

		return "open_details";
	}

	public String editCycleShift() {
		_managingNew = false;

		return "open_details";
	}

	public String commit() {
		try {
			if (_managingNew) {
				_cyclesDao.createCycleShift(userSessionId, _activeCycleShift);
			} else {
				_cyclesDao.updateCycleShift(userSessionId, _activeCycleShift);
			}

			FacesUtils.addMessageInfo("Cycle shift \"" + _activeCycleShift.getId() + "\" saved");

			_cycleShiftsSource.flushCache();
			_activeCycleShift = null;

			if (fromOutcome == null || fromOutcome.equals("")) {
				return "success";
			} else if (fromOutcome.equals("list_cycles")) {
				fromOutcome = null;
				return "successToCycles";
			}

			return "success";
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			return "failure";
		}
	}

	public String deleteCycleShift() {
		try {
			_cyclesDao.deleteCycleShift(userSessionId, _activeCycleShift);

			FacesUtils.addMessageInfo("Cycle shift \"" + _activeCycleShift.getId()
					+ "\" was deleted");

			_cycleShiftsSource.flushCache();
			_activeCycleShift = null;

			return "success";
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			return "failure";
		}
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getShiftTypes() {
		return getDictUtils().getArticles(DictNames.SHIFT_TYPES, true, true);
	}

	public ArrayList<SelectItem> getLengthTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true, false);
	}

	public ArrayList<SelectItem> getCycles() {

		ArrayList<SelectItem> items = null;
		try {
			Cycle[] cyclesArr = _cyclesDao.getCycles(userSessionId, null);
			SelectItem si;
			items = new ArrayList<SelectItem>(cyclesArr.length);
			for (Cycle cycle : cyclesArr) {
				si = new SelectItem((Integer) cycle.getId(), Integer.toString(cycle.getId()));

				items.add(si);
			}

		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public String getFromOutcome() {
		return fromOutcome;
	}

	public void setFromOutcome(String fromOutcome) {
		this.fromOutcome = fromOutcome;
	}

	public void search() {
		_cycleShiftsSource.flushCache();
	}

	public void setFilters() {
		int i = 0;
		if (getFilter().getCycleId() != null && !getFilter().getCycleId().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("cycleId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCycleId().toString());
			filters = new Filter[1];
			filters[i++] = paramFilter;
		}
	}

	public CycleShift getFilter() {
		if (filter == null)
			filter = new CycleShift();
		return filter;
	}

	public void setFilter(CycleShift filter) {
		this.filter = filter;
	}

	public String cancel() {
		_activeCycleShift = null;
		return backLink;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub

	}
}

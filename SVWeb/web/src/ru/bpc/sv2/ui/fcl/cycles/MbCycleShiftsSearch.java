package ru.bpc.sv2.ui.fcl.cycles;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbCycleShiftsSearch")
public class MbCycleShiftsSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FCL");

	// hard code rules!
	private final String SHIFT_TYPE_PERIOD = "CSHTPERD"; // shift by period
	private final String SHIFT_TYPE_WDAY = "CSHTWDAY"; // shift to exact day of
														// week
	private final String SHIFT_TYPE_MDAY = "CSHTMDAY"; // shift to exact day of
														// month

	private CyclesDao _cyclesDao = new CyclesDao();

	private CycleShift _activeCycleShift;
	private CycleShift newCycleShift;
	private final DaoDataModel<CycleShift> _cycleShiftsSource;

	private final TableRowSelection<CycleShift> _itemSelection;

	private boolean _managingNew;

	private CycleShift filter;
	
	private String backLink;
	private Integer cycleId;

	private ArrayList<CycleShift> initialCycleShifts; // to keep initial state
	private ArrayList<CycleShift> storedCycleShifts; // for current work
	private boolean dontSave;
	private boolean disableAll;
	private int fakeId; // is used for feeRates that are added but not saved yet
						// (required for correct data table behaviour)
	private static String COMPONENT_ID = "shitfsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbCycleShiftsSearch() {
		
		fakeId = -1;

		_cycleShiftsSource = new DaoDataModel<CycleShift>() {
			@Override
			protected CycleShift[] loadDaoData(SelectionParams params) {
				if (!searching || cycleId == null)
					return new CycleShift[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (dontSave) {

						// if we don't want to immediately save all changes that
						// have been done to this cycle shifts set then we will
						// work with temporary array list which is first
						// initiated with values from DB. To find changes that
						// were made
						// one more array is created and is not changed
						// (actually
						// we could read it from DB again but then we would have
						// to
						// read it from DB :))

						if (storedCycleShifts == null) {
							CycleShift[] shifts = _cyclesDao.getCycleShifts(userSessionId, params);
							storedCycleShifts = new ArrayList<CycleShift>(shifts.length);
							initialCycleShifts = new ArrayList<CycleShift>(shifts.length);
							for (CycleShift shift: shifts) {
								storedCycleShifts.add(shift);
								initialCycleShifts.add(shift);
							}
						}
						return (CycleShift[]) storedCycleShifts
								.toArray(new CycleShift[storedCycleShifts.size()]);
					}
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
				if (!searching || cycleId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (dontSave && storedCycleShifts != null) {
						return storedCycleShifts.size();
					}
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
		if (_activeCycleShift == null && _cycleShiftsSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCycleShift = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_cycleShiftsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCycleShift = (CycleShift) _cycleShiftsSource.getRowData();
		selection.addKey(_activeCycleShift.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void add() {
		newCycleShift = new CycleShift();

		if (dontSave) {
			newCycleShift.setId(fakeId--);
			if (storedCycleShifts == null) {
				storedCycleShifts = new ArrayList<CycleShift>();
				initialCycleShifts = new ArrayList<CycleShift>();
			}
		}

		newCycleShift.setCycleId(cycleId);
		_managingNew = true;
	}

	public void edit() {
		_managingNew = false;
		try {
			newCycleShift = _activeCycleShift.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newCycleShift = new CycleShift();
		}
	}

	public void save() {
		try {
			if (!checkPriority()) {
				throw new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Msg", "change_priority"));
			}
			
			if (_managingNew && dontSave) {
				storedCycleShifts.add(newCycleShift);
			} else if (_managingNew && !dontSave) {
				_cyclesDao.createCycleShift(userSessionId, newCycleShift);
			} else if (!_managingNew && dontSave) {
				storedCycleShifts.remove(_activeCycleShift);
				storedCycleShifts.add(newCycleShift);
			} else if (!_managingNew && !dontSave) {
				_cyclesDao.updateCycleShift(userSessionId, newCycleShift);
			}
			_cycleShiftsSource.flushCache();
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void delete() {
		try {
			if (dontSave) {
				storedCycleShifts.remove(_activeCycleShift);
			} else {
				_cyclesDao.deleteCycleShift(userSessionId, _activeCycleShift);
			}

			_cycleShiftsSource.flushCache();

			if (_itemSelection != null) {
				_itemSelection.unselect(_activeCycleShift);
			}
			_activeCycleShift = null;

		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	private boolean checkPriority() {
		// if we edit cycle shift skip priority check if it wasn't changed
		if (!_managingNew && _activeCycleShift.getPriority().equals(newCycleShift.getPriority())) {
			return true;
		}
		
		List<CycleShift> cycleShifts;
		if (dontSave) {
			cycleShifts = storedCycleShifts;
		} else {
			cycleShifts = _cycleShiftsSource.getActivePage();
		}

		for (CycleShift shift: cycleShifts) {
			if (shift.getPriority().equals(newCycleShift.getPriority())) {
				return false;
			}
		}
		return true;
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

	public void search() {
		setSearching(true);
		clearBean();
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (cycleId != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("cycleId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(cycleId.toString());
			filtersList.add(paramFilter);
		}
		filters = filtersList;
	}

	public CycleShift getFilter() {
		if (filter == null)
			filter = new CycleShift();
		return filter;
	}

	public void setFilter(CycleShift filter) {
		this.filter = filter;
	}

	public void cancel() {

	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public CycleShift getNewCycleShift() {
		if (newCycleShift == null)
			newCycleShift = new CycleShift();
		return newCycleShift;
	}

	public void setNewCycleShift(CycleShift newCycleShift) {
		this.newCycleShift = newCycleShift;
	}

	public void fullCleanBean() {
		cycleId = null;
		storedCycleShifts = null;

		clearBean();
	}

	public void clearBean() {
		_activeCycleShift = null;
		_itemSelection.clearSelection();
		_cycleShiftsSource.flushCache();
	}

	public ArrayList<CycleShift> getStoredCycleShifts() {
		return storedCycleShifts;
	}

	public void setStoredCycleShifts(ArrayList<CycleShift> storedCycleShifts) {
		this.storedCycleShifts = storedCycleShifts;
	}

	public boolean isDontSave() {
		return dontSave;
	}

	public void setDontSave(boolean dontSave) {
		this.dontSave = dontSave;
	}

	public ArrayList<CycleShift> getInitialCycleShifts() {
		return initialCycleShifts;
	}

	public void setInitialCycleShifts(ArrayList<CycleShift> initialCycleShifts) {
		this.initialCycleShifts = initialCycleShifts;
	}

	public boolean isDisableAll() {
		return disableAll;
	}

	public void setDisableAll(boolean disableAll) {
		this.disableAll = disableAll;
	}

	public Integer getCycleId() {
		return cycleId;
	}

	public void setCycleId(Integer cycleId) {
		this.cycleId = cycleId;
	}

	public boolean getNeedLengthType() {
		return SHIFT_TYPE_PERIOD.equals(getNewCycleShift().getShiftType());
	}

	public void validateLength(FacesContext context, UIComponent toValidate, Object value) {
		Integer newLength = (Integer) value;
		if (newLength.intValue() <= 0) {
			((UIInput) toValidate).setValid(false);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl", "shift_length_mb_pos");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
		if (SHIFT_TYPE_WDAY.equals(newCycleShift.getShiftType()) && newLength.intValue() > 7) {
			((UIInput) toValidate).setValid(false);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl", "wday_restr");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
		if (SHIFT_TYPE_MDAY.equals(newCycleShift.getShiftType()) && newLength.intValue() > 31) {
			((UIInput) toValidate).setValid(false);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl", "mday_restr");
			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
			context.addMessage(toValidate.getClientId(context), message);
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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

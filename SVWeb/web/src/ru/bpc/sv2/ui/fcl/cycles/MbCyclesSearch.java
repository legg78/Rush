package ru.bpc.sv2.ui.fcl.cycles;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCyclesSearch")
public class MbCyclesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FCL");

	private static String COMPONENT_ID = "1049:mainTable";

	private CyclesDao _cyclesDao = new CyclesDao();
	
	private Cycle _activeCycle;
	private Cycle filter;
	private Cycle newCycle;

	
	private String backLink;
	private boolean selectMode;

	private final DaoDataModel<Cycle> _cyclesSource;

	private final TableRowSelection<Cycle> _itemSelection;
	private Menu menu;

	private MbCycles cycleBean;
	private boolean blockCycleType = false;
	private ArrayList<SelectItem> institutions;
	
	private String tabName;

	public MbCyclesSearch() {
		pageLink = "fcl|cycles|list_cycles";
		cycleBean = (MbCycles) ManagedBeanWrapper.getManagedBean("MbCycles");
		menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");

		// restore beans' state from session bean
		if (menu.isKeepState()) {
			selectMode = cycleBean.isSelectMode();
			backLink = cycleBean.getBackLinkSearch();
			filter = cycleBean.getSearchFilter();
			searching = cycleBean.isSearching();
			blockCycleType = cycleBean.isBlockCycleType();
		}

		_cyclesSource = new DaoDataModel<Cycle>() {
			@Override
			protected Cycle[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Cycle[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cyclesDao.getCycles(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Cycle[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cyclesDao.getCyclesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Cycle>(null, _cyclesSource);
	}

	public ArrayList<Cycle> getTmp() {
		ArrayList<Cycle> tmp = new ArrayList<Cycle>();
		for (int i = 0; i < 5; i++) {
			Cycle cycle = new Cycle();
			cycle.setCycleType("Type" + i);
			tmp.add(cycle);
		}
		return tmp;
	}

	public DaoDataModel<Cycle> getCycles() {
//		_cyclesSource.setRowIndex(0);
//		_activeCycle = (Cycle)_cyclesSource.getRowData();
//
		return _cyclesSource;
	}

	public Cycle getActiveCycle() {
		return _activeCycle;
	}

	public void setActiveCycle(Cycle activeCycle) {
		_activeCycle = activeCycle;
	}

	public SimpleSelection getItemSelection() {
		if (_activeCycle == null && _cyclesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCycle = _itemSelection.getSingleSelection();
		if (_activeCycle != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_cyclesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCycle = (Cycle) _cyclesSource.getRowData();
		selection.addKey(_activeCycle.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeCycle != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	private void setBeans() {
		MbCycleShiftsSearch cycleShiftBean = (MbCycleShiftsSearch) ManagedBeanWrapper
				.getManagedBean("MbCycleShiftsSearch");
		cycleShiftBean.setCycleId(_activeCycle.getId());
		cycleShiftBean.search();
	}

	public void deleteCycle() {
		try {
			_cyclesDao.deleteCycle(userSessionId, _activeCycle);

			FacesUtils.addMessageInfo("Cycle with id=\"" + _activeCycle.getId() + "\" was deleted");

			_cyclesSource.flushCache();
			_activeCycle = null;

		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void clearFilter() {
		clearBean();
		filter = null;
		searching = false;

		MbCycleShiftsSearch cycleShiftBean = (MbCycleShiftsSearch) ManagedBeanWrapper
				.getManagedBean("MbCycleShiftsSearch");
		cycleShiftBean.setCycleId(null);
	}

	public void search() {
		clearBean();
		setSearching(true);
	}

	public void setSearching(boolean searching) {
		cycleBean.setSearching(searching);
		this.searching = searching;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;
		if (getFilter().getCycleType() != null && !getFilter().getCycleType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("cycleType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCycleType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getLengthType() != null && !getFilter().getLengthType().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("lengthType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getLengthType());
			filtersList.add(paramFilter);
		}
		if (getFilter().getCycleLength() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cycleLength");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getCycleLength().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId().toString());
			filtersList.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		filters = filtersList;
	}

	public ArrayList<SelectItem> getCycleTypes() {
		return getDictUtils().getArticles(DictNames.CYCLE_TYPES, true);
	}

	public ArrayList<SelectItem> getLengthTypes() {
		return getDictUtils().getArticles(DictNames.LENGTH_TYPES, true);
	}

	public ArrayList<SelectItem> getTruncTypes() {
		return getDictUtils().getArticles(DictNames.TRUNC_TYPES, true);
	}

	public CycleShift[] getCycleShifts() {
		if (_activeCycle == null)
			return new CycleShift[0];

		return _cyclesDao.getCycleShiftsByCycle(userSessionId, _activeCycle.getId());
	}

	public Cycle getFilter() {
		if (filter == null) {
			filter = new Cycle();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Cycle filter) {
		this.filter = filter;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String select() {
		cycleBean.setActiveCycle(_activeCycle);
		return backLink;
	}

	public String cancelSelect() {
//		cycles.setActiveCycle(null);
		return backLink;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeCycle = null;
		_cyclesSource.flushCache();
	}

	public boolean isBlockCycleType() {
		return blockCycleType;
	}

	public void setBlockCycleType(boolean blockCycleType) {
		this.blockCycleType = blockCycleType;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void add() {
		newCycle = new Cycle();

		if (getFilter().getInstId() != null) {
			newCycle.setInstId(filter.getInstId());
		}
		newCycle.setCycleType(filter.getCycleType());
		cycleBean.setActiveCycle(newCycle);
		cycleBean.setManagingNew(true);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCycle = (Cycle) _activeCycle.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCycle = _activeCycle;
		}

		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				_cyclesDao.createCycle(userSessionId, newCycle, userLang);
			} else if (isEditMode()) {
				_cyclesDao.updateCycle(userSessionId, newCycle);
			}
			curMode = VIEW_MODE;
			_cyclesSource.flushCache();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public Cycle getNewCycle() {
		if (newCycle == null) {
			newCycle = new Cycle();
		}
		return newCycle;
	}

	public void setNewCycle(Cycle newCycle) {
		this.newCycle = newCycle;
	}

	public void delete() {
		try {
			_cyclesDao.deleteCycle(userSessionId, _activeCycle);
			_itemSelection.clearSelection();
			curMode = VIEW_MODE;
			_activeCycle = null;
			_cyclesSource.flushCache();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public String getDictCycleType() {
		return DictNames.CYCLE_TYPES;
	}

	public Cycle getCycleById(Integer cycleId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		filters[1] = new Filter();
		filters[1].setElement("id");
		filters[1].setValue(cycleId.toString());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Cycle[] cycles = _cyclesDao.getCycles(userSessionId, params);
			if (cycles != null && cycles.length > 0) {
				return cycles[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils
					.addMessageError(new Exception("Couldn't retrieve cycle with id = " + cycleId));
		}
		return null;
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
		
		if (tabName.equalsIgnoreCase("shiftsTab")) {
			MbCycleShiftsSearch bean = (MbCycleShiftsSearch) ManagedBeanWrapper
					.getManagedBean("MbCycleShiftsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_CYCLE_CYCLE;
	}

}

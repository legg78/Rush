package ru.bpc.sv2.ui.administrative;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.Partition;
import ru.bpc.sv2.administrative.PartitionTable;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleShiftsSearch;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.utils.KeyLabelItem;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List PMO Services page.
 */
@ViewScoped
@ManagedBean (name = "MbPartitionTables")
public class MbPartitionTables extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private static String COMPONENT_ID = "2308:mainTable";

	private AccessManagementDao _acmDao = new AccessManagementDao();
	
	private CyclesDao _cyclesDao = new CyclesDao();

	private PartitionTable _activePartitionTable;
	private PartitionTable newPartitionTable;
	private PartitionTable detailPartitionTable;
	
	private PartitionTable filter;
	private List<Filter> partitionTableFilters;

	private boolean selectMode;

	private final DaoDataModel<PartitionTable> _partitionTablesSource;

	private final TableRowSelection<PartitionTable> _partitionTableSelection;
	
	private Cycle parCycle;
	private Cycle stoCycle;
	private Integer parCycleId;
	private Integer stoCycleId;
	
	private List<SelectItem> lengthTypes;
	private List<SelectItem> truncTypes;

	private HashMap<Integer, Cycle> parCyclesMap;
	private HashMap<Integer, Cycle> stoCyclesMap;

	private Integer instId;

	private final int CREATE_VALUE = 1;
	private final int CLONE_VALUE = 2;
	private final int APPLY_VALUE = 4;

	// radio buttons
	private int parCycleMode;
	private int stoCycleMode;
	// ---

	private String curLang;

	private MbCycleShiftsSearch shiftsBean;
	private MbCycleShiftsSearch shiftsStoBean;

	private UserSession userSession;
	
	private List<SelectItem> tableList;
	
	private String tabName;
	private String subTabName;
	
	private static final String PAR_CYCLE_TYPE = "CYTPPRTN";
	private static final String STO_CYCLE_TYPE = "CYTPDRPP";
	
	public MbPartitionTables() {
		

		_partitionTablesSource = new DaoDataModel<PartitionTable>() {
			@Override
			protected PartitionTable[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PartitionTable[0];
				try {
					setPartitionTablesFilters();
					params.setFilters(partitionTableFilters.toArray(new Filter[partitionTableFilters.size()]));
					return _acmDao.getPartitionTables(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PartitionTable[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setPartitionTablesFilters();
					params.setFilters(partitionTableFilters.toArray(new Filter[partitionTableFilters.size()]));
					return _acmDao.getPartitionTablesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		userSession = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		instId = userSession.getUserInst();
		_partitionTableSelection = new TableRowSelection<PartitionTable>(null, _partitionTablesSource);
		shiftsBean = (MbCycleShiftsSearch) ManagedBeanWrapper.getManagedBean("MbCycleShiftsSearch");
		shiftsStoBean = (MbCycleShiftsSearch) ManagedBeanWrapper.getManagedBean("MbCycleShiftsStoSearch");
		
		shiftsBean.fullCleanBean();
		shiftsStoBean.fullCleanBean();
		tabName = "detailsTab";
	}

	public DaoDataModel<PartitionTable> getPartitionTables() {
		return _partitionTablesSource;
	}

	public PartitionTable getActivePartitionTable() {
		return _activePartitionTable;
	}

	public void setActivePartitionTable(PartitionTable activePartitionTable) {
		this._activePartitionTable = activePartitionTable;
	}

	public SimpleSelection getPartitionTableSelection() {
		try {
			if (_activePartitionTable == null && _partitionTablesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activePartitionTable != null && _partitionTablesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activePartitionTable.getModelId());
				_partitionTableSelection.setWrappedSelection(selection);
				_activePartitionTable = _partitionTableSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _partitionTableSelection.getWrappedSelection();
	}

	public void setPartitionTableSelection(SimpleSelection selection) {
		try {
			_partitionTableSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_partitionTableSelection.getSingleSelection() != null 
					&& !_partitionTableSelection.getSingleSelection().getId().equals(_activePartitionTable.getId())) {
				changeSelect = true;
			}
			_activePartitionTable = _partitionTableSelection.getSingleSelection();
			if (_activePartitionTable != null) {
				if (changeSelect) {
					detailPartitionTable = (PartitionTable) _activePartitionTable.clone();
				}
				setInfo();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void setFirstRowActive() throws CloneNotSupportedException {
		_partitionTablesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePartitionTable = (PartitionTable) _partitionTablesSource.getRowData();
		selection.addKey(_activePartitionTable.getModelId());
		_partitionTableSelection.setWrappedSelection(selection);
		if (_activePartitionTable != null) {
			setInfo();
			detailPartitionTable = (PartitionTable) _activePartitionTable.clone();
		}
	}
	
	private void setInfo() {
		if (_activePartitionTable == null)
			return;
		
		if (tabName.equalsIgnoreCase("partitionsTab")) {
			MbPartitionsSearch search = (MbPartitionsSearch) ManagedBeanWrapper
					.getManagedBean("MbPartitionsSearch");
			Partition filter = new Partition();
			filter.setTableName(_activePartitionTable.getTableName());
			search.setPartitionFilter(filter);
			search.search();
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_partitionTablesSource.flushCache();
		if (_partitionTableSelection != null) {
			_partitionTableSelection.clearSelection();
		}
		_activePartitionTable = null;
		detailPartitionTable = null;
	}

	public void add() {
		newPartitionTable = new PartitionTable();
		curMode = NEW_MODE;
		
		try {
			fullCleanBean();
			
			parCycleMode = CREATE_VALUE;
			stoCycleMode = CREATE_VALUE;
			if (getDictUtils().getAllArticles().get(PAR_CYCLE_TYPE) == null) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
						"cycle_type_for_attr_not_found", PAR_CYCLE_TYPE, "partition table"));
			} else if (getDictUtils().getAllArticles().get(STO_CYCLE_TYPE) == null) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Fcl",
						"cycle_type_for_attr_not_found", STO_CYCLE_TYPE, "partition table"));
			}
			createNewCycle();
			createNewStoCycle();
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private void createNewCycle() {
		parCycleId = null;
		
		shiftsBean.setSearching(true);
		
		parCycle = new Cycle();
		parCycle.setCycleType(PAR_CYCLE_TYPE);		
		//get user instId
		parCycle.setInstId(instId);
		
		shiftsBean.fullCleanBean();
		shiftsBean.setCycleId(-1); // just temporary id to unblock buttons
		shiftsBean.setDisableAll(false);
	}
	
	private void createNewStoCycle() {
		stoCycleId = null;
		
		shiftsStoBean.setSearching(true);
		
		stoCycle = new Cycle();
		stoCycle.setCycleType(STO_CYCLE_TYPE);
		//get user instId
		
		stoCycle.setInstId(instId);
		
		shiftsStoBean.fullCleanBean();
		shiftsStoBean.setCycleId(-1); // just temporary id to unblock buttons
		shiftsStoBean.setDisableAll(false);
	}
	
	public void changeCycleMode(ValueChangeEvent event) {
		int newMode = (Integer) event.getNewValue();
		if (subTabName.equalsIgnoreCase("cyclesTab")) {
			if (newMode == CREATE_VALUE) {
				createNewCycle();
			} else if (newMode == CLONE_VALUE) {
				shiftsBean.setDisableAll(false);
			} else if (newMode == APPLY_VALUE) {
				if (parCycleMode == CLONE_VALUE && parCycle != null && parCycle.getId() != null) {
					// to be sure that we'll get original cycle if user changes something in clone mode 
					initCycle(parCycle.getId());
				}
				shiftsBean.setDisableAll(true);
			}
		} else if (subTabName.equalsIgnoreCase("stoCyclesTab")) {
			if (newMode == CREATE_VALUE) {
				createNewStoCycle();
			} else if (newMode == CLONE_VALUE) {
				shiftsStoBean.setDisableAll(false);
			} else if (newMode == APPLY_VALUE) {
				if (stoCycleMode == CLONE_VALUE && stoCycle != null && stoCycle.getId() != null) {
					// to be sure that we'll get original cycle if user changes something in clone mode 
					initStoCycle(stoCycle.getId());
				}
				shiftsStoBean.setDisableAll(true);
			}
		}
	}
	
	public void save() {
		if (!checkForm()) {
			return;
		}

		// When cloning new objects are created (unlike when applying)
		if (parCycleMode == CLONE_VALUE) {
			parCycle.setId(null);
		}
		if (stoCycleMode == CLONE_VALUE) {
			stoCycle.setId(null);
		}

		ArrayList<CycleShift> shifts = null;
		if (parCycleMode == CREATE_VALUE || parCycleMode == CLONE_VALUE) {
			shifts = shiftsBean.getStoredCycleShifts();
		}
		ArrayList<CycleShift> stoShifts = null;
		if (stoCycleMode == CREATE_VALUE || stoCycleMode == CLONE_VALUE) {
			stoShifts = shiftsStoBean.getStoredCycleShifts();
		}

		try {
			newPartitionTable = _acmDao.registerTransactionalTable(userSessionId, newPartitionTable, parCycle, shifts, stoCycle, stoShifts);
			detailPartitionTable = (PartitionTable) newPartitionTable.clone();
			_partitionTableSelection.addNewObjectToList(newPartitionTable);
			_activePartitionTable = newPartitionTable;
			setInfo();
			curMode = VIEW_MODE;

		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
			return;
		}

	}
	
	public boolean checkForm() {
		boolean result = true;
		
		//check table existing
		if (isTableNameExisted()) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Acm", "table_name_existed")));
			result = false;
		} else {
			if (parCycleMode == APPLY_VALUE && parCycleId == null) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Fcl", "select_cycle")));
				result = false;
			} else if (parCycleMode == CREATE_VALUE || parCycleMode == CLONE_VALUE) {
				if (parCycle.getCycleLength() == null || parCycle.getCycleType() == null) {
					FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
							"ru.bpc.sv2.ui.bundles.Fcl", "check_cycle_form")));
					result = false;
				}
			} 
			
			if (stoCycleMode == APPLY_VALUE && stoCycleId == null) {
				FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Fcl", "select_cycle")));
				result = false;
			} else if (stoCycleMode == CREATE_VALUE || stoCycleMode == CLONE_VALUE) {
				if (stoCycle.getCycleLength() == null || stoCycle.getCycleType() == null) {
					FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
							"ru.bpc.sv2.ui.bundles.Fcl", "check_cycle_form")));
					result = false;
				}
			}
		}

		return result;
	}
	
	private boolean isTableNameExisted() {
		boolean result = false;
		List<Filter> filtersList = new ArrayList<Filter>();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("tableName");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(newPartitionTable.getTableName());
		filtersList.add(paramFilter);
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			PartitionTable[] list = _acmDao.getPartitionTables(userSessionId, params);
			
			if (list != null && list.length > 0) result = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return result;
	}
	
	private void initCycle(Integer cycleId) {
		if (cycleId != null) {
			try {
				parCycle = parCyclesMap.get(cycleId).clone();
			} catch (CloneNotSupportedException e) {
				parCycle = parCyclesMap.get(cycleId);
			}
			shiftsBean.fullCleanBean();
			shiftsBean.setCycleId(cycleId);
			shiftsBean.search();
		} else {
			parCycle = null;
			shiftsBean.fullCleanBean();
			shiftsBean.setSearching(false);
		}
	}
	
	private void initStoCycle(Integer cycleId) {
		if (cycleId != null) {
			try {
				stoCycle = stoCyclesMap.get(cycleId).clone();
			} catch (CloneNotSupportedException e) {
				stoCycle = stoCyclesMap.get(cycleId);
			}
			shiftsStoBean.fullCleanBean();
			shiftsStoBean.setCycleId(cycleId);
			shiftsStoBean.search();
		} else {
			stoCycle = null;
			shiftsStoBean.fullCleanBean();
			shiftsStoBean.setSearching(false);
		}
	}
	
	public void fullCleanBean() {
		parCycleMode = 0;
		stoCycleMode = 0;

		parCycle = null;
		parCycleId = null;
		stoCycle = null;
		stoCycleId = null;

		parCyclesMap = null;
		stoCyclesMap = null;

		shiftsBean.fullCleanBean();
		shiftsBean.setDisableAll(true);
		shiftsBean.setDontSave(true);
		
		shiftsStoBean.fullCleanBean();
		shiftsStoBean.setDisableAll(true);
		shiftsStoBean.setDontSave(true);
	}
	
	public void edit() {
		try {
			newPartitionTable = (PartitionTable) detailPartitionTable.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newPartitionTable = _activePartitionTable;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_acmDao.unregisterTransactionalTable(userSessionId, _activePartitionTable);
			FacesUtils.addMessageInfo("Partition table (id = " + _activePartitionTable.getId()
					+ ") has been unregistered.");

			_activePartitionTable = _partitionTableSelection.removeObjectFromList(_activePartitionTable);
			if (_activePartitionTable == null) {
				clearBean();
			} else {
				setInfo();
				detailPartitionTable = (PartitionTable) _activePartitionTable.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}

	public void setPartitionTablesFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getId());
			filtersList.add(paramFilter);
		}
		
		if (getFilter().getTableName() != null && !getFilter().getTableName().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("tableName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getTableName()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (getFilter().getNextPartitionDateFrom() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("nextPartitionDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getNextPartitionDateFrom()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getNextPartitionDateTo() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("nextPartitionDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getNextPartitionDateTo()));
			filtersList.add(paramFilter);
		}
		
		partitionTableFilters = filtersList;
	}

	public PartitionTable getFilter() {
		if (filter == null)
			filter = new PartitionTable();
		return filter;
	}

	public void setFilter(PartitionTable filter) {
		this.filter = filter;
	}

	public List<Filter> getPartitionTableFilters() {
		return partitionTableFilters;
	}

	public void setPartitionTableFilters(List<Filter> partitionTableFilters) {
		this.partitionTableFilters = partitionTableFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PartitionTable getNewPartitionTable() {
		return newPartitionTable;
	}

	public void setNewPartitionTable(PartitionTable newPartitionTable) {
		this.newPartitionTable = newPartitionTable;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public PartitionTable getDetailPartitionTable() {
		return detailPartitionTable;
	}

	public void setDetailPartitionTable(PartitionTable detailPartitionTable) {
		this.detailPartitionTable = detailPartitionTable;
	}

	public void changeCycle(ValueChangeEvent event) {
		Integer newCycleId = (Integer) event.getNewValue();
		if (subTabName.equalsIgnoreCase("cyclesTab")) {
			initCycle(newCycleId);
		} else if (subTabName.equalsIgnoreCase("stoCyclesTab")) {
			initStoCycle(newCycleId);
		}
	}
	
	public int getCreateValue() {
		return CREATE_VALUE;
	}

	public int getCloneValue() {
		return CLONE_VALUE;
	}

	public int getApplyValue() {
		return APPLY_VALUE;
	}
	
	/**
	 * CYCLES TAB
	 */

	public ArrayList<SelectItem> getCycles() {
		if (subTabName != null && !subTabName.isEmpty()
				&& !subTabName.equalsIgnoreCase("generalTab")) {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("cycleType");
			if (subTabName.equalsIgnoreCase("cyclesTab")) {
				filters[0].setValue(PAR_CYCLE_TYPE);
			} else if (subTabName.equalsIgnoreCase("stoCyclesTab")) {
				filters[0].setValue(STO_CYCLE_TYPE);
			}
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);

			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);

			try {
				Cycle[] cycles = _cyclesDao.getCycles(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(cycles.length);
				
				if (subTabName.equalsIgnoreCase("cyclesTab")) {
					parCyclesMap = new HashMap<Integer, Cycle>(cycles.length);
					for (Cycle cycle: cycles) {
						items.add(new SelectItem(cycle.getId(), cycle.getId() + " - "
								+ cycle.getDescription()));
						parCyclesMap.put(cycle.getId(), cycle);
					}
				} else if (subTabName.equalsIgnoreCase("stoCyclesTab")) {
					stoCyclesMap = new HashMap<Integer, Cycle>(cycles.length);
					for (Cycle cycle: cycles) {
						items.add(new SelectItem(cycle.getId(), cycle.getId() + " - "
								+ cycle.getDescription()));
						stoCyclesMap.put(cycle.getId(), cycle);
					}
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public HashMap<Integer, Cycle> getParCyclesMap() {
		return parCyclesMap;
	}

	public void setParCyclesMap(HashMap<Integer, Cycle> parCyclesMap) {
		this.parCyclesMap = parCyclesMap;
	}
	
	public HashMap<Integer, Cycle> getStoCyclesMap() {
		return stoCyclesMap;
	}

	public void setStoCyclesMap(HashMap<Integer, Cycle> stoCyclesMap) {
		this.stoCyclesMap = stoCyclesMap;
	}

	public int getParCycleMode() {
		return parCycleMode;
	}

	public void setParCycleMode(int parCycleMode) {
		this.parCycleMode = parCycleMode;
	}
	
	public int getStoCycleMode() {
		return stoCycleMode;
	}

	public void setStoCycleMode(int stoCycleMode) {
		this.stoCycleMode = stoCycleMode;
	}

	public Integer getParCycleId() {
		return parCycleId;
	}

	public void setParCycleId(Integer parCycleId) {
		this.parCycleId = parCycleId;
	}
	
	public Integer getStoCycleId() {
		return stoCycleId;
	}

	public void setStoCycleId(Integer stoCycleId) {
		this.stoCycleId = stoCycleId;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public Cycle getParCycle() {
		return parCycle;
	}

	public void setParCycle(Cycle parCycle) {
		this.parCycle = parCycle;
	}
	
	public Cycle getStoCycle() {
		return stoCycle;
	}

	public void setStoCycle(Cycle stoCycle) {
		this.stoCycle = stoCycle;
	}

	public List<SelectItem> getTruncTypes() {
		if (truncTypes == null) {
			truncTypes = getDictUtils().getLov(LovConstants.PERIOD_TYPES);
		}
		return truncTypes;
	}

	public List<SelectItem> getLengthTypes() {
		if (lengthTypes == null) {
			lengthTypes = getDictUtils().getLov(LovConstants.PERIOD_TYPES);
		}
		return lengthTypes;
	}

	public List<SelectItem> getTableList() {
		if (tableList == null) {
			
			List<KeyLabelItem> temp = _acmDao.getTables(userSessionId);
			
			SelectItem si;
			tableList = new ArrayList<SelectItem>();
			for (KeyLabelItem item: temp) {
				si = new SelectItem(item.getValue(),item.getLabel(), item.getLabel());
				tableList.add(si);
			}
		}
		return tableList;
	}

	public String getSubTabName() {
		return subTabName;
	}

	public void setSubTabName(String subTabName) {
		this.subTabName = subTabName;
		
		if (subTabName.equalsIgnoreCase("cyclesTab")) {
			shiftsBean.setTabName(subTabName);
			shiftsBean.setParentSectionId(getSectionId());
			shiftsBean.setTableState(getSateFromDB(shiftsBean.getComponentId()));
		} else if (subTabName.equalsIgnoreCase("stoCyclesTab")) {
			shiftsStoBean.setTabName(subTabName);
			shiftsStoBean.setParentSectionId(getSectionId());
			shiftsStoBean.setTableState(getSateFromDB(shiftsStoBean.getComponentId()));
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		setInfo();
		
		if (tabName.equalsIgnoreCase("partitionsTab")) {
			MbPartitionsSearch bean = (MbPartitionsSearch) ManagedBeanWrapper
					.getManagedBean("MbPartitionsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}	
	}

	public String getSectionId() {
		return SectionIdConstants.ADMIN_PARTITION_TABLE;
	}
}

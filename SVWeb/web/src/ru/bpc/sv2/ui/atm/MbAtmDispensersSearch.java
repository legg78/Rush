package ru.bpc.sv2.ui.atm;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.atm.AtmDispenser;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

/**
 * Manage Bean for List PMO Hosts bottom tab.
 */
@ViewScoped
@ManagedBean (name = "MbAtmDispensersSearch")
public class MbAtmDispensersSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ATM");

	private AtmDao _atmDao = new AtmDao();

	private AtmDispenser _activeDispenser;
	private AtmDispenser newDispenser;
	
	private AtmDispenser dispenserFilter;
	private List<Filter> dispenserFilters;

	private boolean selectMode;

	private boolean groupByCurrency;
	private boolean disableButtons;
	
	private final DaoDataModel<AtmDispenser> _dispensersSource;
	private final TableRowSelection<AtmDispenser> _dispenserSelection;

	private static String COMPONENT_ID = "bottomDispensersTable";
	private String tabName;
	private String parentSectionId;
	private Date lastSynchronization;
	private List<SelectItem> currencies;
	//	private List<SelectItem> executionTypeForCombo;
	
	public MbAtmDispensersSearch() {
		_dispensersSource = new DaoDataModel<AtmDispenser>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected AtmDispenser[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new AtmDispenser[0];
				try {
					setDispensersFilters();
					params.setFilters(dispenserFilters.toArray(new Filter[dispenserFilters.size()]));
					if (groupByCurrency) {
						return _atmDao.getDispensersSum(userSessionId, params);
					} else {
						return _atmDao.getDispensers(userSessionId, params);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AtmDispenser[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setDispensersFilters();
					params.setFilters(dispenserFilters.toArray(new Filter[dispenserFilters.size()]));
					if (groupByCurrency) {
						return _atmDao.getDispensersSumCount(userSessionId, params);
					} else {
						return _atmDao.getDispensersCount(userSessionId, params);
					}
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_dispenserSelection = new TableRowSelection<AtmDispenser>(null, _dispensersSource);
		currencies = getDictUtils().getLov(LovConstants.CURRENCIES);
	}

	public DaoDataModel<AtmDispenser> getDispensers() {
		return _dispensersSource;
	}

	public AtmDispenser getActiveDispenser() {
		return _activeDispenser;
	}

	public void setActiveDispenser(AtmDispenser activeDispenser) {
		this._activeDispenser = activeDispenser;
	}

	public SimpleSelection getDispenserSelection() {
		if (_activeDispenser == null && _dispensersSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeDispenser != null && _dispensersSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeDispenser.getModelId());
			_dispenserSelection.setWrappedSelection(selection);
			_activeDispenser = _dispenserSelection.getSingleSelection();			
		}
		return _dispenserSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_dispensersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDispenser = (AtmDispenser) _dispensersSource.getRowData();
		selection.addKey(_activeDispenser.getModelId());
		_dispenserSelection.setWrappedSelection(selection);
		if (_activeDispenser != null) {
			setInfo();
		}
	}
	
	public void setInfo() {
		
	}

	public void setDispenserSelection(SimpleSelection selection) {
		_dispenserSelection.setWrappedSelection(selection);
		_activeDispenser = _dispenserSelection.getSingleSelection();
		if (_activeDispenser != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}
	

	public void clearFilter() {
		dispenserFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_dispensersSource.flushCache();
		if (_dispenserSelection != null) {
			_dispenserSelection.clearSelection();
		}
		_activeDispenser = null;
	}

	public void setDispensersFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		
		if (getDispenserFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getDispenserFilter().getId());
			filtersList.add(paramFilter);
		}
		
		if (getDispenserFilter().getTerminalId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getDispenserFilter().getTerminalId());
			filtersList.add(paramFilter);
		}
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
		dispenserFilters = filtersList;
	}

	public AtmDispenser getDispenserFilter() {
		if (dispenserFilter == null)
			dispenserFilter = new AtmDispenser();
		return dispenserFilter;
	}

	public void setDispenserFilter(AtmDispenser dispenserFilter) {
		this.dispenserFilter = dispenserFilter;
	}

	public List<Filter> getDispenserFilters() {
		return dispenserFilters;
	}

	public void setDispenserFilters(List<Filter> dispenserFilters) {
		this.dispenserFilters = dispenserFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public AtmDispenser getNewDispenser() {
		return newDispenser;
	}

	public void setNewDispenser(AtmDispenser newDispenser) {
		this.newDispenser = newDispenser;
	}
	
	public void add() {
		newDispenser = new AtmDispenser();
		newDispenser.setTerminalId(getDispenserFilter().getTerminalId());
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newDispenser = (AtmDispenser) _activeDispenser.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newDispenser = _activeDispenser;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			
			if (isEditMode()) {
				newDispenser = _atmDao.modifyDispenser(userSessionId, newDispenser);
				_dispensersSource.replaceObject(_activeDispenser, newDispenser);
			} else {
				newDispenser = _atmDao.addDispenser(userSessionId, newDispenser);
				_dispenserSelection.addNewObjectToList(newDispenser);
			}
			_activeDispenser = newDispenser;

			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_atmDao.removeDispenser(userSessionId, _activeDispenser);
			FacesUtils.addMessageInfo("Host (id = " + _activeDispenser.getId()
					+ ") has been deleted.");

			_activeDispenser = _dispenserSelection.removeObjectFromList(_activeDispenser);
			if (_activeDispenser == null) {
				clearBean();
			} 
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}
	
	public List<SelectItem> getDispenserTypes() {
		return getDictUtils().getLov(LovConstants.DISPENSER_TYPE);
	}
	
	public List<SelectItem> getCurrencies() {
		return currencies;
	}

	public boolean isGroupByCurrency() {
		return groupByCurrency;
	}

	public void setGroupByCurrency(boolean groupByCurrency) {
		this.groupByCurrency = groupByCurrency;
	}
	
	public void enableDisableCassette() {
		if (!"CSSTACTV".equals(_activeDispenser.getCassetteStatus())) {
			_activeDispenser.setCassetteStatus("CSSTACTV");
		} else {
			_activeDispenser.setCassetteStatus("CSSTDSBL");
		}
		try {
			_atmDao.modifyDispenserState(userSessionId, _activeDispenser);
			_dispensersSource.flushCache();
		} catch (DataAccessException e) {
			FacesUtils.addSystemError(e);
			logger.error("", e);
		}
	}

	public boolean isDisableButtons() {
		return disableButtons;
	}

	public void setDisableButtons(boolean disableButtons) {
		this.disableButtons = disableButtons;
	}
	
	public void disableButtons(Integer templateId, boolean isAtmTemplate) {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter("terminalId", templateId);
		SelectionParams params = new SelectionParams(filters);

		int result = 0;
		try {
			if (isAtmTemplate) {
				result = _atmDao.getTerminalTemplateAtmsCount(userSessionId, params);
			} else {
				result = _atmDao.getTerminalAtmsCount(userSessionId, params);
			}
		} catch (Exception e) {
			logger.error("" , e);
		}
		setDisableButtons(result <= 0);
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
	
	public Date getLastSynchronization(){
		lastSynchronization = _atmDao.getLastSynchronization(userSessionId, SelectionParams.build("id", getDispenserFilter().getTerminalId()));
		return lastSynchronization;
	}
}

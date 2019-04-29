package ru.bpc.sv2.ui.atm;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.atm.AtmScenario;
import ru.bpc.sv2.atm.TerminalATM;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbTerminalATMs")
public class MbTerminalATMs extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");

	public static final String SYNC_MODE_NOT_PERMITTED = "ATMS0001";
	private AtmDao _atmDao = new AtmDao();

	private TerminalATM filter;
	private boolean isTemplate;
	private TerminalATM _activeATM;
	private TerminalATM newATM;
	private List<SelectItem> dispanceAlgs;

	private final DaoDataModel<TerminalATM> _atmsSource;

	private final TableRowSelection<TerminalATM> _itemSelection;

	private boolean slaveMode = false;
	private List<SelectItem> atmTypes;
	private List<SelectItem> keyChangeAlgos;
	private List<SelectItem> synchronizationModes;

	public MbTerminalATMs() {
		_atmsSource = new DaoDataModel<TerminalATM>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected TerminalATM[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new TerminalATM[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (isTemplate) {
						return _atmDao.getTerminalTemplateAtms(userSessionId, params);
					} else {
						return _atmDao.getTerminalAtms(userSessionId, params);
					}
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new TerminalATM[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (isTemplate) {
						return _atmDao.getTerminalTemplateAtmsCount(userSessionId, params);
					} else {
						return _atmDao.getTerminalAtmsCount(userSessionId, params);
					}
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<TerminalATM>(null, _atmsSource);
		atmTypes = getDictUtils().getLov(LovConstants.ATM_TYPE);
		keyChangeAlgos = getDictUtils().getLov(LovConstants.KEY_CHANGE_ALGORITHM);
		dispanceAlgs = getDictUtils().getLov(LovConstants.DISPENSE_ALG);
		synchronizationModes = getDictUtils().getLov(LovConstants.SYNCHRONIZATION_MODES);
	}

	public DaoDataModel<TerminalATM> getATMs() {
		return _atmsSource;
	}

	public TerminalATM getActiveATM() {
		return _activeATM;
	}

	public void setActiveATM(TerminalATM activeATM) {
		_activeATM = activeATM;
	}

	public SimpleSelection getItemSelection() {
		if (_activeATM == null && _atmsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeATM != null && _atmsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeATM.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeATM = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_atmsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeATM = (TerminalATM) _atmsSource.getRowData();
		selection.addKey(_activeATM.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeATM != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeATM = _itemSelection.getSingleSelection();
		if (_activeATM != null) {
			setInfo();
		}
	}

	public void setInfo() {

	}

	public void clearBeansStates() {
		// MbAtmDispensersSearch also depends on MbTerminal and MbTerminalTemplates 
		// that's why we don't clear its filter and don't set 'search' property
		MbAtmDispensersSearch dispensers = (MbAtmDispensersSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmDispensersSearch");
		dispensers.clearBean();
		dispensers.setDisableButtons(_activeATM == null);
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = new TerminalATM();
		clearState();
		searching = false;
	}

	public TerminalATM getFilter() {
		if (filter == null)
			filter = new TerminalATM();
		return filter;
	}

	public void setFilter(TerminalATM filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_atmsSource.flushCache();
		_activeATM = null;

		clearBeansStates();
	}

	private void setBeans() {
		// MbAtmDispensersSearch also depends on MbTerminal and MbTerminalTemplates 
		// that's why we don't clear its filter and don't set 'search' property
		MbAtmDispensersSearch dispensers = (MbAtmDispensersSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmDispensersSearch");
		dispensers.clearBean();
		dispensers.setDisableButtons(_activeATM == null);
	}

	public void add() {
		newATM = new TerminalATM();
		newATM.setId(getFilter().getId());
		newATM.setLang(userLang);
		// newATM.setTerminalProfile(getFilter().getTerminalProfile());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newATM = (TerminalATM) _activeATM.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newATM = _activeATM;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		if (!isPeriodicAllOperPermitted()) {
			newATM.setPeriodicAllOper(null);
			newATM.setPeriodicOperCount(null);
		}
		if (newATM.getCashInPresent() == null || !newATM.getCashInPresent()) {
			newATM.setCashInMaxWarn(null);
			newATM.setCashInMinWarn(null);
		}
		try {
			if (isNewMode()) {
				newATM = _atmDao.addTerminalAtm(userSessionId, newATM, isTemplate);
				if (!slaveMode) {
					_itemSelection.addNewObjectToList(newATM);
				}
			} else if (isEditMode()) {
				newATM = _atmDao.modifyTerminalAtm(userSessionId, newATM, isTemplate);
				if (!slaveMode) {
					_atmsSource.replaceObject(_activeATM, newATM);
				}
			}
			_activeATM = newATM;
			
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_atmDao.removeTerminalAtm(userSessionId, _activeATM);
			if (!slaveMode) {
				_activeATM = _itemSelection.removeObjectFromList(_activeATM);
			} else {
				_activeATM = null;
			}
			if (_activeATM == null) {
				clearBean();
			} else {
				setBeans();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public TerminalATM getNewATM() {
		if (newATM == null) {
			newATM = new TerminalATM();
		}
		return newATM;
	}

	public void setNewATM(TerminalATM newATM) {
		this.newATM = newATM;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeATM = null;
		_atmsSource.flushCache();
		curLang = userLang;
	}

	public List<SelectItem> getAtmTypes() {
		return atmTypes;
	}

	public List<SelectItem> getKeyChangeAlgos() {
		return keyChangeAlgos;
	}

	public ArrayList<SelectItem> getScenarios() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			List<Filter> filters = new ArrayList<Filter>();
			Filter paramFilter = null;

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filters.add(paramFilter);

			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(-1);
			AtmScenario[] scenarios = _atmDao.getScenarios(userSessionId, params);
			for (AtmScenario scenario : scenarios) {
				items.add(new SelectItem(scenario.getId(), scenario.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}

	/**
	 * <p>
	 * Loads terminal template according to <code>filter</code> , sets it as
	 * <code>_activeTemplate</code> and returns it as method return value
	 * </p>
	 * .
	 * 
	 * @return first terminal template found if any; <code>null</code> -
	 *         otherwise.
	 */
	public TerminalATM loadTerminalATM() {
		setFilters();
		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			_activeATM = null;
			TerminalATM[] atms;
			if (isTemplate) {
				atms = _atmDao.getTerminalTemplateAtms(userSessionId, params);
			} else {
				atms = _atmDao.getTerminalAtms(userSessionId, params);
			}
			if (atms != null && atms.length > 0) {
				_activeATM = atms[0];
				return atms[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public boolean isSlaveMode() {
		return slaveMode;
	}

	public void setSlaveMode(boolean slaveMode) {
		this.slaveMode = slaveMode;
	}

	public List<SelectItem> getSynchronizationModes() {
		return synchronizationModes;
	}

	public boolean isPeriodicAllOperPermitted() {
		return !SYNC_MODE_NOT_PERMITTED.equals(getNewATM().getPeriodicSynch());
	}

	public boolean isTemplate() {
		return isTemplate;
	}

	public void setTemplate(boolean isTemplate) {
		this.isTemplate = isTemplate;
	}

	public List<SelectItem> getDispanceAlgs() {
		return dispanceAlgs;
	}

	public void setDispanceAlgs(List<SelectItem> dispanceAlgs) {
		this.dispanceAlgs = dispanceAlgs;
	}

	// public void changePeriodicSynch(ValueChangeEvent event) {
	// String newValue = (String) event.getNewValue();
	//
	// if (newValue == null || SYNC_MODE_NOT_PERMITTED.equals(newValue)) {
	// getNewATM().setPeriodicAllOper(null);
	// getNewATM().setPeriodicOperCount(null);
	// }
	// }
}

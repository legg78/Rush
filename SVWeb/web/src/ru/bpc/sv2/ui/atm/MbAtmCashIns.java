package ru.bpc.sv2.ui.atm;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.atm.AtmCashIn;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbAtmCashIns")
public class MbAtmCashIns extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ATM");

	private static String COMPONENT_ID = "atmCashInsTable";

	private AtmDao _atmDao = new AtmDao();

	private AtmCashIn filter;
	private AtmCashIn _activeAtmCashIn;

	private final DaoDataModel<AtmCashIn> _atmCashInsSource;
	private final TableRowSelection<AtmCashIn> _itemSelection;
	
	private String tabName;
	private String parentSectionId;
	
	public MbAtmCashIns() {
		_atmCashInsSource = new DaoDataModel<AtmCashIn>() {
			@Override
			protected AtmCashIn[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new AtmCashIn[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _atmDao.getAtmCashIns(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AtmCashIn[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _atmDao.getAtmCashInsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AtmCashIn>(null, _atmCashInsSource);
	}

	public DaoDataModel<AtmCashIn> getAtmCashIns() {
		return _atmCashInsSource;
	}

	public AtmCashIn getActiveAtmCashIn() {
		return _activeAtmCashIn;
	}

	public void setActiveAtmCashIn(AtmCashIn activeAtmCashIn) {
		_activeAtmCashIn = activeAtmCashIn;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeAtmCashIn == null && _atmCashInsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeAtmCashIn != null && _atmCashInsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeAtmCashIn.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeAtmCashIn = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_atmCashInsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAtmCashIn = (AtmCashIn) _atmCashInsSource.getRowData();
		selection.addKey(_activeAtmCashIn.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeAtmCashIn = _itemSelection.getSingleSelection();
		if (_activeAtmCashIn != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {

	}

	public void clearBeansStates() {

	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public AtmCashIn getFilter() {
		if (filter == null) {
			filter = new AtmCashIn();
		}
		return filter;
	}

	public void setFilter(AtmCashIn filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getTerminalId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setValue(filter.getTerminalId());
			filters.add(paramFilter);
		}
		if (filter.getFaceValue() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("faceValue");
			paramFilter.setValue(filter.getFaceValue());
			filters.add(paramFilter);
		}
		if (filter.getCurrency() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("currency");
			paramFilter.setValue(filter.getCurrency());
			filters.add(paramFilter);
		}
		if (filter.getDenominationCode() != null && filter.getDenominationCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("denominationCode");
			paramFilter.setValue(filter.getDenominationCode());
			filters.add(paramFilter);
		}
		if (filter.getIsActive() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("isActive");
			paramFilter.setValue(filter.getIsActive());
			filters.add(paramFilter);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeAtmCashIn = null;
		_atmCashInsSource.flushCache();

		clearBeansStates();
	}

	public Logger getLogger() {
		return logger;
	}

	public AtmCashIn loadAtmCashIn() {
		setFilters();
		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			_activeAtmCashIn = null;
			AtmCashIn[] atms = _atmDao.getAtmCashIns(userSessionId, params);
			if (atms != null && atms.length > 0) {
				_activeAtmCashIn = atms[0];
				return atms[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
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

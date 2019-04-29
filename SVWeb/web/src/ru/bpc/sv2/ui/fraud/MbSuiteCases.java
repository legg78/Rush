package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fraud.Case;
import ru.bpc.sv2.fraud.Suite;
import ru.bpc.sv2.fraud.SuiteCase;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean(name = "MbSuiteCases")
public class MbSuiteCases extends AbstractBean {
	private static final long serialVersionUID = 3778965935622572858L;

	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private FraudDao _fraudDao = new FraudDao();

	private SuiteCase filter;
	private SuiteCase _activeSuiteCase;
	private SuiteCase newSuiteCase;

	private final DaoDataModel<SuiteCase> _suiteCasesSource;
	private final TableRowSelection<SuiteCase> _itemSelection;
	
	private boolean blockSuite;
	private boolean blockCase;
	
	private static String COMPONENT_ID = "suiteCasesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbSuiteCases() {
		_suiteCasesSource = new DaoDataModel<SuiteCase>() {
			private static final long serialVersionUID = -8335966620961800252L;

			@Override
			protected SuiteCase[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new SuiteCase[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getSuiteCases(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new SuiteCase[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getSuiteCasesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<SuiteCase>(null, _suiteCasesSource);
	}

	public DaoDataModel<SuiteCase> getSuiteCases() {
		return _suiteCasesSource;
	}

	public SuiteCase getActiveSuiteCase() {
		return _activeSuiteCase;
	}

	public void setActiveSuiteCase(SuiteCase activeSuiteCase) {
		_activeSuiteCase = activeSuiteCase;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeSuiteCase == null && _suiteCasesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeSuiteCase != null && _suiteCasesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeSuiteCase.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeSuiteCase = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_suiteCasesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSuiteCase = (SuiteCase) _suiteCasesSource.getRowData();
		selection.addKey(_activeSuiteCase.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSuiteCase = _itemSelection.getSingleSelection();
		if (_activeSuiteCase != null) {
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

	public void fullCleanBean() {
		blockSuite = false;
		blockCase = false;
		clearFilter();
	}
	
	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public SuiteCase getFilter() {
		if (filter == null) {
			filter = new SuiteCase();
		}
		return filter;
	}

	public void setFilter(SuiteCase filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getSuiteId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("suiteId");
			paramFilter.setValue(filter.getSuiteId());
			filters.add(paramFilter);
		}
		if (filter.getCaseId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("caseId");
			paramFilter.setValue(filter.getCaseId());
			filters.add(paramFilter);
		}
		if (filter.getPriority() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("priority");
			paramFilter.setValue(filter.getPriority());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newSuiteCase = new SuiteCase();
		newSuiteCase.setLang(userLang);
		if (getFilter().getCaseId() != null) {
			newSuiteCase.setCaseId(getFilter().getCaseId());
		} else if (getFilter().getSuiteId() != null) {
			newSuiteCase.setSuiteId(getFilter().getSuiteId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSuiteCase = (SuiteCase) _activeSuiteCase.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newSuiteCase = _activeSuiteCase;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newSuiteCase = _fraudDao.addSuiteCase(userSessionId, newSuiteCase);
				_itemSelection.addNewObjectToList(newSuiteCase);
			} else if (isEditMode()) {
				newSuiteCase = _fraudDao.modifySuiteCase(userSessionId, newSuiteCase);
				_suiteCasesSource.replaceObject(_activeSuiteCase, newSuiteCase);
			}
			_activeSuiteCase = newSuiteCase;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_fraudDao.removeSuiteCase(userSessionId, _activeSuiteCase);
			_activeSuiteCase = _itemSelection.removeObjectFromList(_activeSuiteCase);

			if (_activeSuiteCase == null) {
				clearState();
			} else {
				setBeans();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public SuiteCase getNewSuiteCase() {
		if (newSuiteCase == null) {
			newSuiteCase = new SuiteCase();
		}
		return newSuiteCase;
	}

	public void setNewSuiteCase(SuiteCase newSuiteCase) {
		this.newSuiteCase = newSuiteCase;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeSuiteCase = null;
		_suiteCasesSource.flushCache();

		clearBeansStates();
	}

	public boolean isBlockSuite() {
		return blockSuite;
	}

	public void setBlockSuite(boolean blockSuite) {
		this.blockSuite = blockSuite;
	}

	public boolean isBlockCase() {
		return blockCase;
	}

	public void setBlockCase(boolean blockCase) {
		this.blockCase = blockCase;
	}
	
	public ArrayList<SelectItem> getSuites() {
		if (blockSuite) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(1);
			items.add(new SelectItem(getFilter().getSuiteId(), getFilter().getSuiteName()));
			return items;
		}
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		try {
			Suite[] suites = _fraudDao.getSuites(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(suites.length);
			
			for (Suite suite: suites) {
				items.add(new SelectItem(suite.getId(), suite.getLabel()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public ArrayList<SelectItem> getCases() {
		if (blockCase) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(1);
			items.add(new SelectItem(getFilter().getCaseId(), getFilter().getCaseName()));
			return items;
		}
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		try {
			Case[] cases = _fraudDao.getCases(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(cases.length);
			
			for (Case frpCase: cases) {
				items.add(new SelectItem(frpCase.getId(), frpCase.getLabel()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return new ArrayList<SelectItem>(0);
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

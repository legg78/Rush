package ru.bpc.sv2.ui.scenario;

import java.util.ArrayList;

import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ScenariosDao;
import ru.bpc.sv2.scenario.AuthState;
import ru.bpc.sv2.scenario.Scenario;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbAuthStates")
public class MbAuthStates extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("SCENARIO");
	
	private static String COMPONENT_ID = "rulesTable";

	private ScenariosDao _scenarioDao = new ScenariosDao();

	private AuthState stateFilter;
	private AuthState newState;
	private MbAuthParams paramsBean;
	private Integer scenarioId;
	
    private final DaoDataModel<AuthState> _stateSource;
	private final TableRowSelection<AuthState> _itemSelection;
	private AuthState _activeState;
	
	private String tabName;
	private String parentSectionId;	

	public MbAuthStates() {
		pageLink = "scenario|states";
		tabName = "detailsTab";
		_stateSource = new DaoDataModel<AuthState>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected AuthState[] loadDaoData(SelectionParams params) {
				if (scenarioId == null || !searching) {
					return new AuthState[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getStates( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AuthState[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (scenarioId == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getStatesCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuthState>(null, _stateSource);
	}

	public DaoDataModel<AuthState> getStates() {
		return _stateSource;
	}

	public AuthState getActiveState() {
		return _activeState;
	}

	public void setActiveState(AuthState activeState) {
		_activeState = activeState;
	}

	public SimpleSelection getItemSelection() {
		if (_activeState == null && _stateSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeState != null && _stateSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeState.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeState = _itemSelection.getSingleSelection();	
			setInfoDepenedOnSeqNum();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_stateSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeState = (AuthState) _stateSource.getRowData();
		selection.addKey(_activeState.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeState != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeState = _itemSelection.getSingleSelection();
		
		if (_activeState != null) {
			setInfo();
		}
	}
	
	public void setInfoDepenedOnSeqNum() {
		paramsBean.setState(_activeState);
	}
	
	public void setInfo() {
		paramsBean = (MbAuthParams) ManagedBeanWrapper.getManagedBean("MbAuthParams");
		paramsBean.getFilter().setStateId(_activeState.getId());
		paramsBean.search();
		//Order of invoking serach() and setting State is important!
		paramsBean.setState(_activeState);
	}
	
	public void search() {
		clearBean();
		setSearching(true);
		scenarioId = stateFilter.getScenarioId();
	}

	public void clearFilter() {
		curLang = userLang;
		searching = false;
		stateFilter = new AuthState();
		scenarioId = null;
		
		clearBean();
	}

	public void setFilters() {
		stateFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (stateFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(stateFilter.getId().toString());
			filters.add(paramFilter);
		}
		if (stateFilter.getScenarioId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("scenarioId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(stateFilter.getScenarioId().toString());
			filters.add(paramFilter);
		}
		if (stateFilter.getCode() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("code");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(stateFilter.getCode().toString());
			filters.add(paramFilter);
		}
		if (stateFilter.getStateType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("stateType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(stateFilter.getStateType());
			filters.add(paramFilter);
		}
		if (stateFilter.getDescription() != null
				&& stateFilter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(stateFilter.getDescription().trim()
					.toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newState =  new AuthState();
		if (scenarioId != null) {
			newState.setScenarioId(scenarioId);
		}
		newState.setLang(userLang);
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newState = (AuthState) _activeState.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newState = _activeState;
		}
		curMode = EDIT_MODE;
	}
	
	public void delete() {
		try {
			_scenarioDao.deleteState( userSessionId, _activeState);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Asc", "state_deleted",
					"(id = " + _activeState.getId() + ")");
			
			_activeState = _itemSelection.removeObjectFromList(_activeState);
			if (_activeState == null) {
				clearBean();
			} else {
				setInfo();
			}
			
			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void save() {
		try {
			if (isNewMode()) {
				newState = _scenarioDao.addState( userSessionId, newState);
				_itemSelection.addNewObjectToList(newState);
			} else {
				newState = _scenarioDao.editState( userSessionId, newState);
				_stateSource.replaceObject(_activeState, newState);
			}
			_activeState = newState;
			setInfo();
			curMode = VIEW_MODE;
			
			FacesUtils.addMessageInfo(
					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Asc", "state_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public AuthState getFilter() {
		if (stateFilter == null) {
			stateFilter = new AuthState();
		}
		return stateFilter;
	}

	public void setFilter(AuthState stateFilter) {
		this.stateFilter = stateFilter;
	}

	public AuthState getNewState() {
		if (newState == null) {
			newState = new AuthState();
		}
		return newState;
	}

	public void setNewState(AuthState newState) {
		this.newState = newState;
	}
	
	public Integer getScenarioId() {
		return scenarioId;
	}

	public void setScenarioId(Integer scenarioId) {
		this.scenarioId = scenarioId;
	}
	
	public void clearBean() {
		_stateSource.flushCache();		
		_itemSelection.clearSelection();
		_activeState = null;
		
		// clear dependent bean 
		paramsBean = (MbAuthParams) ManagedBeanWrapper.getManagedBean("MbAuthParams");
		paramsBean.clearBean();
	}

	public ArrayList<SelectItem> getStateTypes() {
		return getDictUtils().getArticles(DictNames.AUTH_SCN_STATE_TYPE, true, true);		
	}
	
	public ArrayList<SelectItem> getScenarios() {
		ArrayList<SelectItem> items = null;
		try {
			List<Filter> filtersList = new ArrayList<Filter>();
			
			Filter paramFilter = new Filter();
			
			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);
				
			filters = filtersList;		
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			
			params.setRowIndexEnd(-1);
			Scenario[] scenarios = _scenarioDao.getScenarios( userSessionId, params);
			if (scenarios.length > 0) {
				items = new ArrayList<SelectItem>(scenarios.length);
				
				for (Scenario scenario: scenarios) {
					items.add(new SelectItem(scenario.getId(), scenario.getDescription()));
				}
			}
		} catch (Exception e) {
			logger.error("",e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		if (items == null) items = new ArrayList<SelectItem>(0);
		return items;
	}

	public static int getEditMode() {
		return EDIT_MODE;
	}

	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();
		
		List<Filter> filtersList = new ArrayList<Filter>();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeState.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
			
		filters = filtersList;		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			AuthState[] states = _scenarioDao.getStates( userSessionId, params);
			if (states != null && states.length > 0) {
				_activeState = states[0];				
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newState.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newState.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			AuthState[] states = _scenarioDao.getStates( userSessionId, params);
			if (states != null && states.length > 0) {
				newState = states[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "1084:statesTable";
		}
	}

	public Logger getLogger() {
		return logger;
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}

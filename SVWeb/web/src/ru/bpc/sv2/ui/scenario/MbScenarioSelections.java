package ru.bpc.sv2.ui.scenario;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.logic.ScenariosDao;
import ru.bpc.sv2.rules.CommunicationConstants;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.scenario.ScenarioSelection;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbScenarioSelections")
public class MbScenarioSelections extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("SCENARIO");

	private ScenariosDao _scenarioDao = new ScenariosDao();

	private RulesDao _rulesDao = new RulesDao();
	
	private ScenarioSelection scenarioFilter;
	private ScenarioSelection newSelection;

	private final DaoDataModel<ScenarioSelection> _selectionSource;
	private final TableRowSelection<ScenarioSelection> _itemSelection;
	private ScenarioSelection _activeSelection;

	private Integer scenarioId;
	private List<SelectItem> terminalTypes;
	private List<SelectItem> operReasons;
	
	private static String COMPONENT_ID = "selectionsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbScenarioSelections() {
		_selectionSource = new DaoDataModel<ScenarioSelection>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ScenarioSelection[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new ScenarioSelection[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getScenarioSelections(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ScenarioSelection[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getScenarioSelectionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ScenarioSelection>(null, _selectionSource);
	}

	public DaoDataModel<ScenarioSelection> getSelections() {
		return _selectionSource;
	}

	public ScenarioSelection getActiveSelection() {
		return _activeSelection;
	}

	public void setActiveSelection(ScenarioSelection activeSelection) {
		_activeSelection = activeSelection;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeSelection == null && _selectionSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeSelection != null && _selectionSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeSelection.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeSelection = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addErrorExceptionMessage(e);
			logger.error("", e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSelection = _itemSelection.getSingleSelection();
		if (_activeSelection != null) {
			setInfo();
		}
	}

	public void setFirstRowActive() {
		_selectionSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSelection = (ScenarioSelection) _selectionSource.getRowData();
		selection.addKey(_activeSelection.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeSelection != null) {
			setInfo();
		}
	}

	public void search() {
		setSearching(true);
		clearBean();
		clearBeansStates();
	}

	public void clearFilter() {
		searching = false;
		curLang = userLang;
		scenarioFilter = new ScenarioSelection();
		scenarioId = null;
		
		clearBean();
	}

	public void setInfo() {
	}

	private void setFilters() {
		scenarioFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = null;

		if (scenarioId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("scenarioId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(scenarioId);
			filters.add(paramFilter);
		}
		if (scenarioFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(scenarioFilter.getId().toString() + "%");
			filters.add(paramFilter);
		}
		if (scenarioFilter.getName() != null && scenarioFilter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(scenarioFilter.getName().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (scenarioFilter.getDescription() != null
				&& scenarioFilter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(scenarioFilter.getDescription().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (scenarioFilter.getOperType() != null){
			paramFilter = new Filter("operType", scenarioFilter.getOperType());
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newSelection = new ScenarioSelection();
		newSelection.setLang(userLang);
		newSelection.setScenarioId(scenarioId);
		curMode = NEW_MODE;
	}

	public void delete() {
		try {
			_scenarioDao.deleteScenarioSelection(userSessionId, _activeSelection);
			curMode = VIEW_MODE;
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Asc", "scenario_selection_deleted",
			        new Object[] { "(id = " + _activeSelection.getId() + ")" });

			_activeSelection = _itemSelection.removeObjectFromList(_activeSelection);
			if (_activeSelection == null) {
				clearBean();
			} else {
				setInfo();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			newSelection = _scenarioDao.addScenarioSelection(userSessionId, newSelection);
			_itemSelection.addNewObjectToList(newSelection);
			_activeSelection = newSelection;
			setInfo();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Asc",
			        "scenario_selection_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public ScenarioSelection getFilter() {
		if (scenarioFilter == null) {
			scenarioFilter = new ScenarioSelection();
		}
		return scenarioFilter;
	}

	public void setFilter(ScenarioSelection scenarioFilter) {
		this.scenarioFilter = scenarioFilter;
	}

	public ScenarioSelection getNewSelection() {
		if (newSelection == null) {
			newSelection = new ScenarioSelection();
		}
		return newSelection;
	}

	public void setNewSelection(ScenarioSelection newSelection) {
		this.newSelection = newSelection;
	}

	public void clearBean() {
		// search using new criteria
		_selectionSource.flushCache();
		// reset selection
		_itemSelection.clearSelection();
		_activeSelection = null;

		clearBeansStates();
	}

	public void clearBeansStates() {		
	}

	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> items;
		try {
			List<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("scaleType", CommunicationConstants.SCENARIO_SCALE_TYPE));
			SelectionParams params = new SelectionParams(filters);
			Modifier[] mods = _rulesDao.getModifiersForScenario(userSessionId,
					params);
			items = new ArrayList<SelectItem>();
			for (Modifier mod: mods) {
				items.add(new SelectItem(mod.getId(), mod.getName()));
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

	public Integer getScenarioId() {
		return scenarioId;
	}

	public void setScenarioId(Integer scenarioId) {
		this.scenarioId = scenarioId;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		operTypes = null;
		sttlTypes = null;
		msgTypes = null;
		_selectionSource.flushCache();
	}
	
	private List<SelectItem> operTypes;
	
	public List<SelectItem> getOperTypes(){
		if (operTypes == null){
			operTypes = getDictUtils().getArticles(DictNames.OPER_TYPE);
		}
		return operTypes;
	}
	
	private List<SelectItem> sttlTypes;
	
	public List<SelectItem> getSttlTypes(){
		if (sttlTypes == null){
			sttlTypes = getDictUtils().getArticles(DictNames.STTL_TYPE);
		}
		return sttlTypes;
	}

	private List<SelectItem> msgTypes;
	
	public List<SelectItem> getMsgTypes(){
		if (msgTypes == null){
			msgTypes = getDictUtils().getArticles(DictNames.MSG_TYPE);
		}
		return msgTypes;
	}
	
	public List<SelectItem> getTerminalTypes(){
		if (terminalTypes == null){
			terminalTypes = getDictUtils().getLov(LovConstants.TERMINAL_TYPES);
		}
		return terminalTypes;		
	}
	
	public List<SelectItem> getOperReasons(){
		if (operReasons == null){
			operReasons = getDictUtils().getLov(LovConstants.OPER_REASON);
		}
		return operReasons;
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

	public void clearState() {		
		_itemSelection.clearSelection();
		_activeSelection = null;
		_selectionSource.flushCache();
		curLang = userLang;
		
	}
}

package ru.bpc.sv2.ui.scenario;

import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.xml.ws.Binding;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.handler.Handler;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.datamanagement.DataManagement;
import ru.bpc.datamanagement.DataManagement_Service;
import ru.bpc.datamanagement.EntityObjStatusType;
import ru.bpc.datamanagement.EntityObjType;
import ru.bpc.datamanagement.ObjectFactory;
import ru.bpc.datamanagement.SyncronizeRqType;
import ru.bpc.datamanagement.SyncronizeRsType;
import ru.bpc.sv.ws.handlers.soap.SOAPLoggingHandler;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.logic.ScenariosDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.rules.CommunicationConstants;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.scenario.Scenario;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;



@ViewScoped
@ManagedBean (name = "MbScenarios")
public class MbScenarios extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("SCENARIO");

	private static String COMPONENT_ID = "1083:scenariosTable";

	private ScenariosDao _scenarioDao = new ScenariosDao();

	private RulesDao _rulesDao = new RulesDao();
	
	private SettingsDao settingsDao = new SettingsDao();

	private Scenario scenarioFilter;
	private Scenario newScenario;

	private final DaoDataModel<Scenario> _scenarioSource;
	private final TableRowSelection<Scenario> _itemSelection;
	private Scenario _activeScenario;
	
	private String tabName;

	public MbScenarios() {
		pageLink = "scenario|scenarios";
		tabName = "detailsTab";
		_scenarioSource = new DaoDataModel<Scenario>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Scenario[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new Scenario[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getScenarios(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Scenario[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _scenarioDao.getScenariosCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Scenario>(null, _scenarioSource);
	}

	public DaoDataModel<Scenario> getScenarios() {
		return _scenarioSource;
	}

	public Scenario getActiveScenario() {
		return _activeScenario;
	}

	public void setActiveScenario(Scenario activeScenario) {
		_activeScenario = activeScenario;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeScenario == null && _scenarioSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeScenario != null && _scenarioSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeScenario.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeScenario = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addErrorExceptionMessage(e);
			logger.error("", e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_scenarioSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeScenario = (Scenario) _scenarioSource.getRowData();
		selection.addKey(_activeScenario.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeScenario != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeScenario = _itemSelection.getSingleSelection();
		if (_activeScenario != null) {
			setInfo();
		}
	}

	public void search() {
		setSearching(true);
		clearBean();
		clearBeansStates();
	}

	public void clearFilter() {
		curLang = userLang;
		searching = false;
		scenarioFilter = new Scenario();
		clearBean();
	}

	public void setInfo() {
		MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
				.getManagedBean("MbNotesSearch");
		ObjectNoteFilter filterNote = new ObjectNoteFilter();
		filterNote.setEntityType(EntityNames.SCENARIO);
		filterNote.setObjectId(_activeScenario.getId().longValue());
		notesSearch.setFilter(filterNote);
		notesSearch.search();

		MbScenarioSelections scenarioSelections = (MbScenarioSelections) ManagedBeanWrapper
		        .getManagedBean("MbScenarioSelections");
		scenarioSelections.setScenarioId(_activeScenario.getId());
		scenarioSelections.search();
		
		MbAuthStates statesBean = (MbAuthStates) ManagedBeanWrapper.getManagedBean("MbAuthStates");
		statesBean.clearFilter();
		statesBean.getFilter().setScenarioId(_activeScenario.getId());
		statesBean.search();
	}

	public void setFilters() {
		scenarioFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = null;

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

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newScenario = new Scenario();
		newScenario.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newScenario = (Scenario) _activeScenario.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newScenario = _activeScenario;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_scenarioDao.deleteScenario(userSessionId, _activeScenario);
			curMode = VIEW_MODE;
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Asc", "scenario_deleted",
					new Object[] { "(id = " + _activeScenario.getId() + ")" });

			_activeScenario = _itemSelection.removeObjectFromList(_activeScenario);
			if (_activeScenario == null) {
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
			if (isNewMode()) {
				newScenario = _scenarioDao.addScenario(userSessionId, newScenario);
				_itemSelection.addNewObjectToList(newScenario);
			} else {
				newScenario = _scenarioDao.editScenario(userSessionId, newScenario);
				_scenarioSource.replaceObject(_activeScenario, newScenario);
			}
			_activeScenario = newScenario;
			setInfo();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Asc",
					"scenario_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public String editStates() {
		if (_activeScenario != null) {
			MbAuthStates statesBean = (MbAuthStates) ManagedBeanWrapper
					.getManagedBean("MbAuthStates");
			statesBean.getFilter().setScenarioId(_activeScenario.getId());
			statesBean.search();
			Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			mbMenu.externalSelect("scenario|states");
			return "editStates";
		} else {
			return "";
		}
	}

	public Scenario getFilter() {
		if (scenarioFilter == null) {
			scenarioFilter = new Scenario();
		}
		return scenarioFilter;
	}

	public void setFilter(Scenario scenarioFilter) {
		this.scenarioFilter = scenarioFilter;
	}

	public Scenario getNewScenario() {
		if (newScenario == null) {
			newScenario = new Scenario();
		}
		return newScenario;
	}

	public void setNewScenario(Scenario newScenario) {
		this.newScenario = newScenario;
	}

	public void changeDescLang(ValueChangeEvent event) {
		String newLang = (String) event.getNewValue();
		try {
			Scenario scn = _scenarioDao.getScnByLangAndId(userSessionId, newScenario.getId(),
					newLang);
			if (scn != null) {
				newScenario.setDescription(scn.getDescription());
				newScenario.setLang(newLang);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void clearBean() {
		// search using new criteria
		_scenarioSource.flushCache();
		// reset selection
		_itemSelection.clearSelection();
		_activeScenario = null;

		clearBeansStates();
	}

	public void clearBeansStates() {
		MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper.getManagedBean("MbNotesSearch");
		notesSearch.clearState();
		notesSearch.setFilter(null);

		MbScenarioSelections selectionsBean = (MbScenarioSelections) ManagedBeanWrapper.getManagedBean("MbScenarioSelections");
		selectionsBean.clearFilter();
		
		MbAuthStates statesBean = (MbAuthStates) ManagedBeanWrapper.getManagedBean("MbAuthStates");
		statesBean.clearFilter();
	}

	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> items;
		try {
			Modifier[] mods = _rulesDao.getModifiersByScaleType(userSessionId,
					CommunicationConstants.SCENARIO_SCALE_TYPE);
			items = new ArrayList<SelectItem>();
			for (Modifier mod: mods) {
				items.add(new SelectItem(mod.getId(), mod.getName()));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeScenario.getId().toString());
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
			Scenario[] scenarios = _scenarioDao.getScenarios(userSessionId, params);
			if (scenarios != null && scenarios.length > 0) {
				_activeScenario = scenarios[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void reload() {
		try {
			List<Scenario> selectedScenarios = _itemSelection
					.getMultiSelection();
			if (selectedScenarios.size() == 0) {
				return;
			}

			String feLocation = settingsDao.getParameterValueV(userSessionId,
					SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM,
					null);
			if (feLocation == null || feLocation.trim().length() == 0){
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
				FacesUtils.addErrorExceptionMessage(msg);
				return;
			}
			Double wsPort = settingsDao.getParameterValueN(userSessionId,
					SettingsConstants.UPDATE_CACHE_WS_PORT, LevelNames.SYSTEM, null);
			if (wsPort == null) {
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
						SettingsConstants.UPDATE_CACHE_WS_PORT);
				FacesUtils.addErrorExceptionMessage(msg);
			}
			feLocation = feLocation + ":" + wsPort.intValue();

			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType
					.getEntityObj();

			for (Scenario scenario : selectedScenarios) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(scenario.getId().toString());
				entityObj.setObjSeq(scenario.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(EntityNames.SCENARIO);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider)port;
			bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
			bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
			bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);
			
			Binding binding = bp.getBinding();
			@SuppressWarnings({ "rawtypes" })
			List<Handler> soapHandlersList = new ArrayList<Handler>();
			SOAPLoggingHandler soapHandler = new SOAPLoggingHandler();
			soapHandler.setLogger(getLogger());
			soapHandlersList.add(soapHandler);
			binding.getHandlerChain();
			binding.setHandlerChain(soapHandlersList);
			
			SyncronizeRsType rsType = null;
			try {
				rsType = port.syncronize(syncronizeRqType);
			} catch (Exception e) {
				String msg = null;
				if (e.getCause() instanceof UnknownHostException){
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "unknown_host", e.getCause().getMessage()) + ".";
				} else if (e.getCause() instanceof SocketTimeoutException){
					msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "web_service_timeout");
				} else {
					msg = e.getMessage();
				}
				msg += ". " + FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "check_front_end_settings");
				FacesUtils.addErrorExceptionMessage(msg);
				logger.error("", e);
				return;
			}
			List<EntityObjStatusType> objStatusTypes = rsType.getEntityObjStatus();
			
			for (int i=0;i<selectedScenarios.size();i++){
				Scenario scenario = selectedScenarios.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				scenario.setFerrNo(objStatusType.getFerrno());
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newScenario.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newScenario.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Scenario[] scenarios = _scenarioDao.getScenarios(userSessionId, params);
			if (scenarios != null && scenarios.length > 0) {
				newScenario = scenarios[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public List<Scenario> getSelectedItems(){
		return _itemSelection.getMultiSelection();
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
		
		if (tabName.equalsIgnoreCase("notesTab")) {
			MbNotesSearch bean = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("selectionTab")) {
			MbScenarioSelections bean = (MbScenarioSelections) ManagedBeanWrapper
					.getManagedBean("MbScenarioSelections");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("statesTab")) {
			MbAuthStates bean = (MbAuthStates) ManagedBeanWrapper
					.getManagedBean("MbAuthStates");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
			
			MbAuthParams bean1 = (MbAuthParams) ManagedBeanWrapper
					.getManagedBean("MbAuthParams");
			bean1.setTabName(tabName);
			bean1.setParentSectionId(getSectionId());
			bean1.setTableState(getSateFromDB(bean1.getComponentId()));
		}	
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_AUTH_SCENARIO;
	}

}

package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.atm.MbAtmDispensersSearch;
import ru.bpc.sv2.ui.atm.MbTerminalATMs;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbTerminalTemplates")
public class MbTerminalTemplates extends AbstractBean{
	private static final long serialVersionUID = 6128867958423762164L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private static String COMPONENT_ID = "1293:templatesTable";

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private MbTerminalATMs terminalATMs;

	private Terminal filter;
	private Terminal _activeTemplate;
	private Terminal newTemplate;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> availableCurrencies;
	private ArrayList<SelectItem> availableNetworks;
	private ArrayList<SelectItem> availableOperations;
	private ArrayList<SelectItem> cardCaptureCaps;
	private ArrayList<SelectItem> cardDataInputCaps;
	private ArrayList<SelectItem> cardDataInputModes;
	private ArrayList<SelectItem> cardDataOutputCaps;
	private ArrayList<SelectItem> cardDataPresents;
	private ArrayList<SelectItem> catLevels;
	private ArrayList<SelectItem> crdhAuthCaps;
	private ArrayList<SelectItem> crdhAuthEntities;
	private ArrayList<SelectItem> crdhAuthMethods;
	private ArrayList<SelectItem> crdhDataPresents;
	private ArrayList<SelectItem> pinCaptureCaps;
	private ArrayList<SelectItem> standards;
	private ArrayList<SelectItem> termDataOutputCaps;
	private ArrayList<SelectItem> termOperatingEnvs;

	private final DaoDataModel<Terminal> _templatesSource;

	private final TableRowSelection<Terminal> _itemSelection;

	private boolean slaveMode = false;
		
	private String tabName;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	private List<SelectItem> gmtOffsets;
	private boolean showModal;
	
	public MbTerminalTemplates() {
		showModal=false;
		tabName = "detailsTab";
		pageLink = "cmn|templates";
		terminalATMs = (MbTerminalATMs) ManagedBeanWrapper.getManagedBean("MbTerminalATMs");
		terminalATMs.setSlaveMode(true);

		_templatesSource = new DaoDataModel<Terminal>() {
			private static final long serialVersionUID = 9072985949133235548L;

			@Override
			protected Terminal[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Terminal[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getTerminalTemplates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new Terminal[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getTerminalTemplatesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Terminal>(null, _templatesSource);
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbTerminalTemplates");

		if (queueFilter==null)
			return;
		if (queueFilter.containsKey("inst")){
			getFilter().setInstId((Integer)queueFilter.get("inst"));
		}
		if (queueFilter.containsKey("terminalType")){
			getFilter().setTerminalType((String)queueFilter.get("terminalType"));
		}
		if (queueFilter.containsKey("name")){
			getFilter().setName((String)queueFilter.get("name"));
		}
		if (queueFilter.containsKey("status")){
			getFilter().setStatus((String)queueFilter.get("status"));
		}
		
		if (queueFilter.containsKey("showModal")){
			setShowModal(((String)queueFilter.get("showModal")).equals("true"));
			if (queueFilter.containsKey("newTemplate")){
				setNewTemplate((Terminal) queueFilter.get("newTemplate"));
			}
			if (queueFilter.containsKey("curMode")){
				curMode = (Integer)queueFilter.get("curMode");
			}
		}
	
		search();
	}

	@PostConstruct
	public void init() {
		setDefaultValues();
		restoreFilter();
	}
	
	public DaoDataModel<Terminal> getTemplates() {
		return _templatesSource;
	}

	public Terminal getActiveTemplate() {
		return _activeTemplate;
	}

	public void setActiveTemplate(Terminal activeTemplate) {
		_activeTemplate = activeTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTemplate == null && _templatesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTemplate != null && _templatesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTemplate.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTemplate = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_templatesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTemplate = (Terminal) _templatesSource.getRowData();
		selection.addKey(_activeTemplate.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTemplate != null) {
			setBeans();
		}
	}

	public void setItemSelection(SimpleSelection selection) {		
		_itemSelection.setWrappedSelection(selection);
		_activeTemplate = _itemSelection.getSingleSelection();
		if (_activeTemplate != null) {
			setBeans();
		}
	}

	public void setInfo() {

	}

	public void clearBeansStates() {
		MbAtmDispensersSearch bean = (MbAtmDispensersSearch) ManagedBeanWrapper
			.getManagedBean("MbAtmDispensersSearch");
		bean.clearFilter();
		
		MbMccSelection mbMccSelection = ManagedBeanWrapper.getManagedBean(MbMccSelection.class);
		mbMccSelection.clearFilter();
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = new Terminal();
		clearState();
		clearBeansStates();
		setDefaultValues();
		searching = false;
	}

	public Terminal getFilter() {
		if (filter == null)
			filter = new Terminal();
		return filter;
	}

	public void setFilter(Terminal filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getTerminalType() != null && filter.getTerminalType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getTerminalType());
			filters.add(paramFilter);
		}
		
		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStatus());
			filters.add(paramFilter);
		}
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_templatesSource.flushCache();
		_activeTemplate = null;

		clearBeansStates();
		loadedTabs.clear();
	}
	
	private void setBeans() {
//		terminalATMs.clearFilter();
//		terminalATMs.getFilter().setId(getActiveTemplate().getId());
//		terminalATMs.loadTerminalATM();
//		
//		MbAtmDispensersSearch dispensers = (MbAtmDispensersSearch) ManagedBeanWrapper
//				.getManagedBean("MbAtmDispensersSearch");
//		AtmDispenser dispenserFilter = new AtmDispenser();
//		dispenserFilter.setTerminalId(getActiveTemplate().getId());
//		dispensers.setDispenserFilter(dispenserFilter);
//		dispensers.search();
		loadedTabs.clear();
		loadTab(getTabName());
	}
	
	public void add() {
		newTemplate = new Terminal();
		newTemplate.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newTemplate = (Terminal) _activeTemplate.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newTemplate = _activeTemplate;
		}
		curMode = EDIT_MODE;
	}

	public void view() {

	}

	public void save() {
		try {
			if (isNewMode()) {
				newTemplate = _acquiringDao.addTerminalTemplate(userSessionId, newTemplate);
				_itemSelection.addNewObjectToList(newTemplate);
			} else if (isEditMode()) {
				newTemplate = _acquiringDao.modifyTerminalTemplate(userSessionId, newTemplate);
				if (!slaveMode) {
					_templatesSource.replaceObject(_activeTemplate, newTemplate);
				}
			}
			_activeTemplate = newTemplate;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_acquiringDao.deleteTerminalTemplate(userSessionId, _activeTemplate, terminalATMs.getActiveATM());

			_activeTemplate = _itemSelection.removeObjectFromList(_activeTemplate);
			if (_activeTemplate == null) {
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

	public Terminal getNewTemplate() {
		if (newTemplate == null) {
			newTemplate = new Terminal();
		}
		return newTemplate;
	}

	public void setNewTemplate(Terminal newTemplate) {
		this.newTemplate = newTemplate;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeTemplate = null;
		_templatesSource.flushCache();
		curLang = userLang;
		loadedTabs.clear();
	}

	public ArrayList<SelectItem> getTerminalTypes() {
		return getDictUtils().getArticles(DictNames.TERMINAL_TYPE, false, true);
	}

	public ArrayList<SelectItem> getCardDataInputCaps() {
		if(cardDataInputCaps == null){
			cardDataInputCaps = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARD_DATA_INPUT_CAP);
		}
		if(cardDataInputCaps == null){
			cardDataInputCaps = new ArrayList<SelectItem>();
		}
		return cardDataInputCaps;
	}

	public ArrayList<SelectItem> getCrdhAuthCaps() {
		if(crdhAuthCaps == null){
			crdhAuthCaps = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CRDH_AUTH_CAP);
		}
		if(crdhAuthCaps == null){
			crdhAuthCaps = new ArrayList<SelectItem>();
		}
		return crdhAuthCaps;
	}

	public ArrayList<SelectItem> getCardCaptureCaps() {
		if(cardCaptureCaps == null){
			cardCaptureCaps = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARD_CAPTURE_CAP);
		}
		if(cardCaptureCaps == null){
			cardCaptureCaps = new ArrayList<SelectItem>();
		}
		return cardCaptureCaps;
	}

	public ArrayList<SelectItem> getTermOperatingEnvs() {
		if(termOperatingEnvs == null){
			termOperatingEnvs = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.TERM_OPERATING_ENV);
		}
		if(termOperatingEnvs == null){
			termOperatingEnvs = new ArrayList<SelectItem>();
		}
		return termOperatingEnvs;
	}

	public ArrayList<SelectItem> getCrdhDataPresents() {
		if(crdhDataPresents == null){
			crdhDataPresents = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CRDH_DATA_PRESENT);
		}
		if(crdhDataPresents == null){
			crdhDataPresents = new ArrayList<SelectItem>();
		}
		return crdhDataPresents;
	}

	public ArrayList<SelectItem> getCardDataPresents() {
		if(cardDataPresents == null){
			cardDataPresents = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARD_DATA_PRESENT);
		}
		if(cardDataPresents == null){
			cardDataPresents = new ArrayList<SelectItem>();
		}
		return cardDataPresents;
	}

	public ArrayList<SelectItem> getCardDataInputModes() {
		if(cardDataInputModes == null){
			cardDataInputModes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARD_DATA_INPUT_MODE);
		}
		if(cardDataInputModes == null){
			cardDataInputModes = new ArrayList<SelectItem>();
		}
		return cardDataInputModes;
	}

	public ArrayList<SelectItem> getCrdhAuthMethods() {
		if(crdhAuthMethods == null){
			crdhAuthMethods = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CRDH_AUTH_METHOD);
		}
		if(crdhAuthMethods == null){
			crdhAuthMethods = new ArrayList<SelectItem>();
		}
		return crdhAuthMethods;
	}

	public ArrayList<SelectItem> getCrdhAuthEntities() {
		if(crdhAuthEntities == null){
			crdhAuthEntities = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CRDH_AUTH_ENTITY);
		}
		if(crdhAuthEntities == null){
			crdhAuthEntities = new ArrayList<SelectItem>();
		}
		return crdhAuthEntities;
	}

	public ArrayList<SelectItem> getCardDataOutputCaps() {
		if(cardDataOutputCaps == null){
			cardDataOutputCaps = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARD_DATA_OUTPUT_CAP);
		}
		if(cardDataOutputCaps == null){
			cardDataOutputCaps =  new ArrayList<SelectItem>();
		}
		return cardDataOutputCaps;
	}

	public ArrayList<SelectItem> getTermDataOutputCaps() {
		if(termDataOutputCaps == null){
			termDataOutputCaps = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.TERM_DATA_OUTPUT_CAP);
		}
		if(termDataOutputCaps == null){
			termDataOutputCaps = new ArrayList<SelectItem>();
		}
		return termDataOutputCaps;
	}

	public ArrayList<SelectItem> getPinCaptureCaps() {
		if(pinCaptureCaps == null){
			pinCaptureCaps = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.PIN_CAPTURE_CAP);
		}
		if(pinCaptureCaps == null){
			pinCaptureCaps = new ArrayList<SelectItem>();
		}
		return pinCaptureCaps;
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.TERMINAL_STATUS, false, false);
	}

	public ArrayList<SelectItem> getCatLevels() {
		if(catLevels == null){
			catLevels = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CARDHOLDER_ACTIVATED_TERMINAL_LEVEL);
		}
		if(catLevels == null){
			catLevels = new ArrayList<SelectItem>();
		}
		return catLevels;
	}
	
	public List<SelectItem> getStandards() {
		if(standards == null){
			standards = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.STANDARD_ATM);
		}
		if(standards == null){
			standards = new ArrayList<SelectItem>();
		}
		return standards;
	}
	
	public String getStandardName() {
		String result = "";
		if (getActiveTemplate() != null) {
			 HashMap<String, String> lovMap = getDictUtils().getLovMap(LovConstants.STANDARD_ATM);
			 result = lovMap.get(String.valueOf(getActiveTemplate().getStandardId()));
		}
		return result;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeTemplate.getId().toString());
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
			Terminal[] methods = _acquiringDao.getTerminalTemplates(userSessionId, params);
			if (methods != null && methods.length > 0) {
				_activeTemplate = methods[0];
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
		filters[0].setValue(newTemplate.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newTemplate.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Terminal[] methods = _acquiringDao.getTerminalTemplates(userSessionId, params);
			if (methods != null && methods.length > 0) {
				newTemplate = methods[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
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
	public Terminal loadTerminalTemplate() {
		setFilters();
		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			Terminal[] templates = _acquiringDao.getTerminalTemplates(userSessionId, params);
			if (templates != null && templates.length > 0) {
				_activeTemplate = templates[0];
				return templates[0];
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
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
	}
	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (getActiveTemplate() == null || getActiveTemplate().getId() == null)
			return;
		
		if (tab.equals("termATMsTab")) {
			terminalATMs.clearFilter();
			terminalATMs.getFilter().setId(getActiveTemplate().getId());
			terminalATMs.setTemplate(true);
			terminalATMs.loadTerminalATM();
		}
		
		if (tab.equals("dispensersTab")) {
			MbAtmDispensersSearch dispensers = (MbAtmDispensersSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmDispensersSearch");
			dispensers.clearFilter();
			dispensers.getDispenserFilter().setTerminalId(getActiveTemplate().getId());
			dispensers.disableButtons(getActiveTemplate().getId(), true);
			dispensers.search();
		}
		
		if (tab.equals("mccRedefinitionsTab")){
			MbMccSelection mbMccSelection = ManagedBeanWrapper.getManagedBean(MbMccSelection.class);
			mbMccSelection.clearFilter();
			mbMccSelection.getFilter().setMccTemplateId(getActiveTemplate().getMccTemplateId());
			mbMccSelection.search();
		}
		
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}
	
	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}
	
	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getGmtOffsets(){
		if (gmtOffsets == null){
			gmtOffsets = getDictUtils().getLov(LovConstants.GMT_OFFSETS);
		}
		return gmtOffsets; 
	}
	
	public List<SelectItem> getAvailableNetworks() {
		if(availableNetworks == null){
			availableNetworks = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.AVAILABLE_NETWORKS);
		}
		if(availableNetworks == null){
			availableNetworks = new ArrayList<SelectItem>();
		}
		return availableNetworks;
	}

	public List<SelectItem> getAvailableOperations() {
		if(availableOperations == null){
			availableOperations = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.AVAILABLE_OPERATIONS);
		}
		if(availableOperations == null){
			availableOperations = new ArrayList<SelectItem>();
		}
		return availableOperations;
	}

	public List<SelectItem> getAvailableCurrencies() {
		if(availableCurrencies == null){
			availableCurrencies = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.AVAILABLE_CURRENCIES);
		}
		if(availableCurrencies == null){
			availableCurrencies = new ArrayList<SelectItem>();
		}
		return availableCurrencies;
	}

	private void setDefaultValues() {
		if (sectionFilterModeEdit) return;
		
		filter = new Terminal();
		filter.setInstId(userInstId);
	}
	
	private List<SelectItem> mccSelectionTemplates;
	private Map<Long, String> mccSelectionTemplatesMap;
	
	public List<SelectItem> getMccSelectionTemplates(){
		if (mccSelectionTemplates == null){
			initMccSelectionTemplates();
		}
		return mccSelectionTemplates;
	}
	
	private void initMccSelectionTemplates(){
		mccSelectionTemplates = getDictUtils().getLov(LovConstants.MCC_SELECTION_TEMPLATE);
		mccSelectionTemplatesMap = new HashMap<Long, String>();
		for (SelectItem item : mccSelectionTemplates){
			mccSelectionTemplatesMap.put(new Long(item.getValue().toString()), item.getLabel());
		}
	}
	
	public Map<Long, String> getMccSelectionTemplatesMap(){
		if (mccSelectionTemplatesMap == null){
			initMccSelectionTemplates();
		}
		return mccSelectionTemplatesMap;
	}
	
	public String addNewAvailable(){
		Integer arrayTypeId = getArrayTypesId("TERMINAL_AVAILABLE_NETWORKS");

		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("inst", getFilter().getInstId());
		queueFilter.put("terminalType", getFilter().getTerminalType());
		queueFilter.put("name", getFilter().getName());
		queueFilter.put("status", getFilter().getStatus());
		queueFilter.put("showModal", "true");
		queueFilter.put("newTemplate", newTemplate);
		queueFilter.put("curMode", curMode);
		addFilterToQueue("MbTerminalTemplates", (HashMap<String,Object>)queueFilter.clone());
		
		queueFilter.clear();
		queueFilter.put("arrayTypeId", arrayTypeId);
		queueFilter.put("backLink", pageLink);
		addFilterToQueue("MbArrays", queueFilter);
		
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect("arrays|arrays");
		
		return "arrays|arrays";
	}
	
	public Integer getArrayTypesId(String name) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("name_code", name);
		if (getDictUtils().getLov(LovConstants.ARRAY_TYPE, map).size()>0){
			return Integer.valueOf((String) getDictUtils().getLov(LovConstants.ARRAY_TYPE, map).get(0).getValue());
		}
		return null;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}
}

package ru.bpc.sv2.ui.acquiring;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.datamanagement.*;
import ru.bpc.sv2.accounts.AccountPrivConstants;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.atm.AtmDispenser;
import ru.bpc.sv2.cmn.CmnPrivConstants;
import ru.bpc.sv2.cmn.TcpIpDevice;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.notes.ObjectNoteFilter;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.accounts.MbAccountsSearch;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.atm.MbAtmCashIns;
import ru.bpc.sv2.ui.atm.MbAtmCollectionsSearch;
import ru.bpc.sv2.ui.atm.MbAtmDispensersSearch;
import ru.bpc.sv2.ui.atm.MbTerminalATMs;
import ru.bpc.sv2.ui.aup.MbAupSchemeObjects;
import ru.bpc.sv2.ui.cmn.MbTcpIpDevices;
import ru.bpc.sv2.ui.common.MbAddressesSearch;
import ru.bpc.sv2.ui.common.MbContactDataSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.events.MbStatusLogs;
import ru.bpc.sv2.ui.fcl.cycles.MbCycleCounters;
import ru.bpc.sv2.ui.fcl.limits.MbLimitCounters;
import ru.bpc.sv2.ui.fraud.MbFraudObjects;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.network.MbIfConfig;
import ru.bpc.sv2.ui.notes.MbNotesSearch;
import ru.bpc.sv2.ui.pmo.MbObjectPurposeParameterValues;
import ru.bpc.sv2.ui.pmo.MbObjectPurposes;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.products.MbCustomersDependent;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import ru.bpc.sv2.ui.reports.MbEntityObjectInfoBottom;
import ru.bpc.sv2.ui.reports.MbReportsBottom;
import ru.bpc.sv2.ui.security.MbDesKeysBottom;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.xml.ws.BindingProvider;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.text.ParseException;
import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean(name = "MbTerminal")
public class MbTerminal extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");
	private static Logger classLogger = Logger.getLogger(MbTerminal.class);
	
	private static String COMPONENT_ID = "1021:terminalsTable";
	private static String COMPONENT_TAB_ID = "1021:terminalsTabs";

	public static final String ATM_TERMINAL = "TRMT0002";
	public static final String IMPRINTER = "TRMT0001";

	private AcquiringDao _acquringDao = new AcquiringDao();
	private SettingsDao settingsDao = new SettingsDao();
	private ProductsDao _productsDao = new ProductsDao();
	private EventsDao _eventsDao = new EventsDao();

	private MbTerminalATMs terminalATMs;

	// private TerminalTemplate[] terminals;
	private LinkedHashMap<Integer, Terminal> terminals;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> terminalTypes;
	private Terminal _activeTerminal;
	

	protected String tabName;
	protected HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	protected String needRerender;
	private List<String> rerenderList;

	private boolean _managingNew;
	private Terminal filter;
	private boolean selectMode = false;

	private final DaoDataModel<Terminal> _terminalSource;
	private final TableRowSelection<Terminal> _itemSelection;

	private String backLink;
	private Long accountId;

	protected MbTerminalSess sessionBean;
	private List<Terminal> reloadResult;

	private Map<String, Boolean> renderTabsMap;
	private Menu mbMenu;
	private HashMap<String, Object> paramMap;
	
	private ContextType ctxType;
	private String ctxItemEntityType;
	
	private Boolean useHsm;

	public MbTerminal() {
		pageLink = "acquiring|terminals";
		tabName = "detailsTab";
		thisBackLink = "acquiring|terminals";
		sessionBean = (MbTerminalSess) ManagedBeanWrapper.getManagedBean("MbTerminalSess");
		mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
//		terminalATMs = (MbTerminalATMs) ManagedBeanWrapper.getManagedBean("MbTerminalATMs");
//		terminalATMs.setSlaveMode(true);

		_terminalSource = new DaoDataModel<Terminal>(true) {
			private static final long serialVersionUID = 1L;

			@Override
			protected Terminal[] loadDaoData(SelectionParams params) {
				if (restoreBean) {
					FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
					if (sessionBean.getTerminalsList() != null) {
						List<Terminal> terminalsList = sessionBean.getTerminalsList();
						sessionBean.setTerminalsList(null);
						return (Terminal[]) terminalsList
								.toArray(new Terminal[terminalsList.size()]);
					}
				}
				if (!searching) {
					return new Terminal[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquringDao.getTerminalsCur(userSessionId, params, getParamMap());
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Terminal[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (restoreBean && sessionBean.getTerminalsList() != null) {
					return sessionBean.getTerminalsList().size();
				}
				if (!searching) {
					return 0;
				}
				int count = 0;
				int threshold = 300;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setThreshold(threshold);
					count = _acquringDao.getTerminalsCountCur(userSessionId, getParamMap());
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return count;
			}
		};

		_itemSelection = new TableRowSelection<Terminal>(null, _terminalSource);
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbTerminal");
		if (queueFilter==null)
			return;
		clearFilter();
		setSelectMode(true);
		if (queueFilter.containsKey("merchantNumber")){
			getFilter().setMerchantNumber((String)queueFilter.get("merchantNumber"));
		}
		if (queueFilter.containsKey("instId")){
			getFilter().setInstId((Integer)queueFilter.get("instId"));
		}
		if (queueFilter.containsKey("backLink")){
			backLink=(String)queueFilter.get("backLink");
		}
        if (queueFilter.containsKey("terminalNumber")){
            getFilter().setTerminalNumber((String)queueFilter.get("terminalNumber"));
        }
        if (queueFilter.containsKey("terminalType")){
            getFilter().setTerminalType((String)queueFilter.get("terminalType"));
        }
		search();
	}

	@PostConstruct
	public void init() {
		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}

		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE; // just to be sure it's not NULL
		} else {
			filter = sessionBean.getFilter();
			_activeTerminal = sessionBean.getActiveTerminal();
			backLink = sessionBean.getBackLink();
			accountId = sessionBean.getAccountId();
			selectMode = sessionBean.isSelectMode();
			tabName = sessionBean.getTabName();
			rowsNum = sessionBean.getRowsNum();
			pageNumber = sessionBean.getPageNumber();

			if (_activeTerminal != null) {
				searching = true;
				setBeans();
			}
		}
	}
	
	public DaoDataModel<Terminal> getTerminals() {
		return _terminalSource;
	}

	public Terminal getActiveTerminal() {
		return _activeTerminal;
	}

	public void setActiveTerminal(Terminal activeTerminal) {
		_activeTerminal = activeTerminal;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeTerminal == null && _terminalSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeTerminal != null && _terminalSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeTerminal.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeTerminal = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}

		return _itemSelection.getWrappedSelection();
	}

	public Terminal getTerminal() {
		if (StringUtils.isNotEmpty(getFilter().getTerminalNumber())) {
			try {
				setFilters();
				SelectionParams params = new SelectionParams(filters);
				Terminal[] terminals = _acquringDao.getTerminalsCur(userSessionId, params, getParamMap());
				if (terminals != null && terminals.length > 0) {
					_activeTerminal = terminals[0];
				}
				return _activeTerminal;
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTerminal = _itemSelection.getSingleSelection();

		if (_activeTerminal != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_terminalSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTerminal = (Terminal) _terminalSource.getRowData();
		selection.addKey(_activeTerminal.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTerminal != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		if (_activeTerminal != null) {
			setRenderTabs(true);
			sessionBean.setAccountId(accountId);
			sessionBean.setActiveTerminal(_activeTerminal);
			sessionBean.setBackLink(backLink);
			sessionBean.setFilter(filter);
			sessionBean.setSelectMode(selectMode);
			sessionBean.setRowsNum(rowsNum);
			sessionBean.setPageNumber(pageNumber);
			sessionBean.setTerminalsList(_terminalSource.getActivePage());
		}
		loadedTabs.clear();
		loadTab(getTabName());
	}

	private void loadTab(String tab) {
		if (tab == null || _activeTerminal == null || _activeTerminal.getId() == null) {
			return;
		}
		if (tab.equalsIgnoreCase("detailsTab")) {
			String reason = _eventsDao.getStatusReason(userSessionId, _activeTerminal.getId().longValue(), EntityNames.TERMINAL);
			_activeTerminal.setStatusReason(reason);
		} else if (tab.equalsIgnoreCase("accountsTab")) {
			// get accounts for this terminal
			MbAccountsSearch accountsBean = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsSearch");
			accountsBean.clearFilter();
			accountsBean.getFilter().setEntityType(EntityNames.TERMINAL);
			accountsBean.getFilter().setObjectId(_activeTerminal.getId().longValue());
			accountsBean.getFilter().setInstId(_activeTerminal.getInstId());
			accountsBean.setSearchByObject(true);
			accountsBean.setBackLink(thisBackLink);
			accountsBean.setPrivilege(AccountPrivConstants.VIEW_TAB_ACCOUNT);
			accountsBean.setParticipantType("ACQ");
			accountsBean.search();
		} else if (tab.equalsIgnoreCase("contactsTab")) {
			// get contacts for this terminal
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearch");
			cont.setBackLink("acq_terminals");
			cont.setObjectId(_activeTerminal.getId().longValue());
			cont.setEntityType(EntityNames.TERMINAL);
			cont.setActiveContact(null);
			cont.search();
		} else if (tab.equalsIgnoreCase("addressesTab")) {
			// get addresses for this terminal
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
			addr.fullCleanBean();
            addr.getFilter().setEntityType(EntityNames.TERMINAL);
            addr.getFilter().setObjectId(_activeTerminal.getId().longValue());
			addr.setCurLang(userLang);
            addr.search();
		} else if (tab.equalsIgnoreCase("additionalTab")) {
			// get flexible data for this terminal
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			FlexFieldData filterFlex = new FlexFieldData();
			filterFlex.setInstId(_activeTerminal.getInstId());
			filterFlex.setEntityType(EntityNames.TERMINAL);
			filterFlex.setObjectType(_activeTerminal.getTerminalType());
			filterFlex.setObjectId(_activeTerminal.getId().longValue());
			flexible.setFilter(filterFlex);
			flexible.search();
		} else if (tab.equalsIgnoreCase("keysTab")) {
			MbDesKeysBottom keys = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysBottom");
			keys.fullCleanBean();
			keys.getFilter().setEntityType(EntityNames.TERMINAL);
			keys.getFilter().setObjectId(_activeTerminal.getId().longValue());
			keys.setDeviceId(_activeTerminal.getDeviceId());
			keys.setInstId(_activeTerminal.getInstId());
			keys.setShowTranslate(false);
			keys.search();
		} else if (tab.equalsIgnoreCase("notesTab")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			ObjectNoteFilter filterNote = new ObjectNoteFilter();
			filterNote.setEntityType(EntityNames.TERMINAL);
			filterNote.setObjectId(_activeTerminal.getId().longValue());
			notesSearch.setFilter(filterNote);
			notesSearch.search();
		} else if (tab.equalsIgnoreCase("attrsTab")) {
			MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
					.getManagedBean("MbObjectAttributes");
			attrs.fullCleanBean();
			attrs.setObjectId(_activeTerminal.getId().longValue());
			attrs.setProductId(_activeTerminal.getProductId());
			attrs.setEntityType(EntityNames.TERMINAL);
			attrs.setInstId(_activeTerminal.getInstId());
			attrs.setProductType(_activeTerminal.getProductType());
		} else if (tab.equalsIgnoreCase("connectivityTab")) {
			loadTerminalDevice();
		} else if (tab.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			limitCounters.setFilter(null);
			limitCounters.getFilter().setObjectId(_activeTerminal.getId().longValue());
			limitCounters.getFilter().setInstId(_activeTerminal.getInstId());
			limitCounters.getFilter().setEntityType(EntityNames.TERMINAL);
			limitCounters.search();
		} else if (tab.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCounters");
			cycleCounters.setFilter(null);
			cycleCounters.getFilter().setObjectId(_activeTerminal.getId().longValue());
			cycleCounters.getFilter().setInstId(_activeTerminal.getInstId());
			cycleCounters.getFilter().setEntityType(EntityNames.TERMINAL);
			cycleCounters.search();
		} else if (tab.equalsIgnoreCase("customerTab")) {
			MbCustomersDependent custBean = (MbCustomersDependent) ManagedBeanWrapper
					.getManagedBean("MbCustomersDependent");
			custBean.getCustomer(_activeTerminal.getCustomerId(), _activeTerminal.getCustomerType());
		} else if (tab.equalsIgnoreCase("standardsTab")) {
			MbIfConfig versions = (MbIfConfig) ManagedBeanWrapper.getManagedBean("MbIfConfig");
			versions.fullCleanBean();
			versions.setParamEntityType(EntityNames.TERMINAL);
			versions.setParamObjectId(_activeTerminal.getId().longValue());
			versions.setValuesEntityType(EntityNames.TERMINAL);
			versions.setValuesObjectId(_activeTerminal.getId().longValue());
			versions.setPageTitle(FacesUtils
					.getMessage("ru.bpc.sv2.ui.bundles.Net", "if_config_title_short", FacesUtils
							.getMessage("ru.bpc.sv2.ui.bundles.Acq", "terminal"), getDictUtils()
							.getAllArticlesDesc().get(_activeTerminal.getTerminalType()),
							_activeTerminal.getTerminalNumber()));
			versions.setBackLink(thisBackLink);
			versions.setHideVersions(false);
			// add bread crumbs, prevent menu selection
			versions.setDirectAccess(false);
			// versions.setPreviousPageName(pageName);
			versions.search();
		} else if (tab.equalsIgnoreCase("paymentsTab")) {
			MbObjectPurposes payments = (MbObjectPurposes) ManagedBeanWrapper
					.getManagedBean("MbObjectPurposes");
			payments.setPurposeFilter(null);
			payments.getPurposeFilter().setObjectId(_activeTerminal.getId().longValue());
			payments.getPurposeFilter().setEntityType("ENTTTRMN");
			payments.search();
		} else if (tab.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjects");
			schemeBean.setObjectId(_activeTerminal.getId().longValue());
			schemeBean.setInstId(_activeTerminal.getInstId());
			schemeBean.setDefaultEntityType(EntityNames.TERMINAL);
			schemeBean.search();
		} else if (tab.equalsIgnoreCase("TERMATMSTAB")) {
            MbTerminalATMs terminalATMs = (MbTerminalATMs)ManagedBeanWrapper.getManagedBean("MbTerminalATMs");
            terminalATMs.setSlaveMode(true);
            this.terminalATMs = terminalATMs;
            terminalATMs.clearFilter();
            terminalATMs.getFilter().setId(getActiveTerminal().getId());
            terminalATMs.setTemplate(false );
            terminalATMs.loadTerminalATM();
		} else if (tab.equalsIgnoreCase("DISPENSERSTAB")) {
			MbAtmDispensersSearch dispensers = (MbAtmDispensersSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmDispensersSearch");
			AtmDispenser dispenserFilter = new AtmDispenser();
			dispenserFilter.setTerminalId(getActiveTerminal().getId());
			dispensers.setDispenserFilter(dispenserFilter);
			dispensers.search();
		} else if (tab.equalsIgnoreCase("cashInTab")) {
			MbAtmCashIns cashInBean = (MbAtmCashIns) ManagedBeanWrapper
					.getManagedBean("MbAtmCashIns");
			cashInBean.clearFilter();
			cashInBean.getFilter().setTerminalId(_activeTerminal.getId());
			cashInBean.loadAtmCashIn();
		} else if (tab.equalsIgnoreCase("mccRedefinitionsTab")) {
			MbMccSelection mbMccSelection = ManagedBeanWrapper
					.getManagedBean(MbMccSelection.class);
			mbMccSelection.getFilter().setMccTemplateId(_activeTerminal.getMccTemplateId());
			mbMccSelection.search();
		} else if (tab.equalsIgnoreCase("statusLogsTab")) {
			MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper
					.getManagedBean("MbStatusLogs");
			statusLogs.clearFilter();
			statusLogs.getFilter().setObjectId(_activeTerminal.getId().longValue());

			// logs are written for card instances
			statusLogs.getFilter().setEntityType(EntityNames.TERMINAL);
			statusLogs.search();
		} else if (tab.equalsIgnoreCase("collectionsTab")) {
			MbAtmCollectionsSearch collectBean = (MbAtmCollectionsSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmCollectionsSearch");
			collectBean.clearFilter();
			collectBean.getCollectionFilter().setTerminalId(_activeTerminal.getId());
			collectBean.search();
		} else if (tab.equalsIgnoreCase("revenueSharingTab")) {
			MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
					.getManagedBean("MbRevenueSharingBottom");
			revenueSharingBean.clearFilter();
			revenueSharingBean.getFilter().setTerminalId(_activeTerminal.getId().longValue());
			revenueSharingBean.search();
		}  else if (tab.equalsIgnoreCase("suitesTab")) {
			MbFraudObjects fraudObjectsBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
			fraudObjectsBean.setObjectId(_activeTerminal.getId().longValue());
			fraudObjectsBean.setEntityType(EntityNames.TERMINAL);
			fraudObjectsBean.search();
		} else if (tab.equalsIgnoreCase("reportTab")){
			MbReportsBottom reportsBean = (MbReportsBottom) ManagedBeanWrapper
					.getManagedBean("MbReportsBottom");
			reportsBean.setEntityType(EntityNames.TERMINAL);
			reportsBean.setObjectType(_activeTerminal.getTerminalType());
			reportsBean.setObjectId(Long.valueOf(_activeTerminal.getId()));
			reportsBean.search();
		} else if (tab.equalsIgnoreCase("info")){
			MbEntityObjectInfoBottom infoBean = (MbEntityObjectInfoBottom) ManagedBeanWrapper
					.getManagedBean("MbEntityObjectInfoBottom");
			infoBean.setEntityType(EntityNames.TERMINAL);
			infoBean.setObjectType(_activeTerminal.getTerminalType().toString());
			infoBean.setObjectId(Long.valueOf(_activeTerminal.getId()));
			infoBean.search();
		}

		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
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

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public void clearFilter() {
		clearFilter(true);
	}

	/**
	 * Clears filter and searches only by isTemplate parameter
	 */
	public void clearFilter(boolean clearBeans) {
		filter = null;
		clearState(clearBeans);
		searching = false;
		clearSectionFilter();
		getParamMap().clear(); 
	}

	public void search() {
		clearState(false);
		searching = true;
	}

	public void clearState() {
		clearState(true);
	}

	public void clearState(boolean clearBeans) {
		_itemSelection.clearSelection();
		_activeTerminal = null;
		_terminalSource.flushCache();

		if (clearBeans) {
			clearBeansStates();
		}
	}

	public void clearBeansStates() {
		MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
				.getManagedBean("MbNotesSearch");
		notesSearch.clearState();
		notesSearch.setFilter(null);

		MbCustomersDependent custBean = (MbCustomersDependent) ManagedBeanWrapper
				.getManagedBean("MbCustomersDependent");
		custBean.clearFilter();

		MbDesKeysBottom keys = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysBottom");
		keys.fullCleanBean();

		MbAupSchemeObjects schemeBean = (MbAupSchemeObjects) ManagedBeanWrapper
				.getManagedBean("MbAupSchemeObjects");
		schemeBean.fullCleanBean();

		MbAtmDispensersSearch dispenserBean = (MbAtmDispensersSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmDispensersSearch");
		dispenserBean.clearFilter();

		MbLimitCounters limitCountersBean = (MbLimitCounters) ManagedBeanWrapper
				.getManagedBean("MbLimitCounters");
		limitCountersBean.clearFilter();

		MbCycleCounters cycleCountersBean = (MbCycleCounters) ManagedBeanWrapper
				.getManagedBean("MbCycleCounters");
		cycleCountersBean.clearFilter();

		MbObjectPurposes objectBean = (MbObjectPurposes) ManagedBeanWrapper
				.getManagedBean("MbObjectPurposes");
		objectBean.clearFilter();

		MbMccSelection mccSelectionBean = ManagedBeanWrapper
				.getManagedBean(MbMccSelection.class);
		mccSelectionBean.fullCleanBean();

		MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
				.getManagedBean("MbAccountsSearch");
		accsSearch.clearFilter();
		accsSearch.setSearching(false);

		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
		flexible.setSearching(false);
		flexible.setFilter(null);

		MbAddressesSearch addrSearch = (MbAddressesSearch) ManagedBeanWrapper
				.getManagedBean("MbAddressesSearch");
		addrSearch.fullCleanBean();

		MbContactSearch contSearch = (MbContactSearch) ManagedBeanWrapper
				.getManagedBean("MbContactSearch");
		contSearch.fullCleanBean();

		MbObjectAttributes attrs = (MbObjectAttributes) ManagedBeanWrapper
				.getManagedBean("MbObjectAttributes");
		attrs.fullCleanBean();

		MbStatusLogs statusLogs = (MbStatusLogs) ManagedBeanWrapper.getManagedBean("MbStatusLogs");
		statusLogs.clearFilter();

		MbTcpIpDevices tcpIpDevicesBean = (MbTcpIpDevices) ManagedBeanWrapper
				.getManagedBean("MbTcpIpDevices");
		tcpIpDevicesBean.clearFilter();

		MbTerminalATMs atmsBean = (MbTerminalATMs) ManagedBeanWrapper
				.getManagedBean("MbTerminalATMs");
		atmsBean.clearFilter();

		MbAtmCashIns atmCashInBean = (MbAtmCashIns) ManagedBeanWrapper
				.getManagedBean("MbAtmCashIns");
		atmCashInBean.clearFilter();

		MbIfConfig ifConfigBean = (MbIfConfig) ManagedBeanWrapper.getManagedBean("MbIfConfig");
		ifConfigBean.clearFilter();

		MbAtmCollectionsSearch collectBean = (MbAtmCollectionsSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmCollectionsSearch");
		collectBean.clearFilter();

		MbRevenueSharingBottom revenueSharingBean = (MbRevenueSharingBottom) ManagedBeanWrapper
				.getManagedBean("MbRevenueSharingBottom");
		revenueSharingBean.clearFilter();
		/*
		MbVouchersBatches mbVouchersBatches = (MbVouchersBatches) ManagedBeanWrapper
				.getManagedBean("MbVouchersBatches");
		mbVouchersBatches.clearFilter();
		*/
		MbFraudObjects suiteObjectBean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
		suiteObjectBean.fullCleanBean();
		
		MbReportsBottom reportBean = (MbReportsBottom) ManagedBeanWrapper.getManagedBean("MbReportsBottom");
		reportBean.clearFilter();
		
		MbEntityObjectInfoBottom info = (MbEntityObjectInfoBottom) ManagedBeanWrapper.getManagedBean("MbEntityObjectInfoBottom");
		reportBean.clearFilter();
	}

	private void setFilters() {
		getFilter();

		filters = new ArrayList<Filter>();

		// as both terminals and terminal templates are stored
		// in the same table we use IS_TEMPLATE = 0 to get terminals
		Filter paramFilter = new Filter();
		paramFilter.setElement("isTemplate");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue("0");
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (getFilter().getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getId());
			filters.add(paramFilter);
		}

		if (getFilter().getTerminalNumber() != null && !getFilter().getTerminalNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("TERMINAL_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getTerminalNumber().toUpperCase().replaceAll("[*]", "%").replaceAll(
					"[?]", "_"));
			filters.add(paramFilter);
		}

		if (getFilter().getInstId() != null) {
			paramFilter = new Filter("INST_ID", getFilter().getInstId());
			filters.add(paramFilter);
		}

		if (getFilter().getMerchantId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_ID");
			paramFilter.setValue(getFilter().getMerchantId());
			filters.add(paramFilter);
		}

		if (getFilter().getMerchantNumber() != null && !getFilter().getMerchantNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getMerchantNumber().toUpperCase().replaceAll("[*]", "%").replaceAll(
					"[?]", "_"));
			filters.add(paramFilter);
		}

		if (getFilter().getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getStatus());
			filters.add(paramFilter);
		}

		if (accountId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_ID");
			paramFilter.setValue(accountId);
			filters.add(paramFilter);

		}
		if (getFilter().getContractId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_ID");
			paramFilter.setValue(getFilter().getContractId());
			filters.add(paramFilter);
		}
		if (getFilter().getCustomerNumber() != null &&
				getFilter().getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("customerNumber");
			paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		
		if (getFilter().getCustomerId() != null ) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setValue(getFilter().getCustomerId());
			filters.add(paramFilter);
		}
		
		if (getFilter().getTerminalType() != null) {
			paramFilter = new Filter("TERMINAL_TYPE", getFilter().getTerminalType());
			filters.add(paramFilter);
		}
		
		getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMap().put("tab_name", "TERMINAL");
	}

	public Long getAccountId() {
		return accountId;
	}

	public void setAccountId(Long accountId) {
		this.accountId = accountId;
	}

	public Terminal getFilter() {
		if (Boolean.TRUE.equals(FacesUtils.getSessionMapValue("initFromContext"))) {
			initFilterFromContext();
			backLink = (String) FacesUtils.getSessionMapValue("backLink");
			search();
			FacesUtils.setSessionMapValue("initFromContext", null);
		}
		if (filter == null) {
			filter = new Terminal();
		}
		return filter;
	}

	public void setFilter(Terminal filterTerm) {
		this.filter = filterTerm;
	}

	public void changeTerminal(ValueChangeEvent event) {
		Integer id = (Integer) event.getNewValue();
		_activeTerminal = terminals.get(id);
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeTerminal.getId().toString());
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
			Terminal[] terminals = _acquringDao.getTerminals(userSessionId, params);
			if (terminals != null && terminals.length > 0) {
				_activeTerminal = terminals[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public String doBack() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public ArrayList<SelectItem> getTerminalItems() {
		if (terminals == null) {
			return new ArrayList<SelectItem>(0);
		}
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		// SelectItem[] items = new SelectItem[terminals.size()];
		for (Terminal terminal : terminals.values()) {
			items.add(new SelectItem(terminal.getId(), String.valueOf(terminal.getId())));
		}
		return items;
	}

	public void setTerminals(LinkedHashMap<Integer, Terminal> terminals) {
		this.terminals = terminals;
	}

	public void cancel() {
		_managingNew = false;
		resetBean();
	}

	public void resetBean() {
		_activeTerminal = new Terminal();
		if (terminals != null)
			terminals.clear();
	}

	// ===--- Getters for values from dictionary ---===//
	public ArrayList<SelectItem> getTerminalTypes() {
		if(terminalTypes == null){
			terminalTypes = getDictUtils().getArticles(DictNames.TERMINAL_TYPE, true, false);
		}
		return terminalTypes;
	}

	public ArrayList<SelectItem> getCardDataInputCaps() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_INPUT_CAP, true, false);
	}

	public ArrayList<SelectItem> getCrdhAuthCaps() {
		return getDictUtils().getArticles(DictNames.CRDH_AUTH_CAP, true, false);
	}

	public ArrayList<SelectItem> getCardCaptureCaps() {
		return getDictUtils().getArticles(DictNames.CARD_CAPTURE_CAP, true, false);
	}

	public ArrayList<SelectItem> getTermOperatingEnvs() {
		return getDictUtils().getArticles(DictNames.TERM_OPERATING_ENV, true, false);
	}

	public ArrayList<SelectItem> getCrdhDataPresents() {
		return getDictUtils().getArticles(DictNames.CRDH_DATA_PRESENT, true, false);
	}

	public ArrayList<SelectItem> getCardDataPresents() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_PRESENT, true, false);
	}

	public ArrayList<SelectItem> getCardDataInputModes() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_INPUT_MODE, true, false);
	}

	public ArrayList<SelectItem> getCrdhAuthMethods() {
		return getDictUtils().getArticles(DictNames.CRDH_AUTH_METHOD, true, false);
	}

	public ArrayList<SelectItem> getCrdhAuthEntities() {
		return getDictUtils().getArticles(DictNames.CRDH_AUTH_ENTITY, true, false);
	}

	public ArrayList<SelectItem> getCardDataOutputCaps() {
		return getDictUtils().getArticles(DictNames.CARD_DATA_OUTPUT_CAP, true, false);
	}

	public ArrayList<SelectItem> getTermDataOutputCaps() {
		return getDictUtils().getArticles(DictNames.TERM_DATA_OUTPUT_CAP, true, false);
	}

	public ArrayList<SelectItem> getPinCaptureCaps() {
		return getDictUtils().getArticles(DictNames.PIN_CAPTURE_CAP, true, false);
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.TERMINAL_STATUS, true, false);
	}

	// ===--- Getters for values from dictionary (END) ---===//

	public void reload() {
		try {
			List<Terminal> selectedTerminals = _itemSelection.getMultiSelection();
			if (selectedTerminals.size() == 0) {
				return;
			}

			String feLocation = settingsDao.getParameterValueV(userSessionId,
					SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM, null);
			if (feLocation == null || feLocation.trim().length() == 0) {
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
						"sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
				FacesUtils.addErrorExceptionMessage(msg);
				return;
			}
			Double wsPort = settingsDao.getParameterValueN(userSessionId,
					SettingsConstants.UPDATE_CACHE_WS_PORT, LevelNames.SYSTEM, null);
			if (wsPort == null) {
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
						"sys_param_empty", SettingsConstants.UPDATE_CACHE_WS_PORT);
				FacesUtils.addErrorExceptionMessage(msg);
			}
			feLocation = feLocation + ":" + wsPort.intValue();

			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType.getEntityObj();

			for (Terminal terminal : selectedTerminals) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(terminal.getId().toString());
				entityObj.setObjSeq(terminal.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(EntityNames.TERMINAL);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider) port;
			bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
			bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
			bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);
			
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

			for (int i = 0; i < selectedTerminals.size(); i++) {
				Terminal terminal = selectedTerminals.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				terminal.setFerrNo(objStatusType.getFerrno());
			}

			reloadResult = selectedTerminals;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String toApplications() {
		try {
/*
			MbApplicationsSearch appSearch = (MbApplicationsSearch) ManagedBeanWrapper
					.getManagedBean("MbApplicationsSearch");
			Application filterApp = new Application();
			filterApp.setTerminalNumber(_activeTerminal.getTerminalNumber());
			filterApp.setInstId(_activeTerminal.getInstId());
			appSearch.setFilter(filterApp);
			appSearch.search();
			appSearch.setBackLink(thisBackLink);
			
			appSearch.clearDisabledFields();
			appSearch.setDisabledTerminalNumber(true);
*/
			
			HashMap<String,Object> queueFilter = new HashMap<String,Object>();
			
			queueFilter.put("terminalType", getFilter().getTerminalType());
			queueFilter.put("terminalNumber", getFilter().getTerminalNumber());
			queueFilter.put("merchantNumber", getFilter().getMerchantNumber());
			queueFilter.put("status", getFilter().getStatus());
			queueFilter.put("customerNumber", getFilter().getCustomerNumber());
			queueFilter.put("instId", filter.getInstId());
			
			addFilterToQueue("MbTerminal", queueFilter);
			
			queueFilter.clear();
			queueFilter.put("terminalNumber", _activeTerminal.getTerminalNumber());
			queueFilter.put("instId", _activeTerminal.getInstId());
			queueFilter.put("objectId", _activeTerminal.getId().longValue());
			queueFilter.put("entityType", EntityNames.TERMINAL);
			queueFilter.put("backLink", thisBackLink);
			if (getFilter().getMerchantNumber() != null && !getFilter().getMerchantNumber().equals("")) {
				queueFilter.put("merchantNumber", getFilter().getMerchantNumber());
			}
			
			addFilterToQueue("MbApplicationsSearch", queueFilter);
			
			Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			mbMenu.externalSelect("applications|list_acq_apps");
			
			return "acquiring|applications|list_apps";
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return "";
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		sessionBean.setTabName(tabName);

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
		
		if (tabName.equalsIgnoreCase("additionalTab")) {
			// get flexible data for this terminal
			MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			flexible.setTabName(tabName);
			flexible.setParentSectionId(getSectionId());
			flexible.setTableState(getSateFromDB(flexible.getComponentId()));
		} else if (tabName.equalsIgnoreCase("keysTab")) {
			MbDesKeysBottom bean = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("accountsTab")) {
			// get accounts for this terminal
			MbAccountsSearch accsSearch = (MbAccountsSearch) ManagedBeanWrapper
					.getManagedBean("MbAccountsSearch");
			accsSearch.setTabName(tabName);
			accsSearch.setParentSectionId(getSectionId());
			accsSearch.setTableState(getSateFromDB(accsSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("addressesTab")) {
			// get addresses for this terminal
			MbAddressesSearch addr = (MbAddressesSearch) ManagedBeanWrapper
					.getManagedBean("MbAddressesSearch");
			addr.setTabName(tabName);
			addr.setParentSectionId(getSectionId());
			addr.setTableState(getSateFromDB(addr.getComponentId()));
		} else if (tabName.equalsIgnoreCase("contactsTab")) {
			// get contacts for this terminal
			MbContactSearch cont = (MbContactSearch) ManagedBeanWrapper
					.getManagedBean("MbContactSearch");
			cont.setTabName(tabName);
			cont.setParentSectionId(getSectionId());
			cont.setTableState(getSateFromDB(cont.getComponentId()));
			
			MbContactDataSearch contData = (MbContactDataSearch) ManagedBeanWrapper
					.getManagedBean("MbContactDataSearch");
			contData.setTabName(tabName);
			contData.setParentSectionId(getSectionId());
			contData.setTableState(getSateFromDB(contData.getComponentId()));
		} else if (tabName.equalsIgnoreCase("attrsTab")) {
			MbAttributeValues bean = (MbAttributeValues) ManagedBeanWrapper
					.getManagedBean("MbAttributeValues");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("notesTab")) {
			MbNotesSearch notesSearch = (MbNotesSearch) ManagedBeanWrapper
					.getManagedBean("MbNotesSearch");
			notesSearch.setTabName(tabName);
			notesSearch.setParentSectionId(getSectionId());
			notesSearch.setTableState(getSateFromDB(notesSearch.getComponentId()));
		} else if (tabName.equalsIgnoreCase("limitCountersTab")) {
			MbLimitCounters limitCounters = (MbLimitCounters) ManagedBeanWrapper
					.getManagedBean("MbLimitCounters");
			limitCounters.setTabName(tabName);
			limitCounters.setParentSectionId(getSectionId());
			limitCounters.setTableState(getSateFromDB(limitCounters.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cycleCountersTab")) {
			MbCycleCounters cycleCounters = (MbCycleCounters) ManagedBeanWrapper
					.getManagedBean("MbCycleCounters");
			cycleCounters.setTabName(tabName);
			cycleCounters.setParentSectionId(getSectionId());
			cycleCounters.setTableState(getSateFromDB(cycleCounters.getComponentId()));
		} else if (tabName.equalsIgnoreCase("paymentsTab")) {
			MbObjectPurposeParameterValues bean = (MbObjectPurposeParameterValues) ManagedBeanWrapper
					.getManagedBean("MbObjectPurposeParameterValues");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("SCHEMESTAB")) {
			MbAupSchemeObjects bean = (MbAupSchemeObjects) ManagedBeanWrapper
					.getManagedBean("MbAupSchemeObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("DISPENSERSTAB")) {
			MbAtmDispensersSearch bean = (MbAtmDispensersSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmDispensersSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("cashInTab")) {
			MbAtmCashIns bean = (MbAtmCashIns) ManagedBeanWrapper
					.getManagedBean("MbAtmCashIns");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("statusLogsTab")) {
			MbStatusLogs bean = (MbStatusLogs) ManagedBeanWrapper
					.getManagedBean("MbStatusLogs");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("collectionsTab")) {
			MbAtmCollectionsSearch bean = (MbAtmCollectionsSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmCollectionsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("revenueSharingTab")) {
			MbRevenueSharingBottom bean = (MbRevenueSharingBottom) ManagedBeanWrapper
					.getManagedBean("MbRevenueSharingBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} /*else if (tabName.equalsIgnoreCase("vouchersBatchesTab")) {
			MbVouchersBatches bean = (MbVouchersBatches) ManagedBeanWrapper
					.getManagedBean("MbVouchersBatches");
			bean.keepTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} */else if (tabName.equalsIgnoreCase("mccRedefinitionsTab")) {
			MbMccSelection bean = ManagedBeanWrapper
					.getManagedBean(MbMccSelection.class);
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("suitesTab")) {
			MbFraudObjects bean = (MbFraudObjects) ManagedBeanWrapper.getManagedBean("MbFraudObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String toOperations() {
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		
		queueFilter.put("terminalType", getFilter().getTerminalType());
		queueFilter.put("terminalNumber", getFilter().getTerminalNumber());
		queueFilter.put("merchantNumber", getFilter().getMerchantNumber());
		queueFilter.put("status", getFilter().getStatus());
		queueFilter.put("customerNumber", getFilter().getCustomerNumber());
		queueFilter.put("instId", filter.getInstId());
		
		addFilterToQueue("MbMerchant", queueFilter);
		
		queueFilter.clear();
		queueFilter.put("terminalNumber", _activeTerminal.getTerminalNumber());
		queueFilter.put("merchantNumber", _activeTerminal.getMerchantNumber());
		
		Calendar hostDateFrom = GregorianCalendar.getInstance();
		hostDateFrom.set(Calendar.DAY_OF_MONTH, hostDateFrom.get(Calendar.DAY_OF_MONTH) - 60);
		
		queueFilter.put("hostDateFrom", hostDateFrom.getTime());
		queueFilter.put("instId", _activeTerminal.getInstId());
		queueFilter.put("operType", ModuleNames.ACQUIRING);
		queueFilter.put("backLink", thisBackLink);
		
		addFilterToQueue("MbOperations", queueFilter);
		return "acquiring|operations";
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Terminal();
				setFilterForm(filterRec);
				if (searchAutomatically)
					search();
			}

			sectionFilterModeEdit = true;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("id") != null) {
			filter.setId(Integer.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("terminalNumber") != null) {
			filter.setTerminalNumber(filterRec.get("terminalNumber"));
		}
		if (filterRec.get("merchantId") != null) {
			filter.setMerchantId(Integer.valueOf(filterRec.get("merchantId")));
		}
		if (filterRec.get("merchantNumber") != null) {
			filter.setMerchantNumber(filterRec.get("merchantNumber"));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		if (filterRec.get("customerNumber") != null) {
			filter.setCustomerNumber(filterRec.get("customerNumber"));
		}
		if (filterRec.get("custInfo") != null) {
			filter.setCustInfo(filterRec.get("custInfo"));
		}
		if (filterRec.get("terminalType") != null) {
			filter.setTerminalType(filterRec.get("terminalType"));
		}
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.parseInt(filterRec.get("instId")));
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {

		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getTerminalNumber() != null && filter.getTerminalNumber().trim().length() > 0) {
			filterRec.put("terminalNumber", filter.getTerminalNumber());
		}
		if (filter.getMerchantId() != null) {
			filterRec.put("merchantId", filter.getMerchantId().toString());
		}
		if (filter.getMerchantNumber() != null && filter.getMerchantNumber().trim().length() > 0) {
			filterRec.put("merchantNumber", filter.getMerchantNumber());
		}
		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			filterRec.put("status", filter.getStatus());
		}
		if (filter.getCustomerNumber() != null && filter.getCustomerNumber().trim().length() > 0) {
			filterRec.put("customerNumber", filter.getCustomerNumber());
		}
		if (filter.getCustInfo() != null && filter.getCustInfo().trim().length() > 0) {
			filterRec.put("custInfo", filter.getCustInfo());
		}
		if (filter.getTerminalType() != null && filter.getTerminalType().trim().length() > 0) {
			filterRec.put("terminalType", filter.getTerminalType());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_TERMINAL;
	}

	public String configureDevice() {
		if (_activeTerminal == null || _activeTerminal.getDeviceId() == null) {
			return "";
		}

		MbTcpIpDevices devices = (MbTcpIpDevices) ManagedBeanWrapper
				.getManagedBean("MbTcpIpDevices");
		String pageTitle = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "if_config_title",
				FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acq", "terminal"), getDictUtils()
						.getAllArticlesDesc().get(_activeTerminal.getTerminalType()),
				_activeTerminal.getTerminalNumber(), FacesUtils.getMessage(
						"ru.bpc.sv2.ui.bundles.Cmn", "device"), _activeTerminal.getDeviceId().toString(),
				devices.getActiveDevice().getCaption());

		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		
		queueFilter.put("backLink", thisBackLink);
		queueFilter.put("valuesObjectId", _activeTerminal.getDeviceId().longValue());
		queueFilter.put("valuesEntityType", EntityNames.COM_DEVICE);
		queueFilter.put("paramObjectId", _activeTerminal.getId().longValue());
		queueFilter.put("paramEntityType", EntityNames.TERMINAL);
		queueFilter.put("pageTitle", pageTitle);
		queueFilter.put("hideVersions", "true");
		queueFilter.put("directAccess", "false");
		
		addFilterToQueue("MbIfConfig", queueFilter);

		return "ifConfig";
	}

	public List<Terminal> getSelectedItems() {
		return _itemSelection.getMultiSelection();
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public String getTabComponentId() {
		return COMPONENT_TAB_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public boolean isAtm() {
		if (_activeTerminal != null) {
			return ATM_TERMINAL.equals(_activeTerminal.getTerminalType());
		}
		return false;
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		if (getFilter().getInstId() != null) {
			custBean.setBlockInstId(true);
			custBean.setDefaultInstId(getFilter().getInstId());
		} else {
			custBean.setBlockInstId(false);
		}
	}

	public void selectCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			getFilter().setCustomerNumber(selected.getCustomerNumber());
			getFilter().setCustomerId(selected.getId());
			getFilter().setCustInfo(selected.getName());
			getFilter().setInstId(custBean.getFilter().getInstId());
		}
	}

	/**
	 * Initializes bean's filter if bean has been accessed by context menu.
	 */
	private void initFilterFromContext() {
		filter = new Terminal();
		if (FacesUtils.getSessionMapValue("customerNumber") != null) {
			filter.setCustomerNumber((String) FacesUtils.getSessionMapValue("customerNumber"));
			filter.setCustInfo((String) FacesUtils.getSessionMapValue("customerNumber"));
			FacesUtils.setSessionMapValue("customerNumber", null);
		}
		if (FacesUtils.getSessionMapValue("instId") != null) {
			filter.setInstId((Integer) FacesUtils.getSessionMapValue("instId"));
			FacesUtils.setSessionMapValue("instId", null);
		}
		if (FacesUtils.getSessionMapValue("terminalNumber") != null) {
			filter.setTerminalNumber((String) FacesUtils.getSessionMapValue("terminalNumber"));
			FacesUtils.setSessionMapValue("terminalNumber", null);
		}
		if (FacesUtils.getSessionMapValue("merchantNumber") != null) {
			filter.setMerchantNumber((String) FacesUtils.getSessionMapValue("merchantNumber"));
			FacesUtils.setSessionMapValue("merchantNumber", null);
		}
	}

	public String back() {
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		mbMenu.externalSelect(backLink);
		return backLink;
	}

	public boolean isShowBackBtn() {
		return backLink == null ? false : (backLink.trim().length() > 0 ? true : false);
	}

	public List<Terminal> getReloadResult() {
		return reloadResult;
	}

	public void setReloadResult(List<Terminal> reloadResult) {
		this.reloadResult = reloadResult;
	}

	public void displayCustInfo() {

		if (getFilter().getCustInfo() == null || "".equals(getFilter().getCustInfo())) {
			getFilter().setCustomerNumber(null);
			getFilter().setCustomerId(null);
			return;
		}

		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getFilter().getCustInfo());
		if (m.find() || getFilter().getInstId() == null) {
			getFilter().setCustomerNumber(getFilter().getCustInfo());
			return;
		}

		// search and redisplay
		Filter[] filters = new Filter[3];
		filters[0] = new Filter("LANG", curLang);
		filters[1] = new Filter("INST_ID", getFilter().getInstId());
		filters[2] = new Filter("CUSTOMER_NUMBER", getFilter().getCustInfo());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] cust = _productsDao.getCombinedCustomersProc(userSessionId, params,
					"CUSTOMER");
			if (cust != null && cust.length > 0) {
				getFilter().setCustInfo(cust[0].getName());
				getFilter().setCustomerNumber(cust[0].getCustomerNumber());
				getFilter().setCustomerId(cust[0].getId());
			} else {
				getFilter().setCustomerNumber(getFilter().getCustInfo());
				getFilter().setCustomerId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void reloadCache() {
		try {
			if (_activeTerminal != null) {
				TerminalParametersCache.getInstance().reloadTerminalParams(
						_activeTerminal.getTerminalNumber());
			}
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public Map<String, Boolean> getRenderTabsMap() {
		if (renderTabsMap == null) {
			renderTabsMap = createTabsMap();
		}
		return renderTabsMap;
	}

	private HashMap<String, Boolean> createTabsMap() {
		HashMap<String, Boolean> map = new HashMap<String, Boolean>();
		for (String str : getSelectedTabs()) {
			map.put(str, true);
		}
		return map;
	}

	public void saveTabsMap() {
		getRenderTabsMap().clear();
		String state = null;
		if (selectedTabs != null) {
			for (String tab : selectedTabs) {
				renderTabsMap.put(tab, true);
				if (state == null) {
					state = tab;
				} else {
					state += ";" + tab;
				}
			}
		}
		setShowAllTabs(false);
		setTabsState(state);
		saveTabsStateDB();
	}

	public void clearTabsMap() {
		deleteTabsStateDB();
		setShowAllTabs(true);
		selectedTabs = null;
		renderTabsMap = null;
	}

	private List<String> selectedTabs;

	private void setTabsList() {
		selectedTabs = new ArrayList<String>();
		if (isShowAllTabs()) {
			selectedTabs.add("additionalTab");
			selectedTabs.add("connectivityTab");
			selectedTabs.add("keysTab");
			selectedTabs.add("accountsTab");
			selectedTabs.add("addressesTab");
			selectedTabs.add("contactsTab");
			selectedTabs.add("customerTab");
			selectedTabs.add("attrsTab");
			selectedTabs.add("notesTab");
			selectedTabs.add("limitCountersTab");
			selectedTabs.add("cycleCountersTab");
			selectedTabs.add("standardsTab");
			selectedTabs.add("paymentsTab");
			selectedTabs.add("schemesTab");
			selectedTabs.add("termATMsTab");
			selectedTabs.add("dispensersTab");
			selectedTabs.add("cashInTab");
			selectedTabs.add("statusLogsTab");
			selectedTabs.add("collectionsTab");
			selectedTabs.add("revenueSharingTab");
			selectedTabs.add("mccSelectionTab");
			selectedTabs.add("vouchersBatchesTab");
		} else {
			String state = getTabsState();
			if (state != null) {
				for (String str : state.split(";")) {
					selectedTabs.add(str);
				}
			}
		}
	}

	public List<String> getSelectedTabs() {
		if (selectedTabs == null) {
			setTabsList();
		}
		return selectedTabs;
	}

	public void setSelectedTabs(List<String> selectedItems) {
		this.selectedTabs = selectedItems;
	}

	public boolean isImprinter(){
		boolean result = false;
		if (_activeTerminal != null){
			result = IMPRINTER.equals(_activeTerminal.getTerminalType());
		}
		return result;
	}
	
	private void loadTerminalDevice() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", curLang);
		filters[1] = new Filter("id", _activeTerminal.getDeviceId());
		
		SelectionParams params = new SelectionParams(filters);
		params.setPrivilege(CmnPrivConstants.VIEW_TAB_COMMUNIC_DEVICE);
		MbTcpIpDevices tcpIpDevicesBean = (MbTcpIpDevices) ManagedBeanWrapper
				.getManagedBean("MbTcpIpDevices");
		try {
			TcpIpDevice[] devices = _acquringDao.getTerminalDevices(userSessionId, params);
			if (devices.length > 0) {
				tcpIpDevicesBean.setActiveDevice(devices[0]);
			} else {
				tcpIpDevicesBean.setActiveDevice(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private Map<Long, String> mccSelectionTemplatesMap;
	
	public Map<Long, String> getMccSelectionTemplatesMap(){
		if (mccSelectionTemplatesMap == null){
			List<SelectItem> selectionTemplates = getDictUtils().getLov(LovConstants.MCC_SELECTION_TEMPLATE);
			mccSelectionTemplatesMap = new HashMap<Long, String>();
			for (SelectItem item : selectionTemplates){
				mccSelectionTemplatesMap.put(new Long(item.getValue().toString()), item.getLabel());
			}
		}
		return mccSelectionTemplatesMap;
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		
		if (_activeTerminal != null) {
			if (EntityNames.TERMINAL.equals(ctxItemEntityType)) {
				 map.put("id", _activeTerminal.getId());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return !ctxItemEntityType.equals(EntityNames.TERMINAL);
	}
	
	public void setupWizard(){
		classLogger.trace("setupWizard...");
		CommonWizardStepInfo step = new CommonWizardStepInfo();
		step.setOrder(0);
		step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
		step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr","select_oper_type"));
		List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
		stepsList.add(step);
		Map<String, Object> context = new HashMap<String, Object>();
		context.put(MbCommonWizard.STEPS, stepsList);
		context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.TERMINAL);
		context.put(MbOperTypeSelectionStep.OBJECT_ID, _activeTerminal.getId().longValue());
		context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ACQ_PARTICIPANT);
		MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
		wizard.init(context);
	}
	
	public void updateTerminalData(){
		classLogger.trace("updateTerminalData...");
	}

	public HashMap<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(HashMap<String, Object> paramMap) {
		this.paramMap = paramMap;
	}
	
	public boolean isUseHsm(){
		if (useHsm == null) {
			Double value = settingsDao.getParameterValueN(null,
				SettingsConstants.USE_HSM, LevelNames.SYSTEM, null);
			useHsm = (value == 1);
		}
		return useHsm;
	}

    public void onSortablePreRenderTable() {
        onSortablePreRenderTable(_terminalSource);
    }
}

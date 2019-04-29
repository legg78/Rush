package ru.bpc.sv2.ui.atm;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv.pctlpeerncr.PCtlPeerNCR;
import ru.bpc.sv.pctlpeerncr.PCtlPeerNCR_Service;
import ru.bpc.sv.pctlpeerwincorndc.PCtlPeerWincorNDC;
import ru.bpc.sv.pctlpeerwincorndc.PCtlPeerWincorNDC_Service;
import ru.bpc.sv2.atm.AtmDispenser;
import ru.bpc.sv2.atm.MonitoredAtm;
import ru.bpc.sv2.constants.ArrayConstants;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AtmDao;
import ru.bpc.sv2.security.SecPrivConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.acquiring.MbTerminal;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.security.MbDesKeys;
import ru.bpc.sv2.ui.services.MbPCtlPeerNcrWS;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.Holder;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbAtmMonitoring")
public class MbAtmMonitoring extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ATM");

	private AtmDao atmDao = new AtmDao();

	private MonitoredAtm filter;
	private String filterAtmDevice;
	private String filterSelectedDeviceStatus;

	private MonitoredAtm activeItem;

	private final DaoDataModel<MonitoredAtm> dataModel;
	private final TableRowSelection<MonitoredAtm> tableRowSelection;

	private MonitoredAtm editingItem;
	private List<SelectItem> cachedInstitutions;
	private List<SelectItem> cachedAtmTypes;
    private List<SelectItem> atmGroups;
	private MbAtmMonitoringSess sessionBean;
	private Menu mbMenu;

	private String tabName;
	private String entityTab;

	public MbAtmMonitoring() {
		pageLink = "atm|monitoring";
		thisBackLink = "atm|monitoring";
		sessionBean = (MbAtmMonitoringSess) ManagedBeanWrapper.getManagedBean("MbAtmMonitoringSess");
		mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		dataModel = new DaoDataModel<MonitoredAtm>() {
			@Override
			protected MonitoredAtm[] loadDaoData(SelectionParams params) {
				MonitoredAtm[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = atmDao
								.getMonitoredAtms(userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
						setDataSize(0);
					}
				} else {
					result = new MonitoredAtm[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = atmDao.getMonitoredAtmsCount(userSessionId,
								params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(pageLink);
		tableRowSelection = new TableRowSelection<MonitoredAtm>(null, dataModel);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;
		} else {
			restoreBean();
		}
		tabName = "detailsTab";
	}

	private void restoreBean(){
		filter = sessionBean.getFilter();
		activeItem = sessionBean.getActiveItem();
		SimpleSelection simpleSelection = sessionBean.getItemSelection();
		tableRowSelection.setWrappedSelection(simpleSelection);
		pageNumber = sessionBean.getPageNumber();
		rowsNum = sessionBean.getRowsNum();
		searching = sessionBean.isSearching();
		filterAtmDevice = sessionBean.getFilterAtmDevice();
	}
	
	private void storeBean(){
		sessionBean.setFilter(filter);
		sessionBean.setActiveItem(activeItem);
		sessionBean.setItemSelection(tableRowSelection.getWrappedSelection());
		sessionBean.setPageNumber(pageNumber);
		sessionBean.setRowsNum(rowsNum);
		sessionBean.setSearching(searching);
		sessionBean.setFilterAtmDevice(filterAtmDevice);
	}
	
	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getTerminalNumber()!= null && !"".equals(filter.getTerminalNumber())) {
			f = new Filter();
			f.setElement("terminalNumber");
			f.setCondition("=");
			f.setValue(filter.getTerminalNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			
			if (((String)f.getValue()).indexOf("%") != -1 || filter.getTerminalNumber().indexOf("?") != -1) {
				f.setCondition("like");
			}
			filters.add(f);
		}

		if (filter.getInstId() != null) {
			f = new Filter();
			f.setValue(filter.getInstId());
			f.setElement("instId");
			filters.add(f);
		}

		if (filter.getAgentId() != null) {
			f = new Filter();
			f.setValue(filter.getAgentId());
			f.setElement("agentId");
			filters.add(f);
		}

        if(filter.getGroupId() != null) {
            f = new Filter();
            f.setValue(filter.getGroupId());
            f.setElement("groupId");
            filters.add(f);
        }

		if (filter.getPlacementType() != null) {
			f = new Filter();
			f.setValue(filter.getPlacementType());
			f.setElement("placementType");
			filters.add(f);
		}

		if (filter.getAtmType() != null) {
			f = new Filter();
			f.setValue(filter.getAtmType());
			f.setElement("atmType");
			filters.add(f);
		}

		if (filter.getSerialNumber() != null && !"".equals(filter.getSerialNumber())) {
			f = new Filter();
			f.setValue(filter.getSerialNumber());
			f.setElement("serialNumber");
			filters.add(f);
		}

		if (filter.getServiceStatus() != null) {
			f = new Filter();
			f.setValue(filter.getServiceStatus());
			f.setElement("serviceStatus");
			filters.add(f);
		}

		if (filterAtmDevice != null && !"".equals(filterAtmDevice)) {
			f = new Filter();

			if ("HCDT0001".equals(filterAtmDevice)) {
				f.setElement("todClockStatus");
			} else if ("HCDT0004".equals(filterAtmDevice)) {
				f.setElement("cardReaderStatus");
			} else if ("HCDT0008".equals(filterAtmDevice)) {
				f.setElement("jrnlStatus");
			} else if ("HCDT0011".equals(filterAtmDevice)) {
				f.setElement("nightSafeStatus");
			} else if ("HCDT0012".equals(filterAtmDevice)) {
				f.setElement("encryptorStatus");
			} else if ("HCDT0013".equals(filterAtmDevice)) {
				f.setElement("cameraStatus");
			} else if ("HCDT0025".equals(filterAtmDevice)) {
				f.setElement("coinDispStatus");
			} else if ("HCDT0028".equals(filterAtmDevice)) {
				f.setElement("envelopeDispStatus");
			} else if ("HCDT0031".equals(filterAtmDevice)) {
				f.setElement("barcodeReaderStatus");
			} else if ("HCDT0032".equals(filterAtmDevice)) {
				f.setElement("chequeModuleStatus");
			} else if ("HCDT0033".equals(filterAtmDevice)) {
				f.setElement("bunchAcptStatus");
			}
			f.setValue(filterSelectedDeviceStatus);
			filters.add(f);
		}
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}

	public void clearBeansStates() {
		MbAtmDispensersSearch dispenserBean = (MbAtmDispensersSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmDispensersSearch");
		dispenserBean.clearFilter();

		MbAtmCollectionsSearch collectBean = (MbAtmCollectionsSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmCollectionsSearch");
		collectBean.clearFilter();
		
		MbAtmCashIns atmCashInBean = (MbAtmCashIns) ManagedBeanWrapper
				.getManagedBean("MbAtmCashIns");
		atmCashInBean.clearFilter();
		
		MbCapturedCard mbCapturedCard = (MbCapturedCard) ManagedBeanWrapper
				.getManagedBean("MbCapturedCard");
		mbCapturedCard.clearFilter();
		
		MbDesKeys mbDesKeys = (MbDesKeys) ManagedBeanWrapper
				.getManagedBean("MbDesKeys");
		mbDesKeys.clearFilter();
		
		MbAtmScenario mbAtmScenario = (MbAtmScenario) ManagedBeanWrapper
				.getManagedBean("MbAtmScenario");
		mbAtmScenario.clearFilter();
		
		MbAdminOperation mbAdminOperation = (MbAdminOperation) ManagedBeanWrapper
				.getManagedBean("MbAdminOperation");
		mbAdminOperation.clearFilter();
		
		MbStatusMessage mbStatusMessage = (MbStatusMessage) ManagedBeanWrapper
				.getManagedBean("MbStatusMessage");
		mbStatusMessage.clearFilter();

        MbAtmFinanceOperationsBottom mbAtmFinanceOperationsBottom = (MbAtmFinanceOperationsBottom) ManagedBeanWrapper
                .getManagedBean("MbAtmFinanceOperationsBottom");
        mbAtmFinanceOperationsBottom.clearFilter();

		MbFraudOperation mbFraudOperation = (MbFraudOperation) ManagedBeanWrapper
				.getManagedBean("MbFraudOperation");
		mbFraudOperation.clearFilter();

        MbAtmGroups mbAtmGroups = (MbAtmGroups) ManagedBeanWrapper
                .getManagedBean("MbAtmGroups");
        mbAtmGroups.clearFilter();
        
        
        MbUnsolicitedSearch unsolicited = (MbUnsolicitedSearch) ManagedBeanWrapper
                .getManagedBean("MbUnsolicitedSearch");
        unsolicited.clearFilter();
		
		
	}

	public void clearFilter() {
		filter = null;
		filterAtmDevice = null;
		filterSelectedDeviceStatus = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public void createNewAtmUiTerminalVw() {
		editingItem = new MonitoredAtm();
		editingItem.setLang(userLang);
		curMode = AbstractBean.NEW_MODE;
	}

	public void editActiveAtmUiTerminalVw() {
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}

	public void resetEditingAtmUiTerminalVw() {
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (MonitoredAtm) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			setBeansState();
		}
	}

	private void setBeansState() {
		MbAtmDispensersSearch dispensers = (MbAtmDispensersSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmDispensersSearch");
		AtmDispenser dispenserFilter = new AtmDispenser();
		dispenserFilter.setTerminalId(getActiveItem().getId());
		dispensers.setDispenserFilter(dispenserFilter);
		dispensers.search();
		
		MbAtmCollectionsSearch collectBean = (MbAtmCollectionsSearch) ManagedBeanWrapper
				.getManagedBean("MbAtmCollectionsSearch");
		collectBean.clearFilter();
		collectBean.getCollectionFilter().setTerminalId(getActiveItem().getId());
		collectBean.search();
		
		MbAtmCashIns cashInBean = (MbAtmCashIns) ManagedBeanWrapper
				.getManagedBean("MbAtmCashIns");
		cashInBean.clearFilter();
		cashInBean.getFilter().setTerminalId(getActiveItem().getId());
		cashInBean.search();
		
		MbCapturedCard mbCapturedCard = (MbCapturedCard) ManagedBeanWrapper
				.getManagedBean("MbCapturedCard");
		mbCapturedCard.clearFilter();
		mbCapturedCard.getFilter().setTerminalId(getActiveItem().getId());
		mbCapturedCard.search();
		
		MbDesKeys mbDesKeys = (MbDesKeys) ManagedBeanWrapper
				.getManagedBean("MbDesKeys");
		mbDesKeys.clearFilter();
		mbDesKeys.getFilter().setEntityType(EntityNames.TERMINAL);
		mbDesKeys.getFilter().setObjectId(new Long(getActiveItem().getId()));
		mbDesKeys.setPrivilege(SecPrivConstants.VIEW_TAB_DES_KEY);
		mbDesKeys.search();
		
		MbAtmScenario mbAtmScenario = (MbAtmScenario) ManagedBeanWrapper
				.getManagedBean("MbAtmScenario");
				
		mbAtmScenario.clearFilter();
		mbAtmScenario.getFilter().setId(getActiveItem().getScenarioId());
		mbAtmScenario.search();
		
		MbAdminOperation mbAdminOperation = (MbAdminOperation) ManagedBeanWrapper
				.getManagedBean("MbAdminOperation");
		mbAdminOperation.clearFilter();
		mbAdminOperation.getFilter().setTerminalId(getActiveItem().getId());
		mbAdminOperation.search();
		
		GregorianCalendar cal = new GregorianCalendar();
		cal.setTime(new Date());
		cal.set(GregorianCalendar.HOUR_OF_DAY, 0);
		cal.set(GregorianCalendar.MINUTE, 0);
		cal.set(GregorianCalendar.SECOND, 0);
		cal.set(GregorianCalendar.MILLISECOND, 0);
		Date thisDay = cal.getTime();
		
		MbStatusMessage mbStatusMessage = (MbStatusMessage) ManagedBeanWrapper
				.getManagedBean("MbStatusMessage");
		mbStatusMessage.clearFilter();
		mbStatusMessage.setFilterStartDate(thisDay);
		mbStatusMessage.getFilter().setTerminalId(getActiveItem().getId());
		mbStatusMessage.search();

        MbAtmFinanceOperationsBottom mbAtmFinanceOperationsBottom = (MbAtmFinanceOperationsBottom) ManagedBeanWrapper
                .getManagedBean("MbAtmFinanceOperationsBottom");
        mbAtmFinanceOperationsBottom.clearFilter();
        mbAtmFinanceOperationsBottom.setOperDateFrom(thisDay);
        mbAtmFinanceOperationsBottom.getFilter().setTerminalId(getActiveItem().getId());
        mbAtmFinanceOperationsBottom.search();

		MbFraudOperation mbFraudOperation = (MbFraudOperation) ManagedBeanWrapper
				.getManagedBean("MbFraudOperation");
		mbFraudOperation.clearFilter();
		mbFraudOperation.getFilter().setTerminalId(getActiveItem().getId().longValue());
		mbFraudOperation.search();

        MbAtmGroups mbAtmGroups = (MbAtmGroups) ManagedBeanWrapper
                .getManagedBean("MbAtmGroups");
        mbAtmGroups.clearFilter();
//        mbAtmGroups.getFilter().setAtmId(getActiveItem().getId());
//        mbAtmGroups.getFilter().setInstId(getActiveItem().getInstId());
        mbAtmGroups.setAtm(getActiveItem());
        mbAtmGroups.search();
        
        MbUnsolicitedSearch unsolicited = (MbUnsolicitedSearch) ManagedBeanWrapper
                .getManagedBean("MbUnsolicitedSearch");
        unsolicited.clearFilter();
        unsolicited.getFilter().setTerminalId(getActiveItem().getId());
        unsolicited.search();

	}

	public MonitoredAtm getFilter() {
		if (filter == null) {
			filter = new MonitoredAtm();
		}
		return filter;
	}

	public DaoDataModel<MonitoredAtm> getDataModel() {
		return dataModel;
	}

	public MonitoredAtm getActiveItem() {
		return activeItem;
	}

	public MonitoredAtm getEditingItem() {
		return editingItem;
	}

	public List<SelectItem> getInstitutions() {
		if (cachedInstitutions == null) {
			cachedInstitutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
			cachedInstitutions.add(0, new SelectItem(""));
		}
		return cachedInstitutions;
	}

	public List<SelectItem> getAgents() {
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("institution_id", filter.getInstId());
		List<SelectItem> agents = getDictUtils().getLov(LovConstants.AGENTS, params);
		agents.add(0, new SelectItem(""));
		return agents;
	}

	public List<SelectItem> getAtmInstallationPlaces() {
		List<SelectItem> places = getDictUtils().getArticles(
				DictNames.ATM_INSTALLATION_PLACE, true, true);
		return places;
	}


    public List<SelectItem> getAtmGroups() {
        if (atmGroups == null) {
            Map<String, Object> paramMap = new HashMap<String, Object>();
            paramMap.put("ARRAY_TYPE_ID", ArrayConstants.ATM_GROUP);
            atmGroups = getDictUtils().getLov(LovConstants.ARRAY_LIST, paramMap);
            atmGroups.add(0, new SelectItem(""));
        }
        return atmGroups;
    }


	public List<SelectItem> getAtmTypes() {
		if (cachedAtmTypes == null) {
			cachedAtmTypes = getDictUtils().getLov(LovConstants.ATM_TYPE);
			cachedAtmTypes.add(0, new SelectItem(""));
		}
		return cachedAtmTypes;
	}

	public List<SelectItem> getServiceStatuses() {
		List<SelectItem> statuses = getDictUtils().getArticles(
				DictNames.ATM_SERVICE_STATUS, true, true);
		return statuses;
	}

	public List<SelectItem> getAtmDevices() {
		List<SelectItem> atmDevices = getDictUtils().getArticles(
				DictNames.HARDWARE_CONF_DATA, true, true);
		return atmDevices;
	}

	public String getFilterAtmDevice() {
		return filterAtmDevice;
	}

	public void setFilterAtmDevice(String filterAtmDevice) {
		this.filterAtmDevice = filterAtmDevice;
	}

	public String getFilterSelectedDeviceStatus() {
		return filterSelectedDeviceStatus;
	}

	public void setFilterSelectedDeviceStatus(String filterSelectedDeviceStatus) {
		this.filterSelectedDeviceStatus = filterSelectedDeviceStatus;
	}

	public List<SelectItem> getAtmDeviceStatuses() {
		List<SelectItem> result;
		String dictName = null;
		if ("HCDT0001".equals(filterAtmDevice)) {
			dictName = DictNames.TIME_OF_D_CLOCK_STATUS_ATM;
		} else if ("HCDT0004".equals(filterAtmDevice)) {
			dictName = DictNames.CARD_READER_STATUS_ATM;
		} else if ("HCDT0008".equals(filterAtmDevice)) {
			dictName = DictNames.JOURNAL_STATUS_ATM;
		} else if ("HCDT0011".equals(filterAtmDevice)) {
			dictName = DictNames.NIGHT_SAFE_DEPS_STATUS_ATM;
		} else if ("HCDT0012".equals(filterAtmDevice)) {
			dictName = DictNames.ENCRYPTOR_STATUS_ATM;
		} else if ("HCDT0013".equals(filterAtmDevice)) {
			dictName = DictNames.CAMERA_STATUS_ATM;
		} else if ("HCDT0025".equals(filterAtmDevice)) {
			dictName = DictNames.COIN_DISPENSER_STATUS_ATM;
		} else if ("HCDT0028".equals(filterAtmDevice)) {
			dictName = DictNames.ENVELOPE_DISP_STATUS_ATM;
		} else if ("HCDT0031".equals(filterAtmDevice)) {
			dictName = DictNames.BARCODE_READER_STATUS_ATM;
		} else if ("HCDT0032".equals(filterAtmDevice)) {
			dictName = DictNames.CHEQUE_PROC_STATUS_ATM;
		} else if ("HCDT0033".equals(filterAtmDevice)) {
			dictName = DictNames.BUNCH_NOTE_ACC_STATUS_ATM;
		}
		result = getDictUtils().getArticles(dictName, true, true);
		return result;
	}
	
	public void sendDateToAtm(){
		try{
			logger.debug("Loading of ATM date...");
			String atmPlugin = obtainAtmPlugin();
			logger.debug("Actual plugin: " + atmPlugin);
			if ("APPLWNDC".equals(atmPlugin)){
				WNDCsendDate();
			} else if ("APPLNCR".equals(atmPlugin)){
				NCRsendDate();
			}
			updateActiveItem();
			logger.debug("Date loading has been successfully complited");
		}catch (Exception e){
			logger.debug(e);

		}
	}
	
	private String obtainAtmPlugin(){
		String atmPlugin = null;
		try {
			atmPlugin = atmDao.getAtmPlugin(userSessionId, new Long(activeItem.getId()), curLang);
		} catch (DataAccessException e){
			FacesUtils.addSystemError(e);
			return atmPlugin;
		}		
		return atmPlugin;
	}

	private void WNDCsendDate() throws Exception{
		PCtlPeerWincorNDC port = prepareWNDCport();
		if (port == null) return;
		
		Integer respCode = null;
		String data = null;
		Holder<Integer> respCodeHd = new Holder<Integer>(respCode);
		Holder<String> dataHd = new Holder<String>(data);
		
		logger.debug("ATM ID: " + activeItem.getId());
		try {
			port.sendDateTimeInfo(activeItem.getId(), respCodeHd, dataHd);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			throw new Exception(e);
		}
	}
	
	private void NCRsendDate() throws Exception{
		PCtlPeerNCR port = prepareNCRport();
		if (port == null) return;
		
		ru.bpc.sv.pctlpeerncr.ObjectFactory of = new ru.bpc.sv.pctlpeerncr.ObjectFactory();
		ru.bpc.sv.pctlpeerncr.SendDateTimeInfoType sdt = of.createSendDateTimeInfoType();
		sdt.setTerminalID(activeItem.getId());
		
		logger.debug("ATM ID: " + activeItem.getId());
		try {
			port.sendDateAndTimeInfo(sdt);			
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			return;
		}
	}
	
	private String prepareEndPoint(String portParamName) throws Exception{
		String endPoint = settingsDao.getParameterValueV(userSessionId,
				SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM,
				null);
		if (endPoint == null || endPoint.trim().length() == 0){
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
			FacesUtils.addErrorExceptionMessage(msg);
			throw new Exception(msg);
		}
		Double wsPort = settingsDao.getParameterValueN(userSessionId,
				portParamName, LevelNames.SYSTEM, null);
		if (wsPort == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					portParamName);
			FacesUtils.addErrorExceptionMessage(msg);
			throw new Exception(msg);
		}
		endPoint = endPoint + ":" + wsPort.intValue();
		return endPoint;
	}
	
	public void updateActiveItem(){
		Filter[] updFilters = new Filter[2];
		Filter f = new Filter();
		f.setValue(activeItem.getId());
		f.setElement("id");
		updFilters[0] = f;
		f = new Filter();
		f.setValue(curLang);
		f.setElement("lang");
		updFilters[1] = f;
		SelectionParams sp = new SelectionParams(updFilters);
		MonitoredAtm[] updatedItem = atmDao.getMonitoredAtms(userSessionId, sp);
		
		try {
			dataModel.replaceObject(activeItem, updatedItem[0]);
			activeItem = updatedItem[0];
		} catch (Exception e) {
			logger.error(e);
			FacesUtils.addSystemError(e);
		}
	}
	
	public void sendHardwareFitness(){
		MbPCtlPeerNcrWS mbPCtlPeerNcrWS = (MbPCtlPeerNcrWS) ManagedBeanWrapper.getManagedBean("MbPCtlPeerNcrWS");
		try {
			mbPCtlPeerNcrWS.sendHardwareFitness(activeItem.getId());
		} catch (Exception e) {
			logger.error(e);
			FacesUtils.addSystemError(e);
		}
	}
	
	private static String IN_SERVICE = "ASSTISRV";
	
	public void openCloseAtm(){		
		try{
			String serviceStatus = activeItem.getServiceStatus();		
			String atmPlugin = obtainAtmPlugin();
			if (IN_SERVICE.equals(serviceStatus)){
				logger.debug("Closing of ATM...");
				logger.debug("Actual plugin: " + atmPlugin);
				logger.debug("ATM ID: " + activeItem.getId());
				if ("APPLWNDC".equals(atmPlugin)){
					WNDCcloseAtm();
				} else if ("APPLNCR".equals(atmPlugin)){
					NCRcloseAtm();
				}
				logger.debug("Closing of ATM has been successfully complited");
			} else {
				logger.debug("Opening of ATM...");
				logger.debug("Actual plugin: " + atmPlugin);
				logger.debug("ATM ID: " + activeItem.getId());
				if ("APPLWNDC".equals(atmPlugin)){
					WNDCopenAtm();
				} else if ("APPLNCR".equals(atmPlugin)){
					NCRopenAtm();
				}
				logger.debug("Opening of ATM has been successfully complited");
			}
		}catch (Exception e){
			logger.error(e);
			return;
		}
		updateActiveItem();
	}
	
	private void WNDCopenAtm() throws Exception{
		PCtlPeerWincorNDC port = prepareWNDCport();
		if (port == null) return;
		
		ru.bpc.sv.pctlpeerwincorndc.ObjectFactory of = new ru.bpc.sv.pctlpeerwincorndc.ObjectFactory();
		ru.bpc.sv.pctlpeerwincorndc.GoInServiceType gis = of.createGoInServiceType();
		gis.setTerminalID(activeItem.getId());
				
		try {
			port.goInService(gis);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			throw new Exception(msg);
		}
	}
	
	private void NCRopenAtm() throws Exception{
		PCtlPeerNCR port = prepareNCRport();
		if (port == null) return;
		
		ru.bpc.sv.pctlpeerncr.ObjectFactory of = new ru.bpc.sv.pctlpeerncr.ObjectFactory();
		ru.bpc.sv.pctlpeerncr.GoInServiceType gis = of.createGoInServiceType();
		gis.setTerminalID(activeItem.getId());
		gis.setForced("");
		
		try {
			port.goInService(gis);			
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			throw new Exception(msg);
		}
	}
	
	private void WNDCcloseAtm() throws Exception{
		PCtlPeerWincorNDC port = prepareWNDCport();
		if (port == null) return;
		
		ru.bpc.sv.pctlpeerwincorndc.ObjectFactory of = new ru.bpc.sv.pctlpeerwincorndc.ObjectFactory();
		ru.bpc.sv.pctlpeerwincorndc.GoOutOfServiceType gos = of.createGoOutOfServiceType();
		gos.setTerminalID(activeItem.getId());
		
		try {
			port.goOutOfService(gos);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			throw new Exception(msg);
		}
	}
	
	private void NCRcloseAtm() throws Exception{
		PCtlPeerNCR port = prepareNCRport();
		if (port == null) return;
		
		ru.bpc.sv.pctlpeerncr.ObjectFactory of = new ru.bpc.sv.pctlpeerncr.ObjectFactory();
		ru.bpc.sv.pctlpeerncr.GoOutOfServiceType gos = of.createGoOutOfServiceType();
		gos.setTerminalID(activeItem.getId());
		gos.setScreen("");
		gos.setForced("");
		
		try {
			port.goOutOfService(gos);	
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			throw new Exception(msg);
		}
	}
	
	private PCtlPeerNCR prepareNCRport() throws Exception{
		PCtlPeerNCR port = null;
		String endPoint = prepareEndPoint(SettingsConstants.NCR_WS_PORT);
		if (endPoint == null) 
			return port;
		
		PCtlPeerNCR_Service service = new PCtlPeerNCR_Service();
		port = service.getPCtlPeerNCRSOAP();
		BindingProvider bp = (BindingProvider)port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, endPoint);
		return port;
	}
	
	private PCtlPeerWincorNDC prepareWNDCport() throws Exception{
		PCtlPeerWincorNDC port = null;
		String endPoint = prepareEndPoint(SettingsConstants.WNDC_WS_PORT);
		if (endPoint == null) 
			return port ;
		
		PCtlPeerWincorNDC_Service service = new PCtlPeerWincorNDC_Service();
		port = service.getPCtlPeerWincorNDCSOAP();
		BindingProvider bp = (BindingProvider)port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, endPoint);
		return port;
	}
	
	public void loadAtmState(){
		try{
			logger.debug("Loading of ATM state...");
			String atmPlugin = obtainAtmPlugin();
			logger.debug("Actual plugin: " + atmPlugin);
			if ("APPLWNDC".equals(atmPlugin)){
				WNDCloadAtmState();
			} else if ("APPLNCR".equals(atmPlugin)){
				NCRloadAtmState();
			}
			updateActiveItem();
			logger.debug("Loading of ATM state has been successfully complited");
		}catch (Exception e){
			logger.debug(e.getMessage());
		}
	}
	
	private void WNDCloadAtmState() throws Exception{
		PCtlPeerWincorNDC port = prepareWNDCport();
		if (port == null) return;
		
		Integer respCode = null;
		String data = null;
		Holder<Integer> respCodeHd = new Holder<Integer>(respCode);
		Holder<String> dataHd = new Holder<String>(data);
		
		logger.debug("ATM ID: " + activeItem.getId());
		try {
			port.sendHardwareConfig(activeItem.getId(), respCodeHd, dataHd);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			return;
		}
	}
	
	private void NCRloadAtmState() throws Exception{
		PCtlPeerNCR port = prepareNCRport();
		if (port == null) return;
		
		Integer respCode = null;
		String data = null;
		Holder<Integer> respCodeHd = new Holder<Integer>(respCode);
		Holder<String> dataHd = new Holder<String>(data);
		
		logger.debug("ATM ID: " + activeItem.getId());
		try {
			port.sendHardwareConfig(activeItem.getId(), respCodeHd, dataHd);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			return;
		}
	}
	
	public String gotoTerminals(){
        HashMap<String,Object> queueFilter = new HashMap<String,Object>();
        queueFilter.put("terminalNumber", activeItem.getTerminalNumber());
        queueFilter.put("terminalType", MbTerminal.ATM_TERMINAL);
        queueFilter.put("backLink", thisBackLink);

        addFilterToQueue("MbTerminal", queueFilter);
		storeBean();
		String link = "acquiring|terminals";
		mbMenu.externalSelect(link);
		return link;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("collectionsTab")) {
			MbAtmCollectionsSearch bean = (MbAtmCollectionsSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmCollectionsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("dispensersTab")) {
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
		} else if (tabName.equalsIgnoreCase("capturedCardsTab")) {
			MbCapturedCard bean = (MbCapturedCard) ManagedBeanWrapper
					.getManagedBean("MbCapturedCard");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("controlTab")) {
			MbDesKeys bean1 = (MbDesKeys) ManagedBeanWrapper
					.getManagedBean("MbDesKeys");
			bean1.setTabName(tabName + ":" + entityTab);
			bean1.setParentSectionId(getSectionId());
			bean1.setTableState(getSateFromDB(bean1.getComponentId()));
		
			MbAtmScenario bean2 = (MbAtmScenario) ManagedBeanWrapper
					.getManagedBean("MbAtmScenario");
			bean2.setTabName(tabName + ":" + entityTab);
			bean2.setParentSectionId(getSectionId());
			bean2.setTableState(getSateFromDB(bean2.getComponentId()));

			MbAtmDispensersSearch bean3 = (MbAtmDispensersSearch) ManagedBeanWrapper
					.getManagedBean("MbAtmDispensersSearch");
			bean3.setTabName(tabName + ":" + entityTab);
			bean3.setParentSectionId(getSectionId());
			bean3.setTableState(getSateFromDB(bean3.getComponentId()));			
		} else if (tabName.equalsIgnoreCase("historyTab")) {
			
			MbAtmFinanceOperationsBottom bean1 = (MbAtmFinanceOperationsBottom) ManagedBeanWrapper
					.getManagedBean("MbAtmFinanceOperationsBottom");
			bean1.setTabName(tabName + ":" + entityTab);
			bean1.setParentSectionId(getSectionId());
			bean1.setTableState(getSateFromDB(bean1.getComponentId()));
			
			MbAdminOperation bean2 = (MbAdminOperation) ManagedBeanWrapper
					.getManagedBean("MbAdminOperation");
			bean2.setTabName(tabName + ":" + entityTab);
			bean2.setParentSectionId(getSectionId());
			bean2.setTableState(getSateFromDB(bean2.getComponentId()));
		
			MbStatusMessage bean3 = (MbStatusMessage) ManagedBeanWrapper
					.getManagedBean("MbStatusMessage");
			bean3.setTabName(tabName + ":" + entityTab);
			bean3.setParentSectionId(getSectionId());
			bean3.setTableState(getSateFromDB(bean3.getComponentId()));

		} else if (tabName.equalsIgnoreCase("atmGroupsTab")) {
            MbAtmGroups bean = (MbAtmGroups) ManagedBeanWrapper
                    .getManagedBean("MbAtmGroups");
            bean.setTabName(tabName);
            bean.setParentSectionId(getSectionId());
            bean.setTableState(getSateFromDB(bean.getComponentId()));
        }
	}
	
	public void synchronizeCounters(){
		try{
			String atmPlugin = obtainAtmPlugin();
			if ("APPLWNDC".equals(atmPlugin)){
				sendSupplyCountersWNDC();
			} else if ("APPLNCR".equals(atmPlugin)){
				sendSupplyCountersNCR();
			}
		} catch (Exception e){
			logger.debug(e.getMessage());
		}
	}	
	
	private void sendSupplyCountersNCR() throws Exception{
		logger.debug("sendSupplyCountersNCR...");
		PCtlPeerNCR port = prepareNCRport();
		if (port == null) return;
		
		Holder<Integer> respCode = new Holder<Integer>();
		Holder<String> data = new Holder<String>();
				
		logger.debug("ATM ID: " + activeItem.getId());
		try {
			port.sendSupplyCounters(activeItem.getId(), "extended", respCode, data);			
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			return;
		}
		logger.debug(String.format("Result: [respCode: %d, date: %s]", respCode.value, data.value));
	}
	
	private void sendSupplyCountersWNDC() throws Exception{
		logger.debug("sendSupplyCountersWNDC...");
		PCtlPeerWincorNDC port = prepareWNDCport();
		if (port == null) return;
		
		Integer respCode = null;
		String data = null;
		Holder<Integer> respCodeHd = new Holder<Integer>(respCode);
		Holder<String> dataHd = new Holder<String>(data);
		
		logger.debug("ATM ID: " + activeItem.getId());
		try {
			port.sendSupplyCounters(activeItem.getId(), respCodeHd, dataHd);
		} catch (Exception e) {
			String msg = e.getMessage() + ". Please check front-end settings";
			FacesUtils.addErrorExceptionMessage(msg);
			logger.error("", e);
			return;
		}
		logger.debug(String.format("Result: [respCodeHd: %d, dataHd: %s]", respCodeHd.value, dataHd.value));
	}
	
	public String getSectionId() {
		return SectionIdConstants.MONITORING_ATM;
	}
}

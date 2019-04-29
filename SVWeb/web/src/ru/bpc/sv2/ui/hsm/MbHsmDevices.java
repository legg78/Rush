package ru.bpc.sv2.ui.hsm;


import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.datamanagement.DataManagement;
import ru.bpc.datamanagement.DataManagement_Service;
import ru.bpc.datamanagement.EntityObjType;
import ru.bpc.datamanagement.ObjectFactory;
import ru.bpc.datamanagement.SyncronizeRqType;
import ru.bpc.datamanagement.SyncronizeRsType;
import ru.bpc.sv.ws.handlers.soap.SOAPLoggingHandler;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.hsm.HsmConnection;
import ru.bpc.sv2.hsm.HsmConstants;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.hsm.HsmLMK;
import ru.bpc.sv2.hsm.HsmSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.HsmDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.process.monitoring.MbProcessTrace;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.xml.ws.Binding;
import javax.xml.ws.BindingProvider;
import javax.xml.ws.handler.Handler;
import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbHsmDevices")
public class MbHsmDevices extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	private static String COMPONENT_ID = "1086:devicesTable";

	private HsmDao _hsmDao = new HsmDao();


	private HsmDevice deviceFilter;
	private HsmDevice newDevice;
	private HsmDevice detailDevice;

	private final DaoDataModel<HsmDevice> _deviceSource;
	private final TableRowSelection<HsmDevice> _itemSelection;
	private HsmDevice _activeDevice;
	private String tabName;

	private ArrayList<SelectItem> hsmLMKs;

	private boolean hsmIsActive = false;

	private HsmDevice[] deviceList = null;

	public MbHsmDevices() {

		pageLink = "hsm|devices";
		tabName = "detailsTab";
		_deviceSource = new DaoDataModel<HsmDevice>() {
			@Override
			protected HsmDevice[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new HsmDevice[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getDevices(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new HsmDevice[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getDevicesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<HsmDevice>(null, _deviceSource);
	}

	public DaoDataModel<HsmDevice> getDevices() {
		return _deviceSource;
	}

	public HsmDevice[] getDeviceList() {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		SelectionParams params = new SelectionParams();
		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		params.setRowIndexEnd(-1);
		try {
			deviceList = _hsmDao.getDevices(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return deviceList;
	}

	public void setDeviceList(HsmDevice[] deviceList) {
		this.deviceList = deviceList;
	}

	public HsmDevice getActiveDevice() {
		return _activeDevice;
	}

	public void setActiveDevice(HsmDevice activeDevice) {
		_activeDevice = activeDevice;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeDevice == null && _deviceSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeDevice != null && _deviceSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeDevice.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeDevice = _itemSelection.getSingleSelection();
				setInfoDepenedOnSeqNum();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null
					&& !_itemSelection.getSingleSelection().getId().equals(_activeDevice.getId())) {
				changeSelect = true;
			}
			_activeDevice = _itemSelection.getSingleSelection();

			if (_activeDevice != null) {
				setBeans();
				if (changeSelect) {
					detailDevice = (HsmDevice) _activeDevice.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_deviceSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDevice = (HsmDevice) _deviceSource.getRowData();
		selection.addKey(_activeDevice.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeDevice != null) {
			setBeans();
			detailDevice = (HsmDevice) _activeDevice.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setInfoDepenedOnSeqNum() {
		MbConnectivity connectivityBean = (MbConnectivity) ManagedBeanWrapper.getManagedBean("MbConnectivity");
		connectivityBean.setHsmDevice(_activeDevice);
		connectivityBean.getConnections().flushCache();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		if (_activeDevice != null) {
			if (tabName.equalsIgnoreCase("connectivityTab")) {
				MbConnectivity connectivityBean = (MbConnectivity) ManagedBeanWrapper.getManagedBean("MbConnectivity");
				connectivityBean.setHsmDevice(_activeDevice);
				connectivityBean.search();
			} else if (tabName.equalsIgnoreCase("selectionsTab")) {
				MbHsmSelectionsSearch selectionsBean = (MbHsmSelectionsSearch) ManagedBeanWrapper
						.getManagedBean("MbHsmSelectionsSearch");
				selectionsBean.clearFilter();
				HsmSelection selectionFilter = new HsmSelection();
				selectionFilter.setHsmId(_activeDevice.getId());
				selectionsBean.setFilter(selectionFilter);
				selectionsBean.setDependent(true);
				selectionsBean.setDeviceEnabled(_activeDevice.isEnabled());
				selectionsBean.search();
			} else if (tabName.equalsIgnoreCase("traceTab")) {
				MbProcessTrace procTraceBean = (MbProcessTrace) ManagedBeanWrapper
						.getManagedBean("MbProcessTrace");
				procTraceBean.getFilter().setObjectId(Long.valueOf(_activeDevice.getId()));
				procTraceBean.getFilter().setEntityType(EntityNames.HSM);
				procTraceBean.search();
			} else if (tabName.equalsIgnoreCase("stdVerTab")) {
				MbHsmStandards standards = (MbHsmStandards) ManagedBeanWrapper.getManagedBean("MbHsmStandards");
				standards.fullCleanBean();
				standards.setValuesEntityType(EntityNames.HSM);
				standards.setValuesObjectId(_activeDevice.getId().longValue());
				standards.setParamEntityType(EntityNames.HSM);
				standards.setParamObjectId(_activeDevice.getId().longValue());
				standards.search();
			}
		}
	}

	public void search() {

		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		deviceFilter = new HsmDevice();
		searching = false;
		clearBean();
		_deviceSource.flushCache();
	}

	public void setFilters() {
		deviceFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (deviceFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(deviceFilter.getId() + "%");
			filters.add(paramFilter);
		}
		if (deviceFilter.getType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("type");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(deviceFilter.getType());
			filters.add(paramFilter);
		}
		if (deviceFilter.getPlugin() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("plugin");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(deviceFilter.getPlugin());
			filters.add(paramFilter);
		}

		if (deviceFilter.getManufacturer() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("manufacturer");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(deviceFilter.getManufacturer());
			filters.add(paramFilter);
		}
		if (deviceFilter.getLmkId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("lmkId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(deviceFilter.getLmkId().toString());
			filters.add(paramFilter);
		}
		if (deviceFilter.getSerialNumber() != null
				&& deviceFilter.getSerialNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("serialNumber");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(deviceFilter.getSerialNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (deviceFilter.getDescription() != null
				&& deviceFilter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(deviceFilter.getDescription().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newDevice = new HsmDevice();
		newDevice.setLang(userLang);
		curLang = newDevice.getLang();
		newDevice.getHsmTcp().setMaxConnections(1);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newDevice = (HsmDevice) detailDevice.clone();
			HsmConnection hsmTcp = (HsmConnection) detailDevice.getHsmTcp().clone();
			newDevice.setHsmTcp(hsmTcp);
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_hsmDao.deleteDevice(userSessionId, _activeDevice);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Hsm", "device_deleted",
					"(id = " + _activeDevice.getId() + ")");

			if (searching) {
				// refresh page if search is on
				clearBean();
			} else {
				// delete object from active page if search is off
				int index = _deviceSource.getActivePage().indexOf(_activeDevice);
				_deviceSource.getActivePage().remove(_activeDevice);
				_itemSelection.clearSelection();

				// if something's left on the page, select item of same index
				if (_deviceSource.getActivePage().size() > 0) {
					SimpleSelection selection = new SimpleSelection();
					if (_deviceSource.getActivePage().size() > index) {
						_activeDevice = _deviceSource.getActivePage().get(index);
					} else {
						_activeDevice = _deviceSource.getActivePage().get(index - 1);
					}
					detailDevice = (HsmDevice) _activeDevice.clone();
					selection.addKey(_activeDevice.getModelId());
					_itemSelection.setWrappedSelection(selection);

					setBeans();
				} else {
					clearBean();
				}
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (HsmConstants.MANUFACTURER_THALES.equals(newDevice.getManufacturer())) {
				if (newDevice.getHsmTcp().getMaxConnections() > 64) {
					throw new Exception("Thales HSM can't have more than 64 connections");
				}
			} else if (HsmConstants.MANUFACTURER_SAFENET.equals(newDevice.getManufacturer())) {
				if (newDevice.getHsmTcp().getMaxConnections() > 16) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul",
							"max_value_field", "Safenet HSM", "16"));
				}
			}
			if (isNewMode()) {
				newDevice = _hsmDao.addDevice(userSessionId, newDevice);
				detailDevice = (HsmDevice) newDevice.clone();
				_itemSelection.addNewObjectToList(newDevice);
			} else {
				newDevice = _hsmDao.editDeviceAndConnection(userSessionId, newDevice);
				detailDevice = (HsmDevice) newDevice.clone();
				if (!userLang.equals(newDevice.getLang())) {
					newDevice = getNodeByLang(_activeDevice.getId(), userLang);
				}
				_deviceSource.replaceObject(_activeDevice, newDevice);
			}
			_activeDevice = newDevice;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Hsm",
					"device_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
		hsmIsActive = false;
	}

	public HsmDevice getFilter() {
		if (deviceFilter == null) {
			deviceFilter = new HsmDevice();
		}
		return deviceFilter;
	}

	public void setFilter(HsmDevice deviceFilter) {
		this.deviceFilter = deviceFilter;
	}

	public HsmDevice getNewDevice() {
		if (newDevice == null) {
			newDevice = new HsmDevice();
		}
		return newDevice;
	}

	public void setNewDevice(HsmDevice newDevice) {
		this.newDevice = newDevice;
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.HSM_STATUS, true, false);
	}

	public ArrayList<SelectItem> getPlugins() {
		return getDictUtils().getArticles(DictNames.HSM_PLUGINS, true, false);
	}

	public ArrayList<SelectItem> getManufacturers() {
		return getDictUtils().getArticles(DictNames.HSM_MANUFACTURERS, true, false);
	}

	public ArrayList<SelectItem> getTypes() {
		return getDictUtils().getArticles(DictNames.HSM_COMMUNICATION_TYPE, true, false);
	}

	public List<SelectItem> getModelNumbers() {
		return getDictUtils().getLov(LovConstants.HSM_MODEL_NUMBER);
	}

	public void clearBean() {
		_deviceSource.flushCache();
		_itemSelection.clearSelection();
		_activeDevice = null;
		detailDevice = null;
		// clear dependent bean
		MbConnectivity connectivityBean = (MbConnectivity) ManagedBeanWrapper.getManagedBean("MbConnectivity");
		connectivityBean.fullCleanBean();

		MbHsmSelectionsSearch selectionsBean = (MbHsmSelectionsSearch) ManagedBeanWrapper
				.getManagedBean("MbHsmSelectionsSearch");
		selectionsBean.clearFilter();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		//
		if (tabName.equalsIgnoreCase("CONNECTIVITYTAB")) {
			MbConnectivity connectivityBean = (MbConnectivity) ManagedBeanWrapper.getManagedBean("MbConnectivity");
			connectivityBean.setTabName(tabName);
			connectivityBean.setParentSectionId(getSectionId());
			connectivityBean.setTableState(getSateFromDB(connectivityBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("SELECTIONSTAB")) {
			MbHsmSelectionsSearch selectionsBean = (MbHsmSelectionsSearch) ManagedBeanWrapper
					.getManagedBean("MbHsmSelectionsSearch");
			selectionsBean.setTabName(tabName);
			selectionsBean.setParentSectionId(getSectionId());
			selectionsBean.setTableState(getSateFromDB(selectionsBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("TRACETAB")) {
			MbProcessTrace procTraceBean = (MbProcessTrace) ManagedBeanWrapper
					.getManagedBean("MbProcessTrace");
			procTraceBean.setTabName(tabName);
			procTraceBean.setParentSectionId(getSectionId());
			procTraceBean.setTableState(getSateFromDB(procTraceBean.getComponentId()));
		}
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailDevice = getNodeByLang(detailDevice.getId(), curLang);
	}

	public HsmDevice getNodeByLang(Integer id, String lang) {
		if (_activeDevice != null) {
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(id.toString());
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(lang);
			filtersList.add(paramFilter);

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			try {
				HsmDevice[] devices = _hsmDao.getDevices(userSessionId, params);
				if (devices != null && devices.length > 0) {
					return devices[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public ArrayList<SelectItem> getHsmLMKs() {
		if (hsmLMKs == null) {

			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				HsmLMK[] lmks = _hsmDao.getHsmLMKs(userSessionId, params);
				for (HsmLMK lmk : lmks) {
					items.add(new SelectItem(lmk.getId(), lmk.getDescription()));
				}
				hsmLMKs = items;
			} catch (Exception e) {
				logger.error("", e);
				if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (hsmLMKs == null)
					hsmLMKs = new ArrayList<SelectItem>();
			}
		}
		return hsmLMKs;
	}

	public boolean getEnableEnabled() {
		if (_activeDevice != null) {
			return _activeDevice.getHsmTcp().getDeviceId() != null;
		}
		return false;
	}

	public void enableHsm() {
		try {
			_activeDevice.setEnabled(true);
			detailDevice = _hsmDao.editDevice(userSessionId, _activeDevice);
			_deviceSource.flushCache(); // refresh
			setBeans();
			updateCache();
		} catch (Exception e) {
			// return previous state in case editing failed
			_activeDevice.setEnabled(false);
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void checkDisableHsm() {
		if (_activeDevice.getStatusOk() > 0) {
			hsmIsActive = true;
		} else {
			disableHsm();
		}
	}

	public void disableHsm() {
		try {
			_activeDevice.setEnabled(false);
			detailDevice = _hsmDao.editDevice(userSessionId, _activeDevice);
			_deviceSource.flushCache(); // refresh
			hsmIsActive = false;
			setBeans();
			updateCache();
		} catch (Exception e) {
			// return previous state in case editing failed
			_activeDevice.setEnabled(true);
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isHsmStatusActive() {
		return hsmIsActive;
	}

	public void confirmEditLanguage() {
		curLang = newDevice.getLang();
		HsmDevice tmp = getNodeByLang(newDevice.getId(), newDevice.getLang());
		if (tmp != null) {
			newDevice.setDescription(tmp.getDescription());
		}
	}

//	public void validateMaxConnections(FacesContext context, UIComponent toValidate, Object value) {
//		Integer newValue = (Integer) value;
//		// check position must be less than or equal to name length
//		if (getNewDevice().getNodeCount() != null
//				&& getNewDevice().getNodeCount().compareTo(newValue) > 0) {
//			((UIInput) toValidate).setValid(false);
//
//			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
//					"one_cant_be_less_than_another", 
//					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Hsm", "max_connections"),
//					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Hsm", "node_count"));
//			FacesMessage message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
//			context.addMessage(toValidate.getClientId(context), message);
//		}
//	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public HsmDevice getDetailDevice() {
		return detailDevice;
	}

	public void setDetailDevice(HsmDevice detailDevice) {
		this.detailDevice = detailDevice;
	}

	public String getSectionId() {
		return SectionIdConstants.HSM_DEVICE;
	}

	public void updateCache() {
		String feLocation = getFeLocation();
		ObjectFactory of = new ObjectFactory();
		SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
		List<EntityObjType> listEnityObjType = syncronizeRqType
				.getEntityObj();

		EntityObjType entityObj = of.createEntityObjType();
		entityObj.setObjId(_activeDevice.getId().toString());
		entityObj.setObjSeq(_activeDevice.getSeqNum());
		listEnityObjType.add(entityObj);

		syncronizeRqType.setEntityType(EntityNames.HSM);

		DataManagement_Service service = new DataManagement_Service();
		DataManagement port = service.getDataManagementSOAP();
		BindingProvider bp = (BindingProvider) port;
		bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
		bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
		bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);

		Binding binding = bp.getBinding();
		@SuppressWarnings({"rawtypes"})
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
			if (e.getCause() instanceof UnknownHostException) {
				msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "unknown_host", e.getCause().getMessage()) + ".";
			} else if (e.getCause() instanceof SocketTimeoutException) {
				msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "web_service_timeout");
			} else {
				msg = e.getMessage();
			}
			msg += ". " + FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "check_front_end_settings");
			FacesUtils.addErrorExceptionMessage(msg);
			loggerDB.error(new TraceLogInfo(userSessionId, e.getMessage(), EntityNames.HSM, _activeDevice.getId().longValue()), e);
			logger.error("", e);
			return;
		}
	}

	private String getFeLocation() {
		String feLocation = settingsDao.getParameterValueV(userSessionId,
				SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM,
				null);
		if (feLocation == null || feLocation.trim().length() == 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty", SettingsConstants.FRONT_END_LOCATION);
			FacesUtils.addErrorExceptionMessage(msg);
			return null;
		}
		Double wsPort = settingsDao.getParameterValueN(userSessionId,
				SettingsConstants.UPDATE_CACHE_WS_PORT, LevelNames.SYSTEM, null);
		if (wsPort == null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "sys_param_empty",
					SettingsConstants.UPDATE_CACHE_WS_PORT);
			FacesUtils.addErrorExceptionMessage(msg);
			return null;
		}
		return feLocation + ":" + wsPort.intValue();
	}
	
	public String getActionHsmDevice(){
		if (_activeDevice != null){
			if (_activeDevice.isEnabled()){
				return "checkDisableHsm";
			}else {
				return "enableHsm";
			}
		}else{
			return "";
		}
	}

	public String getWarningMessage(){
		if (_activeDevice != null){
			if (_activeDevice.isEnabled()){
				return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Hsm", "confirm_hsm_disable");
			}else {
				return FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Hsm", "confirm_hsm_enable");
			}
		}else{
			return "";
		}
	}

}

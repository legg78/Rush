package ru.bpc.sv2.ui.cmn;

import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.xml.ws.BindingProvider;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.datamanagement.DataManagement;
import ru.bpc.datamanagement.DataManagement_Service;
import ru.bpc.datamanagement.EntityObjStatusType;
import ru.bpc.datamanagement.EntityObjType;
import ru.bpc.datamanagement.ObjectFactory;
import ru.bpc.datamanagement.SyncronizeRqType;
import ru.bpc.datamanagement.SyncronizeRsType;
import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.cmn.Device;
import ru.bpc.sv2.cmn.TcpIpDevice;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.rules.CommunicationConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.network.MbNetworkDevicesSearch;
import ru.bpc.sv2.ui.process.monitoring.MbProcessTrace;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;



@ViewScoped
@ManagedBean(name = "MbDevices")
public class MbDevices extends AbstractBean {
	private static final long serialVersionUID = -4035781808928558360L;

	private static final Logger logger = Logger.getLogger("COMMUNICATIONS");

	private static String COMPONENT_ID = "1170:tcpsTable";

	private CommunicationDao _cmnDao = new CommunicationDao();

	private SettingsDao settingsDao = new SettingsDao();

	private Device filter;
	private Device newDevice;

	private boolean blockFilterStandard;
	private ArrayList<SelectItem> institutions;

	private String backLink;
	private boolean selectMode;

	private final DaoDataModel<Device> _devicesSource;
	private final TableRowSelection<Device> _itemSelection;
	private Device _activeDevice;

	private String standardIds;
	private boolean showAvailableOnly = false; // show only those devices that are not assigned to any host

	private boolean addDisabled = false;
	private Menu menu;

	private String tabName;

	public MbDevices() {
		thisBackLink = "cmn|devices";
		pageLink = "cmn|devices";
		tabName = "detailsTab";
		menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");

		_devicesSource = new DaoDataModel<Device>() {
			private static final long serialVersionUID = -882710637142702891L;

			@Override
			protected Device[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Device[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getAllDevices(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Device[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getAllDevicesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Device>(null, _devicesSource);
		restoreFilter();
	}

	private void restoreFilter() {
		HashMap<String, Object> queueFilter = getQueueFilter("MbDevices");

		if (queueFilter == null)
			return;
		clearFilter();
		if (queueFilter.containsKey("standardId")) {
			getFilter().setStandardId((Integer) queueFilter.get("standardId"));
		}
		if (queueFilter.containsKey("blockFilterStandard")) {
			setBlockFilterStandard(queueFilter.get("blockFilterStandard").equals("true"));
		}
		if (queueFilter.containsKey("showAvailableOnly")) {
			setShowAvailableOnly(queueFilter.get("showAvailableOnly").equals("true"));
		}
		if (queueFilter.containsKey("selectMode")) {
			setSelectMode(queueFilter.get("selectMode").equals("true"));
		}
		if (queueFilter.containsKey("backLink")) {
			backLink = (String) queueFilter.get("backLink");
		}

		search();
	}


	public DaoDataModel<Device> getDevices() {
		return _devicesSource;
	}

	public Device getActiveDevice() {
		return _activeDevice;
	}

	public void setActiveDevice(Device activeDevice) {
		_activeDevice = activeDevice;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeDevice == null && _devicesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeDevice != null && _devicesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeDevice.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeDevice = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeDevice = _itemSelection.getSingleSelection();

		if (_activeDevice != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_devicesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDevice = (Device) _devicesSource.getRowData();
		selection.addKey(_activeDevice.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setBeans() {
		if (_activeDevice != null) {
			if (tabName.equalsIgnoreCase("traceTab")) {
				MbProcessTrace procTraceBean = (MbProcessTrace) ManagedBeanWrapper
						.getManagedBean("MbProcessTrace");
				procTraceBean.getFilter().setObjectId(Long.valueOf(_activeDevice.getId()));
				procTraceBean.getFilter().setEntityType(EntityNames.COM_DEVICE);
				procTraceBean.search();
			}
		}
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		filter = null;
		searching = false;
	}

	public void fullCleanBean() {
		clearFilter();
		standardIds = null;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getStandardId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStandardId().toString());
			filters.add(paramFilter);
		} else if (standardIds != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardIds");
			paramFilter.setValue(standardIds);
			filters.add(paramFilter);
		}

		if (showAvailableOnly) {
			paramFilter = new Filter();
			paramFilter.setElement("availableOnly");
			paramFilter.setValue(showAvailableOnly);
			filters.add(paramFilter);
		}
	}

	public void add() {
		newDevice = new Device();
		newDevice.setInstId(getFilter().getInstId());
		newDevice.setStandardId(getFilter().getStandardId());
		newDevice.setTcpDevice(new TcpIpDevice());
		newDevice.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newDevice = (Device) _activeDevice.clone();
		} catch (CloneNotSupportedException e) {
			newDevice = _activeDevice;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			if (_activeDevice.isIsTcpDevice()) {
				_cmnDao.deleteTcpIpDevice(userSessionId, _activeDevice.getTcpDevice());
			} else {
				_cmnDao.deleteDevice(userSessionId, _activeDevice);
			}

			_activeDevice = _itemSelection.removeObjectFromList(_activeDevice);
			if (_activeDevice == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				if (newDevice.isIsTcpDevice()) {
					newDevice.setAsTcpDevice(_cmnDao.addTcpIpDevice(userSessionId, newDevice
							.getTcpDevice(true)));
				} else {
					newDevice = _cmnDao.addDevice(userSessionId, newDevice);
				}
				_itemSelection.addNewObjectToList(newDevice);
			} else {
				if (newDevice.isIsTcpDevice()) {
					newDevice.setAsTcpDevice(_cmnDao.editTcpIpDevice(userSessionId, newDevice
							.getTcpDevice(true)));
				} else {
					newDevice = _cmnDao.editDevice(userSessionId, newDevice);
				}
				_devicesSource.replaceObject(_activeDevice, newDevice);
			}
			_activeDevice = newDevice;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
					"tcp_ip_saved"));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Device getFilter() {
		if (filter == null) {
			filter = new Device();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Device mainFilter) {
		this.filter = mainFilter;
	}

	public Device getNewDevice() {
		if (newDevice == null) {
			newDevice = new Device();
		}
		return newDevice;
	}

	public void setNewDevice(Device newDevice) {
		this.newDevice = newDevice;
	}

	public void clearBean() {
		_devicesSource.flushCache();
		_itemSelection.clearSelection();
		_activeDevice = null;
	}

	public ArrayList<SelectItem> getInitiators() {
		return (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.TCP_INITIATOR);
	}

	public ArrayList<SelectItem> getFormats() {
		return (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.TCP_FORMAT);
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getStandards() {
		ArrayList<SelectItem> items;

		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", userLang);
		filters[1] = new Filter("standardTypes", "'" + CommunicationConstants.NETWORK_CMN_STANDARD
				+ "', '" + CommunicationConstants.TERMINAL_CMN_STANDARD + "'");

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		params.setFilters(filters);
		CmnStandard[] stds;
		try {
			stds = _cmnDao.getCommStandards(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}

		items = new ArrayList<SelectItem>();
		for (CmnStandard std : stds) {
			items.add(new SelectItem(std.getId(), std.getLabel() != null ? std.getLabel()
					: ("{ID = " + std.getId() + "}")));
		}

		return items;
	}

	public ArrayList<SelectItem> getCommPlugins() {
		return (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.COMMUNICATION_PLUGIN);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeDevice.getId().toString());
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
			Device[] devices = _cmnDao.getAllDevices(userSessionId, params);
			if (devices != null && devices.length > 0) {
				_activeDevice = devices[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String cancelSelect() {
		MbNetworkDevicesSearch netDevices = (MbNetworkDevicesSearch) ManagedBeanWrapper
				.getManagedBean("MbNetworkDevicesSearch");
		if (removeLastPageFromRoute() > 0) {
			netDevices.setDirectAccess(false);
		}

		menu.externalSelect(backLink);

		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public String selectDevice() {
		MbNetworkDevicesSearch netDevices = (MbNetworkDevicesSearch) ManagedBeanWrapper
				.getManagedBean("MbNetworkDevicesSearch");
		netDevices.addDeviceToNetwork(_activeDevice, true);

		if (removeLastPageFromRoute() > 0) {
			netDevices.setDirectAccess(false);
		}

		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);

		menu.externalSelect(backLink);
		return backLink;
	}

	public void reload() {
		logger.debug("Reloading of selected devices...");
		try {
			List<Device> selectedDevices = _itemSelection
					.getMultiSelection();
			if (selectedDevices.size() == 0) {
				return;
			}

			String feLocation = settingsDao.getParameterValueV(userSessionId,
					SettingsConstants.FRONT_END_LOCATION, LevelNames.SYSTEM,
					null);
			if (feLocation == null || feLocation.trim().length() == 0) {
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
			logger.debug("FE location: " + feLocation);

			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType
					.getEntityObj();

			logger.debug("Device to reload: " + selectedDevices.size());
			for (Device device : selectedDevices) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(device.getId().toString());
				entityObj.setObjSeq(device.getTcpDevice().getSeqNum());
				listEnityObjType.add(entityObj);
				logger.debug("Device ID: " + device.getId().toString());
				logger.debug("Device Sequence: " + device.getSeqNum());
			}
			syncronizeRqType.setEntityType(EntityNames.COM_DEVICE);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider) port;
			bp.getRequestContext().put(BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
			bp.getRequestContext().put("javax.xml.ws.client.connectionTimeout", SystemConstants.FE_TIMEOUT);
			bp.getRequestContext().put("javax.xml.ws.client.receiveTimeout", SystemConstants.FE_TIMEOUT);

			SyncronizeRsType rsType = null;
			logger.debug("Reloading...");
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
				logger.error("", e);
				return;
			}
			List<EntityObjStatusType> objStatusTypes = rsType.getEntityObjStatus();

			for (int i = 0; i < selectedDevices.size(); i++) {
				Device device = selectedDevices.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				device.setFerrNo(objStatusType.getFerrno());
			}
			logger.debug("Reloading has been successfully complited...");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isBlockFilterStandard() {
		return blockFilterStandard;
	}

	public void setBlockFilterStandard(boolean blockFilterStandard) {
		this.blockFilterStandard = blockFilterStandard;
	}

	public Device loadDevice(Integer id) {
		Filter[] filters = new Filter[2];

		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setOp(Operator.eq);
		filters[0].setValue(userLang);
		filters[1] = new Filter();
		filters[1].setElement("id");
		filters[1].setOp(Operator.eq);
		filters[1].setValue(id.toString());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Device[] device = _cmnDao.getTcpDevices(userSessionId, params);
			if (device != null && device.length > 0) {
				_activeDevice = device[0];
				return device[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}

		return null;
	}

	public String getStandardIds() {
		return standardIds;
	}

	/**
	 * @param standardIds - comma separated standard IDs
	 */
	public void setStandardIds(String standardIds) {
		this.standardIds = standardIds;
	}

	public void enableDevice() {
		try {
			_activeDevice.getTcpDevice().setEnabled(true);
			_cmnDao.enableTcpIpDevice(userSessionId, _activeDevice.getTcpDevice());
		} catch (Exception e) {
			// return previous state in case editing failed
			_activeDevice.getTcpDevice().setEnabled(false);
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void disableDevice() {
		try {
			_activeDevice.getTcpDevice().setEnabled(false);
			_cmnDao.enableTcpIpDevice(userSessionId, _activeDevice.getTcpDevice());
		} catch (Exception e) {
			// return previous state in case editing failed
			_activeDevice.getTcpDevice().setEnabled(true);
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newDevice.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newDevice.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Device[] items = _cmnDao.getTcpDevices(userSessionId, params);
			if (items != null && items.length > 0) {
				newDevice.setCaption(items[0].getCaption());
				newDevice.setDescription(items[0].getDescription());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isShowAvailableOnly() {
		return showAvailableOnly;
	}

	/**
	 * <p>
	 * Whether to show only those devices that are not assigned to any host or
	 * all devices
	 * </p>
	 */
	public void setShowAvailableOnly(boolean showAvailableOnly) {
		this.showAvailableOnly = showAvailableOnly;
	}

	public boolean isAddDisabled() {
		return addDisabled;
	}

	public void setAddDisabled(boolean addDisabled) {
		this.addDisabled = addDisabled;
	}

	public List<Device> getSelectedItems() {
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
		//
		if (tabName.equalsIgnoreCase("traceTab")) {
			MbProcessTrace procTraceBean = (MbProcessTrace) ManagedBeanWrapper
					.getManagedBean("MbProcessTrace");
			procTraceBean.setTabName(tabName);
			procTraceBean.setParentSectionId(getSectionId());
			procTraceBean.setTableState(getSateFromDB(procTraceBean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.ADMIN_COMMU_DEVICE;
	}

}

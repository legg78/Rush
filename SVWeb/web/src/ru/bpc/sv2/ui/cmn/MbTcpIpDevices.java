package ru.bpc.sv2.ui.cmn;

import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.ArrayList;
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
import ru.bpc.sv2.cmn.TcpIpDevice;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.network.MbNetworkDevicesSearch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbTcpIpDevices")
public class MbTcpIpDevices extends AbstractBean {
	private static final long serialVersionUID = -445249267114423505L;

	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private CommunicationDao _cmnDao = new CommunicationDao();

	private TcpIpDevice filter;
	private TcpIpDevice newDevice;

	private boolean blockFilterStandard;
	private ArrayList<SelectItem> institutions;

	private String backLink;
	private boolean selectMode;

	private final DaoDataModel<TcpIpDevice> _tcpsSource;
	private final TableRowSelection<TcpIpDevice> _itemSelection;
	private TcpIpDevice _activeDevice;

	private String standardIds;
	private boolean showAvailableOnly = false; // show only those devices that are not assigned to any host 
	
	public MbTcpIpDevices() {
		thisBackLink = "cmn|tcpIps";
		

		_tcpsSource = new DaoDataModel<TcpIpDevice>() {
			private static final long serialVersionUID = 3983108538116588473L;

			@Override
			protected TcpIpDevice[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new TcpIpDevice[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getTcpDevices(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new TcpIpDevice[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getTcpDevicesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<TcpIpDevice>(null, _tcpsSource);
	}

	public DaoDataModel<TcpIpDevice> getDevices() {
		return _tcpsSource;
	}

	public TcpIpDevice getActiveDevice() {
		return _activeDevice;
	}

	public void setActiveDevice(TcpIpDevice activeDevice) {
		_activeDevice = activeDevice;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeDevice == null && _tcpsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeDevice != null && _tcpsSource.getRowCount() > 0) {
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
		_tcpsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDevice = (TcpIpDevice) _tcpsSource.getRowData();
		selection.addKey(_activeDevice.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeDevice != null) {
			setBeans();
		}
	}

	public void setBeans() {
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
		newDevice = new TcpIpDevice();
		newDevice.setInstId(getFilter().getInstId());
		newDevice.setStandardId(getFilter().getStandardId());
		newDevice.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newDevice = _activeDevice.clone();
		} catch (CloneNotSupportedException e) {
			newDevice = _activeDevice;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_cmnDao.deleteTcpIpDevice(userSessionId, _activeDevice);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn", "tcp_ip_deleted",
					"(id = " + _activeDevice.getId() + ")");

			_activeDevice = _itemSelection.removeObjectFromList(_activeDevice);
			if (_activeDevice == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newDevice = _cmnDao.addTcpIpDevice(userSessionId, newDevice);
				_itemSelection.addNewObjectToList(newDevice);
			} else {
				newDevice = _cmnDao.editTcpIpDevice(userSessionId, newDevice);
				_tcpsSource.replaceObject(_activeDevice, newDevice);
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

	public TcpIpDevice getFilter() {
		if (filter == null) {
			filter = new TcpIpDevice();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(TcpIpDevice mainFilter) {
		this.filter = mainFilter;
	}

	public TcpIpDevice getNewDevice() {
		if (newDevice == null) {
			newDevice = new TcpIpDevice();
		}
		return newDevice;
	}

	public void setNewDevice(TcpIpDevice newDevice) {
		this.newDevice = newDevice;
	}

	public void clearBean() {
		_tcpsSource.flushCache();
		_itemSelection.clearSelection();
		_activeDevice = null;
	}

	public ArrayList<SelectItem> getInitiators() {
		return getDictUtils().getArticles(DictNames.TCP_INITIATOR, true, false);
	}

	public ArrayList<SelectItem> getFormats() {
		return getDictUtils().getArticles(DictNames.TCP_FORMAT, true, false);
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

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		List<Filter> filtersStd = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersStd.add(paramFilter);
		params.setFilters(filtersStd.toArray(new Filter[filtersStd.size()]));
		CmnStandard[] stds;
		try {
			stds = _cmnDao.getCommStandards(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			return new ArrayList<SelectItem>(0);
		}

		items = new ArrayList<SelectItem>();
		for (CmnStandard std: stds) {
			items.add(new SelectItem(std.getId(), std.getLabel() != null ? std.getLabel()
					: ("{ID = " + std.getId() + "}")));
		}

		return items;
	}

	public ArrayList<SelectItem> getCommPlugins() {
		return getDictUtils().getArticles(DictNames.COMMUNICATION_PLUGIN, true, false);
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
			TcpIpDevice[] devices = _cmnDao.getTcpDevices(userSessionId, params);
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
		return backLink;
	}

	public void reload() {
		try {
			List<TcpIpDevice> tcpIpDevices = _itemSelection.getMultiSelection();
			if (tcpIpDevices.size() == 0) {
				return;
			}

			String feLocation = prepareFeLocation(SettingsConstants.UPDATE_CACHE_WS_PORT);
			
			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType.getEntityObj();

			for (TcpIpDevice tcpDevice : tcpIpDevices) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(tcpDevice.getId().toString());
				entityObj.setObjSeq(tcpDevice.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(EntityNames.HOST);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider) port;
			bp.getRequestContext().put(
					BindingProvider.ENDPOINT_ADDRESS_PROPERTY, feLocation);
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

			for (int i = 0; i < tcpIpDevices.size(); i++) {
				TcpIpDevice tcpDevice = tcpIpDevices.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				tcpDevice.setFerrNo(objStatusType.getFerrno());
			}
		} catch (Exception e) {
			FacesUtils.addSystemError(e);
			logger.error("", e);
		}
	}

	public boolean isBlockFilterStandard() {
		return blockFilterStandard;
	}

	public void setBlockFilterStandard(boolean blockFilterStandard) {
		this.blockFilterStandard = blockFilterStandard;
	}

	public TcpIpDevice loadDevice(Integer id) {
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
			TcpIpDevice[] device = _cmnDao.getTcpDevices(userSessionId, params);
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
	 * @param standardIds
	 *            - comma separated standard IDs
	 */
	public void setStandardIds(String standardIds) {
		this.standardIds = standardIds;
	}

	public void enableDevice() {
		try {
			_activeDevice.setEnabled(true);
			_cmnDao.enableTcpIpDevice(userSessionId, _activeDevice);
		} catch (Exception e) {
			// return previous state in case editing failed
			_activeDevice.setEnabled(false);
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void disableDevice() {
		try {
			_activeDevice.setEnabled(false);
			_cmnDao.enableTcpIpDevice(userSessionId, _activeDevice);
		} catch (Exception e) {
			// return previous state in case editing failed
			_activeDevice.setEnabled(true);
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
			TcpIpDevice[] items = _cmnDao.getTcpDevices(userSessionId, params);
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
	
	public List<TcpIpDevice> getSelectedItems() {
		return _itemSelection.getMultiSelection();
	}
}

package ru.bpc.sv2.ui.network;

import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
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
import ru.bpc.sv2.cmn.Device;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.NetDevice;
import ru.bpc.sv2.net.NetworkMember;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.cmn.MbDevices;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbNetworkDevicesSearch")
public class MbNetworkDevicesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("NETWORKS");

	private NetworkDao _networkDao = new NetworkDao();

	private CommunicationDao _cmnDao = new CommunicationDao();

	private ArrayList<Filter> filters;
	private NetDevice newNetDevice;
	private NetDevice _activeNetDevice;
	private Device newDevice;

	private NetworkMember host;

	private String backLink;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<NetDevice> _netDevicesSource;
	private final TableRowSelection<NetDevice> _itemSelection;

	private MbNetworkDevices sessBean;
	private Menu menu;
	
	private static String COMPONENT_ID = "devicesTable";
	private String tabName;
	private String parentSectionId;

	public MbNetworkDevicesSearch() {
		sessBean = (MbNetworkDevices) ManagedBeanWrapper
				.getManagedBean("MbNetworkDevices");		
		menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		_netDevicesSource = new DaoDataModel<NetDevice>() {
			@Override
			protected NetDevice[] loadDaoData(SelectionParams params) {
				if (host == null || !searching) {
					return new NetDevice[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networkDao.getNetDevices(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NetDevice[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (host == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networkDao.getNetDevicesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NetDevice>(null, _netDevicesSource);

		if (!sessBean.isKeepState()) {

		} else {
			searching = sessBean.isSearching();
			host = sessBean.getHost();
			_activeNetDevice = sessBean.getSavedActiveNetDevice();
			sessBean.setKeepState(false);
		}
	}

	public DaoDataModel<NetDevice> getNetDevices() {
		return _netDevicesSource;
	}

	public NetDevice getActiveNetDevice() {
		return _activeNetDevice;
	}

	public void setActiveNetDevice(NetDevice activeNetDevice) {
		_activeNetDevice = activeNetDevice;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeNetDevice == null && _netDevicesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeNetDevice != null && _netDevicesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeNetDevice.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeNetDevice = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_netDevicesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeNetDevice = (NetDevice) _netDevicesSource.getRowData();
		selection.addKey(_activeNetDevice.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeNetDevice = _itemSelection.getSingleSelection();
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter = new Filter();
		paramFilter.setElement("hostMemberId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(host.getId().toString());
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newNetDevice = new NetDevice();
		newNetDevice.setLang(userLang);
		MbDevices devices = (MbDevices) ManagedBeanWrapper.getManagedBean("MbDevices");
		devices.setBlockFilterStandard(true);
		devices.setFilter(null);
		devices.getFilter().setStandardId(host.getOnlineStdId());
		devices.add();
		newNetDevice.setHostMemberId(host.getId());
		curMode = NEW_MODE;
	}

	public String selectDevice() {
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("standardId", host.getOnlineStdId());
		queueFilter.put("blockFilterStandard", "true");
		queueFilter.put("showAvailableOnly", "true");
		queueFilter.put("selectMode", "true");
		queueFilter.put("backLink", backLink);
		
		addFilterToQueue("MbDevices", queueFilter);
		
		menu.externalSelect("cmn|devices");
		
		sessBean.setHost(host);
		sessBean.setKeepState(true);
		search();
		return "cmn|devices";
	}

	public NetDevice addDeviceToNetwork(Device device) {
		return addDeviceToNetwork(device, false);
	}
	
	public NetDevice addDeviceToNetwork(Device device, boolean isExternal) {
		try {
			newNetDevice = new NetDevice();
			newNetDevice.setId(device.getId());
			if (host == null && isExternal) {
				host = sessBean.getHost();
			}
			newNetDevice.setLang(device.getLang());
			newNetDevice.setHostMemberId(host.getId());
			return _networkDao.addNetDevice(userSessionId, newNetDevice);
		} catch (Exception e) {
			logger.error("", e);
			return null;
		}
	}

	public void edit() {
		try {
			// newNetDevice = (NetDevice) _activeNetDevice.clone();
			MbDevices devicesBean = (MbDevices) ManagedBeanWrapper.getManagedBean("MbDevices");

			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("id", _activeNetDevice.getId());
			filters[1] = new Filter("lang", userLang);

			params.setFilters(filters);
			Device[] devices = _cmnDao.getAllDevices(userSessionId, params);
			if (devices.length > 0) {
				devicesBean.setActiveDevice(devices[0]);
				devicesBean.edit();
			}
			curMode = EDIT_MODE;
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networkDao.deleteNetDevice(userSessionId, _activeNetDevice);

			// Why did i add it? 
//			// delete communication device and its protocol settings
//			TcpIpDevice tcpDevice = new TcpIpDevice();
//			tcpDevice.setId(_activeNetDevice.getId());
//			tcpDevice.setSeqNum(_activeNetDevice.getSeqNum()); // hope these two are always equal
//			_cmnDao.deleteTcpIpDevice(userSessionId, tcpDevice);

			_activeNetDevice = _itemSelection.removeObjectFromList(_activeNetDevice);
			if (_activeNetDevice == null) {
				clearState();
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			MbDevices devices = (MbDevices) ManagedBeanWrapper.getManagedBean("MbDevices");
			newDevice = devices.getNewDevice();
			if (isNewMode()) {
				// As network device is a communication device of certain
				// protocol
				// it's need to create such device first...
				if (newDevice.isIsTcpDevice()) {
					newDevice.setAsTcpDevice(_cmnDao.addTcpIpDevice(userSessionId, newDevice
							.getTcpDevice(true)));
				} else {
					newDevice = _cmnDao.addDevice(userSessionId, newDevice);
				}

				// ... then add it to current network by binding it to current
				// host
				newNetDevice = addDeviceToNetwork(newDevice);

				_itemSelection.addNewObjectToList(newNetDevice);
				_activeNetDevice = newNetDevice;
			} else {
				if (newDevice.isIsTcpDevice()) {
					newDevice.setAsTcpDevice(_cmnDao.editTcpIpDevice(userSessionId, newDevice
							.getTcpDevice(true)));
				} else {
					newDevice = _cmnDao.editDevice(userSessionId, newDevice);
				}
				// _networkDao.editNetDevice( userSessionId, newNetDevice);
				_netDevicesSource.flushCache();
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

	public void search() {
		clearState();
		searching = true;
	}

	public NetDevice getNewNetDevice() {
		if (newNetDevice == null) {
			newNetDevice = new NetDevice();
		}
		return newNetDevice;
	}

	public void setNewNetDevice(NetDevice newNetDevice) {
		this.newNetDevice = newNetDevice;
	}

	public void clearState() {
		_netDevicesSource.flushCache();
		_itemSelection.clearSelection();
		_activeNetDevice = null;
	}

	public void fullCleanBean() {
		host = null;

		clearState();
	}

	public NetworkMember getHost() {
		return host;
	}

	public void setHost(NetworkMember host) {
		this.host = host;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public String gotoInterfacesConfig() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);

		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("valuesObjectId", _activeNetDevice.getId().longValue());
		queueFilter.put("valuesEntityType", EntityNames.COM_DEVICE);
		queueFilter.put("standardId", _activeNetDevice.getStandardId());
		queueFilter.put("paramObjectId", host.getId().longValue());
		queueFilter.put("paramEntityType", EntityNames.HOST);
		queueFilter.put("pageTitle", FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "if_config_title",
				FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "host"), host.getId(), host
				.getInstName(), FacesUtils
				.getMessage("ru.bpc.sv2.ui.bundles.Cmn", "device"), _activeNetDevice
				.getId(), _activeNetDevice.getCaption()));
		queueFilter.put("backLink", "net|hosts");
		
		addFilterToQueue("MbIfConfig", queueFilter);

		sessBean.setSearching(searching);
		sessBean.setSavedActiveNetDevice(_activeNetDevice);
		sessBean.setKeepState(true);

		return "ifConfig";
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

	public void reload() {
		try {
			List<NetDevice> netDevices = _itemSelection.getMultiSelection();
			if (netDevices.size() == 0) {
				return;
			}

			String feLocation = prepareFeLocation(SettingsConstants.UPDATE_CACHE_WS_PORT);			

			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType.getEntityObj();

			for (NetDevice host : netDevices) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(host.getId().toString());
				entityObj.setObjSeq(host.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(EntityNames.COM_DEVICE);

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

			for (int i = 0; i < netDevices.size(); i++) {
				NetDevice netDevice = netDevices.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				netDevice.setFerrNo(objStatusType.getFerrno());
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
/*		try {
			FEBOInterchange client = new FEBOInterchange();
			ReloadRequest request = new ReloadRequest();
			request.getIdList().add(new Integer(0));
			client.getNewPort().reloadCommunicationDevice(request);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}*/
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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

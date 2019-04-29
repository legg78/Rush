package ru.bpc.sv2.ui.network;

import java.net.SocketTimeoutException;
import java.net.UnknownHostException;
import java.util.ArrayList;
import java.util.HashMap;
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
import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.net.NetworkMember;
import ru.bpc.sv2.rules.CommunicationConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.security.MbDesKeysBottom;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;



@ViewScoped
@ManagedBean (name = "MbHosts")
public class MbHosts extends AbstractBean {

	private static final long serialVersionUID = 1L;

	private static String COMPONENT_ID = "1232:hostsTable";

	private NetworkDao _networksDao = new NetworkDao();

	private CommunicationDao _cmnDao = new CommunicationDao();

	private static final Logger logger = Logger.getLogger("NETWORKS");

	private NetworkMember newHost;
	private NetworkMember detailHost;
	private NetworkMember filter;

	private String backLink;

	private final DaoDataModel<NetworkMember> _hostsSource;
	private final TableRowSelection<NetworkMember> _itemSelection;
	private NetworkMember _activeHost;
	private HashMap<Integer, NetworkMember> hostOwnersMap;

	private MbHostsSess sessBean;
	private boolean blockNetwork = false;
	private String tabName;
	private Boolean useHsm;

	public MbHosts() {
		pageLink = "net|hosts";
//		thisBackLink = "net|hosts";
		
		sessBean = (MbHostsSess) ManagedBeanWrapper.getManagedBean("MbHostsSess");

		_hostsSource = new DaoDataModel<NetworkMember>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected NetworkMember[] loadDaoData(SelectionParams params) {
				if (restoreBean) {
					FacesUtils.setSessionMapValue(pageLink, Boolean.FALSE);
					if (sessBean.getHostsList() != null) {
						List<NetworkMember> hostsList = sessBean.getHostsList();
						sessBean.setHostsList(null);
						return (NetworkMember[]) hostsList.toArray(new NetworkMember[hostsList
								.size()]);
					}
				}
				if (!searching) {
					return new NetworkMember[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getHosts(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NetworkMember[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (restoreBean && sessBean.getHostsList() != null) {
					return sessBean.getHostsList().size();
				}
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getHostsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NetworkMember>(null, _hostsSource);

		tabName = "detailsTab";
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(pageLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE; // just to be sure it's not NULL
			sessBean.setTabName(tabName);
		} else {
			filter = sessBean.getHostFilter();
			_activeHost = sessBean.getActiveHost();
			backLink = sessBean.getBackLink();
			blockNetwork = sessBean.isBlockNetwork();
			searching = sessBean.isSearching();
			tabName = sessBean.getTabName();
			rowsNum = sessBean.getRowsNum();
			pageNumber = sessBean.getPageNumber();
			if (_activeHost != null) {
				searching = true;
				setBeans(true);
				try {
					detailHost = (NetworkMember) _activeHost.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
		 			logger.error("", e);
				}
			}
		}
	}

	public void reload() {
		try {
			List<NetworkMember> hosts = _itemSelection.getMultiSelection();
			if (hosts.size() == 0) {
				return;
			}

			String feLocation = prepareFeLocation(SettingsConstants.UPDATE_CACHE_WS_PORT);
			
			ObjectFactory of = new ObjectFactory();
			SyncronizeRqType syncronizeRqType = of.createSyncronizeRqType();
			List<EntityObjType> listEnityObjType = syncronizeRqType.getEntityObj();

			for (NetworkMember host : hosts) {
				EntityObjType entityObj = of.createEntityObjType();
				entityObj.setObjId(host.getId().toString());
				entityObj.setObjSeq(host.getSeqNum());
				listEnityObjType.add(entityObj);
			}
			syncronizeRqType.setEntityType(EntityNames.HOST);

			DataManagement_Service service = new DataManagement_Service();
			DataManagement port = service.getDataManagementSOAP();
			BindingProvider bp = (BindingProvider) port;
			Binding binding = bp.getBinding();
			@SuppressWarnings("rawtypes")
			List<Handler> soapHandlersList = new ArrayList<Handler>();
			SOAPLoggingHandler soapHandler = new SOAPLoggingHandler();
			soapHandler.setLogger(logger);
			soapHandlersList.add(soapHandler);
			binding.getHandlerChain();
			binding.setHandlerChain(soapHandlersList);
			
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

			for (int i = 0; i < hosts.size(); i++) {
				NetworkMember host = hosts.get(i);
				EntityObjStatusType objStatusType = objStatusTypes.get(i);
				host.setFerrNo(objStatusType.getFerrno());
			}
		} catch (Exception e) {
			FacesUtils.addSystemError(e);
			logger.error("", e);
		}
	}

	public DaoDataModel<NetworkMember> getHosts() {

		return _hostsSource;
	}

	public NetworkMember getActiveHost() {
		return _activeHost;
	}

	public void setActiveHost(NetworkMember activeHost) {
		_activeHost = activeHost;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeHost == null && _hostsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeHost != null && _hostsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeHost.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeHost = _itemSelection.getSingleSelection();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeHost.getId())) {
				changeSelect = true;
			}
			_activeHost = _itemSelection.getSingleSelection();
	
			if (_activeHost != null) {
				setBeans(false);
				if (changeSelect) {
					detailHost = (NetworkMember) _activeHost.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	/**
	 * Intended for selecting needed node from outside, because setter and
	 * getter for <code>_itemSelection</code> are too complicated for this.
	 * 
	 * @param nodeToSelect
	 *            - try to guess.
	 */
	public void setNodeSelected(NetworkMember nodeToSelect) {
		_itemSelection.clearSelection();
		SimpleSelection ss = new SimpleSelection();
		ss.addKey(nodeToSelect.getModelId());
		_itemSelection.setWrappedSelection(ss);

		_activeHost = nodeToSelect;
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_hostsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeHost = (NetworkMember) _hostsSource.getRowData();
		detailHost = (NetworkMember) _activeHost.clone();
		selection.addKey(_activeHost.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans(false);
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans(boolean restoreState) {
		MbConsumers consumers = (MbConsumers) ManagedBeanWrapper.getManagedBean("MbConsumers");
		consumers.setHost(_activeHost);
		consumers.setBackLink(pageLink);

		consumers.search();
		if (restoreState) {
			consumers.restoreBean();
		} else {
			sessBean.setActiveHost(_activeHost);
			sessBean.setHostSelection(_itemSelection.getWrappedSelection());
			sessBean.setBackLink(backLink);
			sessBean.setHostFilter(filter);
			sessBean.setBlockNetwork(blockNetwork);
			sessBean.setSearching(searching);
			sessBean.setHostsList(_hostsSource.getActivePage());
			sessBean.setPageNumber(pageNumber);
			sessBean.setRowsNum(rowsNum);
		}

		MbDesKeysBottom keys = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysBottom");
		keys.fullCleanBean();
		keys.getFilter().setEntityType(EntityNames.HOST);
		keys.getFilter().setObjectId(_activeHost.getId().longValue());
		keys.setStandardId(_activeHost.getOnlineStdId());
		keys.setInstId(_activeHost.getInstId());
		keys.search();

		MbNetworkDevicesSearch devices = (MbNetworkDevicesSearch) ManagedBeanWrapper
				.getManagedBean("MbNetworkDevicesSearch");
		devices.setHost(_activeHost);
		devices.setBackLink(pageLink);
		devices.search();

		MbIfConfig versions = (MbIfConfig) ManagedBeanWrapper.getManagedBean("MbIfConfig");
		versions.fullCleanBean();
		versions.setParamEntityType(EntityNames.HOST);
		versions.setParamObjectId(_activeHost.getId().longValue());
		versions.search();

		if (restoreState && (!consumers.isDirectAccess() || !devices.isDirectAccess())) {
			// if bean is restored from previous state we need to check if it was
			// loaded directly from menu or url or it was accessed from other page
			directAccess = false;
		}
	}
	
	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (getFilter().getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		if (getFilter().getHostName() != null && getFilter().getHostName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("hostName");
			paramFilter.setValue(filter.getHostName().trim().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (getFilter().getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		if (getFilter().getNetworkId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setValue(filter.getNetworkId().toString());
			filters.add(paramFilter);
		}
	}

	public void search() {
		curMode = VIEW_MODE;

		clearBean();
		searching = true;

	}

	public void clearFilter() {
		filter = new NetworkMember();
		clearBean();

		searching = false;
	}

	public void add() {
		newHost = new NetworkMember();
		newHost.setLang(userLang);
		curLang = newHost.getLang();
		if (getFilter().getNetworkId() != null) {
			newHost.setNetworkId(filter.getNetworkId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newHost = (NetworkMember) detailHost.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_networksDao.deleteHost(userSessionId, _activeHost);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "host_deleted",
					"(id = " + _activeHost.getId() + ")");

			_activeHost = _itemSelection.removeObjectFromList(_activeHost);
			if (_activeHost == null) {
				clearBean();
			} else {
				setBeans(false);
				detailHost = (NetworkMember) _activeHost.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public ArrayList<SelectItem> getParticipantTypes() {
		return getDictUtils().getArticles(DictNames.PARTY_TYPE, false);
	}

	public void save() {
		try {
			if (newHost.getOnlineStdId() == null && newHost.getOfflineStdId() == null) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
						"online_or_offline_standard_must_be_defined"));
			}

			if (isNewMode()) {
				newHost.setInstId(hostOwnersMap.get(newHost.getId()).getInstId());
				newHost.setSeqNum(hostOwnersMap.get(newHost.getId()).getSeqNum());
				newHost = _networksDao.addHost(userSessionId, newHost);
				detailHost = (NetworkMember) newHost.clone();
			} else {
				newHost = _networksDao.editHost(userSessionId, newHost);
				detailHost = (NetworkMember) newHost.clone();
				if (!userLang.equals(newHost.getLang())) {
					newHost = getNodeByLang(_activeHost.getId(), userLang);
				}
			}

			// after editing host can stop being a host and in this case it
			// should be deleted from list
			if (newHost == null) {
				_activeHost = _itemSelection.removeObjectFromList(_activeHost);
				if (_activeHost == null) {
					clearBean();
				} else {
					setBeans(false);
				}
			} else {
				if (isNewMode()) {
					_itemSelection.addNewObjectToList(newHost);
				} else {
					_hostsSource.replaceObject(_activeHost, newHost);
				}

				_activeHost = newHost;
				setBeans(false);
			}
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"host_saved"));
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public NetworkMember getNewHost() {
		if (newHost == null) {
			newHost = new NetworkMember();
		}
		return newHost;
	}

	public void setNewHost(NetworkMember newHost) {
		this.newHost = newHost;
	}

	public void clearBean() {
		_hostsSource.flushCache();
		_itemSelection.clearSelection();
		_activeHost = null;
		detailHost = null;
		clearBeanStates();
	}

	private void clearBeanStates() {
		MbConsumers consumers = (MbConsumers) ManagedBeanWrapper.getManagedBean("MbConsumers");
		consumers.fullCleanBean();

		MbDesKeysBottom keys = (MbDesKeysBottom) ManagedBeanWrapper.getManagedBean("MbDesKeysBottom");
		keys.fullCleanBean();

		MbNetworkDevicesSearch devices = (MbNetworkDevicesSearch) ManagedBeanWrapper
				.getManagedBean("MbNetworkDevicesSearch");
		devices.fullCleanBean();
	}

	public ArrayList<SelectItem> getHostOwners() {
		ArrayList<SelectItem> items = null;
		NetworkMember[] hostOwners = new NetworkMember[0];

		try {
			SelectionParams params = new SelectionParams();
			Filter paramFilter = null;
			List<Filter> filtersHostOwners = new ArrayList<Filter>();

			if (isViewMode()) {
				if (getFilter().getNetworkId() != null) {
					paramFilter = new Filter();
					paramFilter.setElement("networkId");
					paramFilter.setValue(getFilter().getNetworkId().toString());
					filtersHostOwners.add(paramFilter);
				}

				paramFilter = new Filter();
				paramFilter.setElement("usedOnly");
				paramFilter.setValue("true");
				filtersHostOwners.add(paramFilter);

				params.setFilters(filtersHostOwners.toArray(new Filter[filtersHostOwners.size()]));

				hostOwners = _networksDao.getHostOwners(userSessionId, params);
				items = new ArrayList<SelectItem>(hostOwners.length);

				for (NetworkMember host : hostOwners) {
					items.add(new SelectItem(host.getInstId(), host.getInstName()));
				}
			} else if (isNewMode()) {
				if (getNewHost().getNetworkId() != null) {

					paramFilter = new Filter();
					paramFilter.setElement("networkId");
					paramFilter.setValue(getNewHost().getNetworkId().toString());
					filtersHostOwners.add(paramFilter);

					paramFilter = new Filter();
					paramFilter.setElement("freeOnly");
					paramFilter.setValue("true");
					filtersHostOwners.add(paramFilter);

					params.setFilters(filtersHostOwners
							.toArray(new Filter[filtersHostOwners.size()]));

					hostOwners = _networksDao.getHostOwners(userSessionId, params);
				}
				items = new ArrayList<SelectItem>(hostOwners.length);
				hostOwnersMap = new HashMap<Integer, NetworkMember>(hostOwners.length);

				for (NetworkMember host : hostOwners) {
					hostOwnersMap.put(host.getId(), host);
					items.add(new SelectItem(host.getId(), host.getInstName()));
				}
			} else if (isEditMode()) {
				items = new ArrayList<SelectItem>(1);
				items.add(new SelectItem(newHost.getInstId(), newHost.getInstName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return items;
	}

	public boolean isDefaultInst() {
		return _activeHost.getInstId().equals(_activeHost.getNetworkInstId());
	}

	public NetworkMember getFilter() {
		if (filter == null) {
			filter = new NetworkMember();
		}
		return filter;
	}

	public void setFilter(NetworkMember filter) {
		this.filter = filter;
	}

	public ArrayList<SelectItem> getNetworks() {
		SelectionParams params = new SelectionParams();
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);
		params.setRowIndexEnd(-1);
		params.setFilters(filters);

		ArrayList<SelectItem> items = null;
		try {
			Network[] networks = _networksDao.getNetworks(userSessionId, params);
			items = new ArrayList<SelectItem>(networks.length);

			for (Network net : networks) {
				items.add(new SelectItem(net.getId(), net.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		if (items == null) {
			return new ArrayList<SelectItem>(0);
		}

		return items;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailHost = getNodeByLang(detailHost.getId(), curLang);
	}
	
	public NetworkMember getNodeByLang(Integer id, String lang) {
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
			NetworkMember[] hosts = _networksDao.getHosts(userSessionId, params);
			if (hosts != null && hosts.length > 0) {
				return hosts[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getOnlineStandards() {
		ArrayList<SelectItem> items;

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		List<Filter> filtersStd = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filtersStd.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("appPluginExists");
		paramFilter.setValue("true");
		filtersStd.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("standardType");
		paramFilter.setValue("STDT0001"); // only "Network communication standard" are applicable
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
		for (CmnStandard std : stds) {
			items.add(new SelectItem(std.getId(), std.getLabel() != null ? std.getLabel()
					: ("{ID = " + std.getId() + "}")));
		}

		return items;
	}

	public ArrayList<SelectItem> getOfflineStandards() {
		ArrayList<SelectItem> items;

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);

		List<Filter> filtersStd = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filtersStd.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("appPluginNotExists");
		paramFilter.setValue("true");
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
		for (CmnStandard std : stds) {
			items.add(new SelectItem(std.getId(), std.getLabel() != null ? std.getLabel()
					: ("{ID = " + std.getId() + "}")));
		}

		return items;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public String goBack() {
		removeLastPageFromRoute();
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);

		return backLink;
	}

	public boolean isBlockNetwork() {
		return blockNetwork;
	}

	public void setBlockNetwork(boolean blockNetwork) {
		this.blockNetwork = blockNetwork;
	}

	public String getPageName() {
		if (backLink != null)
			pageName = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "hosts");
		return pageName;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		sessBean.setTabName(tabName);
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("instsTab")) {
			MbConsumers bean = (MbConsumers) ManagedBeanWrapper
					.getManagedBean("MbConsumers");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("keysTab")) {
			MbDesKeysBottom bean = (MbDesKeysBottom) ManagedBeanWrapper
					.getManagedBean("MbDesKeysBottom");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("connectivityTab")) {
			MbNetworkDevicesSearch bean = (MbNetworkDevicesSearch) ManagedBeanWrapper
					.getManagedBean("MbNetworkDevicesSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.STRUCT_NET_HOST;
	}

	public void confirmEditLanguage() {
		curLang = newHost.getLang();
		NetworkMember tmp = getNodeByLang(newHost.getId(), newHost.getLang());
		if (tmp != null) {
			newHost.setHostName(tmp.getHostName());
		}
	}

	public List<NetworkMember> getSelectedItems() {
		return _itemSelection.getMultiSelection();
	}

//	private void handleResponse(int respCode) {
//		if (respCode != 1) {
//			String articleCode = String.valueOf(respCode);
//			for (int i = articleCode.length(); i <= DictNames.ARTICLE_CODE_LENGTH; i++) {
//				articleCode = "0" + articleCode;
//			}
//			FacesUtils.addMessageError(new Exception(getDictUtils().getAllArticlesDescByLang().get(
//					curLang).get(DictNames.RESPONSE_CODE + articleCode)));
//		}
//	}
//
//	public void mcActivateHost() {
//		MbPCtlPeerMasterCardWS mcBean = (MbPCtlPeerMasterCardWS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerMasterCardWS");
//
//		int respCode;
//		try {
//			respCode = mcBean.activateHost(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void mcDeactivateHost() {
//		MbPCtlPeerMasterCardWS mcBean = (MbPCtlPeerMasterCardWS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerMasterCardWS");
//
//		int respCode;
//		try {
//			respCode = mcBean.deactivateHost(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void mcSignOn() {
//		MbPCtlPeerMasterCardWS mcBean = (MbPCtlPeerMasterCardWS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerMasterCardWS");
//
//		int respCode;
//		try {
//			respCode = mcBean.signOn(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void mcSignOff() {
//		MbPCtlPeerMasterCardWS mcBean = (MbPCtlPeerMasterCardWS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerMasterCardWS");
//
//		int respCode;
//		try {
//			respCode = mcBean.signOff(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void mcConnectionStatus() {
//		MbPCtlPeerMasterCardWS mcBean = (MbPCtlPeerMasterCardWS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerMasterCardWS");
//
//		int respCode;
//		try {
//			respCode = mcBean.connectionStatus(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
	
	public boolean isMasterCard() {
		if (_activeHost == null) {
			return false;
		}
		return CommunicationConstants.MASTER_CARD_APP_PLUGIN.equals(_activeHost.getOnlineAppPlugin());
	}

	public boolean isVisaBase1() {
		if (_activeHost == null) {
			return false;
		}
		return CommunicationConstants.VISA_BASE1_APP_PLUGIN.equals(_activeHost.getOnlineAppPlugin());
	}
	
	public boolean isVisaSms() {
		if (_activeHost == null) {
			return false;
		}
		return CommunicationConstants.VISA_SMS_APP_PLAGIN.equals(_activeHost.getOnlineAppPlugin());
	}

	public boolean isWay4() {
		if (_activeHost == null) {
			return false;
		}
		return CommunicationConstants.WAY4_APP_PLUGIN.equals(_activeHost.getOnlineAppPlugin());
	}

//	public void vb1EchoTest() {
//		MbPCtlPeerVisaBase1WS vb1Bean = (MbPCtlPeerVisaBase1WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerVisaBase1WS");
//
//		int respCode;
//		try {
//			respCode = vb1Bean.echoTest(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void vb1SignOn() {
//		MbPCtlPeerVisaBase1WS vb1Bean = (MbPCtlPeerVisaBase1WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerVisaBase1WS");
//
//		int respCode;
//		try {
//			respCode = vb1Bean.signOn(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void vb1SignOff() {
//		MbPCtlPeerVisaBase1WS vb1Bean = (MbPCtlPeerVisaBase1WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerVisaBase1WS");
//
//		int respCode;
//		try {
//			respCode = vb1Bean.signOff(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void vb1StartAdvicesTrms() {
//		MbPCtlPeerVisaBase1WS vb1Bean = (MbPCtlPeerVisaBase1WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerVisaBase1WS");
//
//		int respCode;
//		try {
//			respCode = vb1Bean.startAdvicesTrms(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void vb1StopAdvicesTrms() {
//		MbPCtlPeerVisaBase1WS vb1Bean = (MbPCtlPeerVisaBase1WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerVisaBase1WS");
//
//		int respCode;
//		try {
//			respCode = vb1Bean.stopAdvicesTrms(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void way4EchoTest() {
//		MbPCtlPeerWay4WS way4Bean = (MbPCtlPeerWay4WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerWay4WS");
//
//		int respCode;
//		try {
//			respCode = way4Bean.echoTest(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void way4SignIn() {
//		MbPCtlPeerWay4WS way4Bean = (MbPCtlPeerWay4WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerWay4WS");
//
//		int respCode;
//		try {
//			respCode = way4Bean.signIn(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}
//
//	public void way4SignOff() {
//		MbPCtlPeerWay4WS way4Bean = (MbPCtlPeerWay4WS) ManagedBeanWrapper
//				.getManagedBean("MbPCtlPeerWay4WS");
//
//		int respCode;
//		try {
//			respCode = way4Bean.signOff(_activeHost.getId()); // 1 - good
//		} catch (Exception e) {
//			logger.error("", e);
//			FacesUtils.addMessageError(e);
//			return;
//		}
//
//		handleResponse(respCode);
//	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.HOST_STATUS);
	}

	public NetworkMember getDetailHost() {
		return detailHost;
	}

	public void setDetailHost(NetworkMember detailHost) {
		this.detailHost = detailHost;
	}
	
	public boolean isUseHsm(){
		if (useHsm == null) {
			Double value = settingsDao.getParameterValueN(null,
				SettingsConstants.USE_HSM, LevelNames.SYSTEM, null);
			useHsm = (value == 1);
		}
		return useHsm;
	}
	
}

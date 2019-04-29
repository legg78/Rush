package ru.bpc.sv2.ui.network;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.net.NetworkMember;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbNetworkMembers")
public class MbNetworkMembers extends AbstractBean {
	private static final long serialVersionUID = 4400365827075428391L;

	private static final Logger logger = Logger.getLogger("NETWORKS");

	private NetworkDao _networkDao = new NetworkDao();
	private CommunicationDao _cmnDao = new CommunicationDao();

	private NetworkMember filter;
	private NetworkMember newMember;
	private Integer networkId;
	private Integer instNetworkId;
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<NetworkMember> _membersSource;
	private final TableRowSelection<NetworkMember> _itemSelection;
	private NetworkMember _activeMember;
	private MbNetworksSess sessBean;
	private String backLink;

	private boolean showNetworks;

	private static String COMPONENT_ID = "membersTable";
	private String tabName;
	private String parentSectionId;
	private Boolean likeHost;
	private NetworkMember newHost;
	private HashMap<Integer, NetworkMember> hostOwnersMap;
	private HashMap<Integer, Integer> instOwnersMap;
	private String privilege;

	public MbNetworkMembers() {
		sessBean = (MbNetworksSess) ManagedBeanWrapper.getManagedBean("MbNetworksSess");

		_membersSource = new DaoDataModel<NetworkMember>() {
			private static final long serialVersionUID = 1614742347825999075L;

			@Override
			protected NetworkMember[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NetworkMember[0];
				}
				try {
					setFilters();
					params.setPrivilege(privilege);
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networkDao.getNetworkMembers(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NetworkMember[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setPrivilege(privilege);
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networkDao.getNetworkMembersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NetworkMember>(null, _membersSource);
	}

	public DaoDataModel<NetworkMember> getMembers() {
		return _membersSource;
	}

	public NetworkMember getActiveMember() {
		return _activeMember;
	}

	public void setActiveMember(NetworkMember activeMember) {
		_activeMember = activeMember;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMember = _itemSelection.getSingleSelection();
	}

	public void search() {
		searching = true;
	}

	public void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (networkId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setValue(networkId);
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		likeHost = false;
		newMember = new NetworkMember();
		newMember.setNetworkId(networkId);
		newMember.setInstId(filter.getInstId());
		newMember.setLang(userLang);
		newMember.setNetworkId(networkId);
		newHost = new NetworkMember();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newMember = (NetworkMember) _activeMember.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newMember = _activeMember;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			if (_activeMember.getNetworkId().equals(instNetworkId)){
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "default_network_cannot_be_deleted", filter.getInstId().toString());
				FacesUtils.addMessageError(msg);
				return;
			}
			_networkDao.deleteNetworkMember(userSessionId, _activeMember);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "member_deleted",
					"(id = " + _activeMember.getId() + ")");

			_activeMember = _itemSelection.removeObjectFromList(_activeMember);
			if (_activeMember == null) {
				clearBean();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (likeHost){
				if (newMember.getOnlineStdId() == null && newMember.getOfflineStdId() == null) {
					throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
							"online_or_offline_standard_must_be_defined"));
				}
				if (isNewMode()) {
					if (!showNetworks){
						getHostOwners();
						newMember.setId(instOwnersMap.get(newMember.getInstId()));
					}
					newMember = _networkDao.addHost(userSessionId, newMember);
					_itemSelection.addNewObjectToList(newMember);
				}
			} else{
				if (isNewMode()) {
					newMember = _networkDao.addNetworkMember(userSessionId, newMember);
					_itemSelection.addNewObjectToList(newMember);
				} else {
					// _networkDao.editNetworkMember( userSessionId, newMember);
				}

				_activeMember = newMember;
				curMode = VIEW_MODE;

				FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
						"member_added"));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public NetworkMember getNewMember() {
		if (newMember == null) {
			newMember = new NetworkMember();
		}
		return newMember;
	}

	public void setNewMember(NetworkMember newMember) {
		this.newMember = newMember;
	}

	public void fullCleanBean() {
		networkId = null;
		instNetworkId = null;
		filter = null;
		clearBean();
		searching = false;
	}

	public void clearBean() {
		_membersSource.flushCache();
		_itemSelection.clearSelection();
		_activeMember = null;
	}

	public Integer getNetworkId() {
		return networkId;
	}

	public void setNetworkId(Integer networkId) {
		this.networkId = networkId;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public String gotoHosts() {
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		menu.setKeepState(true);
		menu.externalSelect("net|hosts");
		MbHosts hosts = (MbHosts) ManagedBeanWrapper.getManagedBean("MbHosts");
		hosts.setBackLink(backLink);
		hosts.getFilter().setNetworkId(networkId);
		hosts.setBlockNetwork(true);

		// add bread crumbs, prevent menu selection
		hosts.setDirectAccess(false);
		hosts.setPreviousPageName(pageName);

		if (_activeMember != null
				&& (_activeMember.getOnlineStdId() != null || _activeMember.getOfflineStdId() != null)) {
			hosts.getFilter().setInstId(_activeMember.getInstId());

			// hosts.setNodeSelected(_activeMember);
		}
		hosts.search();

		sessBean.setActiveMember(_activeMember);
		sessBean.setMemberSelection(_itemSelection.getWrappedSelection());

		return "hosts";
	}

	public Integer getInstNetworkId() {
		return instNetworkId;
	}

	public void setInstNetrowkId(Integer instNetworkId) {
		this.instNetworkId = instNetworkId;
	}

	public void restoreBean() {
		_activeMember = sessBean.getActiveMember();
		if (sessBean.getMemberSelection() != null) {
			_itemSelection.setWrappedSelection(sessBean.getMemberSelection());
		}
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
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

	public boolean isShowNetworks() {
		return showNetworks;
	}

	public void setShowNetworks(boolean showNetworks) {
		this.showNetworks = showNetworks;
	}

	public ArrayList<SelectItem> getNetworks() {
		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter filter = new Filter();
		filter.setElement("lang");
		filter.setValue(userLang);
		filters.add(filter);
		if (getFilter().getInstId() != null) {
			filter = new Filter();
			filter.setElement("excInstId");
			filter.setValue(getFilter().getInstId());
			filters.add(filter);
		}

		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			Network[] networks = _networkDao.getNetworks(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(networks.length);
			for (Network network: networks) {
				items.add(new SelectItem(network.getId(), network.getName()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return new ArrayList<SelectItem>(0);
	}

	public ArrayList<SelectItem> getParticipantTypes() {
		return getDictUtils().getArticles(DictNames.PARTY_TYPE, false);
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

	public Boolean getLikeHost() {
		return likeHost;
	}

	public void setLikeHost(Boolean likeHost) {
		this.likeHost = likeHost;
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

				hostOwners = _networkDao.getHostOwners(userSessionId, params);
				items = new ArrayList<SelectItem>(hostOwners.length);

				for (NetworkMember host : hostOwners) {
					items.add(new SelectItem(host.getInstId(), host.getInstName()));
				}
			} else if (isNewMode()) {
				if (getNewMember().getNetworkId() != null) {

					paramFilter = new Filter();
					paramFilter.setElement("networkId");
					paramFilter.setValue(getNewMember().getNetworkId().toString());
					filtersHostOwners.add(paramFilter);

					paramFilter = new Filter();
					paramFilter.setElement("freeOnly");
					paramFilter.setValue("true");
					filtersHostOwners.add(paramFilter);

					params.setFilters(filtersHostOwners
							.toArray(new Filter[filtersHostOwners.size()]));

					hostOwners = _networkDao.getHostOwners(userSessionId, params);
				}
				items = new ArrayList<SelectItem>(hostOwners.length);
				hostOwnersMap = new HashMap<Integer, NetworkMember>(hostOwners.length);
				instOwnersMap = new HashMap<Integer, Integer>(hostOwners.length);

				for (NetworkMember host : hostOwners) {
					hostOwnersMap.put(host.getId(), host);
					instOwnersMap.put(host.getInstId(), host.getId());
					items.add(new SelectItem(host.getId(), host.getInstName()));
				}
			} else if (isEditMode()) {
				items = new ArrayList<SelectItem>(1);
				items.add(new SelectItem(newMember.getInstId(), newMember.getInstName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return items;
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

	public List<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.HOST_STATUS);
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}
}

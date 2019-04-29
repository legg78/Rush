package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.common.FlexFieldData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.ui.common.flexible.MbFlexFieldsDataSearch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbNetworks")
public class MbNetworks extends AbstractBean {
	private static final long serialVersionUID = -6076742806121579422L;

	private static final Logger logger = Logger.getLogger("NETWORKS");

	private static String COMPONENT_ID = "1231:networksTable";

	private NetworkDao _networksDao = new NetworkDao();

	private CommunicationDao _cmnDao = new CommunicationDao();
	
	private ArrayList<SelectItem> institutions;

	private String tabName;
	
	private Network filter;
	private Network _activeNetwork;
	private Network newNetwork;
	private Network detailNetwork;
	private MbNetworksSess sessBean;

	private final DaoDataModel<Network> _networkSource;

	private final TableRowSelection<Network> _itemSelection;

	public MbNetworks() {
		pageLink = "net|networks";
//		thisBackLink = "net|networks";
		
		sessBean = (MbNetworksSess) ManagedBeanWrapper.getManagedBean("MbNetworksSess");
		tabName = "detailsTab";
		
		_networkSource = new DaoDataModel<Network>() {
			private static final long serialVersionUID = -560233456862632673L;

			@Override
			protected Network[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Network[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getNetworks(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Network[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getNetworksCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		restoreBean = (Boolean) FacesUtils.getSessionMapValue(pageLink);
		if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;	// just to be sure it's not NULL
			
			// if user came here from menu, we don't need to select previously
			// selected tab
			clearBeansStates();
			_itemSelection = new TableRowSelection<Network>(null, _networkSource);
		} else {
			filter = sessBean.getNetworkFilter();
			_activeNetwork = sessBean.getActiveNetwork();
			_itemSelection = new TableRowSelection<Network>(sessBean.getNetworkSelection(),
					_networkSource);
			tabName = sessBean.getNetworkTab();
			pageNumber = sessBean.getPageNumber();
			rowsNum = sessBean.getRowsNum();
			FacesUtils.setSessionMapValue(pageLink, Boolean.FALSE);
			
			if (_activeNetwork != null) {
				searching = true;
				setBeans(true);
				try {
					detailNetwork = (Network) _activeNetwork.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
		}

	}

	public DaoDataModel<Network> getNetworks() {
		return _networkSource;
	}

	public Network getActiveNetwork() {
//		log(_activeNetwork);
		return _activeNetwork;
	}

	public void setActiveNetwork(Network activeNetwork) {
		_activeNetwork = activeNetwork;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeNetwork == null && _networkSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeNetwork != null && _networkSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeNetwork.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeNetwork = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
//		log(_itemSelection.getWrappedSelection());
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeNetwork.getId())) {
				changeSelect = true;
			}
			_activeNetwork = _itemSelection.getSingleSelection();
	
			if (_activeNetwork != null) {
				setBeans(false);
				if (changeSelect) {
					detailNetwork = (Network) _activeNetwork.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_networkSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeNetwork = (Network) _networkSource.getRowData();
		selection.addKey(_activeNetwork.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeNetwork != null) {
			setBeans(false);
			detailNetwork = (Network) _activeNetwork.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans(boolean restoreState) {
		MbNetworkMembers members = (MbNetworkMembers) ManagedBeanWrapper
				.getManagedBean("MbNetworkMembers");
		members.clearBean();
		members.setNetworkId(_activeNetwork.getId());
		members.setBackLink(pageLink);
		members.setShowNetworks(false);
		members.search();
		
		
		if (restoreState) {
			members.restoreBean();
		} else {
			sessBean = (MbNetworksSess) ManagedBeanWrapper.getManagedBean("MbNetworksSess");
			sessBean.setActiveNetwork(_activeNetwork);
			sessBean.setNetworkFilter(filter);
			sessBean.setNetworkSelection(_itemSelection.getWrappedSelection());
			sessBean.setPageNumber(pageNumber);
			sessBean.setRowsNum(rowsNum);
		}
		
		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
		FlexFieldData filterFlex = new FlexFieldData();
		filterFlex.setInstId(_activeNetwork.getInstId());
		filterFlex.setEntityType(EntityNames.NETWORK);
		filterFlex.setObjectId(_activeNetwork.getId().longValue());
		flexible.setFilter(filterFlex);
		flexible.search();
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
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
			paramFilter.setValue(filter.getName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public Network getFilter() {
		if (filter == null) {
			filter = new Network();
			filter.setInstId(userInstId);
		}
//		log(networkFilter);
		return filter;
	}

	public void setFilter(Network filter) {
		this.filter = filter;
	}

	public void add() {
		newNetwork = new Network();
		newNetwork.setInstId(filter.getInstId());
		newNetwork.setLang(userLang);
		curLang = newNetwork.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newNetwork = detailNetwork.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newNetwork = _activeNetwork;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newNetwork = _networksDao.editNetwork(userSessionId, newNetwork);
				detailNetwork = (Network) newNetwork.clone();
				if (!userLang.equals(newNetwork.getLang())) {
					newNetwork = getNodeByLang(_activeNetwork.getId(), userLang);
				}
				_networkSource.replaceObject(_activeNetwork, newNetwork);
			} else if (isNewMode()) {
				newNetwork = _networksDao.addNetwork(userSessionId, newNetwork);
				detailNetwork = (Network) newNetwork.clone();
				_itemSelection.addNewObjectToList(newNetwork);
			}

			_activeNetwork = newNetwork;
			setBeans(false);
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"network_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networksDao.deleteNetwork(userSessionId, _activeNetwork);
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"network_deleted", "(ID = " + _activeNetwork.getId() + ")"));

			_activeNetwork = _itemSelection.removeObjectFromList(_activeNetwork);
			if (_activeNetwork == null) {
				clearBean();
			} else {
				setBeans(false);
				detailNetwork = (Network) _activeNetwork.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;

	}

	public Network getNewNetwork() {
		if (newNetwork == null) {
			newNetwork = new Network();
		}
//		log(newNetwork);
		return newNetwork;
	}

	public void setNewNetwork(Network newNetwork) {
		this.newNetwork = newNetwork;
	}

	public void setRowsNum(int rowsNum) {
		sessBean.setRowsNum(rowsNum);
		this.rowsNum = rowsNum;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeNetwork = null;
		detailNetwork = null;
		_networkSource.flushCache();

		clearBeansStates();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public void clearInst(){
		institutions = null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailNetwork = getNodeByLang(detailNetwork.getId(), curLang);
	}
	
	public Network getNodeByLang(Integer id, String lang) {
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
			Network[] nets = _networksDao.getNetworks(userSessionId, params);
			if (nets != null && nets.length > 0) {
				return nets[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
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

//		log(items);
		return items;
	}

	public String getTabName() {
//		log(tabName);
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		sessBean.setNetworkTab(tabName);
		
		if (tabName.equalsIgnoreCase("membersTab")) {
			MbNetworkMembers bean = (MbNetworkMembers) ManagedBeanWrapper
					.getManagedBean("MbNetworkMembers");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("flexibleFieldsTab")) {
			MbFlexFieldsDataSearch bean = (MbFlexFieldsDataSearch) ManagedBeanWrapper
					.getManagedBean("MbFlexFieldsDataSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.STRUCT_NET_NET;
	}

	public void clearBeansStates() {
		MbNetworkMembers members = (MbNetworkMembers) ManagedBeanWrapper
				.getManagedBean("MbNetworkMembers");
		members.fullCleanBean();
		
		MbFlexFieldsDataSearch flexible = (MbFlexFieldsDataSearch) ManagedBeanWrapper
				.getManagedBean("MbFlexFieldsDataSearch");
		flexible.clearFilter();
	}

	public void setPageNumber(int pageNumber) {
		sessBean.setPageNumber(pageNumber);
		this.pageNumber = pageNumber;
	}
	
	public void confirmEditLanguage() {
		curLang = newNetwork.getLang();
		Network tmp = getNodeByLang(newNetwork.getId(), newNetwork.getLang());
		if (tmp != null) {
			newNetwork.setName(tmp.getName());
			newNetwork.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Network getDetailNetwork() {
		return detailNetwork;
	}

	public void setDetailNetwork(Network detailNetwork) {
		this.detailNetwork = detailNetwork;
	}
	
	public void activate(){
		MbNetworkMembers members = (MbNetworkMembers) ManagedBeanWrapper
				.getManagedBean("MbNetworkMembers");
		members.setShowNetworks(false);
	}

}

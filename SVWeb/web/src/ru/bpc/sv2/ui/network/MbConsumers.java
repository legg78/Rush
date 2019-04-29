package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.Consumer;
import ru.bpc.sv2.net.NetworkMember;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbConsumers")
public class MbConsumers extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("NETWORKS");

	private NetworkDao _networksDao = new NetworkDao();

	private Consumer newConsumer;
	private NetworkMember host;

	private String backLink;
	
	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<Consumer> _consumersSource;
	private final TableRowSelection<Consumer> _itemSelection;
	private Consumer _activeConsumer;

	private MbHostsSess sessBean;
	
	private static String COMPONENT_ID = "consumersTable";
	private String tabName;
	private String parentSectionId;

	public MbConsumers() {
		sessBean = (MbHostsSess) ManagedBeanWrapper.getManagedBean("MbHostsSess");

		_consumersSource = new DaoDataModel<Consumer>() {
			private static final long serialVersionUID = 1L;
			
			@Override
			protected Consumer[] loadDaoData(SelectionParams params) {
				if (host == null) {
					return new Consumer[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getConsumers(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Consumer[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (host == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getConsumersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Consumer>(null, _consumersSource);
	}

	public DaoDataModel<Consumer> getConsumers() {
		return _consumersSource;
	}

	public Consumer getActiveConsumer() {
		return _activeConsumer;
	}

	public void setActiveConsumer(Consumer activeConsumer) {
		_activeConsumer = activeConsumer;
	}

	public SimpleSelection getItemSelection() {
		if (_activeConsumer == null && _consumersSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeConsumer != null && _consumersSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeConsumer.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeConsumer = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_consumersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeConsumer = (Consumer) _consumersSource.getRowData();
		selection.addKey(_activeConsumer.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeConsumer = _itemSelection.getSingleSelection();
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

	public void search() {
		clearState();
	}

	public void add() {
		newConsumer = new Consumer();
		newConsumer.setHostMemberId(host.getId());
		newConsumer.setLang(curLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newConsumer = (Consumer) _activeConsumer.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newConsumer = _activeConsumer;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_networksDao.deleteConsumer(userSessionId, _activeConsumer);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "consumer_deleted",
					"(id = " + _activeConsumer.getId() + ")");

			_activeConsumer = _itemSelection.removeObjectFromList(_activeConsumer);
			if (_activeConsumer == null) {
				clearState();
			}
			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newConsumer = _networksDao.addConsumer(userSessionId, newConsumer);
				_itemSelection.addNewObjectToList(newConsumer);
			} else {
				newConsumer = _networksDao.editConsumer(userSessionId, newConsumer);
				_consumersSource.replaceObject(_activeConsumer, newConsumer);
			}
			_activeConsumer = newConsumer;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net",
					"consumer_added"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public Consumer getNewConsumer() {
		if (newConsumer == null) {
			newConsumer = new Consumer();
		}
		return newConsumer;
	}

	public void setNewConsumer(Consumer newConsumer) {
		this.newConsumer = newConsumer;
	}

	public void clearState() {
		_consumersSource.flushCache();
		_itemSelection.clearSelection();
		_activeConsumer = null;
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
		
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();		
		queueFilter.put("valuesObjectId", _activeConsumer.getId().longValue());
		queueFilter.put("valuesEntityType", EntityNames.NETWORK_INTERFACE);
		queueFilter.put("paramObjectId", _activeConsumer.getHostMemberId().longValue());
		queueFilter.put("paramEntityType", EntityNames.HOST);
		queueFilter.put("pageTitle", FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "if_config_title",
									FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "host"), host.getId(), host.getInstName(),
									FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common","institution"),
									_activeConsumer.getId(), _activeConsumer.getConsumerInstName()));
		queueFilter.put("backLink", backLink);
		queueFilter.put("directAccess", "false");
		
		addFilterToQueue("MbIfConfig", queueFilter);

		sessBean.setActiveConsumer(_activeConsumer);
		sessBean.setConsumerSelection(_itemSelection.getWrappedSelection());
		
		return "ifConfig";
	}

	public void restoreBean() {
		_activeConsumer = sessBean.getActiveConsumer();
		if (sessBean.getConsumerSelection() != null) {
			_itemSelection.setWrappedSelection(sessBean.getConsumerSelection());
		}
	}

	public ArrayList<SelectItem> getHostOwnersForConsumer() {
		ArrayList<SelectItem> items = null;
		NetworkMember[] hostOwners = new NetworkMember[0];
		if (host == null)
			return new ArrayList<SelectItem>();

		if (isEditMode()) {
			items = new ArrayList<SelectItem>(1);
			items.add(new SelectItem(_activeConsumer.getConsumerInstId(), _activeConsumer
					.getConsumerInstName()));
			return items;
		}

		try {
			SelectionParams params = new SelectionParams();
			Filter paramFilter = null;
			List<Filter> filtersHostOwners = new ArrayList<Filter>();

			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setValue(host.getNetworkId().toString());
			filtersHostOwners.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("exclusiveHostId");
			paramFilter.setValue(host.getId().toString());
			filtersHostOwners.add(paramFilter);

			params.setFilters(filtersHostOwners.toArray(new Filter[filtersHostOwners.size()]));
			hostOwners = _networksDao.getHostOwners(userSessionId, params);
			items = new ArrayList<SelectItem>(hostOwners.length + 1);

			items.add(new SelectItem(""));
			for (NetworkMember host : hostOwners) {
				items.add(new SelectItem(host.getId(), host.getInstName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}

		return items;
	}

	public ArrayList<SelectItem> getHostOwnersForMsp() {
		ArrayList<SelectItem> items = null;
		NetworkMember[] hostOwners = new NetworkMember[0];
		if (host == null)
			return new ArrayList<SelectItem>();

		try {
			SelectionParams params = new SelectionParams();
			Filter paramFilter = null;
			List<Filter> filtersHostOwners = new ArrayList<Filter>();

			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setValue(host.getNetworkId().toString());
			filtersHostOwners.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("inclusiveHostId");
			paramFilter.setValue(host.getId().toString());
			filtersHostOwners.add(paramFilter);

			params.setFilters(filtersHostOwners.toArray(new Filter[filtersHostOwners.size()]));
			hostOwners = _networksDao.getHostOwners(userSessionId, params);
			items = new ArrayList<SelectItem>(hostOwners.length);

			for (NetworkMember host : hostOwners) {
				if (host.getId().equals(newConsumer.getConsumerMemberId())) continue;
				items.add(new SelectItem(host.getId(), host.getInstName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}

		return items;
	}

	public boolean isMsp() {
		if (newConsumer != null && newConsumer.getConsumerMemberId() != null) {
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("hostMemberId");
			filters[0].setValue(host.getId());
			filters[1] = new Filter();
			filters[1].setElement("mspMemberId");
			filters[1].setValue(newConsumer.getConsumerMemberId());
			filters[2] = new Filter();
			filters[2].setElement("lang");
			filters[2].setValue(userLang);
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);
			
			try {
				Consumer[] msps = _networksDao.getConsumers(userSessionId, params);
				if (msps.length > 0) {
					return true;
				}
			} catch (Exception e) {
				logger.error("", e);
				FacesUtils.addMessageError(e);
			}
		}
		return false;
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

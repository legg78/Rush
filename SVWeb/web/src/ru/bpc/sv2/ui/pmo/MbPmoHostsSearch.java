package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.pmo.PmoHost;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

/**
 * Manage Bean for List PMO Hosts bottom tab.
 */
@RequestScoped
@KeepAlive
@ManagedBean (name = "MbPmoHostsSearch")
public class MbPmoHostsSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private RulesDao _rulesDao = new RulesDao();

	private PmoHost _activeHost;
	private PmoHost newHost;

	private PmoHost hostFilter;
	private List<Filter> hostFilters;

	private boolean selectMode;

	private final DaoDataModel<PmoHost> _hostsSource;

	private final TableRowSelection<PmoHost> _hostSelection;

	private List<SelectItem> executionTypeForCombo;
	private List<SelectItem> modForCombo;
	
	private static String COMPONENT_ID = "bottomHostsTable";
	private String tabName;
	private String parentSectionId;

	public MbPmoHostsSearch() {
		_hostsSource = new DaoDataModel<PmoHost>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected PmoHost[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PmoHost[0];
				try {
					setHostsFilters();
					params.setFilters(hostFilters.toArray(new Filter[hostFilters.size()]));
					return _paymentOrdersDao.getHosts(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PmoHost[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setHostsFilters();
					params.setFilters(hostFilters.toArray(new Filter[hostFilters.size()]));
					return _paymentOrdersDao.getHostsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_hostSelection = new TableRowSelection<PmoHost>(null, _hostsSource);
	}

	public DaoDataModel<PmoHost> getHosts() {
		return _hostsSource;
	}

	public PmoHost getActiveHost() {
		return _activeHost;
	}

	public void setActiveHost(PmoHost activeHost) {
		this._activeHost = activeHost;
	}

	public SimpleSelection getHostSelection() {
		if (_activeHost == null && _hostsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeHost != null && _hostsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeHost.getModelId());
			_hostSelection.setWrappedSelection(selection);
			_activeHost = _hostSelection.getSingleSelection();
		}
		return _hostSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_hostsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeHost = (PmoHost) _hostsSource.getRowData();
		selection.addKey(_activeHost.getModelId());
		_hostSelection.setWrappedSelection(selection);
		if (_activeHost != null) {
			setInfo();
		}
	}

	public void setInfo() {

	}

	public void setHostSelection(SimpleSelection selection) {
		_hostSelection.setWrappedSelection(selection);
		_activeHost = _hostSelection.getSingleSelection();
		if (_activeHost != null) {
			setInfo();
		}
	}

	public void search() {
		clearBean();
		boolean found = false;
		if (getHostFilter().getProviderId() != null) {
			found = true;
		}
		// if no selected providers found then we must not search for purposes
		// at all
		if (found) {
			searching = true;
		}
	}

	public void clearFilter() {
		hostFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_hostsSource.flushCache();
		if (_hostSelection != null) {
			_hostSelection.clearSelection();
		}
		_activeHost = null;
	}

	public void setHostsFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getHostFilter().getProviderId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("providerId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getHostFilter().getProviderId());
			filtersList.add(paramFilter);
		}

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
		hostFilters = filtersList;
	}

	public PmoHost getHostFilter() {
		if (hostFilter == null)
			hostFilter = new PmoHost();
		return hostFilter;
	}

	public void setHostFilter(PmoHost hostFilter) {
		this.hostFilter = hostFilter;
	}

	public List<Filter> getHostFilters() {
		return hostFilters;
	}

	public void setHostFilters(List<Filter> hostFilters) {
		this.hostFilters = hostFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoHost getNewHost() {
		return newHost;
	}

	public void setNewHost(PmoHost newHost) {
		this.newHost = newHost;
	}

	public void add() {
		newHost = new PmoHost();
		// set information about provider.
		newHost.setProviderId(getHostFilter().getProviderId());
		newHost.setProviderName(getHostFilter().getProviderName());
		newHost.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newHost = (PmoHost) _activeHost.clone();
			// newHost.setProviderName(getHostFilter().getProviderName());
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newHost = _activeHost;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {

			if (isEditMode()) {
				newHost = _paymentOrdersDao.editHost(userSessionId, newHost);
				_hostsSource.replaceObject(_activeHost, newHost);
			} else {
				// newHost.setProviderId(getHostFilter().getProviderId());
				newHost = _paymentOrdersDao.addHost(userSessionId, newHost);
				_hostSelection.addNewObjectToList(newHost);
			}
			_activeHost = newHost;

			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_paymentOrdersDao.removeHost(userSessionId, _activeHost);
			FacesUtils.addMessageInfo("Host (id = " + _activeHost.getHostId() + ") has been deleted.");

			_activeHost = _hostSelection.removeObjectFromList(_activeHost);
			if (_activeHost == null) {
				clearBean();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {

	}

	public List<SelectItem> getHostsForCombo() {
		return getDictUtils().getLov(LovConstants.PMO_LOCAL_NETWORK_HOST);
	}

	public List<SelectItem> getStatusForCombo() {
		return getDictUtils().getLov(LovConstants.PMO_STATUS_NETWORK_HOST);
	}

	public List<SelectItem> getExecutionTypeForCombo() {
		if (executionTypeForCombo == null) {
			executionTypeForCombo = getDictUtils().getArticles(DictNames.PMO_EXECUTION_TYPE, true);
		}
		return executionTypeForCombo;
	}

	public List<SelectItem> getModForCombo() {
		if (modForCombo == null) {
			modForCombo = getModifiers();
		}
		return modForCombo;
	}

	private List<SelectItem> getModifiers() {
		ArrayList<SelectItem> items;
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			Modifier[] mods = _rulesDao.getModifiers(userSessionId, params);

			items = new ArrayList<SelectItem>();
			for (Modifier mod : mods) {
				items.add(new SelectItem(mod.getId(), mod.getId() + " - " + mod.getName()));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			items = new ArrayList<SelectItem>(0);
		}
		return items;
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

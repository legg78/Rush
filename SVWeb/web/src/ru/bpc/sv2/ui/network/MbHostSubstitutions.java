package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.HostSubstitution;
import ru.bpc.sv2.net.NetworkMember;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import static ru.bpc.sv2.logic.controller.LovController.getLov;

@ViewScoped
@ManagedBean (name = "MbHostSubstitutions")
public class MbHostSubstitutions extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("NETWORKS");

	private static String COMPONENT_ID = "1231:networksTable"; // TODO: change to actual value

	private NetworkDao _networksDao = new NetworkDao();

	private CommunicationDao _cmnDao = new CommunicationDao();

	private ArrayList<SelectItem> institutions;

	private String tabName;

	private HostSubstitution filter;
	private HostSubstitution _activeHostSubstitution;
	private HostSubstitution newHostSubstitution;
	private HostSubstitution detailHostSubstitution;

	private final DaoDataModel<HostSubstitution> _substitutionsSource;

	private final TableRowSelection<HostSubstitution> _itemSelection;

	public MbHostSubstitutions() {
		pageLink = "net|hostSubstitutions";
		thisBackLink = "net|networks";
		tabName = "detailsTab";

		_substitutionsSource = new DaoDataModel<HostSubstitution>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected HostSubstitution[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new HostSubstitution[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getHostSubstitutions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new HostSubstitution[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getHostSubstitutionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<HostSubstitution>(null, _substitutionsSource);
	}

	public DaoDataModel<HostSubstitution> getHostSubstitutions() {
		return _substitutionsSource;
	}

	public HostSubstitution getActiveHostSubstitution() {
		return _activeHostSubstitution;
	}

	public void setActiveHostSubstitution(HostSubstitution activeHostSubstitution) {
		_activeHostSubstitution = activeHostSubstitution;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeHostSubstitution == null && _substitutionsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeHostSubstitution != null && _substitutionsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeHostSubstitution.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeHostSubstitution = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeHostSubstitution.getId())) {
				changeSelect = true;
			}
			_activeHostSubstitution = _itemSelection.getSingleSelection();
	
			if (_activeHostSubstitution != null) {
				setBeans();
				if (changeSelect) {
					detailHostSubstitution = (HostSubstitution) _activeHostSubstitution.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_substitutionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeHostSubstitution = (HostSubstitution) _substitutionsSource.getRowData();
		selection.addKey(_activeHostSubstitution.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeHostSubstitution != null) {
			setBeans();
			detailHostSubstitution = (HostSubstitution) _activeHostSubstitution.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
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

		Filter paramFilter = new Filter("lang", userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter("id", filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getOperType() != null) {
			paramFilter = new Filter("operType", filter.getOperType());
			filters.add(paramFilter);
		}
		if (filter.getTerminalType() != null) {
			paramFilter = new Filter("terminalType", filter.getTerminalType());
			filters.add(paramFilter);
		}
	}

	public HostSubstitution getFilter() {
		if (filter == null) {
			filter = new HostSubstitution();
		}
		return filter;
	}

	public void setFilter(HostSubstitution filter) {
		this.filter = filter;
	}

	public void add() {
		newHostSubstitution = new HostSubstitution();
		newHostSubstitution.setLang(userLang);
		// curLang = newHostSubstitution.getLang(); // WTF???

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newHostSubstitution = (HostSubstitution) detailHostSubstitution.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newHostSubstitution = _activeHostSubstitution;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newHostSubstitution = _networksDao.editHostSubstitution(userSessionId, newHostSubstitution);
				detailHostSubstitution = (HostSubstitution) newHostSubstitution.clone();
				_substitutionsSource.replaceObject(_activeHostSubstitution, newHostSubstitution);
			} else if (isNewMode()) {
				newHostSubstitution = _networksDao.addHostSubstitution(userSessionId, newHostSubstitution);
				detailHostSubstitution = (HostSubstitution) newHostSubstitution.clone();
				_itemSelection.addNewObjectToList(newHostSubstitution);
			}

			_activeHostSubstitution = newHostSubstitution;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networksDao.deleteHostSubstitution(userSessionId, _activeHostSubstitution);
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Net", "network_deleted", "(ID = "
					+ _activeHostSubstitution.getId() + ")"));

			_activeHostSubstitution = _itemSelection.removeObjectFromList(_activeHostSubstitution);
			if (_activeHostSubstitution == null) {
				clearBean();
			} else {
				setBeans();
				detailHostSubstitution = (HostSubstitution) _activeHostSubstitution.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;

	}

	public HostSubstitution getNewHostSubstitution() {
		if (newHostSubstitution == null) {
			newHostSubstitution = new HostSubstitution();
		}
		return newHostSubstitution;
	}

	public void setNewHostSubstitution(HostSubstitution newHostSubstitution) {
		this.newHostSubstitution = newHostSubstitution;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeHostSubstitution = null;
		detailHostSubstitution = null;
		_substitutionsSource.flushCache();

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

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailHostSubstitution = getNodeByLang(detailHostSubstitution.getId(), curLang);
	}

	public HostSubstitution getNodeByLang(Long id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		filtersList.add(new Filter("id", id));
		filtersList.add(new Filter("lang", lang));

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			HostSubstitution[] nets = _networksDao.getHostSubstitutions(userSessionId, params);
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
		for (CmnStandard std : stds) {
			items.add(new SelectItem(std.getId(), std.getLabel() != null ? std.getLabel()
					: ("{ID = " + std.getId() + "}")));
		}

		return items;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void clearBeansStates() {
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public HostSubstitution getDetailHostSubstitution() {
		return detailHostSubstitution;
	}

	public void setDetailHostSubstitution(HostSubstitution detailHostSubstitution) {
		this.detailHostSubstitution = detailHostSubstitution;
	}

	public List<SelectItem> getOperTypes() {
		return getDictUtils().getLov(LovConstants.OPERATION_TYPE);
	}
	
	public List<SelectItem>getTerminalArraes(){
		return getDictUtils().getLov(LovConstants.TERMINAL_ARRAY_ID);
	}
	
	public List<SelectItem>getMerchantArraes(){
		return getDictUtils().getLov(LovConstants.MERCHANT_ARRAY_ID);
	}
	
	public List<SelectItem>getOperReasons(){
		return getDictUtils().getLov(LovConstants.OPER_REASON);
	}
	
	public List<SelectItem> getOperationCurrencies(){
		return getDictUtils().getLov(LovConstants.CURRENCIES);
	}
	
	public List<SelectItem>getMessageTypes(){
		return getDictUtils().getLov(LovConstants.MESSAGE_TYPES);
	}
	
	public List<SelectItem> getTerminalTypes() {
		return getDictUtils().getLov(LovConstants.TERMINAL_TYPES);
	}

	public List<SelectItem> getNetworks() {
		return getDictUtils().getLov(LovConstants.NETWORKS);
	}

	public List<SelectItem> getAcqMembers() {
		if (getNewHostSubstitution().getAcqNetworkId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getMembers(getNewHostSubstitution().getAcqNetworkId());
	}

	public List<SelectItem> getCardMembers() {
		if (getNewHostSubstitution().getCardNetworkId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getMembers(getNewHostSubstitution().getCardNetworkId());
	}

    //todo new countries field.
    public List<SelectItem> getCardCountries(){
        return getDictUtils().getLov(LovConstants.COUNTRIES);
    }
	
	public List<SelectItem> getIssMembers() {
		if (getNewHostSubstitution().getIssNetworkId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getMembers(getNewHostSubstitution().getIssNetworkId());
	}

	public List<SelectItem> getSubstitutionMembers() {
		if (getNewHostSubstitution().getSubstitutionNetworkId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getMembers(getNewHostSubstitution().getSubstitutionNetworkId());
	}

	private List<SelectItem> getMembers(String networkId) {
		ArrayList<SelectItem> items = null;
		try {
			ArrayList<Filter> filters = new ArrayList<Filter>();
			filters.add(new Filter("lang", userLang));
			if (!HostSubstitution.ANY.equals(networkId)) {
				filters.add(new Filter("networkId", networkId));
			}

			SelectionParams params = new SelectionParams(filters);
			params.setRowIndexEnd(-1);

			NetworkMember[] members = _networksDao.getNetworkMembers(userSessionId, params);
			HashMap<String, SelectItem> map = new HashMap<String, SelectItem>();
			
			for (NetworkMember member : members) {
				map.put(member.getInstId().toString(), new SelectItem(member.getInstId(), member.getInstId() + " - " + member.getInstName()));
			}
			items = new ArrayList<SelectItem>(map.values());
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}
		
		return items;
	}
}

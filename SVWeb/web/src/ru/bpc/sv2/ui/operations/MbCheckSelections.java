package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.operations.CheckGroup;
import ru.bpc.sv2.operations.CheckSelection;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCheckSelections")
public class MbCheckSelections extends AbstractBean {
	private static final long serialVersionUID = 1149263596519258954L;

	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
	
	private static String COMPONENT_ID = "1743:checkGroupsTable";

	private OperationDao _operationsDao = new OperationDao();

	private NetworkDao _networksDao = new NetworkDao();
	
	private CheckSelection filter;
	private CheckSelection _activeCheckSelection;
	private CheckSelection newCheckSelection;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<CheckSelection> _checkSelectionsSource;

	private final TableRowSelection<CheckSelection> _itemSelection;
	
	private String tabName;

	public MbCheckSelections() {
		logger.trace("MbCheckSelections construction...");
		pageLink = "operations|checkSelections";
		tabName = "detailsTab";
		_checkSelectionsSource = new DaoDataModel<CheckSelection>() {
			private static final long serialVersionUID = -5918530178677188217L;

			@Override
			protected CheckSelection[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CheckSelection[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getCheckSelections(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CheckSelection[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getCheckSelectionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CheckSelection>(null, _checkSelectionsSource);
	}

	public DaoDataModel<CheckSelection> getCheckSelections() {
		return _checkSelectionsSource;
	}

	public CheckSelection getActiveCheckSelection() {
		return _activeCheckSelection;
	}

	public void setActiveCheckSelection(CheckSelection activeCheckSelection) {
		_activeCheckSelection = activeCheckSelection;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCheckSelection == null && _checkSelectionsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCheckSelection != null && _checkSelectionsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCheckSelection.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCheckSelection = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_checkSelectionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCheckSelection = (CheckSelection) _checkSelectionsSource.getRowData();
		selection.addKey(_activeCheckSelection.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCheckSelection = _itemSelection.getSingleSelection();
		if (_activeCheckSelection != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {
        if(_activeCheckSelection != null) {
            MbChecks checksBean = (MbChecks) ManagedBeanWrapper.getManagedBean("MbChecks");
            checksBean.setGroupId(_activeCheckSelection.getCheckGroupId());
            checksBean.search();
        }
	}

	public void clearBeansStates() {
		MbChecks checksBean = (MbChecks) ManagedBeanWrapper.getManagedBean("MbChecks");
		checksBean.fullCleanBean();
		checksBean.setSearching(false);
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public CheckSelection getFilter() {
		if (filter == null) {
			filter = new CheckSelection();
			filter.setInstId(userInstId.toString());
		}
		return filter;
	}

	public void setFilter(CheckSelection filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getCheckGroupId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("checkGroupId");
			paramFilter.setValue(filter.getCheckGroupId().toString());
			filters.add(paramFilter);
		}
		if (filter.getOperType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operType");
			paramFilter.setValue(filter.getOperType());
			filters.add(paramFilter);
		}
		if (filter.getMsgType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("msgType");
			paramFilter.setValue(filter.getMsgType());
			filters.add(paramFilter);
		}
		if (filter.getPartyType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("partyTypeEq");
			paramFilter.setValue(filter.getPartyType());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getNetworkId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setValue(filter.getNetworkId());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCheckSelection = new CheckSelection();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCheckSelection = (CheckSelection) _activeCheckSelection.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCheckSelection = _activeCheckSelection;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newCheckSelection = _operationsDao.addCheckSelection(userSessionId,
						newCheckSelection, userLang);
				_itemSelection.addNewObjectToList(newCheckSelection);
			} else if (isEditMode()) {
				newCheckSelection = _operationsDao.modifyCheckSelection(userSessionId,
						newCheckSelection, userLang);
				_checkSelectionsSource.replaceObject(_activeCheckSelection, newCheckSelection);
			}
			_activeCheckSelection = newCheckSelection;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_operationsDao.removeCheckSelection(userSessionId, _activeCheckSelection);
			_activeCheckSelection = _itemSelection.removeObjectFromList(_activeCheckSelection);

			if (_activeCheckSelection == null) {
				clearState();
			} else {
				setBeans();
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

	public CheckSelection getNewCheckSelection() {
		if (newCheckSelection == null) {
			newCheckSelection = new CheckSelection();
		}
		return newCheckSelection;
	}

	public void setNewCheckSelection(CheckSelection newCheckSelection) {
		this.newCheckSelection = newCheckSelection;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCheckSelection = null;
		_checkSelectionsSource.flushCache();

		clearBeansStates();
	}

	public void changeLanguage(ValueChangeEvent checkGroup) {
		curLang = (String) checkGroup.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeCheckSelection.getId().toString());
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
			CheckSelection[] checkGroups = _operationsDao.getCheckSelections(userSessionId, params);
			if (checkGroups != null && checkGroups.length > 0) {
				_activeCheckSelection = checkGroups[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getNetworks() {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(userLang);

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		try {
			Network[] networks = _networksDao.getNetworks(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(networks.length);
			for (Network network: networks) {
				String name = network.getName();
				items.add(new SelectItem(network.getId().toString(), name));
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

	public ArrayList<SelectItem> getNetworksForEdit() {
		if (getNewCheckSelection().getInstId() != null) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();

			ArrayList<Filter> filters = new ArrayList<Filter>();
			Filter filter = new Filter();
			filter.setElement("lang");
			filter.setValue(userLang);
			filters.add(filter);
			if (!"%".equals(newCheckSelection.getInstId())) {
				filter = new Filter();
				filter.setElement("instId");
				filter.setValue(newCheckSelection.getInstId());
				filters.add(filter);
			}
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
			try {
				Network[] networks = _networksDao.getNetworks(userSessionId, params);
				for (Network network: networks) {
					String name = network.getName();
					items.add(new SelectItem(network.getId().toString(), name));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}
	
	public ArrayList<SelectItem> getCheckGroups() {
		ArrayList<SelectItem> items = null;
		try {
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(userLang);
			                              
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);
			
			CheckGroup[] groups = _operationsDao.getCheckGroups(userSessionId, params);
			items = new ArrayList<SelectItem>(groups.length);
			for (CheckGroup group: groups) {
				items.add(new SelectItem(group.getId(), group.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public ArrayList<SelectItem> getMsgTypes() {
		return getDictUtils().getArticles(DictNames.MSG_TYPE, true);
	}

	public ArrayList<SelectItem> getOperTypes() {
		return getDictUtils().getArticles(DictNames.OPER_TYPE, true);
	}

	public ArrayList<SelectItem> getPartyTypes() {
		return getDictUtils().getArticles(DictNames.PARTY_TYPE, true);
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
		
		if (tabName.equalsIgnoreCase("checksTab")) {
			MbChecks bean = (MbChecks) ManagedBeanWrapper
					.getManagedBean("MbChecks");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_CHECK_SELECTION;
	}

}

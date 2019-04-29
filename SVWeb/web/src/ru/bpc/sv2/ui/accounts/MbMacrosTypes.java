package ru.bpc.sv2.ui.accounts;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.BunchType;
import ru.bpc.sv2.accounts.MacrosType;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbMacrosTypes")
public class MbMacrosTypes extends AbstractBean {
	private static final long serialVersionUID = -669829283751839686L;
	private static String COMPONENT_ID = "1043:macrosTypesTable";

	private AccountsDao _accountsDao = new AccountsDao();

	private String tabName;
	private List<Filter> filters;
	private List<SelectItem> institutions;
	private MacrosType macrosTypeFilter;
	private MacrosType newMacrosType;
	private ArrayList<SelectItem> types;

	private final DaoDataModel<MacrosType> _macrosTypeSource;
	private final TableRowSelection<MacrosType> _itemSelection;
	private MacrosType _activeMacrosType;
	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	public MbMacrosTypes() {
		pageLink = "account|macrosTypes";
		filters = new ArrayList<Filter>();

		_macrosTypeSource = new DaoDataListModel<MacrosType>(logger) {
			private static final long serialVersionUID = -3898541732467350914L;
			@Override
			protected List<MacrosType> loadDaoListData(SelectionParams params) {
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getMacrosTypes(userSessionId, params);
				}
				return new ArrayList<MacrosType>();
			}
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getMacrosTypesCount(userSessionId, params);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<MacrosType>(null, _macrosTypeSource);
	}

	public DaoDataModel<MacrosType> getMacrosTypes() {
		return _macrosTypeSource;
	}

	public MacrosType getActiveMacrosType() {
		return _activeMacrosType;
	}

	public void setActiveMacrosType(MacrosType activeMacrosType) {
		_activeMacrosType = activeMacrosType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeMacrosType == null && _macrosTypeSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeMacrosType != null && _macrosTypeSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeMacrosType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeMacrosType = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMacrosType = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_macrosTypeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMacrosType = (MacrosType) _macrosTypeSource.getRowData();
		selection.addKey(_activeMacrosType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeMacrosType != null) {
			// setInfo();
		}
	}

	public String search() {
		// search using new criteria
		_macrosTypeSource.flushCache();

		// reset selection
		if (_activeMacrosType != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeMacrosType);
			}
			_activeMacrosType = null;
		}
		searching = true;

		return "";
	}

	private void setBeans() {

	}

	public void clearBean() {
		_macrosTypeSource.flushCache();
		_itemSelection.clearSelection();
		_activeMacrosType = null;
	}

	public void clearFilter() {
		macrosTypeFilter = new MacrosType();

		curLang = userLang;

		clearBean();
		
		searching = false;
	}

	public void setFilters() {
		macrosTypeFilter = getFilter();
		filters = new ArrayList<Filter>();

		filters.add(Filter.create("lang", userLang));
		if (macrosTypeFilter.getName() != null && macrosTypeFilter.getName().trim().length() > 0) {
			filters.add(Filter.create("name", Operator.like, Filter.mask(macrosTypeFilter.getName())));
		}
		if (macrosTypeFilter.getDescription() != null && macrosTypeFilter.getDescription().trim().length() > 0) {
			filters.add(Filter.create("description", Operator.like, Filter.mask(macrosTypeFilter.getDescription())));
		}
	}

	public MacrosType getFilter() {
		if (macrosTypeFilter == null) {
			macrosTypeFilter = new MacrosType();
		}
		return macrosTypeFilter;
	}

	public void setFilter(MacrosType macrosTypeFilter) {
		this.macrosTypeFilter = macrosTypeFilter;
	}

	public void add() {
		newMacrosType = new MacrosType();
		newMacrosType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		newMacrosType = (MacrosType) _activeMacrosType.clone();
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newMacrosType = _accountsDao.addMacrosType(userSessionId, newMacrosType);
				_macrosTypeSource.flushCache();
				_itemSelection.addNewObjectToList(newMacrosType);
			} else {
				newMacrosType = _accountsDao.editMacrosType(userSessionId, newMacrosType);
				_macrosTypeSource.replaceObject(_activeMacrosType, newMacrosType);
			}
			curMode = VIEW_MODE;
			_activeMacrosType = newMacrosType;
			FacesUtils.addMessageInfo("Macros type has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_accountsDao.removeMacrosType(userSessionId, _activeMacrosType);
			curMode = VIEW_MODE;

			String msg = "Macros type with id = " + _activeMacrosType.getId() + " has been deleted.";

			_activeMacrosType = _itemSelection.removeObjectFromList(_activeMacrosType);
			if (_activeMacrosType == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getBunchTypes() {
		ArrayList<SelectItem> out = new ArrayList<SelectItem>(0);
		try {
			ArrayList<Filter> bunchesFilters = new ArrayList<Filter>();
			bunchesFilters.add(Filter.create("lang", curLang));
			if (newMacrosType.getInstId() != null) {
				bunchesFilters.add(Filter.create("instIds", newMacrosType.getInstId()));
			}

			SelectionParams params = new SelectionParams();
			params.setFilters(bunchesFilters.toArray(new Filter[bunchesFilters.size()]));
			params.setRowIndexEnd(-1);

			formBunchTypesList(out, _accountsDao.getBunchTypes(userSessionId, params));
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			out = new ArrayList<SelectItem>(0);
		}
		return out;
	}

	private void formBunchTypesList(ArrayList<SelectItem> items, BunchType[] bunches) {
		if (bunches != null) {
			for (BunchType bunch : bunches) {
				items.add(new SelectItem(bunch.getId(), bunch.getName()));
			}
		}
	}

	public MacrosType getNewMacrosType() {
		if (newMacrosType == null) {
			newMacrosType = new MacrosType();
		}
		return newMacrosType;
	}

	public void setNewMacrosType(MacrosType newMacrosType) {
		this.newMacrosType = newMacrosType;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		List<Filter> filtersList = new ArrayList<Filter>();
		filtersList.add(Filter.create("id", _activeMacrosType.getId()));
		filtersList.add(Filter.create("lang", curLang));
		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			List<MacrosType> macrosTypes = _accountsDao.getMacrosTypes(userSessionId, params);
			if (macrosTypes != null && macrosTypes.size() > 0) {
				_activeMacrosType = macrosTypes.get(0);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = Filter.create("id", newMacrosType.getId());
		filters[1] = Filter.create("lang", newMacrosType.getLang());
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			List<MacrosType> macrosTypes = _accountsDao.getMacrosTypes(userSessionId, params);
			if (macrosTypes != null && macrosTypes.size() > 0) {
				newMacrosType = macrosTypes.get(0);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ArrayList<SelectItem> getTypes() {
		if (types == null){
			types = (ArrayList<SelectItem>) getDictUtils()
					.getLov(LovConstants.MACROS_TYPE_STATUS);
		}
		return types;
	}

	public void setTypes(ArrayList<SelectItem> types) {
		this.types = types;
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
			if (institutions == null) {
				institutions = new ArrayList<SelectItem>();
			}
		}
		return institutions;
	}
}

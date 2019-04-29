package ru.bpc.sv2.ui.accounts;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.SelectionPriority;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbSelectionPriorities")
public class MbSelectionPriorities extends AbstractBean {
	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private static String COMPONENT_ID = "2264:prioritiesTable";

	private AccountsDao _accountsDao = new AccountsDao();

	private SelectionPriority filter;
	private SelectionPriority newSelectionPriority;
	

	private final DaoDataModel<SelectionPriority> _prioritiesSource;
	private final TableRowSelection<SelectionPriority> _itemSelection;
	private SelectionPriority _activeSelectionPriority;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> msgTypes;
	private List<SelectItem> modifiers;

	public MbSelectionPriorities() {
		
		pageLink = "accounts|selectionPriorities";
		_prioritiesSource = new DaoDataModel<SelectionPriority>() {
			@Override
			protected SelectionPriority[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new SelectionPriority[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getSelectionPriorities(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new SelectionPriority[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getSelectionPrioritiesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<SelectionPriority>(null, _prioritiesSource);
	}

	public DaoDataModel<SelectionPriority> getSelectionPriorities() {
		return _prioritiesSource;
	}

	public SelectionPriority getActiveSelectionPriority() {
		return _activeSelectionPriority;
	}

	public void setActiveSelectionPriority(SelectionPriority activeSelectionPriority) {
		_activeSelectionPriority = activeSelectionPriority;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeSelectionPriority == null && _prioritiesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeSelectionPriority != null && _prioritiesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeSelectionPriority.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeSelectionPriority = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSelectionPriority = _itemSelection.getSingleSelection();

		if (_activeSelectionPriority != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_prioritiesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSelectionPriority = (SelectionPriority) _prioritiesSource.getRowData();
		selection.addKey(_activeSelectionPriority.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getOperType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operType");
			paramFilter.setValue(filter.getOperType());
			filters.add(paramFilter);
		}
		if (filter.getAccountStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountStatus");
			paramFilter.setValue(filter.getAccountStatus());
			filters.add(paramFilter);
		}
		if (filter.getAccountType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("accountType");
			paramFilter.setValue(filter.getAccountType());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getPriority() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("priority");
			paramFilter.setValue(filter.getPriority());
			filters.add(paramFilter);
		}
		if (filter.getMsgType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("msgType");
			paramFilter.setValue(filter.getMsgType());
			filters.add(paramFilter);
		}
	}

	public SelectionPriority getFilter() {
		if (filter == null) {
			filter = new SelectionPriority();
			filter.setInstId(userInstId.toString());
		}
		return filter;
	}

	public void setFilter(SelectionPriority filter) {
		this.filter = filter;
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

	public void add() {
		newSelectionPriority = new SelectionPriority();

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSelectionPriority = (SelectionPriority) _activeSelectionPriority.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newSelectionPriority = _activeSelectionPriority;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_accountsDao.removeSelectionPriority(userSessionId, _activeSelectionPriority);

			_activeSelectionPriority = _itemSelection.removeObjectFromList(_activeSelectionPriority);
			if (_activeSelectionPriority == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newSelectionPriority = _accountsDao.addSelectionPriority(userSessionId, newSelectionPriority);
				_itemSelection.addNewObjectToList(newSelectionPriority);
			} else {
				newSelectionPriority = _accountsDao.modifySelectionPriority(userSessionId, newSelectionPriority);
				_prioritiesSource.replaceObject(_activeSelectionPriority, newSelectionPriority);
			}
			_activeSelectionPriority = newSelectionPriority;
			curMode = VIEW_MODE;
			setBeans();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public SelectionPriority getNewSelectionPriority() {
		if (newSelectionPriority == null) {
			newSelectionPriority = new SelectionPriority();
		}
		return newSelectionPriority;
	}

	public void setNewSelectionPriority(SelectionPriority newSelectionPriority) {
		this.newSelectionPriority = newSelectionPriority;
	}

	public void clearBean() {
		curLang = userLang;
		_prioritiesSource.flushCache();
		_itemSelection.clearSelection();
		_activeSelectionPriority = null;

		clearBeans();
	}

	private void clearBeans() {

	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null) {
			institutions = new ArrayList<SelectItem>(0);
		}
		return institutions;
	}

	public ArrayList<SelectItem> getAccountStatuses() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_STATUS, true);
	}

	public ArrayList<SelectItem> getAccountTypes() {
		return getDictUtils().getArticles(DictNames.ACCOUNT_TYPE, true);
	}

	public List<SelectItem> getAccountCurrencies() {
		return getDictUtils().getLov(LovConstants.CURRENCIES);
	}

	public ArrayList<SelectItem> getOperTypes() {
		return getDictUtils().getArticles(DictNames.OPER_TYPE, true);
	}
	
	public List<SelectItem> getPartyTypes(){
		List<SelectItem> result = getDictUtils().getArticles(DictNames.PARTY_TYPE);
		return result;
	}
	public List<SelectItem> getMsgTypes(){
		if (msgTypes == null) {
			msgTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.MSG_TYPE);
		}
		if (msgTypes == null) {
			return new ArrayList<SelectItem>(0);
		}
		return msgTypes;
	}
	public List<SelectItem> getModifiers(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("SCALE_TYPE", ScaleConstants.SCALE_FOR_ACC_SELECT);
		modifiers = getDictUtils().getLov(LovConstants.MODIFIER_LIST, paramMap);
		if (modifiers == null) {
			return new ArrayList<SelectItem>(0);
		}
		return modifiers;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}

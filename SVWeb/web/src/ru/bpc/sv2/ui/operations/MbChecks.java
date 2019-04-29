package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Check;
import ru.bpc.sv2.operations.CheckGroup;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped 
@ManagedBean(name = "MbChecks")
public class MbChecks extends AbstractBean {
	private static final long serialVersionUID = -8334064280388362590L;

	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private OperationDao _operationsDao = new OperationDao();
	
	private Integer groupId;

	private Check filter;
	private Check _activeCheck;
	private Check newCheck;

	private final DaoDataModel<Check> _checksSource;

	private final TableRowSelection<Check> _itemSelection;
	
	private static String COMPONENT_ID = "checksTable";
	private String tabName;
	private String parentSectionId;

	public MbChecks() {
		_checksSource = new DaoDataModel<Check>() {
			private static final long serialVersionUID = -7692212535133304349L;

			@Override
			protected Check[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Check[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getChecks(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Check[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getChecksCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Check>(null, _checksSource);
	}

	public DaoDataModel<Check> getChecks() {
		return _checksSource;
	}

	public Check getActiveCheck() {
		return _activeCheck;
	}

	public void setActiveCheck(Check activeCheck) {
		_activeCheck = activeCheck;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCheck == null && _checksSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCheck != null && _checksSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCheck.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCheck = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_checksSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCheck = (Check) _checksSource.getRowData();
		selection.addKey(_activeCheck.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeCheck != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCheck = _itemSelection.getSingleSelection();
		if (_activeCheck != null) {
			// setInfo();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new Check();

		clearState();
		searching = false;
	}

	public Check getFilter() {
		if (filter == null)
			filter = new Check();
		return filter;
	}

	public void setFilter(Check filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("checkGroupId");
		paramFilter.setValue(groupId.toString());
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getCheckType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("checkType");
			paramFilter.setValue(filter.getCheckType());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCheck = new Check();
		newCheck.setCheckGroupId(groupId);

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCheck = (Check) _activeCheck.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCheck = _activeCheck;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newCheck = _operationsDao.addCheck(userSessionId, newCheck, userLang);
				_itemSelection.addNewObjectToList(newCheck);
			} else if (isEditMode()) {
				newCheck = _operationsDao.modifyCheck(userSessionId, newCheck, userLang);
				_checksSource.replaceObject(_activeCheck, newCheck);
			}
			_activeCheck = newCheck;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_operationsDao.removeCheck(userSessionId, _activeCheck);
			_activeCheck = _itemSelection.removeObjectFromList(_activeCheck);
			if (_activeCheck == null) {
				clearState();
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

	public Check getNewCheck() {
		if (newCheck == null) {
			newCheck = new Check();
		}
		return newCheck;
	}

	public void setNewCheck(Check newCheck) {
		this.newCheck = newCheck;
	}

	private void setBeans() {

	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCheck = null;
		_checksSource.flushCache();
	}

	public void fullCleanBean() {
		groupId = null;

		clearFilter();
	}

	public Integer getGroupId() {
		return groupId;
	}

	public void setGroupId(Integer groupId) {
		this.groupId = groupId;
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
	
	public ArrayList<SelectItem> getCheckTypes() {
		return getDictUtils().getArticles(DictNames.OPERATION_CHECK_TYPES, true);
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

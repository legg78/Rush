package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.CheckGroup;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbCheckGroups")
public class MbCheckGroups extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private static String COMPONENT_ID = "1742:checkGroupsTable";

	private OperationDao _operationsDao = new OperationDao();

	

	private CheckGroup filter;
	private CheckGroup _activeCheckGroup;
	private CheckGroup newCheckGroup;
	private CheckGroup detailCheckGroup;

	private final DaoDataModel<CheckGroup> _checkGroupsSource;

	private final TableRowSelection<CheckGroup> _itemSelection;
	
	private String tabName;

	public MbCheckGroups() {
		
		pageLink = "operations|checkGroups";
		tabName = "detailsTab";
		_checkGroupsSource = new DaoDataModel<CheckGroup>() {
			@Override
			protected CheckGroup[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CheckGroup[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getCheckGroups(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CheckGroup[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getCheckGroupsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CheckGroup>(null, _checkGroupsSource);
	}

	public DaoDataModel<CheckGroup> getCheckGroups() {
		return _checkGroupsSource;
	}

	public CheckGroup getActiveCheckGroup() {
		return _activeCheckGroup;
	}

	public void setActiveCheckGroup(CheckGroup activeCheckGroup) {
		_activeCheckGroup = activeCheckGroup;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCheckGroup == null && _checkGroupsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCheckGroup != null && _checkGroupsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCheckGroup.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCheckGroup = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_checkGroupsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCheckGroup = (CheckGroup) _checkGroupsSource.getRowData();
		detailCheckGroup = (CheckGroup) _activeCheckGroup.clone();
		selection.addKey(_activeCheckGroup.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeCheckGroup.getId())) {
				changeSelect = true;
			}
			_activeCheckGroup = _itemSelection.getSingleSelection();
			if (_activeCheckGroup != null) {
				setBeans();
				if (changeSelect) {
					detailCheckGroup = (CheckGroup) _activeCheckGroup.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {
		MbChecks checksBean = (MbChecks) ManagedBeanWrapper.getManagedBean("MbChecks");
		checksBean.setGroupId(_activeCheckGroup.getId());
		checksBean.search();
	}

	public void clearBeansStates() {
		MbChecks checksBean = (MbChecks) ManagedBeanWrapper.getManagedBean("MbChecks");
		checksBean.fullCleanBean();
		checksBean.setSearching(false);
	}

	public void clearFilter() {
		filter = new CheckGroup();

		clearState();
		searching = false;
	}

	public CheckGroup getFilter() {
		if (filter == null)
			filter = new CheckGroup();
		return filter;
	}

	public void setFilter(CheckGroup filter) {
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

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setCondition("like");
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCheckGroup = new CheckGroup();
		newCheckGroup.setLang(userLang);
		curLang = newCheckGroup.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCheckGroup = (CheckGroup) detailCheckGroup.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newCheckGroup = _activeCheckGroup;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newCheckGroup = _operationsDao.addCheckGroup(userSessionId, newCheckGroup);
				detailCheckGroup = (CheckGroup) newCheckGroup.clone();
				_itemSelection.addNewObjectToList(newCheckGroup);
			} else if (isEditMode()) {
				newCheckGroup = _operationsDao.modifyCheckGroup(userSessionId, newCheckGroup);
				detailCheckGroup = (CheckGroup) newCheckGroup.clone();
				if (!userLang.equals(newCheckGroup.getLang())) {
					newCheckGroup = getNodeByLang(_activeCheckGroup.getId(), userLang);
				}
				_checkGroupsSource.replaceObject(_activeCheckGroup, newCheckGroup);
			}
			_activeCheckGroup = newCheckGroup;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_operationsDao.removeCheckGroup(userSessionId, _activeCheckGroup);
			_activeCheckGroup = _itemSelection.removeObjectFromList(_activeCheckGroup);

			if (_activeCheckGroup == null) {
				clearState();
			} else {
				setBeans();
				detailCheckGroup = (CheckGroup) _activeCheckGroup.clone();
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

	public CheckGroup getNewCheckGroup() {
		if (newCheckGroup == null) {
			newCheckGroup = new CheckGroup();
		}
		return newCheckGroup;
	}

	public void setNewCheckGroup(CheckGroup newCheckGroup) {
		this.newCheckGroup = newCheckGroup;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCheckGroup = null;
		detailCheckGroup = null;
		_checkGroupsSource.flushCache();

		clearBeansStates();
	}

	public void changeLanguage(ValueChangeEvent checkGroup) {
		curLang = (String) checkGroup.getNewValue();
		detailCheckGroup = getNodeByLang(detailCheckGroup.getId(), curLang);
	}
	
	public void confirmEditLanguage() {
		curLang = newCheckGroup.getLang();
		CheckGroup tmp = getNodeByLang(newCheckGroup.getId(), newCheckGroup.getLang());
		if (tmp != null) {
			newCheckGroup.setName(tmp.getName());
			newCheckGroup.setDescription(tmp.getDescription());
		}
	}
	
	public CheckGroup getNodeByLang(Integer id, String lang) {
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
			CheckGroup[] checkGroups = _operationsDao.getCheckGroups(userSessionId, params);
			if (checkGroups != null && checkGroups.length > 0) {
				return checkGroups[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public CheckGroup getDetailCheckGroup() {
		return detailCheckGroup;
	}

	public void setDetailCheckGroup(CheckGroup detailCheckGroup) {
		this.detailCheckGroup = detailCheckGroup;
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
		return SectionIdConstants.OPERATION_CHECK_GROUP;
	}
}

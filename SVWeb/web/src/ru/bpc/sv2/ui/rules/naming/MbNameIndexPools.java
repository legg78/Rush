package ru.bpc.sv2.ui.rules.naming;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.naming.NameIndexPool;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbNameIndexPools")
public class MbNameIndexPools extends AbstractBean {
	private static final Logger logger = Logger.getLogger("RULES");

	private RulesDao _rulesDao = new RulesDao();

	private NameIndexPool filter;
	private NameIndexPool _activeNameIndexPool;
	private NameIndexPool newNameIndexPool;

	private final DaoDataModel<NameIndexPool> _nameIndexPoolsSource;
	private final TableRowSelection<NameIndexPool> _itemSelection;
	
	private boolean addPool;
	private boolean deletePool; 
	
	private static String COMPONENT_ID = "poolsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbNameIndexPools() {
		_nameIndexPoolsSource = new DaoDataModel<NameIndexPool>() {
			@Override
			protected NameIndexPool[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NameIndexPool[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameIndexPools(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NameIndexPool[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getNameIndexPoolsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NameIndexPool>(null, _nameIndexPoolsSource);
	}

	public DaoDataModel<NameIndexPool> getNameIndexPools() {
		return _nameIndexPoolsSource;
	}

	public NameIndexPool getActiveNameIndexPool() {
		return _activeNameIndexPool;
	}

	public void setActiveNameIndexPool(NameIndexPool activeNameIndexPool) {
		_activeNameIndexPool = activeNameIndexPool;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeNameIndexPool == null && _nameIndexPoolsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeNameIndexPool != null && _nameIndexPoolsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeNameIndexPool.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeNameIndexPool = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_nameIndexPoolsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeNameIndexPool = (NameIndexPool) _nameIndexPoolsSource.getRowData();
		selection.addKey(_activeNameIndexPool.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeNameIndexPool = _itemSelection.getSingleSelection();
		if (_activeNameIndexPool != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {

	}

	public void clearBeansStates() {

	}

	public void fullCleanBean() {
		clearFilter();
	}
	
	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public NameIndexPool getFilter() {
		if (filter == null) {
			filter = new NameIndexPool();
		}
		return filter;
	}

	public void setFilter(NameIndexPool filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getIndexRangeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("indexRangeId");
			paramFilter.setValue(filter.getIndexRangeId());
			filters.add(paramFilter);
		}
		if (filter.getIsUsed() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("isUsed");
			paramFilter.setValue(filter.getIsUsed());
			filters.add(paramFilter);
		}
	}

	public void addValue() {
		newNameIndexPool = new NameIndexPool();
		newNameIndexPool.setIndexRangeId(getFilter().getIndexRangeId());
		curMode = NEW_MODE;
		addPool = false;
	}

	public void addPool() {
		newNameIndexPool = new NameIndexPool();
		newNameIndexPool.setIndexRangeId(getFilter().getIndexRangeId());
		curMode = NEW_MODE;
		addPool = true;
	}

	public void edit() {
		try {
			newNameIndexPool = (NameIndexPool) _activeNameIndexPool.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newNameIndexPool = _activeNameIndexPool;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (addPool) {
				_rulesDao.addNameIndexPool(userSessionId, newNameIndexPool);
				_nameIndexPoolsSource.flushCache();
			} else {
				newNameIndexPool = _rulesDao.addNameIndexPoolValue(userSessionId, newNameIndexPool);
				_itemSelection.addNewObjectToList(newNameIndexPool);
				_activeNameIndexPool = newNameIndexPool;
				setBeans();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void deleteValue() {
		try {
			_rulesDao.removeNameIndexPoolValue(userSessionId, _activeNameIndexPool);
			_activeNameIndexPool = _itemSelection.removeObjectFromList(_activeNameIndexPool);

			if (_activeNameIndexPool == null) {
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

	public void deletePoolRangeInit() {
		newNameIndexPool = new NameIndexPool();
		newNameIndexPool.setIndexRangeId(getFilter().getIndexRangeId());
		deletePool = true;
	}
	
	public void deletePoolRange() {
		try {
			_rulesDao.removeNameIndexPoolRange(userSessionId, newNameIndexPool);
			clearState();
			curMode = VIEW_MODE;
			deletePool = false;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void deletePool() {
		try {
			_rulesDao.removeNameIndexPool(userSessionId, _activeNameIndexPool);
			clearState();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void clearPool() {
		try {
			_rulesDao.clearNameIndexPool(userSessionId, _activeNameIndexPool);
			_nameIndexPoolsSource.flushCache();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		deletePool = false;
		addPool = false;
		curMode = VIEW_MODE;
	}

	public NameIndexPool getNewNameIndexPool() {
		if (newNameIndexPool == null) {
			newNameIndexPool = new NameIndexPool();
		}
		return newNameIndexPool;
	}

	public void setNewNameIndexPool(NameIndexPool newNameIndexPool) {
		this.newNameIndexPool = newNameIndexPool;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeNameIndexPool = null;
		_nameIndexPoolsSource.flushCache();

		clearBeansStates();
	}

	public boolean isAddPool() {
		return addPool;
	}

	public boolean isDeletePool() {
		return deletePool;
	}
	
	public boolean isPoolEmpty() {
		return _nameIndexPoolsSource.getDataSize() < 1;
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

package ru.bpc.sv2.ui.network;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.OperTypeMap;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbOperTypeMaps")
public class MbOperTypeMaps extends AbstractBean {
	private static final long serialVersionUID = -6076742806121579422L;

	private static final Logger logger = Logger.getLogger("NETWORKS");

	private NetworkDao _networksDao = new NetworkDao();

	private CommunicationDao _cmnDao = new CommunicationDao();
	
	private ArrayList<SelectItem> institutions;

	private OperTypeMap filter;
	private OperTypeMap _activeOperTypeMap;
	private OperTypeMap newOperTypeMap;

	private final DaoDataModel<OperTypeMap> _networkSource;

	private final TableRowSelection<OperTypeMap> _itemSelection;
	
	private static String COMPONENT_ID = "operTypeMapsTable";
	private String tabName;
	private String parentSectionId;

	public MbOperTypeMaps() {
		_networkSource = new DaoDataModel<OperTypeMap>() {
			private static final long serialVersionUID = -560233456862632673L;

			@Override
			protected OperTypeMap[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new OperTypeMap[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getOperTypeMaps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new OperTypeMap[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _networksDao.getOperTypeMapsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		
		_itemSelection = new TableRowSelection<OperTypeMap>(null, _networkSource);
	}

	public DaoDataModel<OperTypeMap> getOperTypeMaps() {
		return _networkSource;
	}

	public OperTypeMap getActiveOperTypeMap() {
		return _activeOperTypeMap;
	}

	public void setActiveOperTypeMap(OperTypeMap activeOperTypeMap) {
		_activeOperTypeMap = activeOperTypeMap;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeOperTypeMap == null && _networkSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeOperTypeMap != null && _networkSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeOperTypeMap.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeOperTypeMap = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeOperTypeMap = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_networkSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeOperTypeMap = (OperTypeMap) _networkSource.getRowData();
		selection.addKey(_activeOperTypeMap.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeOperTypeMap != null) {
			setBeans();
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

		if (filter.getId() != null) {
			filters.add(new Filter("id", filter.getId()));
		}
		if (filter.getStandardId() != null) {
			filters.add(new Filter("standardId", filter.getStandardId()));
		}
		if (filter.getNetworkOperType() != null) {
			filters.add(new Filter("networkOperType", filter.getNetworkOperType()));
		}
		if (filter.getOperType() != null) {
			filters.add(new Filter("operType", filter.getOperType()));
		}
	}

	public OperTypeMap getFilter() {
		if (filter == null) {
			filter = new OperTypeMap();
		}
		return filter;
	}

	public void setFilter(OperTypeMap filter) {
		this.filter = filter;
	}

	public void add() {
		newOperTypeMap = new OperTypeMap();
		newOperTypeMap.setStandardId(filter.getStandardId());
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newOperTypeMap = (OperTypeMap) _activeOperTypeMap.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newOperTypeMap = _activeOperTypeMap;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newOperTypeMap = _networksDao.modifyOperTypeMap(userSessionId, newOperTypeMap);
				_networkSource.replaceObject(_activeOperTypeMap, newOperTypeMap);
			} else {
				newOperTypeMap = _networksDao.addOperTypeMap(userSessionId, newOperTypeMap);
				_itemSelection.addNewObjectToList(newOperTypeMap);
			}

			_activeOperTypeMap = newOperTypeMap;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_networksDao.removeOperTypeMap(userSessionId, _activeOperTypeMap);
			curMode = VIEW_MODE;

			_activeOperTypeMap = _itemSelection.removeObjectFromList(_activeOperTypeMap);
			if (_activeOperTypeMap == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;

	}

	public OperTypeMap getNewOperTypeMap() {
		if (newOperTypeMap == null) {
			newOperTypeMap = new OperTypeMap();
		}
		return newOperTypeMap;
	}

	public void setNewOperTypeMap(OperTypeMap newOperTypeMap) {
		this.newOperTypeMap = newOperTypeMap;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeOperTypeMap = null;
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

	public void clearBeansStates() {
	}

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "1231:networksTable";
		}
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public List<SelectItem> getOperTypes() {
		return getDictUtils().getLov(LovConstants.OPERATION_TYPE);
	}
}

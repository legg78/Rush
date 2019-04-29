package ru.bpc.sv2.ui.events;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.evt.StatusMap;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbStatusMap")
public class MbStatusMap extends AbstractBean {

	private static final Logger logger = Logger.getLogger("EVENTS");

	private static String COMPONENT_ID = "1882:statusMapTable";

	private EventsDao _eventsDao = new EventsDao();

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<StatusMap> _statusMapSource;
	private final TableRowSelection<StatusMap> _itemSelection;
	private StatusMap _activeStatusMap;

	private List<Filter> filters;
	private StatusMap filter;

	private StatusMap newStatusMap;

	public MbStatusMap() {
		
		curMode = VIEW_MODE;
		pageLink = "events|statusMap";
		_statusMapSource = new DaoDataModel<StatusMap>() {
			@Override
			protected StatusMap[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new StatusMap[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getStatusInstMaps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new StatusMap[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getStatusMapsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<StatusMap>(null, _statusMapSource);
	}

	public DaoDataModel<StatusMap> getStatusMaps() {
		return _statusMapSource;
	}

	public StatusMap getActiveStatusMap() {
		return _activeStatusMap;
	}

	public void setActiveStatusMap(StatusMap activeStatusMap) {
		_activeStatusMap = activeStatusMap;
	}

	public SimpleSelection getItemSelection() {
		if (_activeStatusMap == null && _statusMapSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeStatusMap != null && _statusMapSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeStatusMap.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeStatusMap = _itemSelection.getSingleSelection();
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeStatusMap = _itemSelection.getSingleSelection();

		if (_activeStatusMap != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_statusMapSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeStatusMap = (StatusMap) _statusMapSource.getRowData();
		selection.addKey(_activeStatusMap.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeStatusMap != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public StatusMap getFilter() {
		if (filter == null) {
			filter = new StatusMap();
		}
		return filter;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Filter.Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getEventType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("eventType");
			paramFilter.setValue(filter.getEventType());
			filters.add(paramFilter);
		}
		if (filter.getInitiator() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("initiator");
			paramFilter.setValue(filter.getInitiator());
			filters.add(paramFilter);
		}
		if (filter.getInitialStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("initialStatus");
			paramFilter.setValue(filter.getInitialStatus());
			filters.add(paramFilter);
		}
		if (filter.getResultStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("resultStatus");
			paramFilter.setValue(filter.getResultStatus());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
	}

	public List<SelectItem> getInitiators() {
		return getDictUtils().getLov(LovConstants.INITIATORS);
	}

	public List<SelectItem> getEventTypes() {
		return getDictUtils().getLov(LovConstants.EVENT_TYPES_FOR_STATUS);
	}

	public List<SelectItem> getInitialStatuses() {
		return getDictUtils().getLov(LovConstants.STATUS);
	}

	public List<SelectItem> getResultStatuses() {
		return getDictUtils().getLov(LovConstants.STATUS);
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = new StatusMap();
		searching = false;
		clearBean();
	}

	public void clearBean() {
		_statusMapSource.flushCache();
		_itemSelection.clearSelection();
		_activeStatusMap = null;

		// clear dependent bean
	}

	public void add() {
		newStatusMap = new StatusMap();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newStatusMap = (StatusMap) _activeStatusMap.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newStatusMap = _activeStatusMap;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_eventsDao.deleteStatusMap(userSessionId, _activeStatusMap);
			_activeStatusMap = _itemSelection.removeObjectFromList(_activeStatusMap);
			if (_activeStatusMap == null) {
				clearBean();
			} else {
				setBeans();
			}
			curMode = VIEW_MODE;
			//			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Evt",
			//			        "status_map_deleted", "(id = " + _activeStatusMap.getId() + ")"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isEditMode()) {
				newStatusMap = _eventsDao.editStatusMap(userSessionId, newStatusMap, userLang);
				_statusMapSource.replaceObject(_activeStatusMap, newStatusMap);
			} else {
				newStatusMap = _eventsDao.addStatusMap(userSessionId, newStatusMap, userLang);
				_itemSelection.addNewObjectToList(newStatusMap);
			}
			_activeStatusMap = newStatusMap;
			setBeans();
			curMode = VIEW_MODE;

			//			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Evt",
			//			        "status_map_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public StatusMap getNewStatusMap() {
		if (newStatusMap == null) {
			newStatusMap = new StatusMap();
		}
		return newStatusMap;
	}

	public void setNewStatusMap(StatusMap newStatusMap) {
		this.newStatusMap = newStatusMap;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new StatusMap();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("eventType") != null) {
					filter.setEventType(filterRec.get("eventType"));
				}
				if (filterRec.get("initiator") != null) {
					filter.setInitiator(filterRec.get("initiator"));
				}
				if (filterRec.get("resultStatus") != null) {
					filter.setResultStatus(filterRec.get("resultStatus"));
				}
				if (filterRec.get("initialStatus") != null) {
					filter.setInitialStatus(filterRec.get("initialStatus"));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getInstId() != null) {
				filterRec.put("instId", filter.getInstId().toString());
			}
			if (filter.getEventType() != null) {
				filterRec.put("eventType", filter.getEventType());
			}
			if (filter.getInitiator() != null) {
				filterRec.put("initiator", filter.getInitiator());
			}
			if (filter.getResultStatus() != null) {
				filterRec.put("resultStatus", filter.getResultStatus());
			}
			if (filter.getInitialStatus() != null) {
				filterRec.put("initialStatus", filter.getInitialStatus());
			}
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

}

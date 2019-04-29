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

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.evt.StatusLog;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbStatusLogs")
public class MbStatusLogs extends AbstractBean{
	private static final Logger logger = Logger.getLogger("EVENTS");
	
	private final String INITIATOR_OPERATOR = "ENSIOPER";

	private EventsDao _eventsDao = new EventsDao();
	
	private StatusLog filter;
	private StatusLog newStatusLog;

	

	private final DaoDataModel<StatusLog> _statusLogSource;
	private final TableRowSelection<StatusLog> _itemSelection;
	private StatusLog _activeStatusLog;
	private String tabName;
	private DaoDataModel<?> extDataSource;
	
	private static String COMPONENT_ID = "statusLogsTable";
	private String parentSectionId;
	
	public MbStatusLogs() {
		

		_statusLogSource = new DaoDataModel<StatusLog>() {
			@Override
			protected StatusLog[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new StatusLog[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (EntityNames.CARD_INSTANCE.equals(filter.getEntityType())) {
						//We have to process this case separately, as objectId is card object id, 
						//but statuses are logged for card instances. Therefore we have separate 
						//method and sql query
						return _eventsDao.getCardStatusLogs(userSessionId, params);
					}
					return _eventsDao.getStatusLogs(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new StatusLog[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (EntityNames.CARD_INSTANCE.equals(filter.getEntityType())) {
						return _eventsDao.getCardStatusLogsCount(userSessionId, params);
					}
					return _eventsDao.getStatusLogsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<StatusLog>(null, _statusLogSource);
	}

	public DaoDataModel<StatusLog> getStatusLogs() {
		return _statusLogSource;
	}

	public StatusLog getActiveStatusLog() {
		return _activeStatusLog;
	}

	public void setActiveStatusLog(StatusLog activeStatusLog) {
		_activeStatusLog = activeStatusLog;
	}

	public SimpleSelection getItemSelection() {
		if (_activeStatusLog == null && _statusLogSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeStatusLog != null && _statusLogSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeStatusLog.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeStatusLog = _itemSelection.getSingleSelection();
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeStatusLog = _itemSelection.getSingleSelection();

		if (_activeStatusLog != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_statusLogSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeStatusLog = (StatusLog) _statusLogSource.getRowData();
		selection.addKey(_activeStatusLog.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeStatusLog != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new StatusLog();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter= new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId());
			filters.add(paramFilter);
		}

		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			filters.add(new Filter("status", filter.getStatus()));
		}

		if (filter.getDateFrom() != null) {
			filters.add(new Filter("dateFrom", filter.getDateFrom()));
		}
		if (filter.getDateTo() != null) {
			filters.add(new Filter("dateTo", filter.getDateTo()));
		}
	}

	public void add() {
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
	}

	public void delete() {
	}

	public void save() {
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public StatusLog getFilter() {
		if (filter == null) {
			filter = new StatusLog();
		}
		return filter;
	}

	public void setFilter(StatusLog filter) {
		this.filter = filter;
	}

	public StatusLog getNewStatusLog() {
		if (newStatusLog == null) {
			newStatusLog = new StatusLog();
		}
		return newStatusLog;
	}

	public void setNewStatusLog(StatusLog newStatusLog) {
		this.newStatusLog = newStatusLog;
	}

	public void clearBean() {
		_statusLogSource.flushCache();
		_itemSelection.clearSelection();
		_activeStatusLog = null;

		// clear dependent bean
	}

	public void fullCleanBean() {
		clearFilter();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void prepChangeStatus() {
		prepChangeStatus(getFilter().getEntityType(), getFilter().getObjectId(), getFilter()
				.getStatus());
	}
	
	public void prepChangeStatus(String entityType, Long objectId, String initialStatus) {
		newStatusLog = new StatusLog();
		newStatusLog.setEntityType(entityType);
		newStatusLog.setObjectId(objectId);
		newStatusLog.setStatus(initialStatus);
		newStatusLog.setInitiator(INITIATOR_OPERATOR);
	}

	public void changeStatus() {
		try {
			_eventsDao.changeStatus(userSessionId, newStatusLog);
			if (extDataSource != null) {
				extDataSource.flushCache();
			}
			_statusLogSource.flushCache();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public List<SelectItem> getChangeCommands() {
		if (getNewStatusLog().getStatus() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("initiator", newStatusLog.getInitiator());
		paramMap.put("initial_status", newStatusLog.getStatus());
		return getDictUtils().getLov(LovConstants.CHANGE_STATUS_COMMANDS, paramMap);
	}
	
	public List<SelectItem> getChangeReasons() {
		if (getNewStatusLog().getEventType() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter("eventType", newStatusLog.getEventType());
			filters[1] = new Filter("entityType", newStatusLog.getEntityType());
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			
			List<Integer> lovs = _eventsDao.getChangeReasonsLov(userSessionId, params);
			if (lovs != null && lovs.size() > 0 && lovs.get(0) != null) {
				return getDictUtils().getLov(lovs.get(0));
			}
		}
		return new ArrayList<SelectItem>(0);
		
	}
	
	public DaoDataModel<?> getExtDataSource() {
		return extDataSource;
	}

	public void setExtDataSource(DaoDataModel<?> extDataSource) {
		this.extDataSource = extDataSource;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}

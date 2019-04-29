package ru.bpc.sv2.ui.common.events;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.events.EventType;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbEventTypes")
public class MbEventTypes extends AbstractBean {

	private static String COMPONENT_ID = "1291:eventTypesTable";

	private EventsDao _eventsDao = new EventsDao();

	private EventType eventTypeFilter;
	private EventType _activeEventType;
	private EventType newEventType;

	private final DaoDataModel<EventType> _eventTypeSource;

	private final TableRowSelection<EventType> _itemSelection;
	private static final Logger logger = Logger.getLogger("EVENTS");
	
	private String tabName;
	
	private List<SelectItem> reasonList;

	public MbEventTypes() {
		thisBackLink = "common|events|types";
		pageLink = "common|events|types";

//		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss,SSS");
//		System.out.println("MbEventTypes " + sdf.format(new Date()));
		
		_eventTypeSource = new DaoDataModel<EventType>() {
			@Override
			protected EventType[] loadDaoData(SelectionParams params) {
//				log("Data");
				if (!searching) {
					return new EventType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new EventType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
//				log("Data size");
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<EventType>(null, _eventTypeSource);
		tabName = "subscribersTab";
	}

	public DaoDataModel<EventType> getEventTypes() {
		return _eventTypeSource;
	}

	public EventType getActiveEventType() {
//		log(_activeEventType);
		return _activeEventType;
	}

	public void setActiveEventType(EventType activeEventType) {
		_activeEventType = activeEventType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeEventType == null && _eventTypeSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeEventType != null && _eventTypeSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeEventType.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeEventType = _itemSelection.getSingleSelection();
		}
//		log(_itemSelection.getWrappedSelection());
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeEventType = _itemSelection.getSingleSelection();

		// set entry templates
		if (_activeEventType != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_eventTypeSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeEventType = (EventType) _eventTypeSource.getRowData();
		selection.addKey(_activeEventType.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbEventSubscribers subscr = (MbEventSubscribers) ManagedBeanWrapper
				.getManagedBean("MbEventSubscribers");
		subscr.setEventType(_activeEventType.getEventType());
		subscr.search();
	}

	public void clearFilter() {
		eventTypeFilter = new EventType();
		curLang = userLang;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;

		clearBean();
		searching = true;

	}

	private void setFilters() {
		eventTypeFilter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = null;
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (eventTypeFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(eventTypeFilter.getId().toString());
			filters.add(paramFilter);
		}

		if (eventTypeFilter.getEventType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("eventType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(eventTypeFilter.getEventType());
			filters.add(paramFilter);
		}

		if (eventTypeFilter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(eventTypeFilter.getEntityType());
			filters.add(paramFilter);
		}
		

	}

	public EventType getFilter() {
		if (eventTypeFilter == null)
			eventTypeFilter = new EventType();
//		log(eventTypeFilter);
		return eventTypeFilter;
	}

	public void setFilter(EventType filter) {
		this.eventTypeFilter = filter;
	}

	public void add() {
		newEventType = new EventType();
		newEventType.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newEventType = (EventType) _activeEventType.clone();						
		} catch (CloneNotSupportedException e) {
			newEventType = _activeEventType;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newEventType = _eventsDao.editEventType(userSessionId, newEventType);
				_eventTypeSource.replaceObject(_activeEventType, newEventType);
			} else {
				_eventsDao.addEventType(userSessionId, newEventType);
				_itemSelection.addNewObjectToList(newEventType);
			}
			getDictUtils().flush();

			_activeEventType = newEventType;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"event_type_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public void delete() {
		try {
			_eventsDao.deleteEventType(userSessionId, _activeEventType);
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"event_type_deleted", "(id = " + _activeEventType.getId() + ")"));

			_activeEventType = _itemSelection.removeObjectFromList(_activeEventType);
			if (_activeEventType == null) {
				clearBean();
			} else {
				setBeans();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;

	}

	public EventType getNewEventType() {
		if (newEventType == null) {
			newEventType = new EventType();
		}
//		log(newEventType);
		return newEventType;
	}

	public void setNewEventType(EventType newEventType) {
		this.newEventType = newEventType;
	}

	public void clearBean() {
		// clear dependent bean
		MbEventSubscribers subscr = (MbEventSubscribers) ManagedBeanWrapper
				.getManagedBean("MbEventSubscribers");
		subscr.setEventType(null);
		subscr.clearState();

		if (_activeEventType != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeEventType);
			}
			_activeEventType = null;
		}
		_eventTypeSource.flushCache();
	}

	public List<SelectItem> getEntityTypes() {
//		log(getDictUtils().getArticles(DictNames.ENTITY_TYPES, false, false));
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public List<SelectItem> getEventTypesItems() {
//		ArrayList<SelectItem> items = getDictUtils().getArticles(DictNames.EVENT_TYPES, true);
//		items.addAll(getDictUtils().getArticles(DictNames.CYCLE_TYPES, true));
		
//		log(items);
//		return items;
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EVENTS);
		return result;
	}
	
	public List<SelectItem> getReasonLovIds(){
		if (reasonList==null){
			reasonList = getDictUtils().getLov(LovConstants.LOVS_LOV);
		}
		return reasonList;
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
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_EVENT_TYPE;
	}

}

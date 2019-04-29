package ru.bpc.sv2.ui.common.events;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.events.Event;
import ru.bpc.sv2.common.events.EventSubscriber;
import ru.bpc.sv2.common.events.EventSubscription;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbEventSubscriptions")
public class MbEventSubscriptions extends AbstractBean {
	private static final long serialVersionUID = 720961535538514866L;

	private static final Logger logger = Logger.getLogger("EVENTS");

	private EventsDao _eventsDao = new EventsDao();

	private RulesDao _rulesDao = new RulesDao();
	private Event event;

	private EventSubscription filter;
	private EventSubscription _activeSubscription;
	private EventSubscription newSubscription;

	private final DaoDataModel<EventSubscription> _eventSubscriptionsSource;

	private final TableRowSelection<EventSubscription> _itemSelection;
	
	private static String COMPONENT_ID = "subscriptionsTable";
	private String tabName;
	private String parentSectionId;

	private List<SelectItem> containers;
	private Map<Integer, String> subscrsByProcedure;

	public MbEventSubscriptions() {
		_eventSubscriptionsSource = new DaoDataModel<EventSubscription>() {
			private static final long serialVersionUID = -8426261218445306062L;

			@Override
			protected EventSubscription[] loadDaoData(SelectionParams params) {
				if (!searching || event == null) {
					return new EventSubscription[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventSubscriptions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new EventSubscription[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || event == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventSubscriptionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<EventSubscription>(null, _eventSubscriptionsSource);
	}

	public DaoDataModel<EventSubscription> getEventSubscriptions() {
		return _eventSubscriptionsSource;
	}

	public EventSubscription getActiveSubscription() {
		return _activeSubscription;
	}

	public void setActiveSubscription(EventSubscription activeSubscription) {
		_activeSubscription = activeSubscription;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeSubscription == null && _eventSubscriptionsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeSubscription != null && _eventSubscriptionsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeSubscription.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeSubscription = _itemSelection.getSingleSelection();
			}
			return _itemSelection.getWrappedSelection();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}

	public void setFirstRowActive() {
		_eventSubscriptionsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSubscription = (EventSubscription) _eventSubscriptionsSource.getRowData();
		selection.addKey(_activeSubscription.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeSubscription != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSubscription = _itemSelection.getSingleSelection();
		if (_activeSubscription != null) {
			// setInfo();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new EventSubscription();

		clearState();
		searching = false;
	}

	public EventSubscription getFilter() {
		if (filter == null)
			filter = new EventSubscription();
		return filter;
	}

	public void setFilter(EventSubscription filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("eventId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(event.getId().toString());
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newSubscription = new EventSubscription();
		newSubscription.setEventId(event.getId());

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSubscription = (EventSubscription) _activeSubscription.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newSubscription = _activeSubscription;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newSubscription = _eventsDao.addEventSubscription(userSessionId, newSubscription,
						userLang);
				_itemSelection.addNewObjectToList(newSubscription);
			} else if (isEditMode()) {
				newSubscription = _eventsDao.modifyEventSubscription(userSessionId,
						newSubscription, userLang);
				_eventSubscriptionsSource.replaceObject(_activeSubscription, newSubscription);
			}
			_activeSubscription = newSubscription;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_eventsDao.deleteEventSubscription(userSessionId, _activeSubscription);
			_activeSubscription = _itemSelection.removeObjectFromList(_activeSubscription);

			if (_activeSubscription == null) {
				clearState();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void setCurMode(int mode) {
		curMode = mode;
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}

	public EventSubscription getNewSubscription() {
		if (newSubscription == null) {
			newSubscription = new EventSubscription();
		}
		return newSubscription;
	}

	public void setNewSubscription(EventSubscription newSubscription) {
		this.newSubscription = newSubscription;
	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeSubscription = null;
		_eventSubscriptionsSource.flushCache();
	}

	public void fullCleanBean() {
		event = null;

		clearState();
	}

	public Event getEvent() {
		return event;
	}

	public void setEvent(Event event) {
		this.event = event;
	}

	public ArrayList<SelectItem> getMods() {
		if (event != null) {
			ArrayList<SelectItem> modsList;
			try {
				Modifier[] mods = _rulesDao.getModifiers(userSessionId, event.getScaleId());
				modsList = new ArrayList<SelectItem>(mods.length);
				for (Modifier mod : mods) {
					modsList.add(new SelectItem(mod.getId(), mod.getName()));
				}
			} catch (Exception e) {
				modsList = new ArrayList<SelectItem>(0);
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
			return modsList;
		} else {
			return new ArrayList<SelectItem>(0);
		}
	}

	public ArrayList<SelectItem> getSubscribers() {
		if (event != null) {
			ArrayList<SelectItem> subscribers;
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				Filter[] filtersList = new Filter[2];
				filtersList[0] = new Filter();
				filtersList[0].setElement("eventType");
				filtersList[0].setValue(event.getEventType());
				filtersList[1] = new Filter();
				filtersList[1].setElement("instId");
				filtersList[1].setValue(event.getInstId().toString());

				params.setFilters(filtersList);
				EventSubscriber[] subscrs = _eventsDao.getEventSubscribers(userSessionId, params);
				subscribers = new ArrayList<SelectItem>(subscrs.length);
				subscrsByProcedure = new HashMap<Integer, String>();
				for (EventSubscriber subscr : subscrs) {
					subscribers.add(new SelectItem(subscr.getId(), subscr.getProcessName()));
					subscrsByProcedure.put(subscr.getId(), subscr.getProcedureName());
				}
			} catch (Exception e) {
				subscribers = new ArrayList<SelectItem>(0);
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
			return subscribers;
		} else {
			return new ArrayList<SelectItem>(0);
		}
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

	public List<SelectItem> getContainers() {
		if(newSubscription != null && newSubscription.getSubscrId()!=null){
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("procedure_name", subscrsByProcedure.get(newSubscription.getSubscrId()));
			return getDictUtils().getLov(LovConstants.CONTAINERS_BY_PROCEDURENAME, params);
		}else{
			return new ArrayList<SelectItem>();
		}
	}

}

package ru.bpc.sv2.ui.common.events;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.events.Event;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.rules.RuleSet;
import ru.bpc.sv2.rules.RulesCategory;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbEventsSearch")
public class MbEventsSearch extends AbstractBean {
	private static final long serialVersionUID = 3597367353047865386L;

	private static final Logger logger = Logger.getLogger("EVENTS");

	private static String COMPONENT_ID = "1292:eventsTable";

	private EventsDao _eventsDao = new EventsDao();

	private RulesDao _rulesDao = new RulesDao();

	private Event filter;
	private Event _activeEvent;
	private Event newEvent;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> ruleSets;

	private final DaoDataModel<Event> _eventsSource;

	private final TableRowSelection<Event> _itemSelection;
	
	private String tabName;

	public MbEventsSearch() {
		pageLink = "common|events|events";
		_eventsSource = new DaoDataModel<Event>() {
			private static final long serialVersionUID = 5607939169014333981L;

			@Override
			protected Event[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Event[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEvents(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Event[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Event>(null, _eventsSource);
		tabName = "ruleSetsTab";
	}

	public DaoDataModel<Event> getEvents() {
		return _eventsSource;
	}

	public Event getActiveEvent() {
		return _activeEvent;
	}

	public void setActiveEvent(Event activeEvent) {
		_activeEvent = activeEvent;
	}

	public SimpleSelection getItemSelection() {
		if (_activeEvent == null && _eventsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeEvent != null && _eventsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeEvent.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeEvent = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_eventsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeEvent = (Event) _eventsSource.getRowData();
		selection.addKey(_activeEvent.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeEvent = _itemSelection.getSingleSelection();
		if (_activeEvent != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void setBeans() {
		MbEventRuleSets ruleSetsBean = (MbEventRuleSets) ManagedBeanWrapper
				.getManagedBean("MbEventRuleSets");
		ruleSetsBean.setEventId(_activeEvent.getId());
		ruleSetsBean.setScaleId(_activeEvent.getScaleId());
		ruleSetsBean.search();

		MbEventSubscriptions subscrBean = (MbEventSubscriptions) ManagedBeanWrapper
				.getManagedBean("MbEventSubscriptions");
		subscrBean.setEvent(_activeEvent);
		subscrBean.search();
	}

	public void clearBeansStates() {
		MbEventRuleSets ruleSetsBean = (MbEventRuleSets) ManagedBeanWrapper
				.getManagedBean("MbEventRuleSets");
		ruleSetsBean.fullCleanBean();
		ruleSetsBean.setSearching(false);

		MbEventSubscriptions subscrBean = (MbEventSubscriptions) ManagedBeanWrapper
				.getManagedBean("MbEventSubscriptions");
		subscrBean.fullCleanBean();
		subscrBean.setSearching(false);
	}

	public void clearFilter() {
		filter = null;

		clearState();
		clearBeansStates();
		searching = false;
	}

	public Event getFilter() {
		if (filter == null) {
			filter = new Event();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Event filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getEventType() != null && filter.getEventType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("eventType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEventType());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newEvent = new Event();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newEvent = (Event) _activeEvent.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newEvent = _activeEvent;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newEvent = _eventsDao.addEvent(userSessionId, newEvent, userLang);
				_itemSelection.addNewObjectToList(newEvent);
			} else if (isEditMode()) {
				newEvent = _eventsDao.modifyEvent(userSessionId, newEvent, userLang);
				_eventsSource.replaceObject(_activeEvent, newEvent);
			}
			_activeEvent = newEvent;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_eventsDao.deleteEvent(userSessionId, _activeEvent);
			_activeEvent = _itemSelection.removeObjectFromList(_activeEvent);

			if (_activeEvent == null) {
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

	public void close() {
		curMode = VIEW_MODE;
	}

	public Event getNewEvent() {
		if (newEvent == null) {
			newEvent = new Event();
		}
		return newEvent;
	}

	public void setNewEvent(Event newEvent) {
		this.newEvent = newEvent;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeEvent = null;
		_eventsSource.flushCache();
		
		clearBeansStates();
	}

	public List<SelectItem> getEventTypes() {
		List<SelectItem> result = getDictUtils().getLov(LovConstants.EVENT_TYPES);
		return result;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeEvent.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Event[] events = _eventsDao.getEvents(userSessionId, params);
			if (events != null && events.length > 0) {
				_activeEvent = events[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getRuleSets() {
		if (ruleSets == null) {

			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				paramFilter = new Filter();
				paramFilter.setElement("category");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(RulesCategory.EVENT);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
				RuleSet[] ruleSetsTmp = _rulesDao.getRuleSets(userSessionId, params);
				for (RuleSet set : ruleSetsTmp) {
					items.add(new SelectItem(set.getId(), set.getName()));
				}
				ruleSets = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (ruleSets == null)
					ruleSets = new ArrayList<SelectItem>();
			}
		}
		return ruleSets;
	}

	public ArrayList<SelectItem> getScales() {
		if (newEvent == null || newEvent.getInstId() == null) {
			return new ArrayList<SelectItem>(0);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);

		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("instId");
		filters[0].setValue(newEvent.getInstId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);
		filters[2] = new Filter();
		filters[2].setElement("scaleType");
		filters[2].setValue(ScaleConstants.SCALE_FOR_EVENT);
		params.setFilters(filters);

		ModScale[] scales;
		try {
			scales = _rulesDao.getModScales(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}

		ArrayList<SelectItem> items = new ArrayList<SelectItem>(scales.length);
		for (ModScale scale : scales) {
			items.add(new SelectItem(scale.getId(), scale.getName()));
		}
		return items;
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
		
		if (tabName.equalsIgnoreCase("subscriptionTab")) {
			MbEventSubscriptions bean = (MbEventSubscriptions) ManagedBeanWrapper
					.getManagedBean("MbEventSubscriptions");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.OPERATION_EVENT_EVENT;
	}

	public boolean forbidEditScale() {
		if (isEditMode()) {
			try {
				List<Filter> filters = new ArrayList<Filter>();
				filters.add(Filter.create("eventId", newEvent.getId().toString()));
				filters.add(Filter.create("modIdNotNull", true));

				SelectionParams params = new SelectionParams();
				params.setFilters(Filter.asArray(filters));
				if (_eventsDao.getEventSubscriptionsCount(userSessionId, params) <= 0) {
					return (_eventsDao.getEventRuleSetsCount(userSessionId, params) > 0);
				} else {
					return true;
				}
			} catch (Exception e) {
				logger.error(e.getMessage(), e);
			}
		}
		return false;
	}
}

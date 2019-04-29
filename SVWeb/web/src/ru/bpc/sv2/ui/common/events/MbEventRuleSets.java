package ru.bpc.sv2.ui.common.events;

import java.util.ArrayList;

import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.events.EventRuleSet;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.rules.RuleSet;
import ru.bpc.sv2.rules.RulesCategory;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbEventRuleSets")
public class MbEventRuleSets extends AbstractBean {
	private static final long serialVersionUID = 5935640666258316921L;

	private static final Logger logger = Logger.getLogger("EVENTS");

	private EventsDao _eventsDao = new EventsDao();

	private RulesDao _rulesDao = new RulesDao();

	private Integer eventId;
	private Integer scaleId;

	private ArrayList<SelectItem> ruleSets;

	private EventRuleSet filter;
	private EventRuleSet _activeEventRuleSet;
	private EventRuleSet newEventRuleSet;

	private final DaoDataModel<EventRuleSet> _eventRuleSetsSource;

	private final TableRowSelection<EventRuleSet> _itemSelection;
	
	private static String COMPONENT_ID = "ersTable";
	private String tabName;
	private String parentSectionId;

	public MbEventRuleSets() {
		_eventRuleSetsSource = new DaoDataModel<EventRuleSet>() {
			private static final long serialVersionUID = -1306144206391907005L;

			@Override
			protected EventRuleSet[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new EventRuleSet[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventRuleSets(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new EventRuleSet[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventRuleSetsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<EventRuleSet>(null, _eventRuleSetsSource);
	}

	public DaoDataModel<EventRuleSet> getEventRuleSets() {
		return _eventRuleSetsSource;
	}

	public EventRuleSet getActiveEventRuleSet() {
		return _activeEventRuleSet;
	}

	public void setActiveEventRuleSet(EventRuleSet activeEventRuleSet) {
		_activeEventRuleSet = activeEventRuleSet;
	}

	public SimpleSelection getItemSelection() {
		if (_activeEventRuleSet == null && _eventRuleSetsSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeEventRuleSet != null && _eventRuleSetsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeEventRuleSet.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeEventRuleSet = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_eventRuleSetsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeEventRuleSet = (EventRuleSet) _eventRuleSetsSource.getRowData();
		selection.addKey(_activeEventRuleSet.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeEventRuleSet != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeEventRuleSet = _itemSelection.getSingleSelection();
		if (_activeEventRuleSet != null) {
			// setInfo();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new EventRuleSet();

		clearState();
		searching = false;
	}

	public EventRuleSet getFilter() {
		if (filter == null)
			filter = new EventRuleSet();
		return filter;
	}

	public void setFilter(EventRuleSet filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("eventId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(eventId.toString());
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public void add() {
		newEventRuleSet = new EventRuleSet();
		newEventRuleSet.setEventId(eventId);

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newEventRuleSet = (EventRuleSet) _activeEventRuleSet.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newEventRuleSet = _activeEventRuleSet;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newEventRuleSet = _eventsDao.addEventRuleSet(userSessionId, newEventRuleSet,
						userLang);
				_itemSelection.addNewObjectToList(newEventRuleSet);
			} else if (isEditMode()) {
				newEventRuleSet = _eventsDao.editEventRuleSet(userSessionId, newEventRuleSet,
						userLang);
				_eventRuleSetsSource.replaceObject(_activeEventRuleSet, newEventRuleSet);
			}
			_activeEventRuleSet = newEventRuleSet;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_eventsDao.deleteEventRuleSet(userSessionId, _activeEventRuleSet);
			_activeEventRuleSet = _itemSelection.removeObjectFromList(_activeEventRuleSet);
			if (_activeEventRuleSet == null) {
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

	public EventRuleSet getNewEventRuleSet() {
		if (newEventRuleSet == null) {
			newEventRuleSet = new EventRuleSet();
		}
		return newEventRuleSet;
	}

	public void setNewEventRuleSet(EventRuleSet newEventRuleSet) {
		this.newEventRuleSet = newEventRuleSet;
	}

	private void setBeans() {

	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeEventRuleSet = null;
		_eventRuleSetsSource.flushCache();
	}

	public void fullCleanBean() {
		eventId = null;
		scaleId = null;

		clearState();
	}

	public Integer getEventId() {
		return eventId;
	}

	public void setEventId(Integer eventId) {
		this.eventId = eventId;
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

	public Integer getScaleId() {
		return scaleId;
	}

	public void setScaleId(Integer scaleId) {
		this.scaleId = scaleId;
	}

	public ArrayList<SelectItem> getMods() {
		ArrayList<SelectItem> modsList;
		if (scaleId != null) {
			try {
				Modifier[] mods = _rulesDao.getModifiers(userSessionId, scaleId);
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
		} else {
			modsList = new ArrayList<SelectItem>(0);
		}
		return modsList;
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
	
	@Override
	public String getTableState() {
		MbEventsSearch bean = (MbEventsSearch) ManagedBeanWrapper
				.getManagedBean("MbEventsSearch");
		if (bean != null) {
			setTabName(bean.getTabName());
			setParentSectionId(bean.getSectionId());
		}
		return super.getTableState();
	}
}

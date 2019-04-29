package ru.bpc.sv2.ui.common.events;

import java.util.ArrayList;
import java.util.List;


import javax.faces.application.FacesMessage;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.component.UIComponent;
import javax.faces.component.UIInput;
import javax.faces.context.FacesContext;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.common.events.EventSubscriber;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbEventSubscribers")
public class MbEventSubscribers extends AbstractBean {
	private static final Logger logger = Logger.getLogger("EVENTS");

	private EventsDao _eventsDao = new EventsDao();

	

	private String eventType;

	private EventSubscriber filter;
	private EventSubscriber _activeSubscriber;
	private EventSubscriber newSubscriber;
	
	private List<SelectItem> processes = null;
	private List<SelectItem> eventTypes = null;
	private List<SelectItem> entityTypes = null;
	

	private final DaoDataModel<EventSubscriber> _subscribersSource;

	private final TableRowSelection<EventSubscriber> _itemSelection;
	
	private static String COMPONENT_ID = "subscribersTable";
	private String tabName;
	private String parentSectionId;

	public MbEventSubscribers() {
		
		
		_subscribersSource = new DaoDataModel<EventSubscriber>() {
			@Override
			protected EventSubscriber[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new EventSubscriber[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventSubscribers(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new EventSubscriber[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _eventsDao.getEventSubscribersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<EventSubscriber>(null, _subscribersSource);
	}

	public DaoDataModel<EventSubscriber> getSubscribers() {
		return _subscribersSource;
	}

	public EventSubscriber getActiveSubscriber() {
		return _activeSubscriber;
	}

	public void setActiveSubscriber(EventSubscriber activeSubscriber) {
		_activeSubscriber = activeSubscriber;
	}

	public SimpleSelection getItemSelection() {
		if (_activeSubscriber == null && _subscribersSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeSubscriber != null && _subscribersSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeSubscriber.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeSubscriber = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_subscribersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSubscriber = (EventSubscriber) _subscribersSource.getRowData();
		selection.addKey(_activeSubscriber.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeSubscriber != null) {
			// setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSubscriber = _itemSelection.getSingleSelection();
		if (_activeSubscriber != null) {
			// setInfo();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new EventSubscriber();

		clearState();
		searching = false;
	}

	public EventSubscriber getFilter() {
		if (filter == null)
			filter = new EventSubscriber();
		return filter;
	}

	public void setFilter(EventSubscriber filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("eventType");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(eventType);
		filters.add(paramFilter);
	}

	public void add() {
		newSubscriber = new EventSubscriber();
		newSubscriber.setEventType(eventType);

		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSubscriber = (EventSubscriber) _activeSubscriber.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newSubscriber = _activeSubscriber;
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			validatePriority();
			
			if (isNewMode()) {
				newSubscriber = _eventsDao.addEventSubscriber(userSessionId, newSubscriber);
				_itemSelection.addNewObjectToList(newSubscriber);
			} else if (isEditMode()) {
				newSubscriber = _eventsDao.modifyEventSubscriber(userSessionId, newSubscriber);
				_subscribersSource.replaceObject(_activeSubscriber, newSubscriber);
			}
			_activeSubscriber = newSubscriber;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_eventsDao.deleteEventSubscriber(userSessionId, _activeSubscriber);
			_activeSubscriber = _itemSelection.removeObjectFromList(_activeSubscriber);
			if (_activeSubscriber == null) {
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

	public EventSubscriber getNewSubscriber() {
		if (newSubscriber == null) {
			newSubscriber = new EventSubscriber();
		}
		return newSubscriber;
	}

	public void setNewSubscriber(EventSubscriber newSubscriber) {
		this.newSubscriber = newSubscriber;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeSubscriber = null;
		_subscribersSource.flushCache();
		curLang = userLang;
	}

	private void setBeans() {

	}

	public List<SelectItem> getEntityTypes() {
		if (entityTypes == null) {
			entityTypes = getDictUtils().getLov(LovConstants.ENTITY_TYPES);
		}
		return entityTypes;
	}

	public List<SelectItem> getEventTypes() {
		if (eventTypes == null) {
			eventTypes = getDictUtils().getLov(LovConstants.EVENT_TYPES_DICT);
		}
		return eventTypes;
	}

	public String getEventType() {
		return eventType;
	}

	public void setEventType(String eventType) {
		this.eventType = eventType;
	}

	public List<SelectItem> getProcesses() {
		if (processes == null) {
			processes = getDictUtils().getLov(LovConstants.PROCESS_PROCEDURES);
		}
		return processes;
	}

	private void validatePriority() throws Exception {
		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("procedureName");
		filters[0].setValue(newSubscriber.getProcedureName());
		filters[1] = new Filter();
		filters[1].setElement("eventType");
		filters[1].setValue(newSubscriber.getEventType());
		filters[2] = new Filter();
		filters[2].setElement("priority");
		filters[2].setValue(newSubscriber.getPriority().toString());

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);

		EventSubscriber result = _eventsDao.checkSubscription(userSessionId,  newSubscriber);

		//EventSubscriber[] subscrs = _eventsDao.getEventSubscribers(userSessionId, params);
		if (result != null) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"change_evt_proc_priority",
					result.getEventType() + " - " +
							getDictUtils().getAllArticlesDesc().get(result.getEventType()));
			throw new Exception(msg);
		}
	}

	public void validateProcess(FacesContext context, UIComponent toValidate, Object value) {
		String procedureName = (String) value;
		FacesMessage message = null;

		if (procedureName != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("eventType");
			filters[0].setValue(eventType);
			filters[1] = new Filter();
			filters[1].setElement("procedureName");
			filters[1].setValue(procedureName.toUpperCase());

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);

			try {
				EventSubscriber[] subscrs = _eventsDao.getEventSubscribers(userSessionId, params);
				if (subscrs.length > 0) {
					((UIInput) toValidate).setValid(false);

					String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
							"choose_another_procedure");
					message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
					context.addMessage(toValidate.getClientId(context), message);
				}
			} catch (Exception e) {
				((UIInput) toValidate).setValid(false);

				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "unknown_error");
				message = new FacesMessage(FacesMessage.SEVERITY_ERROR, msg, msg);
				context.addMessage(toValidate.getClientId(context), message);
				logger.error("", e);
			}
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
	
	@Override
	public String getTableState() {
		MbEventTypes bean = (MbEventTypes) ManagedBeanWrapper
				.getManagedBean("MbEventTypes");
		if (bean != null) {
			setTabName(bean.getTabName());
			setParentSectionId(bean.getSectionId());
		}
		return super.getTableState();
	}
}

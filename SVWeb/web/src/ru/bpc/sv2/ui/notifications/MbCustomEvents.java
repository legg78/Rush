package ru.bpc.sv2.ui.notifications;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.notifications.CustomEvent;
import ru.bpc.sv2.notifications.SchemeEvent;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCustomEvents")
public class MbCustomEvents extends AbstractBean {
	private static final long serialVersionUID = 8462600356086408678L;

	private static final Logger logger = Logger.getLogger("NOTIFICATION");

	private static String COMPONENT_ID = "1613:customEventsTable";

	private NotificationsDao _notificationsDao = new NotificationsDao();

	private RulesDao _rulesDao = new RulesDao();

	private CustomEvent filter;
	private CustomEvent newCustomEvent;
	private Integer notifSchemeId;

	private final DaoDataModel<CustomEvent> _customEventSource;
	private final TableRowSelection<CustomEvent> _itemSelection;
	private CustomEvent _activeCustomEvent;
	private String tabName;
	private ArrayList<SelectItem> institutions;
	private List<SelectItem>statuses;

	private HashMap<Integer, SchemeEvent> schemeEvents;
	private String eventOwnerEntityType; 
	
	public MbCustomEvents() {
		initFilter();
		pageLink = "notifications|custom";
		_customEventSource = new DaoDataModel<CustomEvent>() {
			private static final long serialVersionUID = -6158044942777071717L;

			@Override
			protected CustomEvent[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new CustomEvent[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (EntityNames.ROLE.equals(eventOwnerEntityType)) {
						return _notificationsDao.getRoleCustomEvents(userSessionId, params);
					} else if (EntityNames.USER.equals(eventOwnerEntityType)) {
						return _notificationsDao.getUserCustomEvents(userSessionId, params);
					}
					return _notificationsDao.getCustomEvents(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);					
				}
				return new CustomEvent[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if (EntityNames.ROLE.equals(eventOwnerEntityType)) {
						return _notificationsDao.getRoleCustomEventsCount(userSessionId, params);
					} else if (EntityNames.USER.equals(filter.getEntityType())) {
						return _notificationsDao.getUserCustomEventsCount(userSessionId, params);
					}
					return _notificationsDao.getCustomEventsCount(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);					
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CustomEvent>(null, _customEventSource);
	}

	public DaoDataModel<CustomEvent> getCustomEvents() {
		return _customEventSource;
	}

	public CustomEvent getActiveCustomEvent() {
		return _activeCustomEvent;
	}

	public void setActiveCustomEvent(CustomEvent activeCustomEvent) {
		_activeCustomEvent = activeCustomEvent;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCustomEvent == null && _customEventSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCustomEvent != null && _customEventSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCustomEvent.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCustomEvent = _itemSelection.getSingleSelection();
			}
			return _itemSelection.getWrappedSelection();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return null;
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCustomEvent = _itemSelection.getSingleSelection();

		if (_activeCustomEvent != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_customEventSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomEvent = (CustomEvent) _customEventSource.getRowData();
		selection.addKey(_activeCustomEvent.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeCustomEvent != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbCustomObjects objects = (MbCustomObjects) ManagedBeanWrapper
				.getManagedBean("MbCustomObjects");
		objects.setCustomEventId(_activeCustomEvent.getId());
		objects.search();
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	/**
	 * Clears bean's internal data, filtering conditions and <code>notifSchemeId</code>.
	 */
	public void fullCleanBean() {
		notifSchemeId = null;
		clearFilter();
	}
	
	/**
	 * Clears bean's internal data without cleaning filter conditions 
	 */
	public void clearBean() {
		_customEventSource.flushCache();
		_itemSelection.clearSelection();
		_activeCustomEvent = null;

		// clear dependent bean
		MbCustomObjects objects = (MbCustomObjects) ManagedBeanWrapper
				.getManagedBean("MbCustomObjects");
		objects.clearBean();
	}

	/**
	 * Clears all bean's internal data and then inits filter with default values. 
	 */
	public void resetFilter() {
		clearFilter();
		initFilter();
	}
	
	/**
	 * Clears bean's internal data and filtering conditions. 
	 */
	public void clearFilter() {
		curLang = userLang;
		filter = null;
		clearBean();
		searching = false;
	}

	private void initFilter() {
		filter = new CustomEvent();
		filter.setInstId(userInstId);
	}
	
	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getChannelId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("channelId");
			paramFilter.setValue(filter.getChannelId().toString());
			filters.add(paramFilter);
		}
		if (filter.getEventType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("eventType");
			paramFilter.setValue(filter.getEventType());
			filters.add(paramFilter);
		}
		if (filter.getActive() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("active");
			paramFilter.setValue(filter.getActive() ? "1" : "0");
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getEntityNumber() != null && !filter.getEntityNumber().trim().isEmpty()) {
			paramFilter = new Filter();
			paramFilter.setElement("entityNumber");
			paramFilter.setValue(filter.getEntityNumber());
			filters.add(paramFilter);
		}
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setValue(filter.getStatus());
			filters.add(paramFilter);
		}
		if (notifSchemeId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("notifSchemeId");
			paramFilter.setValue(notifSchemeId.toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCustomEvent = new CustomEvent();
		newCustomEvent.setEntityType(eventOwnerEntityType);
		newCustomEvent.setObjectId(filter.getObjectId());
		if (filter.getInstId() != null) {
			newCustomEvent.setInstId(filter.getInstId());
		}
		newCustomEvent.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCustomEvent = (CustomEvent) _activeCustomEvent.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCustomEvent = _activeCustomEvent;
		}
		if (eventOwnerEntityType != null) {
			newCustomEvent.setEntityType(eventOwnerEntityType);
		}
		curMode = EDIT_MODE;
	}
	
	public void set() {
		try {
			newCustomEvent = (CustomEvent) _activeCustomEvent.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCustomEvent = _activeCustomEvent;
		}

		if (newCustomEvent.getId() == null) {
			curMode = NEW_MODE;
			newCustomEvent.setEntityType(eventOwnerEntityType);
			newCustomEvent.setObjectId(filter.getObjectId());
			if (filter.getInstId() != null) {
				newCustomEvent.setInstId(filter.getInstId());
			}
		} else {
			newCustomEvent.setEntityType(eventOwnerEntityType);
			curMode = EDIT_MODE;
		}
	}

	public void delete() {
		try {
			_notificationsDao.deleteCustomEvent(userSessionId, _activeCustomEvent);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"scheme_deleted", "(id = " + _activeCustomEvent.getId() + ")");

			clearBean();

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
//			if (newCustomEvent.getFromHour().compareTo(newCustomEvent.getToHour()) > 0) {
//				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
//						"wrong_delivery_period"));
//			}
			newCustomEvent.setDeliveryTime(newCustomEvent.getFromHour() + "-"
					+ newCustomEvent.getToHour());

			newCustomEvent = _notificationsDao.setCustomEvent(userSessionId, newCustomEvent);
			
			_customEventSource.replaceObject(_activeCustomEvent, newCustomEvent);
			_activeCustomEvent = newCustomEvent;
			
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"custom_event_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public CustomEvent getFilter() {
		if (filter == null) {
			filter = new CustomEvent();
		}
		return filter;
	}

	public void setFilter(CustomEvent filter) {
		this.filter = filter;
	}

	public CustomEvent getNewCustomEvent() {
		if (newCustomEvent == null) {
			newCustomEvent = new CustomEvent();
		}
		return newCustomEvent;
	}

	public void setNewCustomEvent(CustomEvent newCustomEvent) {
		this.newCustomEvent = newCustomEvent;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("objectsTab")) {
			MbCustomObjects bean = (MbCustomObjects) ManagedBeanWrapper
					.getManagedBean("MbCustomObjects");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_NOTIF_EVENT;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeCustomEvent != null) {
			curLang = (String) event.getNewValue();
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeCustomEvent.getId());
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(curLang);
			filtersList.add(paramFilter);

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(Integer.MAX_VALUE);
			try {
				CustomEvent[] events;
				if (EntityNames.ROLE.equals(eventOwnerEntityType)) {
					events = _notificationsDao.getRoleCustomEvents(userSessionId, params);
				} else if (EntityNames.USER.equals(eventOwnerEntityType)) {
					events = _notificationsDao.getUserCustomEvents(userSessionId, params);
				} else {
					events = _notificationsDao.getCustomEvents(userSessionId, params);
				}
						
				if (events != null && events.length > 0) {
					_activeCustomEvent = events[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public List<SelectItem> getStatuses(){
		if (statuses == null){
			statuses = getDictUtils().getLov(LovConstants.NTF_CUSTOM_EVENT_STATUS);
		}
		return statuses;
	}

	public ArrayList<SelectItem> getChannels() {
		ArrayList<SelectItem> items = null;

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		params.setFilters(filters);

		try {
			Channel[] channels = _notificationsDao.getChannels(userSessionId, params);
			items = new ArrayList<SelectItem>(channels.length);
			for (Channel channel : channels) {
				items.add(new SelectItem(channel.getId(), channel.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}

	public ArrayList<SelectItem> getEventTypes() {
		return getDictUtils().getArticles(DictNames.EVENT_TYPES, false);
	}

	private List<SelectItem> notificationEventTypes = null;
	
	public List<SelectItem> getNotificationEventTypes(){
		if (notificationEventTypes == null){
			notificationEventTypes = getDictUtils().getLov(LovConstants.EVENT_TYPE_NOTIF);
			for (SelectItem item : notificationEventTypes){
				item.setLabel(String.format("%s - %s", item.getValue(), item.getLabel()));
			}
		}
		return notificationEventTypes;
	}
	
	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> modsList;
		if (schemeEvents != null && getNewCustomEvent().getSchemeEventId() != null) {
			try {
				Modifier[] mods = _rulesDao.getModifiers(userSessionId, schemeEvents.get(
						newCustomEvent.getSchemeEventId()).getScaleId());
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

	public ArrayList<SelectItem> getHours() {
		ArrayList<SelectItem> hours = new ArrayList<SelectItem>(24);
		for (int i = 0; i < 24; i++) {
			hours.add(new SelectItem(i + "", i + ""));
		}
		return hours;
	}

	public Integer getNotifSchemeId() {
		return notifSchemeId;
	}

	public void setNotifSchemeId(Integer notifSchemeId) {
		this.notifSchemeId = notifSchemeId;
	}

	public String getEventOwnerEntityType() {
		return eventOwnerEntityType;
	}

	/**
	 * <p>
	 * Sets a real owner of event because e.g. roles' events have entity type 
	 * "ENTTUSER" because it's a user type event, but when we add event we 
	 * should pass entity type "ENTTROLE" to save event correctly.
	 * </p><p>
	 * Entity type for filtering should be set via <code>getFilter()</code>
	 * </p>
	 * @param eventOwnerEntityType
	 */
	public void setEventOwnerEntityType(String eventOwnerEntityType) {
		this.eventOwnerEntityType = eventOwnerEntityType;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}

package ru.bpc.sv2.ui.notifications;

import java.util.ArrayList;


import java.util.List;


import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.notifications.Notification;
import ru.bpc.sv2.notifications.Scheme;
import ru.bpc.sv2.notifications.SchemeEvent;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbSchemeEvents")
public class MbSchemeEvents extends AbstractBean{
	private static final long serialVersionUID = -8601663868519698442L;

	private static final Logger logger = Logger.getLogger("NOTIFICATION");

	private NotificationsDao _notificationsDao = new NotificationsDao();

	private RulesDao _rulesDao = new RulesDao();
	
	private RolesDao _rolesDao = new RolesDao();

	private SchemeEvent filter;
	private SchemeEvent newSchemeEvent;
	
	private List<SelectItem> eventTypes;
	private List<SelectItem> statuses;

	private Scheme scheme;
	
	private final String USER_NOTIFICATION = "NTFS0020";

	private final DaoDataModel<SchemeEvent> _schemeEventSource;
	private final TableRowSelection<SchemeEvent> _itemSelection;
	private SchemeEvent _activeSchemeEvent;
	private String tabName;
	private boolean blockEntityType;
	
	private static String COMPONENT_ID = "schemeEventsTable";
	private static int HARD_COPY_ID = 2;
	private String parentSectionId;
	
	public MbSchemeEvents() {
		_schemeEventSource = new DaoDataModel<SchemeEvent>() {
			private static final long serialVersionUID = 2406408977761139801L;

			@Override
			protected SchemeEvent[] loadDaoData(SelectionParams params) {
				if (scheme == null || !searching) {
					return new SchemeEvent[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getSchemeEvents(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new SchemeEvent[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (scheme == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getSchemeEventsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<SchemeEvent>(null, _schemeEventSource);
	}

	public DaoDataModel<SchemeEvent> getSchemeEvents() {
		return _schemeEventSource;
	}

	public SchemeEvent getActiveSchemeEvent() {
		return _activeSchemeEvent;
	}

	public void setActiveSchemeEvent(SchemeEvent activeSchemeEvent) {
		_activeSchemeEvent = activeSchemeEvent;
	}

	public SimpleSelection getItemSelection() {
		if (_activeSchemeEvent == null && _schemeEventSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeSchemeEvent != null && _schemeEventSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeSchemeEvent.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeSchemeEvent = _itemSelection.getSingleSelection();
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeSchemeEvent = _itemSelection.getSingleSelection();

		if (_activeSchemeEvent != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_schemeEventSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSchemeEvent = (SchemeEvent) _schemeEventSource.getRowData();
		selection.addKey(_activeSchemeEvent.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeSchemeEvent != null) {
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
		filter = new SchemeEvent();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("schemeId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(scheme.getId().toString());
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getNotificationId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("notifId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getNotificationId().toString());
			filters.add(paramFilter);
		}
		if (filter.getChannelId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("channelId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getChannelId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newSchemeEvent = new SchemeEvent();
		newSchemeEvent.setSchemeId(scheme.getId());
		if (USER_NOTIFICATION.equals(scheme.getSchemeType())) {
			newSchemeEvent.setEntityType(EntityNames.USER);
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSchemeEvent = (SchemeEvent) _activeSchemeEvent.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newSchemeEvent = _activeSchemeEvent;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		// check if Scheme event is being in use
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("notifSchemeId");
		filters[0].setValue(_activeSchemeEvent.getSchemeId());
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			ComplexRole[] result = _rolesDao
					.getRolesUnassignedToObject(userSessionId, params);
			if (result != null && result.length > 0) {
				FacesUtils.addMessageError("Scheme event is in use.");
				return;
			}
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		
		try {
			_notificationsDao.deleteSchemeEvent(userSessionId, _activeSchemeEvent);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf", "scheme_event_deleted",
					"(id = " + _activeSchemeEvent.getId() + ")");

			_activeSchemeEvent = _itemSelection.removeObjectFromList(_activeSchemeEvent);
			if (_activeSchemeEvent == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
//			if (newSchemeEvent.getFromHour().compareTo(newSchemeEvent.getToHour()) > 0) {
//				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
//						"wrong_delivery_period"));
//			}
			newSchemeEvent.setDeliveryTime(newSchemeEvent.getFromHour() + "-"
					+ newSchemeEvent.getToHour());
			if (isNewMode()) {
				newSchemeEvent = _notificationsDao.addSchemeEvent(userSessionId, newSchemeEvent,
						userLang);
				_itemSelection.addNewObjectToList(newSchemeEvent);
			} else {
				newSchemeEvent = _notificationsDao.editSchemeEvent(userSessionId, newSchemeEvent,
						userLang);
				_schemeEventSource.replaceObject(_activeSchemeEvent, newSchemeEvent);
			}
			_activeSchemeEvent = newSchemeEvent;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"scheme_event_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public SchemeEvent getFilter() {
		if (filter == null) {
			filter = new SchemeEvent();
		}
		return filter;
	}

	public void setFilter(SchemeEvent filter) {
		this.filter = filter;
	}

	public SchemeEvent getNewSchemeEvent() {
		if (newSchemeEvent == null) {
			newSchemeEvent = new SchemeEvent();
		}
		return newSchemeEvent;
	}

	public void setNewSchemeEvent(SchemeEvent newSchemeEvent) {
		this.newSchemeEvent = newSchemeEvent;
	}

	public void clearBean() {
		_schemeEventSource.flushCache();
		_itemSelection.clearSelection();
		_activeSchemeEvent = null;

		// clear dependent bean
	}

	public void fullCleanBean() {
		clearBean();
		scheme = null;
		filter = null;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public List<SelectItem> getEventTypes() {
		if (eventTypes == null) {
			eventTypes = getDictUtils().getLov(LovConstants.EVENT_TYPES);
		}
		return eventTypes;
	}
	
	public List<SelectItem> getStatuses(){
		if (statuses == null || (newSchemeEvent != null && newSchemeEvent.getEntityType()!= null 
				&& !EntityNames.CUSTOMER.equals(newSchemeEvent.getEntityType()))) {
			statuses = getDictUtils().getLov(LovConstants.NTF_SCHEME_EVENT_STATUS);
		} 
		if (EntityNames.CUSTOMER.equals(newSchemeEvent.getEntityType())) {
			SelectItem removeItem = null;
			for (SelectItem item : statuses) {
				if ("NTES0020".equals(item.getValue())) {
					removeItem = item;
					break;
				}
			}
			if (removeItem != null) statuses.remove(removeItem);
		}	
		return statuses;
	}


	public List<SelectItem> getEntityTypes() {
		blockEntityType = false;
		if (scheme == null) {
			return new ArrayList<SelectItem>(0);
		}
		if (USER_NOTIFICATION.equals(scheme.getSchemeType())) {
			List<SelectItem> items = new ArrayList<SelectItem>(1);
			items.add(new SelectItem(EntityNames.USER, EntityNames.USER + " - "
					+ getDictUtils().getAllArticlesDesc().get(EntityNames.USER)));
			blockEntityType = true;
			return items;
		}
		return getDictUtils().getLov(LovConstants.SCHEME_EVENT_ENTITY_TYPES);
	}

	public Scheme getScheme() {
		return scheme;
	}

	public void setScheme(Scheme scheme) {
		this.scheme = scheme;
	}

	public ArrayList<SelectItem> getHours() {
		ArrayList<SelectItem> hours = new ArrayList<SelectItem>(24);
		for (int i = 0; i < 24; i++) {
			hours.add(new SelectItem(i + "", i + ""));
		}
		return hours;
	}

	public ArrayList<SelectItem> getNotifications() {
		if (scheme == null) {
			return new ArrayList<SelectItem>(0);
		}
		
		ArrayList<SelectItem> items = null;
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("eventType");
			filters[1].setValue(getNewSchemeEvent().getEventType());
			filters[2] = new Filter();
			filters[2].setElement("instId");
			filters[2].setValue(scheme.getInstId().toString());

			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			Notification[] notifs = _notificationsDao.getNotifications(userSessionId, params);
			items = new ArrayList<SelectItem>(notifs.length);
			for (Notification notif: notifs) {
				items.add(new SelectItem(notif.getId(), notif.getName()));
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

	public ArrayList<SelectItem> getChannels() {
		if (getNewSchemeEvent().getNotificationId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		
		ArrayList<SelectItem> items = null;
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("notifId");
			filters[1].setValue(newSchemeEvent.getNotificationId().toString());

			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			Channel[] channels = _notificationsDao.getChannels(userSessionId, params);
			items = new ArrayList<SelectItem>(channels.length);
			for (Channel channel: channels) {
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

	public ArrayList<SelectItem> getScales() {
		if (scheme == null) {
			return new ArrayList<SelectItem>(0);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);

		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("scaleType");
		filters[1].setValue("SCTPNTFC"); // TODO: set as constant?
		filters[2] = new Filter();
		filters[2].setElement("instId");
		filters[2].setValue(scheme.getInstId().toString());
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
		for (ModScale scale: scales) {
			items.add(new SelectItem(scale.getId(), scale.getName()));
		}
		return items;
	}

	public ArrayList<SelectItem> getContactTypes() {
		if(newSchemeEvent.getChannelId() != null) {
			if (newSchemeEvent.getChannelId() == HARD_COPY_ID) {
				return getDictUtils().getArticles(DictNames.ADDRESS_TYPE, false);
			} else return getDictUtils().getArticles(DictNames.CONTACT_TYPE, false);
		}
		else return new ArrayList<SelectItem>(0);
	}

	public boolean isBlockEntityType() {
		return blockEntityType;
	}

	public void setBlockEntityType(boolean blockEntityType) {
		this.blockEntityType = blockEntityType;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}

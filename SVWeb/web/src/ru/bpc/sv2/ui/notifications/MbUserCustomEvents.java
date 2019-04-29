package ru.bpc.sv2.ui.notifications;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.notifications.SchemeEvent;
import ru.bpc.sv2.notifications.UserCustomEvent;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbUserCustomEvents")
@Deprecated
public class MbUserCustomEvents extends AbstractBean {
	private static final long serialVersionUID = -8159088710893090259L;

	private static final Logger logger = Logger.getLogger("NOTIFICATION");

	private NotificationsDao _notificationsDao = new NotificationsDao();

	private RulesDao _rulesDao = new RulesDao();

	private UserCustomEvent filter;
	private UserCustomEvent newUserCustomEvent;

	private final DaoDataModel<UserCustomEvent> _userCustomEventSource;
	private final TableRowSelection<UserCustomEvent> _itemSelection;
	private UserCustomEvent _activeUserCustomEvent;
	private String tabName;

	private HashMap<Integer, SchemeEvent> schemeEvents;

	public MbUserCustomEvents() {
		_userCustomEventSource = new DaoDataModel<UserCustomEvent>() {
			private static final long serialVersionUID = 8100941092479969904L;

			@Override
			protected UserCustomEvent[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new UserCustomEvent[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					// return _notificationsDao.getUserCustomEvents(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new UserCustomEvent[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getUserCustomEventsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<UserCustomEvent>(null, _userCustomEventSource);
	}

	public DaoDataModel<UserCustomEvent> getUserCustomEvents() {
		return _userCustomEventSource;
	}

	public UserCustomEvent getActiveUserCustomEvent() {
		return _activeUserCustomEvent;
	}

	public void setActiveUserCustomEvent(UserCustomEvent activeUserCustomEvent) {
		_activeUserCustomEvent = activeUserCustomEvent;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeUserCustomEvent == null && _userCustomEventSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeUserCustomEvent != null && _userCustomEventSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeUserCustomEvent.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeUserCustomEvent = _itemSelection.getSingleSelection();
				setBeans();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeUserCustomEvent = _itemSelection.getSingleSelection();

		if (_activeUserCustomEvent != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_userCustomEventSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeUserCustomEvent = (UserCustomEvent) _userCustomEventSource.getRowData();
		selection.addKey(_activeUserCustomEvent.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeUserCustomEvent != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbCustomObjects objects = (MbCustomObjects) ManagedBeanWrapper
				.getManagedBean("MbCustomObjects");
		objects.setCustomEventId(_activeUserCustomEvent.getId());
		objects.search();
	}

	public void search() {
		curLang = userLang;
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		filter = new UserCustomEvent();
		searching = false;
		curLang = userLang;

		MbCustomObjects objects = (MbCustomObjects) ManagedBeanWrapper
				.getManagedBean("MbCustomObjects");
		objects.clearBean();
	}

	public void setFilters() {
		getFilter();

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
//		if (filter.getUserId() != null) {
//			paramFilter = new Filter();
//			paramFilter.setElement("userId");
//			paramFilter.setValue(filter.getUserId().toString());
//			filters.add(paramFilter);
//		}
//		if (filter.getRoleId() != null) {
//			paramFilter = new Filter();
//			paramFilter.setElement("roleId");
//			paramFilter.setValue(filter.getRoleId().toString());
//			filters.add(paramFilter);
//		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId().toString());
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
	}

	public void set() {
		try {
			newUserCustomEvent = (UserCustomEvent) _activeUserCustomEvent.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newUserCustomEvent = _activeUserCustomEvent;
		}
		
		if (newUserCustomEvent.getId() == null) {
			curMode = NEW_MODE;
		} else {
			curMode = EDIT_MODE;
			if (EntityNames.ROLE.equals(newUserCustomEvent.getEntityType())) {
				// if custom event belongs to role then if changed it must be reassigned
				// to user (create new custom event) so that not to change role's event 
				newUserCustomEvent.setId(null);
			}
		}

		// user custom event should belong to user even if it was gained through role (see up) 
		newUserCustomEvent.setObjectId(filter.getUserId().longValue());
		newUserCustomEvent.setEntityType(EntityNames.USER);
	}

	public void delete() {
		try {
			_notificationsDao.deleteCustomEvent(userSessionId, _activeUserCustomEvent);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf", "custom_event_deleted",
					"(id = " + _activeUserCustomEvent.getId() + ")");

			clearBean();
			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
//			if (newUserCustomEvent.getFromHour().compareTo(newUserCustomEvent.getToHour()) > 0) {
//				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
//						"wrong_delivery_period"));
//			}
			newUserCustomEvent.setDeliveryTime(newUserCustomEvent.getFromHour() + "-"
					+ newUserCustomEvent.getToHour());

			newUserCustomEvent = _notificationsDao.setUserCustomEvent(userSessionId,
					newUserCustomEvent);

			_userCustomEventSource.replaceObject(_activeUserCustomEvent, newUserCustomEvent);

			_activeUserCustomEvent = newUserCustomEvent;
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

	public UserCustomEvent getFilter() {
		if (filter == null) {
			filter = new UserCustomEvent();
		}
		return filter;
	}

	public void setFilter(UserCustomEvent filter) {
		this.filter = filter;
	}

	public UserCustomEvent getNewUserCustomEvent() {
		if (newUserCustomEvent == null) {
			newUserCustomEvent = new UserCustomEvent();
		}
		return newUserCustomEvent;
	}

	public void setNewUserCustomEvent(UserCustomEvent newUserCustomEvent) {
		this.newUserCustomEvent = newUserCustomEvent;
	}

	public void clearBean() {
		_userCustomEventSource.flushCache();
		_itemSelection.clearSelection();
		_activeUserCustomEvent = null;

		// clear dependent bean
		MbCustomObjects objects = (MbCustomObjects) ManagedBeanWrapper
				.getManagedBean("MbCustomObjects");
		objects.clearBean();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeUserCustomEvent != null) {
			curLang = (String) event.getNewValue();
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeUserCustomEvent.getId().toString());
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
//				UserCustomEvent[] devices = _notificationsDao.getUserCustomEvents(userSessionId,
//						params);
//				if (devices != null && devices.length > 0) {
//					_activeUserCustomEvent = devices[0];
//				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
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

	public ArrayList<SelectItem> getSchemeEvents() {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			SchemeEvent[] events = _notificationsDao.getSchemeEvents(userSessionId, params);
			ArrayList<SelectItem> result = new ArrayList<SelectItem>(events.length);
			schemeEvents = new HashMap<Integer, SchemeEvent>(events.length);
			for (SchemeEvent event : events) {
				result.add(new SelectItem(event.getId(), event.getId() + " - "
						+ getDictUtils().getAllArticlesDesc().get(event.getEventType())));
				schemeEvents.put(event.getId(), event);
			}

			return result;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}
	}

	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> modsList;
		if (schemeEvents != null && getNewUserCustomEvent().getSchemeEventId() != null) {
			try {
				Modifier[] mods = _rulesDao.getModifiers(userSessionId, schemeEvents.get(
						newUserCustomEvent.getSchemeEventId()).getScaleId());
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
}

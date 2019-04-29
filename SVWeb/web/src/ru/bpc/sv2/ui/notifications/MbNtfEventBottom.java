package ru.bpc.sv2.ui.notifications;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.notifications.NotificationCustomEvent;
import ru.bpc.sv2.notifications.SchemeEvent;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name="MbNtfEventBottom")
public class MbNtfEventBottom extends AbstractBean {
	private static final Logger logger = Logger.getLogger("NOTIFICATION");
	
	private NotificationsDao _notificationsDao = new NotificationsDao();
	
	private RulesDao _rulesDao = new RulesDao();
	
	private final DaoDataModel<NotificationCustomEvent> _customEventSource;
	private final TableRowSelection<NotificationCustomEvent> _itemSelection;
	private NotificationCustomEvent _activeCustomEvent;
	private Map<String, Object> filter;
	private Map<String, Object> map;
	private String entityType;
	private Long objectId;
	private HashMap<Integer, SchemeEvent> schemeEvents;
	private List<SelectItem>statuses;
	
	private String parentSectionId;
	private String tabName;
	private static String COMPONENT_ID = "ntfTable";
	
	public MbNtfEventBottom(){
		_customEventSource = new DaoDataModel<NotificationCustomEvent>() {
			private static final long serialVersionUID = -7410006776577381648L;

			@Override
			protected NotificationCustomEvent[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NotificationCustomEvent[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if(EntityNames.CARD.equals(entityType)) {
						return _notificationsDao.getObjectNtfEvents(userSessionId, params, map);
					}
					else {
						return _notificationsDao.getNtfEvents(userSessionId, params, map);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);					
				}
				return new NotificationCustomEvent[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					if(EntityNames.CARD.equals(entityType)) {
						return _notificationsDao.getObjectNtfEventsCount(userSessionId, params, map);
					}
					else {
						return _notificationsDao.getNtfEventsCount(userSessionId, params, map);
					}
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);					
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NotificationCustomEvent>(null, _customEventSource);
	}

	@Override
	public void clearFilter() {
		clearBean();
		filter = null;
		searching = false;
	}
	
	public Map<String, Object> getFilter() {
		if (filter == null) {
			filter = new HashMap<String, Object>();
		}
		return filter;
	}
	
	public void setFilters() {
		filter = getFilter();
		map = new HashMap<String, Object>();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (entityType != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
			map.put("entityType", entityType);
		}
		if (objectId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(objectId.toString());
			filters.add(paramFilter);
			map.put("objectId", objectId);
		}
	}
	
	public DaoDataModel<NotificationCustomEvent> getCustomEvents() {
		return _customEventSource;
	}

	public NotificationCustomEvent getActiveCustomEvent() {
		return _activeCustomEvent;
	}

	public void setActiveCustomEvent(NotificationCustomEvent activeCustomEvent) {
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
	}

	public void setFirstRowActive() {
		_customEventSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomEvent = (NotificationCustomEvent) _customEventSource.getRowData();
		selection.addKey(_activeCustomEvent.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}
	
	public void clearBean() {
		_activeCustomEvent = null;
		_customEventSource.flushCache();
		_itemSelection.clearSelection();
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
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
	
	public ArrayList<SelectItem> getHours() {
		ArrayList<SelectItem> hours = new ArrayList<SelectItem>(24);
		for (int i = 0; i < 24; i++) {
			hours.add(new SelectItem(i + "", i + ""));
		}
		return hours;
	}
	
	public List<SelectItem> getStatuses(){
		if (statuses == null){
			statuses = getDictUtils().getLov(LovConstants.NTF_CUSTOM_EVENT_STATUS);
		}
		return statuses;
	}
	
	public void setParentSectionId(String parentSectionId) {
        this.parentSectionId = parentSectionId;
    }

    public void setTabName(String tabName) {
        this.tabName = tabName;
    }
    
    public String getComponentId() {
        return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
    }
}

package ru.bpc.sv2.ui.notifications;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.notifications.CustomObject;
import ru.bpc.sv2.notifications.Notification;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbCustomObjects")
public class MbCustomObjects extends AbstractBean {
	private static final long serialVersionUID = 7196424852948896789L;

	private static final Logger logger = Logger.getLogger("NOTIFICATION");
	
	private NotificationsDao _notificationsDao = new NotificationsDao();
	private IssuingDao _issuingDao = new IssuingDao();

	private CustomObject filter;
	private CustomObject newCustomObject;
	private Long customEventId;

    private final DaoDataModel<CustomObject> _customObjectSource;
	private final TableRowSelection<CustomObject> _itemSelection;
	private CustomObject _activeCustomObject;
	private String tabName;
	
	private static String COMPONENT_ID = "customObjectsTable";
	private String parentSectionId;

	public MbCustomObjects() {
		_customObjectSource = new DaoDataModel<CustomObject>() {
			private static final long serialVersionUID = -290933362570842970L;

			@Override
			protected CustomObject[] loadDaoData(SelectionParams params) {
				if (customEventId == null || !searching) {
					return new CustomObject[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getCustomObjects( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);				
				}
				return new CustomObject[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (customEventId == null || !searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getCustomObjectsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CustomObject>(null, _customObjectSource);
	}

	public DaoDataModel<CustomObject> getCustomObjects() {
		return _customObjectSource;
	}

	public CustomObject getActiveCustomObject() {
		return _activeCustomObject;
	}

	public void setActiveCustomObject(CustomObject activeCustomObject) {
		_activeCustomObject = activeCustomObject;
	}

	public SimpleSelection getItemSelection() {
		if (_activeCustomObject == null && _customObjectSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeCustomObject != null && _customObjectSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeCustomObject.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeCustomObject = _itemSelection.getSingleSelection();
			if (_activeCustomObject.getObjectType() != null) {
				if (_activeCustomObject.getObjectType().equals(EntityNames.CARD)) {
					if (_activeCustomObject.getObjectId() != null) {
						Filter[] filters = new Filter[] {new Filter("id", _activeCustomObject.getObjectId())};
						Card[] cards = _issuingDao.getCards(userSessionId, new SelectionParams(filters));
						if (cards.length > 0) {
							_activeCustomObject.setActiveCard(cards[0]);
						}
					}
				}
			}
			setBeans();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCustomObject = _itemSelection.getSingleSelection();
		
		if (_activeCustomObject != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_customObjectSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCustomObject = (CustomObject) _customObjectSource.getRowData();
		selection.addKey(_activeCustomObject.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeCustomObject != null) {
			setBeans();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}
	
	public void search() {
		clearBean();
		searching = true;		
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new CustomObject();
		searching = false;		
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("customEventId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(customEventId.toString());
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
	}

	public void add() {
		newCustomObject =  new CustomObject();
		newCustomObject.setCustomEventId(customEventId);
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newCustomObject = (CustomObject) _activeCustomObject.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newCustomObject = _activeCustomObject;
		}
		curMode = EDIT_MODE;
	}
	
	public void save() {
		try {
			_notificationsDao.setCustomObject( userSessionId, newCustomObject);
			_customObjectSource.flushCache();
			curMode = VIEW_MODE;
			
			FacesUtils.addMessageInfo(
					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf", "custom_object_saved"));
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
	}
	
	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	public CustomObject getFilter() {
		if (filter == null) {
			filter = new CustomObject();
		}
		return filter;
	}

	public void setFilter(CustomObject filter) {
		this.filter = filter;
	}

	public CustomObject getNewCustomObject() {
		if (newCustomObject == null) {
			newCustomObject = new CustomObject();
		}
		return newCustomObject;
	}

	public void setNewCustomObject(CustomObject newCustomObject) {
		this.newCustomObject = newCustomObject;
	}

	public void clearBean() {
		_customObjectSource.flushCache();
		_itemSelection.clearSelection();
		_activeCustomObject = null;
		
		// clear dependent bean 
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public ArrayList<SelectItem> getEventTypes() {
		return getDictUtils().getArticles(DictNames.EVENT_TYPES, true);
	}

	public Long getCustomEventId() {
		return customEventId;
	}

	public void setCustomEventId(Long customEventId) {
		this.customEventId = customEventId;
	}

	public ArrayList<SelectItem> getHours() {
		ArrayList<SelectItem> hours = new ArrayList<SelectItem>(24);
		for (int i = 0; i < 24; i++) {
			hours.add(new SelectItem(i + "", i + ""));
		}
		return hours;
	}
	
	public ArrayList<SelectItem> getNotifications() {
		ArrayList<SelectItem> items = null;
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			Notification[] notifs = _notificationsDao.getNotifications( userSessionId, params);
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
		ArrayList<SelectItem> items = new ArrayList<SelectItem>(0);
		try {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			Channel[] channels = _notificationsDao.getChannels( userSessionId, params);
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
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public boolean showCardNumberButton() {
		if (getItemSelection() != null && _activeCustomObject != null) {
			if (_activeCustomObject.getActiveCard() != null && _activeCustomObject.getActiveCard().getCardNumber() != null) {
				return true;
			}
		}
		return false;
	}

	public void viewCardNumber() {
		try {
			_issuingDao.viewCardNumber(userSessionId, _activeCustomObject.getActiveCard().getId());
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
}

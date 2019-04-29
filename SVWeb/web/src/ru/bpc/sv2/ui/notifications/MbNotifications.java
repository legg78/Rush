package ru.bpc.sv2.ui.notifications;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.notifications.Notification;
import ru.bpc.sv2.reports.Report;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbNotifications")
public class MbNotifications extends AbstractBean {
	private static final long serialVersionUID = -6541109364718477195L;

	private static final Logger logger = Logger.getLogger("NOTIFICATION");

	private static String COMPONENT_ID = "1575:notificationsTable";

	private NotificationsDao _notificationsDao = new NotificationsDao();

	private ReportsDao _reportsDao = new ReportsDao();

	private Notification filter;
	private Notification newNotification;
	private Notification detailNotification;

	private final DaoDataModel<Notification> _notificationSource;
	private final TableRowSelection<Notification> _itemSelection;
	private Notification _activeNotification;
	private String tabName;
	private ArrayList<SelectItem> institutions;
	private List<SelectItem> eventTypes;

	public MbNotifications() {
		pageLink = "notifications|notifications";
		_notificationSource = new DaoDataModel<Notification>() {
			private static final long serialVersionUID = -1576999692190901387L;

			@Override
			protected Notification[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Notification[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getNotifications(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Notification[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getNotificationsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Notification>(null, _notificationSource);
	}

	public DaoDataModel<Notification> getNotifications() {
		return _notificationSource;
	}

	public Notification getActiveNotification() {
		return _activeNotification;
	}

	public void setActiveNotification(Notification activeNotification) {
		_activeNotification = activeNotification;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeNotification == null && _notificationSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeNotification != null && _notificationSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeNotification.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeNotification = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeNotification.getId())) {
				changeSelect = true;
			}
			_activeNotification = _itemSelection.getSingleSelection();
	
			if (_activeNotification != null) {
				setBeans();
				if (changeSelect) {
					detailNotification = (Notification) _activeNotification.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_notificationSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeNotification = (Notification) _notificationSource.getRowData();
		selection.addKey(_activeNotification.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeNotification != null) {
			setBeans();
			detailNotification = (Notification) _activeNotification.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbNotificationTemplates templates = (MbNotificationTemplates) ManagedBeanWrapper
				.getManagedBean("MbNotificationTemplates");
		templates.clearFilter();
		templates.getFilter().setNotificationId(_activeNotification.getId());
		templates.setReportId(_activeNotification.getReportId());
		templates.search();
	}
	
	public void clearBeans() {
		MbNotificationTemplates templates = (MbNotificationTemplates) ManagedBeanWrapper
				.getManagedBean("MbNotificationTemplates");
		templates.clearFilter();
		templates.clearBean();
	}

	public void search() {
		curLang = userLang;
		clearBean();
		clearBeans();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		clearBean();
		filter = null;
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
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setValue(filter.getName().trim().toUpperCase().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getEventType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("eventType");
			paramFilter.setValue(filter.getEventType());
			filters.add(paramFilter);
		}
		if (filter.getReportId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("reportId");
			paramFilter.setValue(filter.getReportId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newNotification = new Notification();
		newNotification.setLang(userLang);
		curLang = newNotification.getLang();
		if (filter.getInstId() != null) {
			newNotification.setInstId(filter.getInstId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newNotification = (Notification) detailNotification.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			newNotification = _activeNotification;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_notificationsDao.deleteNotification(userSessionId, _activeNotification);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf", "notification_deleted",
					"(id = " + _activeNotification.getId() + ")");

			_activeNotification = _itemSelection.removeObjectFromList(_activeNotification);
			if (_activeNotification == null) {
				clearBean();
				clearBeans();
			} else {
				setBeans();
				detailNotification = (Notification) _activeNotification.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newNotification = _notificationsDao.addNotification(userSessionId, newNotification);
				detailNotification = (Notification) newNotification.clone();
				_itemSelection.addNewObjectToList(newNotification);
			} else {
				newNotification = _notificationsDao
						.editNotification(userSessionId, newNotification);
				detailNotification = (Notification) newNotification.clone();
				if (!userLang.equals(newNotification.getLang())) {
					newNotification = getNodeByLang(_activeNotification.getId(), userLang);
				}

				_notificationSource.replaceObject(_activeNotification, newNotification);
			}
			_activeNotification = newNotification;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"notification_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Notification getFilter() {
		if (filter == null) {
			filter = new Notification();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Notification filter) {
		this.filter = filter;
	}

	public Notification getNewNotification() {
		if (newNotification == null) {
			newNotification = new Notification();
		}
		return newNotification;
	}

	public void setNewNotification(Notification newNotification) {
		this.newNotification = newNotification;
	}

	public void clearBean() {
		_notificationSource.flushCache();
		_itemSelection.clearSelection();
		_activeNotification = null;
		detailNotification = null;
		// clear dependent bean
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("templatesTab")) {
			MbNotificationTemplates bean = (MbNotificationTemplates) ManagedBeanWrapper
					.getManagedBean("MbNotificationTemplates");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_NOTIF_NOTIF;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeNotification != null) {
			curLang = (String) event.getNewValue();
			detailNotification = getNodeByLang(detailNotification.getId(), curLang);
		}
	}
	
	public Notification getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			Notification[] devices = _notificationsDao.getNotifications(userSessionId, params);
			if (devices != null && devices.length > 0) {
				return devices[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		return institutions;
	}

	public List<SelectItem> getEventTypes() {
		if (eventTypes == null) {
			eventTypes = getDictUtils().getLov(LovConstants.EVENT_TYPES);
		}
		return eventTypes;
	}

	public ArrayList<SelectItem> getAllReports() {
		ArrayList<SelectItem> items = null;
		try {
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);

			Report[] reports = _reportsDao.getReportsLight(userSessionId, params);
			items = new ArrayList<SelectItem>(reports.length);
			for (Report report: reports) {
				items.add(new SelectItem(report.getId(), report.getName()));
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

	public ArrayList<SelectItem> getReports() {
		if (getNewNotification().getInstId() == null) {
			return new ArrayList<SelectItem>(0);
		}

		ArrayList<SelectItem> items = null;
		try {
			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(curLang);
			filters[1] = new Filter();
			filters[1].setElement("instId");
			filters[1].setValue(newNotification.getInstId().toString());
			filters[2] = new Filter();
			filters[2].setElement("templatedOnly");
			filters[2].setValue("1");
			
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(Integer.MAX_VALUE);
			params.setFilters(filters);

			Report[] reports = _reportsDao.getReportsLight(userSessionId, params);
			items = new ArrayList<SelectItem>(reports.length);
			for (Report report: reports) {
				items.add(new SelectItem(report.getId(), report.getName()));
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
	
	public void confirmEditLanguage() {
		curLang = newNotification.getLang();
		Notification tmp = getNodeByLang(newNotification.getId(), newNotification.getLang());
		if (tmp != null) {
			newNotification.setName(tmp.getName());
			newNotification.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Notification getDetailNotification() {
		return detailNotification;
	}

	public void setDetailNotification(Notification detailNotification) {
		this.detailNotification = detailNotification;
	}
}

package ru.bpc.sv2.ui.notifications;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.logic.ReportsDao;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.notifications.Notification;
import ru.bpc.sv2.notifications.NotificationTemplate;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbNotificationTemplates")
public class MbNotificationTemplates extends AbstractBean {
	private static final long serialVersionUID = -1287532503414178228L;

	private static final Logger logger = Logger.getLogger("NOTIFICATION");

	private static String COMPONENT_ID = "templatesTable";

	private NotificationsDao _notificationsDao = new NotificationsDao();

	private ReportsDao _reportsDao = new ReportsDao();

	private NotificationTemplate filter;
	private NotificationTemplate newTemplate;

	private final DaoDataModel<NotificationTemplate> _templatesSource;
	private final TableRowSelection<NotificationTemplate> _itemSelection;
	private NotificationTemplate _activeTemplate;
	private String tabName;
	private Integer reportId;
	
	private String parentSectionId;
	
	public MbNotificationTemplates() {
		pageLink = "notifications|templates";
		_templatesSource = new DaoDataModel<NotificationTemplate>() {
			private static final long serialVersionUID = 1184945153322369609L;

			@Override
			protected NotificationTemplate[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NotificationTemplate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getNotificationTemplates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NotificationTemplate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _notificationsDao.getNotificationTemplatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<NotificationTemplate>(null, _templatesSource);
	}

	public DaoDataModel<NotificationTemplate> getTemplates() {
		return _templatesSource;
	}

	public NotificationTemplate getActiveTemplate() {
		return _activeTemplate;
	}

	public void setActiveTemplate(NotificationTemplate activeTemplate) {
		_activeTemplate = activeTemplate;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeTemplate == null && _templatesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeTemplate != null && _templatesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeTemplate.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeTemplate = _itemSelection.getSingleSelection();
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
		_activeTemplate = _itemSelection.getSingleSelection();

		if (_activeTemplate != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_templatesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTemplate = (NotificationTemplate) _templatesSource.getRowData();
		selection.addKey(_activeTemplate.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTemplate != null) {
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
		filter = new NotificationTemplate();
		searching = false;
		reportId = null;
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

		if (filter.getLang() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("templateLang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getLang());
			filters.add(paramFilter);
		}
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
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getChannelId().toString());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newTemplate = new NotificationTemplate();
		newTemplate.setLang(userLang);
		if (filter.getNotificationId() != null) {
			newTemplate.setNotificationId(filter.getNotificationId());
		}
		if (filter.getChannelId() != null) {
			newTemplate.setChannelId(filter.getChannelId());
		}
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newTemplate = (NotificationTemplate) _activeTemplate.clone();
			reportId = newTemplate.getReportId();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newTemplate = _activeTemplate;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_notificationsDao.deleteNotificationTemplate(userSessionId, _activeTemplate);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"notif_template_deleted", "(id = " + _activeTemplate.getId() + ")");

			_activeTemplate = _itemSelection.removeObjectFromList(_activeTemplate);
			if (_activeTemplate == null) {
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
			if (isNewMode()) {
				newTemplate = _notificationsDao.addNotificationTemplate(userSessionId, newTemplate,
						userLang);
				_itemSelection.addNewObjectToList(newTemplate);
			} else {
				newTemplate = _notificationsDao.editNotificationTemplate(userSessionId,
						newTemplate, userLang);

				_templatesSource.replaceObject(_activeTemplate, newTemplate);
			}
			_activeTemplate = newTemplate;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Ntf",
					"notif_template_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public NotificationTemplate getFilter() {
		if (filter == null) {
			filter = new NotificationTemplate();
		}
		return filter;
	}

	public void setFilter(NotificationTemplate filter) {
		this.filter = filter;
	}

	public NotificationTemplate getNewTemplate() {
		if (newTemplate == null) {
			newTemplate = new NotificationTemplate();
		}
		return newTemplate;
	}

	public void setNewTemplate(NotificationTemplate newTemplate) {
		this.newTemplate = newTemplate;
	}

	public void clearBean() {
		_templatesSource.flushCache();
		_itemSelection.clearSelection();
		_activeTemplate = null;

		// clear dependent bean
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeTemplate != null) {
			curLang = (String) event.getNewValue();
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(_activeTemplate.getId().toString());
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
				NotificationTemplate[] devices = _notificationsDao.getNotificationTemplates(
						userSessionId, params);
				if (devices != null && devices.length > 0) {
					_activeTemplate = devices[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public ArrayList<SelectItem> getEventTypes() {
		return getDictUtils().getArticles(DictNames.EVENT_TYPES, true);
	}

	public ArrayList<SelectItem> getReportTemplates() {
		ArrayList<SelectItem> items = null;

		ArrayList<Filter> filters = new ArrayList<Filter>();
		Filter filter = new Filter("lang", newTemplate.getLang());
		filters.add(filter);
		filter = new Filter("templateLang", newTemplate.getLang());
		filters.add(filter);
		if (reportId != null) {
			filter = new Filter("reportId", reportId);
			filters.add(filter);
		} else if (newTemplate.getNotificationId() != null) {
			filter = new Filter("notifId", newTemplate.getNotificationId());
			filters.add(filter);
		}
		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		try {
			ReportTemplate[] templates = _reportsDao.getReportTemplatesLight(userSessionId, params);
			items = new ArrayList<SelectItem>(templates.length);
			for (ReportTemplate template: templates) {
				items.add(new SelectItem(template.getId(), template.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addSystemError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}

		return items;
	}

	public ArrayList<SelectItem> getNotifications() {
		ArrayList<SelectItem> items = null;

		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
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
		ArrayList<SelectItem> items = null;

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		Filter[] filters = new Filter[1];
		filters[0] = new Filter("lang", curLang);
		params.setFilters(filters);

		try {
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

	public String getComponentId() {
		if (parentSectionId != null && tabName != null) {
			return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
		} else {
			return "1593:templatesTable";
		}
	}

	public Logger getLogger() {
		return logger;
	}

	public Integer getReportId() {
		return reportId;
	}

	public void setReportId(Integer reportId) {
		this.reportId = reportId;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}

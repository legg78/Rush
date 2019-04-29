package ru.bpc.sv2.logic;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import javax.xml.transform.TransformerException;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.notifications.Channel;
import ru.bpc.sv2.notifications.CustomEvent;
import ru.bpc.sv2.notifications.CustomObject;
import ru.bpc.sv2.notifications.Notification;
import ru.bpc.sv2.notifications.NotificationCustomEvent;
import ru.bpc.sv2.notifications.NotificationMessage;
import ru.bpc.sv2.notifications.NotificationPrivConstants;
import ru.bpc.sv2.notifications.NotificationTemplate;
import ru.bpc.sv2.notifications.Scheme;
import ru.bpc.sv2.notifications.SchemeEvent;
import ru.bpc.sv2.notifications.UserCustomEvent;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class NotificationsDao
 */
public class NotificationsDao extends IbatisAware {

	@SuppressWarnings("unchecked")
	public Scheme[] getSchemes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATION_SCHEMES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATION_SCHEMES);
			List<Scheme> schemes = ssn.queryForList("ntf.get-schemes", convertQueryParams(params, limitation));
			return schemes.toArray(new Scheme[schemes.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSchemesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATION_SCHEMES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATION_SCHEMES);
			return (Integer) ssn
			        .queryForObject("ntf.get-schemes-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Scheme addScheme(Long userSessionId, Scheme scheme) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.ADD_NOTIF_SCHEME, paramArr);

			ssn.insert("ntf.add-scheme", scheme);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(scheme.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(scheme.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Scheme) ssn.queryForObject("ntf.get-schemes", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Scheme editScheme(Long userSessionId, Scheme scheme) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.MODIFY_NOTIF_SCHEME, paramArr);

			ssn.update("ntf.edit-scheme", scheme);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(scheme.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(scheme.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Scheme) ssn.queryForObject("ntf.get-schemes", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteScheme(Long userSessionId, Scheme scheme) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(scheme.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.REMOVE_NOTIF_SCHEME, paramArr);

			ssn.delete("ntf.delete-scheme", scheme);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Notification[] getNotifications(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATIONS);
			List<Notification> notifications = ssn.queryForList("ntf.get-notifications",
			        convertQueryParams(params, limitation));
			return notifications.toArray(new Notification[notifications.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNotificationsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATIONS);
			return (Integer) ssn.queryForObject("ntf.get-notifications-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Notification addNotification(Long userSessionId, Notification notification) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(notification.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.ADD_NOTIFICATION, paramArr);

			ssn.insert("ntf.add-notification", notification);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(notification.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(notification.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Notification) ssn.queryForObject("ntf.get-notifications",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Notification editNotification(Long userSessionId, Notification notification) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(notification.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.MODIFY_NOTIFICATION, paramArr);

			ssn.update("ntf.edit-notification", notification);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(notification.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(notification.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Notification) ssn.queryForObject("ntf.get-notifications",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNotification(Long userSessionId, Notification notification) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(notification.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.REMOVE_NOTIFICATION, paramArr);

			ssn.delete("ntf.delete-notification", notification);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SchemeEvent[] getSchemeEvents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIF_SCHEME_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIF_SCHEME_EVENTS);
			List<SchemeEvent> schemeEvents = ssn.queryForList("ntf.get-scheme-events",
			        convertQueryParams(params, limitation));
			return schemeEvents.toArray(new SchemeEvent[schemeEvents.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSchemeEventsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIF_SCHEME_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIF_SCHEME_EVENTS);
			return (Integer) ssn.queryForObject("ntf.get-scheme-events-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SchemeEvent addSchemeEvent(Long userSessionId, SchemeEvent schemeEvent, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(schemeEvent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.ADD_NOTIF_SCHEME_EVENT, paramArr);

			ssn.insert("ntf.add-scheme-event", schemeEvent);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(lang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(schemeEvent.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (SchemeEvent) ssn.queryForObject("ntf.get-scheme-events",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SchemeEvent editSchemeEvent(Long userSessionId, SchemeEvent schemeEvent, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(schemeEvent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.MODIFY_NOTIF_SCHEME_EVENT, paramArr);

			ssn.update("ntf.edit-scheme-event", schemeEvent);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(lang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(schemeEvent.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (SchemeEvent) ssn.queryForObject("ntf.get-scheme-events",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteSchemeEvent(Long userSessionId, SchemeEvent schemeEvent) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(schemeEvent.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.REMOVE_NOTIF_SCHEME_EVENT, paramArr);

			ssn.delete("ntf.delete-scheme-event", schemeEvent);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NotificationTemplate[] getNotificationTemplates(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATION_TEMPLATES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATION_TEMPLATES);
			List<NotificationTemplate> templates = ssn.queryForList("ntf.get-templates",
			        convertQueryParams(params, limitation));
			return templates.toArray(new NotificationTemplate[templates.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNotificationTemplatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATION_TEMPLATES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATION_TEMPLATES);
			return (Integer) ssn.queryForObject("ntf.get-templates-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NotificationTemplate addNotificationTemplate(Long userSessionId,
			NotificationTemplate template, String userLang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.ADD_NOTIF_TEMPLATE, paramArr);

			ssn.insert("ntf.add-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(userLang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(template.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NotificationTemplate) ssn.queryForObject("ntf.get-templates",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NotificationTemplate editNotificationTemplate(Long userSessionId,
			NotificationTemplate template, String userLang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.MODIFY_NOTIF_TEMPLATE, paramArr);

			ssn.update("ntf.edit-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(userLang);
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(template.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NotificationTemplate) ssn.queryForObject("ntf.get-templates",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNotificationTemplate(Long userSessionId, NotificationTemplate template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.REMOVE_NOTIF_TEMPLATE, paramArr);

			ssn.delete("ntf.delete-template", template);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Channel[] getChannels(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CHANNELS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CHANNELS);
			List<Channel> channels = ssn.queryForList("ntf.get-channels",
			        convertQueryParams(params, limitation));
			return channels.toArray(new Channel[channels.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getChannelsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CHANNELS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CHANNELS);
			return (Integer) ssn.queryForObject("ntf.get-channels-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Channel addChannel(Long userSessionId, Channel channel) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(channel.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.ADD_CHANNEL, paramArr);

			ssn.insert("ntf.add-channel", channel);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(channel.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(channel.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Channel) ssn.queryForObject("ntf.get-channels", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Channel editChannel(Long userSessionId, Channel channel) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(channel.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.MODIFY_CHANNEL, paramArr);

			ssn.update("ntf.edit-channel", channel);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(channel.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(channel.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Channel) ssn.queryForObject("ntf.get-channels", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteChannel(Long userSessionId, Channel channel) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(channel.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.REMOVE_CHANNEL, paramArr);

			ssn.delete("ntf.delete-channel", channel);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CustomEvent[] getCustomEvents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_EVENTS);
			List<CustomEvent> events = ssn.queryForList("ntf.get-custom-events", convertQueryParams(params, limitation));
			return events.toArray(new CustomEvent[events.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e.getCause().getMessage(), e);
		} finally {
			close(ssn);
		}
	}


	public int getCustomEventsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_EVENTS);
			return (Integer) ssn.queryForObject("ntf.get-custom-events-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CustomEvent[] getUserCustomEvents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_EVENTS);
			List<CustomEvent> events = ssn.queryForList("ntf.get-user-custom-events",
			        convertQueryParams(params, limitation));
			return events.toArray(new CustomEvent[events.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getUserCustomEventsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_EVENTS);
			return (Integer) ssn.queryForObject("ntf.get-user-custom-events-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CustomEvent setCustomEvent(Long userSessionId, CustomEvent event) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(event.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.SET_CUSTOM_EVENT, paramArr);

			ssn.update("ntf.set-custom-event", event);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(event.getId().toString());
			
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(event.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CustomEvent) ssn.queryForObject("ntf.get-user-custom-events",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public UserCustomEvent setUserCustomEvent(Long userSessionId, CustomEvent event) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(event.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.SET_CUSTOM_EVENT, paramArr);

			ssn.update("ntf.set-custom-event", event);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(event.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(event.getLang());
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (UserCustomEvent) ssn.queryForObject("ntf.get-user-custom-events",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCustomEvent(Long userSessionId, CustomEvent event) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(event.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.REMOVE_CUSTOM_EVENT, paramArr);

			ssn.delete("ntf.delete-custom-event", event);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CustomObject[] getCustomObjects(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_OBJECTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_OBJECTS);
			List<CustomObject> objects = ssn.queryForList("ntf.get-custom-objects",
			        convertQueryParams(params, limitation));
			return objects.toArray(new CustomObject[objects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCustomObjectsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_OBJECTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_OBJECTS);
			return (Integer) ssn.queryForObject("ntf.get-custom-objects-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long setCustomObject(Long userSessionId, CustomObject object) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(object.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.SET_CUSTOM_OBJECT, paramArr);

			ssn.update("ntf.set-custom-object", object);

			return object.getId();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CustomEvent[] getRoleCustomEvents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_EVENTS);
			List<CustomEvent> events = ssn.queryForList("ntf.get-role-custom-events",
			        convertQueryParams(params, limitation));
			return events.toArray(new CustomEvent[events.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRoleCustomEventsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_CUSTOM_EVENTS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_CUSTOM_EVENTS);
			return (Integer) ssn.queryForObject("ntf.get-role-custom-events-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NotificationMessage[] getNotificationMessages(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATION_MESSAGES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATION_MESSAGES);
			List<NotificationMessage> notifMess = ssn.queryForList("ntf.get-notification-messages",
			        convertQueryParams(params, limitation));
			for (int i = 0; i < notifMess.size(); i++){
				javax.xml.transform.TransformerFactory transFact = javax.xml.transform.TransformerFactory
						.newInstance();
				String text = notifMess.get(i).getText();
				int start = text.indexOf("<datasource><report>");
				int end = text.indexOf("</report>");
				if (start < 0 || end < 0){
					continue;
				}
				start += "<datasource>".length();
				end += "</report>".length();
				String xmlSours = text.substring(start, end );
				int startXsl = text.indexOf("</datasource><template>");
				int endXsl = text.indexOf("</template>");
				if (startXsl < 0 || endXsl < 0){
					continue;
				}
				startXsl += "</datasource><template>".length();
				String xslSours = text.substring(startXsl, endXsl);
				xslSours = xslSours.replace("<![CDATA[", "").replace("]]>", "");
				InputStream xmlStream = new ByteArrayInputStream(xmlSours.getBytes());

				InputStream xsltStream = new ByteArrayInputStream(xslSours.getBytes());
				ByteArrayOutputStream xmlResultStream = new ByteArrayOutputStream();
				javax.xml.transform.Source xmlSource = new javax.xml.transform.stream.StreamSource(
						xmlStream);

				
				javax.xml.transform.Source xsltSource = new javax.xml.transform.stream.StreamSource(
						xsltStream);

				javax.xml.transform.Result result = new javax.xml.transform.stream.StreamResult(
						xmlResultStream);
				try{
					javax.xml.transform.Transformer trans = transFact.newTransformer(xsltSource);
	
					trans.transform(xmlSource, result);
					notifMess.get(i).setText(xmlResultStream.toString());
				}catch (TransformerException e){
					continue;
				}
			}
			return notifMess.toArray(new NotificationMessage[notifMess.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNotificationMEssagesCount(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATION_MESSAGES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotificationPrivConstants.VIEW_NOTIFICATION_MESSAGES);
			return (Integer) ssn.queryForObject("ntf.get-notification-messages-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	
	@SuppressWarnings("unchecked")
	public NotificationCustomEvent[] getNtfEvents(Long userSessionId, SelectionParams params, Map<String, Object> map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATIONS, paramArr);
			ssn.update("ntf.get-notification-settings", map);
			List <NotificationCustomEvent>ntfs = (List<NotificationCustomEvent>)map.get("ref_cur");
			return ntfs.toArray(new NotificationCustomEvent[ntfs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public int getNtfEventsCount(Long userSessionId, SelectionParams params, Map<String, Object> map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATIONS, paramArr);
			ssn.update("ntf.get-notification-settings", map);
			List <NotificationCustomEvent>ntfs = (List<NotificationCustomEvent>)map.get("ref_cur");
			return ntfs.size();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NotificationCustomEvent[] getObjectNtfEvents(Long userSessionId, SelectionParams params, Map<String, Object> map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATIONS, paramArr);
			ssn.update("ntf.get-object-notification-settings", map);
			List <NotificationCustomEvent>ntfs = (List<NotificationCustomEvent>)map.get("ref_cur");
			return ntfs.toArray(new NotificationCustomEvent[ntfs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public int getObjectNtfEventsCount(Long userSessionId, SelectionParams params, Map<String, Object> map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATIONS, paramArr);
			ssn.update("ntf.get-object-notification-settings", map);
			List <NotificationCustomEvent>ntfs = (List<NotificationCustomEvent>)map.get("ref_cur");
			return ntfs.size();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public NotificationMessage[] getNotificationMessagesCur(Long userSessionId,
			SelectionParams params, Map<String, Object> paramsMap) {
		SqlMapSession ssn = null;
		try{
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotificationPrivConstants.VIEW_NOTIFICATION_MESSAGES, paramArr);
			QueryParams qparams = convertQueryParams(params);
			paramsMap.put("first_row", qparams.getRange().getStartPlusOne());
			paramsMap.put("last_row", qparams.getRange().getEndPlusOne());
			paramsMap.put("sorting_tab", params.getSortElement());
			ssn.update("ntf.get-notification-message-prc", paramsMap);
			List<NotificationMessage> result = (List<NotificationMessage>)paramsMap.get("ref_cur");
			return  result.toArray(new NotificationMessage[result.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNotificationMessagesCountCur(Long userSessionId, Map<String, Object> paramsMap) {
		Integer result = 0;
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			ssn.update("ntf.get-notification-message-prc-count", paramsMap);
			result = (Integer)paramsMap.get("row_count");
		}catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public void changeStatus(Long userSessionId, Map params) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			ssn.update("ntf.change-status", params);
		}catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		
	}
}

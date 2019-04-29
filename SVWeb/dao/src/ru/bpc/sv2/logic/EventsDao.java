package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.ObjectEntity;
import ru.bpc.sv2.common.events.*;
import ru.bpc.sv2.evt.EventObject;
import ru.bpc.sv2.evt.StatusLog;
import ru.bpc.sv2.evt.StatusMap;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Session Bean implementation class EventsDao
 */
public class EventsDao extends AbstractDao {
	private static final Logger logger = Logger.getLogger("EVENTS");
	private static final String sqlMap = "events";

	@Override
	protected Logger getLogger() {
		return logger;
	}
	@Override
	protected String getSqlMap() {
		return sqlMap;
	}

	@SuppressWarnings("unchecked")
	public EventSubscriber[] getEventSubscribers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_SUBSCRIBER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_SUBSCRIBER);
			List<EventSubscriber> subscribers = ssn.queryForList("events.get-subscribers",
					convertQueryParams(params, limitation));
			return subscribers.toArray(new EventSubscriber[subscribers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEventSubscribersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_SUBSCRIBER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_SUBSCRIBER);
			return (Integer) ssn.queryForObject("events.get-subscribers-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventSubscriber addEventSubscriber(Long userSessionId, EventSubscriber subscriber) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(subscriber.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.ADD_EVENT_SUBSCRIBER, paramArr);

			ssn.insert("events.add-subscriber", subscriber);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(subscriber.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EventSubscriber) ssn.queryForObject("events.get-subscribers",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public EventSubscriber modifyEventSubscriber(Long userSessionId, EventSubscriber subscriber) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(subscriber.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.MODIFY_EVENT_SUBSCRIBER, paramArr);

			ssn.update("events.modify-subscriber", subscriber);

			return subscriber;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteEventSubscriber(Long userSessionId, EventSubscriber subscriber) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(subscriber.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.REMOVE_EVENT_SUBSCRIBER, paramArr);

			ssn.delete("events.remove-subscriber", subscriber);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Event[] getEvents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT);
			List<Event> events = ssn.queryForList("events.get-events", convertQueryParams(params,
					limitation));
			return events.toArray(new Event[events.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEventsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT);
			return (Integer) ssn.queryForObject("events.get-events-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Event addEvent(Long userSessionId, Event event, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(event.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.ADD_EVENT, paramArr);

			ssn.insert("events.add-event", event);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(event.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Event) ssn.queryForObject("events.get-events", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Event modifyEvent(Long userSessionId, Event event, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(event.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.MODIFY_EVENT, paramArr);

			ssn.update("events.modify-event", event);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(event.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Event) ssn.queryForObject("events.get-events", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteEvent(Long userSessionId, Event event) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(event.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.REMOVE_EVENT, paramArr);

			ssn.delete("events.remove-event", event);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public EventType[] getEventTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_TYPE);
			List<EventType> types = ssn.queryForList("events.get-event-types", convertQueryParams(
					params, limitation));
			return types.toArray(new EventType[types.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEventTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_TYPE);
			return (Integer) ssn.queryForObject("events.get-event-types-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventType addEventType(Long userSessionId, EventType type) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(type.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.ADD_EVENT_TYPE, paramArr);

			ssn.insert("events.add-event-type", type);

			return type;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventType editEventType(Long userSessionId, EventType type) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(type.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.MODIFY_EVENT_TYPE, paramArr);

			ssn.insert("events.modify-event-type", type);

			return type;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteEventType(Long userSessionId, EventType type) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(type.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.REMOVE_EVENT_TYPE, paramArr);

			ssn.delete("events.remove-event-type", type);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public EventRuleSet[] getEventRuleSets(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_RULE_SET, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_RULE_SET);
			List<EventRuleSet> sets = ssn.queryForList("events.get-event-rule-sets",
					convertQueryParams(params, limitation));
			return sets.toArray(new EventRuleSet[sets.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEventRuleSetsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_RULE_SET, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_RULE_SET);
			return (Integer) ssn.queryForObject("events.get-event-rule-sets-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventRuleSet addEventRuleSet(Long userSessionId, EventRuleSet set, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(set.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.ADD_EVENT_RULE_SET, paramArr);

			ssn.insert("events.add-event-rule-set", set);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(set.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EventRuleSet) ssn.queryForObject("events.get-event-rule-sets",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventRuleSet editEventRuleSet(Long userSessionId, EventRuleSet set, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(set.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.MODIFY_EVENT_RULE_SET, paramArr);

			ssn.update("events.modify-event-rule-set", set);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(set.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EventRuleSet) ssn.queryForObject("events.get-event-rule-sets",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteEventRuleSet(Long userSessionId, EventRuleSet set) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(set.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.REMOVE_EVENT_RULE_SET, paramArr);

			ssn.delete("events.remove-event-rule-set", set);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public EventSubscription[] getEventSubscriptions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_SUBSCRIPTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_SUBSCRIPTION);
			List<EventSubscription> subscriptions = ssn.queryForList("events.get-subscriptions",
					convertQueryParams(params, limitation));
			return subscriptions.toArray(new EventSubscription[subscriptions.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getEventSubscriptionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_EVENT_SUBSCRIPTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_EVENT_SUBSCRIPTION);
			return (Integer) ssn.queryForObject("events.get-subscriptions-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventSubscription addEventSubscription(Long userSessionId,
			EventSubscription subscription, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(subscription.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.ADD_EVENT_SUBSCRIPTION, paramArr);

			ssn.insert("events.add-subscription", subscription);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(subscription.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EventSubscription) ssn.queryForObject("events.get-subscriptions",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventSubscription modifyEventSubscription(Long userSessionId,
			EventSubscription subscription, String lang) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(subscription.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.MODIFY_EVENT_SUBSCRIPTION, paramArr);

			ssn.update("events.modify-subscription", subscription);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(subscription.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (EventSubscription) ssn.queryForObject("events.get-subscriptions",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteEventSubscription(Long userSessionId, EventSubscription subscription) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(subscription.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.REMOVE_EVENT_SUBSCRIPTION, paramArr);

			ssn.delete("events.remove-subscription", subscription);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public StatusLog[] getStatusLogs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_STATUS_LOG, paramArr);

			List<StatusLog> logs = ssn.queryForList("events.get-status-logs",
					convertQueryParams(params));
			return logs.toArray(new StatusLog[logs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getStatusLogsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_STATUS_LOG, paramArr);

			return (Integer) ssn.queryForObject("events.get-status-logs-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public StatusLog[] getCardStatusLogs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_CARD_STATUS_LOG, paramArr);

			List<StatusLog> logs = ssn.queryForList("events.get-card-status-logs",
					convertQueryParams(params));
			return logs.toArray(new StatusLog[logs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getCardStatusLogsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_CARD_STATUS_LOG, paramArr);

			return (Integer) ssn.queryForObject("events.get-card-status-logs-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public List<Integer> getChangeReasonsLov(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return ssn.queryForList("events.get-change-reason-lovs", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void changeStatus(Long userSessionId, StatusLog statusLog) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("events.change-status", statusLog);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public String changeStatusByNewStatus(Long userSessionId, StatusLog statusLog) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("events.change-status-by-new-status", statusLog);
			return statusLog.getStatus();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public StatusMap[] getStatusMaps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_STATUS_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_STATUS_MAPPING);
			List<StatusMap> statusMaps = ssn.queryForList("events.get-status-maps",
					convertQueryParams(params, limitation));
			return statusMaps.toArray(new StatusMap[statusMaps.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public StatusMap[] getStatusInstMaps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_STATUS_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_STATUS_MAPPING);
			List<StatusMap> statusMaps = ssn.queryForList("events.get-status-inst-maps",
					convertQueryParams(params, limitation));
			return statusMaps.toArray(new StatusMap[statusMaps.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getStatusMapsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.VIEW_STATUS_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					EventPrivConstants.VIEW_STATUS_MAPPING);
			return (Integer) ssn.queryForObject("events.get-status-maps-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StatusMap addStatusMap(Long userSessionId, StatusMap statusMap, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(statusMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.ADD_STATUS_MAPPING, paramArr);
			ssn.insert("events.add-status-map", statusMap);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(statusMap.getId().toString());

			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (StatusMap) ssn.queryForObject("events.get-status-inst-maps",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StatusMap editStatusMap(Long userSessionId, StatusMap statusMap, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(statusMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.MODIFY_STATUS_MAPPING, paramArr);
			ssn.update("events.modify-status-map", statusMap);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(statusMap.getId().toString());

			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (StatusMap) ssn.queryForObject("events.get-status-inst-maps",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteStatusMap(Long userSessionId, StatusMap statusMap) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(statusMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, EventPrivConstants.REMOVE_STATUS_MAPPING, paramArr);
			ssn.delete("events.remove-status-map", statusMap);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void registerEvent(RegisteredEvent event) throws UserException {
		registerEvent(event, null, null);
	}
	

	public void registerEvent(RegisteredEvent event, Long userSessionId, String userName)
			throws UserException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null){
				ssn = getIbatisSession(userSessionId, userName);
			}else{
				ssn = getIbatisSessionNoContext();
			}
			ssn.delete("events.register-event", event);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
		
	}


	public void registerEvent(RegisteredEvent event, Long userSessionId) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			ssn.update("events.register-event", event);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	public void removeEventObject(RegisteredEvent event) throws UserException {
		delete(event, "remove-event-object");
	}

	@SuppressWarnings("unchecked")
	public EventObject[] getEventObjects(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<EventObject> eventObjects = ssn.queryForList("events.get-event-objects", convertQueryParams(params));
			return eventObjects.toArray(new EventObject[eventObjects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public EventObject[] getEventObjects(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<EventObject> eventObjects = ssn.queryForList("events.get-event-objects", convertQueryParams(params));
			return eventObjects.toArray(new EventObject[eventObjects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public EventSubscriber checkSubscription(Long userSessionId, EventSubscriber subscriber) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			SelectionParams params = SelectionParams.build("procedureName",  subscriber.getProcedureName(), "priority",  subscriber.getPriority());

			List<EventSubscriber> subscribers = ssn.queryForList("events.get-subscribers", convertQueryParams(params));

			EventSubscriber eventSubscriber = null;
			for(EventSubscriber subscr : subscribers){
				if(!subscr.getEventType().equals(subscriber.getEventType())){
					eventSubscriber = subscr;
				}
			}

			return eventSubscriber;
			
		}catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}	
	}

	public String getObjectStatus(Long userSessionId, String entityType, Long objectId) {
		Object status = execute(userSessionId, new ObjectEntity(objectId, entityType), "get-object-status");
		return (status != null) ? (String)status : null;
	}

	public void returnStatus(Long sessionId, String user) {
		Map <String, Object> map = new HashMap<String, Object>(1);
		map.put("session_id", sessionId);
		execute(sessionId, map, "return-status");
	}

	public String getStatusReason(Long sessionId, Long id, String entityType) {
		Map<String, Object> map = new HashMap<String, Object>(3);
		map.put("id", id);
		map.put("type", entityType);
		try {
			map = execute(sessionId, map, "get-status-reason");
		} catch (Exception ignored) {
			logger.warn(ignored.getLocalizedMessage());
		}
		return (map.get("result") != null) ? map.get("result").toString() : "";
	}
}
